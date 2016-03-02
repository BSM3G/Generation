#!/bin/bash

Number_Events=10
Number_Processes=5
Start=0
End_Proc=$[$Number_Processes + $Start - 1]

cd /home/teaguedo/scratch/CMSSW_7_4_4/src

if [ ! -d logfiles ]
then 
    mkdir logfiles
fi

if [ ! -f fastsim_default_cfg.py ]
then
    echo Need a cfg file to run the task!
    echo Run setup_cfg.sh

fi

if [ ! -f events.lhe ]
then 
    echo "events.lhe does not exist. Copy in to src or make using MadGraph"
    exit
fi

cp slurm_default.slurm run_slurm.slurm

sed -i -e s/START_NUM/$Start/g run_slurm.slurm
sed -i -e s/END_NUM/$End_Proc/g run_slurm.slurm
sed -i -e s/NUM_EVENT/$Number_Events/g run_slurm.slurm


sbatch run_slurm.slurm






