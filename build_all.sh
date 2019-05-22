
# This is 3.20 version!
GENVER=320

. env$GENVER

export GBCPROJDIR=/opt/fourjs/gbc-current
if [ ! -d $GBCPROJDIR ]; then
	echo "WARNING: GBCPROJDIR = $GBCPROJDIR - not found!"
	read a
fi

echo "Updating etc/app_info.txt ..."
cat etc/app_name.txt > etc/app_info.txt
git describe >> etc/app_info.txt

echo "Cleaning distbin & bin$GENVER ..."
cd distbin
rm -f *.gar *.zip
cd ..
rm -f bin$GENVER

export PROJBASE=$( pwd )

if [ -e gbc ]; then
	echo "Building GBC packages BASE=$BASE ..."
	cd gbc
	make
	cd ..
fi

echo "Building Main App GAR file ..."
gsmake njms_demos$GENVER.4pw
