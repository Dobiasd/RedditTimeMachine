module DateTools where

import Date

import Interval(Interval, Days, Weeks, Months, Years)


-- (start, end)
type TimeSpan = (Time, Time)

type DateAsInts = {year: Int, month: Int, day: Int}
dateAsInts y m d = {year = y, month = m, day =d}

oneDay : Time
oneDay = 24*60*60*second

oneMinute : Time
oneMinute = 1*60*second

iterate : Int -> (a -> a) -> a -> [a]
iterate n f x = if n < 1 then [] else x :: iterate (n-1) f (f x)

lastNDays : Int -> DateAsInts -> [DateAsInts]
lastNDays n today = iterate n dateAsIntsMinusOneDay today

lastNDayStarts : Int -> Time -> [Time]
lastNDayStarts n now =
  let
    today = now |> timeToDateAsInts
  in
    lastNDays n today |> map dateAsIntsToTime

lastNDaySpans : Int -> Time -> [TimeSpan]
lastNDaySpans n now =
  let
    starts = lastNDayStarts n now
  in
    -- two times one minute buffer for leap seconds and stuff
    map (\x -> (x + oneMinute, x + oneDay - oneMinute)) starts

dateAsIntsMinusOneDay : DateAsInts -> DateAsInts
dateAsIntsMinusOneDay intDate =
  let
    d' = { intDate | day <- intDate.day - 1 }
    minusOneMonthWrongDay = dateAsIntsMinusOneMonth d'
  in
    if | d'.day < 1 ->
         { minusOneMonthWrongDay | day <- lastDayInMonth minusOneMonthWrongDay }
       | otherwise -> d'

lastDayInMonth : DateAsInts -> Int
lastDayInMonth {year, month} =
  if | month == 1 -> 31
     | month == 2 -> if year `mod` 4 == 0 then 29 else 28
     | month == 3 -> 31
     | month == 4 -> 30
     | month == 5 -> 31
     | month == 6 -> 30
     | month == 7 -> 31
     | month == 8 -> 31
     | month == 9 -> 30
     | month == 10 -> 31
     | month == 11 -> 30
     | month == 12 -> 31

dateAsIntsMinusOneMonth : DateAsInts -> DateAsInts
dateAsIntsMinusOneMonth ({month} as intDate) =
  let
    d' = { intDate | month <- intDate.month - 1 }
    minusOneYearWrongMonth = dateAsIntsMinusOneYear d'
  in
    if | d'.month < 1 -> { minusOneYearWrongMonth | month <- 12 }
       | otherwise -> d'

dateAsIntsMinusOneYear : DateAsInts -> DateAsInts
dateAsIntsMinusOneYear ({year} as intDate) =
  { intDate | year <- year - 1 }

dateToDateAsInts : Date.Date -> DateAsInts
dateToDateAsInts date =
  dateAsInts (Date.year date) (Date.month date |> monthToInt) (Date.day date)

timeToDateAsInts : Time -> DateAsInts
timeToDateAsInts = dateToDateAsInts . Date.fromTime

dateAsIntsToTime : DateAsInts -> Time
dateAsIntsToTime = Date.toTime . readDate . showDateAsInts

showDateAsInts : DateAsInts -> String
showDateAsInts intDate = 
  let
    pad = String.padLeft 2 '0'
    yearStr = show intDate.year
    monthStr = show intDate.month |> pad
    dayStr = show intDate.day |> pad
  in
    join "-" [yearStr, monthStr, dayStr]

readDate : String -> Date.Date
readDate s = [Date.read s] |> justs |> head

monthToInt m =
  case m of
    Date.Jan ->  1
    Date.Feb ->  2
    Date.Mar ->  3
    Date.Apr ->  4
    Date.May ->  5
    Date.Jun ->  6
    Date.Jul ->  7
    Date.Aug ->  8
    Date.Sep ->  9
    Date.Oct -> 10
    Date.Nov -> 11
    Date.Dec -> 12