module Interval where

import List exposing (map)
import Graphics.Element exposing (Element)
import Graphics.Input exposing (dropDown)
import Signal
import Time

type Interval = Days | Weeks | Months | Years

defaultInterval : Interval
defaultInterval = Months

intervalInput : Signal.Mailbox Interval
intervalInput = Signal.mailbox defaultInterval

readInterval : String -> Interval
readInterval s = if s == "days" then Days
                 else if s == "weeks" then Weeks
                 else if s == "months" then Months
                 else if s == "years" then Years
                 else defaultInterval

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
    dropDown (Signal.message intervalInput.address) <| map f all

intervalInMs : Interval -> Time.Time
intervalInMs i =
  case i of
    Days -> 1000*3600*24
    Weeks -> 1000*3600*24*7
    _ -> 0