module Amount where

import Graphics.Input (Input, input, dropDown)

import SfwSwitches(toIntDef)

defaultAmount : Int
defaultAmount = 10

type Amount = Int

amountInput : Input Amount
amountInput = input defaultAmount

readAmount : String -> Amount
readAmount = toIntDef defaultAmount

showAmount : Amount -> String
showAmount = show

amountDropDown : Element
amountDropDown =
  let
    f c = (showAmount c, c)
  in
    dropDown amountInput.handle <| map f [10, 20, 50, 100, 200, 500, 1000]