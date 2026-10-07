#!/bin/bash

# Runs the Melissa Property Cloud API Python 3 sample.
#
# This script runs PropertyPython3.py with python3, passing along the license
# and (if supplied) the lookup fields.
#
# Overall flow:
#   1. Parse the command-line options below.
#   2. Resolve the license (--license, then a prompt, then the MD_LICENSE environment variable).
#   3. Run PropertyPython3.py: with the lookup fields if any was supplied,
#      otherwise with only the license (the Python program prompts for each field).
#
# Options (each takes a value):
#   --fips      County FIPS code to test.
#   --apn       Assessor's Parcel Number (APN) to test.
#   --license   License string. If omitted, the script prompts for it; if the prompt
#               is left blank, it falls back to MD_LICENSE. Running without --license
#               always prompts, even when MD_LICENSE is set.
#
# PropertyPython3.py is found relative to the current directory, so run the script from its own folder.
#
# Examples:
#   ./PropertyPython3.sh --license "your-license"
#   ./PropertyPython3.sh --fips "06059" --apn "80505208" --license "your-license"

######################### Constants ##########################

RED='\033[0;31m' #RED
NC='\033[0m' # No Color

######################### Parameters ##########################

fips=""
apn=""
license=""

# Read each --flag and its value. A flag with no value, or whose value starts with
# "-", is an error. Unrecognized options are ignored.
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
# Neither --fips nor --apn supplied -> run with only the license (the program prompts);
# otherwise pass both through. An unsupplied field arrives as an empty string and the
# program prompts for it.
if [ -z "$fips" ] && [ -z "$apn" ];
then
    python3 PropertyPython3.py --license "$license"
else
    python3 PropertyPython3.py --license "$license" --fips "$fips" --apn "$apn"
fi
