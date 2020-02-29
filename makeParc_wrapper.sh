#!/bin/bash

parcDir='/data/jet/jmedaglia/jaredz/prism/DP5_TNI_combined/parc/ParcellationResults'
matlabScriptPath='/data/jet/jmedaglia/jaredz/prism/DP5_TNI_combined/scripts'
lutFile='/data/jet/jmedaglia/jaredz/prism/DP5_TNI_combined/n19_WangYeoParcellation_colorLUT.mat'
cd ${parcDir}

subList=$(find $(pwd) -maxdepth 1 -type d -regextype posix-extended -regex '^.*(TNI033_DP5025)')

for sub in ${subList}; do

  subID=$(basename ${sub})

  if [ ! -e "${sub}/lh.${subID}_native_parc.annot" ]; then
    echo "START Matlab parcellation for subject ${sub}"
    matlab -nodisplay \
    -nojvm \
    -r \
    "addpath('${matlabScriptPath}'); makeParcNative('${parcDir}', '${subID}', '${lutFile}', '${FREESURFER_HOME}'); exit"
    echo "COMPLETE Matlab parcellation for subject ${sub}"
  else
    echo "parcellation files exist already"
  fi

done
