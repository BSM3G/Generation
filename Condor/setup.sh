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

cmsDriver.py Hadronizer_TuneCUETP8M1_13TeV_generic_LHE_pythia8_cff.py \
    --filein file:${CMS_BASE}/events.lhe --fileout OUTFILE -n 271828 \
    --conditions MCRUN2_74_V9 --fast \
    --eventcontent AODSIM -s GEN,SIM,RECOBEFMIX,DIGI,L1,L1Reco,RECO,HLT:@frozen25ns \
    --datatier AODSIM \
    --beamspot NominalCollision2015 \
    --customise SLHCUpgradeSimulations/Configuration/postLS1Customs.customisePostLS1 \
    --magField 38T_PostLS1 \
    --python_filename fastsim_default_cfg.py \
    --no_exec

cmsDriver.py step3  \
    --filein file:INFILE --fileout OUTFILE -n 271828 \
    --conditions MCRUN2_74_V9 --fast -s PAT \
    --eventcontent MINIAODSIM \
    --runUnscheduled  \
    --datatier MINIAODSIM \
    --customise SLHCUpgradeSimulations/Configuration/postLS1Customs.customisePostLS1 --mc \
    --no_exec \
    --python_filename pat_default_cfg.py


sed -i -e s/271828/NUMBER_EVENT/g fastsim_default_cfg.py
sed -i -e s/271828/NUMBER_EVENT/g pat_default_cfg.py
sed -i -e 's/"LHESource",/"LHESource",skipEvents = cms\.untracked\.uint32(SKIPPER),/g' fastsim_default_cfg.py

##########################################
##### CREATING DEFAULT CONDOR FILE #######
##########################################

touch condor_default.cmd

printf "\
Universe   = vanilla
Executable = run_EXECUTING.sh
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

sed -i -e s@WORK_AREA@${CMS_BASE}@g run_fastsim.sh
sed -i -e s/USERNAME/${username}/g run_fastsim.sh

sed -i -e s@WORK_AREA@${CMS_BASE}@g run_pat.sh
sed -i -e s/USERNAME/${username}/g run_pat.sh
