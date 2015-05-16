module Layout where

import Color exposing (Color, lightGray, black)
import Graphics.Element exposing (Element, spacer, flow, down, right
  , leftAligned)
import List exposing ((::))
import List
import Text

{-| splitEvery [1,2,3,4,5,6,7,8] === [[1,2,3],[4,5,6],[7,8]] -}
splitEvery : Int -> List a -> List (List a)
splitEvery n xs =
  if List.length xs > n
    then (List.take n xs) :: (List.drop n xs |> splitEvery n)
    else [xs]

asGrid : Int -> Element -> List Element -> Element
asGrid colCnt spacer =
  splitEvery colCnt
  >> List.map (List.intersperse spacer >> flow right)
  >> List.intersperse spacer
  >> flow down

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

plainText : String -> Element
plainText = Text.fromString >> leftAligned

pageWidth : Int
pageWidth = 450

toSizedText : Float -> String -> Element
toSizedText s =
  Text.fromString
  >> Text.height s
  >> Text.color black
  >> leftAligned

toSizedTextMod : (Text.Text -> Text.Text) -> Float -> String -> Element
toSizedTextMod f s =
  Text.fromString
  >> f
  >> Text.height s
  >> Text.color black
  >> leftAligned

toColText : Color -> String -> Element
toColText c =
  Text.fromString
  >> Text.height defTextSize
  >> Text.color c
  >> leftAligned

defTextSize : Float
defTextSize = 20

toDefText : String -> Element
toDefText = toSizedText defTextSize