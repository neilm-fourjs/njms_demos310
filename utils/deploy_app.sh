#!/bin/bash
# needs to run using: sudo -u gpaas ./deploy_app.sh <appname>

VER=${2:-310}

# Set the GAS environment
. /opt/fourjs/gas$VER/envas

# Define the command using our custom XCF
if [ -e $FGLASDIR/etc/isv_as$VER.xcf ]; then
	CMD="gasadmin gar -f $FGLASDIR/etc/isv_as$VER.xcf"
else
	CMD="gasadmin gar"
fi

echo -e "\n attempt to disable previous version of app ..."
echo "$CMD --disable-archive $1"
$CMD --disable-archive $1
if [ $? -eq 0 ]; then
	echo -e "\n attempt to undeploy previous version of app ..."
	echo  "$CMD --undeploy-archive $1"
	$CMD --undeploy-archive $1
fi

#echo -e "\n List archives:"
#$CMD --list-archives

echo -e "\n attempt to clean archives ..."
echo "$CMD --clean-archives"
$CMD --clean-archives

echo -e "\n attempt to install new version of app ..."
echo "$CMD --deploy-archive $1.gar"
$CMD --deploy-archive $1.gar

if [ $? -eq 0 ]; then
	echo -e "\n attempt to enable app ..."
	echo "$CMD --enable-archive $1"
	$CMD --enable-archive $1
else
	echo "Deploy Failed!"
fi

