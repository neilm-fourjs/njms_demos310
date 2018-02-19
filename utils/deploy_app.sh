
# needs to run using: sudo -u gpaas ./deploy_app.sh <appname>

. /opt/fourjs/gas310/envas

CMD="gasadmin gar -f /opt/fourjs/gas310/etc/isv_as310.xcf"


echo -e "\n attempt to disable previous version of app ..."
echo "$CMD --disable-archive $1"
$CMD --disable-archive $1

echo -e "\n attempt to undeploy previous version of app ..."
echo  "$CMD --undeploy-archive $1"
$CMD --undeploy-archive $1

echo -e "\n List archives:"
$CMD --list-archives

echo -e "\n attempt to clean archives ..."
echo "$CMD --clean-archives"
$CMD --clean-archives

echo -e "\n attempt to install new version of app ..."
echo "$CMD --deploy-archive $1.gar"
$CMD --deploy-archive $1.gar

echo -e "\n attempt to enable app ..."
echo "$CMD --enable-archive $1"
$CMD --enable-archive $1

