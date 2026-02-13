echo local in child is $LOCAL
echo global in child is $GLOBAL

LOCAL="local edited in child"
GLOBAL="global edited in child"

./ex6-grandchild.sh
