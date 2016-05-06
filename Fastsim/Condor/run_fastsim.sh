#!/bin/bash

cd WORK_AREA
source /cvmfs/cms.cern.ch/cmsset_default.sh
export slc6_amd64_gcc491
eval `scramv1 runtime -sh`

run_num=$[$1+$2]
filename=AODSIM.${run_num}.root
n_events=$3
start=$[$n_events*$run_num]

cd ${_CONDOR_SCRATCH_DIR}

cp WORK_AREA/fastsim_default_cfg.py fastsim_cfg.py

sed -i -e s/NUMBER_EVENT/$n_events/g fastsim_cfg.py
sed -i -e s/OUTFILE/${filename}/g fastsim_cfg.py
sed -i -e s/SKIPPER/${start}/g fastsim_cfg.py

cmsRun fastsim_cfg.py

xrdcp $_CONDOR_SCRATCH_DIR/${filename} root://cmseos.fnal.gov//store/user/USERNAME/Generate/AODSIM/
rm ${_CONDOR_SCRATCH_DIR}/${filename}
rm ${_CONDOR_SCRATCH_DIR}/fastsim_cfg.py









