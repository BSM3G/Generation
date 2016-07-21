#!/bin/bash

if [ ! -f tntAnalyze.sh ]
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


for inputList in $(cat SAMPLES_LIST.txt)
do
    echo $inputList
    if [ ! -d $inputList ] 
    then
	mkdir $inputList
    fi
    tmp=( $(wc list_Samples/${inputList}.txt) )
    n_proc=${tmp[1]}

    cp condor_default.cmd ${inputList}/run_condor.cmd
    cp tntAnalyze.sh $inputList

    cd ${inputList}
    sed -i -e s/INPUT_SAMPLE/${inputList}/g run_condor.cmd
    sed -i -e s/NUMBER_QUEUED/${n_proc}/g run_condor.cmd
    
    condor_submit run_condor.cmd
    cd ..
done





