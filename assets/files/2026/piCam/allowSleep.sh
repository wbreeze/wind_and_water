#! /bin/bash
VID_DIR="${HOME}/Videos/Popa"
KA="${VID_DIR}/keepalive"
if [ -e "${KA}" ]; then
  rm "${KA}"
fi

