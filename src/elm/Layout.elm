module Layout where

spacerSize : Int
spacerSize = 8

defaultSpacer : Element
defaultSpacer = spacer spacerSize spacerSize

bgColor : Color
bgColor = lightGray

pageWidth : Int
pageWidth = 450

toSizedText : Float -> String -> Element
toSizedText s = leftAligned . Text.color black . Text.height s . toText

toSizedTextMod : (Text -> Text) -> Float -> String -> Element
toSizedTextMod f s =
  leftAligned . Text.color black . Text.height s . f . toText

toDefText : String -> Element
toDefText = toSizedText 20