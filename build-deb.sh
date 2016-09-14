#!/bin/bash

## BUILDING SHOULD BE FOR chrome, chrome_sandbox and pdf targets:
## ninja -C out/Release chrome chrome_sandbox pdf

OUT_FILES="catalog chromium-browser chrome_100_percent.pak chrome_200_percent.pak chrome_material_100_percent.pak chrome_material_200_percent.pak chrome-sandbox content_browser_manifest.json content_renderer_manifest.json content_resources.pak icudtl.dat keyboard_resources.pak libs libyuv.a locales natives_blob.bin pseudo_locales resources.pak snapshot_blob.bin xdg-mime xdg-settings"

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

wget https://github.com/kusti8/chromium-build/blob/master/chromium-browser_51.tar.gz?raw=true -O chromium.tar.gz
tar xvf chromium.tar.gz
mv chromium-browser_51.0.2704.91-0ubuntu0.14.04.1.6001 $OUT_DIR


mv src/out/Release/chrome_sandbox src/out/Release/chrome-sandbox
chown root:root src/out/Release/chrome-sandbox
chmod 4755 src/out/Release/chrome-sandbox
mv src/out/Release/chrome src/out/Release/chromium-browser
mv src/out/Release/lib src/out/Release/libs

for FILE in $OUT_FILES; do
  cp -r src/out/Release/$FILE $OUT_DIR/usr/lib/chromium-browser/
done

sed -i "/Version:/c\Version: $2" $OUT_DIR/DEBIAN/control

dpkg-deb --build $OUT_DIR
