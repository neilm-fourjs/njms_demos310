#!/bin/bash

# needs to run using: sudo -u gpaas ./deploy_gbc.sh <name>

VER=${2:-310}

# Set the GAS environmment
. /opt/fourjs/gas$VER/envas

# Define the command with custom .xcf file
if [ -e $FGLASDIR/etc/isv_as$VER.xcf ]; then
	CMD="gasadmin gbc -f $FGLASDIR/etc/isv_as$VER.xcf"
else
	CMD="gasadmin gbc"
fi

echo "Attempt to undeploy previous version of gbc ..."
echo "$CMD --undeploy $1"
$CMD --undeploy $1

echo "Attempt to deploy new version of gbc ..."
echo "$CMD --deploy $1"
$CMD --deploy $1

rm $1
