#!/bin/bash

# Obtains *.json for bucket, stores in staging directory.
# json contains mp4 full path, and for each we'll capture 1s locally
# for thumbnails.

bucket=""
staging_dir=""
aws=$(which aws)

if [ ! -z "$ENVKEY" ]; then
    eval $(envkey-source $ENVKEY)
    bucket="s3://$BUCKET"
    staging_dir=$(realpath $STAGING_DIR)
else
    bucket="s3://$1"
    staging_dir=$2
fi


[ -z "$bucket" ] && echo "Missing bucket name, for use as source" || echo " -- Copying *.json from ${bucket}"
[ -z "$staging_dir" ] && echo "Missing staging_dir, where ths json will temporaily stored" || echo " -- Staging json to ${staging_dir}"
[ -z "$aws" ] && echo "AWS-Cli missing, please install \"apt-get install aws-cli\"" || echo " -- Found aws-cli"

echo " -- Cleaning out $staging_dir"
rm -rf ${staging_dir}/* | true
[ ! -d ${staging_dir} ] && mkdir -p ${staging_dir} | true

${aws} s3 cp $bucket ${staging_dir} --recursive --exclude "*" --include "*.json"

