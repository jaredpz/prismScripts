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

imList=$(find ${outDir} -iname *residualised.nii.gz)

for img in ${imList}; do
    
    task=$(echo ${img} | grep -Eo "(Stroop|Navon)")
    sesh=$(echo ${img} | grep -Eo "T00[[:digit:]]{1}")
    subID=$(echo ${img} | grep -Eo "DP5\.SC\.1\.[[:digit:]]{3}")
    uniqueID=$(echo ${img} | grep -Eo "TNI[[:digit:]]{3}_DP5[[:digit:]]{3}")



    cd ${outDir}/${subID}
    if [ ! -e "coreg" ]; then
        mkdir coreg surf
    fi

    echo "START registering subject ${subID}_${sesh}_${task}"   
    bbregister --s ${uniqueID} \
    --mov ${xcpOutDir}/${task}/${subID}/${sesh}/prestats/*referenceVolumeBrain.nii.gz \
    --reg ${outDir}/${subID}/coreg/${subID}_${sesh}_${task}_fs_epi2struct.dat \
    --init-fsl --bold >> ${outDir}/${subID}/coreg/${subID}_${sesh}_${task}_TEMP_coreg.log 2>&1
    echo "COMPLETE registering subject ${subID}_${sesh}_${task}"    

        for hem in ${hemi[@]}; do
            echo "START vol2surf projection for subject ${subID}_${sesh}_${task} on ${hem}" 
            mri_vol2surf --mov ${img} \
            --reg ${outDir}/${subID}/coreg/${subID}_${sesh}_${task}_fs_epi2struct.dat \
            --hemi ${hem} \
            --o ${outDir}/${subID}/surf/${hem}.sm${fwhm}.${subID}_${sesh}_${task}_residualised.mgh \
            --projfrac 0.5 \
            --interp trilinear \
            --noreshape --surf-fwhm ${fwhm} \
            >> ${outDir}/${subID}/surf/${subID}_${sesh}_${task}_TEMP_projection.log 2>&1
            echo "COMPLETE vole2surf projection for subject ${subID}_${sesh}_${task} on ${hem}"

            echo "START surf2surf resampling for subject ${subID}_${sesh}_${task} on ${hem}"
            mri_surf2surf --srcsubject ${uniqueID} \
            --srcsurfval ${outDir}/${subID}/surf/${hem}.sm${fwhm}.${subID}_${sesh}_${task}_residualised.mgh \
            --trgsubject ico \
            --trgicoorder 4 \
            --trgsurfval ${outDir}/${subID}/${sesh}/surf/${hem}.fs4.sm${fwhm}.${subID}_${sesh}_${task}_residualised.mgh \
            --hemi ${hem} >> ${outDir}/${subID}/surf/${subID}_${sesh}_${task}_TEMP_projection.log 2>&1
            echo "COMPLETE surf2surf resampling for subject ${subID}_${sesh}_${task} on ${hem}"

            echo "START Matlab squeeze for subject ${uniqueID} on ${hem}"
            matlab -nodisplay -nojvm \
            -r "addpath('${matlabScriptPath}'); squeezeFuncSurf('${outDir}/${subID}/surf/${hem}.fs4.sm${fwhm}.${subID}_${sesh}_${task}_residualised.mgh', '${outDir}/${subID}/surf/${hem}.squeezed.fs4.sm${fwhm}.${subID}_${sesh}_${task}_residualised.mgh', '${FREESURFER_HOME}'); exit"
            echo "COMPLETE Matlab squeeze for subject ${uniqueID} on ${hem}"
    
        done

        #rename and date logs
        mv ${outDir}/${subID}/surf/${subID}_TEMP_projection.log ${outDir}/${subID}/surf/${subID}_projection_$(date +%s).log
        mv ${outDir}/${subID}/coreg/${subID}_TEMP_coreg.log ${outDir}/${subID}/coreg/${subID}_coreg_$(date +%s).log
done

