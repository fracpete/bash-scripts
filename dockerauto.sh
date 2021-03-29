#!/bin/bash
#
# Script for logging in/out of docker registries.
# 
# Format:
# name TAB comma-separated list of registries

# the usage of this script
function usage()
{
   echo
   echo "${0##*/} -a <login|logout> [-r <name>] [-l] [-h]"
   echo
   echo "Performs login/logout from docker registries defined in $LIST."
   echo "Must be run as root user."
   echo
   echo " -a   <login|logout>"
   echo "      the action to perform"
   echo " -h   this help"
   echo " -l   list all named registry blocks"
   echo " -r   <name>"
   echo "      resume update with this registry block"
   echo
}

ROOT=`expr "$0" : '\(.*\)/'`
LIST=$ROOT/dockerauto.list
COMMENT="#"
RESUME=""
LIST_ONLY="no"
ACTION=""
EXEC="no"

# root user?
if [ $UID -gt 0 ]
then
  echo "Script must be run as root user!"
  usage
  exit 3
fi

# interprete parameters
while getopts ":hlr:a:" flag
do
   case $flag in
      a) if [ "$OPTARG" = "login" ] || [ "$OPTARG" = "logout" ]
         then
           ACTION=$OPTARG
         fi
         EXEC="yes"
         ;;
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

if [ "$EXEC" = "yes" ] && [ "$ACTION" = "" ]
then
  echo "No or incorrect action specified!"
  usage
  exit 2
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
  REGS="${PARTS[1]}"
  
  # find block to resume
  if [ ! "$RESUME" = "" ]
  then
    if [ ! "$RESUME" = "$NAME" ]
    then
      continue
    else
      RESUME=""
    fi
  fi

  echo "$NAME"

  if [ ! "$LIST_ONLY" = "yes" ]
  then
    # query user/pw
    if [ "$ACTION" = "login" ]
    then
      read -u 3 -p User: -a DUSER
      read -u 3 -s -p Password: -a DPW
      echo
    fi

    REGSLIST=`echo $REGS | sed s/","/" "/g`
    for REG in $REGSLIST
    do
      echo " - $REG"
      case $ACTION in
        login)
          echo $DPW | docker login -u $DUSER --password-stdin $REG
          RC=$?
          ;;
        logout)
          docker logout $REG
          RC=$?
          ;;
      esac

      # failed?
      if [[ $RC != 0 ]]
      then 
        echo
        echo "Action $ACTION for '$NAME' failed with exit code: $RC"
        echo "You can resume with: ${0##*/} -r $NAME"
        echo
        exit $RC
      fi
      done
  fi
done 3<&0 < "$LIST"

