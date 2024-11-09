#!/bin/bash

rel_date="11-9-2024"
date_rel="2024-11-9"

debian_security="20241109T084744Z"
debian="20241109T082826Z"

source="debian:bookworm-20241016-slim@sha256:936ea04e67a02e5e83056bfa8c7331e1c9ae89d4a324bbc1654d9497b815ae56"

git remote remove origin && git remote add origin git@Debian:0mniteck/debian.git
git submodule update --init $1 --recursive
sudo apt install -y snapd
sudo snap install syft --classic
rm -f -r /var/snap/docker/*
rm -f -r /var/snap/docker
snap remove docker --purge
mkdir /var/snap/docker
chown root:root /var/snap/docker
snap install docker --revision=2936 && ufw disable
sleep 10
docker buildx create --name debian-builder --bootstrap --use
docker login

for module in debian-slim debian debian-extra
do
pushd $module/
git remote remove origin && git remote add origin git@Debian:0mniteck/debian.git
docker buildx build --load \
--tag omniteck-$module \
--build-arg REL_DATE=$rel_date \
--build-arg DEBIAN=$debian \
--build-arg DEBIAN_SECURITY=$debian_security \
--build-arg SOURCE=$source .
rm -f $module.manifest.spdx.json
mkdir -p "$HOME/syft" && TMPDIR="$HOME/syft" syft scan docker:omniteck-$module -o spdx-json=$module.manifest.spdx.json && rm -f -r "$HOME/syft" 
docker tag omniteck-debian-slim:latest 0mniteck/$module:$rel_date
docker push 0mniteck/$module:$rel_date > push.log
echo "$(cat push.log | grep digest)" > push.log && cat push.log
git status && git add -A && git status
git commit -a -S -m "Successful Build of $module:$(cat push.log)" && git push --set-upstream origin HEAD:$module
popd
done

git status && git add -A && git status
git commit -a -S -m "Successful Build of Release $date_rel" && git push --set-upstream origin builder
git tag -a $date_rel -s -m "Tagged Release $date_rel" && git push origin $date_rel
docker logout

snap disable docker
rm -f -r /var/snap/docker/*
rm -f -r /var/snap/docker
sleep 10
snap remove docker --purge
snap remove docker --purge
ufw -f enable
