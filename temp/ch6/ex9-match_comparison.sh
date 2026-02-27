#!bash

function div_with_remainder {
	first=$1
	second=$2
	quotient=$(($1 / $2))
	remainder=$(($1 % $2))
	echo quotient is $quotient
	echo remainder is $remainder
}

function int_sqrt {
	n=$1
	resultCandidate=1
	while (( resultCandidate ** 2 <= n )); do
		((resultCandidate++))
	done
	result=$((resultCandidate-1))
	echo square root with bash arithmetic is $result

	bcResult=$(bc -l <<< "scale=10; sqrt($n)")
	echo square root with bc is $bcResult
}

function safe_multiply {
	MAX_INT=$((2**63 - 1))
	local a=$1
	local b=$2

	# Handle cases where one number is 0 (no overflow possible)
	if [[ $a -eq 0 || $b -eq 0 ]]; then
		echo 0
	fi

	# Normalize signs for comparison
	local abs_a=${a#-}
	local abs_b=${b#-}

	# Logic: if a * b > MAX, then a > MAX / b
	# We use integer division for the check
	if [[ $abs_a -gt $((MAX_INT / abs_b)) ]]; then
		echo error: overflow
	else
		echo result is $((a*b)) 
	fi
}

function with_bash {
	for i in {1..1000}; do
		local result=$(( i * 2 + 5 ))
		# echo $result
	done
}

function with_bc_herestring {
	for i in {1..1000}; do
		result=$(bc -l <<< "$i * 2 + 5")
		# echo bc herestring: $result

	done
}

function with_bc_pipe {
	for i in {1..1000}; do
		result=$(echo "$i * 2 + 5" | bc -l )
		# echo bc pipe: $result

	done
}

function with_bc_pipe_single_invocation {
    {
        for i in {1..1000}; do
            echo "$i * 2 + 5"
        done
    } | bc -l > /dev/null
}

function with_awk {
	for i in {1..1000}; do
		result=$(awk "BEGIN {print $i * 2 + 5 }")
		# echo awk: $result

	done
}

function with_awk_loop {
	awk "BEGIN {
		for (i=1; i<=1000; i++) {
			result = i * 2 + 5
}
}"
}

function with_expr {
	for i in {1..1000}; do
		result=$(expr $i \* 2 + 5)
		# echo expr: $result

	done
}

# div_with_remainder $1 $2
# int_sqrt $1
# safe_multiply $1 $2
echo with_bash:
time with_bash
echo with_bc_herestring
time with_bc_herestring
echo with_bc_pipe
time with_bc_pipe
echo with_bc_pipe_single_invocation
time with_bc_pipe_single_invocation
echo with_awk
time with_awk
echo with_expr
time with_expr
echo with_awk_loop
time with_awk_loop

# result get rounded to 3 because bash only supports integer arithmetic
# VAR1=$((10 / 3))
# echo 10/3 is $VAR1

# error, 0.5 is not a valid token (because it's a float, 2 ** 2 works)
# VAR2=$((2 ** 0.5))
# echo '2 ** 0.5' is $VAR2

# error: division by zero
# VAR3=$((10 / 0))
# echo '2 ** 0.5' is $VAR3

# error: bad tokens
# VAR4=$((0.1 + 0.2))
# echo $VAR4

#VAR5=$((9999999999 * 9999999999))
#cho VAR5 is $VAR5

#cho first: $((2**63 - 1))
#cho second: $((2**63))

# VAR1=$(bc -l <<< 'scale=3; 10/3')
# echo 10/3 is $VAR1

: <<'END_COMMENT'
Exercise 9: Arithmetic Limitations and Workarounds
Create math_comparison.sh in three parts.
Part A — Find and explain the failures:
Run each of these and document what actually happens (wrong result, error, silent failure, etc.):
bashresult=$((10 / 3))
result=$((2 ** 0.5))
result=$((0.1 + 0.2))
result=$((10 / 0))
result=$((9999999999 * 9999999999))
For the overflow case: determine what your system's integer limit actually is. Is it 32-bit or 64-bit? What happens at $((2**63 - 1)) vs $((2**63))?

Part B — Implement these specific things:

Write a function div_with_remainder that takes two integers and prints both the quotient and remainder using only bash arithmetic (no bc, no expr).
Write a function int_sqrt that computes integer square root (floor) using a loop — no external tools. It should work correctly for 0, 1, perfect squares, and non-perfect squares.
Use bc to compute the same square root with 10 decimal places and compare the truncated result to your integer version.
Write a function safe_multiply that detects potential overflow before it happens and either returns an error or falls back to bc. Define "overflow" as exceeding $((2**63 - 1)).

Part C — Benchmark and interpret:
Time exactly 1000 iterations of the same calculation (i * 2 + 5 for i in 1..1000) using:

$(( ))
bc via pipe
awk
expr

Use time or TIMEFORMAT to measure wall time. Then answer in a comment in the script: at what point (roughly how many operations per script invocation) does reaching for bc become acceptable overhead?

my results:
with_bash:

real    0m0.002s
user    0m0.002s
sys     0m0.000s
with_bc_herestring

real    0m1.308s
user    0m0.655s
sys     0m0.729s
with_bc_pipe

real    0m1.554s
user    0m0.813s
sys     0m1.059s
with_bc_pipe_single_invocation

real    0m0.003s
user    0m0.001s
sys     0m0.005s
with_awk

real    0m1.661s
user    0m0.530s
sys     0m1.158s
with_expr

real    0m1.122s
user    0m0.295s
sys     0m0.855s
with_awk_loop

real    0m0.002s
user    0m0.000s
sys     0m0.002s
END_COMMENT
