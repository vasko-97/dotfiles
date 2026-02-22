#!bash
shopt -s extglob

EXCLUDE_ARRAY=()
DEST_ARRAY=()
FILE_ARRAY=()
UNKNOWN_OPTIONS_ARRAY=()
while (( $# > 0 ))
do
	if [[ $DASHES_ENCOUNTERED ]]; then
		FILE_ARRAY+=("$1")
		shift
		continue
	fi
	case "$1" in
		-v|--verbose) echo verbose set
			;;
		-d|--destination) shift;
			[[ $# -eq 0 ]] && { echo "error: -d requires an argument"; exit 1; }
			DEST_ARRAY+=("$1")
			;;
		@(-d|--destination)=*)
			VALUE="${1#*=}"
			DEST_ARRAY+=("$VALUE")
			;;
		--exclude) shift;
			EXCLUDE_ARRAY+=("$1")
			;;
		--exclude=*)
			VALUE="${1#*=}"
			EXCLUDE_ARRAY+=("$VALUE")
			;;
		--) DASHES_ENCOUNTERED=1
			;;
		-*) UNKNOWN_OPTIONS_ARRAY+=("$1")
			;;
		*) FILE_ARRAY+=("$1")
			;;
	esac
	shift
done

echo debug: full unknown options array:
declare -p UNKNOWN_OPTIONS_ARRAY
echo debug: full dest array:
declare -p DEST_ARRAY
echo debug: full exclude array:
declare -p EXCLUDE_ARRAY
echo debug: full file array:
declare -p FILE_ARRAY

[[ ${#DEST_ARRAY[@]} -eq 0 ]] && { echo error: please specify destination; HAS_ERRORS=1; }
[[ ${#DEST_ARRAY[@]} -gt 1 ]] && { echo error: please specify only one destination, destinations specified: "${DEST_ARRAY[@]}"; HAS_ERRORS=1; }

if [[ ${#DEST_ARRAY[@]} -eq 1 ]]; then
	DEST=${DEST_ARRAY[0]}
	[[ -e "$DEST" && -w "$DEST" ]] || { echo error: destination does not exist or is not writeable; HAS_ERRORS=1; }
fi

[[ ${#FILE_ARRAY[@]} -eq 0 ]] && { echo error: please specify at least one file to back up; HAS_ERRORS=1; }

[[ ${#UNKNOWN_OPTIONS_ARRAY[@]} -gt 0 ]] && { echo error: unknown options: "${UNKNOWN_OPTIONS_ARRAY[@]}"; HAS_ERRORS=1; }

[[ -n $HAS_ERRORS ]] && exit 1

: <<'END'
## Exercise 7: Argument Parsing State Machine

Write `backup_script.sh` with complex argument parsing:

```
backup_script.sh -v -d /backup --exclude "*.tmp" --exclude "*.log" file1 file2 file3
```

Support:
- `-v` or `--verbose`: verbose mode (flag, no argument)
- `-d DIR` or `--destination DIR`: backup destination (requires argument)
- `--exclude PATTERN`: can appear multiple times, accumulate patterns
- `--`: stop processing options, treat rest as files
- Remaining args: files to backup

Requirements:
- Use `while` + `case` for parsing
- Handle `--option=value` format as well as `--option value`
- Accumulate multiple `--exclude` patterns into an array
- Validate that destination exists and is writable
- Validate at least one file specified
- Handle errors: missing arguments, unknown options, conflicting options

Then test these error cases:
- No destination specified
- Destination is read-only
- No files to backup
- Unknown option
- Option requiring argument but none provided

**Expected outcome:** Build industrial-strength argument parser, understand why `getopts` exists but know how to roll your own.
END
