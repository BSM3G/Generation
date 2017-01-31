#!/bin/bash

for file in $(ls list_Samples | xargs -n 1 basename)
do	    
    file=${file/.txt/}
    xrdfs root://cmseos.fnal.gov/ mkdir /store/user/DUMMY/TEMPDIRECTORY/$file
done

