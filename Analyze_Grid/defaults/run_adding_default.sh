#!/bin/bash


process=$1
divy=$2
level=$3
full_end=$4
max=$5
work_dir=$6
sample_list=$7

eos=/store/user/EOS_DIR
ntimes=1
while [ ! -d $work_dir ]
do
    sleep 5s
    work_dir=${work_dir/\/d?\//\/d${ntimes}\/}

    if [ $ntimes -gt 5 ]
    then
	cd $work_dir
	echo $@
	exit 1
    fi
    ntimes=$[ntimes+1]
done

cd $work_dir
source /cvmfs/cms.cern.ch/cmsset_default.sh
export slc6_amd64_gcc530
eval `scramv1 runtime -sh`


start=$[process*divy]
end=$[start + divy]
if [ $end -gt $full_end ]
then
    end=$full_end
fi


check_loop() {
    missing_file=false

    tmp_list=""
    for file in ${filearray[*]}
    do
#	if [ -z $(ls ${level}_$file.root 2>/dev/null) ] 
	if [ ! -e ${level}_$file.root ] 
	then
	    tmp_list="$tmp_list $file"
	fi
    done
    unset filearray
    filearray=($tmp_list)

    return 
}


list=""
if [ $level -eq $max ]
then
    full_list=""
    IFS=$'|'
    for sample in $sample_list
    do
	full_list="$full_list $(xrdfs root://cmseos.fnal.gov/ ls -u $eos/$sample)"
    done
    IFS=$' '
    list=$(echo $full_list | sed -n "$[start+1],${end}p" | xargs)
    echo " "
else 


    i=$start
    tmp_list=""

    while [ $i -lt $end ]
    do
	list="$list $work_dir/${level}_$i.root"
	if [ ! -e "${level}_$i.root" ] 
	then
	    tmp_list="$tmp_list $i"
	fi
	i=$[i+1]
    done
    filearray=($tmp_list)

    max_loops=300
    loops=0
    while [ ${#filearray[@]} -ne 0 ] 
    do
    	sleep 1s
    	check_loop
	loops=$[loops+1]
	if [ $loops -gt $max_loops ]
	then
	    echo "Can't find files!" >2
	    exit 1
	fi
    done
    
    echo $list
fi

cd ${_CONDOR_SCRATCH_DIR}
hadd $[level-1]_$process.root $list 1>/dev/null


