#!/bin/zsh
# version 1.3
idx=${1:-0}
for mkt in {ZH-CN,EN-US,EN-GB,EN-CA,EN-IN,JA-JP,FR-FR,DE-DE,ES-ES,PT-BR,IT-IT}
do
	unset image
	while [[ -z $image ]]
	do image=$(curl -sG -d idx=$idx -d n=1 -d mkt=$mkt https://www.bing.com/HPImageArchive.aspx)
	done
	enddate=$(echo $image | xmllint --xpath '/images/image/enddate/text()' -)
	urlBase=$(echo $image | xmllint --xpath '/images/image/urlBase/text()' -)
	filename=${${urlBase#*.}%%_*}
	echo "$enddate,$filename,$mkt,$(echo ${urlBase##*_} | grep -oE '[0-9]+'),\"$(echo $image | xmllint --xpath '/images/image/headline/text()' -)\",\"$(echo $image | xmllint --xpath '/images/image/copyright/text()' -)\"" >> metadata/$mkt.csv
	[[ -e img/$filename.jpg ]] || curl -so img/$filename.jpg www.bing.com${urlBase}_1920x1080.jpg
	[[ $mkt == ZH-CN ]] && ln -f img/$filename.jpg img/latest.jpg
done
[[ $(git status --porcelain) ]] || exit
git add img metadata
git commit -m "Fetch: $enddate"
[[ $idx -eq 0 ]] && git push
