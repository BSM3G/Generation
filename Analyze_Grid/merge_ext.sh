#!/bin/bash

mkdir tmp_dir

for file in $(ls *root)
do

    if [ ! -f $file ] 
    then
	continue
    fi

    tag=$(echo $file | sed -rn -e 's/^(.*)(_|-)(v|V)(1|2|3).*$/\1/p' -e 's/^(.*)_RunII.*$/\1/p' )
    tag=$(echo $tag | sed -r 's/_ext(1|2)?//g')
    if [ -z $tag ] 
    then 
	continue
    fi

    if [ $(ls ${tag}*root | wc -l) -ne 1 ]
    then
	hadd tmp_dir/${tag}.root $(ls ${tag}*root) 
	rm $(ls ${tag}*root)
    else
	mv $file $tag.root
	continue
    fi


done

mv tmp_dir/*root . 2>/dev/null
rm -r tmp_dir
