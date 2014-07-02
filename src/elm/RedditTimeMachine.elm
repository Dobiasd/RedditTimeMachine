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

import Suggestions(genSuggestions, showSuggestion, maxSuggestions, overflowIndicator, Subreddits, subreddits, suggestionClick, toIntDef, sfwCheck, nsfwCheck)

import Footer(currentPage, MainPage, AboutPage, Page)

import DateTools(floorTimeToPrec, PrecDay, showTimeRange, now)
import Amount(showAmount, amountDropDown, Amount, amount, readAmount, amountInput)
import SfwSwitches(toIntDef, sfwCheck, nsfwCheck, Subreddits, showBool, sfwOn, nsfwOn, subreddits, sfw, nsfw, readBoolDef, sfwDefault, nsfwDefault)
import Criterion(Criterion, showCriterion, criterionDropDown, criterion, readCriterion, criterionInput)
import Interval(showInterval, Days, Weeks, Months, Interval, interval, intervalDropDown, readInterval, intervalInput)

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

port selected : Signal String
port selected = suggestionClick.signal

port showQuery : Signal Bool
port showQuery = (\x -> x == MainPage) <~ currentPage

interval : Signal Interval
interval = merge (readInterval <~ intervalInStr) intervalInput.signal

criterion : Signal Criterion
criterion = merge (readCriterion <~ sortedByInStr) criterionInput.signal

amount : Signal Amount
amount = merge (readAmount <~ amountInStr) amountInput.signal

sfwOn : Signal Bool
sfwOn = merge (readBoolDef sfwDefault <~ sfwInStr) sfwCheck.signal

nsfwOn : Signal Bool
nsfwOn = merge (readBoolDef nsfwDefault <~ nsfwInStr) nsfwCheck.signal

subreddits : Signal Subreddits
subreddits = (\sfwOn nsfwOn ->
  (if sfwOn then sfw else []) ++
  (if nsfwOn then nsfw else []) |> sortBy snd |> reverse)
  <~ sfwCheck.signal ~ nsfwCheck.signal




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