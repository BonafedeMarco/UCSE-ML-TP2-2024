#!/bin/bash
shopt -s nullglob # to avoid listing dotted directories allegedly

BLACK="\033[30m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PINK="\033[35m"
CYAN="\033[36m"
WHITE="\033[37m"
NORMAL="\033[0;39m"

# PARAMETERS
validationPercentage=40 # int because bash and floats
seed="milangaNapolitana" # any string is the same as 0
trainDir=./train
validationDir=./validation

# Dataset check and backup handling
dataCheck=0

if [ -e $trainDir ]
then
  echo -e "[ $CYAN BAK $WHITE ] Train dataset found"
  ((dataCheck+=1))
fi
if [ -e $trainDir-backup ]
then
  echo -e "[ $CYAN BAK $WHITE ] Backup found"
  ((dataCheck+=2))
fi

if [ $dataCheck == 0 ]
then
  echo -e "[ $RED ERR $WHITE ] Did not find a training dataset to work with. Check paths"
  exit 1
fi

if [ $dataCheck == 1 ]
then
  echo -e "[ $YELLOW BAK $WHITE ] No backup found, creating..."
  cp -r ${trainDir} ${trainDir}-backup
fi

if [ $dataCheck == 2 ]
then
  echo -e "[ $YELLOW BAK $WHITE ] Restoring backup for use"
  cp -r ${trainDir}-backup ${trainDir}
fi

#if [ $dataCheck == 3 ]
#then
#  # Both directories exist, add a check to verify that their contents match
#fi

# Check for existing validation dataset
if [ -e $validationDir ]
then
  for trainSubDir in ${trainDir}/*
  do
    validationSubDir="${validationDir}"/"${trainSubDir##*/train/}"
    
    if [ -e $validationSubDir ]
    then
      fileCount=($validationSubDir/*)
      fileCount=${#fileCount[@]}

      if [ $fileCount != 0 ]
      then
        echo -e "[ $RED ERR $WHITE ] "${validationSubDir}" already exists and is not empty"
        exit 1
      fi
    fi
  done
fi

# Validation folder structure creation
for trainSubDir in ${trainDir}/*
do
  validationSubDir="${validationDir}"/"${trainSubDir##*/train/}"

  if ! [ -e $validationSubDir ]
  then
    echo -e "[ $GREEN DIR $WHITE ] "${validationSubDir}" does not exist, creating..."
    mkdir -p $validationSubDir
  fi
done

# Dataset splitting
RANDOM=$seed
for trainSubDir in ${trainDir}/*
do
  validationSubDir="${validationDir}"/"${trainSubDir##*/train/}"

  images=($trainSubDir/*)
  imageCount=${#images[@]}

  toMove=$(( imageCount / 100 * validationPercentage )) # Imprecise, but works in bash ootb
  #toMove=$(echo "$imageCount * ($validationPercentage / 10)" | bc -l) # More precise, but requires the installation of bc

  echo -e "[ $CYAN IMG $WHITE ] "${trainSubDir}" contains "${imageCount}" images, moving "${toMove}" as validation..."
  
  #toMove=5 # hardcode debug limit
  while [ $toMove -gt 0 ]
  do
    index=$(($RANDOM % $imageCount))
    image=${images[index]}

    #echo "mv "${image}" "${validationSubDir}""${image##$trainSubDir}" &" #dry run
    exec mv "${image}" "${validationSubDir}""${image##$trainSubDir}" &

    images=($trainSubDir/*)
    imageCount=${#images[@]}

    ((toMove--))
  done
done
