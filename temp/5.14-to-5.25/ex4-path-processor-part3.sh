#!bash

INPUT='/some/long/fucking/path/and/its/child/file.txt'
for i in {1..1000}; do
	DIR=$(dirname $INPUT)
	NAME=$(basename $INPUT)

	# echo DIR is $DIR
	# echo NAME is $NAME
done
