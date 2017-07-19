#!/bin/bash

#SBATCH --ntasks=1
#SBATCH --time=0:30:00
#SBATCH --mem=4G
#SBATCH --output=output_%A_%a.out

# INPUT_SAMPLE=$1; shift
# outfilename=Output.${1}.root; shift
iteration=$SLURM_ARRAY_TASK_ID
analyzer_area=ANALYZER_AREA
sample_area=$(pwd | xargs basename)

options=$@
part_det=$(echo ${options[@]} | sed -nr 's|.*-C ([A-Za-z0-9/]+).*|\1|p')
if [ -z "$part_det" ]; then
    part_det="PartDet"
fi

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

export X509_USER_PROXY=${HOME}/.x509up_u${UID}

cd $analyzer_area
date

sed -r -i 's/(ApplyGenWeight\s+)(0|false)/\1true/' $part_det/Run_info.in
if [ ! -z "$(echo $sample_area | grep -e 'Tau\.' -e 'HTMHT\.' -e 'SingleMuon\.' -e 'MET\.' )" ] ; then
    ### data
   sed -r -i -e 's/(isData\s+)(0|false)/\1true/' -e 's/(CalculatePUS[a-z]+\s+)(1|true)/\1false/' $part_det/Run_info.in
else
    sed -r -i -e 's/(isData\s+)(1|true)/\1false/' -e 's/(CalculatePUS[a-z]+\s+)(0|false)/\1true/' $part_det/Run_info.in
fi
$run_script
if [ $? -ne 0 ]; then
    exit 1
fi

date


#. tntAnalyze.sh $SLURM_ARRAY_TASK_ID $INPUT_SAMPLE
