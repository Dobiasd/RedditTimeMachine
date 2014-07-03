module Suggestions where

import SfwSwitches(Subreddits)

import Graphics.Input (Input, input, button, customButton)

maxSuggestions : Int
maxSuggestions = 10

overflowIndicator : String
overflowIndicator = "..."

useRegexDefault : Bool
useRegexDefault = False

useRegexCheck : Input Bool
useRegexCheck = input useRegexDefault

genSuggestions : Subreddits -> String -> Bool -> [String]
genSuggestions names query regexOn =
  let
    allStarting = filter (String.startsWith query . fst) names
    allContaining = filter (containsNotStartsWith query . fst) names
  in
    (allStarting ++ allContaining) |> map fst

containsNotStartsWith : String -> String -> Bool
containsNotStartsWith a b = String.contains a b && not (String.startsWith a b)

showSuggestion : String -> String -> Element
showSuggestion query s =
  let
    emptyQuery = String.isEmpty query
    idxs = if emptyQuery then [] else String.indexes query s
    dummy = spacer 0 0 |> color white
  in
    if emptyQuery || isEmpty idxs
      -- todo: remove dummies after this is fixed:
      -- https://github.com/elm-lang/Elm/issues/672
      then suggButton (flow right [showSuggPart id black s, dummy, dummy]) s
      else showSuggestionNonEmptyQuery query s (head idxs)

showSuggPart : (Text -> Text) -> Color -> String -> Element
showSuggPart f col = centered . f . Text.color col . Text.height 14 . toText

suggButton : Element -> String -> Element
suggButton elem s =
  let
    elemHover = elem |> color lightBlue
    elemClick = elem |> color lightGreen
  in
    customButton suggestionClick.handle s elem elemHover elemClick
    --button suggestionClick.handle s s

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
  in suggButton elem s

suggestionClick : Input String
suggestionClick = input ""