#!/bin/zsh
idx=${1:-0}
for mkt in {zh-cn,en-us,en-gb,en-ca,en-in,ja-jp,fr-fr,de-de,es-es,pt-br,it-it}
do
	image=$(curl -sG -d idx=$idx -d n=1 -d mkt=$mkt https://www.bing.com/HPImageArchive.aspx | xmllint --xpath '/images/image' -)
	[[ -z $image ]] && continue
	startdate=$(echo $image | xmllint --xpath '/image/startdate/text()' -)
	url=$(echo $image | xmllint --xpath '/image/url/text()' -)
	filename=${${url#*.}%%_*}
	[[ -e img/$filename.jpg ]] && continue
	echo $image | xmllint --xpath '/image/headline/text()' - > desc/$filename.txt
	echo $image | xmllint --xpath '/image/copyright/text()' - >> desc/$filename.txt
	curl -so img/$filename.jpg www.bing.com/${url%%&*}
	[[ $mkt == zh-cn ]] && ln -f img/$filename.jpg img/latest.jpg
done
[[ $(git status --porcelain) ]] || exit
git add desc img
git commit -m "Fetch: $startdate"
git push
