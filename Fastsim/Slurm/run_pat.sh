#!/bin/bash

run_num=$1
infilename=AODSIM/AODSIM.${run_num}.root
outfilename=miniAOD/miniAOD.${run_num}.root
n_events=$2

if [ ! -f $infilename ] 
then
    echo "$infilename not found in AODSIM/"
    exit
fi

cp pat_default_cfg.py logfiles/patc_${run_num}_cfg.py
cd logfiles

sed -i -e s/NUMBER_EVENT/$n_events/g patc_${run_num}_cfg.py
sed -i -e s@INFILE@${infilename}@g patc_${run_num}_cfg.py
sed -i -e s@OUTFILE@${outfilename}@g patc_${run_num}_cfg.py

touch patlog.${run_num}.log
cd ..

cmsRun logfiles/patc_${run_num}_cfg.py >> logfiles/patlog.${run_num}.log










