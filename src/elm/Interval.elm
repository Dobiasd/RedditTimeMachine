module Interval where

import List(map)
import Graphics.Element(Element)
import Graphics.Input (dropDown)
import Signal
import Time

type Interval = Days | Weeks | Months | Years

defaultInterval : Interval
defaultInterval = Months

intervalInput : Signal.Channel Interval
intervalInput = Signal.channel defaultInterval

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

intervalDropDown : Interval -> Element
intervalDropDown current =
  let
    f c = (showInterval c, c)
    all = [Days, Weeks, Months, Years]
  in
    dropDown (Signal.send intervalInput) <| map f all

intervalInMs : Interval -> Time.Time
intervalInMs i =
  case i of
    Days -> 1000*3600*24
    Weeks -> 1000*3600*24*7
    _ -> 0