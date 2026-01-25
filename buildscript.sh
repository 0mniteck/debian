#!/bin/bash

run_id=$PKEXEC_UID
run_as=$(id -u $run_id -n)
home=/home/$run_as
systemd_path=/etc/systemd/system/snap.docker
buildx_path=usr/libexec/docker/cli-plugins
snap_path=snap/docker/current
docker_path=/$snap_path/bin
rootless_path=$home/.rootless
docker=$docker_path/docker

rel_date="01-24-2026"
date_rel="2026-01-24"

debian_security=20260122T200547Z
debian=20260122T143611Z
source=debian:trixie-20260112-slim@sha256:5a777b4bb3cfd59d2def8e0db5e3e70a9bfa262d7f5f2251a4b0ee84d7b45193

if [[ "$run_id" == "" ]]; then
  if [[ "$(whoami)" == *root* ]]; then
    echo "DO NOT run with sudo or su!"
    echo "Instead Use: ~\$ 'pkexec --keep-cwd ./buildscript.sh'"
    exit 1
  else
    echo "Super user is required for installation steps."
    echo "Use ~\$ 'pkexec --keep-cwd ./buildscript.sh'"
    exit 1
  fi
fi

apt install -y gnupg2 gpg-agent \
               pcscd pkexec rootlesskit \
               scdaemon slirp4netns snapd systemd-container uidmap
