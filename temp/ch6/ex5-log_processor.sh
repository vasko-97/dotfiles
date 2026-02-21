#!bash

COUNT=0
ERROR_COUNT=0
BYTE_COUNT=0
FIRST_ERR_TIME=""

while read -r LINE; do
	COUNT=$(( COUNT + 1 ))
	echo count: $COUNT, line: $LINE

	if [[ "$LINE" == *ERROR* ]]; then
		(( ERROR_COUNT++ ))
		[[ "$LINE" =~ ^([0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]][0-9]{2}:[0-9]{2}:[0-9]{2}) ]]
		ERR_TIME=${BASH_REMATCH[1]}
		if [[ -z $FIRST_ERR_TIME ]]; then
			FIRST_ERR_TIME="$ERR_TIME"
		fi
	fi

	if [[ "$LINE" =~ bytes:[[:space:]]([0-9]+) ]]; then
		MATCH=${BASH_REMATCH[1]}
		BYTE_COUNT=$((BYTE_COUNT+MATCH))
		echo bytes match is $MATCH, byte count so far: $BYTE_COUNT
	fi

done < "$1"

echo final count is $COUNT
echo final error count is $ERROR_COUNT
echo final byte count is $BYTE_COUNT
echo first err time: $FIRST_ERR_TIME
echo last err time: $ERR_TIME

while read line; do
	((counter++))
done < "$1"
echo fixed counter is $counter

for ((i=0; i<10; i++)); do
	echo simulating running failing command...
	false && break
done

for f in data_{1..10}.txt; do
	echo processing $f...
done

delay=1
while (( delay < 8 )); do
	sleep $delay
	echo simulate processing
	delay=$((delay * 2))
	# delay=$(echo $delay*2 | bc -l)
	echo set next delay to $delay
done

: <<'END'
Exercise 5: Loop Control Flow Challenge
Write log_processor.sh that reads a log file and:
Part A - while read fundamentals:

Count total lines
Count lines containing "ERROR"
Sum all numeric values in lines matching pattern "bytes: [0-9]+"
Track the first ERROR timestamp and last ERROR timestamp

Part B - Tricky issues:

Demonstrate that this FAILS to work as expected:

bashcat logfile | while read line; do
    ((counter++))
done
echo $counter  # Why is this wrong?

Fix it using redirection instead of pipe
Explain why pipe version fails (hint: subshell)

Part C - Multiple loop types:

Use C-style for ((i=0; i<10; i++)) to retry a failing command up to 10 times
Use for x in with brace expansion to process files named data_{1..100}.txt
Use while (( condition )) with arithmetic to implement exponential backoff

Expected outcome: Master different loop types, understand the pipe-creates-subshell trap, know when to use each loop style.
END
