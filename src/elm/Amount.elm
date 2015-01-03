module Amount where

import Graphics.Element (Element)
import Graphics.Input (dropDown)
import List (map)
import Signal
import SfwSwitches (toIntDef)

type alias Amount = Int

defaultAmount : Int
defaultAmount = 20

amountInput : Signal.Channel Amount
amountInput = Signal.channel defaultAmount

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
    dropDown (Signal.send amountInput) <| map f all