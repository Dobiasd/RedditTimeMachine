module Skeleton where

import Layout(defaultSpacer, pageWidth, bgColor, toDefText, toSizedText, showPage, divider)
import Footer(footer)
import Header(header)

showPage : Int -> Element -> Element
showPage w content =
  let
    headerElem = header w
    footerElem = footer w
    h = heightOf headerElem + heightOf content + heightOf footerElem + 6
  in
    flow down [
      headerElem
    , content
    , divider |> container w (heightOf divider) midTop
    , footerElem
    ] |> color bgColor |> container w h midTop