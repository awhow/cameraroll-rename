#!/bin/sh

is_jpg () {
	if ! file -b "$1" | grep 'JPEG' > /dev/null ; then
		echo "$1 is not JPEG type" 1>&2
		return 1
	fi
	return 0
}

rename_jpg () {

	dir=$(dirname "$1")
	new_name=$(exif -t 'Date and Time' "$1" | awk '/Value/ { printf("%04s-%02d-%02dT%02d%02d%02d.jpg", $5, $6, $7, $8, $9, $10) }' 'FS=[ :.]')

	if [ -z "$new_name" ]; then
		new_name=$(stat -c %w "$1" | awk '{ printf("%sT%02d%02d%02d.jpg", $1, $2, $3, $4) }' 'FS=[ :.]')
	fi

	echo "$1 -> $dir/$new_name"
	mv "$1" "$dir/$new_name"
}

for i in "$@"
do
	if is_jpg "$i"; then
		rename_jpg "$i"
	fi
done
