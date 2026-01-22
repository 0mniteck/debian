#!/bin/bash

rel_date="1-15-2026"
date_rel="2026-1-15"

debian_security="20260115T193932Z"
debian="20260115T202701Z"
source="debian:trixie-20260112-slim@sha256:5a777b4bb3cfd59d2def8e0db5e3e70a9bfa262d7f5f2251a4b0ee84d7b45193"

apt install -y snapd
snap install syft --classic
snap install grype --classic
rm -f -r /var/snap/docker*
snap remove docker --purge
mkdir /var/snap/docker
chown root:root /var/snap/docker
snap install docker --revision=3380

if [[ "$(grep debian- $(echo /root/.gitconfig))" != *debian-* ]]; then
  git config --global --add safe.directory $(echo /home/$(id -u 1000 -n))/Debian
  git config --global --add safe.directory $(echo /home/$(id -u 1000 -n))/Debian/debian-slim
  git config --global --add safe.directory $(echo /home/$(id -u 1000 -n))/Debian/debian
  git config --global --add safe.directory $(echo /home/$(id -u 1000 -n))/Debian/debian-extra
fi

machinectl shell $(id -u 1000 -n)@ /bin/bash -c "
cd $(echo $PWD)
eval \"$(ssh-agent -s)\"
ssh-add /home/$(id -u 1000 -n)/.ssh/id_ecdsa_s*[!.pub]

scan_using_grype() { # $1 = Name, $2 = Type:Name
  grype config > /home/$(id -u 1000 -n)/.grype.yaml
  mkdir -p '/home/$(id -u 1000 -n)/syft' && TMPDIR=/home/$(id -u 1000 -n)/syft SYFT_CACHE_DIR=/home/$(id -u 1000 -n)/syft syft scan \$2 -o spdx-json=\$1.spdx.json && rm -f -r '/home/$(id -u 1000 -n)/syft'
  mkdir -p '/home/$(id -u 1000 -n)/grype' && script -q -c \"TMPDIR=/home/$(id -u 1000 -n)/grype GRYPE_DB_CACHE_DIR=/home/$(id -u 1000 -n)/grype grype sbom:\$1.spdx.json -c /home/$(id -u 1000 -n)/.grype.yaml -o json > \$1.grype.json\" \$1.grype.tmp.tmp > \$1.grype.tmp && rm -f -r '/home/$(id -u 1000 -n)/grype'
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

if [[ \"$(grep debian- $(echo /home/$(id -u 1000 -n))/.gitconfig)\" != *debian-* ]]; then
  git config --global --add safe.directory $(echo /home/$(id -u 1000 -n))/Debian
  git config --global --add safe.directory $(echo /home/$(id -u 1000 -n))/Debian/debian-slim
  git config --global --add safe.directory $(echo /home/$(id -u 1000 -n))/Debian/debian
  git config --global --add safe.directory $(echo /home/$(id -u 1000 -n))/Debian/debian-extra
fi

git remote remove origin && git remote add origin git@Debian:0mniteck/Debian.git
git submodule update --init --remote --merge
docker buildx create --name debian-builder --driver-opt \"network=host\" --bootstrap --use
docker login

for module in debian-slim debian debian-extra
do
  pushd \$module/
    git remote remove origin && git remote add origin git@Debian:0mniteck/Debian.git
    rm -f \$module.spdx.json
    rm -f \$module.meta.json
    rm -f \$module.grype.json
    rm -f \$module.grype.status
    rm -f digest
    rm -f readme.md
    rm -f push.log
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
    cat push.log | grep digest > digest
    git status && git add -A && git status
  popd
done
docker logout
git status && git add -A && git status"

for module in debian-slim debian debian-extra
do
  pushd $module/
    git commit -a -S -m "Successful Build of $module:$(cat push.log)" && git push --set-upstream origin HEAD:$module
  popd
done
git commit -a -S -m "Successful Build of Release $date_rel" && git push --set-upstream origin builder
git tag -a $date_rel -s -m "Tagged Release $date_rel" && git push origin $date_rel

snap disable docker
rm -f -r /var/snap/docker*
sleep 5
snap remove docker --purge
snap remove docker --purge
networkctl delete docker0
snap remove syft --purge
snap remove grype --purge

# rm $HOME/getter* -f -r && rm $HOME/grype-scratch* -f -r && rm $HOME/syft -f -r && rm $HOME/6 -f -r && rm $HOME/Library -f -r
# rm -f -r $HOME/.cache/grype && rm -f -r $HOME/.cache/syft && rm -f -r /tmp/grype-scratch* && rm -f -r /tmp/getter*
