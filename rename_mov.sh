#!/bin/sh

is_mov () {
	if ! file -b "$1" | grep 'MOV' > /dev/null ; then
		echo "$1 is not MOV type" 1>&2
		return 1
	fi
	return 0
}

rename_mov () {

	dir=$(dirname "$1")
	new_name=$(stat -c %w "$1" | awk '{ printf("%sT%02d%02d%02d.mov", $1, $2, $3, $4) }' 'FS=[ :.]')

	echo "$1 -> $dir/$new_name"
	mv "$1" "$dir/$new_name"
}

for i in "$@"
do
	if is_mov "$i"; then
		rename_mov "$i"
	fi
done
