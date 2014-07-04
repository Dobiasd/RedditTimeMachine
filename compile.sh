#!/bin/bash

#rm -r build
#rm -r cache

elm -m -o --src-dir=./src/elm --set-runtime=elm-runtime.js src/elm/Main.elm

cp -r ./src/imgs ./build

mkdir -p ./build/js


# todo: reactivate when bugs in elm are fixed and workaround section removed
#uglifyjs $HOME/.cabal/share/Elm-0.12.3/elm-runtime.js > ./build/js/elm-runtime.js



### start of workarounds for bugs in elm

cp $HOME/.cabal/share/Elm-0.12.3/elm-runtime.js ./build/js/elm-runtime.js

#evil hack to work around https://github.com/elm-lang/Elm/issues/671
cat ./build/js/elm-runtime.js | perl -pe "s/if \(currP.href === ''\) {/if (currP.href === '' || !node.lastNode) {/g" > ./build/js/elm-runtime.js.fix671
mv ./build/js/elm-runtime.js.fix671 ./build/js/elm-runtime.js

#evil hack to work around https://github.com/elm-lang/Elm/issues/668
cat ./build/js/elm-runtime.js | perl -pe "s/node\.elm_down\.elm_value = value;/node\.elm_down\.elm_value = value;\n\nnode\.elm_signal = signal;\nnode\.elm_value = value;\n/g" > ./build/js/elm-runtime.js.fix668
mv ./build/js/elm-runtime.js.fix668 ./build/js/elm-runtime.js

#evil hack to work around https://github.com/elm-lang/Elm/issues/670
#cat ./build/js/elm-runtime.js | perl -pe "s/model: \{\}/model: {signal:signal, values:values}/g" | perl -pe 's/function updateDropDown\(node, oldModel, newModel\) \{/function updateDropDown(node, oldModel, newModel) {\n      var freshNode = renderDropDown(newModel.signal, newModel.values)();\n      while (node.firstChild) {\n        node.removeChild(node.firstChild);\n      }\n      var nodes = freshNode.childNodes;\n      for(var i = 0; i < nodes.length; ++i) {\n        node.appendChild(nodes[i].cloneNode(true));\n      }\n      oldModel = newModel;\n/g' > ./build/js/elm-runtime.js.fix670
#var freshNode = renderDropDown(newModel.signal, newModel.values)();
#mv ./build/js/elm-runtime.js.fix670 ./build/js/elm-runtime.js

uglifyjs ./build/js/elm-runtime.js > ./build/js/elm-runtime.js.ugly
sleep 1 # otherwise the OS sometimes says 'Operation not permitted'
mv ./build/js/elm-runtime.js.ugly ./build/js/elm-runtime.js

### end of workarounds for bugs in elm



for pathname in ./build/src/elm/*.js
do
    filename="${pathname##*/}"
    uglifyjs "$pathname" > "./build/js/$filename"
    #cp "$pathname" "./build/js/$filename"
done

cp ./src/index.html ./build/index.html
uglifyjs ./src/htmlMain.js > ./build/js/htmlMain.js
yui-compressor ./src/style.css > ./build/style.css

rm -r ./build/src