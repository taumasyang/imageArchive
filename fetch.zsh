#!/bin/zsh
# version 1.5.4
local -i idx=${1:-0} n=1
(( idx > 14 )) && print -u2 -- 'index too large' && return $idx
(( idx > 7 )) && (( n = idx - 6 ))
local mkt image
for mkt in {EN-US,JA-JP,ZH-CN,EN-IN,DE-DE,ES-ES,FR-FR,IT-IT,EN-GB,PT-BR,EN-CA}
do
	image=
	repeat 16
	do image=$(curl -sG -d idx=$idx -d n=$n -d mkt=$mkt https://www.bing.com/HPImageArchive.aspx) && (($#image)) && break
	done
	local enddate=$(xmllint --xpath '//enddate/text()' - <<< $image | tail -n1)
	local urlBase=$(xmllint --xpath '//urlBase/text()' - <<< $image | tail -n1)
	local filename=${${urlBase#*.}%%_*}
	print -- "$enddate,$filename,$mkt,$(grep -oE '[0-9]+' <<< ${urlBase##*_}),\"$(xmllint --xpath '//headline/text()' - <<< $image | tail -n1)\",\"$(xmllint --xpath '//copyright/text()' - <<< $image | tail -n1)\"" >> metadata/$mkt.csv
	[[ -f img/$filename.jpg ]] || curl -so img/$filename.jpg https://www.bing.com${urlBase}_1920x1080.jpg
	ln -f img/$filename.jpg img/latest.jpg
done
[[ $(git status --porcelain) ]] || return
git add img metadata
git commit -m "Fetch: $enddate"
(($#1)) || git push
