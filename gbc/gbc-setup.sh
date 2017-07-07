
# This script attempts to setup a GBC dev environment
#
# Example:
# ./setup.sh 1.00.37 201706291754

BASE=$(pwd)

GBC=gbc
VER=$1
BLD=$2

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
	cd gbc-$VER
else
	cd $BLDDIR
fi

npm install
npm install grunt-cli
npm install bower
grunt deps

