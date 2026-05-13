#! /bin/bash
TIMESTAMP=`env TZ='UTC' date +%Y%m%d%H%M`
VID_DIR="${HOME}/Videos/Popa"
CAM_0="${VID_DIR}/Cam0"
[ -d ${CAM_0} ] || mkdir -p "${CAM_0}"
CAM_1="${VID_DIR}/Cam1"
[ -d ${CAM_1} ] || mkdir -p "${CAM_1}"
#rpicam-vid --camera 0 -t 15s -o "${CAM_0}/Popa${TIMESTAMP}.mp4"
#rpicam-vid --camera 1 -t 15s -o "${CAM_1}/Popa${TIMESTAMP}.mp4"
if [ ! -e "${VID_DIR}/keepalive" ]; then
  #echo +3600 | tee /sys/class/rtc0/wakealarm
  #shutdown now
fi

