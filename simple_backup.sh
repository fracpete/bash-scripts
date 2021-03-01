#!/bin/bash
#
# Script for backing up directories to a backup dir, optionally
# on a remote host.
# 
# Format:
# name TAB source_dir TAB dir_alias
#
# for each "name" an exclude file can be specified
# simple_backup.<name>.excl

# the usage of this script
function usage()
{
   echo
   echo "${0##*/} [-H <host>] -b <dir> [-n] [-d] [-r <name>]"
   echo "      [-u <user>] [-p <password>] [-P] [-i <identity>] [-h]"
   echo
   echo "Backs up directories defined in $LIST."
   echo
   echo " -h   this help"
   echo " -H   <host>"
   echo "      the host to back up the data to (default is local backup)"
   echo " -b   <dir>"
   echo "      the (top-level) backup directory to use"
   echo " -n   perform 'dry-run'"
   echo " -d   delete files in backup dir that no longer exist"
   echo "      in source directory"
   echo " -r   <name>"
   echo "      resume backup with this directory name"
   echo " -q   really quiet, only error output"
   echo " -u   <user>"
   echo "      the user name to use for the for remote machine"
   echo " -p   <password>"
   echo "      the password to use for the remote machine"
   echo "      (not recommended, as the password can end up in the"
   echo "      command history in plain text)"
   echo " -P   reads the password from stdin"
   echo " -i   <identity>"
   echo "      the private SSH key to use for authentication instead"
   echo "      of user/password"
   echo " -v   verbose output"
   echo
}

# changes into DIR and calls gdrive pull
function backup {
  if [ "$REMOTE_HOST" = "" ]
  then
    rsync $DRYRUN $DELETE -a $VERBOSE $EXCL_OPT $SOURCE $BACKUPDIR/$ALIAS
    RC=$?
  elif [ "$IDENTITY" = "" ]
  then
    if [ ! "$PASSWORD" = "" ]
    then
      RSYNC_PASSWORD="$PASSWORD"
    fi
    rsync $DRYRUN $DELETE -a $VERBOSE $EXCL_OPT $SOURCE $REMOTE_USER@$REMOTE_HOST:$BACKUPDIR/$ALIAS
    RC=$?
    if [ ! "$PASSWORD" = "" ]
    then
      unset RSYNC_PASSWORD
    fi
  else
    rsync $DRYRUN $DELETE -e "$IDENTITY" -a $VERBOSE $EXCL_OPT $SOURCE $REMOTE_USER@$REMOTE_HOST:$BACKUPDIR/$ALIAS
    RC=$?
  fi
}

ROOT=`expr "$0" : '\(.*\)/'`
LIST=$ROOT/simple_backup.list
COMMENT="#"
BACKUPDIR=""
RESUME=""
DRYRUN=""
DELETE=""
VERBOSE=""
REMOTE_HOST=""
REMOTE_USER=""
PASSWORD=""
PASSWORD_STDIN="no"
IDENTITY=""

# interprete parameters
while getopts ":hb:r:ndqvH:u:p:Pi:" flag
do
   case $flag in
      b) BACKUPDIR="$OPTARG"
         ;;
      r) RESUME="$OPTARG"
         ;;
      n) DRYRUN="-n"
         ;;
      d) DELETE="--delete"
         ;;
      q) VERBOSE="-q"
         ;;
      v) VERBOSE="-v"
         ;;
      H) REMOTE_HOST="$OPTARG"
         ;;
      u) REMOTE_USER="$OPTARG"
         ;;
      p) PASSWORD="$OPTARG"
         ;;
      P) PASSWORD_STDIN="yes"
         ;;
      i) IDENTITY="ssh -i $OPTARG"
         ;;
      h) usage
         exit 0
         ;;
      *) usage
         exit 1
         ;;
   esac
done

# checks
if [ "$BACKUPDIR" = "" ]
then
  echo "No backup directory provided!"
  exit 2
fi
if [ ! -d "$BACKUPDIR" ]
then
  echo "Backup directory does not exist: $BACKUPDIR"
  exit 3
fi

# obtain password
if [ "PASSWORD_STDIN" = "yes" ] && [ "$IDENTITY" = "" ]
then
  read -p "Please enter password: " -s PASSWORD
  RC=$?
  if [[ $RC != 0 ]]
  then 
     echo
     echo "Failed to obtain password, exiting."
     echo
     exit 5
  fi
fi

while read LINE
do
  # comment or empty line?
  if [[ "$LINE" =~ ^$COMMENT ]] || [ -z "$LINE" ]
  then
    continue
  fi
  
  read -a PARTS <<< "${LINE}"
  
  NAME="${PARTS[0]}"
  SOURCE="${PARTS[1]}"
  ALIAS="${PARTS[2]}"
  EXCL="$ROOT/simple_backup.$NAME.excl"
  
  # find project to resume
  if [ ! "$RESUME" = "" ]
  then
    if [ ! "$RESUME" = "$NAME" ]
    then
      continue
    else
      RESUME=""
    fi
  fi

  echo "$NAME - $SOURCE"

  if [ -f "$EXCL" ]
  then
    EXCL_OPT="--exclude-from=$EXCL"
  else
    EXCL_OPT=""
  fi

  backup

  # failed?
  if [[ $RC != 0 ]]
  then 
    echo
    echo "Backup of '$NAME' failed with exit code: $RC"
    echo "You can resume backups with: ${0##*/} -r $NAME"
    echo
    exit $RC
  fi
done < "$LIST"

