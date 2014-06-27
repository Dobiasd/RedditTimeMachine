import Graphics.Input (Input, input, dropDown, customButton)
import Graphics.Input.Field as Field
import Text
import String
import Window

import Sfw
import Nsfw

-- nameField : Input Field.Content
-- nameField = input Field.noContent

-- name
-- Field.field Field.defaultStyle name.handle id "Type here!" fieldContent

-- from http://subreddits.org/search.html

data Criterion = Relevance | Hot | Top | Comments
data Interval = Days | Weeks | Months | Years

criterion : Input Criterion
criterion = input Top

criterionDropDown : Element
criterionDropDown =
    dropDown criterion.handle
      [ ("top"      , Top)
      , ("hot"      , Hot)
      , ("comments" , Comments)
      , ("relevance", Relevance)
      ]

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

main : Signal Element
main = scene <~ Window.dimensions
    ~ nameInput.signal ~ criterion.signal ~ interval.signal ~ amount.signal

nameInput : Input Field.Content
nameInput = input Field.noContent

showResult : String -> Criterion -> Interval -> Int -> Element
showResult name criterion interval amount =
  plainText <| name ++ " " ++ show criterion ++ " " ++
               show interval ++ " " ++ show amount

clicks : Input ()
clicks = input ()

iconSize : Int
iconSize = 32

logoHeight : Int
logoHeight = 192

spacerSize : Int
spacerSize = 10

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
logo = image 256 logoHeight "imgs/snoo.png"

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
    , logo |> container w (heightOf logo) midTop ]

maxSuggestions : Int
maxSuggestions = 10

lowerFst : [(String, a)] -> [(String, a)]
lowerFst = map (\(s, i) -> (String.toLower s, i))

sfw = Sfw.sfw |> lowerFst 
nsfw = Nsfw.nsfw |> lowerFst

suggestions : String -> [String]
suggestions query =
  let
    fitting = filter (String.contains (String.toLower query) . fst) sfw
  in
    sortBy snd fitting |> reverse |> take maxSuggestions |> map fst

scene : (Int, Int) -> Field.Content -> Criterion -> Interval -> Int -> Element
scene (w,h) fieldContent criterion interval amount =
  let
    nameElem = flow right
             [ Field.field Field.defaultStyle nameInput.handle id "enter subreddit" fieldContent
             , defaultSpacer
             --, plainText (String.reverse fieldContent.string)
             , suggestions fieldContent.string |> map (centered . Text.color black . Text.height 14 . toText) |> flow down
             , defaultSpacer ]
    rows = [ nameElem
           , flow right [ plainText "criterion: ", criterionDropDown ]
           , flow right [ plainText "interval: ", intervalDropDown ]
           , flow right [ plainText "amount: ", amountDropDown ]
           , showResult fieldContent.string criterion interval amount
           ]
    bodyContent = intersperse (defaultSpacer) rows |> flow down
    body = container w (heightOf bodyContent) midTop bodyContent
    page = flow down [ header w, body ] |> color lightGray
  in
    page |> container w (heightOf page) midTop