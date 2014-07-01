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

toDefText : String -> Element
toDefText = toSizedText 20

divider : Element
divider = flow down [ spacer 1 4 |> color bgColor
                    , spacer pageWidth 3 |> color lightOrange ]