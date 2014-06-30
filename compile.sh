#!/bin/bash

rm -r build
rm -r cache

elm -m -o --src-dir=./src/elm --set-runtime=elm-runtime.js src/elm/RedditTimeMachine.elm

cp -r ./src/icons ./build
cp -r ./src/imgs ./build

mkdir ./build/js

cp $HOME/.cabal/share/Elm-0.12.3/elm-runtime.js ./build/js

for pathname in ./src/js/*.js
do
    filename="${pathname##*/}"
    #uglifyjs "$pathname" > "./build/js/$filename"
    cp "$pathname" "./build/js/$filename"
done

for pathname in ./build/src/elm/*.js
do
    filename="${pathname##*/}"
    #uglifyjs "$pathname" > "./build/js/$filename"
    cp "$pathname" "./build/js/$filename"
done

cp ./src/index.html ./build/index.html
cp ./src/style.css ./build/style.css

rm -r ./build/src