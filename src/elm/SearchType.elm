module SearchType where

import Graphics.Input (Input, input, dropDown)

data SearchType = TitleSearch | TextSearch

defaultSearchType : SearchType
defaultSearchType = TitleSearch

searchTypeInput : Input SearchType
searchTypeInput = input defaultSearchType

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
    dropDown searchTypeInput.handle <| map f all