#!/bin/bash

#####################
##### Variables #####
#####################

limit=200 # Make it an increment of 100
stepsize=100   #Size of each packet of jobs to be sent
runfile=tntAnalyze.sh
#####################
#####################


limit=$[$limit/$stepsize*$stepsize]  ### makes limit a multiple of stepsize
if [ $limit -lt 0 ] 
then
    echo "Limit too small (limit < $stepsize)"
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
    echo "Making Analyzer:"
    make Analyzer
fi
 


need_init=$(voms-proxy-info | grep "timeleft" | awk 'BEGIN{FS=":"}{if($2==" 0" && $3=="00" && $4=="00"){print "true"} else{print "false"}}')
if [ $need_init == "true" ]
then
    voms-proxy-init --voms cms
fi

PS3="Your Choice: "

echo
echo Is this analysis being run for MC or for Data?
echo

runfile=$CMSSW_BASE/src/Analyzer/PartDet/Run_info.in

isData=$(awk '/isData/{ print NR; exit }' $runfile)
CalcPU=$(awk '/CalculatePUSystematics/{ print NR; exit }' $runfile)

select filename in Data MC
do 
    if [ -z $filename ]
    then
	echo "Not valid choice, enter valid number"
	continue

    elif [ $REPLY -eq 1 ]
    then
	sed -i "${isData}s/\(0\|false\)/true/" $runfile
	sed -i "${CalcPU}s/\(1\|true\)/false/" $runfile
	
	list=$(ls defaults/SAMPLES_LIST_data*)

	echo 
	echo Pick which data set you would like to use:
	echo
	select sample in ${list//defaults\/SAMPLES_LIST_data/data}
	do
	    if [ -z $sample ]
	    then
		echo "Not valid choice, enter valid number"
	    else
		cp defaults/SAMPLES_LIST_$sample SAMPLES_LIST.txt
		break
	    fi
	done

    elif [ $REPLY -eq 2 ]
    then
	sed -i "${CalcPU}s/\(0\|false\)/true/" $runfile
	sed -i "${isData}s/\(1\|true\)/false/" $runfile

	cp SAMPLES_LIST_MC.txt SAMPLES_LIST.txt
    fi

    break
done


touch kill_process.sh
echo "/usr/sbin/lsof | grep -e 'USER_NAME.*master.sh' | awk '{print \$2}' | xargs kill" > kill_process.sh 
echo "condor_rm USER_NAME" >> kill_process.sh

for inputList in $(cat SAMPLES_LIST.txt)
do
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
	    send=$stepsize
	    if [ $[$limit-$running] -lt $stepsize ] 
	    then
		send=$[$limit-$running]
	    fi
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






