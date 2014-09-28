module Main where

import Graphics.Input (Input, input, dropDown, checkbox, customButton)
import Graphics.Input
import Graphics.Input.Field as Field
import Date
import Text
import String
import Window

-- todo remove
import Debug

import Layout (defaultSpacer, pageWidth, bgColor, toDefText, toSizedText
             , toSizedTextMod, doubleDefSpacer, quadDefSpacer, defTextSize)
import Skeleton (showPage)
import About (about)
import Suggestions (genSuggestions, showSuggestion, maxSuggestions
                  , overflowIndicator, suggestionClick
                  , useRegexCheck, useRegexDefault)
import Footer (pageClick, readPage, showPageName, Page(MainPage))
import DateTools (lastNDaySpans, showDateAsInts, timeToDateAsInts
                , lastNWeekSpans, lastNMonthsSpans, lastNYearsSpans)
import Amount (showAmount, amountDropDown, Amount, readAmount
             , amountInput)
import SfwSwitches (toIntDef, sfwCheck, nsfwCheck, Subreddits, showBool
                  , sfw, nsfw, readBoolDef, sfwDefault
                  , nsfwDefault)
import Criterion (Criterion, showCriterion, criterionDropDown
                , readCriterion, criterionInput)
import Interval (showInterval, Interval(Days, Weeks, Months, Years)
               , intervalDropDown, readInterval, intervalInput)
import SearchType (SearchType, showSearchType, searchTypeDropDown
                , readSearchType, searchTypeInput)

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
port pageInStr : Signal String

port searchTypeInStr : Signal String
port search : Signal String

currentPage : Signal Page
currentPage = merge (readPage <~ pageInStr) pageClick.signal

port staticLinkOut : Signal String
port staticLinkOut = genStaticLink <~ query ~ useRegex ~ sfwOn ~ nsfwOn ~ criterion ~ searchType ~ search ~ interval ~ amount ~ currentPage

port selected : Signal String
port selected = suggestionClick.signal

port showQueryAndSearch : Signal Bool
port showQueryAndSearch = (\x -> x == MainPage) <~ currentPage

port queryColor : Signal String
port queryColor =
  (\b -> if b then "PaleGreen" else "LightYellow") <~ isQuerySurelyFound

isQuerySurelyFound : Signal Bool
isQuerySurelyFound =
  let
    f srs q = String.isEmpty q
              || q == "all"
              || any (\x -> x == q) (map fst srs)
  in f <~ subreddits ~ query

now : Signal Time
now = every minute

goBackFrom : Signal Time
goBackFrom = merges [constant 0, nearerClick.signal, furtherClick.signal]

timezoneOffset : Signal Time
timezoneOffset = (\x -> toFloat x * minute)
                   <~ (dropRepeats timezoneOffsetInMinutes)

interval : Signal Interval
interval = merge (readInterval <~ intervalInStr) intervalInput.signal

criterion : Signal Criterion
criterion = merge (readCriterion <~ sortedByInStr) criterionInput.signal

searchType : Signal SearchType
searchType = merge (readSearchType <~ sortedByInStr) searchTypeInput.signal

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
main = scene <~ Window.width
              ~ useRegex
              ~ sfwOn
              ~ nsfwOn
              ~ subreddits
              ~ merge (String.toLower <~ query) suggestionClick.signal
              ~ criterion
              ~ searchType
              ~ search
              ~ interval
              ~ amount
              ~ now
              ~ goBackFrom
              ~ timezoneOffset
              ~ currentPage

