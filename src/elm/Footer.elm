module Footer where

import Color(gray)
import Graphics.Element(color, flow, down, right, container, heightOf, midTop
  , Element)
import Graphics.Input (customButton)
import Layout (defaultSpacer)
import Signal
import Text(plainText)

footer : Int -> Element
footer w =
  let
    main = plainText "Home" |> color gray
    about = plainText "About" |> color gray
    mainLink = customButton (Signal.send pageClick MainPage) main main main
    aboutLink = customButton (Signal.send pageClick AboutPage) about about about
    content = flow down [ defaultSpacer
                       , flow right [ mainLink
                                    , defaultSpacer
                                    , defaultSpacer
                                    , aboutLink ]
                       , defaultSpacer ]
  in
    content |> container w (heightOf content) midTop

pageClick : Signal.Channel Page
pageClick = Signal.channel MainPage

defaultPage : Page
defaultPage = MainPage

readPage : String -> Page
readPage s = if | s == "home" -> MainPage
                | s == "about" -> AboutPage
                | otherwise -> MainPage

showPageName : Page -> String
showPageName p =
  case p of
    MainPage -> "home"
    AboutPage -> "about"

type Page = MainPage | AboutPage