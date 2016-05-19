#!/bin/bash

for y in `ls -p -I defaults -I list_Samples | grep /`
do

    new_file=${y/\//}
    echo Deleting the following directory: ${new_file}

    rm -rf ${new_file}

done

