#!/bin/bash

# Main
run_dir=$(pwd)
cur_dir=$(cd `dirname $0`; pwd)

if [ ! -r "$cur_dir/silk/decoder" ]; then
	cd "$cur_dir/silk" || { echo '{"code": 1, "message": "No directory named silk."}'; exit 1; }
	make > /dev/null 2>&1 && make decoder > /dev/null 2>&1
	[ ! -r "$cur_dir/silk/decoder" ]&&echo '{"code": 1, "message": "Decoder Compile False"}'&&exit
fi

#cd "$run_dir"
fileName=$(basename $1)

$cur_dir/silk/decoder "$1" "/tmp/${fileName%.*}.pcm" > /dev/null 2>&1
if [ ! -f "/tmp/${fileName%.*}.pcm" ]; then
	echo '{"code": 1, "message": "Maybe not a silk v3 encoded file."}'&&exit
fi
ffmpeg -y -f s16le -ar 24000 -ac 1 -i "/tmp/${fileName%.*}.pcm" "${1%.*}.$2" > /dev/null 2>&1
ffmpeg_pid=$!
while kill -0 "$ffmpeg_pid"; do sleep 1; done > /dev/null 2>&1
rm "/tmp/${fileName%.*}.pcm"
[ ! -f "${1%.*}.$2" ]&&echo '{"code": 1, "message": "It is possible that ffmpeg does not support this format."}'&&exit
echo "{\"code\": 0, \"message\": \"${1%.*}.$2\"}"
exit
