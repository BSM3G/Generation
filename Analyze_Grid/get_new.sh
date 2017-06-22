#!/bin/bash

start=$(pwd -P)
store='store/user/ra2tau/jan2017tuple'
output_dir='new_list'
cd /eos/uscms

for first in $(find $store -maxdepth 1 -type d)
do
   outname=$(echo $first | sed -rn "s|^"${store}"/(.+)$|\1|p")
   echo $outname
   find $first -maxdepth 4 -mindepth 4 -type f -name OutTree*root -printf "%s root://cmseos.fnal.gov/%p \n" | sort -r > ${start}/${output_dir}/${outname}.txt
   if [ ! -s ${start}/${output_dir}/${outname}.txt ]; then
       echo "$outname not properly formated!"
       rm ${start}/${output_dir}/${outname}.txt
   fi
done
