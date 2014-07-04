module Amount where

import Graphics.Input (Input, input, dropDown)
import SfwSwitches (toIntDef)

type Amount = Int

defaultAmount : Int
defaultAmount = 10

amountInput : Input Amount
amountInput = input defaultAmount

readAmount : String -> Amount
readAmount = toIntDef defaultAmount

showAmount : Amount -> String
showAmount = show

-- todo if issue 670 is resolved, remove the parameter current again
amountDropDown : Amount -> Element
amountDropDown current =
  let
    f c = (showAmount c, c)
    all = [10, 20, 50, 100, 200, 500, 1000, 2000, 5000] |> filter (\x -> x /= current)
  in
    dropDown amountInput.handle <| map f (current :: all)