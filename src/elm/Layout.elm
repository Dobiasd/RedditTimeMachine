module Layout where

import Color(Color, lightGray, black)
import Graphics.Element(Element, spacer)
import Text

spacerSize : Int
spacerSize = 8

defaultSpacer : Element
defaultSpacer = spacer spacerSize spacerSize

doubleDefSpacer : Element
doubleDefSpacer = spacer ( 2 * spacerSize) (2 * spacerSize)

quadDefSpacer : Element
quadDefSpacer = spacer ( 4 * spacerSize) (4 * spacerSize)

bgColor : Color
bgColor = lightGray

pageWidth : Int
pageWidth = 450

toSizedText : Float -> String -> Element
toSizedText s =
  Text.fromString
  >> Text.height s
  >> Text.color black
  >> Text.leftAligned

toSizedTextMod : (Text.Text -> Text.Text) -> Float -> String -> Element
toSizedTextMod f s =
  Text.fromString
  >> f
  >> Text.height s
  >> Text.color black
  >> Text.leftAligned

toColText : Color -> String -> Element
toColText c =
  Text.fromString
  >> Text.height defTextSize
  >> Text.color c
  >> Text.leftAligned

defTextSize : Float
defTextSize = 20

toDefText : String -> Element
toDefText = toSizedText defTextSize