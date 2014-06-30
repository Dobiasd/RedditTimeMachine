#!/bin/bash

elm -m -o --src-dir=./src/elm --set-runtime=elm-runtime.js src/elm/RedditTimeMachine.elm



#mv ./build/src/RedditTimeMachine.html ./build/index.html
# remove whitespaces to shrink file size
# cat ./build/src/RedditTimeMachine.html | perl -pe "s/ +/ /g" > ./build/index.html

cp -r ./src/icons ./build
cp -r ./src/imgs ./build

mkdir ./build/js

cp $HOME/.cabal/share/Elm-0.12.3/elm-runtime.js ./build/js

for pathname in ./src/js/*.js
do
    filename="${pathname##*/}"
    uglifyjs "$pathname" > "./build/js/$filename"
    #cp "$pathname" "./build/js/$filename"
done

for pathname in ./build/src/elm/*.js
do
    filename="${pathname##*/}"
    uglifyjs "$pathname" > "./build/js/$filename"
done

cp ./src/index.html ./build/index.html
cp ./src/style.css ./build/style.css

#rm -r ./build/src