#!/bin/bash

source /cvmfs/cms.cern.ch/cmsset_default.sh
export slc6_amd64_gcc491
eval `scramv1 runtime -sh`

CMS_BASE=$(pwd)

echo "Please type Username"
read username

##########################################
######## CREATING CONFIG FILES ###########
##########################################

aodfile=''
echo
echo "Pick a file to run with"
select name in $(ls ${CMS_BASE}/NtupleMaker/BSM3G_TNT_Maker/python/miniAOD*)
do
    if [ -z $filename ] 
    then
	echo "Not valid choice, enter valid number"
    else
	aodfile=$filename
	break
    fi
    
done

cp ${CMS_BASE}/NtupleMaker/BSM3G_TNT_Maker/python/${aodfile} tnt_default_cfg.py


sed -i -e s/271828/NUMBER_EVENT/g tnt_default_cfg.py
sed -i -e s/271828/NUMBER_EVENT/g tnt_default_cfg.py


##########################################
##### CREATING DEFAULT CONDOR FILE #######
##########################################

mkdir logfile

############################################
############# FIXING RUN FILES #############
############################################

sed -i -e s@WORK_AREA@${CMS_BASE}@g run_ntuple.sh
sed -i -e s/USERNAME/${username}/g run_ntuple.sh


