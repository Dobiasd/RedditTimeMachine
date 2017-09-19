module Skeleton (..) where

import Color exposing (lightOrange)
import Graphics.Element exposing (heightOf, flow, down, spacer, color, container, midTop, Element)
import Layout exposing (defaultSpacer, pageWidth, bgColor, toDefText, toSizedText)
import List
import Footer exposing (footer)
import Header exposing (header)


showPage : Int -> Element -> Element
showPage w content =
    let
        headerElem = header w

        footerElem = footer w

        h = heightOf headerElem + heightOf content + heightOf footerElem + 18

        divider =
            flow
                down
                [ spacer 1 4 |> color bgColor
                , spacer w 3 |> color lightOrange
                ]
                |> container w 7 midTop
    in
        flow
            down
            [ headerElem
            , content
            , divider
            , footerElem
            ]
            |> color bgColor
            |> container w h midTop
