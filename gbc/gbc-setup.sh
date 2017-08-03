
# This script attempts to setup a GBC dev environment
#
# Example:
# ./setup.sh 1.00.37 201706291754

BASE=$(pwd)

GBC=gbc
VER=$1
BLD=$2

if [ -z $GBCPROJECTDIR ]; then
	echo "WARNING: GBCPROJECTDIR is not set to location of GBC project zip file(s)"
	GBCPROJECTDIR=~/FourJs_Downloads/GBC
	echo "Defaulting GBCPROJECTDIR to $GBCPROJECTDIR"
fi

if [ $# -ne 2 ]; then
	echo "ERROR: Must pass GBC version and Build, eg:"
	echo "./setup.sh 1.00.37 201706291754"
	exit 1
fi

SRC="$GBCPROJECTDIR/fjs-$GBC-$VER-build$BLD-project.zip"

BLDDIR=build/gbc-$VER

if [ ! -d $BLDDIR ]; then
	mkdir -p $BLDDIR
	if [ ! -e "$SRC" ]; then
		echo "Missing $SRC Aborting!"
		exit 1
	fi
	cd build
	unzip $SRC
	rm -f gbc-current
	ln -s gbc-$VER gbc-current
	cd gbc-$VER
else
	cd $BLDDIR
fi

npm install
npm install grunt-cli
npm install bower
grunt deps

