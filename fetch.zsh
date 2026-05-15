#!/bin/zsh
# version 1.6
local -i idx=${1:-0} n=1
((idx>14)) && print -u2 -- 'index too large' && return $idx
((idx>7)) && ((n=idx-6))
local -a mkt=(EN-US JA-JP ZH-CN EN-IN DE-DE ES-ES FR-FR IT-IT EN-GB PT-BR EN-CA)
local data=$(curl -fsSL "https://www.bing.com/HPImageArchive.aspx?format=js&idx=$idx&n=$n&mkt="${^mkt})
local -a info=(${(@f)"$(jq -r '.images[-1] | .enddate, .urlbase, .title, .copyright' <<< $data)"})
local -a targets
for ((i=1; i<=$#mkt; i++)) do
	local filename=${${info[4*i-2]#*.}%%_*}
	print -- "$info[4*i-3],$filename,$mkt[$i],${${info[4*i-2]##*_}[6,-1]},\"$info[4*i-1]\",\"$info[4*i]\"" >> metadata/$mkt[$i].csv
	[[ ! -f img/$filename.jpg ]] && ((! $targets[(I)$filename.jpg])) && targets+=(-o $filename.jpg https://www.bing.com$info[4*i-2]_1920x1080.jpg)
done
(($#targets)) && curl -fsSLZ --output-dir img $targets && ln -f img/$targets[-2] img/latest.jpg
[[ -n $(git status --porcelain) ]] || return
git add img metadata
git commit -m "Fetch: $info[1]"
(($#1)) || git push
