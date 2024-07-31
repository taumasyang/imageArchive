#!/bin/zsh
# version 1.4
local idx=${1:-0}
local mkt
for mkt in {ZH-CN,EN-US,EN-GB,EN-CA,EN-IN,JA-JP,FR-FR,DE-DE,ES-ES,PT-BR,IT-IT}
do
	unset image
	while [[ -z $image ]]
	do local image=$(curl -sG -d idx=$idx -d n=1 -d mkt=$mkt https://www.bing.com/HPImageArchive.aspx)
	done
	local enddate=$(echo $image | xmllint --xpath '/images/image/enddate/text()' -)
	local urlBase=$(echo $image | xmllint --xpath '/images/image/urlBase/text()' -)
	local filename=${${urlBase#*.}%%_*}
	echo "$enddate,$filename,$mkt,$(echo ${urlBase##*_} | grep -oE '[0-9]+'),\"$(echo $image | xmllint --xpath '/images/image/headline/text()' -)\",\"$(echo $image | xmllint --xpath '/images/image/copyright/text()' -)\"" >> metadata/$mkt.csv
	[[ -e img/$filename.jpg ]] || curl -so img/$filename.jpg https://www.bing.com${urlBase}_1920x1080.jpg
	[[ $mkt == ZH-CN ]] && ln -f img/$filename.jpg img/latest.jpg
done
[[ $(git status --porcelain) ]] || exit
git add img metadata
git commit -m "Fetch: $enddate"
[[ -z $1 ]] && git push
