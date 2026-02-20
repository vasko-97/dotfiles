#!bash

PRINCIPAL=1000
RATE=5
YEARS=$1

echo "$PRINCIPAL * (1 + $RATE/(100*12))^($YEARS*12)"
AMOUNT=$(echo "${PRINCIPAL}*(1+${RATE}/(100*12))^(${YEARS}*12)" | bc -l)
echo "After $YEARS years: $AMOUNT"

INTEREST=$(echo "$AMOUNT - $PRINCIPAL" | bc -l)
echo Interest earned: $INTEREST
