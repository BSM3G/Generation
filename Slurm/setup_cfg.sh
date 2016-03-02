#!/bin/bash

config_frag="Hadronizer_TuneCUETP8M1_13TeV_generic_LHE_pythia8_cff.py"

source /cvmfs/cms.cern.ch/cmsset_default.sh
export slc6_amd64_gcc491
eval `scramv1 runtime -sh`

if [ -f $config_frag ]
then
    POSITION=$(pwd)
else
    echo "cff file isn't available.  Make sure it is in your src directory"
fi

sed -i -e s/POSITION/$POSITION/g slurm_default.slurm
sed -i -e s/POSITION/$POSITION/g master.sh

    cmsDriver.py $POSITION/Hadronizer_TuneCUETP8M1_13TeV_generic_LHE_pythia8_cff.py  --filein file:$POSITION/events.lhe --fileout OUTFILE --conditions MCRUN2_74_V9 --fast  -n NUMBER_EVENT --eventcontent AODSIM -s GEN,SIM,RECOBEFMIX,DIGI,L1,L1Reco,RECO,HLT:@frozen25ns --datatier AODSIM --beamspot NominalCollision2015 --customise SLHCUpgradeSimulations/Configuration/postLS1Customs.customisePostLS1 --magField 38T_PostLS1 --python_filename fastsim_default_cfg.py --no_exec

cmsDriver.py step3  --conditions MCRUN2_74_V9 --fast  -n NUMBER_EVENT --eventcontent MINIAODSIM --runUnscheduled  --filein file:INFILE -s PAT --datatier MINIAODSIM --customise SLHCUpgradeSimulations/Configuration/postLS1Customs.customisePostLS1 --mc --no_exec --fileout OUTFILE --python_filename pat_default_cfg.py
