#!/bin/bash

#rm -r build
#rm -r cache

elm -m -o --src-dir=./src/elm --set-runtime=elm-runtime.js src/elm/Main.elm

if [ $? -eq 0 ]
then

  cp -r ./src/imgs ./build

  mkdir -p ./build/js


  # todo: reactivate when issues are fixed
  #uglifyjs $HOME/.cabal/share/Elm-0.12.3/elm-runtime.js > ./build/js/elm-runtime.js


  ### start of workarounds

  cp $HOME/.cabal/share/Elm-0.12.3/elm-runtime.js ./build/js/elm-runtime.js

  #evil hack to work around https://github.com/elm-lang/Elm/issues/671
  cat ./build/js/elm-runtime.js | perl -pe "s/if \(currP.href === ''\) {/if (currP.href === '' || !node.lastNode) {/g" > ./build/js/elm-runtime.js.fix671
  mv ./build/js/elm-runtime.js.fix671 ./build/js/elm-runtime.js

  #evil hack to work around https://github.com/elm-lang/Elm/issues/668
  cat ./build/js/elm-runtime.js | perl -pe "s/node\.elm_down\.elm_value = value;/node\.elm_down\.elm_value = value;\n\nnode\.elm_signal = signal;\nnode\.elm_value = value;\n/g" > ./build/js/elm-runtime.js.fix668
  mv ./build/js/elm-runtime.js.fix668 ./build/js/elm-runtime.js

  uglifyjs ./build/js/elm-runtime.js > ./build/js/elm-runtime.js.ugly
  mv ./build/js/elm-runtime.js.ugly ./build/js/elm-runtime.js

  ### end of workarounds


  for pathname in ./build/src/elm/*.js
  do
      filename="${pathname##*/}"
      uglifyjs "$pathname" > "./build/js/$filename"
  done

  cp ./src/index.html ./build/index.html
  uglifyjs ./src/htmlMain.js > ./build/js/htmlMain.js
  yui-compressor ./src/style.css > ./build/style.css

  rm -r ./build/src

fi