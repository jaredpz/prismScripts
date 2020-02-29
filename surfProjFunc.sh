#!/usr/bin/env bash

# This function takes a T1 and residualized BOLD time-series and projects
# time-series onto Freesurfer surface.

if [[ $# -lt 1 ]]; then
cat <<USAGE

  $0 <subject> <SUBJECTS_DIR> <movRef> <bold> <outDir> <scriptPath>
  
  subject - subject ID
  SUBJECTS_DIR - Freesurfer SUBJECTS_DIR
  outputDir - where the results will be saved
  movRef - Moving reference image.  Should be reference BOLD used for coreg.
  bold - residualized BOLD time-series image
  outDir - directory to save outputs.
  scriptPath - full-path to Matlab function for squeezing the surface projected time-series
USAGE

exit 1

fi

# Parse inputs
subID=$1
subDir=$2
movRef=$3
bold=$4
outDir=$5
scriptPath=$6

# set SUBEJCTS_DIR
export SUBJECTS_DIR=${subDir}

# hemispheres to project
hemis=(lh rh)

# extract BOLD image filename
boldName1=$(basename ${bold})
boldName2=${boldName1%.nii.gz}



# register BOLD to subject surface with bbr
bbregister --s ${subID} \
    --mov ${movRef} \
    --reg ${outDir}/${subID}_fs_epi2struct.dat \
    --init-fsl --bold


# project to surface
for hemi in ${hemis[@]}; do

  # projection to subject surface
  mri_vol2surf --mov ${bold} \
        --reg ${outDir}/${subID}_fs_epi2struct.dat \
        --hemi ${hemi} \
        --o ${outDir}/${hemi}.sm6.${boldName2}.mgh \
        --projfrac 0.5 \
        --interp trilinear \
        --noreshape --surf-fwhm 6

  # resample to fsaverage4      
  mri_surf2surf --srcsubject ${subID} \
              --srcsurfval ${outDir}/${hemi}.sm6.${boldName2}.mgh \
              --trgsubject ico \
              --trgicoorder 4 \
              --trgsurfval ${outDir}/${hemi}.fs4.sm6.${boldName2}.mgh \
              --hemi ${hemi}

  matlab -nodisplay -nojvm \
            -r "addpath('${scriptPath}'); squeezeFuncSurf('${outDir}/${hemi}.fs4.sm6.${boldName2}.mgh', '${outDir}/${hemi}.squeezed.fs4.sm6.${boldName2}.mgh', '${FREESURFER_HOME}'); exit"



done
