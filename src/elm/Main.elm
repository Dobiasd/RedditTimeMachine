module Main where

import Graphics.Input (Input, input, dropDown, checkbox)
import Graphics.Input
import Graphics.Input.Field as Field
import Date
import Text
import String
import Window

import Layout (defaultSpacer, pageWidth, bgColor, toDefText, toSizedText
             , toSizedTextMod, doubleDefSpacer, quadDefSpacer)
import Skeleton (showPage)
import About (about)
import Suggestions (genSuggestions, showSuggestion, maxSuggestions
                  , overflowIndicator, Subreddits, subreddits, suggestionClick
                  , toIntDef, useRegexCheck, useRegexDefault)
import Footer (currentPage, MainPage, AboutPage, Page)
import DateTools (lastNDaySpans, showDateAsInts, timeToDateAsInts
                , lastNWeekSpans, lastNMonthsSpans, lastNYearsSpans)
import Amount (showAmount, amountDropDown, Amount, amount, readAmount
             , amountInput)
import SfwSwitches (toIntDef, sfwCheck, nsfwCheck, Subreddits, showBool, sfwOn
                  , nsfwOn, subreddits, sfw, nsfw, readBoolDef, sfwDefault
                  , nsfwDefault)
import Criterion (Criterion, showCriterion, criterionDropDown, criterion
                , readCriterion, criterionInput)
import Interval (showInterval, Days, Weeks, Months, Years, Interval, interval
               , intervalDropDown, readInterval, intervalInput)

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

port timezoneOffsetInMinutes : Signal Int

-- for static links with paramters in URL
port useRegexInStr : Signal String
port sfwInStr : Signal String
port nsfwInStr : Signal String
port sortedByInStr : Signal String
port intervalInStr : Signal String
port amountInStr : Signal String

port staticLinkOut : Signal String
port staticLinkOut = genStaticLink <~ query ~ useRegex ~ sfwOn ~ nsfwOn ~ criterion ~ interval ~ amount

port selected : Signal String
port selected = suggestionClick.signal

port showQuery : Signal Bool
port showQuery = (\x -> x == MainPage) <~ currentPage

now : Signal Time
now = every minute

timezoneOffset : Signal Time
timezoneOffset = (\x -> toFloat x * minute)
                   <~ (dropRepeats timezoneOffsetInMinutes)

interval : Signal Interval
interval = merge (readInterval <~ intervalInStr) intervalInput.signal

criterion : Signal Criterion
criterion = merge (readCriterion <~ sortedByInStr) criterionInput.signal

amount : Signal Amount
amount = merge (readAmount <~ amountInStr) amountInput.signal

useRegex : Signal Bool
useRegex = merge (readBoolDef useRegexDefault <~ useRegexInStr)
                 useRegexCheck.signal

sfwOn : Signal Bool
sfwOn = merge (readBoolDef sfwDefault <~ sfwInStr) sfwCheck.signal

nsfwOn : Signal Bool
nsfwOn = merge (readBoolDef nsfwDefault <~ nsfwInStr) nsfwCheck.signal

subreddits : Signal Subreddits
subreddits = (\sfwOn nsfwOn ->
  (if sfwOn then sfw else []) ++
  (if nsfwOn then nsfw else []) |> sortBy snd |> reverse)
  <~ sfwOn ~ nsfwOn

-- todo: outfactor search options
main : Signal Element
main = scene <~ (dropRepeats Window.width)
              ~ useRegex
              ~ sfwOn
              ~ nsfwOn
              ~ subreddits
              ~ merge (String.toLower <~ query) suggestionClick.signal
              ~ criterion
              ~ interval
              ~ amount
              ~ now
              ~ timezoneOffset
              ~ currentPage

genLink : String -> Criterion -> (Time, Time) -> String
genLink name criterion (start, end) =
  staticLink ("http://www.reddit.com/r/" ++ name ++ "/search")
             [ ("q", "timestamp:" ++ show (start/second) ++ ".."
                                  ++ show (end/second))
             , ("sort", showCriterion criterion)
             , ("restrict_sr", "on")
             , ("syntax", "cloudsearch") ]

staticLink : String -> [(String, String)] -> String
staticLink base parameters =
  let
    addon = map (\(name, value) -> name ++ "=" ++ value) parameters
              |> join "&"
  in
    base ++ (if String.isEmpty addon then "" else "?" ++ addon)

genStaticLink : String -> Bool -> Bool -> Bool -> Criterion -> Interval
             -> Int -> String
genStaticLink query useRegex sfwOn nsfwOn criterion interval amount =
  staticLink ""
    [ ("query", query)
    , ("useregex", showBool useRegex)
    , ("sfw", showBool sfwOn)
    , ("nsfw", showBool nsfwOn)
    , ("sortedby", showCriterion criterion)
    , ("interval", showInterval interval)
    , ("amount", showAmount amount) ]

notEmptyOr : String -> String -> String
notEmptyOr def s = if String.isEmpty s then def else s

avoidEmptySubredditName : String -> String
avoidEmptySubredditName = notEmptyOr "all"

showTimeSpan : (String -> String) -> Time -> (Time, Time) -> String
showTimeSpan transF timezoneOffset (start, end) =
  let
    showTimeAsDate = showDateAsInts
                   . timeToDateAsInts
                   . (\x -> x + timezoneOffset)
    -- aim at middle of day
    startStr = start + 12 * hour |> showTimeAsDate |> transF
    endStr = end - 12 * hour |> showTimeAsDate |> transF
  in
    startStr ++ if endStr /= startStr then " - " ++ endStr else ""

