#!/bin/bash

#####################
##### Variables #####
#####################

runfile=addingRoot_perdir.sh
#####################
#####################

if [ ! -f $runfile ]
then 
    echo "Need the addingRoot per directory script!!"
    echo "Get a run file from running NormalSetup.csh"
    exit
fi 

source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc6_amd64_gcc491
eval `scramv1 runtime -sh`

mkdir Merging_Results
cd Merging_Results

for dir in $(xrdfs root://cmseos.fnal.gov/ ls /store/user/DUMMY/TEMPDIRECTORY/ | xargs -n 1 basename)
do
    cp ../defaults/condor_default_add.cmd run_condor_add_${dir}.cmd
    cp ../addingRoot_perdir.sh addingRoot_perdir_${dir}.sh
    sed -i -- "s/DIRE/$dir/g" addingRoot_perdir_${dir}.sh
    sed -i -- "s/EXEC/addingRoot_perdir_${dir}.sh/g" run_condor_add_${dir}.cmd
    condor_submit run_condor_add_${dir}.cmd
done
