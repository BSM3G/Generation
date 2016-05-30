#!/bin/bash

date

cd /gpfs21/scratch/teaguedo/workspace/test/CMSSW_7_4_15/src/Analyze_Grid
source /cvmfs/cms.cern.ch/cmsset_default.sh
export slc6_amd64_gcc491
eval `scramv1 runtime -sh`

run_num=$[ $1 ]
input_sample=$2

infilename=$(tail -n+${run_num} list_Samples/${input_sample}.txt | head -n1)
outfilename=${input_sample}.${run_num}.root

infilename=${infilename/\\/}
infilename=${infilename/cmseos/cmsxrootd}
infilename=${infilename/\/ra2tau/}

echo $infilename
echo $outfilename

cd $CMSSW_BASE/src/Analyzer/BSM3G_TNT_MainAnalyzer/VBFEWKinoAnalysis_diMuonChannel_SR
./BSM3GAnalyzer $infilename $outfilename

cp $outfilename ${CMSSW_BASE}/src/Files/Analysis/test/${input_sample}










