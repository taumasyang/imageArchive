#!/bin/zsh
idx=${1:-0}
for mkt in {ZH-CN,EN-US,EN-GB,EN-CA,EN-IN,JA-JP,FR-FR,DE-DE,ES-ES,PT-BR,IT-IT}
do
	image=$(curl -sG -d idx=$idx -d n=1 -d mkt=$mkt https://www.bing.com/HPImageArchive.aspx | xmllint --xpath '/images/image' -)
	[[ -z $image ]] && continue
	enddate=$(echo $image | xmllint --xpath '/image/enddate/text()' -)
	urlBase=$(echo $image | xmllint --xpath '/image/urlBase/text()' -)
	filename=${${urlBase#*.}%%_*}
	[[ -e img/$filename.jpg ]] && continue
	echo "$enddate,$filename,$mkt,$(echo ${urlBase##*_} | grep -oE '[0-9]+'),\"$(echo $image | xmllint --xpath '/image/headline/text()' -)\",\"$(echo $image | xmllint --xpath '/image/copyright/text()' -)\"" >> metadata.csv
	curl -so img/$filename.jpg www.bing.com${urlBase}_1920x1080.jpg
	[[ $mkt == ZH-CN ]] && ln -f img/$filename.jpg img/latest.jpg
done
[[ $(git status --porcelain) ]] || exit
git add img metadata.csv
git commit -m "Fetch: $enddate"
git push
