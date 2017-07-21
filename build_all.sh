
cat etc/app_name.txt > etc/app_info.txt
git describe >> etc/app_info.txt

cd gbc
make
cd ..

gsmake njms_demos310.4pw
