#!/bin/bash
#create reduced versions of images in named directory 
SRC_DIR=$1
if [[ -n ${SRC_DIR} && -e ${SRC_DIR} && -d ${SRC_DIR} ]]; then
  echo converting in "${SRC_DIR}"
  DEST_DIR="${SRC_DIR}/reduced"
  [ -e ${DEST_DIR} ] || mkdir ${DEST_DIR}
  if [ -d ${DEST_DIR} ]; then
    while IFS= read -d $'\0' -r SRC_IMAGE ; do
      CURF=${SRC_IMAGE##*/}
      DEST_IMAGE="${DEST_DIR}/${CURF}"
      [ "$SRC_IMAGE" -nt "${DEST_IMAGE}" ] && echo "${DEST_IMAGE}"
      [ "$SRC_IMAGE" -nt "${DEST_IMAGE}" ] && convert "${SRC_IMAGE}" -resize 600x "${DEST_IMAGE}"
    done < <(find -L ${SRC_DIR} -maxdepth 1 \( -iname '*.jpg' \
       -o -iname '*.jpeg' \
       -o -iname '*.gif' \
       -o -iname '*.png' \) \
       -a -type f -print0 | sort -z )
  else
    echo 'failed to create scaled image directory. file in the way?'
  fi
else
  echo 'specify an existing directory of source images'
fi
