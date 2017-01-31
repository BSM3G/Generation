#!/bin/bash

for dir in $(xrdfs root://cmseos.fnal.gov/ ls /store/user/DUMMY/TEMPDIRECTORY/ | xargs -n 1 basename)
do	    
    string=$(xrdfs root://cmseos.fnal.gov ls /store/user/DUMMY/TEMPDIRECTORY/$dir/)
    set -- $string
    if [ ! -z $1 ]
    then
	hadd ${dir}.root $(xrdfs root://cmseos.fnal.gov ls -u /store/user/DUMMY/TEMPDIRECTORY/$dir/)
	echo $dir
    fi
done

