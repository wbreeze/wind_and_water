curl -I https://wnw.wbreeze.com/
if [[ $? == 0 ]] ; then sudo nginx ; fi
