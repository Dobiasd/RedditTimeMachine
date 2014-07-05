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

-- todo: If issue 670 is resolved, remove the parameter current again.
--       https://github.com/elm-lang/Elm/issues/670
amountDropDown : Amount -> Element
amountDropDown current =
  let
    f c = (showAmount c, c)
    -- more than 1000 results in "too much recursion" for elm
    all = [10, 20, 50, 100, 200, 500, 1000] |> filter (\x -> x /= current)
  in
    dropDown amountInput.handle <| map f (current :: all)