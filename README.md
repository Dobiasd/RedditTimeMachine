reddittimemachine.com
Reddit Time Machine - check out what was up on reddit days/weeks/months ago

http://www.reddit.com/r/help/comments/27eziq/view_top_posts_of_a_specific_timespan/

http://www.reddit.com/dev/api



todo:

Links generieren ab june 2005:
http://www.reddit.com/r/programming/search?q=timestamp:1377993600..1380585600&sort=top&restrict_sr=on&syntax=cloudsearch

domain reservieren

ausgabe bei monaten und wochen auf jahre aufteilen, bei tagen auf monate
Die ist dann soviele spalten breit, wie ins fenster passen

dates constructen ueber funktion, die intern mit fromString arbeitet
intervall-ende ist dann nächste Tag minus eine sekunde

in module aufteilen

rollover ueber die suggestions soll nicht haengen bleiben (ganz raus? Dann aber anders als link kennzeichnen. hand mouse cursor?)
https://github.com/elm-lang/Elm/issues/652

click auf eine suggestion muss den richtigen wert setzen (wenn nicht geht, normalen button verwenden, der hat aber leider nix fettgedrucktes)
https://groups.google.com/forum/#!topic/elm-discuss/V7frjla1ZoE
https://github.com/elm-lang/Elm/issues/668

Auch wenn man noch nix eingegeben hat muessen die suggestions clickbar sein.