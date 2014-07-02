module DateTools where

import Date

import Interval(Interval, Days, Weeks, Months, Years)

type DateAsInts = {year: Int, month: Int, day: Int}

data DatePrec = PrecDay | PrecMonth | PrecYear

showDate : DatePrec -> Date.Date -> String
showDate prec d =
  let
    yearStr = show (Date.year d)
    monthStr = case prec of
      PrecYear -> "00"
      _ -> (monthToIntStr . Date.month) d
    dayStr = case prec of
      PrecDay -> show (Date.day d) |> String.padLeft 2 '0'
      _ -> "00"
  in
    intersperse "-" [yearStr, monthStr, dayStr] |> concat

monthToIntStr m =
  case m of
    Date.Jan -> "01"
    Date.Feb -> "02"
    Date.Mar -> "03"
    Date.Apr -> "04"
    Date.May -> "05"
    Date.Jun -> "06"
    Date.Jul -> "07"
    Date.Aug -> "08"
    Date.Sep -> "09"
    Date.Oct -> "10"
    Date.Nov -> "11"
    Date.Dec -> "12"

floorTimeToPrec : DatePrec -> Time -> Time
floorTimeToPrec prec t =
  [Date.read (showDate prec (Date.fromTime t))]
  |> justs |> head |> Date.toTime

-- todo plus one chosen time unit
ceilTimeToPrec : DatePrec -> Time -> Time
ceilTimeToPrec prec t = floorTimeToPrec prec t

ceilTimeForInterval : Interval -> Time -> Time
ceilTimeForInterval interval =
  case interval of
    Days -> ceilTimeToPrec PrecDay
    Weeks -> ceilTimeToPrec PrecDay
    Months -> ceilTimeToPrec PrecMonth
    Years -> ceilTimeToPrec PrecYear

showTimeRange : (Time, Time) -> String
showTimeRange (start, end) =
  showDate PrecDay (Date.fromTime start) ++ " to "
    ++ showDate PrecDay (Date.fromTime end)

{-
calcRanges : Criterion -> Interval -> Int -> Time
calcRanges rawName criterion interval amount today =
  let
    lastDay =
    nums = [0..amount]
-}

now : Signal Time
now = every minute