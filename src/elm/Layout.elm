module Layout where

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
toSizedText s = leftAligned . Text.color black . Text.height s . toText

toSizedTextMod : (Text -> Text) -> Float -> String -> Element
toSizedTextMod f s =
  leftAligned . Text.color black . Text.height s . f . toText

toColText : Color -> String -> Element
toColText c =
  leftAligned . Text.color c . Text.height defTextSize . toText

defTextSize : Float
defTextSize = 20

toDefText : String -> Element
toDefText = toSizedText defTextSize