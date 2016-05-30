#!/bin/bash

#SBATCH --ntasks=1
#SBATCH --time=1:00:00
#SBATCH --mem=4G
#SBATCH --array=START_NUM-END_NUM%4
#SBATCH --output=output_%A_%a.out


echo "SLURM_JOBID: " $SLURM_JOBID
echo "SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_TASK_ID
echo "SLURM_ARRAY_JOB_ID: " $SLURM_ARRAY_JOB_ID
cd POSITION
source /cvmfs/cms.cern.ch/cmsset_default.sh
export slc6_amd64_gcc491
eval `scramv1 runtime -sh`


grid=$(grid-proxy-info | grep "path" | awk '{print $3}')
export X509_USER_PROXY=$grid


. tntAnalyze.sh $SLURM_ARRAY_TASK_ID INPUT_SAMPLE