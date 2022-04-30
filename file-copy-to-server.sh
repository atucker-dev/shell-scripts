#!/bin/bash

# Script that recursively copies media files from a source folder to destination folders 
# following YEAR/MONTH directory naming convention
#
# $1 - Source directory to scan for media files
# $2 - Base image destination directory
# $3 - Base video destination directory

scan_dir(){
    for file in "$1"/*; do
      if [ -d "$file" ]; then
       #ESCAPED_FILE=$(echo $file | sed 's! !\\ !g')
       scan_dir "$file"
      elif [ -f "$file" ]; then
        case "$file" in
          *.jpg|*.jpeg|*.png|*.gif|*.mp4)
            parse_filename_date "$file"
        esac
      fi
    done
}

parse_filename_date() {
  shopt -s nocasematch

  FILE_NAME=$(echo $1 | awk -F"/" '{printf $8}')
  if [[ $FILE_NAME =~ ^(IMG|PXL|PANO)_[0-9]{8}_[0-9]{6,9}.*\.(jpg|gif|jpeg|png)$ ]]; then
    DATE=$(echo $FILE_NAME | awk -F"_" '{printf $2}')
    copy_img_file_to_dest "$1" "$DATE"
  elif [[ $FILE_NAME =~ ^[0-9]{10} ]]; then
    DATE=$(echo $FILE_NAME | awk -F'[.-]' '{printf $1}')
    copy_date_only_file_to_dest "$1" "$DATE"
  elif [[ $FILE_NAME =~ ^(VID|PXL)_[0-9]{8}_[0-9]{6,9}.*\.(mp4|gif)$ ]]; then
    copy_video_file_to_dest "$1"
  else
    copy_no_date_file_to_dest "$1"
  fi

  shopt -u nocasematch
}

copy_img_file_to_dest() {
    YEAR=$(echo $2 | cut -c1-4)
    MONTH=$(echo $2 | cut -c5-6)
    #printf '%s\n' "$1"
    cp -v "$1" "$BASE_DEST_DIR/$YEAR/$MONTH/"
}

copy_date_only_file_to_dest() {
    YEAR=$(echo $2 | cut -c5-6)
    MONTH=$(echo $2 | cut -c1-2)
    cp -v "$1" "$BASE_DEST_DIR/20$YEAR/$MONTH/"
}

copy_video_file_to_dest() {
    cp -v "$1" "$BASE_VIDEO_DIR/"
}

copy_no_date_file_to_dest() {
    cp -v "$1" "$BASE_DEST_DIR/no-date-info/"
}

BASE_VIDEO_DIR="$3"
BASE_DEST_DIR="$2"
scan_dir "$1"