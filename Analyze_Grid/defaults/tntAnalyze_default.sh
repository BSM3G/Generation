#!/bin/bash
date

cd WORK_AREA
source /cvmfs/cms.cern.ch/cmsset_default.sh
export slc6_amd64_gcc530
eval `scramv1 runtime -sh`

run_num=$[ $1 + $2 + 1 ]
input_sample=$3

infilename=$(sed -n ${run_num}p WORK_AREA/list_Samples/${input_sample}.txt)
outfilename=Output.${run_num}.root

infilename=${infilename/\\/}

cd ${_CONDOR_SCRATCH_DIR}

cp -r $CMSSW_BASE/src/Analyzer/PartDet/ .
cp -r $CMSSW_BASE/src/Analyzer/Pileup/ .
cp -r $CMSSW_BASE/src/Analyzer/Analyzer .
./Analyzer $infilename $outfilename

xrdcp -sf $_CONDOR_SCRATCH_DIR/$outfilename root://cmseos.fnal.gov//store/user/DUMMY/TEMPDIRECTORY/$input_sample

cd ${_CONDOR_SCRATCH_DIR}