snap install syft --classic && wait
snap install grype --classic && wait
snap remove docker --purge && wait
snap install docker --revision=3380 && wait && sleep 5
snap set docker nvidia-support.disabled=true && wait
snap stop docker && wait
rm -r -f /run/docker*
rm -r -f /run/snap.docker/*
rm -r -f /run/containerd/
rm -r -f /run/user/1000/docker*
rm -r -f /run/user/1000/runc/
groupadd -fr docker && usermod -aG docker $run_as && wait

machinectl shell $run_as@ /bin/bash -c "
docker login && mkdir -p $home/.docker && \
ln -s $home/$snap_path/.docker/config.json $home/.docker/config.json || exit 1"

> $home/rootless.sh
cat >> $home/rootless.sh << __EOF
#!/bin/bash
rootlesskit --copy-up=/etc --copy-up=/run --net=slirp4netns --disable-host-loopback --state-dir $rootless_path /bin/bash -i -c '
env > $rootless_path/env-docker
grep ROOTLESS $rootless_path/env-docker > $rootless_path/env-rootless
echo "HOME=$home
XDG_RUNTIME_DIR=/run/user/$run_id
XDG_CONFIG_HOME=$home
DOCKER_TMPDIR=$home/.docker/tmp
PATH=\$PATH:$docker_path" >> $rootless_path/env-rootless
echo "\$(echo \$(<$rootless_path/env-rootless)) $(echo $docker)d --rootless --feature cdi=false --group docker" | /bin/bash 2> $rootless_path/log'
__EOF
chmod +x $home/rootless.sh && chown $run_as:$run_as $home/rootless.sh

mkdir -p /home/root
sed -i "s':/root:':/home/root:'" /etc/passwd
sed -i "s|\[Service\]|\[Service\]\\
User=$run_as\\
Group=$run_as\\
Slice=docker.slice|" $systemd_path.dockerd.service
sed -i "s|EnvironmentFile.*|EnvironmentFile=-$rootless_path/env-rootless|" \
$systemd_path.dockerd.service
sed -i "s|ExecStart.*|ExecStart=/bin/bash -c \'$home/rootless.sh\'|" \
$systemd_path.dockerd.service
sed -i "s|\[Service\]|\[Service\]\\
User=$run_as\\
Group=$run_as\\
Slice=docker.slice|" $systemd_path.nvidia-container-toolkit.service

snap set docker nvidia-support.disabled=true && wait
systemctl daemon-reload && wait && snap start docker && wait

mkdir -p /$buildx_path && wait && \
ln -s /$snap_path/$buildx_path/docker-buildx /$buildx_path/docker-buildx

if [[ "$(cat /lib/udev/rules.d/60-scdaemon.rules | grep $run_as)" != *$run_as* ]]; then
  sed -i "s/\"1050\", ATTR{idProduct}==\"040.\", /&MODE=\"0660\", GROUP=\"$run_as\", /g" /lib/udev/rules.d/60-scdaemon.rules
  udevadm control --reload-rules && udevadm trigger
  while [[ "$(lsusb | grep Yubikey)" == *Yubikey* ]]; do
    printf "\rPlease remove yubikey...\033[K"
  done
  while [[ "$(lsusb | grep Yubikey)" != *Yubikey* ]]; do
    printf "\rPlease re-insert yubikey...\033[K"
  done && sleep 1 && echo
fi

chown $run_as:$run_as /dev/hidraw*

machinectl shell $run_as@ /bin/bash -c "
cd $(echo $PWD)

scan_using_grype() { # $1 = Name, $2 = Type:Name
  grype config > $home/.grype.yaml
  TMPDIR=$home/syft SYFT_CACHE_DIR=$home/syft syft scan \$2 -o spdx-json=\$1.spdx.json
  rm -f -r $home/syft/* && wait
  script -q -c \"TMPDIR=$home/grype GRYPE_DB_CACHE_DIR=$home/grype grype sbom:\$1.spdx.json \
  -c $home/.grype.yaml -o json > \$1.grype.json\" \$1.grype.tmp.tmp > \$1.grype.tmp
  rm -f -r $home/grype/* && wait
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

systemctl status snap.docker.dockerd --no-pager -n 0
export BUILDX_METADATA_PROVENANCE=max && export BUILDX_METADATA_WARNINGS=1
export DOCKER_HOST=unix:///run/user/$run_id/docker.sock
$docker info && $docker info | grep rootless >> $rootless_path/log

eval \"\$(ssh-agent -s)\" && ssh-add $home/.ssh/id_ecdsa_s*[!.pub]
systemctl --user restart gpg-agent && wait
git remote remove origin && git remote add origin git@Debian:0mniteck/Debian.git
git submodule update --init --remote --merge

if [[ \"\$(gpg-card list)\" == *42E2DDF1E31B370F8BFFEE03287EE837E6ED2DD3* ]]; then
  echo && echo \"Signing key 287EE837E6ED2DD3 present\" && echo
else
  echo \"Signing key 287EE837E6ED2DD3 missing\!\"
  read -p \"Check Yubikey and try again.\"
  lsusb
  exit 1
fi

mkdir -p $home/syft && mkdir -p $home/grype
for module in debian-slim debian debian-extra
do
  pushd \$module/
    git remote remove origin && git remote add origin git@Debian:0mniteck/Debian.git
    rm -f \$module.spdx.json \$module.meta.json \$module.grype.json \$module.grype.status digest readme.md push.log
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
    --build-arg SOURCE=$source .
    scan_using_grype \$module docker:0mniteck/\$module
    $docker buildx stop --name \$module-builder && wait
    $docker buildx rm -f --all-inactive && wait
    $docker buildx ls && $docker buildx prune -f -a
    echo 0mniteck/\$module:$rel_date > digest
    cat \$module.meta.json | grep '\"digest\": \"sha256' >> digest
    echo '## ' >> readme.md && cat digest >> readme.md && cat readme.md
    git status && git add -A && git status
    git commit -a -S -m \"Successful Build of \$module:$rel_date\" && git push --set-upstream origin HEAD:\$module
  popd
done

$docker logout && cat ./*/digest > digests && git status && git add -A && git status
git commit -a -S -m \"Successful Build of Release $date_rel\" && git push --set-upstream origin builder
git tag -a $date_rel -s -m \"Tagged Release $date_rel\" && git push origin $date_rel
eval \"\$(ssh-agent -k)\""

snap disable docker
snap remove docker --purge
snap remove docker --purge
networkctl delete docker0
snap remove syft --purge
rm -f -r $home/syft
snap remove grype --purge
rm -f -r $home/grype
