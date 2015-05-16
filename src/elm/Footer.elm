module Footer where

import Color exposing (gray)
import Graphics.Element exposing (color, flow, down, right, container
  , heightOf, midTop, Element)
import Graphics.Input exposing (customButton)
import Layout exposing (defaultSpacer, plainText)
import Signal

footer : Int -> Element
footer w =
  let
    main = plainText "Home" |> color gray
    about = plainText "About" |> color gray
    mainLink = customButton (Signal.message pageClick.address MainPage) main main main
    aboutLink = customButton (Signal.message pageClick.address AboutPage) about about about
    content = flow down [ defaultSpacer
                       , flow right [ mainLink
                                    , defaultSpacer
                                    , defaultSpacer
                                    , aboutLink ]
                       , defaultSpacer ]
  in
    content |> container w (heightOf content) midTop

pageClick : Signal.Mailbox Page
pageClick = Signal.mailbox MainPage

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