module Criterion where

import List exposing (map)
import Graphics.Element exposing (Element)
import Graphics.Input exposing (dropDown)
import Signal

type Criterion = Relevance | Hot | Top | Comments

defaultCriterion : Criterion
defaultCriterion = Top

criterionInput : Signal.Mailbox Criterion
criterionInput = Signal.mailbox defaultCriterion

readCriterion : String -> Criterion
readCriterion s =
    if s == "relevance" then Relevance
    else if s == "hot" then Hot
    else if s == "top" then Top
    else if s == "comments" then Comments
    else defaultCriterion

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
    dropDown (Signal.message criterionInput.address) <| map f all