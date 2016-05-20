#!/bin/bash

command='\e[1m%s\e[0m\n'
PS3="Your choice:  "
source /cvmfs/cms.cern.ch/cmsset_default.sh
export slc6_amd64_gcc491
eval `scramv1 runtime -sh
`

echo
printf $command "Hello. What is your username?"
echo

read varname

echo

while [ true ] 
do
    string=$(xrdfs root://cmseos.fnal.gov/ ls /store/user/$varname/)
    if [ $? -eq 0 ]
    then
	break
    fi
    echo Not valid Username, try again!
    read varname
done

printf $command "What is the name of your eos analysis directory? Below are your options"

temp_dir=$(ls list_Samples | head -n1)
top_dir=${temp_dir/.txt/}

fl1=""
for files in $(ls -d /eos/uscms/store/user/$varname/*/ | xargs -n 1 basename)
do
    for files2 in $(xrdfs root://cmseos.fnal.gov/ ls /store/user/$varname/$files)
    do
	tmp=""
	if [ ! -z $files2 ]
	then
	    tmp=$(basename $files2)
	fi
	if [ $tmp == $top_dir ]
	then
	    fl1="$fl1 $files"
	fi
    done
done

echo

select filename in $fl1 NEW_FILE
do 
    if [ -z $filename ]
    then
	echo "Not valid choice, enter valid number"
    elif [ $filename == 'NEW_FILE' ]
    then
	echo -e "\nWhat do you want to name your directory?\n"

	read dirname

	while [  -d "/eos/uscms/store/user/$varname/$dirname" ]
	do
      	    echo Directory already exists! Please pick a new name
	    read dirname
	done

	xrdfs root://cmseos.fnal.gov/ mkdir /store/user/$varname/$dirname
	cp defaults/makeEOSdirectories_default.csh makeEOSdirectories.csh
	sed -i -e s/DUMMY/"$varname"/g makeEOSdirectories.csh
	sed -i -e s/TEMPDIRECTORY/"$dirname"/g makeEOSdirectories.csh
	./makeEOSdirectories.csh
	rm makeEOSdirectories.csh
	echo Your eos analysis directories have been created
	break
	
    else
	dirname=$filename
	break
    fi
done

printf "\n"


printf $command "We will now setup the analyses scripts needed to submit jobs to CONDOR. Which analysis configuration do you want to use from the options below?"
printf "\n"

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
sed -i -e s/TEMPDIRECTORY/"$dirname"/g tntAnalyze.sh
sed -i -e s/ANALYSISDIRECTORY/"$analysisname"/g tntAnalyze.sh
sed -i -e s@WORK_AREA@"$location"@g tntAnalyze.sh



cp defaults/deleteEOSAnalysisRootFiles_default.csh deleteEOSAnalysisRootFiles.csh
sed -i -e s/DUMMY/"$varname"/g deleteEOSAnalysisRootFiles.csh
sed -i -e s/TEMPDIRECTORY/"$dirname"/g deleteEOSAnalysisRootFiles.csh

cp defaults/addingRoot.sh .
sed -i -e s/DUMMY/"$varname"/g addingRoot.sh
sed -i -e s/TEMPDIRECTORY/"$dirname"/g addingRoot.sh


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
