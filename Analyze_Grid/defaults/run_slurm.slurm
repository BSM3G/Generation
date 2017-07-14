#!/bin/bash

#SBATCH --ntasks=1
#SBATCH --time=1:00:00
#SBATCH --mem=4G
#SBATCH --output=output_%A_%a.out

# INPUT_SAMPLE=$1; shift
# outfilename=Output.${1}.root; shift
iteration=$SLURM_ARRAY_TASK_ID
analyzer_area=ANALYZER_AREA

options=$@

in_files=$(cat bins.txt | awk -F '|' -v line="$iteration" '{print $line}')
out_file="${PWD}/Output.${iteration}.root"

echo "SLURM_JOBID: " $SLURM_JOBID
echo "SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_TASK_ID
echo "SLURM_ARRAY_JOB_ID: " $SLURM_ARRAY_JOB_ID

source /cvmfs/cms.cern.ch/cmsset_default.sh
export slc6_amd64_gcc530
eval `scramv1 runtime -sh`


run_script="./Analyzer -out $out_file -in $in_files"
if [ ! -z "${options[@]}" ]; then 
    run_script="$run_script ${options[@]}"
fi

export X509_USER_PROXY=${HOME}/x509up_u${UID}

cd $analyzer_area
date
$run_script
date


#. tntAnalyze.sh $SLURM_ARRAY_TASK_ID $INPUT_SAMPLE
