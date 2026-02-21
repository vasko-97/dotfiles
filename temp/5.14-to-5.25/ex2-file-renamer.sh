#!bash

for f in "$@"; do
	LOWER=${f,,}
	echo lower: $LOWER
	WITHOUT_DRAFT=${LOWER/draft/}
	WITHOUT_FINAL=${WITHOUT_DRAFT/final/}
	echo without draft or final: $WITHOUT_FINAL
	BASENAME=${WITHOUT_FINAL##*/}
	echo basename: $BASENAME
	EXTENSION=${BASENAME##*.}
	echo extension: $EXTENSION
	WITHOUT_EXTENSION=${BASENAME%.*}
	echo without extension: $WITHOUT_EXTENSION

	echo
done

