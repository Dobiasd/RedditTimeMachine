module Skeleton where

import Layout (defaultSpacer, pageWidth, bgColor, toDefText, toSizedText)
import Footer (footer)
import Header (header)

showPage : Int -> Element -> Element
showPage w content =
  let
    headerElem = header w
    footerElem = footer w
    h = heightOf headerElem + heightOf content + heightOf footerElem + 6
    divider = flow down [ spacer 1 4 |> color bgColor
                        , spacer w 3 |> color lightOrange ]
                        |> container w 7 midTop
  in
    flow down [
      headerElem
    , content
    , divider
    , footerElem
    ] |> color bgColor |> container w h midTop