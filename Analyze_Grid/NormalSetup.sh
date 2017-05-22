#!/bin/bash

PS3="Your choice:  "
source /cvmfs/cms.cern.ch/cmsset_default.sh
export slc6_amd64_gcc491
eval `scramv1 runtime -sh`

if [ $(ls list_Samples | wc -w) -eq 0 ]
then
    ./get_files.sh
fi

get_Analyzer_dir() {

    PS3="Your choice "

    pos=$(pwd -P)"/"
    pos_list=""
    final=""

    while [ $pos != "/" ]
    do
	if [ ! -z $(ls $pos | grep '^Analyzer$') ]
	then
	    pos_list="$pos_list $pos"
	fi
	
	pos=$(echo $pos | sed -nr 's|^(.*)/.+/$|\1/|p')
    done

    if [ $(echo $pos_list | wc -w) -eq 1 ]
    then
	echo $pos_list
	return
    fi

    select item in $pos_list
    do
    if [ -z $item ] 
    then
	echo "Not valid choice, enter valid number"
    else 
	final=$item
	break
    fi
    done

    echo $final
}

echo
printf  "Hello. What is your username?"
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

if [ $(grep USER_NAME master.sh | wc -l) -ne 0 ] 
then 
    sed -i -e s/USER_NAME/$varname/g master.sh
fi

fl1=""
for files in $(ls /eos/uscms/store/user/$varname/)
do
    diff <(ls list_Samples | xargs -n1 basename | sed 's/.txt//g') <(ls /eos/uscms/store/user/$varname/$files) &>/dev/null
    if [ $? -eq 0 ]
    then
	fl1="$fl1 $files"
    fi
done

echo  "What is the name of your eos analysis directory? Below are your options (enter number)"

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

        mkdir /eos/uscms/store/user/$varname/$dirname
        for file in $(ls ./list_Samples)
        do
            file=${file/.txt/}
            mkdir /eos/uscms/store/user/$varname/$dirname/$file
        done
	echo Your eos analysis directories have been created
	break
	
    else
	dirname=$filename
	break
    fi
done

echo

echo "Which analyzer do you want to use?"
analyzer_dir=$(get_Analyzer_dir)

echo 
printf  "We will now setup the analyses scripts needed to submit jobs to CONDOR. Which analysis configuration do you want to use from the options below? (Default is uses the Config files already set up)"
printf "\n"

fl2=$(ls -p $analyzer_dir/Analyzer/Analyses/ | grep / )

select analyzename in $fl2 "Default"
do 
    if [ -z $analyzename ]
    then
	echo "Not valid choice, enter valid number"
    elif [ $analyzename != "Default" ]
    then
	cp $analyzer_dir/Analyzer/Analyses/$analyzename/* $analyzer_dir/Analyzer/PartDet/
	break
    else
	break
    fi
done

echo

location=$(pwd -P)

sed -e s/DUMMY/"$varname"/g -e "s/TEMPDIRECTORY/$dirname/g" -e "s@WORK_AREA@$location@g" \
    -e "s@ANALYZERDIR@$analyzer_dir@g" <defaults/tntAnalyze_default.sh >tntAnalyze.sh
chmod 700 tntAnalyze.sh

sed -e "s/DUMMY/$varname/g" -e "s/TEMPDIRECTORY/$dirname/g" \
    <defaults/deleteEOSAnalysisRootFiles_default.sh >deleteEOSAnalysisRootFiles.sh
chmod 700 deleteEOSAnalysisRootFiles.sh

sed -e "s/DUMMY/$varname/g" -e "s/TEMPDIRECTORY/$dirname/g" \
    <defaults/addingRoot.sh >addingRoot.sh
chmod 700 addingRoot.sh

sed -e "s/EOS_DIR/$varname\/$dirname/g" < defaults/run_adding_default.sh >run_adding.sh
chmod +x run_adding.sh

sed -e "s/DUMMY/$varname/g" -e "s/TEMPDIRECTORY/$dirname/g" \
    <defaults/addingRoot_recursive_default.sh >addingRoot_recursive.sh
chmod +x addingRoot_recursive.sh

echo
echo The analysis scripts have been configured.
