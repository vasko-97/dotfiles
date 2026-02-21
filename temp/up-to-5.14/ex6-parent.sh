LOCAL="local value set in parent"
export GLOBAL="global value set in parent"

./ex6-child.sh

echo global at the end in parent is $GLOBAL
