#!/bin/bash

####
# This script projects residualized time-series data onto the freesurfer surface for each subject
# It also smooths the data by 6mm on the subject surface, then downsamples to fsaverage4 surface.
####

export SUBJECTS_DIR="/data/jet/jmedaglia/jaredz/prism/DP5_TNI_combined/struct"
xcpOutDir="/data/jet/jmedaglia/DP5_study/rsfmripreproc/output"
outDir="/data/jet/jmedaglia/jaredz/prism/DP5_TNI_combined/func"
matlabScriptPath="/data/jet/jmedaglia/jaredz/prism/scripts"
hemi=(lh rh)
fwhm=12


imList=$(find ${outDir} -regextype posix-extended -regex '^.*DP5\.SC\.1\.001.*residualised\.nii\.gz')

for img in ${imList}; do
    
    task=$(echo ${img} | grep -Eo "(Stroop|Navon)")
    sesh=$(echo ${img} | grep -Eo "T00[[:digit:]]{1}")
    subID=$(echo ${img} | grep -Eo "DP5\.SC\.1\.[[:digit:]]{3}")
    uniqueID=$(echo ${img} | grep -Eo "TNI[[:digit:]]{3}_DP5[[:digit:]]{3}")



    cd ${outDir}/${uniqueID}
    if [ ! -e "coreg" ]; then
        mkdir coreg surf
    fi

    echo -----------------------------------------------------
    echo
    echo
    echo
    echo "START registering subject ${subID}_${sesh}_${task}"
    echo
    echo
    echo
    echo -----------------------------------------------------  
    bbregister --s ${uniqueID} \
    --mov ${xcpOutDir}/${task}/${subID}/${sesh}/prestats/*referenceVolumeBrain.nii.gz \
    --reg ${outDir}/${uniqueID}/coreg/${subID}_${sesh}_${task}_fs_epi2struct.dat \
    --init-fsl --bold

    echo -----------------------------------------------------
    echo
    echo
    echo
    echo "COMPLETE registering subject ${subID}_${sesh}_${task}"
    echo
    echo
    echo
    echo -----------------------------------------------------      

        for hem in ${hemi[@]}; do

            echo -----------------------------------------------------
            echo
            echo
            echo
            echo "START vol2surf projection for subject ${subID}_${sesh}_${task} on ${hem}" 
            echo
            echo
            echo
            echo -----------------------------------------------------     
            mri_vol2surf --mov ${img} \
            --reg ${outDir}/${uniqueID}/coreg/${subID}_${sesh}_${task}_fs_epi2struct.dat \
            --hemi ${hem} \
            --o ${outDir}/${uniqueID}/surf/${hem}.sm${fwhm}.${subID}_${sesh}_${task}_residualised.mgh \
            --projfrac 0.5 \
            --interp trilinear \
            --noreshape --surf-fwhm ${fwhm}
            echo -----------------------------------------------------
            echo
            echo
            echo
            echo "COMPLETE vol2surf projection for subject ${subID}_${sesh}_${task} on ${hem}"
            echo
            echo
            echo
            echo -----------------------------------------------------    

            echo -----------------------------------------------------
            echo
            echo
            echo
            echo "START surf2surf resampling for subject ${subID}_${sesh}_${task} on ${hem}"
            echo
            echo
            echo
            echo -----------------------------------------------------  
            mri_surf2surf --srcsubject ${uniqueID} \
            --srcsurfval ${outDir}/${uniqueID}/surf/${hem}.sm${fwhm}.${subID}_${sesh}_${task}_residualised.mgh \
            --trgsubject ico \
            --trgicoorder 4 \
            --trgsurfval ${outDir}/${uniqueID}/surf/${hem}.fs4.sm${fwhm}.${subID}_${sesh}_${task}_residualised.mgh \
            --hemi ${hem}
            echo -----------------------------------------------------
            echo
            echo
            echo
            echo "COMPLETE surf2surf resampling for subject ${subID}_${sesh}_${task} on ${hem}"
            echo
            echo
            echo
            echo -----------------------------------------------------


            echo -----------------------------------------------------
            echo
            echo
            echo
            echo "START Matlab squeeze for subject ${uniqueID} on ${hem}"
            echo
            echo
            echo
            echo -----------------------------------------------------
            matlab -nodisplay -nojvm \
            -r "addpath('${matlabScriptPath}'); squeezeFuncSurf('${outDir}/${uniqueID}/surf/${hem}.fs4.sm${fwhm}.${subID}_${sesh}_${task}_residualised.mgh', '${outDir}/${uniqueID}/surf/${hem}.squeezed.fs4.sm${fwhm}.${subID}_${sesh}_${task}_residualised.mgh', '${FREESURFER_HOME}'); exit"
            echo -----------------------------------------------------
            echo
            echo
            echo
            echo "COMPLETE Matlab squeeze for subject ${uniqueID} on ${hem}"
            echo
            echo
            echo
            echo -----------------------------------------------------
    
        done

    
done
