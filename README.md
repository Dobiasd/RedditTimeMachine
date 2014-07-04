# Reddit Time Machine
## check out what was up on reddit days/weeks/months ago

http://www.reddit.com/r/help/comments/27eziq/view_top_posts_of_a_specific_timespan/

http://www.reddit.com/dev/api



todo:

Why does adsense not accept me? ask at webmasters.stackexchange

ausgabe bei monaten und wochen auf jahre aufteilen, bei tagen auf monate
Die ist dann soviele spalten breit, wie ins fenster passen

code clean up und comments

dropDowns muessen von den statischen links auch gesetzt werden
https://github.com/elm-lang/Elm/issues/670

rollover ueber die suggestions soll nicht haengen bleiben (ganz raus? Dann aber anders als link kennzeichnen. hand mouse cursor?)
https://github.com/elm-lang/Elm/issues/652

do not go back beyond start date of reddit




issue 670 workaround:
    function updateDropDown(node, oldModel, newModel) {
      var freshNode = renderDropDown(newModel.signal, newModel.values)();
      while (node.firstChild) {
        node.removeChild(node.firstChild);
      }
      var nodes = freshNode.childNodes;
      for(var i = 0; i < nodes.length; ++i) {
        node.appendChild(nodes[i].cloneNode(true));
      }
      oldModel = newModel;
    }
    function dropDown(signal, values) {
        return A3(newElement, 100, 24, {
            ctor: 'Custom',
            type: 'DropDown',
            render: renderDropDown(signal,values),
            update: updateDropDown,
            model: {signal:signal, values:values}
        });
    }
