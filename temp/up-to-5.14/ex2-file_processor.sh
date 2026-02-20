#!bash

CONFIG_DIR=${1:-"$HOME/.config"}
LOG_LEVEL=${2:-INFO}
MAX_RETRIES=${3:?'must set max retries'}

# this does as expected
# _=${VAR_SET:='will be set'}
# _=${VAR_UNSET:-'will not be set'}

# this tries to execute a command called `will be set` and `will not be set`, how come?
: ${VAR_SET:='will be set'}
: ${VAR_UNSET:-'will not be set'}

echo config dir $CONFIG_DIR
echo log level $LOG_LEVEL
echo max retries $MAX_RETRIES
echo var set: $VAR_SET
echo var unset: $VAR_UNSET
