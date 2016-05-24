#!/bin/bash

n_proc=10
n_evnt=500
start=0
End_Proc=$[$n_proc + $start - 1]
num_cores=10

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

if [ ! -d ${CMSSW_BASE}/src/Files ]
then
    mkdir ${CMSSW_BASE}/src/Files
fi


if [ ! -d ${CMSSW_BASE}/src/Files/TNT ]
then
    mkdir ${CMSSW_BASE}/src/Files/TNT
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

sbatch run_slurm.slurm


