#!/bin/bash
#
# Script for backing up directories to a backup dir
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
   echo "${0##*/} -b <dir> [-n] [-d] [-r <name>] [-h]"
   echo
   echo "Backs up directories defined in $LIST."
   echo
   echo " -h   this help"
   echo " -b   <dir>"
   echo "      the (top-level) backup directory to use"
   echo " -n   perform 'dry-run'"
   echo " -d   delete files in backup dir that no longer exist"
   echo "      in source directory"
   echo " -r   <name>"
   echo "      resume backup with this directory name"
   echo " -q   really quiet, only error output"
   echo " -v   verbose output"
   echo
}

# changes into DIR and calls gdrive pull
function backup {
  rsync $DRYRUN $DELETE -a $VERBOSE $EXCL_OPT $SOURCE $BACKUPDIR/$ALIAS
  RC=$?
}

ROOT=`expr "$0" : '\(.*\)/'`
LIST=$ROOT/simple_backup.list
COMMENT="#"
BACKUPDIR=""
RESUME=""
DRYRUN=""
DELETE=""
VERBOSE=""

# interprete parameters
while getopts ":hb:r:ndqv" flag
do
   case $flag in
      b) BACKUPDIR=$OPTARG
         ;;
      r) RESUME=$OPTARG
         ;;
      n) DRYRUN="-n"
         ;;
      d) DELETE="--delete"
         ;;
      q) VERBOSE="-q"
         ;;
      v) VERBOSE="-v"
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

