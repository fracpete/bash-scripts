#!/bin/bash
#
# Checks whether git repos on github are using git@ rather than https://

# the usage of this script
function usage()
{
  echo
  echo "${0##*/} -d [-r] [-H] [-U] [-R host] [-v] [-h]"
  echo
  echo "Checks the git repository whether it uses git@ or https://"
  echo
  echo " -h   this help"
  echo " -d   <dir>"
  echo "      the directory of the git repository to check"
  echo " -r   whether to look for git repositories recursively"
  echo " -H   only list git repos with https as URL"
  echo " -U   whether to switch to ssh (using git@REMOTE)"
  echo " -R   host"
  echo "      the remote host to update, default: github.com"
  echo " -v   use verbose output"
  echo
}

# checks the directory referenced in CURR_DIR
function check_dir()
{
  CONFIG_FILE="$CURR_DIR/.git/config"
  if [ -f "$CONFIG_FILE" ]
  then
    if [ "$VERBOSE" = "yes" ]
    then
      echo "Checking $CURR_DIR"
    fi

    # check for remote host
    COUNT=`grep "url = " $CONFIG_FILE | grep "$REMOTE" | wc -l`
    if [ "$COUNT" -eq 1 ]
    then
      URL=`grep "url =" "$CONFIG_FILE" | sed s/".*url = "//g | sed s/":.*"//g`
      NEEDS_UPDATE="no"
      
      if [ "$HTTPS_ONLY" = "yes" ] && [ "$URL" = "https" ]
      then
        if [ "$VERBOSE" = "yes" ]
        then
          echo "...found: $URL"
        else
          echo "$CURR_DIR: $URL"
        fi
        NEEDS_UPDATE="yes"
      elif [ "$HTTPS_ONLY" = "no" ]
      then
        echo "$CURR_DIR: $URL"
        NEEDS_UPDATE="yes"
      fi

      if [ "$UPDATE" = "yes" ] 
      then
        if [ "$NEEDS_UPDATE" = "yes" ]
        then
          echo "...updating"
          cp $CONFIG_FILE $CONFIG_FILE.bak
          cat $CONFIG_FILE.bak | sed s/"url = https:\/\/$REMOTE\/"/"url = git@$REMOTE:"/g > $CONFIG_FILE
        else
          if [ "$VERBOSE" = "yes" ]
          then
            echo "...no update required"
          fi
        fi
      fi
    else
      if [ "$VERBOSE" = "yes" ]
      then
        echo "...different remote host - skipping"
      fi
    fi
  fi
}

ROOT=`expr "$0" : '\(.*\)/'`
DIR=""
RECURSIVE="no"
HTTPS_ONLY="no"
UPDATE="no"
REMOTE="github.com"

# interprete parameters
while getopts ":hrHvUd:R:" flag
do
  case $flag in
    d) DIR=$OPTARG
       ;;
    R) REMOTE=$OPTARG
       ;;
    r) RECURSIVE="yes"
       ;;
    H) HTTPS_ONLY="yes"
       ;;
    U) UPDATE="yes"
       ;;
    v) VERBOSE="yes"
       ;;
    h) usage
       exit 0
       ;;
    *) usage
       exit 1
       ;;
  esac
done

if [ "$DIR" = "" ]
then
  echo
  echo "No directory supplied!"
  echo
  exit 1
fi

if [ "$RECURSIVE" = "yes" ]
then
  TMP=`find "$DIR" -type d`;
  for CURR_DIR in $TMP
  do 
    check_dir
  done
else
  CURR_DIR="$DIR"
  check_dir
fi

