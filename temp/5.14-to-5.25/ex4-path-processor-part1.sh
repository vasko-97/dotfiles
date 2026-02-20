#!bash

INPUT='/some/long/fucking/path/and/its/child/file.txt'
for i in {1..1000}; do
	DIR=${INPUT%/*}	
	NAME=${INPUT##*/}
	EXT=${INPUT##*.}
	NAME_NO_EXT=${INPUT%.*}
	PARENT=${DIR##*/}

	echo DIR is $DIR
	echo NAME is $NAME
	echo EXT is $EXT
	echo NAME_NO_EXT is $NAME_NO_EXT
	echo PARENT is $PARENT
done
