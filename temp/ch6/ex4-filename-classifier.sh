#!bash

shopt -s extglob

INPUT="$1"

if [[ $INPUT = *.jpg || $INPUT = *.png || $INPUT = *.gif ]]; then
	echo image
fi

if [[ $INPUT = *.tar.gz || $INPUT = *.zip || $INPUT = *.bz2 ]]; then
	echo compressed file
fi

if [[ $INPUT = *@(.bak|.backup|.old) ]]; then
	echo backup file
fi

if [[ $INPUT = @(tmp|temp|cache)* ]]; then
	echo  temp file
fi

if [[ $INPUT = file.v+([0-9]) ]]; then
	echo versioned file
fi

if [[ $INPUT = app.20[0-9][0-9]-[0-9][0-9]-[0-9][0-9].log ]]; then
	echo log file
fi

if [[ $INPUT = !(*test*|*spec*).@(c|cpp|h) ]]; then
	echo source file
fi

if [[ $INPUT =~ [0-9]+\.[0-9]+\.[0-9]+ ]]; then
	echo semantic version string
fi

if [[ $INPUT =~ .*@.*\.(com|uk|net) ]]; then
	echo email
fi

if [[ $INPUT =~ ([[:alpha:]]+),[:space:]([[:alpha:]]+) ]]; then
	echo name
	echo first: ${BASH_REMATCH[1]}
	echo second: ${BASH_REMATCH[2]}
fi

: <<'COMMENT'
Build filename_classifier.sh using increasingly sophisticated pattern matching:
Level 1 - Basic patterns with [[ ]]:

Match image files: *.jpg, *.png, *.gif
Match compressed files: *.tar.gz, *.zip, *.bz2

Level 2 - Extended globs with extglob:

Match backup files: anything ending .bak OR .backup OR .old
Match temp files: anything starting with tmp OR temp OR cache
Match version patterns: file.v1, file.v2, file.v10 (but not file.version)

Level 3 - Complex combinations:

Match log files with dates: app.2024-01-15.log format only
Match source files excluding tests: .c/.cpp/*.h but NOT test OR spec

Level 4 - Regex with =~:

Match semantic version strings: X.Y.Z where X,Y,Z are numbers
Match email-like patterns
Extract components from "LastName, FirstName" format

Expected outcome: Progress from simple patterns to complex regex, understanding when each tool is appropriate.
COMMENT
