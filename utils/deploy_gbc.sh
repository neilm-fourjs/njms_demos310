
# needs to run using: sudo -u gpaas ./deploy_gbc.sh <name>

. /opt/fourjs/gas310/envas

CMD="gasadmin gbc -f /opt/fourjs/gas310/etc/isv_as310.xcf"

echo "Attempt to undeploy previous version of gbc ..."
echo "$CMD --undeploy $1"
$CMD --undeploy $1

echo "Attempt to deploy new version of gbc ..."
echo "$CMD --deploy $1"
$CMD --deploy $1
