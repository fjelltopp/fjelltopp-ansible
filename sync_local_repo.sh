#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'This script syncs local files or directories with CKAN pod running on Minikube. Run it with two parameters, first: local_path and second: remote_path, where remote path is a path already inside /usr/lib/ckan, so it can be just / or /ckanext-dms'
    echo 'Example: ./sync_local_repo.sh /home/michal/dms/ckanext-dms/ /'
    exit 0
fi

local_path=$1
remote_path=$2
pod_path=/usr/lib/ckan

minikube kubectl -- -n ckan cp "$local_path" "$(minikube kubectl -- get pods -n ckan -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}' --selector=app=ckan)":"$pod_path""$remote_path"
