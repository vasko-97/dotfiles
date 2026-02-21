#!bash

declare -l LOWER
LOWER='ASDasdfASD asodifj'
declare -u UPPER
UPPER='ASDasdfASD asodifj'
declare -c CAPITALISED
CAPITALISED='ASDasdfASD asodifj'

echo lower: $LOWER
echo upper: $UPPER
echo capitalised: $CAPITALISED

while read TXT
do
	RA=($TXT)
	echo ${RA[@]^}
done
