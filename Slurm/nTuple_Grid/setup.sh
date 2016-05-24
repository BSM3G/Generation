#!/bin/bash

source /cvmfs/cms.cern.ch/cmsset_default.sh
export slc6_amd64_gcc491
eval `scramv1 runtime -sh`

echo "Please type Username"
read username

WORK_AREA=$(pwd)

##########################################
######## CREATING CONFIG FILES ###########
##########################################

PS3="choice: "
aodfile=''
echo
echo "Pick a file to run with"
select filename in $(ls ${CMSSW_BASE}/src/NtupleMaker/BSM3G_TNT_Maker/python/miniAOD*py | xargs -n 1 basename)
do
    if [ -z $filename ] 
    then
	echo "Not valid choice, enter valid number"
    else
	aodfile=$filename
	break
    fi
    
done

cp ${CMSSW_BASE}/src/NtupleMaker/BSM3G_TNT_Maker/python/${aodfile} tnt_default_cfg.py


sed -i -e s/500/NUMBER_EVENT/g tnt_default_cfg.py
sed -i -e s@/store/.*.root@file:INFILE@g tnt_default_cfg.py
sed -i -e s/OutTree.root/OUTFILE/g tnt_default_cfg.py


##########################################
##### CREATING DEFAULT CONDOR FILE #######
##########################################

mkdir logfiles

############################################
############# FIXING RUN FILES #############
############################################

sed -i -e s@WORK_AREA@${WORK_AREA}@g run_ntuple.sh
sed -i -e s/USERNAME/${username}/g run_ntuple.sh


