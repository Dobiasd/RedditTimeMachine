#!/bin/bash

elm -m --src-dir=./src --set-runtime=elm-runtime.js src/RedditTimeMachine.elm

cp $HOME/.cabal/share/Elm-0.12.3/elm-runtime.js ./build

#mv ./build/src/RedditTimeMachine.html ./build/index.html
# remove whitespaces to shrink file size
cat ./build/src/RedditTimeMachine.html | perl -pe "s/ +/ /g" > ./build/index.html

cp -r ./src/icons ./build
cp -r ./src/imgs ./build

rm -r ./build/src