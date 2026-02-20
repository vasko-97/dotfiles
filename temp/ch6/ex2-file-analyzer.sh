#!bash 

echo kek

FILEPATH=$1

if [[ ! -h "$FILEPATH" && ! -e "$FILEPATH" ]]; then
	echo "doesn't exist"
	exit 23
fi

if [[ ! -s "$FILEPATH" ]]; then
	echo exists but empty
fi

SIZE=$(stat -c %s "$FILEPATH")
echo size is $SIZE bytes

if [[ -r "$FILEPATH" && -x "$FILEPATH" && "$SIZE" -gt 100 && "$SIZE" -lt 1000 ]]; then
	echo small executable script
elif [[ -r "$FILEPATH" && "$SIZE" -gt 1000 && "$FILEPATH" = *.log ]]; then
	echo large log file
elif [[ -d "$FILEPATH" && -w "$FILEPATH" ]]; then
	echo writeable directory
elif [[ -h "$FILEPATH" ]]; then
	TARGET=$(readlink "$FILEPATH")
	echo symbolic link pointing to $TARGET
	if [[ ! -e "$TARGET" ]]; then
		echo symlink is broken btw
	fi
else
	echo unknown type
fi

: <<'END_COMMENT'
Write `file_analyzer.sh` that takes a filepath and determines:
- If it doesn't exist: exit with error
- If it exists but is empty: "empty file"
- If readable and >100 bytes and <1MB and executable: "small executable script"
- If readable and >1MB and ends in .log: "large log file"
- If directory and writable: "writable directory"
- If symbolic link: "symlink pointing to [target]"
- Otherwise: "unknown file type"

Requirements:
- Use compound conditions with `-a` and `-o`
- Test for multiple characteristics in single `if` statements
- Handle edge cases (broken symlinks, special files)
- Use proper operator precedence with escaped parentheses

Test with: regular files, directories, symlinks, /dev/null, nonexistent paths, files without read permission.

**Expected outcome:** Master file tests, compound conditions, and operator precedence.
END_COMMENT
