
cat etc/app_name.txt > etc/app_info.txt
git describe >> etc/app_info.txt

cd gbc
make
cd ..

if [ -z "$FGLDIR" ]; then
	. env310
fi

gsmake njms_demos310.4pw
