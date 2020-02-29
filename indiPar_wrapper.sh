#!/bin/bash


export SUBJECTS_DIR="/data/jet/jmedaglia/jaredz/prism/DP5_TNI_combined/struct"
indiParDir="/data/jux/BBL/projects/zimmermanSingleSubjectParcellation/software/IndiPar_v1.0_with_MCR_Package/IndiPar_v1.0"
mcrPath="/data/jux/BBL/projects/zimmermanSingleSubjectParcellation/software/IndiPar_v1.0_with_MCR_Package/MCR_Installer/v85"
inDir="/data/jet/jmedaglia/jaredz/prism/DP5_TNI_combined/input"
outDir="/data/jet/jmedaglia/jaredz/prism/DP5_TNI_combined/parc"


scriptDir=$(pwd)
# cd into input directory and list all subjects
cd ${inDir}
subList=$(find ${inDir} -maxdepth 1 -type d -regextype posix-egrep -regex '^.*(TNI011_DP5037|TNI033_DP5025|TNI018_DP5002|DP5040)')

# iterate over subjects and run indiPar
for subPath in ${subList}; do
  echo $subPath
  sub=$(basename ${subPath})
  echo $sub

  echo ----------------------------------
  echo --- RUNNING INDIPAR FOR ${sub} ---
  echo ----------------------------------
  echo INPUT DIRECTORY = ${inDir}
  echo OUTPUT DIRECTORY = ${outDir}
  echo SUBJECTS_DIR = ${SUBJECTS_DIR}
  echo INDIPAR SOFTWARE DIRECTORY = ${indiParDir}
  echo MATLAB RUNTIME COMPILER = ${mcrPath}
  echo ----------------------------------
  echo ---           BEGIN            ---
  echo ----------------------------------
  echo
  echo $(pwd)
  echo

  cd ${indiParDir}
  echo $(pwd)
  ${scriptDir}/indiPar_single_subject.sh ${sub} ${SUBJECTS_DIR} ${outDir} ${inDir} ${indiParDir} ${mcrPath}
  
  
done
