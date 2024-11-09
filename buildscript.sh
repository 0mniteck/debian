#!/bin/bash

rel_date=11-9-2024
date_rel=2024-11-9

git remote remove origin && git remote add origin git@Debian:0mniteck/debian.git
git submodule update --init --remote --recursive
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
docker buildx build --load --tag omniteck-$module .
rm -f $module.manifest.spdx.json
mkdir -p "$HOME/syft" && TMPDIR="$HOME/syft" syft scan docker:omniteck-$module -o spdx-json=$module.manifest.spdx.json && rm -f -r "$HOME/syft" 
docker tag omniteck-debian-slim:latest 0mniteck/$module:$rel_date
docker push 0mniteck/$module:$rel_date > 
git status && git add -A && git status
git commit -a -S -m "Successful Build of $module:$rel_date" && git push --set-upstream origin HEAD:$module
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
