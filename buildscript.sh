#!/bin/bash

# debug="set -x" # uncomment to enable debugging
$debug

rel_date=$(date -d "$(date)" +"%m-%d-%Y")
date_rel=$(date -d "$(date)" +"%Y-%m-%d")

docker_snap_ver=3380
debian_security=20260201T214338Z
debian=20260202T022019Z
source="debian:trixie-20260112-slim@sha256:5a777b4bb3cfd59d2def8e0db5e3e70a9bfa262d7f5f2251a4b0ee84d7b45193"

run_id=$PKEXEC_UID
run_as=$(id -u $run_id -n)

if [[ "$run_id" == "" ]]; then
  if [[ "$(whoami)" == *root* ]]; then
    echo && echo "DO NOT run with sudo or su root"
    echo "Instead Use: ~\$ 'pkexec --keep-cwd ./buildscript.sh'" && echo
    exit 1
  else
    echo && echo "Pkexec is required for installation steps"
    echo "Using: ~\$ 'pkexec --keep-cwd ./buildscript.sh'" && echo
    exec pkexec --keep-cwd "$0" "$@"
    exit 0
  fi
fi

if [[ "$(cat /lib/udev/rules.d/60-scdaemon.rules | grep $run_as)" != *$run_as* ]]; then
  sed -i "s/\"1050\", ATTR{idProduct}==\"040.\", /&MODE=\"0660\", GROUP=\"$run_as\", /g" \
  /lib/udev/rules.d/60-scdaemon.rules
  udevadm control --reload-rules && udevadm trigger
fi

while [[ "$(lsusb | grep Yubikey)" != *Yubikey* ]]; do
  printf "\rPlease insert yubikey...\033[K"
done && sleep 1 && echo

chown $run_as:$run_as /dev/hidraw*

DEVICE=$(lsusb -d 1050:0407 | grep -o Device.... - | grep -o [0-9][0-9][0-9])
BUS=$(lsusb -d 1050:0407 | grep -o Bus.... - | grep -o [0-9][0-9][0-9])
setfacl -m u:$run_as:rw /dev/bus/usb/$BUS/$DEVICE

home=/home/$run_as
data_dir=$home/.local/share
sysusr_path=$data_dir/systemd/user
rootless_path=$data_dir/rootless
docker_data=$data_dir/docker
snap_path=snap/docker/current
docker_path=/$snap_path/bin
docker=$docker_path/docker
systemd_service=/etc/systemd/system/snap.docker.dockerd.service
sysusr_service=$sysusr_path/docker.dockerd.service
buildx_path=usr/libexec/docker/cli-plugins

sed_ech=$(cat << _EOF__
\\\\[Service\\\\]\\
Group=$run_as\\
Slice=docker.slice\\
_EOF__
)

