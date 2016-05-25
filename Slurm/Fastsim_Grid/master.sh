#!/bin/bash

### variable for picking out if fastsim or pat is being run
patORfast=$1

### n_proc    -> number of processes to be run OR in other words, number of AOD files to be made
### n_evnt    -> number of events in each process
### start     -> starting point for process.  If you have made AOD0-100, set start to 101 to make AOD101
### End_Proc  -> made variable to find what the last process number is
### num_cores -> number of cores used, or number of process that can be run at once
n_proc=10
n_evnt=500
start=0
End_Proc=$[$n_proc + $start - 1]
num_cores=10


if [[ -z $patORfast && ( $patORfast != 'pat' || $patORfast != 'fastsim' ) ]] 
then 
    echo "Please specify if you are running pat or FastSim by entering: "
    echo ./master fastsim
    echo ./master pat
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

if [ ! -d ${CMSSW_BASE}/src/Files ] 
then
    mkdir ${CMSSW_BASE}/src/Files
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
    if [ ! -d ${CMSSW_BASE}/src/Files/AODSIM ] 
    then
	mkdir ${CMSSW_BASE}/src/Files/AODSIM 
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
    if [ ! -d ${CMSSW_BASE}/src/Files/miniAOD ]
    then
	mkdir ${CMSSW_BASE}/src/Files/miniAOD
    fi
fi



if [ ! -d logfiles ]
then
    mkdir logfiles
fi

cp slurm_default.slurm run_slurm.slurm

position=$(pwd -P)

sed -i -e s/START_NUM/$start/g run_slurm.slurm
sed -i -e s/END_NUM/$End_Proc/g run_slurm.slurm
sed -i -e s/NUM_EVENT/$n_evnt/g run_slurm.slurm
sed -i -e s/NUM_CORES/$num_cores/g run_slurm.slurm
sed -i -e s@POSITION@$position@g run_slurm.slurm
sed -i -e s/RUNNING_FILE/run_${patORfast}.sh/g run_slurm.slurm


sbatch run_slurm.slurm
