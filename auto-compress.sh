#!/bin/bash

check_last_access()
{
x=$1
output="in_danger"


  access_date=$(stat --printf=%X $x )
  current_date=$(date +"%s")
  check_sum=$((30 * 24 * 60 * 60))
  if [ $(expr $current_date - $access_date ) -le  $((30 * 24 * 60 * 60)) ]
  then
  output="safe"
  else
  output="in_danger"
  fi


  echo $output
}

global_path=$(pwd)

for path in $(find . -type d | awk '{ Table[NR]=$0; i=NR } END{ for(;i>-1;i--){ print Table[i]; } }'| grep -o '\./.*')
do
cd "$global_path""/""$path"
        
        for file in $(ls)
        do
        if [ -f $file ] && [ "$file" != "solution" ] && [ ${file#*.} != tgz ]
        then
        	msg=$(check_last_access $file)
        	if [ "$msg" == "safe" ]
        	then
        	break
        	fi
        fi
        done;

        if [ "$msg" == "in_danger" ] && [ $(find . -type d) == "." ]
        then
        cd ..
        archive_name=$(echo $path | awk 'BEGIN {FS="/"} {print $NF}')
        tar czf $archive_name.tgz $archive_name
        rm -r "$global_path""/""$path"
        fi

done;
