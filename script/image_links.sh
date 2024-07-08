#!/bin/bash

if [ ! -d "$1" ]; then
  echo 'specify an image directory'
  echo 'e.g. script/image_links.sh docs/assets/images/...'
  exit 1
fi

rnn=`echo $1 | sed -E 's/\.?\/?docs\///'`
for fn in `ls -U -1 $1` ; do
  echo "![description]("
  echo "  {{ '$rnn/$fn' | relative_url }}"
  echo ")"
  echo
done

cd ..
