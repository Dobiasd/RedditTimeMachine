module Footer where

import Graphics.Input (Input, input, customButton)
import Layout (defaultSpacer)

footer : Int -> Element
footer w =
  let
    main = plainText "Home" |> color gray
    about = plainText "About" |> color gray
    mainLink = customButton pageClick.handle MainPage main main main
    aboutLink = customButton pageClick.handle AboutPage about about about
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