#!/bin/bash

run_as=$1

rel_date="1-21-2026"
date_rel="2026-1-21"

debian_security="20260120T213558Z"
debian="20260115T202701Z"
source="debian:trixie-20260112-slim@sha256:5a777b4bb3cfd59d2def8e0db5e3e70a9bfa262d7f5f2251a4b0ee84d7b45193"

apt install -y snapd gnupg2 gpg-agent pcscd scdaemon
snap install syft --classic
snap install grype --classic
rm -f -r /var/snap/docker*
snap remove docker --purge
mkdir /var/snap/docker
chown root:root /var/snap/docker
snap install docker --revision=3380

usermod -aG plugdev $run_as
sed -i 's/"1050", ATTR{idProduct}=="0407", /"1050", MODE="0660", GROUP="plugdev", ATTR{idProduct}=="0407", /g' /lib/udev/rules.d/60-scdaemon.rules
udevadm control --reload-rules && udevadm trigger
if [[ "$(ls -la /dev/hidraw* | grep plugdev)" != *plugdev* ]]; then
  if [[ "$(lsusb | grep Yubikey)" == *Yubikey* ]]; then read -p "Plugin any Yubikeys again then hit enter..."; fi
  chown $run_as:plugdev /dev/hidraw*
fi

if [[ "$(grep debian- $(echo /root/.gitconfig))" != *debian-* ]]; then
  git config --global --add safe.directory /home/$run_as/Debian
  git config --global --add safe.directory /home/$run_as/Debian/debian-slim
  git config --global --add safe.directory /home/$run_as/Debian/debian
  git config --global --add safe.directory /home/$run_as/Debian/debian-extra
fi

machinectl shell $run_as@ /bin/bash -c "
cd $(echo $PWD)
eval \"\$(ssh-agent -s)\"
ssh-add /home/$run_as/.ssh/id_ecdsa_s*[!.pub]
systemctl --user restart gpg-agent && wait
if [[ \"\$(gpg-card list)\" == *42E2DDF1E31B370F8BFFEE03287EE837E6ED2DD3* ]]; then
  echo \"Signing key present\"
else
  echo \"Signing key missing\"
  read -p \"Check Yubikey and try again.\"
  exit 0
fi

mkdir -p /home/$run_as/syft
mkdir -p /home/$run_as/grype

scan_using_grype() { # $1 = Name, $2 = Type:Name
  grype config > /home/$run_as/.grype.yaml
  TMPDIR=/home/$run_as/syft SYFT_CACHE_DIR=/home/$run_as/syft syft scan \$2 -o spdx-json=\$1.spdx.json && rm -f -r /home/$run_as/syft/*
  script -q -c \"TMPDIR=/home/$run_as/grype GRYPE_DB_CACHE_DIR=/home/$run_as/grype grype sbom:\$1.spdx.json -c /home/$run_as/.grype.yaml -o json > \$1.grype.json\" \$1.grype.tmp.tmp > \$1.grype.tmp && rm -f -r /home/$run_as/grype/*
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
  cat readme.md
}

if [[ \"$(grep debian- $(echo /home/$run_as)/.gitconfig)\" != *debian-* ]]; then
  git config --global --add safe.directory $(echo /home/$run_as)/Debian
  git config --global --add safe.directory $(echo /home/$run_as)/Debian/debian-slim
  git config --global --add safe.directory $(echo /home/$run_as)/Debian/debian
  git config --global --add safe.directory $(echo /home/$run_as)/Debian/debian-extra
fi

git remote remove origin && git remote add origin git@Debian:0mniteck/Debian.git
git submodule update --init --remote --merge
docker buildx create --name debian-builder --driver-opt \"network=host\" --bootstrap --use
docker login

for module in debian-slim debian debian-extra
do
  pushd \$module/
    git remote remove origin && git remote add origin git@Debian:0mniteck/Debian.git
    rm -f \$module.spdx.json \$module.meta.json \$module.grype.json \$module.grype.status digest readme.md push.log
    docker buildx build --load \
    --tag omniteck-\$module \
    --metadata-file \$module.meta.json \
    --build-arg REL_DATE=$rel_date \
    --build-arg DEBIAN=$debian \
    --build-arg DEBIAN_SECURITY=$debian_security \
    --build-arg SOURCE=$source .
    scan_using_grype \$module docker:omniteck-\$module
    docker tag omniteck-\$module:latest 0mniteck/\$module:$rel_date
    docker push 0mniteck/\$module:$rel_date > push.log
    echo 0mniteck/\$module:$rel_date > digest
    cat push.log | grep digest >> digest
    cat digest
    git status && git add -A && git status
    git commit -a -S -m \"Successful Build of \$module:\$(cat push.log | grep digest)\" && git push --set-upstream origin HEAD:\$module
  popd
done

docker logout
cat ./*/digest > digests
git status && git add -A && git status
git commit -a -S -m \"Successful Build of Release $date_rel\" && git push --set-upstream origin builder
git tag -a $date_rel -s -m \"Tagged Release $date_rel\" && git push origin $date_rel
eval \"\$(ssh-agent -k)\""

# chown -R $run_as:$run_as *
snap disable docker
rm -f -r /var/snap/docker*
sleep 5
snap remove docker --purge
snap remove docker --purge
networkctl delete docker0
snap remove syft --purge
rm -f -r /home/$run_as/syft
snap remove grype --purge
rm -f -r /home/$run_as/grype
