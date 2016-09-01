#!/bin/bash

IFS=$'\n'
for dir in $(cat SAMPLES_LIST.txt)
do
    if [[ ! -z $(echo $dir | grep '^//.*') || ! -z $(echo $dir | grep '^#.*') ]]
    then
	continue
    fi
    
    if [ ! -d $dir ]
    then
	echo "Waiting on $dir"
	echo 
    fi
    
    $(ls -l $dir/*.stderr &> /dev/null)
    
    if [ $? != "0" ] 
    then
	echo "No files in ${dir}!"
	continue
    fi
    
    error=$(ls -l $dir/*.stderr | awk '{if ($5 > 0) exit 1}')
    
    if [ $? -ne 0 ] 
    then
	echo "ERROR: stderr is not 0 length in directory $dir"
	echo "       This means a problem occurred and was recorded in a stderr file"
	continue
    fi

    cd $dir
    list=$(ls condor_out*.stdout)


    echo $dir
    echo
    awk 'BEGIN { 
           area=0; 
           total=0;
           totline=0
         } 
         { 
           if($1 == "TOTAL") { 
              total += $3; 
           } else if($1 == "---------------------------------------------------------------------------" && $0 != "") { 
               area += 1;
               line = 0; 
           } else if(area % 2 == 1) {
               if ( area < 2 ) { 
                  nameArr[line] = $1;
               } else if( nameArr[line] != $1) {
                  print line, nameArr[line];
                  print "ERROR: Mismatched cut names"; 
                  exit 1; 
               }
               if(line >= totline) totline = line+1
               totalArr[line] += $2; 
               cumulArr[line] += $5; 
               line += 1; 
           } 
         }
         END { 
            print "Total Events: ", total; 
            print;

            for( i=0; i < totline; i++) { 
               printf "%30s:  %-10i  %-10i\n", nameArr[i], totalArr[i], cumulArr[i]; 
            }
            print;
         }' $list
    echo
    cd ..
done
