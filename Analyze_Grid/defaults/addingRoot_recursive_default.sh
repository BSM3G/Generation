#!/bin/bash

magicNumber=64

sample_arr=()
num_arr=()
it=0

prev_name=""
prev_num=0
prev_list=""

work_area=$(pwd -P)

start_testfunc() {
    total=$1
    divide=$2
    sample=$3
    work_dir=$(pwd -P)


    tmp=1
    max_level=0
    while [ $tmp -lt $total ]
    do
	max_level=$[max_level+1]
	tmp=$[tmp*divide]
    done

    end=$total
    level=$max_level
    while [ $end -gt 1 ]
    do
	queue=$[(end-1)/$divide+1]
	tmp_divide=$[(end-1)/$queue+1]
	i=0

	condor_submit ../condor_recursive.cmd -append "args = \$(Process) $tmp_divide $level $end $max_level $work_dir $sample" -queue $queue



	echo "sent $queue events at $level level with $end as end"
	end=$queue
	level=$[level-1]
    done

}

setup_event() {
    
    sample_arr[it]=$1
    num_arr[it]=$it
    it=$[it+1]
    echo $1
    mkdir ${1}_adding 2>/dev/null
    cd ${1}_adding

}

IFS=$'\n'
for inputList in $(cat $work_area/SAMPLES_LIST.txt)
do
    if [[ ! -z $(echo $inputList | grep '^//.*') || ! -z $(echo $inputList | grep '^#.*') ]]
    then
	continue
    fi
    
    isData=$(echo $inputList | sed -rn 's/^(.+)_Run201.*$/\1/gp')    
    num=$(xrdfs root://cmseos.fnal.gov/ ls /store/user/DUMMY/TEMPDIRECTORY/$inputList | grep root | wc -l)

    if [ -z $isData ] 
    then
	setup_event $inputList
	start_testfunc $num $magicNumber ${inputList}
    else
	if [[ ! -z $prev_name ]] && [[ $prev_name != $isData ]]
	then
	    setup_event $prev_name
	    start_testfunc $prev_num $magicNumber ${prev_list}
	    prev_name=""
	    prev_num=0
	    prev_list=""
	else
	    prev_name=$isData
	fi
	prev_num=$[prev_num+num]
	prev_list="$prev_list$inputList|"
    fi
    
    cd $work_area

done

if [ ! -z $prev_name ]
then
    setup_event $prev_name
    start_testfunc $prev_num $magicNumber ${prev_list}
    cd $work_area
fi

sleep 5s

while [ ${#num_arr[*]} -ne 0 ]
do
    for arrit in ${num_arr[*]}
    do
	samp=${sample_arr[$arrit]}
	name=${sample_arr[$arrit]}_adding

	
	ls_list=$(ls $name/*stdout 2>/dev/null)
	if [ $(echo $ls_list | wc -w) -ne 0 ]
	then

    	    for stdout in $ls_list
    	    do
    		stderr=${stdout/stdout/stderr}
    		if [ -s $stdout ] 
    		then
    		    if [ -s $stderr ] 
    		    then
    		    	echo ERROR in $stderr, will try to rerun
			cat $stdout
    		    	# newvariables=$(cat $stdout)
    		    	# condor_submit test_recursive.cmd -append "args = $newvariables" -queue 1
    		    else
    		    	cat $stdout | xargs rm 2>/dev/null
    		    	rm $stderr
    		    fi
    		    rm $stdout
    		fi
	    done
	else
	    echo ${name} is done
	    cp  ${name}/0_0.root $samp.root
	    unset -v "num_arr[$arrit]"
	    rm -r ${name}
	fi
    done
    sleep 1s
done

