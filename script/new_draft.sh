#!/bin/bash
if [ -z "$1" ]; then
  echo 'specify a name for the post'
  exit 1
fi
ymd=`date +%Y-%m-%d`
title=$1
name=`echo ${title} | sed -E "s/[^[:alnum:]]+/-/g"`
destDir="./_drafts"
dest="${destDir}/${name}.md"
[[ -e "${destDir}" || `mkdir -p "${destDir}"` ]]
template="./new_post_template.md"
subst="s/title: title/title: ${title}/;s/date: .+/date: ${ymd}/"
if [[ ! -e ${dest} ]]; then
  sed -E "${subst}" "${template}" >"${dest}"
  echo "Created ${dest}"
else
  echo "${dest} already present"
fi
vi ${dest}
