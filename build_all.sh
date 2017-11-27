
echo "Updating etc/app_info.txt ..."
cat etc/app_name.txt > etc/app_info.txt
git describe >> etc/app_info.txt

echo "Cleaning distbin ..."
cd distbin
rm *.gar *.zip
cd ..

export PROJBASE=$( pwd )

echo "Building GBC packages BASE=$BASE ..."
cd gbc
make
cd ..

if [ -z "$FGLDIR" ]; then
	. env310
fi

echo "Building Main App GAR file ..."
gsmake njms_demos310.4pw
