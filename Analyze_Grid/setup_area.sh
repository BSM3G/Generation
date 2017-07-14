#!/bin/bash

PS3="Your choice:  "
source /cvmfs/cms.cern.ch/cmsset_default.sh
export slc6_amd64_gcc491
eval `scramv1 runtime -sh`

###### variables needed
username=$(whoami)
list_area="new_list"
eos_area="/cms/store/user/"
analyzer_area=""
analyze_grid=$PWD

## Setup rootfiles to run over
if [ -z "$(find . -type d -name $list_area)" ]; then
    ./get_files.sh
fi

# # check if can run over eos area
# if [ ! -d $eos_area$username ]; then
#     echo "Can't find your EOS area, consider getting one or changing code to put output files in (adequately sized) file area"
#     exit 1
# fi


#### get analyzer area
analyzer_list=$(find $CMSSW_BASE -type d -name Analyzer | sed -n "s|$CMSSW_BASE||pg")
n_analyzer_list=$(echo $analyzer_list | wc -w)
if [ $n_analyzer_list -eq 0 ]; then
    echo "No Analyzer in your CMSSW area, move code there or specify in code"
elif [ $n_analyzer_list -eq 1 ]; then
    analyzer_area=$analyzer_list
else
    echo
    echo "Please select a number corresponding to the Analyzer you wish to use:"
    select tmp_area in $analyzer_list; do 
        if [ -z "$tmp_area" ]; then
	    echo "Not a valid number"
	else
	    analyzer_area=$tmp_area
	    break
	fi
    done
fi

##### download pyslurm stuff
git clone https://github.com/PySlurm/pyslurm
cd pyslurm
tmp_slurm=$(which sbatch)
slurm=$(echo $tmp_slurm | sed -rn 's|(.*slurm).*|\1|gp')
python setup.py build --slurm=$slurm
python setup.py install --user

IFS=':'
working_path=''
for path in $PYTHONPATH; do
    if [ -d $path/pyslurm ]; then
	working_path=$path
	break
    fi
done

cd $analyze_grid
cp defaults/pyslurm_tmp.py $working_path/pyslurm

rm -rf pyslurm
rm pyslurm_tmp.py

###### move default files to main directory
sed -e 's@ANALYZER_AREA@'"$analyzer_area"'@g' < default/run_slurm.slurm >run_slurm.slurm