genLink : String -> Criterion -> SearchType -> String -> (Time, Time) -> String
genLink name criterion searchType search (start, end) =
  staticLink ("http://www.reddit.com/r/" ++ name ++ "/search")
             [ ("q", "(and+timestamp:" ++ show (start/second) ++ ".."
                                     ++ show (end/second) ++ "+"
                     ++ showSearchType searchType ++ ":'" ++ search ++ "')")
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

genStaticLink : String -> Bool -> Bool -> Bool -> Criterion -> SearchType
             -> String -> Interval -> Int -> Page -> String
genStaticLink query useRegex sfwOn nsfwOn criterion searchType search
              interval amount page =
  staticLink ""
    [ ("query", query)
    , ("useregex", showBool useRegex)
    , ("sfw", showBool sfwOn)
    , ("nsfw", showBool nsfwOn)
    , ("sortedby", showCriterion criterion)
    , ("searchtype", showSearchType searchType)
    , ("search", search)
    , ("interval", showInterval interval)
    , ("amount", showAmount amount)
    , ("page", showPageName page) ]

notEmptyOr : String -> String -> String
notEmptyOr def s = if String.isEmpty s then def else s

avoidEmptySubredditName : String -> String
avoidEmptySubredditName = notEmptyOr "all"

showTimeSpan : (String -> String) -> Time -> (Time, Time) -> String
showTimeSpan transF timezoneOffset (start, end) =
  let
    showTimeAsDate = (\x -> x + timezoneOffset)
      >> timeToDateAsInts
      >> showDateAsInts
    -- aim at middle of day
    startStr = start + 12 * hour |> showTimeAsDate |> transF
    endStr = end - 12 * hour |> showTimeAsDate |> transF
  in
    startStr ++ if endStr /= startStr then " - " ++ endStr else ""

nearerClick : Input Time
nearerClick = input 0

furtherClick : Input Time
furtherClick = input 0

showResult : Int -> String -> Bool -> Bool -> Criterion -> SearchType -> String
          -> Interval -> Int -> Time -> Time -> Time -> Element
showResult w rawName sfwOn nsfwOn criterion searchType search interval amount
           now goBackFromRaw timezoneOffset =
  let
    name = avoidEmptySubredditName rawName
    (lastNFunc, transF) = case interval of
      Days -> (lastNDaySpans, identity)
      Weeks -> (lastNWeekSpans, identity)
      Months -> (lastNMonthsSpans, String.dropRight 3)
      Years -> (lastNYearsSpans, String.dropRight 6)
    -- 2005-05-01 minus 12 hours
    validTime x = x > 1119398400*second - 12*60*60*second
    goBackFrom = (if validTime goBackFromRaw then goBackFromRaw else now)
                 |> min now
    spans = lastNFunc amount goBackFrom |> filter (snd >> validTime)
    urls = map (genLink name criterion searchType search) spans
    texts = map (showTimeSpan transF timezoneOffset) spans
    spanCnt = length spans
    textSize = if | spanCnt > 113 -> 16
                  | spanCnt >  93 -> 18
                  | spanCnt >  33 -> 20
                  | spanCnt >  13 -> 22
                  | otherwise     -> 24
    linkElems = zipWith (\t url -> toSizedText textSize t |> link url) texts urls
    nearerPossible = firstSeenEnd <= now
    furtherPossible = length spans >= amount
    doCenter h x = x |> container (widthOf columnElem) h midTop
    makeTimeElem img = repeat 4 img |> intersperse defaultSpacer |> flow right |> doCenter 24
    nearerElem = makeTimeElem <| image 24 24 "imgs/arrowup.png"
    furtherElem = makeTimeElem <| image 24 24 "imgs/arrowdown.png"
    firstSeenStart = head spans |> fst
    firstSeenEnd = head spans |> snd
    lastSeen = last spans |> fst
    seenSpan = firstSeenEnd - lastSeen
    oneSpan = firstSeenEnd - firstSeenStart
    nearerButton = customButton nearerClick.handle (firstSeenStart + seenSpan - (oneSpan/2))
                                nearerElem nearerElem nearerElem
    furtherButton = customButton furtherClick.handle lastSeen
                                 furtherElem furtherElem furtherElem
    noTimeBtnSpacer = makeTimeElem <| image 24 24 "imgs/bar.png"
    columnElem = linkElems |> asColumns w
  in
    [ if nearerPossible then nearerButton else noTimeBtnSpacer
    , columnElem
    , if furtherPossible then furtherButton else noTimeBtnSpacer ]
    |> intersperse defaultSpacer |> flow down

group : Int -> [a] -> [[a]]
group n l = case l of
  [] -> []
  l -> if | n > 0 -> (take n l) :: (group n (drop n l))
          | otherwise -> []

asColumns : Int -> [Element] -> Element
asColumns w elems =
  let
    maxW = map widthOf elems |> maximum
    colCnt = w // (maxW + 2 * widthOf quadDefSpacer + 2) |> max 1
    rowCnt = length elems // colCnt + 1 |> max 5
    rows = group rowCnt elems
    cols = map (flow down) rows
    maxH = map heightOf cols |> maximum
    colSpacer = spacer 2 maxH |> color lightBlue
    paddedColSpacer = flow right [ quadDefSpacer, colSpacer, quadDefSpacer ]
  in
    map (flow down) rows |> intersperse paddedColSpacer |> flow right

scene : Int -> Bool -> Bool -> Bool -> Subreddits -> String -> Criterion
     -> SearchType -> String -> Interval -> Int -> Time -> Time -> Time -> Page
     -> Element
scene w regexOn sfwOn nsfwOn names query criterion searchType search interval
      amount now goBackFrom timezoneOffset page =
  case page of
    MainPage -> mainPage w regexOn sfwOn nsfwOn names query criterion searchType
                search interval amount now goBackFrom timezoneOffset
    AboutPage -> about w

showInputs : Bool -> Bool -> Bool -> Criterion -> SearchType
          -> Interval -> Amount -> Element
showInputs useRegex sfwOn nsfwOn criterion searchType interval amount =
  let
    useRegexCheckBox = checkbox useRegexCheck.handle identity useRegex
      |> width 23
    sfwCheckBox = checkbox sfwCheck.handle identity sfwOn |> width 23
    nsfwCheckBox = checkbox nsfwCheck.handle identity nsfwOn |> width 23
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
      , flow right [ toDefText "amount:"    |> labelSizeF, amountDropDown ]
      , defaultSpacer
      , flow right [ toDefText "search:"    |> labelSizeF, searchTypeDropDown searchType ]
      , defaultSpacer ]
  in
    intersperse defaultSpacer rows |> flow down

showLeftBody : Bool -> Bool -> Bool -> Criterion -> SearchType -> Interval
            -> Amount -> Element
showLeftBody useRegex sfwOn nsfwOn criterion searchType interval amount =
  let
    inputElem = showInputs useRegex sfwOn nsfwOn criterion searchType interval
                           amount
  in
    flow down [ spacer 1 30 |> color bgColor -- room for text input field
              , flow right [ inputElem, defaultSpacer, defaultSpacer ] ]

mainPage : Int -> Bool -> Bool -> Bool -> Subreddits -> String -> Criterion
        -> SearchType -> String -> Interval -> Amount -> Time -> Time -> Time
        -> Element
mainPage w useRegex sfwOn nsfwOn names query criterion searchType search
         interval amount now goBackFrom timezoneOffset =
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

    resultElem = showResult w query sfwOn nsfwOn criterion searchType search
                            interval amount now goBackFrom timezoneOffset
    bodyLeft = showLeftBody useRegex sfwOn nsfwOn criterion searchType interval
                            amount
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