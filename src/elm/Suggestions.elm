module Suggestions where

import Graphics.Input (Input, input, button, customButton)

maxSuggestions : Int
maxSuggestions = 10

toIntDef : Int -> String -> Int
toIntDef def x = case String.toInt x of
  Just res -> res
  Nothing -> def

type Subreddits = [(String, Int)]

sfwCheck : Input Bool
sfwCheck = input True

nsfwCheck : Input Bool
nsfwCheck = input False

overflowIndicator : String
overflowIndicator = "..."

containsNotStartsWith : String -> String -> Bool
containsNotStartsWith a b = String.contains a b && not (String.startsWith a b)

showSuggestion : String -> String -> Element
showSuggestion query s =
  let
    emptyQuery = String.isEmpty query
    idxs = if emptyQuery then [] else String.indexes query s
  in
    if emptyQuery || isEmpty idxs
      then showSuggPart id black s
      else showSuggestionNonEmptyQuery query s (head idxs)

showSuggPart : (Text -> Text) -> Color -> String -> Element
showSuggPart f col = centered . f . Text.color col . Text.height 14 . toText

showSuggestionNonEmptyQuery : String -> String -> Int -> Element
showSuggestionNonEmptyQuery query s idx =
  let
    queryLen = String.length query
    sLen = String.length s
    slc = String.slice
    (s1, s2, s3) =
      if idx == 0
        then ("", query, slc queryLen sLen s)
        else (slc 0 idx s, query, slc (idx + queryLen) sLen s)
    elem = flow right [ showSuggPart id black s1
                      , showSuggPart bold black s2
                      , showSuggPart id black s3]
    elemHover = elem |> color lightBlue
    elemClick = elem |> color lightGreen
  in
    customButton suggestionClick.handle s elem elemHover elemClick
    --button suggestionClick.handle s s

suggestionClick : Input String
suggestionClick = input ""