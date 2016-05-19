#!/bin/bash

if [ ! -f tnt_default_cfg.py ]
then 
    echo "Need a cfg file to run the task!!"
    echo "Get a run file from Ntuple/BSM3G_NtupleMaker/python"
    exit
fi   
 

source /cvmfs/cms.cern.ch/cmsset_default.sh
export slc6_amd64_gcc491
eval `scramv1 runtime -sh`
voms-proxy-init --voms cms


for inputList in $(cat SAMPLES_LIST.txt)
do
    echo $inputList
    mkdir $inputList
    tmp=( $(wc list_Samples/$inputList) )
    n_proc=${tmp[1]}

    cp condor_default.cmd ${inputList}/run_condor.cmd
    
    cd ${inputList}
    sed -i -e s/INPUT_SAMPLE/${inputList}/g run_condor.cmd
    sed -i -e s/NUMBER_QUEUED/${n_proc}/g run_condor.cmd

    condor_submit run_condor.cmd
    cd ..
done

