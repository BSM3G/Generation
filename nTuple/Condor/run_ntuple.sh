#!/bin/bash

cd WORK_AREA
source /cvmfs/cms.cern.ch/cmsset_default.sh
export slc6_amd64_gcc491
eval `scramv1 runtime -sh`

run_num=$[$1+$2]
infilename=root://cmseos.fnal.gov//store/user/USERNAME/Generate/miniAOD/miniAOD.${run_num}.root
outfilename=tnt.${run_num}.root
n_events=$3

cd ${_CONDOR_SCRATCH_DIR}

cp /uscms_data/d3/dteague/CMSSW_7_4_15/src/tnt_default_cfg.py tnt_cfg.py

sed -i -e s/NUMBER_EVENT/$n_events/g tnt_cfg.py
sed -i -e s@INFILE@${infilename}@g tnt_cfg.py
sed -i -e s/OUTFILE/${outfilename}/g tnt_cfg.py

cmsRun tnt_cfg.py

xrdcp $_CONDOR_SCRATCH_DIR/${outfilename} root://cmseos.fnal.gov//store/user/USERNAME/Generate/TNT/
rm ${_CONDOR_SCRATCH_DIR}/${outfilename}
rm ${_CONDOR_SCRATCH_DIR}/tnt_cfg.py









