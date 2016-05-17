#!/bin/bash

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




