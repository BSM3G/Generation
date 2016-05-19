#!/bin/bash

date

cd WORK_AREA
source /cvmfs/cms.cern.ch/cmsset_default.sh
export slc6_amd64_gcc491
eval `scramv1 runtime -sh`

run_num=$1
input_sample=$2
infilename=$(sed "${run_num}q;d" list_Samples/${input_sample}.txt)
outfilename=Output.${run_num}.root


cd ${_CONDOR_SCRATCH_DIR}
ls ${_CONDOR_SCRATCH_DIR}

cp -r $CMSSW_BASE/src/Analyzer/BSM3G_TNT_MainAnalyzer/ANALYSISDIRECTORY .
cd ANALYSISDIRECTORY
./BSM3GAnalyzer $infilename $outfilename

xrdcp -sf $_CONDOR_SCRATCH_DIR/ANALYSISDIRECTORY/$outfilename root://cmseos.fnal.gov//store/user/DUMMY/TEMPDIRECTORY/$input_sample

cd ${_CONDOR_SCRATCH_DIR}
rm -rf ANALYSISDIRECTORY

ls ${_CONDOR_SCRATCH_DIR}










