#!bash

VAR1="05"
VAR2="5"
VAR3="10"    
VAR4="9"
VAR5="abc"   
VAR6="5"
VAR7=" 5 "   
VAR8="5"

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
