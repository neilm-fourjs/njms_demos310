#!/bin/bash
# If the user doesn't have permissions to deploy apps then use sudo

function localDeploy() {
	GAR=$1
	VER=$2

	# Set the GAS environment
	. /opt/fourjs/gas$VER/envas

	# Define the command using our custom XCF
	if [ -e $FGLASDIR/etc/isv_as$VER.xcf ]; then
		CMD="gasadmin gar -f $FGLASDIR/etc/isv_as$VER.xcf"
	else
		CMD="gasadmin gar"
	fi
	
	echo -e "\n attempt to disable previous version of app ..."
	echo "$CMD --disable-archive $GAR"
	$CMD --disable-archive $GAR
	if [ $? -eq 0 ]; then
		echo -e "\n attempt to undeploy previous version of app ..."
		echo	"$CMD --undeploy-archive $GAR"
		$CMD --undeploy-archive $GAR
	fi
	
	#echo -e "\n List archives:"
	#$CMD --list-archives
	
	echo -e "\n attempt to clean archives ..."
	echo "$CMD --clean-archives"
	$CMD --clean-archives
	
	echo -e "\n attempt to install new version of app ..."
	echo "$CMD --deploy-archive $GAR.gar"
	$CMD --deploy-archive $GAR.gar
	
	if [ $? -eq 0 ]; then
		echo -e "\n attempt to enable app ..."
		echo "$CMD --enable-archive $GAR"
		$CMD --enable-archive $GAR
	else
		echo "Deploy Failed!"
	fi
}

function remoteDeploy() {
	GAR=$1
	VER=$2
	CMD="./deploy_app.sh 0 $GAR $VER"

	echo "Deploying ${GAR}.gar to $HOST ..."
	# Copy the gar to the server
	scp -P $PORT ${GAR}.gar $HOST:
	# Run the deploy script to use gasadmin to re-deploy the gar
	ssh -p $PORT $HOST $CMD
}

# Main code

PORT=22
SRV=${1:-1}
APP=${2:-njms_demos$VER}
VER=${3:-320}
DB=pgs
GAR=${APP}_${DB}

if [ ! -e ${GAR}_${DB}.gar ]; then
	exit 1
fi


case $SRV in
0)
	HOST=local
;;
1)
	HOST=$4
	DB=${5:-ifx}
;;
2)
	HOST=pi@generodemos.dynu.net
	PORT=666
;;
3)
	HOST=ryan-4js.com
	PORT=666
;;
4)
	HOST=neilm@demos.4js-emea.com
;;
5)
	HOST=neilm@10.2.1.100
;;
esac

if [ "$HOST" == "local" ] || [ "$HOST" == "localhost" ]; then
	localDeploy $GAR $VER
else
	remotelDeploy $GAR $VER
fi

echo "Finished."

