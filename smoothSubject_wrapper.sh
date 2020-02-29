#!/bin/bash

####
# This script will wrap over all subjects (directory names) in 
# parcDir apply smoothing and resample back to native space
####

subDir="/data/jet/jmedaglia/jaredz/prism/DP5_TNI_combined/struct"
parcDir="/data/jet/jmedaglia/jaredz/prism/DP5_TNI_combined/parc/ParcellationResults"
scriptDir="/data/jet/jmedaglia/jaredz/prism/DP5_TNI_combined/scripts"


# cd into input directory and list all subjects
cd ${parcDir}
subList=$(find ${parcDir} -regextype posix-extended -regex '^.*(TNI011_DP5037|TNI033_DP5025|TNI018_DP5002|DP5040)')

# set SUBJECTS_DIR
export SUBJECTS_DIR=${subDir}

####################
## SET PARAMETERS ##
####################
sm1=6
sm2=6
dil=2

# iterate over subjects and run indiPar
for subPath in ${subList}; do
  echo $subPath
  sub=$(basename ${subPath})
  echo $sub

  cd ${parcDir}/${sub}

  # set script name
  scriptToRun=${parcDir}/${sub}/${sub}_smoothResample.sh

  cat > ${scriptToRun} <<- SMOOTH_SUBJ_JOB_SCRIPT

  export SUBJECTS_DIR=${subDir}

  ${scriptDir}/smoothSingleSubject.sh ${sub} ${SUBJECTS_DIR} ${parcDir} ${dil} ${sm1} ${sm2}

SMOOTH_SUBJ_JOB_SCRIPT

  cmd="qsub -S /bin/bash -o ${parcDir}/${sub}/${sub}_smooth.stdout -e ${parcDir}/${sub}/${sub}_smooth.stderr ${scriptToRun}"

  echo ${cmd}
  echo
  ${cmd}
  sleep 0.5
  echo
  
done
