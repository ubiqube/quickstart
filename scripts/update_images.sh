#!/usr/bin/bash


usage() {
  echo -e "Usage: $(basename $0) REFERENCE_FILE FILE
  Update images in FILE accroding to REFERENCE_FILE.
  REFERENCE_FILE docker compose reference file
  FILE           docker compose file to be changed, a backup is created backup_FILE
"
  exit $1
}

if [ $# -ne 2 ]; then
  usage 1
fi

ref_file=$1
src_file=$2
backup_file=backup_$src_file

if [ ! -f $ref_file ]; then
  echo "$ref_file does not exist"
  exit 1
fi

if [ ! -f $src_file ]; then
  echo "$src_file does not exist"
  exit 1
fi

if [ -f $backup_file ]; then
  echo "$backup_file already exists"
  exit 1
fi

cp -p $src_file $backup_file
for img in $(awk 'match($0, /\s*image:\s+(ubiqube\/.*)/, a) {print a[1]}' $ref_file | sort -u); do
  name=${img%%:*}
  project=${name##ubiqube/}
  sed -i -r "s@^(\s+)image:\s+\S+${project}.*@\1image: ${img}@" $src_file
done
