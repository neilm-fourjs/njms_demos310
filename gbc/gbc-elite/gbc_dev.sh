CUSTOM=$(basename $PWD)
echo "Dev build for $CUSTOM"
cd ../build/current
grunt --customization=customization/$CUSTOM dev

