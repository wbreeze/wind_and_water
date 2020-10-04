#!/bin/bash
if [ -z "$1" ]; then
  echo 'specify the absolute or relative file to publish'
  exit 1
fi
if [ ! -f "$1" ]; then
  echo "File "$1" not found."
  exit 2
fi
src="$1"
base_name=${src##*/}
ymd=`date +%Y-%m-%d`
dest="./_posts/${ymd}-${base_name}"
subst="s/date: .+/date: ${ymd}/"
sed -E "${subst}" "${src}" >"${dest}"
echo
echo "Published ${dest}"
head -n 12 ${dest}
echo "Recent content of _posts:"
ls -lt ./_posts | head -n 6
echo
echo "Remove the draft?"
echo "Press enter to leave it, or type \"y\" and then enter to delete it."
rm -i "${src}"
