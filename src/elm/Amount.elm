module Amount where

import Graphics.Input (Input, input, dropDown)
import SfwSwitches (toIntDef)

type Amount = Int

defaultAmount : Int
defaultAmount = 20

amountInput : Input Amount
amountInput = input defaultAmount

readAmount : String -> Amount
readAmount = max 10 . min 500 . toIntDef defaultAmount

showAmount : Amount -> String
showAmount = show

-- todo: If issue 670 is resolved, remove the parameter current again.
--       https://github.com/elm-lang/Elm/issues/670
amountDropDown : Amount -> Element
amountDropDown current =
  let
    f c = (showAmount c, c)
    -- Too much results in "too much recursion" in firefox.
    all = [10, 20, 50, 100, 200, 500] |> filter (\x -> x /= current)
  in
    dropDown amountInput.handle <| map f (current :: all)