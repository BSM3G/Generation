#!/bin/bash

start='/uscms_data/d3/dteague/CMSSW_8_0_10/src/Dev/Generation/Analyze_Grid/new_list'
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
	ls $store/$first/$name/*/*/OutTree*root | awk '{print "root://cmseos.fnal.gov//"$0}' > $start/$name.txt
    done
#    ls store/user/ra2tau/jan2017tuple/$name/*/*/*/OutTree*root
    
done
