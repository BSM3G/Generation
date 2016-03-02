#!/bin/bash

#SBATCH --ntasks=1
#SBATCH --time=1:00:00
#SBATCH --mem=4G
#SBATCH --array=START_NUM-END_NUM%4
#SBATCH --output=output_%A_%a.out

Number_Events=NUM_EVENT



echo "SLURM_JOBID: " $SLURM_JOBID
echo "SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_TASK_ID
echo "SLURM_ARRAY_JOB_ID: " $SLURM_ARRAY_JOB_ID
cd /scratch/teaguedo/workspace/CMSSW_7_4_4/src
source /cvmfs/cms.cern.ch/cmsset_default.sh
export slc6_amd64_gcc491
eval `scramv1 runtime -sh`


. run_fastsim.sh $SLURM_ARRAY_TASK_ID $Number_Events






