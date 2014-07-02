module RedditTimeMachine where

import Graphics.Input (Input, input, dropDown, checkbox)
import Graphics.Input
import Graphics.Input.Field as Field
import Date
import Text
import String
import Window

import Debug

import Layout(defaultSpacer, pageWidth, bgColor, toDefText, toSizedText)
import Skeleton(showPage)

import About(about)

import Suggestions(genSuggestions, showSuggestion, maxSuggestions, overflowIndicator, Subreddits, subreddits, suggestionClick, toIntDef, sfwCheck, nsfwCheck, sfwDefault, nsfwDefault)

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

-- for static links with paramters in URL
port sfwInStr : Signal String
port nsfwInStr : Signal String
port sortedByInStr : Signal String
port intervalInStr : Signal String
port amountInStr : Signal String

readBoolDef : Bool -> String -> Bool
readBoolDef def s = if | s == "false" -> False
                       | s == "true" -> True
                       | otherwise -> def

showBool : Bool -> String
showBool b = if b then "true" else "false"

sfwOn : Signal Bool
sfwOn = merge (readBoolDef sfwDefault <~ sfwInStr) sfwCheck.signal

nsfwOn : Signal Bool
nsfwOn = merge (readBoolDef nsfwDefault <~ nsfwInStr) nsfwCheck.signal

port selected : Signal String
port selected = suggestionClick.signal

port showQuery : Signal Bool
port showQuery = (\x -> x == MainPage) <~ currentPage

data Criterion = Relevance | Hot | Top | Comments
data Interval = Days | Weeks | Months | Years

defaultCriterion = Top
defaultInterval = Weeks

criterionInput : Input Criterion
criterionInput = input defaultCriterion

criterion : Signal Criterion
criterion = merge (readCriterion <~ sortedByInStr) criterionInput.signal

interval : Signal Interval
interval = merge (readInterval <~ intervalInStr) intervalInput.signal

amount : Signal Amount
amount = merge (readAmount <~ amountInStr) amountInput.signal

readCriterion : String -> Criterion
readCriterion s =
    if | s == "relevance" -> Relevance
       | s == "hot" -> Hot
       | s == "top" -> Top
       | s == "comments" -> Comments
       | otherwise -> defaultCriterion

showCriterion : Criterion -> String
showCriterion c =
  case c of
    Relevance -> "relevance"
    Hot -> "hot"
    Top -> "top"
    Comments -> "comments"

criterionDropDown : Element
criterionDropDown =
  let
    f c = (showCriterion c, c)
  in
    dropDown criterionInput.handle <| map f [Top, Hot, Comments, Relevance]

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

defaultAmount : Int
defaultAmount = 10

type Amount = Int

amountInput : Input Amount
amountInput = input defaultAmount

readAmount : String -> Amount
readAmount = toIntDef defaultAmount

showAmount : Amount -> String
showAmount = show

amountDropDown : Element
amountDropDown =
  let
    f c = (showAmount c, c)
  in
    dropDown amountInput.handle <| map f [10, 20, 50, 100, 200, 500, 1000]

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
              ~ sfwOn 
              ~ nsfwOn
              ~ subreddits
              ~ merge (String.toLower <~ query) suggestionClick.signal
              ~ criterion
              ~ interval
              ~ amount
              ~ now
              ~ currentPage

genLink : String -> Criterion -> Time -> Time -> String
genLink name criterion start end =
  "http://www.reddit.com/r/" ++ name ++ "/search?q=timestamp:" ++ show (start/1000) ++ ".." ++ show (end/1000) ++ "&sort=" ++ showCriterion criterion ++ "&restrict_sr=on&syntax=cloudsearch"

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

genStaticLink : String -> Bool -> Bool -> Criterion -> Interval -> Int -> String
genStaticLink subreddit sfwOn nsfwOn criterion interval amount =
  let
    base = "http://www.reddittimemachine.com/index.html"
    subredditOption = "?subreddit=" ++ subreddit
    sfwOption = "&sfw=" ++ showBool sfwOn
    nsfwOption = "&nsfw=" ++ showBool nsfwOn
    sortedByOption = "&sortedby=" ++ showCriterion criterion
    intervalOption = "&interval=" ++ showInterval interval
    amountOption = "&amount=" ++ showAmount amount
  in
    base ++ subredditOption ++ sfwOption ++ nsfwOption ++
            sortedByOption ++ intervalOption ++ amountOption

avoidEmptySubredditName : String -> String
avoidEmptySubredditName s = if String.isEmpty s then "all" else s

showStaticLink : String -> Bool -> Bool -> Criterion -> Interval -> Int -> Element
showStaticLink subredditRaw sfwOn nsfwOn criterion interval amount =
  let
    subreddit = avoidEmptySubredditName subredditRaw
    url = genStaticLink subreddit sfwOn nsfwOn criterion interval amount
  in
    flow down [ toDefText "static link to this list:"
                 -- using link here results in:
                 -- "TypeError: e.lastNode is undefined"
               , toDefText url -- |> link url
               ]

showResult : String -> Bool -> Bool -> Criterion -> Interval -> Int -> Time -> Element
showResult rawName sfwOn nsfwOn criterion interval amount now =
  let
    today = floorTimeToPrec PrecDay now
    name = avoidEmptySubredditName rawName
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

    resultElem = showResult query sfwOn nsfwOn criterion interval amount now
    staticLinkElem = showStaticLink query sfwOn nsfwOn criterion interval amount
    body = bodyContent
    bodyLeft = flow down [
                 spacer 1 30 |> color bgColor -- room for text input field
               , body ]
    centerHorizontally : Element -> Element
    centerHorizontally elem = container w (heightOf elem) midTop elem
    contentRaw = flow down [
                   flow right [
                     bodyLeft
                   , suggestionsElem ] |> centerHorizontally
                 , resultElem |> centerHorizontally
                 , staticLinkElem |> centerHorizontally ]
    content = contentRaw |> centerHorizontally
  in
    showPage w content