showResult : Int -> String -> Bool -> Bool -> Criterion -> Interval -> Int
          -> Time -> Time -> Element
showResult w rawName sfwOn nsfwOn criterion interval amount now
           timezoneOffset =
  let
    name = avoidEmptySubredditName rawName
    (lastNFunc, transF) = case interval of
      Days -> (lastNDaySpans, id)
      Weeks -> (lastNWeekSpans, id)
      Months -> (lastNMonthsSpans, String.dropRight 3)
      Years -> (lastNYearsSpans, String.dropRight 6)
    validTime x = x > 1114905600*second - 12*60*60*second -- 2005-05-01 minus 12 hours
    spans = lastNFunc amount now |> filter (validTime . fst)
    urls = map (genLink name criterion) spans
    texts = map (showTimeSpan transF timezoneOffset) spans
    spanCnt = length spans
    textSize = if | spanCnt > 113 -> 16
                  | spanCnt >  93 -> 18
                  | spanCnt >  33 -> 20
                  | spanCnt >  13 -> 22
                  | otherwise     -> 24
  in
    -- todo: use links when this is solved:
    -- https://github.com/elm-lang/Elm/issues/671
    zipWith (\t url -> toSizedText textSize t |> link url) texts urls
            |> asColumns w

group : Int -> [a] -> [[a]]
group n l = case l of
  [] -> []
  l -> if | n > 0 -> (take n l) :: (group n (drop n l))
          | otherwise -> []

asColumns : Int -> [Element] -> Element
asColumns w elems =
  let
    maxW = map widthOf elems |> maximum
    colCnt = w `div` (maxW + widthOf quadDefSpacer) - 1
    rowCnt = length elems `div` colCnt + 1
    rows = group rowCnt elems
  in
    map (flow down) rows |> intersperse quadDefSpacer |> flow right

scene : Int -> Bool -> Bool -> Bool -> Subreddits -> String -> Criterion
     -> Interval -> Int -> Time -> Time -> Page -> Element
scene w regexOn sfwOn nsfwOn names query criterion interval amount
      now timezoneOffset page =
  case page of
    MainPage -> mainPage w regexOn sfwOn nsfwOn names query criterion interval amount
                now timezoneOffset
    AboutPage -> about w

showInputs : Bool -> Bool -> Bool -> Criterion -> Interval -> Amount
          -> Element
showInputs useRegex sfwOn nsfwOn criterion interval amount =
  let
    useRegexCheckBox = checkbox useRegexCheck.handle id useRegex |> width 23
    sfwCheckBox = checkbox sfwCheck.handle id sfwOn |> width 23
    nsfwCheckBox = checkbox nsfwCheck.handle id nsfwOn |> width 23
    labelSizeF = width 120
    rows =
      [ spacer 0 0 |> color bgColor
      , flow right [
          flow right [
            toSizedText 16 "use "
          , toSizedText 16 "regex"
            |> link "http://en.wikipedia.org/wiki/Regular_expression"
          , toSizedText 16 ":" ]
          |> labelSizeF, useRegexCheckBox ]
      , flow right [ toDefText "sfw:"       |> labelSizeF, sfwCheckBox ]
      , flow right [ toDefText "nsfw:"      |> labelSizeF, nsfwCheckBox ]
      , defaultSpacer
      , flow right [ toDefText "sorted by:" |> labelSizeF, criterionDropDown criterion ]
      , flow right [ toDefText "interval:"  |> labelSizeF, intervalDropDown interval ]
      , flow right [ toDefText "amount:"    |> labelSizeF, amountDropDown amount ]
      , defaultSpacer ]
  in
    intersperse defaultSpacer rows |> flow down

showLeftBody : Bool -> Bool -> Bool -> Criterion -> Interval -> Amount
            -> Element
showLeftBody useRegex sfwOn nsfwOn criterion interval amount =
  let
    inputElem = showInputs useRegex sfwOn nsfwOn criterion interval amount
  in
    flow down [ spacer 1 30 |> color bgColor -- room for text input field
              , flow right [ inputElem, defaultSpacer, defaultSpacer ] ]

mainPage : Int -> Bool -> Bool -> Bool -> Subreddits -> String -> Criterion
        -> Interval -> Amount -> Time -> Time -> Element
mainPage w useRegex sfwOn nsfwOn names query criterion interval amount
         now timezoneOffset =
  let
    suggestions = genSuggestions useRegex names query
    suggestionElems = suggestions |> take maxSuggestions
                      |> map (showSuggestion query)
    suggestionsElemRaw = suggestionElems
      ++ (if length suggestions > maxSuggestions
           then [toDefText overflowIndicator]
           else [])
        |> flow down
    suggestionsElem = suggestionsElemRaw
                      |> container 200 (heightOf suggestionsElemRaw) topLeft

    resultElem = showResult w query sfwOn nsfwOn criterion interval amount
                            now timezoneOffset
    bodyLeft = showLeftBody useRegex sfwOn nsfwOn criterion interval amount
    centerHorizontally : Element -> Element
    centerHorizontally elem = container w (heightOf elem) midTop elem
    contentRaw = flow down [
                   flow right [
                     bodyLeft
                   , suggestionsElem ] |> centerHorizontally
                 , defaultSpacer
                 , resultElem |> centerHorizontally
                 , defaultSpacer ]
    content = contentRaw |> centerHorizontally
  in
    showPage w content