#!/bin/bash

rm -r build
mkdir build

elm-make src/elm/Main.elm --output build/js/rtm_uncompressed.js

if [ $? -eq 0 ]
then
  cp -r ./src/imgs ./build

  mkdir -p ./build/js

  cp ./src/index.html ./build/index.html
  uglifyjs ./build/js/rtm_uncompressed.js > ./build/js/rtm.js
  rm ./build/js/rtm_uncompressed.js
  uglifyjs ./src/htmlmain.js > ./build/js/htmlmain.js
  yui-compressor ./src/style.css > ./build/style.css

fi