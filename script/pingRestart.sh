curl -I https://wnw.wbreeze.com/
if [[ $? == 7 ]] ; then sudo -n nginx ; fi
