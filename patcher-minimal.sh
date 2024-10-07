#!/bin/bash
#####=============== SMALLRAT TOOLBOX ===============#####
function existance() {
   if [ -e "$1" ]; then
      found=true && eval "$2"
   else
      found=false && eval "$3"
   fi
}
csd=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
pass=":"
#####================================================#####

# Check for necessary tools
command -v "$csd/tools/magiskboot" >/dev/null 2>&1 || { echo "magiskboot is required but not installed. Aborting." >&2; exit 1; }
command -v openssl >/dev/null 2>&1 || { echo "openssl is required but not installed. Aborting." >&2; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "python3 is required but not installed. Aborting." >&2; exit 1; }

# Exit or rename if necessary
existance "$csd/recovery.img.lz4" "$pass" "$pass"
if [ $found == true ]; then
   echo "found lz4-zipped image! please unzip it yourself, and re-run this script! " && exit
else existance "$csd/recovery.img" "$pass" "$pass"
   if [ $found == true ]; then
      mv "$csd/recovery.img" "$csd/raw.img" &&
      echo "found unzipped image!"
   else
      echo "no image to patch found. please place recovery.img in folder!" && exit 1
   fi
fi

# Edit raw image
echo "editing image..."
off=$(grep -ab -o SEANDROIDENFORCE raw.img | tail -n 1 | cut -d : -f 1)
if [ -z "$off" ]; then
   echo "Pattern SEANDROIDENFORCE not found in raw.img. Aborting."
   exit 1
fi
dd if=raw.img of=header.img bs=4k count=$off iflag=count_bytes || { echo "Failed to copy raw.img. Aborting."; exit 1; }
echo "made edit to image!"
echo "running file check..."
existance "$csd/header.img" "echo finished!" "echo file check on header.img failed && exit 1"

# Make key/signature
[ -d "$csd/keys" ] || mkdir "$csd/keys"
echo "making keyfile..."
existance "$csd/keys/phh.pem" ":" "openssl genrsa -f4 -out $csd/keys/phh.pem 4096 && echo 'made phh.pem'"

# Fragment the edited image
[ -d "$csd/fragments" ] || mkdir "$csd/fragments"
cd fragments
echo "fragmenting image for patching!"
$csd/tools/magiskboot unpack "$csd/header.img" || { echo "Failed to unpack header.img. Aborting."; exit 1; }
$csd/tools/magiskboot cpio ramdisk.cpio extract || { echo "Failed to extract ramdisk.cpio. Aborting."; exit 1; }
echo "showing directory..."
ls "$csd/fragments"
existance "$csd/fragments/system/bin/recovery" "echo successfully fragmented image!" "echo fragmentation failed! && exit 1"
