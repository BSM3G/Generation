#!/bin/bash

#####################
##### Variables #####
#####################

limit=200
runfile=tntAnalyze.sh
#####################
#####################


if [ $limit -le 0 ] 
then
    echo "Limit too small (limit <= 0)"
    exit 1
fi

if [ ! -f $runfile ]
then 
    echo "Need the TNT Analyze file!!"
    echo "Get a run file from running NormalSetup.csh"
    exit
fi   

source /cvmfs/cms.cern.ch/cmsset_default.sh
export slc6_amd64_gcc491
eval `scramv1 runtime -sh`

if [ ! -f $CMSSW_BASE/src/Analyzer/Analyzer ] 
then
    cd $CMSSW_BASE/src/Analyzer/Analyzer
    echo "Making Analyzer:"
    make Analyzer
    cd -
fi

echo "Do you want to delete the old files? (y or n)"
read -t 5 answer

if [ -z $answer ]
then
    answer="y"
fi

if [ ${answer:0:1} == "y" ] 
then
    ./deleteLocalLogFileDirectories.csh
    ./deleteEOSAnalysisRootFiles.csh
fi
 
touch kill_process.sh
echo "/usr/sbin/lsof | grep -e 'USER_NAME.*master.sh' | awk '{print \$2}' | xargs kill" > kill_process.sh 
echo "condor_rm USER_NAME" >> kill_process.sh

IFS=$'\n'
for inputList in $(cat SAMPLES_LIST.txt)
do
    if [[ ! -z $(echo $inputList | grep '^//.*') || ! -z $(echo $inputList | grep '^#.*') ]]
    then
	continue
    fi

    echo $inputList

        if [ ! -d $inputList ] 
    then
    	mkdir $inputList
    fi
    total=$(cat list_Samples/${inputList}.txt | wc -l)
    left=$total
    start=0
    cp condor_default.cmd ${inputList}/run_condor.cmd
    cp tntAnalyze.sh $inputList

    cd ${inputList}
    while [ $left -gt 0 ] 
    do
    	running=$(condor_q USER_NAME | grep $runfile | wc -l)
    	if [ $running -ge $limit ]
    	then
    	    sleep 1m
    	else
    	    send=$[$limit-$running]

    	    if [ $left -lt $send ] 
    	    then
    		send=$left
    	    fi
    	    left=$[$left-$send]
    	    condor_submit -append "args = \$(Process) $start $inputList"  run_condor.cmd -queue $send
    	    start=$[$start+$send]
    	fi
    done
    cd ..
done

rm kill_process.sh






