import Graphics.Input (Input, input, dropDown, customButton, clickable)
import Graphics.Input.Field as Field
import Date
import Text
import String
import Window

import Sfw
import Nsfw

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
      PrecDay -> show (Date.day d)
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
    ~ nameInput.signal ~ criterion.signal ~ interval.signal ~ amount.signal ~ now

nameInput : Input Field.Content
nameInput = input Field.noContent

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

clicks : Input ()
clicks = input ()

suggestionClick : Input String
suggestionClick = input ""

pageWidth : Int
pageWidth = 400

iconSize : Int
iconSize = 32

logoHeight : Int
logoHeight = 100

spacerSize : Int
spacerSize = 8

defaultSpacer : Element
defaultSpacer = spacer spacerSize spacerSize

shareIcons : Element
shareIcons =
  let
    buttons =
      [ ( image iconSize iconSize "icons/facebook.png", "https://www.facebook.com/sharer/sharer.php?u=http://www.reddittimemachine.com" )
      , ( image iconSize iconSize "icons/twitter.png", "https://twitter.com/home?status=Check%20out%20what%20was%20hot%20on%20reddit%20days/weeks/months%20ago%20at%20http://www.reddittimemachine.com" )
      , ( image iconSize iconSize "icons/googleplus.png", "https://plus.google.com/share?url=http://www.reddittimemachine.com" )
      , ( image iconSize iconSize "icons/linkedin.png", "https://www.linkedin.com/shareArticle?mini=true&url=http://www.reddittimemachine.com&title=Reddit%20Time%20Machine&summary=Check%20out%20what%20was%20hot%20on%20reddit%20days/weeks/months%20ago.&source=" )
      , ( image iconSize iconSize "icons/pinterest.png", "https://pinterest.com/pin/create/button/?url=&media=http://www.reddittimemachine.com&description=Check%20out%20what%20was%20hot%20on%20reddit%20days/weeks/months%20ago." ) ]
      |> map (\ (img, url) -> customButton clicks.handle () img img img |> link url)
  in
    plainText "share: " :: buttons |> intersperse (defaultSpacer) |> flow right

logo : Element
logo = image 120 logoHeight "imgs/snoo.png"

topBar : Int -> Element
topBar w =
  flow down [ defaultSpacer
            , flow right [ shareIcons, defaultSpacer ] |> container w (heightOf shareIcons) topRight
            , defaultSpacer ] |> color lightBlue

titleText : String
titleText = "reddit time machine"

header : Int -> Element
header w =
  let
    title = toText titleText |> centered . Text.color black . Text.height 24
  in
    flow down [
      topBar w
    , title |> container w (heightOf title) midTop
    , logo |> container w (heightOf logo) midTop
    , defaultSpacer ]

maxSuggestions : Int
maxSuggestions = 10

lowerFst : [(String, a)] -> [(String, a)]
lowerFst = map (\(s, i) -> (String.toLower s, i))

sfw = Sfw.sfw |> lowerFst
nsfw = Nsfw.nsfw |> lowerFst

subreddits = sfw ++ nsfw

overflowIndicator : String
overflowIndicator = "..."

suggestions : String -> [String]
suggestions query =
  let
    allFitting = filter (String.contains (String.toLower query) . fst) subreddits
    overflow = length allFitting > maxSuggestions
    nameCnt = if overflow then maxSuggestions - 1 else maxSuggestions
    fitting = sortBy snd allFitting |> reverse |> take nameCnt |> map fst
    isIncluded = any (\x -> x == query) fitting
    names = if isIncluded then fitting else query :: fitting
  in
    if overflow then names ++ [overflowIndicator] else names

showSuggestion : String -> String -> Element
showSuggestion query s =
  let
    showCol : Color -> String -> Element
    showCol col = centered . Text.color col . Text.height 16 . toText
    showNormal = showCol black
    showQuery = showCol darkBrown
    showDots = showCol darkBlue
    showF x = if | x == query -> showQuery s
                 | x == overflowIndicator -> showDots s
                 | otherwise -> showNormal s
    elem = showF s
    elemHover = showF s |> color lightBlue
    elemClick = showF s |> color lightGreen
  in
    if s == overflowIndicator then elem
      else customButton suggestionClick.handle "s" elem elemHover elemClick

scene : (Int, Int) -> Field.Content -> Criterion -> Interval -> Int -> Time -> Element
scene (w,h) fieldContent criterion interval amount now =
  let
    query = fieldContent.string
    nameElem = flow right
             [ Field.field Field.defaultStyle nameInput.handle id "enter subreddit" fieldContent
             , defaultSpacer
             , suggestions query |> map (showSuggestion query) |> flow down
             , defaultSpacer ]
    labelSizeF = width 100
    rows = [ nameElem
           , flow right [ plainText "criterion:" |> labelSizeF, criterionDropDown ]
           , flow right [ plainText "interval:"  |> labelSizeF, intervalDropDown ]
           , flow right [ plainText "amount:"    |> labelSizeF, amountDropDown ]
           , showResult query criterion interval amount now
           ]
    bodyContent = intersperse (defaultSpacer) rows |> flow down
    body = container pageWidth (heightOf bodyContent) midLeft bodyContent |> container w (heightOf bodyContent) midTop
    page = flow down [ header w, body ] |> color lightGray
  in
    page |> container w (heightOf page) midTop