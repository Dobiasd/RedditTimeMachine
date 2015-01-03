module About where

import Graphics.Element(Element)
import Markdown
import Skeleton (showPage)
import Layout (toColText, defaultSpacer)

about : Int -> Element
about w =
  let
    content = Markdown.toElement """
# About

This webpage is not associated with the [official reddit page](http://www.reddit.com).
It just provides an auxiliary tool to extend the user experience.

Did you also always wonder what reddit was talking about on your birthday 4 years ago? Or did you just remember that you forgot to check reddit on 2007-09-23? Then Reddit Time Machine is just for you! ;-)

With the [built-in search function on reddit](http://www.reddit.com/wiki/search) you can ([without much manual effort](http://www.reddit.com/r/help/comments/27eziq/view_top_posts_of_a_specific_timespan/)) only choose time intervals ending in the now (dark gray in the image below). Reddit Time Machine lets you generate links for different intervals (blue in the image below) comfortably with just a few clicks.

![timeline](imgs/timeline.png)


# FAQ

## How did you make this page?
This page was mostly written in [Elm](http://elm-lang.org), an awesome [pure functional](http://en.wikipedia.org/wiki/Functional_programming) [Haskell](http://www.haskell.org)-like programming language that compiles to Javascript.

## Can you show me the source code?
Sure! Here it is: [github/Dobiasd/RedditTimeMachine](https://github.com/Dobiasd/RedditTimeMachine)


# Contact

If you have any questions, suggestions or something, just drop an email: info (at) reddittimemachine.com
"""
  in
    showPage w content