#!/bin/bash

if [ ! -f tntAnalyze.sh ]
then 
    echo "Need the TNT Analyze file!!"
    echo "Get a run file from running NormalSetup.csh"
    exit
fi   
 

source /cvmfs/cms.cern.ch/cmsset_default.sh
export slc6_amd64_gcc491
eval `scramv1 runtime -sh`
voms-proxy-init --voms cms


for inputList in $(cat SAMPLES_LIST.txt)
do
    echo $inputList
    if [ ! -d $inputList ] 
    then
	mkdir $inputList
    fi
    tmp=( $(wc list_Samples/${inputList}.txt) )
    n_proc=${tmp[1]}

    cp condor_default.cmd ${inputList}/run_condor.cmd
    cp tntAnalyze.sh $inputList

    cd ${inputList}
    sed -i -e s/INPUT_SAMPLE/${inputList}/g run_condor.cmd
    sed -i -e s/NUMBER_QUEUED/${n_proc}/g run_condor.cmd
    
    condor_submit run_condor.cmd
    cd ..
done

