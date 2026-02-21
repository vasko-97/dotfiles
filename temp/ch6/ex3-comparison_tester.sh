#!bash

VAR1="05"
VAR2="5"
VAR3="10"    
VAR4="9"
VAR5="abc"   
VAR6="5"
VAR7=" 5 "   
VAR8="5"

echo 05 and 5 with =
[[ "$VAR1" = "$VAR2" ]] && echo match || echo not match

echo 05 and 5 with -eq
[[ "$VAR1" -eq "$VAR2" ]] && echo match || echo not match

echo 10 and 9 with =
[[ "$VAR3" = "$VAR4" ]] && echo match || echo not match

echo 10 and 9 with -eq
[[ "$VAR3" -eq "$VAR4" ]] && echo match || echo not match

echo abc and 5 with =
[[ "$VAR5" = "$VAR6" ]] && echo match || echo not match

echo abc and 5 with -eq
[[ "$VAR5" -eq "$VAR6" ]] && echo match || echo not match

echo  5 with surrounding space and 5 with =
[[ "$VAR7" = "$VAR8" ]] && echo match || echo not match

echo  5 with surrounding space and 5 with -eq
[[ "$VAR7" -eq "$VAR8" ]] && echo match || echo not match

echo bizzare behaviour
[[ "abc" -eq 0 ]] && echo match || echo not match

IN_FIRST=$1
IN_SECOND=$2

IFS='.' read -r first_major first_minor <<< "$IN_FIRST"
echo first major: $first_major
echo first minor: $first_minor

IFS='.' read -r second_major second_minor <<< "$IN_SECOND"
echo second major: $second_major
echo second minor: $second_minor

[[ $first_major -gt $second_major ]] && echo 'first is greater' && exit
[[ $first_major -lt $second_major ]] && echo 'second is greater' && exit
[[ $first_minor -gt $second_minor ]] && echo 'first is greater' && exit
[[ $first_minor -lt $second_minor ]] && echo 'second is greater' && exit
echo "they're equal"

: <<'END_COMMENT'
Create `comparison_tester.sh` that demonstrates when `-eq` vs `=` matters:

Given these test cases:
```
VAR1="05"     VAR2="5"
VAR3="10"     VAR4="9"
VAR5="abc"    VAR6="5"
VAR7=" 5 "    VAR8="5"

For each pair, test and report:

Do they match with -eq?
Do they match with =?
If they differ, explain why

Then create a realistic bug: Write a version check script that incorrectly uses = to compare version strings like "1.10" vs "1.9" and fails. Fix it properly (hint: you'll need to parse and compare components separately).
Expected outcome: Internalize when each comparison type is appropriate and the consequences of choosing wrong.
END_COMMENT
