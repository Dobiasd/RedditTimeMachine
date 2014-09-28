module Amount where

import Graphics.Input (Input, input, dropDown)
import SfwSwitches (toIntDef)

type Amount = Int

defaultAmount : Int
defaultAmount = 20

amountInput : Input Amount
amountInput = input defaultAmount

readAmount : String -> Amount
readAmount = toIntDef defaultAmount >> min 500 >> max 10

showAmount : Amount -> String
showAmount = show

amountDropDown : Element
amountDropDown =
  let
    f c = (showAmount c, c)
    -- Too much results in "too much recursion" in firefox.
    all = [10, 20, 50, 100, 200, 500]
  in
    dropDown amountInput.handle <| map f all