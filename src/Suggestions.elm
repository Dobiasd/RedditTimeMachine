module Suggestions where

import Graphics.Input (Input, input, customButton)

import Sfw
import Nsfw

maxSuggestions : Int
maxSuggestions = 10

toIntDef : Int -> String -> Int
toIntDef def x = case String.toInt x of
  Just res -> res
  Nothing -> def

parseRawSubreddits : [String] -> [(String, Int)]
parseRawSubreddits =
  let
    parseRawSubreddit raw = String.split "," raw |>
      (\[a, b] -> (a, toIntDef 0 b))
  in
    map parseRawSubreddit

lowerFst : [(String, a)] -> [(String, a)]
lowerFst = map (\(s, i) -> (String.toLower s, i))

sfw : Subreddits
sfw = Sfw.sfwRaw |> parseRawSubreddits |> lowerFst

nsfw : Subreddits
nsfw = Nsfw.nsfwRaw |> parseRawSubreddits |> lowerFst

type Subreddits = [(String, Int)]

sfwCheck : Input Bool
sfwCheck = input True

nsfwCheck : Input Bool
nsfwCheck = input False

subreddits : Signal Subreddits
subreddits = (\sfwOn nsfwOn ->
  (if sfwOn then sfw else []) ++
  (if nsfwOn then nsfw else []) |> sortBy snd |> reverse)
  <~ sfwCheck.signal ~ nsfwCheck.signal

overflowIndicator : String
overflowIndicator = "..."

containsNotStartsWith : String -> String -> Bool
containsNotStartsWith a b = String.contains a b && not (String.startsWith a b)

genSuggestions : Subreddits -> String -> [String]
genSuggestions names query =
  let
    allStarting = filter (String.startsWith query . fst) names
    allContaining = filter (containsNotStartsWith query . fst) names
  in
    (allStarting ++ allContaining) |> map fst

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
    customButton suggestionClick.handle "s" elem elemHover elemClick

suggestionClick : Input String
suggestionClick = input ""