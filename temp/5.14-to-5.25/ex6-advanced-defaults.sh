#!bash

 # ${TMPDIR:=$(mktemp -d)} - command substitution in default
 # ${BACKUP_DIR:=${HOME}/backups} - parameter expansion in default
 # ${MAX_TRIES:=$((RETRIES * 2))} - arithmetic in default
 # ${USER_HOME:=~${USERNAME}} - tilde expansion in default
 # Build a path using multiple levels: ${BASE:=/opt}/${APP:=myapp}/${ENV:=prod}

 ${TMPDIR:=$(mktemp -d)}
 echo tmpdir $TMPDIR
 ${BACKUP_DIR:="${HOME}/backups"}
 echo backupdir $BACKUP_DIR
 RETRIES=4
 ${MAX_TRIES:=$((RETRIES * 2))}
 echo max tries $MAX_TRIES
${USER_HOME:=~/${USERNAME}}
 echo user home: $USER_HOME
