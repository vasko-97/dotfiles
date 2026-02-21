#!bash

ARRAY=()
while read NEWVAL
do
	ARRAY+=($NEWVAL)
	LIST="${LIST}${LIST:+,}${NEWVAL}"
done < <(printf "one\ntwo\nthree\nfour")

echo $LIST
echo whole array ${ARRAY[@]}




