#!/bin/bash

# Simple script to copy & deploy a custom GBC .zip file
# ./deploy_gbc.sh  # No args = deploy to default server with 320
# ./deploy_gbc.sh 0  # deploy to localhost with 320
# ./deploy_gbc.sh x fourjs@oldserver.com 310  # deploy to a specific server with 310

function localDeploy() {
	GBC=$1
	GASVER=$2

	# Set the GAS environmment
	. /opt/fourjs/gas$VER/envas
	gasadmin -V

	# Define the command with custom .xcf file if it exists
	if [ -e $FGLASDIR/etc/isv_as$VER.xcf ]; then
  	CMD="gasadmin gbc -f $FGLASDIR/etc/isv_as$VER.xcf"
	else
  	CMD="gasadmin gbc"
	fi
	
	echo "Attempt to undeploy previous version of gbc ..."
	echo "$CMD --undeploy $GBC"
	$CMD --undeploy $GBC
	
	echo "Attempt to deploy new version of gbc ..."
	echo "$CMD --deploy $GBC"
	$CMD --deploy $GBC
	
	#rm $GBC
}

function remoteDeploy() {
	GBC=$1
	GASVER=$2
	# The ./deploy_gbc.sh on target machine sets the correct GAS env and runs the 
	# gasadmin command to deploy the custom GBC
	CMD="./deploy_gbc.sh $GBC $VER"
	
	# Copy the gar to the server
	echo "Coping ${GBC} to $HOST ..."
	scp ${GBC} $HOST:

	# Run CMD to deploy the copied GBC
	echo "Running ${CMD} on $HOST ..."
	ssh $HOST $CMD
}

SRV=${1:-1}
VER=${2:-320}

case $SRV in
0)
  HOST=local
;;
1)
  HOST=fourjs@myserver.com
;;
2)
  HOST=fourjs@myserver2.com
;;
*)
	HOST=$3
;;
esac

if [ $(ls -l gbc-*.zip | wc -l) -eq 0 ]; then
	echo "No GBC zip files found to deploy!"
	exit 1
fi

for GBC in gbc-*.zip
do
	if [ "$HOST" == "local" ]; then
		localDeploy $GBC $VER
	else
		remotelDeploy $GBC $VER
	fi
done

echo "Finished."
