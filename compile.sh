#!/bin/bash

rm -r build
mkdir build

elm -m -o --src-dir=./src/elm src/elm/Main.elm

if [ $? -eq 0 ]
then
  cp ./src/.htaccess ./build
  cp -r ./src/imgs ./build

  mkdir -p ./build/js

  for pathname in ./build/src/elm/*.js
  do
      filename="${pathname##*/}"
      uglifyjs "$pathname" > "./build/js/$filename"
  done

  cp ./src/index.html ./build/index.html
  uglifyjs ./src/htmlmain.js > ./build/js/htmlmain.js
  yui-compressor ./src/style.css > ./build/style.css

  rm -r ./build/src

fi