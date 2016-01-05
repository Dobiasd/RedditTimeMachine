module SfwSwitches (..) where

import Debug
import List exposing (map)
import String
import Signal
import Sfw
import Nsfw


type alias Subreddit =
    ( String, Int )


type alias Subreddits =
    List Subreddit


toIntDef : Int -> String -> Int
toIntDef def x =
    case String.toInt x of
        Ok res ->
            res

        Err _ ->
            def


parseRawSubreddits : List String -> Subreddits
parseRawSubreddits =
    let
        parseRawSubreddit raw =
            String.split "," raw
                |> (\pair ->
                        case pair of
                            a :: (b :: []) ->
                                ( a, toIntDef 0 b )

                            _ ->
                                Debug.crash "parseRawSubreddits failed"
                   )
    in
        map parseRawSubreddit


lowerFst : List ( String, a ) -> List ( String, a )
lowerFst =
    map (\( s, i ) -> ( String.toLower s, i ))


readBoolDef : Bool -> String -> Bool
readBoolDef def s =
    if s == "false" then
        False
    else if s == "true" then
        True
    else
        def


showBool : Bool -> String
showBool b =
    if b then
        "true"
    else
        "false"


sfwDefault : Bool
sfwDefault =
    True


nsfwDefault : Bool
nsfwDefault =
    False


sfwCheck : Signal.Mailbox Bool
sfwCheck =
    Signal.mailbox sfwDefault


nsfwCheck : Signal.Mailbox Bool
nsfwCheck =
    Signal.mailbox nsfwDefault


sfw : Subreddits
sfw =
    Sfw.sfwRaw |> parseRawSubreddits |> lowerFst


nsfw : Subreddits
nsfw =
    Nsfw.nsfwRaw |> parseRawSubreddits |> lowerFst
