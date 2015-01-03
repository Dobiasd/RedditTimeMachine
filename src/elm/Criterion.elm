module Criterion where

import List(map)
import Graphics.Element(Element)
import Graphics.Input (dropDown)
import Signal

type Criterion = Relevance | Hot | Top | Comments

defaultCriterion : Criterion
defaultCriterion = Top

criterionInput : Signal.Channel Criterion
criterionInput = Signal.channel defaultCriterion

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

criterionDropDown : Criterion -> Element
criterionDropDown current =
  let
    f c = (showCriterion c, c)
    all = [Top, Hot, Comments, Relevance]
  in
    dropDown (Signal.send criterionInput) <| map f all