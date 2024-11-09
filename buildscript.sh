#!/bin/bash

git remote remove origin && git remote add origin git@Debian:0mniteck/debian.git
git submodule update --init --recursive
# git pull --recurse-submodules
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

pushd debian-slim/
docker buildx build --load --tag omniteck-debian-slim .
rm -f *.spdx.json
mkdir -p "$HOME/syft" && TMPDIR="$HOME/syft" syft scan docker:omniteck-debian-slim -o spdx-json=debian-slim.manifest.spdx.json && rm -f -r "$HOME/syft" 
docker tag docker:omniteck-debian-slim 0mniteck/debian-slim:10-30-2024 && docker push 0mniteck/debian-slim:10-30-2024
git status && git add -A && git status
git commit -a -S -m "Successful Build of debian-slim:10-30-2024" && git push --set-upstream origin docker-slim
popd

pushd debian/
docker buildx build --load --tag omniteck-debian .
rm -f *.spdx.json
mkdir -p "$HOME/syft" && TMPDIR="$HOME/syft" syft scan docker:omniteck-debian -o spdx-json=debian.manifest.spdx.json && rm -f -r "$HOME/syft" 
docker tag docker:omniteck-debian 0mniteck/debian:10-30-2024 && docker push 0mniteck/debian:10-30-2024
git status && git add -A && git status
git commit -a -S -m "Successful Build of debian:10-30-2024" && git push --set-upstream origin docker
popd

pushd debian-extra/
docker buildx build --load --tag omniteck-debian-extra .
rm -f *.spdx.json
mkdir -p "$HOME/syft" && TMPDIR="$HOME/syft" syft scan docker:omniteck-debian-extra -o spdx-json=debian-extra.manifest.spdx.json && rm -f -r "$HOME/syft" 
docker tag docker:omniteck-debian-extra 0mniteck/debian-extra:10-30-2024 && docker push 0mniteck/debian-extra:10-30-2024
git status && git add -A && git status
git commit -a -S -m "Successful Build of debian-extra:10-30-2024" && git push --set-upstream origin docker-extra
popd

git submodule update --recursive
git status && git add -A && git status
git commit -a -S -m "Successful Build of Tagged Release 2024-10-30" && git push --set-upstream origin builder
git tag -a 2024-10-30 -S -m "First tagged release" && git push origin 2024-10-30
docker logout

snap disable docker
rm -f -r /var/snap/docker/*
rm -f -r /var/snap/docker
sleep 10
snap remove docker --purge
snap remove docker --purge
ufw -f enable