rm -r -f /home/root/*
rm -r -f /root/snap/docker/
rm -r -f /var/snap/docker/
rm -r -f /run/snap.docker/
rm -r -f /run/containerd/
rm -r -f /run/docker*
rm -r -f /run/runc/
rm -r -f /usr/libexec/docker/
rm -r -f /var/lib/snapd/cache/*

apt-get -qq update && apt-get -qq upgrade -y
apt-get -qq install -y gnupg2 gpg-agent \
               jq pkexec rootlesskit \
               scdaemon slirp4netns snapd \
               systemd-container uidmap

snap install syft --classic && wait
snap install grype --classic && wait
snap remove docker --purge && wait || echo "Failed to remove Docker"
networkctl delete docker0 2>/dev/null
snap install docker --revision=$docker_snap_ver && wait || echo "Failed to install Docker"

snap stop docker && wait
systemctl reset-failed && wait
systemctl stop snap.docker* --all && wait
systemctl mask snap.docker.dockerd --runtime --now && wait
networkctl delete docker0 2>/dev/null

rm -r -f /home/root/*
rm -r -f /root/snap/docker/
rm -r -f /run/snap.docker/
rm -r -f /run/containerd/
rm -r -f /run/docker*
rm -r -f /run/runc/
rm -r -f /usr/libexec/docker/
rm -r -f /var/lib/snapd/cache/*

groupadd -f docker && wait # Keep docker group for fumctionality, but do not add as system group (-r)
usermod -aG docker $run_as && wait
mkdir -p /home/root && sed -i "s|:/root:|:/home/root:|" /etc/passwd #rootlesskit fakeroot

mkdir -p /$buildx_path && wait && \
ln -s /$snap_path/$buildx_path/docker-buildx /$buildx_path/docker-buildx || exit 1

machinectl shell $run_as@ /bin/bash -c "
cd $(echo $PWD)
$debug
rm -r -f /home/$run_as/.docker/
rm -r -f /home/$run_as/.local/share/docker/
rm -r -f /home/$run_as/.local/share/rootless*
rm -r -f /home/$run_as/.local/share/systemd/
rm -r -f /run/user/$run_id/containerd/
rm -r -f /run/user/$run_id/docker*
rm -r -f /run/user/$run_id/runc/

docker login && mkdir -p $docker_data/.docker && wait && \
ln -s $home/$snap_path/.docker/config.json $docker_data/.docker/config.json || exit 1

mkdir -p $rootless_path/tmp && wait
> $rootless_path.sh && > $rootless_path/env-docker && > $rootless_path/env-rootless && chmod +x $rootless_path.sh && wait

cat >> $rootless_path.sh << __EOF
#!/bin/bash
$debug
mkdir -p $rootless_path/tmp && wait
> $rootless_path/env-docker && > $rootless_path/env-rootless && wait
rootlesskit --copy-up=/etc --copy-up=/run --net=slirp4netns --disable-host-loopback --state-dir $rootless_path/tmp /bin/bash -i -c '
env > $rootless_path/env-docker && grep ROOTLESS $rootless_path/env-docker > $rootless_path/env-rootless && rm -f $rootless_path/env-docker
echo \"HOME=$home
XDG_CONFIG_HOME=$home
XDG_RUNTIME_DIR=/run/user/$run_id
DOCKER_TMPDIR=$docker_data/tmp
DOCKER_CONFIG=$docker_data/.docker
DOCKER_HOST=unix:///run/user/$run_id/docker.sock
BUILDX_METADATA_PROVENANCE=max
BUILDX_METADATA_WARNINGS=1
PATH=/usr/sbin:/usr/bin:/snap/bin:$docker_path\" >> $rootless_path/env-rootless
sed \"s/^/export -- /g\" $rootless_path/env-rootless > $rootless_path/env-rootless.exp
\$(echo \"echo echo $\(\<$rootless_path/env-rootless\)\" $(echo $docker)d --rootless \
--userland-proxy-path=$docker_path/docker-proxy --init-path=$docker_path/docker-init \
--feature cdi=false --group docker) | /bin/bash | /bin/bash 2>> $rootless_path/rootless.log'
__EOF

mkdir -p $sysusr_path && wait && \
cp $systemd_service $sysusr_service || exit 1

sed -z -i \"s|\[Service\]\nEnv|$(printf \"%s\\\\n\" $(echo $sed_ech))Env|\" $sysusr_service
sed -i \"s|EnvironmentFile.*|EnvironmentFile=-$rootless_path/env-rootless|\" $sysusr_service
sed -i \"s|ExecStart.*|ExecStart=/bin/bash -c \'$data_dir/rootless.sh\'|\" $sysusr_service

scan_using_grype() { # $1 = Name, $2 = Name:tag
  grype config > $docker_data/.grype.yaml
  TMPDIR=$docker_data/syft SYFT_CACHE_DIR=$docker_data/syft syft scan \$2 --from docker -o spdx-json=\$1.spdx.json
  rm -f -r $docker_data/syft/* && wait
  script -q -c \"TMPDIR=$docker_data/grype GRYPE_DB_CACHE_DIR=$docker_data/grype grype sbom:\$1.spdx.json \
  -c $docker_data/.grype.yaml -o json > \$1.grype.json\" \$1.grype.tmp.tmp > \$1.grype.tmp
  rm -f -r $docker_data/grype/* && wait
  marker() { # $1 = Name, $2 = Order, $3 = Marker/ID
    grep \"\$3\" \$1.grype.tmp | tail -n 1 > \$1.grype.status.\$2
    tr -d '\000-\037\177' < \$1.grype.status.\$2 | sed '/^$/d' > \$1.grype.status.\$2.tmp
    line1=\$(cat \$1.grype.status.\$2)
    if [[ \"\$line1\" == *\$3* ]]; then
      export \"wright\$2\"=\"\$line1\"
    fi
  }
  marker \$1 1 \"✔ Scanned for vulnerabilities\"
  marker \$1 2 \"├── by severity:\"
  marker \$1 3 \"└── by status:\"
  echo \$wright1 > \$1.grype.status
  echo \$wright2 >> \$1.grype.status
  echo \$wright3 >> \$1.grype.status
  sed -i 's/[^[:print:]]//g' \$1.grype.status
  sed -i 's/\[K//g' \$1.grype.status
  sed -i 's/\[2A//g' \$1.grype.status
  sed -i 's/\[3A//g' \$1.grype.status
  rm -f \$1.grype.tmp*
  rm -f \$1.grype.status.*
  cp \$1.grype.status readme.md
  sed -i '1,3s/^/#### /g' readme.md
}

systemctl --user reset-failed && wait
systemctl --user stop docker* --all && wait
systemctl --user daemon-reload && wait
systemctl --user list-units docker* --all
systemctl --user start docker.dockerd && sleep 10
systemctl --user status docker* --all --no-pager -n 150 > $rootless_path/rootless.ctl.log

source $rootless_path/env-rootless.exp
$docker info | grep \"rootless\" > $rootless_path/rootless.status
if [[ \"\$(grep root $rootless_path/rootless.status)\" != *rootless* ]]; then
  echo && echo \"Rootless Docker Failed\" && echo
  exit 1
else
  echo && echo \"Rootless Docker Started\" && echo
  echo \"Rootless Docker Started\" > $rootless_path/rootless.status
fi

eval \"\$(ssh-agent -s)\"
ssh-add -l -L -t 1D -h git@github.com $home/.ssh/id_ecdsa_s*[!.pub]
systemctl --user restart gpg-agent* --all && wait
git submodule update --init --remote --merge

git remote remove origin && git remote add origin git@Debian:0mniteck/Debian.git
git config --global user.email 10482171+0mniteck@users.noreply.github.com
git config --global user.name "Shant Patrick Tchatalbachian"
git config --global user.signingkey 287EE837E6ED2DD3

if [[ \"\$(gpg-card list)\" == *42E2DDF1E31B370F8BFFEE03287EE837E6ED2DD3* ]]; then
  echo && echo \"Signing key 287EE837E6ED2DD3 present\" && echo
else
  echo \"Signing key 287EE837E6ED2DD3 missing\"
  echo \"Check Yubikey and try again.\"
  lsusb && ls -la /dev/hid* && gpg-card list
  systemctl --user status gpg-agent* --all
  ls -la $home/.gnupg
  exit 1
fi

mkdir -p $docker_data/syft && mkdir -p $docker_data/grype
for module in debian-slim debian debian-extra
do
  pushd \$module/
    git remote remove origin && git remote add origin git@Debian:0mniteck/Debian.git
    rm -f \$module.* digest readme.md
    $docker buildx create \
    --name \$module-builder --buildkitd-flags \"--oci-worker-rootless=true\" \
    --driver docker-container --driver-opt \"network=host,default-load=true\" --bootstrap --use
    $docker buildx build --push \
    --tag 0mniteck/\$module:$rel_date \
    --metadata-file \$module.meta.json \
    --attest \"type=provenance,mode=max\" \
    --build-arg REL_DATE=$rel_date \
    --build-arg DEBIAN=$debian \
    --build-arg DEBIAN_SECURITY=$debian_security \
    --build-arg SOURCE=\"$source\" .
    scan_using_grype \$module 0mniteck/\$module:$rel_date
    $docker buildx stop \$module-builder && wait
    $docker buildx rm -f --all-inactive && wait
    $docker buildx ls && $docker buildx prune -f -a
    echo '# '0mniteck/\$module:$rel_date > \$module.image.digest
    cat \$module.meta.json | jq .[] | tail -n 2 | grep sha256 | sed 's/\"//g' >> \$module.image.digest
    echo '## ' >> readme.md && cat \$module.image.digest >> readme.md && cat readme.md
    git status && git add -A && git status
    git commit -a -S -m \"Successful Build of \$module:$rel_date\" && git push --set-upstream origin HEAD:\$module
  popd
done

$docker logout && cat ./*/*.digest > image.digests && git status && git add -A && git status
git commit -a -S -m \"Successful Build of Release $date_rel\" && git push --set-upstream origin builder
git tag -a $date_rel -s -m \"Tagged Release $date_rel\" && git push origin $date_rel
ssh-add -D && eval \"\$(ssh-agent -k)\"

systemctl --user reset-failed && wait
systemctl --user stop docker* --all && wait
rm -r -f /home/$run_as/snap/docker/
rm -r -f /home/$run_as/.docker/
rm -r -f /home/$run_as/.local/share/docker/
rm -r -f /home/$run_as/.local/share/rootless*
rm -r -f /home/$run_as/.local/share/systemd/
rm -r -f /run/user/$run_id/containerd/
rm -r -f /run/user/$run_id/docker*
rm -r -f /run/user/$run_id/runc/
systemctl --user daemon-reload
systemctl --user list-units docker* --all"

systemctl unmask snap.docker.dockerd --runtime
snap disable docker
snap remove docker --purge || echo "Failed to remove Docker"
networkctl delete docker0 2>/dev/null
snap remove grype --purge
snap remove syft --purge

sed -i "s|:/home/root:|:/root:|" /etc/passwd
delgroup docker

rm -r -f /home/root/*
rm -r -f /root/snap/docker/
rm -r -f /var/snap/docker/
rm -r -f /run/snap.docker/
rm -r -f /run/containerd/
rm -r -f /run/docker*
rm -r -f /run/runc/
rm -r -f /usr/libexec/docker/
rm -r -f /var/lib/snapd/cache/*

exit 0
