module Header where

import Graphics.Input (Input, input, customButton)
import Window

import Layout (defaultSpacer, bgColor, toDefText, toSizedText)

iconSize : Int
iconSize = 32

logoHeight : Int
logoHeight = 100

logoWidth : Int
logoWidth = 120

clicks : Input ()
clicks = input ()

-- Images as hyperlinks do not work, so customButton is used.
-- https://groups.google.com/forum/#!topic/elm-discuss/K5tHTGDbLLk
shareIcons : Element
shareIcons =
  let
    buttons =
      [ ( image iconSize iconSize "imgs/facebook.png", "https://www.facebook.com/sharer/sharer.php?u=http://www.reddittimemachine.com" )
      , ( image iconSize iconSize "imgs/twitter.png", "https://twitter.com/home?status=Check%20out%20what%20was%20up%20on%20reddit%20days/weeks/months%20ago%20at%20http://www.reddittimemachine.com" )
      , ( image iconSize iconSize "imgs/googleplus.png", "https://plus.google.com/share?url=http://www.reddittimemachine.com" )
      , ( image iconSize iconSize "imgs/linkedin.png", "https://www.linkedin.com/shareArticle?mini=true&url=http://www.reddittimemachine.com&title=Reddit%20Time%20Machine&summary=Check%20out%20what%20was%20up%20on%20reddit%20days/weeks/months%20ago.&source=" )
      , ( image iconSize iconSize "imgs/pinterest.png", "https://pinterest.com/pin/create/button/?url=&media=http://www.reddittimemachine.com&description=Check%20out%20what%20was%20up%20on%20reddit%20days/weeks/months%20ago." )
      , ( image iconSize iconSize "imgs/digg.png", "http://digg.com/submit?phase=2&url=http://www.reddittimemachine.com&title=Check%20out%20what%20was%20up%20on%20reddit%20days/weeks/months%20ago." )
      , ( image iconSize iconSize "imgs/stumbleupon.png", "http://www.stumbleupon.com/submit?url=http://www.reddittimemachine.com&title=Check%20out%20what%20was%20up%20on%20reddit%20days/weeks/months%20ago." )
      , ( image iconSize iconSize "imgs/email.png", "mailto:%20?subject=reddit time machine&body=Check%20out%20what%20was%20up%20on%20reddit%20days/weeks/months%20ago%20at%20http://www.reddittimemachine.com" ) ]
      |> map (\ (img, url) -> customButton clicks.handle () img img img |> link url)
  in
    toDefText "share: " :: buttons |> intersperse (defaultSpacer) |> flow right

logo : Element
logo = image logoWidth logoHeight "imgs/snoo.png"

topBar : Int -> Element
topBar w =
  flow down [ defaultSpacer
            , flow right [ shareIcons, defaultSpacer ]
              |> container w (heightOf shareIcons) topRight
            , defaultSpacer ] |> color lightBlue

header : Int -> Element
header w =
  let
    title = flow right [
      toSizedText 32 "reddit time machine"
    , toText " .com" |> leftAligned . Text.color darkGray . Text.height 18
    ]
  in
    flow down [
      topBar w
    , title |> container w (heightOf title) midTop
    , logo |> container w (heightOf logo) midTop
    , defaultSpacer ] |> color bgColor