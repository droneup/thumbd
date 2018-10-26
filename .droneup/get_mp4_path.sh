#!/bin/bash
json_dir="$1" #This is a User.objectId, but probably should be a Media.objectId
staging_dir=""
aws=$(which aws)
[ -z "$aws" ] && echo "AWS-Cli missing, please install \"apt-get install aws-cli\"" || echo " -- Found aws-cli"

if [ -z "$ENVKEY" ]; then
    eval $(envkey-source $ENVKEY)
    staging_dir=$STAGING_DIR
else
    staging_dir="$2"
fi


file_path=$(ls -a $staging_dir/$json_dir/*.json)
mp4_name=$(cat $file_path | jq '.File')
echo $mp4_name
