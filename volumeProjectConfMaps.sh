#!/usr/bin/env bash

###############################################################################
###############################################################################
# This script smooths and resamples indiPar data from native surface to native volume
# You must hav already smoothed the data and resampled to native surface
# This just takes the native surface maps and projects them back to subejct T1
###############################################################################
###############################################################################

################
# Set defaults #
################
export SUBJECTS_DIR=/data/jet/jmedaglia/jaredz/prism/DP5_TNI_combined/struct
parcDir=/data/jet/jmedaglia/jaredz/prism/DP5_TNI_combined/parc/ParcellationResults

## set directory
cd ${parcDir}

## Get subjects to smooth
subList=$(find ${parcDir} -maxdepth 1 -type d -regextype posix-extended -regex '^.*(TNI011_DP5037|TNI033_DP5025|TNI018_DP5002|DP5040)')


##################################
## RESAMPLE AND SMOOTH NETWORKS ##
##################################

#----------------------#
## LOOP OVER SUBJECTS ##
#----------------------#
for subPath in ${subList}; do
  cd ${parcDir}
  subID=$(basename ${subPath})
  cd ${subPath}
  echo ${subID}

  # get network confidence images to be smoothed
  nets=$(find $(pwd)/smooth -regextype posix-extended -regex '^.*NetworkConfidence_[0-9]{1,2}_lh.*_sm6dil2\.mgh$')


  # make native directory
  if [ ! -e vol ]; then
  mkdir vol && cd vol
  else
    cd vol
  fi

  for netMap in ${nets}; do 

    netMapName=$(basename ${netMap} .mgh)
    netMap_rh=$(echo ${netMap} | sed "s/_lh_/_rh_/")
    netName=$(echo ${netMapName} | grep -Eo 'NetworkConfidence_[0-9]{1,2}')

    echo ${netMapName}


    echo 
    echo ------------------------------------------------------
    echo -- START: reampling network ${netMapName} to volume --
    echo ------------------------------------------------------
    echo

    mri_surf2vol --surfval ${netMap} \
    --hemi lh \
    --fillribbon \
    --subject ${subID} \
    --identity ${subID} \
    --template ${SUBJECTS_DIR}/${subID}/mri/orig.mgz \
    --o ${subID}_${netName}_lh_vol.nii.gz >> ${parcDir}/${subID}/vol/${subID}_volProj.log 2>&1

    mri_surf2vol --surfval ${netMap_rh} \
    --hemi rh \
    --fillribbon \
    --subject ${subID} \
    --identity ${subID} \
    --template ${SUBJECTS_DIR}/${subID}/mri/orig.mgz \
    --merge ${subID}_${netName}_lh_vol.nii.gz \
    --o ${subID}_${netName}_lhrh_vol.nii.gz >> ${parcDir}/${subID}/vol/${subID}_volProj.log 2>&1


    echo 
    echo ------------------------------------------------------
    echo -- FINISH: reampling network ${netMapName} to native --
    echo ------------------------------------------------------
    echo

  done



done

