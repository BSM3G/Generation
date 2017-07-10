#!/bin/bash

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

echo $working_path
cp pyslurm_tmp.py $working_path/pyslurm

rm -rf pyslurm
rm pyslurm_tmp.py