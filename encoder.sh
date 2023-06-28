#!/bin/bash

# Main
run_dir=$(pwd)
cur_dir=$(cd `dirname $0`; pwd)

if [ ! -r "$cur_dir/silk/encoder" ]; then
	cd "$cur_dir/silk" || { echo '{"code": 1, "message": "No directory named silk."}'; exit 1; }
	make > /dev/null 2>&1 && make encoder > /dev/null 2>&1
	[ ! -r "$cur_dir/silk/encoder" ]&&echo '{"code": 1, "message": "Encoder Compile False"}'&&exit
fi

#cd "$run_dir"

fileName=$(basename $1)

ffmpeg -y -i "$1" -acodec pcm_s16le -f s16le -ac 1 -ar 24000 "/tmp/${fileName%.*}.pcm" > /dev/null 2>&1 &
ffmpeg_pid=$!
while kill -0 "$ffmpeg_pid"; do sleep 1; done > /dev/null 2>&1
if [ ! -f "/tmp/${fileName%.*}.pcm" ]; then
	echo '{"code": 1, "message": "It is possible that ffmpeg does not support this format."}'&&exit
fi
"$cur_dir"/silk/encoder "/tmp/${fileName%.*}.pcm" "${1%.*}.$2" -tencent > /dev/null 2>&1
rm "/tmp/${fileName%.*}.pcm"
[ ! -f "${1%.*}.$2" ]&&echo '{"code": 1, "message": "Convert false"}'&&exit
echo "{\"code\": 0, \"message\": \"${1%.*}.$2\"}"
exit
