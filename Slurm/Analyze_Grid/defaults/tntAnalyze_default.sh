#!/bin/bash

date

cd WORK_AREA
source /cvmfs/cms.cern.ch/cmsset_default.sh
export slc6_amd64_gcc491
eval `scramv1 runtime -sh`

run_num=$[ $1 + 1 ]
input_sample=$2

infilename=$(tail -n+${run_num} list_Samples/${input_sample}.txt | head -n1)
outfilename=${input_sample}.${run_num}.root

infilename=${infilename/\\/}

cd $CMSSW_BASE/src/Analyzer/BSM3G_TNT_MainAnalyzer/ANALYSISDIRECTORY
./BSM3GAnalyzer $infilename $outfilename

cp $outfilename ${CMSSW_BASE}/src/Files/Analysis/WORK_DIRECTORY/${input_sample}










