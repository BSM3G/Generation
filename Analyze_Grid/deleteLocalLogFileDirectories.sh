#!/bin/bash

for y in `ls -p |  grep /`
do
    
    new_file=${y/\//}
    if [ -z $(ls list_Samples | grep $new_file) ]
    then
	continue
    fi
    echo Deleting the following directory: ${new_file}

    rm -rf ${new_file}

done

