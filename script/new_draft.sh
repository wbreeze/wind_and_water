#!/bin/bash
if [ -z "$1" ]; then
  echo 'specify a name for the post'
  exit 1
fi
ymd=`date +%Y-%m-%d`
title=$1
name=`echo ${title} | sed -E "s/[^[:alnum:]]+/-/g"`
dest="./_drafts/${name}.md"
template="./_drafts/template.md"
subst="s/title: title/title: ${title}/;s/date: .+/date: ${ymd}/"
sed -E "${subst}" "${template}" >"${dest}"
echo "Created ${dest}"
vi ${dest}
