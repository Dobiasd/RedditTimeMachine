import Graphics.Input (Input, input, dropDown)
import Graphics.Input.Field as Field
import Text
import String
import Window

-- nameField : Input Field.Content
-- nameField = input Field.noContent

-- name
-- Field.field Field.defaultStyle name.handle id "Type here!" fieldContent

data Criterion = Relevance | Hot | Top | Comments
data Interval = Days | Weeks | Months | Years | Forever

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
      nums = map (\x -> 10 * x) [1..50]
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

scene : (Int, Int) -> Field.Content -> Criterion -> Interval -> Int -> Element
scene (w,h) fieldContent criterion interval amount =
  let
    rows = [ flow right
             [ Field.field Field.defaultStyle nameInput.handle id "enter subreddit" fieldContent
             , spacer 10 10
             , plainText (String.reverse fieldContent.string)
             , spacer 10 10 ]
           , flow right [ plainText "criterion: ", criterionDropDown ]
           , flow right [ plainText "interval: ", intervalDropDown ]
           , flow right [ plainText "amount: ", amountDropDown ]
           , showResult fieldContent.string criterion interval amount
           ]
  in
    intersperse (spacer 10 10) rows |> flow down |> container w h midTop