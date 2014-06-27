#!/bin/bash

elm -m --src-dir=./src --runtime=elm-runtime.js src/RedditTimeMachine.elm

cp $HOME/.cabal/share/Elm-0.12/elm-runtime.js ./build

mv ./build/src/RedditTimeMachine.html ./build/index.html

rm -r ./build/src