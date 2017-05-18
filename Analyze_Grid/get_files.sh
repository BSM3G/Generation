#!/bin/bash

start=$(pwd -P)
store='store/user/ra2tau/jan2017tuple'
cd /eos/uscms

for first in $(ls $store)
do
    for name in $(ls $store/$first)
    do
	if [ ! -d $store/$first/$name ]
	then
	    continue
	fi
	echo $name
	ls $store/$first/$name/*/*/OutTree*root &>/dev/null
	if [ $? -ne 0 ]
	then
	  echo "Can't find output files in this directory"
	  continue
	fi
	
	generator=$(echo $first | sed -rn 's/^.*_13TeV(-|_)(.*)$/-\2/p')

	ls $store/$first/$name/*/*/OutTree*root | awk '{print "root://cmseos.fnal.gov//"$0}' > $start/list_Samples/$name$generator.txt
    done
    
done
