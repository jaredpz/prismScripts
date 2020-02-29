#!/usr/bin/env bash

# This script will take as the output of the Wang et al 2015
# individual parcellation script and will smooth and resample
# the network confidence maps to the native subject surface

if [[ $# -lt 1 ]]; then
cat <<USAGE

  $0 <subject> <SUBJECTS_DIR> <parcDir> <dil> <sm1> <sm2>
  
  subject - subject ID
  SUBJECTS_DIR - Freesurfer SUBJECTS_DIR
  outputDir - where the results will be saved
  parcDir - input directory.  This is the output directory of
            The indiPar algorithm.
  dil - How much to dilate the label masks for smoothing.  
        Recommended is 2
  sm1 - FWHM of first smoothing iteration.  This is done constrained 
        within the dilated label mask to preserve network topography.
        Recommended is 6
  sm2 - FWHM of second smoothing iteration.  The second smoothing 
        iteration is not constrained by the label mask, and thus
        should be relatively small.  Recommended is 6, sm2 <= sm1
USAGE

exit 1

fi

# Parse inputs
subID=$1
subDir=$2
parcDir=$3
dil=$4
sm1=$5
sm2=$6

export SUBJECTS_DIR=${subDir}

cd ${parcDir}/${subID}

# get network masks to resample
masks=$(find $(pwd) -regextype posix-extended -regex '^.*Network_[0-9]{1,2}_[lr]h\.mgh$')
# get network confidence images to be smoothed
nets=$(find $(pwd) -regextype posix-extended -regex '^.*NetworkConfidence_[0-9]{1,2}_[lr]h\.mgh$')


# make label directory
if [ ! -e label ]; then
mkdir label && cd label
else
  cd label
fi

#-------------------#
## LOOP OVER MASKS ##
#-------------------#
for netMask in ${masks}; do 
  hemi=$(echo ${netMask} | grep -Eo '[lr]h')
  netMaskName=$(basename ${netMask} .mgh)

  echo 
  echo --------------------------------------------
  echo -- START: resampling label ${netMaskName} --
  echo --------------------------------------------
  echo 

  # resample to desired fsaverage
  mri_surf2surf --srcsubject fsaverage4 \
  --srcsurfval ${netMask} \
  --trgsubject ${subID} \
  --trgsurfval ./${netMaskName}_native.mgh \
  --hemi ${hemi} \
  --cortex > ${parcDir}/${subID}/label/${subID}_label.log 2>&1

  # convert to label
  mri_cor2label --i ./${netMaskName}_native.mgh \
  --id 1 \
  --l ./${netMaskName}_native.label \
  --surf ${subID} ${hemi} white >> ${parcDir}/${subID}/label/${subID}_label.log 2>&1

  # dilate by 2 steps
  mri_label2label --srclabel ./${netMaskName}_native.label \
  --s ${subID} \
  --hemi ${hemi} \
  --dilate ${dil} \
  --trglabel ./${netMaskName}_native_dil${dil}.label \
  --regmethod surface >> ${parcDir}/${subID}/label/${subID}_label.log 2>&1

  echo 
  echo --------------------------------------------
  echo -- FINISH: resampling label ${netMaskName} --
  echo --------------------------------------------
  echo 

done

# cd back into subject directory
cd ${parcDir}/${subID}

# make smooth directory
if [ ! -e smooth ]; then
mkdir smooth && cd smooth
else
  cd smooth
fi

#------------------#
## LOOP OVER NETS ##
#------------------#
for netMap in ${nets}; do 
  hemi=$(echo ${netMap} | grep -Eo '[lr]h')
  netMapName=$(basename ${netMap} .mgh)
  netNum=$(echo ${netMapName} | grep -Eo '[[:digit:]]{1,2}')
  label1=$(ls ../label/Network_${netNum}_${hemi}_native.label)
  label2=$(ls ../label/Network_${netNum}_${hemi}_native_dil${dil}.label)

  echo 
  echo --------------------------------------------
  echo -- START: smoothing network ${netMapName} --
  echo --------------------------------------------
  echo 

  # resample and smooth conidence map from fsav4 to fsav
  mri_surf2surf --srcsubject fsaverage4 \
  --srcsurfval ${netMap} \
  --trgsubject ${subID} \
  --trgsurfval ${netMapName}_native_sm${sm1}.mgh \
  --fwhm-trg ${sm1} \
  --hemi ${hemi} \
  --label-trg ${label1} >> ${parcDir}/${subID}/smooth/${subID}_smooth.log 2>&1

  # smooth by 6 fwhm inside dilated mask
  mri_surf2surf --srcsubject ${subID} \
  --srcsurfval ${netMapName}_native_sm${sm1}.mgh \
  --trgsubject ${subID} \
  --trgsurfval ${netMapName}_native_sm${sm1}_sm${sm2}dil${dil}.mgh \
  --fwhm-trg ${sm2} \
  --hemi ${hemi} \
  --label-trg ${label2} >> ${parcDir}/${subID}/smooth/${subID}_smooth.log 2>&1

  echo 
  echo --------------------------------------------
  echo -- FINISH: smoothing network ${netMapName} --
  echo --------------------------------------------
  echo 
done
