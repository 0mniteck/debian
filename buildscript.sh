#!/bin/bash
docker='/snap/docker/current/bin/docker'
run_as=$(id -u $(echo $PKEXEC_UID) -n)
HOME=/home/$run_as

rel_date="01-22-2026"
date_rel="2026-01-22"

debian_security="20260122T200547Z"
debian="20260122T143611Z"
source="debian:trixie-20260112-slim@sha256:5a777b4bb3cfd59d2def8e0db5e3e70a9bfa262d7f5f2251a4b0ee84d7b45193"

if [[ "$(echo $PKEXEC_UID)" == "" ]]; then
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

if [[ "$(cat /lib/udev/rules.d/60-scdaemon.rules | grep plugdev)" != *plugdev* ]]; then
  usermod -aG plugdev $run_as
  sed -i 's/"1050", ATTR{idProduct}=="040.", /&MODE="0660", GROUP="plugdev", /g' /lib/udev/rules.d/60-scdaemon.rules
  udevadm control --reload-rules && udevadm trigger
  while [[ "$(lsusb | grep Yubikey)" == *Yubikey* ]]; do
    printf "\rPlease remove yubikey...\033[K"
  done
  while [[ "$(lsusb | grep Yubikey)" != *Yubikey* ]]; do
    printf "\rPlease re-insert yubikey...\033[K"
  done
  sleep 5
fi

if [[ "$(ls -la /dev/hidraw* | grep plugdev)" != *plugdev* ]]; then
  chown $run_as:plugdev /dev/hidraw*
fi

apt install -y gnupg2 gpg-agent pcscd pkexec rootlesskit scdaemon slirp4netns snapd uidmap
snap install syft --classic
snap install grype --classic
snap remove docker --purge
snap install docker --revision=3380
snap stop docker

> $HOME/rootless.sh
cat >> $HOME/rootless.sh << __EOF
#!/bin/bash
rootlesskit --copy-up=/etc --copy-up=/run --net=slirp4netns --disable-host-loopback --state-dir $HOME/tmp bash -i -c '
env > $HOME/tmp/environment-docker
grep ROOTLESS $HOME/tmp/environment-docker >> $HOME/tmp/environment-rootless
echo "HOME=$HOME" >> $HOME/tmp/environment-rootless
echo "XDG_RUNTIME_DIR=/run/user/$(id -u)" >> $HOME/tmp/environment-rootless
echo "PATH=$PATH:/snap/docker/current/bin" >> $HOME/tmp/environment-rootless
echo "\$(echo \$(<$HOME/tmp/environment-rootless)) /snap/docker/current/bin/dockerd --rootless" | bash 2> $HOME/tmp/log'
__EOF
chmod +x $HOME/rootless.sh
chown $run_as:$run_as $HOME/rootless.sh

mkdir -p /home/root
sed -i "s':/root:':/home/root:'" /etc/passwd
sed -i "s|\[Service\]|\[Service\]\\
User=$(echo $run_as)|" /etc/systemd/system/snap.docker.dockerd.service
sed -i "s|EnvironmentFile.*|EnvironmentFile=-$HOME/tmp/environment-rootless|" /etc/systemd/system/snap.docker.dockerd.service
sed -i "s|ExecStart.*|ExecStart=/bin/bash -c \'$HOME/rootless.sh\'|" /etc/systemd/system/snap.docker.dockerd.service
sed -i "s|\[Service\]|\[Service\]\\
User=$(echo $run_as)|" /etc/systemd/system/snap.docker.nvidia-container-toolkit.service
mkdir -p /usr/libexec/docker/cli-plugins
ln -s /snap/docker/current/usr/libexec/docker/cli-plugins/docker-buildx /usr/libexec/docker/cli-plugins/docker-buildx
systemctl daemon-reload && wait
snap start docker && wait

machinectl shell $run_as@ /bin/bash -c "
cd $(echo $PWD)

scan_using_grype() { # $1 = Name, $2 = Type:Name
  grype config > /home/$run_as/.grype.yaml
  TMPDIR=/home/$run_as/syft SYFT_CACHE_DIR=/home/$run_as/syft syft scan \$2 -o spdx-json=\$1.spdx.json && rm -f -r /home/$run_as/syft/* && wait
  script -q -c \"TMPDIR=/home/$run_as/grype GRYPE_DB_CACHE_DIR=/home/$run_as/grype grype sbom:\$1.spdx.json -c /home/$run_as/.grype.yaml \
  -o json > \$1.grype.json\" \$1.grype.tmp.tmp > \$1.grype.tmp && rm -f -r /home/$run_as/grype/* && wait
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

mkdir -p /home/$run_as/syft && mkdir -p /home/$run_as/grype
eval \"\$(ssh-agent -s)\" && ssh-add /home/$run_as/.ssh/id_ecdsa_s*[!.pub]
systemctl --user restart gpg-agent && wait && systemctl status snap.docker.dockerd --no-pager -n 0
export DOCKER_HOST=unix:///run/user/$run_as/docker.sock && $docker info | grep rootless
git remote remove origin && git remote add origin git@Debian:0mniteck/Debian.git
git submodule update --init --remote --merge
$docker login && export BUILDX_METADATA_PROVENANCE=max && export BUILDX_METADATA_WARNINGS=1

if [[ \"\$(gpg-card list)\" == *42E2DDF1E31B370F8BFFEE03287EE837E6ED2DD3* ]]; then
  echo && echo \"Signing key 287EE837E6ED2DD3 present\" && echo
else
  echo \"Signing key 287EE837E6ED2DD3 missing\!\"
  read -p \"Check Yubikey and try again.\"
  lsusb
  exit 0
fi

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
rm -f -r /var/snap/docker/ && wait
snap remove docker --purge
snap remove docker --purge
networkctl delete docker0
snap remove syft --purge
rm -f -r /home/$run_as/syft
snap remove grype --purge
rm -f -r /home/$run_as/grype
