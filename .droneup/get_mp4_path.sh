#!/bin/bash
json_dir="$1"
staging_dir="$2"
file_path=$(ls -a $staging_dir/$json_dir/*.json)
mp4_name=$(cat $file_path | jq '.File')
echo $mp4_name
