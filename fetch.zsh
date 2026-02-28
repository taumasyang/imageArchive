#!/bin/zsh
# version 1.5.2
local -i idx=${1:-0} n=1
(( idx > 14 )) && print -u2 -- 'index too large' && return $idx
(( idx > 7 )) && (( n = idx - 6 ))
local mkt image
for mkt in {EN-US,JA-JP,ZH-CN,EN-IN,DE-DE,ES-ES,FR-FR,IT-IT,EN-GB,PT-BR,EN-CA}
do
	image=''
	while [[ -z $image ]]
	do image=$(curl -sG -d idx=$idx -d n=$n -d mkt=$mkt https://www.bing.com/HPImageArchive.aspx)
	done
	local enddate=$(print -- $image | xmllint --xpath '//enddate/text()' - | head -n$n)
	local urlBase=$(print -- $image | xmllint --xpath '//urlBase/text()' - | head -n$n)
	local filename=${${urlBase#*.}%%_*}
	print -- "$enddate,$filename,$mkt,$(print -- ${urlBase##*_} | grep -oE '[0-9]+'),\"$(print -- $image | xmllint --xpath '//headline/text()' - | head -n$n)\",\"$(print -- $image | xmllint --xpath '//copyright/text()' - | head -n$n)\"" >> metadata/$mkt.csv
	[[ -f img/$filename.jpg ]] || curl -so img/$filename.jpg https://www.bing.com${urlBase}_1920x1080.jpg
	ln -f img/$filename.jpg img/latest.jpg
done
[[ $(git status --porcelain) ]] || return
git add img metadata
git commit -m "Fetch: $enddate"
(($#1)) || git push
