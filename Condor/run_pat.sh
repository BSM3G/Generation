#!/bin/bash

cd WORK_AREA
source /cvmfs/cms.cern.ch/cmsset_default.sh
export slc6_amd64_gcc491
eval `scramv1 runtime -sh`

run_num=$[$1+$2]
infilename=root://cmseos.fnal.gov//store/user/USERNAME/Generate/AODSIM/AODSIM.${run_num}.root
outfilename=miniAOD.${run_num}.root
n_events=$3

cd ${_CONDOR_SCRATCH_DIR}

cp WORK_AREA/pat_default_cfg.py pat_cfg.py

sed -i -e s/NUMBER_EVENT/$n_events/g pat_cfg.py
sed -i -e s@INFILE@${infilename}@g pat_cfg.py
sed -i -e s/OUTFILE/${outfilename}/g pat_cfg.py

cmsRun pat_cfg.py

xrdcp $_CONDOR_SCRATCH_DIR/${outfilename} root://cmseos.fnal.gov//store/user/USERNAME/Generate/miniAOD/
rm ${_CONDOR_SCRATCH_DIR}/${outfilename}
rm ${_CONDOR_SCRATCH_DIR}/pat_cfg.py










