#!/bin/bash

# Name:    PropertyCloudAPI
# Purpose: Execute the PropertyCloudAPI program

######################### Constants ##########################

RED='\033[0;31m' #RED
NC='\033[0m' # No Color

######################### Parameters ##########################

fips=""
apn=""
license=""

while [ $# -gt 0 ] ; do
  case $1 in
    --fips) 
        if [ -z "$2" ] || [[ $2 == -* ]];
        then
            printf "${RED}Error: Missing an argument for parameter \'fips\'.${NC}\n"  
            exit 1
        fi 

        fips="$2"
        shift
        ;;
    --apn) 
        if [ -z "$2" ] || [[ $2 == -* ]];
        then
            printf "${RED}Error: Missing an argument for parameter \'apn\'.${NC}\n"  
            exit 1
        fi 

        apn="$2"
        shift
        ;;
    --license) 
        if [ -z "$2" ] || [[ $2 == -* ]];
        then
            printf "${RED}Error: Missing an argument for parameter \'license\'.${NC}\n"  
            exit 1
        fi 

        license="$2"
        shift 
        ;;
  esac
  shift
done

########################## Main ############################
printf "\n======================== Melissa Property Cloud Api ===========================\n"

# Get license (either from parameters or user input)
if [ -z "$license" ];
then
  printf "Please enter your license string: "
  read license
fi

# Check for License from Environment Variables 
if [ -z "$license" ];
then
  license=`echo $MD_LICENSE` 
fi

if [ -z "$license" ];
then
  printf "\nLicense String is invalid!\n"
  exit 1
fi

# Run project
if [ -z "$fips" ] && [ -z "$apn" ];
then
    python3 PropertyPython3.py --license $license  
else
    python3 PropertyPython3.py --license $license --fips $fips --apn $apn
fi
