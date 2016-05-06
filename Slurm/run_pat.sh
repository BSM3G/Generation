#!/bin/bash

run_num=$1
infilename=
outfilename=miniAOD.${run_num}.root
n_events=$2

cp pat_default_cfg.py logfiles/patc_${run_num}_cfg.py
cd logfiles

sed -i -e s/NUMBER_EVENT/$n_events/g patc_${run_num}_cfg.py
sed -i -e s/INFILE/${filename}/g patc_${run_num}_cfg.py
sed -i -e s/OUTFILE/${outfilename}/g patc_${run_num}_cfg.py

touch patlog.${run_num}.log
cd ..

cmsRun logfiles/patc_${run_num}_cfg.py >> logfiles/patlog.${run_num}.log










