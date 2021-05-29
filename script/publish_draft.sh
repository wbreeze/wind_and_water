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
post_dir="./_posts"
dest="${post_dir}/${ymd}-${base_name}"
aspell -M -l en check "${src}"
subst="s/date: .+/date: ${ymd}/"
sed -E "${subst}" "${src}" >"${dest}"
echo
echo "Published ${dest}"
head -n 12 ${dest}
echo "Recent content of ${post_dir}:"
ls -lt ${post_dir} | head -n 6
echo
echo "Remove the draft?"
echo "Press enter to leave it, or type \"y\" and then enter to delete it."
rm -i "${src}"
