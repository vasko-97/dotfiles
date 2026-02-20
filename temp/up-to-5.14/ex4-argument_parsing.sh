#!/usr/bin/env bash

if (( $# < 2 )) || (( $# > 5 )); then
	echo provide between 2 and 5 arguments
	exit 1;
fi

VERBOSE=0
DIRECTORY=""
#while [[ $# -gt 0 ]] && [[ $1 == -* ]]; do
while [[ $1 == -* ]]; do
	case $1 in
		-v)
			VERBOSE=1
			shift
			;;
		-d)
			shift
			DIRECTORY="$1"
			shift
			;;
		 *)
			echo invalid option detected: $1
			exit 1
			;;
	esac
done

echo verbose is $VERBOSE
echo directory is $DIRECTORY
printf "remaining arguments:\n"
printf "<%s>\n" "$@"

