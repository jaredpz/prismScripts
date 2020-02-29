#!/usr/bin/env bash

# This script runs the Wang et al. 2015 Individualized Parcellation algorithm on for one subject

if [[ $# -lt 1 ]]; then
cat <<USAGE

  $0 <subject> <SUBJECTS_DIR> <outputDir> <dataDir> <indiParDir> <mcrPath>
  
  subject - subject ID
  SUBJECTS_DIR - Freesurfer SUBJECTS_DIR
  outputDir - where the results will be saved
  dataDir - input directory.  Should have a folder named
  			"subject" in which the only files are
  			residualised time-series data registered to
  			fsaverage4.  Multiple runs can be in here and
  			will be concatenated before analysis.
  indiParDir - Directory where the indiPar software is installed
  mcrPath - path to the installation of the Matlab Compiler Runtime
  			used for indiPar

USAGE

exit 1

fi

# parse inputs
subID=$1
subDir=$2
outDir=$3
inDir=$4
indiParDir=$5
mcrPath=$6

# make directory to store subject level scripts
if [ ! -e ${outDir}/${subID} ]; then
    mkdir ${outDir}/${subID}
fi

# set script name
scriptToRun=${outDir}/${subID}/indiPar_submit_${subID}.sh

cat > ${scriptToRun} << INDIPAR_SUBJ_JOB_SCRIPT

export SUBJECTS_DIR=${subDir}

cd ${indiParDir}

./IndividualParcellation.sh ${mcrPath} ${subID} ${inDir} ${outDir} ${SUBJECTS_DIR}

INDIPAR_SUBJ_JOB_SCRIPT

cmd="qsub -S /bin/bash -o ${outDir}/${subID}/${subID}_indiPar.stdout -e ${outDir}/${subID}/${subID}_indiPar.stderr ${scriptToRun}"

echo ${cmd}
echo
${cmd}
sleep 0.5
echo

