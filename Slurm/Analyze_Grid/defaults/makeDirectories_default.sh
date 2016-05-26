#!/bin/bash

for file in $(ls ./list_Samples | xargs -n 1 basename)
do	    
    file=${file/.txt/}
    mkdir ${CMSSW_BASE}/src/Files/Analysis/WORK_DIRECTORY/$file
done



