#!/bin/bash

patORfast=$1

n_proc=300
n_evnt=500
start=0
End_Proc=$[$n_proc + $start - 1]

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
voms-proxy-init --voms cms


if [ ! -d logfiles ]
then
    mkdir logfiles
fi

cp slurm_default.slurm run_slurm.slurm

sed -i -e s/START_NUM/$Start/g run_slurm.slurm
sed -i -e s/END_NUM/$End_Proc/g run_slurm.slurm
sed -i -e s/NUM_EVENT/$Number_Events/g run_slurm.slurm
sed -i -e s/RUNNING_FILE/run_${patORfast}.sh/g run_slurm.slurm


sbatch run_slurm.slurm
