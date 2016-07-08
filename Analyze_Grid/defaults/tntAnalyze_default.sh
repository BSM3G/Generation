#!/bin/bash

date

cd WORK_AREA
source /cvmfs/cms.cern.ch/cmsset_default.sh
export slc6_amd64_gcc491
eval `scramv1 runtime -sh`

run_num=$[ $1 + 1 ]
input_sample=$2

infilename=$(tail -n+${run_num} list_Samples/${input_sample}.txt | head -n1)
outfilename=Output.${run_num}.root

infilename=${infilename/\\/}

cd ${_CONDOR_SCRATCH_DIR}

cp -r $CMSSW_BASE/src/Analyzer/BSM3G_TNT_MainAnalyzer/ANALYSISDIRECTORY .
cd ANALYSISDIRECTORY
./BSM3GAnalyzer $infilename $outfilename

xrdcp -sf $_CONDOR_SCRATCH_DIR/ANALYSISDIRECTORY/$outfilename root://cmseos.fnal.gov//store/user/DUMMY/TEMPDIRECTORY/$input_sample

cd ${_CONDOR_SCRATCH_DIR}
rm -rf ANALYSISDIRECTORY










