module Header (..) where

import Color exposing (lightBlue, darkGray)
import Graphics.Element exposing (image, link, flow, right, Element, down, container, heightOf, topRight, color, midTop, spacer, leftAligned)
import Graphics.Input exposing (customButton)
import List exposing (map, (::), intersperse)
import Signal
import Window
import Layout exposing (defaultSpacer, bgColor, toDefText, toSizedText, asGrid)
import Text


iconSize : Int
iconSize =
    32


logoHeight : Int
logoHeight =
    100


logoWidth : Int
logoWidth =
    120


clicks : Signal.Mailbox ()
clicks =
    Signal.mailbox ()


shareIcons : Element
shareIcons =
    let
        buttons =
            [ ( image iconSize iconSize "imgs/facebook.png", "https://www.facebook.com/sharer/sharer.php?u=http://www.editgym.com/reddit-time-machine/" )
            , ( image iconSize iconSize "imgs/twitter.png", "https://twitter.com/home?status=Check%20out%20what%20was%20up%20on%20reddit%20days/weeks/months%20ago%20at%20http://www.editgym.com/reddit-time-machine/" )
            , ( image iconSize iconSize "imgs/googleplus.png", "https://plus.google.com/share?url=http://www.editgym.com/reddit-time-machine/" )
            , ( image iconSize iconSize "imgs/linkedin.png", "https://www.linkedin.com/shareArticle?mini=true&url=http://www.editgym.com/reddit-time-machine/&title=Reddit%20Time%20Machine&summary=Check%20out%20what%20was%20up%20on%20reddit%20days/weeks/months%20ago.&source=" )
            , ( image iconSize iconSize "imgs/pinterest.png", "https://pinterest.com/pin/create/button/?url=&media=http://www.editgym.com/reddit-time-machine/&description=Check%20out%20what%20was%20up%20on%20reddit%20days/weeks/months%20ago." )
            , ( image iconSize iconSize "imgs/digg.png", "http://digg.com/submit?phase=2&url=http://www.editgym.com/reddit-time-machine/&title=Check%20out%20what%20was%20up%20on%20reddit%20days/weeks/months%20ago." )
            , ( image iconSize iconSize "imgs/stumbleupon.png", "http://www.stumbleupon.com/submit?url=http://www.editgym.com/reddit-time-machine/&title=Check%20out%20what%20was%20up%20on%20reddit%20days/weeks/months%20ago." )
            , ( image iconSize iconSize "imgs/tumblr.png", "http://www.tumblr.com/share/link?url=http://www.editgym.com/reddit-time-machine/" )
            , ( image iconSize iconSize "imgs/bufferapp.png", "https://bufferapp.com/add?url=http://www.editgym.com/reddit-time-machine/&text=Check%20out%20what%20was%20up%20on%20reddit%20days/weeks/months%20ago." )
            , ( image iconSize iconSize "imgs/email.png", "mailto:%20?subject=reddit time machine&body=Check%20out%20what%20was%20up%20on%20reddit%20days/weeks/months%20ago%20at%20http://www.editgym.com/reddit-time-machine/" )
            ]
                |> map (\( img, url ) -> img |> link url)
    in
        buttons |> asGrid 5 defaultSpacer


logo : Element
logo =
    image logoWidth logoHeight "imgs/snoo.png"


topBar : Int -> Element
topBar w =
    flow
        right
        [ spacer 1 90
        , flow
            down
            [ defaultSpacer
            , flow right [ shareIcons, defaultSpacer ]
                |> container w (heightOf shareIcons) topRight
            , defaultSpacer
            ]
        ]
        |> color lightBlue


header : Int -> Element
header w =
    let
        title = toSizedText 32 "reddit time machine"
    in
        flow
            down
            [ topBar w
            , title |> container w (heightOf title) midTop
            , logo |> container w (heightOf logo) midTop
            , defaultSpacer
            ]
            |> color bgColor
