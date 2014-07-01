module Footer where

import Graphics.Input (Input, input, customButton)
import Layout(defaultSpacer)

footer : Int -> Element
footer w =
  let
    mainElem = plainText "Home" |> color gray
    aboutElem = plainText "About" |> color gray
    mainLink = customButton pageClick.handle MainPage mainElem mainElem mainElem
    aboutLink = customButton pageClick.handle AboutPage aboutElem aboutElem aboutElem
    content = flow down [ defaultSpacer
                       , flow right [ mainLink
                                    , defaultSpacer
                                    , defaultSpacer
                                    , aboutLink ]
                       , defaultSpacer ]
  in
    content |> container w (heightOf content) midTop

pageClick : Input Page
pageClick = input MainPage

data Page = MainPage | AboutPage

currentPage : Signal Page
currentPage = pageClick.signal