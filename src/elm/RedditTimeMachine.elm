module RedditTimeMachine where

import Graphics.Input (Input, input, dropDown, checkbox)
import Graphics.Input
import Graphics.Input.Field as Field
import Date
import Text
import String
import Window

import Layout(defaultSpacer, pageWidth, bgColor, toDefText, toSizedText)
import Skeleton(showPage)

import About(about)

import Suggestions(genSuggestions, showSuggestion, sfwCheck, nsfwCheck, maxSuggestions, overflowIndicator, Subreddits, subreddits, suggestionClick)

import Footer(currentPage, MainPage, AboutPage, Page)

-- To keep the query text input from swallowing characters
-- if the generation of suggestions is too slow for the typing speed,
-- the edit box is provided by the containing html page.
-- https://groups.google.com/forum/#!topic/elm-discuss/Lm-M-PPM2zQ
--
-- And there is no possibility to set the initial keyboard focus in elm.
-- https://groups.google.com/forum/#!topic/elm-discuss/d6B3D6suJNw
--
-- And the elm generated input field works badly in Android browser
-- because after redrawing the text is selected and thus you would
-- overwrite every character with the next one with normal typing.
port query : Signal String

port selected : Signal String
port selected = suggestionClick.signal

port showQuery : Signal Bool
port showQuery = (\x -> x == MainPage) <~ currentPage

data Criterion = Relevance | Hot | Top | Comments
data Interval = Days | Weeks | Months | Years

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
main = scene <~ (dropRepeats Window.width)
              ~ sfwCheck.signal
              ~ nsfwCheck.signal
              ~ subreddits
              ~ merge (String.toLower <~ query) suggestionClick.signal
              ~ criterion.signal
              ~ interval.signal
              ~ amount.signal
              ~ now
              ~ currentPage

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
    [ spacer pageWidth 1 |> color lightOrange
    , Text.link url (toText ("/r/" ++ name ++ " " ++ timeRangeStr)) |> centered
    ] |> intersperse defaultSpacer |> flow down

scene : Int -> Bool -> Bool -> Subreddits -> String -> Criterion -> Interval -> Int -> Time -> Page -> Element
scene w sfwOn nsfwOn names query criterion interval amount now page =
  case page of
    MainPage -> mainPage w sfwOn nsfwOn names query criterion interval amount now
    AboutPage -> about w

mainPage : Int -> Bool -> Bool -> Subreddits -> String -> Criterion -> Interval -> Int -> Time -> Element
mainPage w sfwOn nsfwOn names query criterion interval amount now =
  let
    labelSizeF = width 120
    rows = [ spacer 0 0 |> color bgColor
           , flow right [ toDefText "sfw:"       |> labelSizeF, checkbox sfwCheck.handle id sfwOn |> width 23 ]
           , flow right [ toDefText "nsfw:"      |> labelSizeF, checkbox nsfwCheck.handle id nsfwOn |> width 23 ]
           , defaultSpacer
           , flow right [ toDefText "sorted by:" |> labelSizeF, criterionDropDown ]
           , flow right [ toDefText "interval:"  |> labelSizeF, intervalDropDown ]
           , flow right [ toDefText "amount:"    |> labelSizeF, amountDropDown ]
           , spacer 10 40
           ]
    inputElem = intersperse defaultSpacer rows |> flow down
    bodyContent = flow right [ inputElem, defaultSpacer, defaultSpacer ]
    suggestions = genSuggestions names query
    suggestionElems = suggestions |> take maxSuggestions |> map (showSuggestion query)
    suggestionsElemRaw = suggestionElems
      ++ (if length suggestions > maxSuggestions
           then [toDefText overflowIndicator]
           else [])
        |> flow down
    suggestionsElem = suggestionsElemRaw |> container 200 (heightOf suggestionsElemRaw) topLeft

    resultElem = showResult query criterion interval amount now
    body = bodyContent
    bodyLeft = flow down [
                 spacer 1 30 |> color bgColor -- room for text input field
               , body ]

    contentRaw = flow down [
                   flow right [
                     bodyLeft
                   , suggestionsElem ] |> container w (heightOf bodyLeft) midTop
                 , resultElem |> container w (heightOf resultElem) midTop ]
    content = contentRaw |> container w (heightOf contentRaw) midTop
  in
    showPage w content