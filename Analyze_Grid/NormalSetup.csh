#!/bin/bash

command='\e[1m%s\e[0m\n'
PS3="Your choice:  "
source /cvmfs/cms.cern.ch/cmsset_default.sh
export slc6_amd64_gcc491
eval `scramv1 runtime -sh
`
if [ ! -d ${CMSSW_BASE}/src/Files ]
then
    mkdir ${CMSSW_BASE}/src/Files
fi

if [ ! -d ${CMSSW_BASE}/src/Files/Analysis ]
then
    mkdir ${CMSSW_BASE}/src/Files/Analysis
fi

printf $command "What is the name of your eos analysis directory? Below are your options"

temp=$(ls -d ${CMSSW_BASE}/src/Files/Analysis/*/ 2> /dev/null)
is_empty=$?
fl1=""

if [ $is_empty -eq 0 ]
then
    temp_dir=$(ls list_Samples | head -n1)
    top_dir=${temp_dir/.txt/}

    
    for files in $(ls -d ${CMSSW_BASE}/src/Files/Analysis/*/)
    do
	is_workplace=$(ls $files | grep $top_dir)
	if [ ! -z $is_workplace ]
	then
	    final=$(basename $files)
	    fl1="$fl1 $final"
	fi
    done
fi

fl1="$fl1 NEW_FILE"

select filename in $fl1
do 
    if [ -z $filename ]
    then
	echo "Not valid choice, enter valid number"
    elif [ $filename == 'NEW_FILE' ]
    then
	echo -e "\nWhat do you want to name your directory?\n"

	read dirname

	while [ -d ${CMSSW_BASE}/src/Files/Analysis/$dirname/ ]
	do
      	    echo Directory already exists! Please pick a new name
	    read dirname
	done
	

	mkdir ${CMSSW_BASE}/src/Files/Analysis/$dirname/ 
	cp defaults/makeDirectories_default.sh makeDirectories.sh
	sed -i -e s/WORK_DIRECTORY/"$dirname"/g makeDirectories.sh
	./makeDirectories.sh
	rm makeDirectories.sh
	echo Your analysis directories have been created
	break
	
    else
	dirname=$filename
	break
    fi
done

printf "\n"


printf $command "We will now setup the analyses scripts needed to submit jobs to CONDOR. Which analysis configuration do you want to use from the options below?"
printf "\n"

if [ ! -d $CMSSW_BASE/src/Analyzer ]
then
    echo "Need to download Analyzer, Run the command:"
    echo "git clone https://github.com/gurrola/Analyzer"
    exit 1
fi

fl2=$(ls -d $CMSSW_BASE/src/Analyzer/BSM3G_TNT_MainAnalyzer/*/ | xargs -n 1 basename)

select filename in $fl2
do 
    if [ -z $filename ]
    then
	echo "Not valid choice, enter valid number"
    else
	analysisname=$filename
	break
    fi
done

printf "\n"

location=$(pwd -P)

cp defaults/tntAnalyze_default.sh tntAnalyze.sh
sed -i -e s/DUMMY/"$varname"/g tntAnalyze.sh
sed -i -e s/WORK_DIRECTORY/"$dirname"/g tntAnalyze.sh
sed -i -e s/ANALYSISDIRECTORY/"$analysisname"/g tntAnalyze.sh
sed -i -e s@WORK_AREA@"$location"@g tntAnalyze.sh



cp defaults/deleteRootfiles_default.sh deleteRootfiles.sh
sed -i -e s/WORK_DIRECTORY/"$dirname"/g deleteRootfiles.sh

cp defaults/addingRoot.sh .
sed -i -e s/WORK_DIRECTORY/"$dirname"/g addingRoot.sh


printf "\n"
printf $command "Which QCD MC sample do you want to analyze?"
select type in mu em none;
do
    if [ -z $type ]
    then
	echo "Not valid choice, enter valid number"
    else
	whichqcd=$type
	break
    fi
done

cp defaults/SAMPLES_LIST_MC_default.txt SAMPLES_LIST_MC.txt

if [ "$whichqcd" = "mu" ]
then
    sed -i '17,23d' SAMPLES_LIST_MC.txt
elif [ "$whichqcd" = "em" ]
then
    sed -i '16d' SAMPLES_LIST_MC.txt
elif [ "$whichqcd" = "none" ]
then
    sed -i '16,23d' SAMPLES_LIST_MC.txt
fi

printf "\n"
echo The analysis scripts have been configured.
