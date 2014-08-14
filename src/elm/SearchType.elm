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

-- todo: If issue 670 is resolved, remove the parameter current again.
--       https://github.com/elm-lang/Elm/issues/670
searchTypeDropDown : SearchType -> Element
searchTypeDropDown current =
  let
    f c = (showSearchType c, c)
    all = [TitleSearch, TextSearch] |> filter (\x -> x /= current)
  in
    dropDown searchTypeInput.handle <| map f (current :: all)