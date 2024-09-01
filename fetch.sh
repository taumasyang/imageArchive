#!/bin/zsh
# version 1.5
local -i idx=${1:-0}
[[ idx -gt 14 ]] && echo 'index too large' >&2 && exit $idx
local -i n=1
[[ idx -gt 7 ]] && n=$((idx-6))
local mkt
for mkt in {EN-US,JA-JP,ZH-CN,EN-IN,DE-DE,ES-ES,FR-FR,IT-IT,EN-GB,PT-BR,EN-CA}
do
	while [[ -z $image ]]
	do local image=$(curl -sG -d idx=$idx -d n=$n -d mkt=$mkt https://www.bing.com/HPImageArchive.aspx)
	done
	local enddate=$(echo $image | xmllint --xpath '//enddate/text()' - | head -n$n)
	local urlBase=$(echo $image | xmllint --xpath '//urlBase/text()' - | head -n$n)
	local filename=${${urlBase#*.}%%_*}
	echo "$enddate,$filename,$mkt,$(echo ${urlBase##*_} | grep -oE '[0-9]+'),\"$(echo $image | xmllint --xpath '//headline/text()' - | head -n$n)\",\"$(echo $image | xmllint --xpath '//copyright/text()' - | head -n$n)\"" >> metadata/$mkt.csv
	[[ -e img/$filename.jpg ]] || curl -so img/$filename.jpg https://www.bing.com${urlBase}_1920x1080.jpg
	ln -f img/$filename.jpg img/latest.jpg
	unset image
done
[[ $(git status --porcelain) ]] || exit
git add img metadata
git commit -m "Fetch: $enddate"
[[ -z $1 ]] && git push
