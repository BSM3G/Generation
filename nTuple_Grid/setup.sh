#!/bin/bash

source /cvmfs/cms.cern.ch/cmsset_default.sh
export slc6_amd64_gcc491
eval `scramv1 runtime -sh`

echo
echo "Please type Username"
read username

##########################################
######## CREATING CONFIG FILES ###########
##########################################

aodfile=''
echo
echo "Pick a file to run with"
select name in $(ls ${CMSSW_BASE}/src/NtupleMaker/BSM3G_TNT_Maker/python/miniAOD*py | xargs -n1 basename)
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

touch condor_default.cmd

printf "\
Universe   = vanilla
Executable = run_ntuple.sh
Log        = EXECUTING.log
Output     = EXECUTING.\$(Process).out
Error      = EXECUTING.\$(Process).error
Initialdir = logfiles

Arguments  = \$(Process) START EVENTS_PROCESSED
Queue NUMBER_QUEUED\n" >> condor_default.cmd

#############################################
############ CREATING EOS AREAS #############
#############################################

Generate_exist=false

for dir in $(xrdfs root://cmseos.fnal.gov/ ls /store/user/${username}/)
do
    newdir=$(basename $dir)
    if [ "Generate" = $newdir ] 
    then
	Generate_exist=true
    fi
done

if [ $Generate_exist = "false" ] 
then
    xrdfs root://cmseos.fnal.gov/ mkdir /store/user/${username}/Generate
fi

AOD_exist=false
miniAOD_exist=false
nTuple_exist=false

for dir in $(xrdfs root://cmseos.fnal.gov/ ls /store/user/${username}/Generate)
do
    newdir=$(basename $dir)
    if [ $newdir = "AODSIM" ] 
    then
	AOD_exist=true
    fi
    if [ $newdir = "miniAOD" ] 
    then
	miniAOD_exist=true
    fi
    if [ $newdir = "TNT" ] 
    then
	nTuple_exist=true
    fi
done

if [ AOD_exist = "false" ] 
then
    xrdfs root://cmseos.fnal.gov/ mkdir /store/user/${username}/Generate/AODSIM/
fi

if [ miniAOD_exist = "false" ] 
then
    xrdfs root://cmseos.fnal.gov/ mkdir /store/user/${username}/Generate/miniAOD/
fi

if [ nTuple_exist = "false" ] 
then
    xrdfs root://cmseos.fnal.gov/ mkdir /store/user/${username}/Generate/TNT/
fi
    
mkdir logfile

############################################
############# FIXING RUN FILES #############
############################################

sed -i -e s@WORK_AREA@${CMS_BASE}@g run_ntuple.sh
sed -i -e s/USERNAME/${username}/g run_ntuple.sh
