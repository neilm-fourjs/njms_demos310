#!/bin/bash

FGLVER=$(fglrun -V | head -1 | awk '{FS=" ";}{print $2}')
GRETEST=~/all/my_github/njms_demos310
export FGLLDPATH=$GRETEST/bin:$GREDIR/lib
export FGLRESOURCEPATH=$GRETEST/etc
export GREFILEPATH=./
export FONTDIR=~/.fonts

l_inFile=$1
l_4rp=$2
l_device=$3
l_targetName=$4

if [ -z "$l_inFile" ]; then
	echo "No xml passed"
	echo "USAGE: inFile 4rp device targetName"
	exit 1
fi

if [ ! -z $l_targetName ]; then
	unset FGLSERVER
fi

echo XML=$l_inFile
echo 4RP=$l_4rp
echo Dev=$l_device
echo Out=$l_targetName

fglrun $GRETEST/bin/gre_test4rp.42r $l_inFile $l_4rp $l_device $l_targetName

if [ $? -eq 0 ]; then
	if [ "$l_device" = "PDF" ] && [ ! -z $l_targetName ]; then
		xdg-open $l_targetName
	fi
fi
