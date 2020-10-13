#!/bin/bash
#
# Script for updating repositories defined in text file.
# 
# Format:
# name TAB type TAB local dir
#
# Supported types:
# - git
#   sudo apt-get install git
# - svn
#   sudo apt-get install subversion
# - gdrive
#   https://github.com/odeke-em/drive


# the usage of this script
function usage()
{
   echo
   echo "${0##*/} [-r <name>] [-h]"
   echo
   echo "Updates projects as defined in $LIST."
   echo
   echo " -h   this help"
   echo " -l   list all projects"
   echo " -r   <name>"
   echo "      resume update with this project name"
   echo
}

# changes into DIR and calls git pull
function update_git {
  cd $DIR
  git pull
  RC=$?
}

# changes into DIR and calls svn update
function update_svn {
  cd $DIR
  svn update
  RC=$?
}

# changes into DIR and calls gdrive pull
function update_gdrive {
  cd $DIR
  drive pull -no-prompt -quiet -ignore-name-clashes -ignore-conflict
  RC=$?
}

ROOT=`expr "$0" : '\(.*\)/'`
LIST=$ROOT/update.list
COMMENT="#"
RESUME=""
LIST_ONLY="no"

# interprete parameters
while getopts ":hlr:" flag
do
   case $flag in
      r) RESUME=$OPTARG
         ;;
      l) LIST_ONLY="yes"
         ;;
      h) usage
         exit 0
         ;;
      *) usage
         exit 1
         ;;
   esac
done

while read LINE
do
  # comment or empty line?
  if [[ "$LINE" =~ ^$COMMENT ]] || [ -z "$LINE" ]
  then
    continue
  fi
  
  read -a PARTS <<< "${LINE}"
  
  NAME="${PARTS[0]}"
  TYPE="${PARTS[1]}"
  DIR="${PARTS[2]}"
  
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

  echo "$NAME - $DIR"

  if [ ! "$LIST_ONLY" = "yes" ]
  then
    case $TYPE in
      svn)
        update_svn
        ;;
      git)
        update_git
        ;;
      gdrive)
        update_gdrive
        ;;
      *)
        echo "Unknown repository type $TYPE, skipping!"
    esac

    # failed?
    if [ $RC != 0 ]
    then 
      echo
      echo "Update of '$NAME' failed with exit code: $RC"
      echo "You can resume updates with: ${0##*/} -r $NAME"
      echo
      exit $RC
    fi
  fi
done < "$LIST"

