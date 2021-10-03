#!/bin/bash

app_name="ursr-app-name"
usage_string="Usage: ./make-${app_name}.sh $app_name /path/to/pier /path/to/${app_name}"

if [ $# -ne 3 ]; then
    echo "$usage_string"
    echo ""
    echo "Set up ${app_name}."
    echo ""
    echo "First parameter, ursr-app-name, must be one of:"
    echo "* ursr-client"
    echo "* ursr-demo"
    echo "* ursr-provider"
    echo ""
    echo "This script should be copied to and run"
    echo "in the pkg directory in the Urbit repo."
    echo ""
    echo "Requires the ship pier be already mounted"
    echo "and a ${app_name} desk already made, e.g. via"
    echo ""
    echo "|mount %"
    echo "|merge %${app_name} our %base"
    echo "|mount %${app_name}"
    echo ""
    echo "After running this script, run"
    echo ""
    echo "|commit %${app_name}"
    exit 1
fi
app_name=$1
path_to_pier=$2
path_to_app_code=$3

if [ "$app_name" != "ursr-client" ] \
&& [ "$app_name" != "ursr-demo" ]   \
&& [ "$app_name" != "ursr-provider" ]; then
    echo "$usage_string"
    echo ""
    echo "First parameter, ursr-app-name, must be one of:"
    echo "* ursr-client"
    echo "* ursr-demo"
    echo "* ursr-provider"
    echo ""
    echo "Input of ${app_name} is invalid."
    exit 2
fi

if [ -f "$app_name" ]; then
    rm -r $app_name
fi

if [ -f "ursr-dev-tmp" ]; then
    rm -r "./ursr-dev-tmp"
fi
cp -r "$(dirname $path_to_app_code)/ursr-dev" "./ursr-dev-tmp"

if [ -f "${app_name}-tmp" ]; then
    rm -r "./${app_name}-tmp"
fi
cp -r $path_to_app_code "./${app_name}-tmp"

if [ "$app_name" == "ursr-demo" ]; then
    ./symbolic-merge.sh landscape $app_name
fi
./symbolic-merge.sh base-dev $app_name
./symbolic-merge.sh garden-dev $app_name
./symbolic-merge.sh ursr-dev-tmp $app_name
if [ "$path_to_app_code" != "" ]; then
    ./symbolic-merge.sh "./${app_name}-tmp" $app_name
    if [ -f "./${app_name}-tmp/desk.bill" ]; then
        cp "./${app_name}-tmp/desk.bill" $app_name
    fi
fi

echo "[%zuse 420]" > ${app_name}/sys.kelvin

rm -r "${path_to_pier}/${app_name}"
cp -Lr $app_name $path_to_pier

# rm -r $app_name
rm -r "./ursr-dev-tmp"
# rm -r "./${app_name}-tmp"

echo "Done."
