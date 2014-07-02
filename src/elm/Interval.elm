module Interval where

import Graphics.Input (Input, input, dropDown)

import String

defaultInterval = Weeks

data Interval = Days | Weeks | Months | Years

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

intervalDropDown : Element
intervalDropDown =
  let
    f c = (showInterval c, c)
  in
    dropDown intervalInput.handle <| map f [Days, Weeks, Months, Years]

intervalInMs : Interval -> Time
intervalInMs i =
  case i of
    Days -> 1000*3600*24
    Weeks -> 1000*3600*24*7
    _ -> 0