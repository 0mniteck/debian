#!/bin/bash

rel_date="04-24-2025"
date_rel="2025-04-24"

debian_security="20250424T134513Z"
debian="20250424T144915Z"
source="debian:bookworm-20250407-slim@sha256:912d8a461ca5f85380a40de97d7b38dfcc39972de210518de07136126dd0bfa9"

export GRYPE_DB_CACHE_DIR="$HOME"
export TMPDIR="$HOME"

git remote remove origin && git remote add origin git@Debian:0mniteck/debian.git
git submodule update --init $1 --recursive
sudo apt install -y snapd
sudo snap install syft --classic
sudo snap install grype --classic
rm -f -r /var/snap/docker*
snap remove docker --purge
mkdir /var/snap/docker
chown root:root /var/snap/docker
snap install docker --revision=3065
docker buildx create --name debian-builder --driver-opt "network=host" --bootstrap --use
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
networkctl delete docker0
snap remove syft --purge && rm -f -r $HOME/.cache/syft
snap remove grype --purge
rm /root/getter* -f -r && rm /root/grype-scratch* -f -r && rm /root/6 -f -r && rm -f -r $HOME/.cache/grype && rm -f -r /tmp/grype-scratch*
