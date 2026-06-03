#! /bin/bash
DESTV="/home/pi-admin"
TIMESTAMP=`env TZ='UTC' date +%Y%m%d%H%M`
VID_DIR="${DESTV}/Videos/Popa"
LOG="${VID_DIR}/${TIMESTAMP}.log"

CAM_0="${VID_DIR}/Cam0"
[ -d ${CAM_0} ] || mkdir -p "${CAM_0}"
DEST="${CAM_0}/Popa${TIMESTAMP}0.mp4"
echo "$DEST"
rpicam-vid --camera 0 -t 15s --config grabConfig.txt -o "${DEST}" >"${LOG}" 2>&1

CAM_1="${VID_DIR}/Cam1"
[ -d ${CAM_1} ] || mkdir -p "${CAM_1}"
DEST="${CAM_1}/Popa${TIMESTAMP}1.mp4"
echo "$DEST"
rpicam-vid --camera 1 -t 15s --config grabConfig.txt -o "${DEST}" >>"${LOG}" 2>&1

if [ ! -e "${VID_DIR}/keepalive" ]; then
  echo +3300 | tee /sys/class/rtc/rtc0/wakealarm
  sudo shutdown now
fi

