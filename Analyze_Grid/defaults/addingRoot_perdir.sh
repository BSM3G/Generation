#!/bin/bash

cd ${_CONDOR_SCRATCH_DIR}

cd -

source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc6_amd64_gcc530
eval `scramv1 project CMSSW_8_0_10` # equivalent to cmsrel
cd CMSSW_8_0_10/src/
eval `scramv1 runtime -sh`

cd -

string=$(xrdfs root://cmseos.fnal.gov ls /store/user/DUMMY/TEMPDIRECTORY/DIRE/)
set -- $string
if [ ! -z $2 ]
    then
    hadd DIRE.root $(xrdfs root://cmseos.fnal.gov ls -u /store/user/DUMMY/TEMPDIRECTORY/DIRE/)
fi

