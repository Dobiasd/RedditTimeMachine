module SearchType where

import List(map)
import Graphics.Element (Element)
import Graphics.Input (dropDown)
import Signal

type SearchType = TitleSearch | TextSearch

defaultSearchType : SearchType
defaultSearchType = TitleSearch

searchTypeInput : Signal.Channel SearchType
searchTypeInput = Signal.channel defaultSearchType

readSearchType : String -> SearchType
readSearchType s =
    if | s == "title" -> TitleSearch
       | s == "text" -> TextSearch
       | otherwise -> defaultSearchType

-- https://groups.google.com/forum/#!topic/reddit-dev/SarzNxbLSzI
showSearchType : SearchType -> String
showSearchType c =
  case c of
    TitleSearch -> "title"
    TextSearch -> "text"

searchTypeDropDown : SearchType -> Element
searchTypeDropDown current =
  let
    f c = (showSearchType c, c)
    all = [TitleSearch, TextSearch]
  in
    dropDown (Signal.send searchTypeInput) <| map f all