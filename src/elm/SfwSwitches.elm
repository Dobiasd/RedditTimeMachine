module SfwSwitches where

import Graphics.Input (Input, input)

import Sfw
import Nsfw

toIntDef : Int -> String -> Int
toIntDef def x = case String.toInt x of
  Just res -> res
  Nothing -> def

parseRawSubreddits : [String] -> Subreddits
parseRawSubreddits =
  let
    parseRawSubreddit raw = String.split "," raw |>
      (\[a, b] -> (a, toIntDef 0 b))
  in
    map parseRawSubreddit

lowerFst : [(String, a)] -> [(String, a)]
lowerFst = map (\(s, i) -> (String.toLower s, i))

readBoolDef : Bool -> String -> Bool
readBoolDef def s = if | s == "false" -> False
                       | s == "true" -> True
                       | otherwise -> def

showBool : Bool -> String
showBool b = if b then "true" else "false"

sfwDefault : Bool
sfwDefault = True

nsfwDefault : Bool
nsfwDefault = False

sfwCheck : Input Bool
sfwCheck = input sfwDefault

nsfwCheck : Input Bool
nsfwCheck = input nsfwDefault

sfw : Subreddits
sfw = Sfw.sfwRaw |> parseRawSubreddits |> lowerFst

nsfw : Subreddits
nsfw = Nsfw.nsfwRaw |> parseRawSubreddits |> lowerFst

type Subreddits = [(String, Int)]

