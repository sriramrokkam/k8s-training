#!/bin/bash
# Author : vasu1124
# License : MIT

function usage()
{
    cat << EOFmark
Usage: $0 <binary> [destination]
copies all dependant libraries, preserving library paths into destination folder
default destination is .
library paths in destination are created dynamincally.
EOFmark
exit 1
}

#Validate the inputs
[[ $# < 1 ]] && usage
dest=$2
[[ $# < 2 ]] && dest=.

#Check if the paths are valid
[[ ! -e $1 ]] && echo "Not a valid input $1" && exit 1 
[[ -d $dest ]] || echo "No such directory $dest ..." 

lddtree -l $1 | while read lib
do
  dir="${lib%/*}"
  mkdir -p ${dest}${dir}
  cp -vf $lib ${dest}${lib}
done
