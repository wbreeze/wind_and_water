#!/bin/bash
if [ -z "$1" ]; then
  echo 'specify a name for the post'
  exit 1
fi
ymd=`date +%Y-%m-%d`
title=$1
name=`echo ${title} | sed -E "s/[^[:alnum:]]+/-/g"`
name="./_posts/${ymd}-${name}.md"
template="./_posts/drafts/template.md"
subst="s/title: title/title: ${title}/;s/date: .+/date: ${ymd}/"
sed -E "${subst}" "${template}" >"${name}"
echo "Created ${name}"
vi ${name}
