#!/bin/bash

rel_date="11-11-2024"
date_rel="2024-11-11"

debian_security="20241111T212343Z"
debian="20241111T203302Z"

source="debian:bookworm-20241111-slim@sha256:046de794712cf47a9ea8995d8f8d77f61230d8da7655b6dbfa1eb1b86feabbf5"

git remote remove origin && git remote add origin git@Debian:0mniteck/debian.git
git submodule update --init $1 --recursive
sudo apt install -y snapd
sudo snap install syft --classic
sudo snap install grype --classic
rm -f -r /var/snap/docker*
snap remove docker --purge
mkdir /var/snap/docker
chown root:root /var/snap/docker
snap install docker --revision=2936 && ufw disable && sleep 5
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
grype sbom:$module.manifest.spdx.json -o json > $module.grype.json
docker tag omniteck-$module:latest 0mniteck/$module:$rel_date
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
rm -f -r /var/snap/docker*
sleep 5
snap remove docker --purge
snap remove docker --purge
ufw -f enable
snap remove syft --purge
snap remove grype --purge
