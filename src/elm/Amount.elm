module Amount where

import Graphics.Element exposing (Element)
import Graphics.Input exposing (dropDown)
import List exposing (map)
import Signal
import SfwSwitches exposing (toIntDef)

type alias Amount = Int

defaultAmount : Int
defaultAmount = 20

amountInput : Signal.Mailbox Amount
amountInput = Signal.mailbox defaultAmount

readAmount : String -> Amount
readAmount = toIntDef defaultAmount >> min 500 >> max 10

showAmount : Amount -> String
showAmount = toString

amountDropDown : Element
amountDropDown =
  let
    f c = (showAmount c, c)
    -- Too much results in "too much recursion" in firefox.
    all = [10, 20, 50, 100, 200, 500]
  in
    dropDown (Signal.message amountInput.address) <| map f all