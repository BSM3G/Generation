#!/bin/bash

n_proc=300
n_evnt=500
start=0



if [ ! -f tnt_default_cfg.py ]
then 
    echo "Need a cfg file to run the task!!"
    echo "Get a run file from Ntuple/BSM3G_NtupleMaker/python"
    exit
fi   
 

source /cvmfs/cms.cern.ch/cmsset_default.sh
export slc6_amd64_gcc491
eval `scramv1 runtime -sh`

need_init=$(voms-proxy-info | grep "timeleft" | awk 'BEGIN{FS=":"}{if($2==" 0" && $3=="00" && $4=="00"){print "true"}}')
if [ $need_init == "true" ]
then
    voms-proxy-init --voms cms
fi



if [ ! -d logfiles ]
then
    mkdir logfiles
fi



cp condor_default.cmd run_condor.cmd
sed -i -e s/START/${start}/g run_condor.cmd
sed -i -e s/EVENTS_PROCESSED/${n_evnt}/g run_condor.cmd
sed -i -e s/NUMBER_QUEUED/${n_proc}/g run_condor.cmd

condor_submit run_condor.cmd


