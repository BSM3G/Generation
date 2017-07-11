#!/bin/bash

start=$(pwd -P)
store='/store/user/ra2tau/jan2017tuple'
output_dir='list_Samples'
root_loc="root://cmsxrootd-site2.fnal.gov/"

for first in $(xrdfs $root_loc ls $store 2>/dev/null)
do
    outname=$(echo $first | sed -rn "s|^"${store}"/(.+)$|\1|p")
    echo $outname
    if [ -f $output_dir/$outname.txt ]; then
    	rm $output_dir/$outname.txt
    fi
    touch $output_dir/$outname.txt
    
    temp=( $(xrdfs $root_loc ls -l $first 2>/dev/null | awk '{if($1 == "dr-x") print $5}') )
    if [ -z "$(echo $work_var | grep fail)" ]; then
	xrdfs $root_loc ls -l $first 2>/dev/null | awk '{if($1 == "-r--" && $5 ~ "/root/" ) print $4, $5}' 1>>$output_dir/$outname.txt
    fi

    while [ ${#temp[@]} -ne 0 ]; do
	work_var=${temp[0]}
	if [ -z "$(echo $work_var | grep fail)" ]; then
	    xrdfs $root_loc ls -l $work_var 2>/dev/null | awk '{if($1 == "-r--" && $5 ~ /root/ ) print $4, "root://cmsxrootd.fnal.gov/" $5}' 1>> $output_dir/$outname.txt
	fi
    	unset temp[0]
	temp=( "${temp[@]}" $(xrdfs $root_loc ls -l $work_var 2>/dev/null | awk '{if($1 == "dr-x") print $5}') )
    done
    cat $output_dir/$outname.txt | sort -rg -o $output_dir/$outname.txt
done
