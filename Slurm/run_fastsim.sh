#!/bin/bash

run_num=$1
filename=AODSIM.${run_num}.root
n_events=$2
start=$[$n_events*$run_num]

cp fastsim_default_cfg.py logfiles/fastsimc_${run_num}_cfg.py
cd logfiles

sed -i -e s/NUMBER_EVENT/$n_events/g fastsimc_${run_num}_cfg.py
sed -i -e s/OUTFILE/${filename}/g fastsimc_${run_num}_cfg.py
sed -i -e s/SKIPPER/${start}/g fastsim_cfg.py

touch log.${run_num}.log
cd ..

cmsRun logfiles/fastsimc_${run_num}_cfg.py >> logfiles/log.${run_num}.log










