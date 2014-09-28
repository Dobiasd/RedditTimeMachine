module Criterion where

import Graphics.Input (Input, input, dropDown)

data Criterion = Relevance | Hot | Top | Comments

defaultCriterion : Criterion
defaultCriterion = Top

criterionInput : Input Criterion
criterionInput = input defaultCriterion

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
    dropDown criterionInput.handle <| map f all