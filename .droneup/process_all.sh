#!/bin/bash
aws=$(which aws)
[ -z "$aws" ] && echo "AWS-Cli missing, please install \"apt-get install aws-cli\"" || echo " -- Found aws-cli"

if [ ! -z "$ENVKEY" ]; then
    eval $(envkey-source $ENVKEY)
fi

[ -z "$AWS_KEY" ] && echo "Missing AWS_KEY in environment" && exit -1 || echo "Found AWS_KEY"
[ -z "$AWS_SECRET" ] && echo "Missing AWS_SECRET in environment" && exit -1 || echo "Found AWS_SECRET"
[ -z "$BUCKET" ] && echo "Missing Bucket name with JSON/MP4's" && exit 1 || echo "Found BUCKET"
[ -z "$STAGING_DIR" ] && echo "Missing staging dir, where json is stored" && exit 1 || echo "Found STAGING_DIR"
[ -z "$PROCESSED_DIR" ] && echo "Missing processed dir, where jpgs are stored" && exit 1 || echo "Found PROCESSED_DIR"

bucket=${BUCKET}
staging_dir=$(realpath $STAGING_DIR)
processed_dir=$(realpath $PROCESSED_DIR)

mkdir -p ${staging_dir} | true
mkdir -p ${processed_dir} | true

eval ${PWD}/fill_staging.sh $bucket $staging_dir
all_json=$(find ${staging_dir} -name "*.json")

# For each directory in staging, so we can have GUID (its in s3 path)
for d in ${staging_dir}/* ; do
    folder=$(basename "$d")
    json_files=$(ls -a ${staging_dir}/$folder/*.json)
    for json in $json_files; do
      mp4name=$(cat $json | jq '.File')
      mp4name=${mp4name:1:-1} #Prior results had " " surrounding, remove them.
      baseName=$(basename -- $mp4name)
      s3fullpath=${bucket}/$folder/$mp4name
      auth_http=$(aws s3 presign $s3fullpath)
      mkdir -p ${processed_dir}/$folder
      ffmpeg -noaccurate_seek -ss 00:00:01 -i ${auth_http} -frames:v 1 ${processed_dir}/$folder/$baseName.jpg
      ${aws} s3 cp ${processed_dir}/$folder/$baseName.jpg s3://${bucket}/${folder}/${baseName}.jpg
      echo " -- Copied thumbnail to s3://${bucket}/${folder}/${baseName}.jpg"
    done
done
