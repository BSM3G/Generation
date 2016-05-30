#!/bin/bash

######NUMBER OF CORES#####
num_cores=10



if [ ! -f tntAnalyze.sh ]
then 
    echo "Need the TNT Analyze file!!"
    echo "Get a run file from running NormalSetup.csh"
    exit
fi   
 

source /cvmfs/cms.cern.ch/cmsset_default.sh
export slc6_amd64_gcc491
eval `scramv1 runtime -sh`

voms-proxy-info 2> /dev/null
find_proxy=$?

need_init=$(voms-proxy-info | grep "timeleft" | awk 'BEGIN{FS=":"}{if($2==" 0" && $3=="00" && $4=="00"){print "true"} else{print "false"}}')
if [[ $find_proxy != 0 || $need_init == "true" ]]
then
    voms-proxy-init --voms cms
fi


echo
echo We will modify the default analyzer configuration file to run. Which analysis configuration do you want to use from the options below?
echo

base=$CMSSW_BASE/src/Analyzer/BSM3G_TNT_MainAnalyzer/
PS3="Your Choice: "

fl=$(ls -d ${base}/*/ | xargs -n 1 basename)
select filename in $fl
do 
    if [ -z $filename ]
    then
	echo "Not valid choice, enter valid number"
    else
	analysisname=$base$filename
	break
    fi
done

echo
echo Is this analysis being run for MC or for Data?
echo

select filename in Data MC
do 
    if [ -z $filename ]
    then
	echo "Not valid choice, enter valid number"
	continue

    elif [ $REPLY -eq 1 ]
    then
	sed -i '643s/.*/CalculatePUSystematics 0/' ${analysisname}/BSM3GAnalyzer_CutParameters.in
	sed -i '646s/.*/isData 1/' ${analysisname}/BSM3GAnalyzer_CutParameters.in
	
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
	sed -i '643s/.*/CalculatePUSystematics 1/' ${analysisname}/BSM3GAnalyzer_CutParameters.in
	sed -i '646s/.*/isData 0/' ${analysisname}/BSM3GAnalyzer_CutParameters.in

	cp SAMPLES_LIST_MC.txt SAMPLES_LIST.txt
    fi

    break
done

position=$(pwd -P)

for inputList in $(cat SAMPLES_LIST.txt)
do
    echo $inputList
    if [ ! -d $inputList ] 
    then
	mkdir $inputList
    fi
    tmp=( $(wc list_Samples/${inputList}.txt) )
    n_proc=${tmp[1]}

    cp slurm_default.slurm ${inputList}/run_slurm.slurm
    cp tntAnalyze.sh $inputList

    cd ${inputList}

    sed -i -e s/NUM_CORES/$num_cores/g run_slurm.slurm
    sed -i -e s@POSITION@$position@g run_slurm.slurm
    sed -i -e s/INPUT_SAMPLE/${inputList}/g run_slurm.slurm
    sed -i -e s/START_NUM/1/g run_slurm.slurm
    sed -i -e s/END_NUM/${n_proc}/g run_slurm.slurm
    
    sbatch run_slurm.slurm
    cd ..
done

