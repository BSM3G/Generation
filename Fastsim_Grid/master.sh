#!/bin/bash

patORfast=$1

n_proc=300
n_evnt=500
start=0


if [[ -z $patORfast && ( $patORfast != 'pat' || $patORfast != 'fastsim' ) ]] 
then 
    echo "Please specify if you are running pat or FastSim by entering: "
    echo ./master fastsim
    echo ./master pat
    exit
fi

if [ $patORfast == "fastsim" ]
then 
  
    if [ ! -f events.lhe ]
    then
	echo Need an LHE file to run events over!
	exit
    fi

    if [ ! -f fastsim_default_cfg.py ]
    then 
	echo "Need a cfg file to run the task!!"
	echo "Please run ./setup.sh to get the files"
	exit
    fi

fi    


if [ $patORfast == "pat" ]
then 
    if [ ! -f pat_default_cfg.py ]
    then 
	echo "Need a cfg file to run the task!!"
	echo "Please run ./setup.sh to get the files"
	exit
    fi    
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
sed -i -e s/EXECUTING/${patORfast}/g run_condor.cmd
sed -i -e s/EVENTS_PROCESSED/${n_evnt}/g run_condor.cmd
sed -i -e s/NUMBER_QUEUED/${n_proc}/g run_condor.cmd

condor_submit run_condor.cmd


