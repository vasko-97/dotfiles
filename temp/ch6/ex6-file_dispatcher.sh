#!bash
shopt -s extglob

for file in "$@"; do
    case "$file" in
	    *.c|*.h) echo simulating compiling source file $file
		    ;;
	    *.tar.gz|*.tgz) echo simulating extracting archive $file
		    ;;
	    *.pdf|*.doc|*.docx) echo simulating opening document $file
		    ;;
	    !(*thumbnail*).@(jpg|png)) echo simulating resizing image $file
		    ;;
	    *.conf|*.cfg|*.ini) echo simulating validating syntax for config file $file
		    ;;&
	    .*) echo simulating special handling for dotfile $file
		    ;;
	    *) echo unknown file type
		    ;;
    esac
done

: <<'END'
Requirements:
- Source code files (*.c/*.h): compile them
- Archives (*.tar.gz|*.tgz): extract to tmp/
- Documents (*.pdf|*.doc|*.docx): open in viewer
- Images (*.jpg|*.png but NOT thumbnail*): optimize size
- Config files (*.conf|*.cfg|*.ini): validate syntax
- Dotfiles (.*): handle specially (they're hidden)
- Everything else: report "unknown file type"

Advanced: Use `;&` fallthrough to handle files that match multiple patterns (e.g., ".config.ini" should trigger both dotfile AND config logic).

Test with edge cases: files with multiple extensions, files with no extension, files starting with `-`, files with spaces in names.

**Expected outcome:** Master case patterns, understand `;;` vs `;;&` vs `;&`, handle real-world filename complexity.
END
