module DateTools where

import Date
import Interval(Interval)

import List
import String

-- (start, end)
type TimeSpan = (Time, Time)

type DateAsInts = {year: Int, month: Int, day: Int}
dateAsInts y m d = {year = y, month = m, day =d}

oneDay : Time
oneDay = 24*60*60*second

oneWeek : Time
oneWeek = 7 * oneDay

iterate : Int -> (a -> a) -> a -> [a]
iterate n f x = if n < 1 then [] else x :: iterate (n-1) f (f x)

applyNTimes : Int -> (a -> a) -> a -> a
applyNTimes n f x =
  if | n == 0 -> x
     | otherwise -> iterate (n + 1) f x |> last

-- days

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
    map (\x -> (x, x + oneDay)) starts

-- weeks

lastNWeeks : Int -> DateAsInts -> [DateAsInts]
lastNWeeks n today = iterate n dateAsIntsMinusOneWeek today

floorWeek : DateAsInts -> DateAsInts
floorWeek intDate =
  let
    weekday = intDate |> showDateAsInts |> readDate |> Date.dayOfWeek
    n : Int
    n = case weekday of
          Date.Mon -> 0
          Date.Tue -> 1
          Date.Wed -> 2
          Date.Thu -> 3
          Date.Fri -> 4
          Date.Sat -> 5
          Date.Sun -> 6
  in
    applyNTimes n dateAsIntsMinusOneDay intDate

lastNWeekStarts : Int -> Time -> [Time]
lastNWeekStarts n now =
  let
    today = now |> timeToDateAsInts
    lastMonday = floorWeek today
  in
    lastNWeeks n lastMonday |> map dateAsIntsToTime

lastNWeekSpans : Int -> Time -> [TimeSpan]
lastNWeekSpans n now =
  let
    starts = lastNWeekStarts n now
  in
    map (\x -> (x, x + oneWeek)) starts

-- months

lastNMonthsSpans : Int -> Time -> [TimeSpan]
lastNMonthsSpans n now =
  let
    starts = now |> timeToDateAsInts
                 |> floorMonth
                 |> iterate n dateAsIntsMinusOneMonth
  in
    map (\x -> (dateAsIntsToTime x, dateAsIntsToTime (ceilMonth x) + oneDay)) starts

ceilMonth : DateAsInts -> DateAsInts
ceilMonth ({day} as intDate) = { intDate | day <- lastDayInMonth intDate }

floorMonth : DateAsInts -> DateAsInts
floorMonth ({day} as intDate) = { intDate | day <- 1 }

-- years

lastNYearsSpans : Int -> Time -> [TimeSpan]
lastNYearsSpans n now =
  let
    starts = now |> timeToDateAsInts
                 |> floorYear
                 |> iterate n dateAsIntsMinusOneYear
  in
    map (\x -> (dateAsIntsToTime x, dateAsIntsToTime (ceilYear x) + oneDay)) starts

ceilYear : DateAsInts -> DateAsInts
ceilYear ({day, month} as intDate) =
  { intDate | day <- lastDayInMonth intDate
            , month <- 12 }

floorYear : DateAsInts -> DateAsInts
floorYear ({day, month} as intDate) =
  { intDate | day <- 1
            , month <- 1 }

--

dateAsIntsMinusOneDay : DateAsInts -> DateAsInts
dateAsIntsMinusOneDay intDate =
  let
    d' = { intDate | day <- intDate.day - 1 }
    minusOneMonthWrongDay = dateAsIntsMinusOneMonth d'
  in
    if | d'.day < 1 ->
         { minusOneMonthWrongDay | day <- lastDayInMonth minusOneMonthWrongDay }
       | otherwise -> d'

dateAsIntsMinusOneWeek : DateAsInts -> DateAsInts
dateAsIntsMinusOneWeek = applyNTimes 7 dateAsIntsMinusOneDay

lastDayInMonth : DateAsInts -> Int
lastDayInMonth {year, month} =
  if | month == 1 -> 31
     | month == 2 -> if year % 4 == 0 then 29 else 28
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
timeToDateAsInts = Date.fromTime >> dateToDateAsInts

dateAsIntsToTime : DateAsInts -> Time
dateAsIntsToTime = showDateAsInts >> readDate >> Date.toTime

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
readDate s = [Date.read s] |> List.filterMap identity |> head

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