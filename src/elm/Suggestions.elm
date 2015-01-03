module Suggestions where

import SfwSwitches(Subreddit, Subreddits)
import Layout(toSizedText)

import Color (darkGray, white, black, Color, lightBlue, lightGreen)
import Graphics.Element (Element, spacer, color, flow, right)
import Graphics.Input (button, customButton)
import List (filter, isEmpty, head)
import Regex
import Signal
import String
import Text

maxSuggestions : Int
maxSuggestions = 10

overflowIndicator : String
overflowIndicator = "..."

useRegexDefault : Bool
useRegexDefault = False

useRegexCheck : Signal.Channel Bool
useRegexCheck = Signal.channel useRegexDefault

genSuggestions : Bool -> Subreddits -> String -> Subreddits
genSuggestions useRegex =
  if useRegex then genSuggestionsRegex else genSuggestionsString

genSuggestionsRegex : Subreddits -> String -> Subreddits
genSuggestionsRegex names query =
  let
    ex = query |> Regex.regex
  in
    filter (fst >> Regex.contains ex) names

genSuggestionsString : Subreddits -> String -> Subreddits
genSuggestionsString srs query =
  let
    allStarting = filter (fst >> String.startsWith query) srs
    allContaining = filter (fst >> containsNotStartsWith query) srs
  in
    allStarting ++ allContaining

containsNotStartsWith : String -> String -> Bool
containsNotStartsWith a b = String.contains a b && not (String.startsWith a b)

subscriberCntToStr : Int -> String
subscriberCntToStr i =
  if | i > 1000000000 -> toString (i // 1000000000) ++ "G"
     | i >    1000000 -> toString (i //    1000000) ++ "M"
     | i >       1000 -> toString (i //       1000) ++ "k"
     | otherwise      -> toString i

showSubscriberCnt : Int -> Element
showSubscriberCnt i = "  " ++ subscriberCntToStr i |> Text.fromString
  |> Text.height 12 |> Text.color darkGray |> Text.leftAligned

showSuggestion : String -> Subreddit -> Element
showSuggestion query ((s, i) as sr) =
  let
    emptyQuery = String.isEmpty query
    idxs = if emptyQuery then [] else String.indexes query s
    dummy = spacer 0 0 |> color white
  in
    if emptyQuery || isEmpty idxs
      then suggButton (flow right [showSuggPart identity black s
                                 , showSubscriberCnt i]) s
      else showSuggestionNonEmptyQuery query sr (head idxs)

showSuggPart : (Text.Text -> Text.Text) -> Color -> String -> Element
showSuggPart f col =
  Text.fromString >> Text.height 14 >> Text.color col >> f >> Text.centered

suggButton : Element -> String -> Element
suggButton elem s =
  let
    elemHover = elem |> color lightBlue
    elemClick = elem |> color lightGreen
  in
    customButton (Signal.send suggestionClick s) elem elemHover elemClick

showSuggestionNonEmptyQuery : String -> Subreddit -> Int -> Element
showSuggestionNonEmptyQuery query (s, i) idx =
  let
    queryLen = String.length query
    sLen = String.length s
    slc = String.slice
    (s1, s2, s3) =
      if idx == 0
        then ("", query, slc queryLen sLen s)
        else (slc 0 idx s, query, slc (idx + queryLen) sLen s)
    elem = flow right [ showSuggPart identity black s1
                      , showSuggPart Text.bold black s2
                      , showSuggPart identity black s3
                      , showSubscriberCnt i]
  in suggButton elem s

suggestionClick : Signal.Channel String
suggestionClick = Signal.channel ""