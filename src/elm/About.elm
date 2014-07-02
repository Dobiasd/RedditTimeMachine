module About where

import Skeleton (showPage)

about : Int -> Element
about w =
  let
    content = [markdown|
# About

This webpage is not associated with the [official reddit page](http://www.reddit.com).
It just provides an auxiliary tool to extend the user experience.

# Contact

If you have any questions, suggestions or something, just drop an email: info (at) reddittimemachine.com
|]
  in
    showPage w content