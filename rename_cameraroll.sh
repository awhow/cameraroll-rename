#!/bin/sh

is_type () {
	if ! file -b "$1" | grep "$2" > /dev/null ; then
		#echo "$1 is not $2 type" 1>&2
		return 1
	fi
	return 0
}

is_jpg () {
	is_type "$1" "JPEG"
}

is_mov () {
	is_type "$1" "MOV"
}

is_mp4 () {
	is_type "$1" "MP4"
}

perform_rename() {
	if [ "$1" = "$2" ]; then
		echo "$1 name is accurate"
	else
		echo "$1 -> $2"
		mv -i "$1" "$2"
	fi
}

stat_new_name () {
	new_name=$(stat -c %y "$1" | awk -v EXT="$2" '{ printf("%sT%02d%02d%02d.%s", $1, $2, $3, $4, EXT) }' 'FS=[ :.]')
	echo "$new_name"
}

exiftool_new_name() {
	new_name=$(exiftool "$1" | awk -v TGT="$2" '/TGT/ { printf("%04d-%02d-%02dT%02d%02d%02d.mov", $2, $3, $4, $5, $6, $7) }' 'FS=[:Z]')
	echo "$new_name"
}

rename_jpg () {
	dir=$(dirname "$1")
	new_name=$(exif -t 'Date and Time' "$1" | awk '/Value/ { printf("%04s-%02d-%02dT%02d%02d%02d.jpg", $5, $6, $7, $8, $9, $10) }' 'FS=[ :.]')

	if [ -z "$new_name" ]; then
		new_name=$(stat_new_name "$1" "jpg")
	fi

	perform_rename "$1" "$dir/$new_name"
}

rename_mov () {
	dir=$(dirname "$1")
	#new_name=$(exiftool "$1" | awk '/Creation Date/ { printf("%04d-%02d-%02dT%02d%02d%02d.mov", $2, $3, $4, $5, $6, $7) }' 'FS=:')
	new_name=$(exiftool_new_name "$1" "Creation Date")
	echo "MOV exiftool new_name is $new_name"
	if [ -z "$new_name" ]; then
		new_name=$(stat_new_name "$1" "mov")
	fi
	perform_rename "$1" "$dir/$new_name"
}

for i in "$@"
do
	if is_jpg "$i"; then
		rename_jpg "$i"
	fi

	if is_mov "$i"; then
		rename_mov "$i"
	fi
done
