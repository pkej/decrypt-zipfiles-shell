#!/bin/bash

# TODO: Checking if a file is complete before opening.

## Next line commented out on purpose. This script depends on error codes from
## other commandline commands in logic blocks
#set -o errexit

set -o nounset
set -o pipefail

optstring=":hdp:x:u:b:z:e:aqv"
autocleanup=0
quietmode=0
verbosemode=0

while getopts ${optstring} arg; do
  case ${arg} in
    q)
      quietmode=1
      ;;
    v)
      verbosemode=1
      ;;
    a)
      autocleanup=1
      if [[ ${verbosemode} -eq 1 ]]
      then
        echo "Autocleanup = ${autocleanup} so we will delete old files that have been extraced before"
      fi
      ;;
    d)
      if [[ ${verbosemode} -eq 1 ]]
      then
        echo "Successfully extracted zip files will be deleted"
      fi
      ;;
    b)  
      if [[ -d "${OPTARG}" ]]
      then
        backupdirectory=$(readlink -f "${OPTARG}")
        if [[ ${verbosemode} -eq 1 ]]
        then  
          echo "Backup directory: '${backupdirectory}' for unsuccessful files"
        fi
      else
        echo "Backup directory: '${OPTARG}' doesn't exist, can't perform backup"
        exit 1
      fi
      ;;
    z)
      if [[ -d "${OPTARG}" ]]
      then
        zipdirectory=$(readlink -f "${OPTARG}")
        if [[ ${quietmode} -eq 0 ]]
        then 
          echo "Zip directory: '${zipdirectory}' for fetching files"
        fi
      else
        echo "Directory '${OPTARG}' doesn't exist, can't do any extractions"
        exit 1
      fi
      ;;
    p)
      if [[ -f "${OPTARG}" ]]
      then
        passwordfile=$(basename -- "${OPTARG}")
        passworddirectory=$(readlink -f "${OPTARG%"${passwordfile}"}")
        nosPasswords=$(wc -l < "${passworddirectory}/${passwordfile}")
        nosPasswords=${nosPasswords// /}
        if [[ quietmode -eq 0 ]]
        then 
          echo "Passwords file: '${passworddirectory}/${passwordfile}' contains '${nosPasswords}' passwords"
        fi
      else
        echo "File '${OPTARG}' does not exist"
        exit 1
      fi
      ;;
    x)
      
      if [[ -f "${OPTARG}" ]]
      then
        excludefiles=$(basename -- "${OPTARG}")
        excludefiledirectory=$(readlink -f "${OPTARG%"${excludefiles}"}")
        if [[ ${verbosemode} -eq 1 ]]
        then 
          echo "Exclude list: '${excludefiledirectory}/${excludefiles}'"
        fi
      else
        if [[ ${quietmode} -eq 0 ]]
        then 
          echo "File '${OPTARG}' does not exist"
          echo "It will be created"
        fi
      fi
      ;;
    u)

      if [[ -f "${OPTARG}" ]]
      then
        unsuccessfulfile=$(basename -- "${OPTARG}")
        unsuccessfulfiledirectory=$(readlink -f "${OPTARG%"${unsuccessfulfile}"}")
        if [[ ${verbosemode} -eq 1 ]]
        then 
          echo "Unsuccessful list: '${unsuccessfulfiledirectory}/${unsuccessfulfile}' because passwords didn't work"
        fi
      else
        if [[ $quietmode -eq 0 ]]
        then 
          echo "File '${OPTARG}' does not exist"
          echo "It will be created"
        fi
      fi
      ;;
    e)
      if [[ -d "${OPTARG}" ]]
      then
        extractedirectory=$(readlink -f "${OPTARG}")
        if [[ ${quietmode} -eq 0 ]]
        then 
          echo "Extraction directory '${extractedirectory}'"
        fi
      else
        if [[ quietmode -eq 0 ]]
        then 
          echo "Directory '${OPTARG}' doesn't exist, it will be created"
        fi
        mkdir "${OPTARG}"
      fi
      ;;
    h)
      echo "showing usage!"
      usage
      ;;
    :)
      echo "$0: Must supply an argument to -$OPTARG." >&2
      exit 1
      ;;
    ?)
      echo "Invalid option: -${OPTARG}."
      exit 2
      ;;
  esac
