module RedditTimeMachine where

import Graphics.Input (Input, input, dropDown, checkbox, customButton)
import Graphics.Input
import Graphics.Input.Field as Field
import Date
import Text
import String
import Window

import Layout(defaultSpacer, pageWidth, bgColor)

import Suggestions(genSuggestions, showSuggestion, sfwCheck, nsfwCheck, maxSuggestions, overflowIndicator, Subreddits, subreddits, suggestionClick)

port query : Signal String

port title : Signal String
port title = genTitle <~ query

port selected : Signal String
port selected = suggestionClick.signal

data Criterion = Relevance | Hot | Top | Comments
data Interval = Days | Weeks | Months | Years

genTitle : String -> String
genTitle name =
  let
    addOn = if String.isEmpty name then "" else " -> " ++ name
  in
    "Reddit Time Machine - check out what was hot on reddit days/weeks/months ago" ++ addOn

criterion : Input Criterion
criterion = input Top

criterionStr : Criterion -> String
criterionStr c =
  case c of
    Relevance -> "relevance"
    Hot -> "hot"
    Top -> "top"
    Comments -> "comments"

criterionDropDown : Element
criterionDropDown =
  let
    f c = (criterionStr c, c)
  in
    dropDown criterion.handle <| map f [Top, Hot, Comments, Relevance]

interval : Input Interval
interval = input Weeks

intervalDropDown : Element
intervalDropDown =
    dropDown interval.handle
      [ ("days"  , Days)
      , ("weeks" , Weeks)
      , ("months", Months)
      , ("years" , Years)
      ]

amount : Input Int
amount = input 10

amountDropDown : Element
amountDropDown =
    let
      asPair i = (show i, i)
      nums = [10, 20, 50, 100, 200, 500, 1000]
    in
      dropDown amount.handle <| map asPair nums

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

showTimeRange : (Time, Time) -> String
showTimeRange (start, end) =
  showDate PrecDay (Date.fromTime start) ++ " to " ++ showDate PrecDay (Date.fromTime end)

now : Signal Time
now = every minute

main : Signal Element
main = scene <~ Window.dimensions
              ~ sfwCheck.signal
              ~ nsfwCheck.signal
              ~ subreddits
              ~ merge (String.toLower <~ query) suggestionClick.signal
              ~ criterion.signal
              ~ interval.signal
              ~ amount.signal
              ~ now

genLink : String -> Criterion -> Time -> Time -> String
genLink name criterion start end =
  "http://www.reddit.com/r/" ++ name ++ "/search?q=timestamp:" ++ show (start/1000) ++ ".." ++ show (end/1000) ++ "&sort=" ++ criterionStr criterion ++ "&restrict_sr=on&syntax=cloudsearch"

intervalInMs : Interval -> Time
intervalInMs i =
  case i of
    Days -> 1000*3600*24
    Weeks -> 1000*3600*24*7
    _ -> 0

{-
calcRanges : Criterion -> Interval -> Int -> Time
calcRanges rawName criterion interval amount today =
  let
    lastDay =
    nums = [0..amount]
-}

showResult : String -> Criterion -> Interval -> Int -> Time -> Element
showResult rawName criterion interval amount now =
  let
    today = floorTimeToPrec PrecDay now
    name = if String.isEmpty rawName then "all" else rawName
    start = today - 1000*3600*24*10
    end = today - 1000*3600*24*9
    url = genLink name criterion start end
    timeRangeStr = showTimeRange (start, end)
  in
    flow down [
      spacer pageWidth 3 |> color lightOrange
    , Text.link url (toText ("/r/" ++ name ++ " " ++ timeRangeStr)) |> centered
    ]

scene : (Int, Int) -> Bool -> Bool -> Subreddits -> String -> Criterion -> Interval -> Int -> Time -> Element
scene (w,h) sfwOn nsfwOn names query criterion interval amount now =
  let
    labelSizeF = width 100
    rows = [ flow right [ plainText "sfw:"       |> labelSizeF, checkbox sfwCheck.handle id sfwOn |> width 23 ]
           , flow right [ plainText "nsfw:"      |> labelSizeF, checkbox nsfwCheck.handle id nsfwOn |> width 23 ]
           , defaultSpacer
           , flow right [ plainText "sorted by:" |> labelSizeF, criterionDropDown ]
           , flow right [ plainText "interval:"  |> labelSizeF, intervalDropDown ]
           , flow right [ plainText "amount:"    |> labelSizeF, amountDropDown ]
           , spacer 10 60
           ]
    inputElem = intersperse (defaultSpacer) rows |> flow down
    bodyContent = flow down [
                    flow right [ inputElem, defaultSpacer, defaultSpacer, suggestionsElem ]
                  , showResult query criterion interval amount now
                  ]
    suggestions = genSuggestions names query
    suggestionElems = suggestions |> take maxSuggestions |> map (showSuggestion query)
    suggestionsElem = suggestionElems
      ++ (if length suggestions > maxSuggestions
           then [plainText overflowIndicator]
           else [])
        |> flow down

    body = container pageWidth (heightOf bodyContent) midLeft bodyContent |> container w (heightOf bodyContent) midTop
    page = body |> color bgColor
  in
    page |> container w (heightOf page) midTop