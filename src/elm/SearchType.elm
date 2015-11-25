module SearchType where

import List exposing (map)
import Graphics.Element exposing (Element)
import Graphics.Input exposing (dropDown)
import Signal

type SearchType = TitleSearch | TextSearch

defaultSearchType : SearchType
defaultSearchType = TitleSearch

searchTypeInput : Signal.Mailbox SearchType
searchTypeInput = Signal.mailbox defaultSearchType

readSearchType : String -> SearchType
readSearchType s =
    if s == "title" then TitleSearch
    else if s == "text" then TextSearch
    else defaultSearchType

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
    dropDown (Signal.message searchTypeInput.address) <| map f all