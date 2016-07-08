#!/bin/bash

source /cvmfs/cms.cern.ch/cmsset_default.sh
export slc6_amd64_gcc491
eval $(scramv1 runtime -sh)

for dir in $(ls -d ${CMSSW_BASE}/src/Files/Analysis/WORK_DIRECTORY/*/)
do	    
    rootfiles=$(ls $dir | head -n1)
    if [ ! -z $rootfiles ]
    then
	rm $dir/*
	echo $(basename $dir)
    fi
done