done

currentWorkingDirectory=$(pwd)
if [[ $verbosemode -eq 1 ]]
then
  echo "We're starting in ${currentWorkingDirectory}"
  echo "CDing into ${extractedirectory}"
fi

cd "${extractedirectory}" || exit
passwordFound=0
correctPassword=""

listOfZipfiles=$(ls "${zipdirectory}/"*.zip 2>/dev/null)
if [[ $listOfZipfiles == "" ]]
then
  echo "No files to extract"
  exit 0
fi
if [[ $verbosemode -eq 1 ]]
then
  echo "Files to extract ${listOfZipfiles}"
fi



for f in "${zipdirectory}"/*.zip
do
  zipfile="$(basename -- "${f}")"
  zipfilefull="${zipdirectory}/${zipfile}"

  if ! grep -qxFe "${zipfile}" "${excludefiledirectory}/${excludefiles}"; then
    if [[ $verbosemode -eq 1 ]]
    then
      echo "Trying to extract: ${zipfilefull}"
    fi
    if unzip -qqtP fail "${zipfilefull}" 2>/dev/null ; then
      if [[ $verbosemode -eq 1 ]]
      then
        echo "File is unencrypted: ${zipfilefull}"
        echo "Adding ${zipfile} to ${excludefiles}"
      fi
      unzip -qqo "${zipfilefull}" 2>/dev/null
      echo "${zipfile}" >> "${excludefiledirectory}/${excludefiles}"
    else
      if [[ $verbosemode -eq 1 ]]
      then
        echo "File is encrypted: ${zipfilefull}"
      fi
      while IFS="" read -r p || [ -n "$p" ]
      do
        if [[ $verbosemode -eq 1 ]]
        then
          printf 'Testing password: %s\n' "$p"
        fi
        if unzip -qqtP "${p}" "${zipfilefull}" 1>/dev/null 2>/dev/null ; then
          passwordFound=1
          correctPassword="${p}"
          break
        fi
      done < "${passworddirectory}/${passwordfile}"

      if [ ${passwordFound} -eq 1 ] ; then
        if [[ $quietmode -eq 0 || $verbosemode -eq 1 ]]
        then
          echo "Correct password '${correctPassword}' for ${zipfile} found"
          echo "Adding ${zipfile} to ${excludefiles}"
        fi
        echo "${zipfile}" >> "${excludefiledirectory}/${excludefiles}"
        echo "${correctPassword} ${zipfile}" >> "${excludefiledirectory}/_password_for_file.txt"
        unzip -qqoP "${p}" "${zipdirectory}/${zipfile}" 2>/dev/null
      else
        if [[ $quietmode -eq 0 || $verbosemode -eq 1 ]]
        then 
          echo "No password in password list worked for this file"
          echo "Adding ${zipfile} to ${unsuccessfulfiledirectory}/${unsuccessfulfile}"
          echo "Moving ${zipfile} to '${backupdirectory}'"
        fi
        echo "${zipfile}" >> "${unsuccessfulfiledirectory}/${unsuccessfulfile}"
        mv "${zipfilefull}" "${backupdirectory}"
      fi

      # Add file to another xlist for files with no correct password!
    fi
  else
    echo "Skipping: ${zipfilefull}"
    if [[ $autocleanup -eq 1 ]]
    then
      echo "Deleting: ${zipfilefull}"
      rm "${zipfilefull}"
    fi
  fi

  shopt -s nullglob dotglob     # To include hidden files
  OLDIFS="$IFS"
  IFS=""

  find "${extractedirectory}" -maxdepth 1 -type f -exec mv {} "${extractedirectory}/${zipfile%.*}" \;

  IFS=$OLDIFS
done
