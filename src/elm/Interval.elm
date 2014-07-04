module Interval where

import Graphics.Input (Input, input, dropDown)

data Interval = Days | Weeks | Months | Years

defaultInterval : Interval
defaultInterval = Weeks

intervalInput : Input Interval
intervalInput = input defaultInterval

readInterval : String -> Interval
readInterval s = if | s == "days" -> Days
                    | s == "weeks" -> Weeks
                    | s == "months" -> Months
                    | s == "years" -> Years
                    | otherwise -> defaultInterval

showInterval : Interval -> String
showInterval c =
  case c of
    Days -> "days"
    Weeks -> "weeks"
    Months -> "months"
    Years -> "years"

-- todo if issue 670 is resolved, remove the parameter current again
intervalDropDown : Interval -> Element
intervalDropDown current =
  let
    f c = (showInterval c, c)
    all = [Days, Weeks, Months, Years] |> filter (\x -> x /= current)
  in
    dropDown intervalInput.handle <| map f (current :: all)

intervalInMs : Interval -> Time
intervalInMs i =
  case i of
    Days -> 1000*3600*24
    Weeks -> 1000*3600*24*7
    _ -> 0