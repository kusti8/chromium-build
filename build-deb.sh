#!/bin/bash

## BUILDING SHOULD BE FOR chrome, chrome_sandbox and pdf targets:
## ninja -C out/Release chrome chrome_sandbox pdf

OUT_FILES="catalog chromium-browser chrome_100_percent.pak chrome_200_percent.pak chrome_material_100_percent.pak chrome_material_200_percent.pak chrome-sandbox content_browser_manifest.json content_renderer_manifest.json content_resources.pak icudtl.dat keyboard_resources.pak libs libyuv.a locales natives_blob.bin pseudo_locales resources.pak snapshot_blob.bin xdg-mime xdg-settings *.so *.pak nacl_helper_bootstrap nacl_helper_nonsfi nacl_irt_arm.nexe"

if [ "$2" == "" ]; then
  echo "Usage: $0 deb_name version"
  echo "e.g.: build-deb.sh chromium-browser_51.0.2704.91-0ubuntu0.14.04.1.7000 51.0.2704.91-0ubuntu0.14.04.1.7000"
  exit 1
fi

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

OUT_DIR=$1
LIB_DIR=$OUT_DIR/usr/lib/arm-linux-gnueabihf
LIBFFMPEG=libffmpeg_chrome.so.55

wget https://github.com/kusti8/chromium-build/blob/master/chromium-browser_55.tar.gz?raw=true -O chromium.tar.gz
tar xvf chromium.tar.gz
mv chromium-browser_51.0.2704.91-0ubuntu0.14.04.1.6001 $OUT_DIR


mv src/out/armv6/chrome_sandbox src/out/armv6/chrome-sandbox
chown root:root src/out/armv6/chrome-sandbox
chmod 4755 src/out/armv6/chrome-sandbox
mv src/out/armv6/chrome src/out/armv6/chromium-browser
mv src/out/armv6/lib src/out/armv6/libs

for FILE in $OUT_FILES; do
  cp -r src/out/armv6/$FILE $OUT_DIR/usr/lib/chromium-browser/
done

cp src/out/armv6/$LIBFFMPEG $LIB_DIR/
cp src/out/armv7/$LIBFFMPEG $LIB_DIR/neon/vfp/

sed -i "/Version:/c\Version: $2" $OUT_DIR/DEBIAN/control

chown root:root $OUT_DIR/usr/lib/chromium-browser/chrome-sandbox
chmod 4755 $OUT_DIR/usr/lib/chromium-browser/chrome-sandbox
chown root:root $OUT_DIR/*

dpkg-deb --build $OUT_DIR
