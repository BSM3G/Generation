#!/bin/bash/

for dir in $(ls -d ./*Asympt25ns/)
do
    first=0
    echo $dir
    cd $dir
    for file in $(ls *stderr)
    do 
	tmp=${file/condor_out_0_/}
	tmp=${tmp/.stderr/}
	
	if [ $first -eq 0 ]
	then
	    first=$tmp
	fi
	run=$(ll $file | awk '{if ($5 > 0) print 0; else print 1;}')
	
	if [ $run -eq 0 ] 
	then
	    num=$[$tmp - $first + 1 ]
	    rm $file
	    condor_submit submit_${num}.cmd
	fi
    done
    cd ..
done
