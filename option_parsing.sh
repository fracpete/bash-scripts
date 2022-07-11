#!/bin/bash
#
# Example script with option parsing and help screen.

# the usage of this script
function usage()
{
   echo
   echo "${0##*/} [-f] [-a <arg>] [-h]"
   echo
   echo "Example script for option parsing."
   echo
   echo " -h   this help"
   echo " -f   this flag enables an option"
   echo " -a   <arg>"
   echo "      option that takes an argument"
   echo
}

ROOT=`expr "$0" : '\(.*\)/'`
FLAG="no"
ARG=""

# interpret parameters
while getopts ":hfa:" flag
do
   case $flag in
      a) ARG=$OPTARG
         ;;
      f) FLAG="yes"
         ;;
      h) usage
         exit 0
         ;;
      *) usage
         exit 1
         ;;
   esac
done

echo "Values after option parsing:"
echo "- FLAG: $FLAG"
echo "- ARG: $ARG"

