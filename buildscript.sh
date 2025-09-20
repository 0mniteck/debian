#!/bin/bash

rel_date="09-19-2025"
date_rel="2025-09-19"

debian_security="20250919T182858Z"
debian="20250919T203151Z"
source="debian:trixie-20250908-slim@sha256:57801c95cab6cb8003835d78008f0ec0655bed246f9038be25df807427a1971d"

export GRYPE_DB_CACHE_DIR="$HOME"
export TMPDIR="$HOME"

scan_using_grype() { # $1 = Name, $2 = Type:[Name]
    if [ -f "$HOME/.grype.yaml" ]; then GRCONF="-c $HOME/.grype.yaml"; fi
    mkdir -p "$HOME/syft" && TMPDIR="$HOME/syft" syft scan $2 -o spdx-json=$1.spdx.json && rm -f -r "$HOME/syft"
    script -q -c "grype $GRCONF sbom:$1.spdx.json -o json > $1.grype.json" $1.grype.tmp
    grep "✔ Scanned for vulnerabilities" $1.grype.tmp | tail -n 1 > $1.grype.status.1
    tr -d '\000-\037\177' < $1.grype.status.1 | sed '/^$/d' > $1.grype.status.1.tmp
    line1=$(cat $1.grype.status.1.tmp)
    left1=${line1%%" [K"*}
    grep "├── by severity:" $1.grype.tmp | tail -n 1 > $1.grype.status.2
    tr -d '\000-\037\177' < $1.grype.status.2 | sed '/^$/d' > $1.grype.status.2.tmp
    line2=$(cat $1.grype.status.2.tmp)
    left2=${line2%%" [K"*}
    grep "└── by status:" $1.grype.tmp | tail -n 1 > $1.grype.status.3
    tr -d '\000-\037\177' < $1.grype.status.3 | sed '/^$/d' > $1.grype.status.3.tmp
    line3=$(cat $1.grype.status.3.tmp)
    left3=${line3%%" [K"*}
    echo $left1 > $1.grype.status
    echo $left2 >> $1.grype.status
    echo $left3 >> $1.grype.status
    rm -f $1.grype.tmp
    rm -f $1.grype.status.*
    cat $1.grype.status
    return
}

git remote remove origin && git remote add origin git@Debian:0mniteck/debian.git
git submodule update --init $1 --recursive
sudo apt install -y snapd
sudo snap install syft --classic
sudo snap install grype --classic
rm -f -r /var/snap/docker*
snap remove docker --purge
mkdir /var/snap/docker
chown root:root /var/snap/docker
snap install docker --revision=3267
docker buildx create --name debian-builder --driver-opt "network=host" --bootstrap --use
docker login

for module in debian-slim debian debian-extra
do
pushd $module/
git remote remove origin && git remote add origin git@Debian:0mniteck/debian.git
rm -f $module.spdx.json
rm -f $module.meta.json
rm -f $module.grype.json
rm -f $module.grype.status
rm -f readme.md
docker buildx build --load \
--tag omniteck-$module \
--metadata-file $module.meta.json \
--build-arg REL_DATE=$rel_date \
--build-arg DEBIAN=$debian \
--build-arg DEBIAN_SECURITY=$debian_security \
--build-arg SOURCE=$source .
scan_using_grype $module docker:omniteck-$module
cp $module.grype.status readme.md
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
rm /root/getter* -f -r && rm /root/grype-scratch* -f -r && rm /root/Library -f -r && rm -f -r $HOME/.cache/grype && rm -f -r /tmp/grype-scratch*
