#!/bin/bash

#SBATCH --ntasks=1
#SBATCH --time=1:00:00
#SBATCH --mem=4G
#SBATCH --output=output_%A.out

INPUT_SAMPLE=$1; shift
outfilename=Output.${1}.root; shift
rest=$@

echo "SLURM_JOBID: " $SLURM_JOBID
echo "SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_TASK_ID
echo "SLURM_ARRAY_JOB_ID: " $SLURM_ARRAY_JOB_ID
echo $outfilename

source /cvmfs/cms.cern.ch/cmsset_default.sh
export slc6_amd64_gcc530
eval `scramv1 runtime -sh`

sleep 30

path="/cms/store/user/teaguedo"
touch $path/$outfilename
echo ./Analyzer -out $outfilename -in ${rest[@]} >> $path/${outfilename}





# grid=$(grid-proxy-info | grep "path" | awk '{print $3}')
# export X509_USER_PROXY=$grid


#. tntAnalyze.sh $SLURM_ARRAY_TASK_ID $INPUT_SAMPLE