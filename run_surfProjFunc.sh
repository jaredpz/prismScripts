#!/usr/bin/env bash

# wrapper around surfProjFunc.sh

subID=DP5.SC.1.050
subDir=/data/jet/jmedaglia/Freesurfer_subjects/
movRef=/data/picsl/akelkar/rsfmripreproc_DP5/output/Navon/DP5.SC.1.050/T001/prestats/DP5.SC.1.050_T001_referenceVolumeBrain.nii.gz
bold=/data/picsl/akelkar/rsfmripreproc_DP5/output/Navon/DP5.SC.1.050/T001/regress/DP5.SC.1.050_T001_residualised.nii.gz
outDir=/data/jet/jmedaglia/jaredz/prism/DP5_TNI_combined/input/extraProc
scriptPath=/data/jet/jmedaglia/jaredz/prism/scripts

./surfProjFunc.sh ${subID} ${subDir} ${movRef} ${bold} ${outDir} ${scriptPath}

