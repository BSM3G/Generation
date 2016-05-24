#!/bin/bash

run_num=$1
infilename=${CMSSW_BASE}/src/Files/miniAOD/miniAOD.${run_num}.root
outfilename=${CMSSW_BASE}/src/Files/TNT/tnt.${run_num}.root
n_events=$2

if [ ! -f $infilename ] 
then
    echo "$infilename not found in AODSIM/"
    exit
fi

echo $run_num
echo $infilename
echo $outfilename
echo $n_events

cp tnt_default_cfg.py logfiles/tnt_${run_num}_cfg.py
cd logfiles

sed -i -e s/NUMBER_EVENT/$n_events/g tnt_${run_num}_cfg.py
sed -i -e s@INFILE@${infilename}@g tnt_${run_num}_cfg.py
sed -i -e s@OUTFILE@${outfilename}@g tnt_${run_num}_cfg.py

touch log.${run_num}.log
cd ..

cmsRun logfiles/tnt_${run_num}_cfg.py >> logfiles/log.${run_num}.log















