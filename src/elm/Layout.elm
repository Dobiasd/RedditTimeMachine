module Layout where

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
toSizedText s = toText >> Text.height s >> Text.color black >> leftAligned

toSizedTextMod : (Text -> Text) -> Float -> String -> Element
toSizedTextMod f s =
  toText >> f >> Text.height s >> Text.color black >> leftAligned

toColText : Color -> String -> Element
toColText c =
  toText >> Text.height defTextSize >> Text.color c >> leftAligned

defTextSize : Float
defTextSize = 20

toDefText : String -> Element
toDefText = toSizedText defTextSize