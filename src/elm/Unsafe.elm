module Unsafe (..) where

import Debug


unsafeLast : List a -> a
unsafeLast xs =
    List.drop (List.length xs - 1) xs |> unsafeHead


unsafeHead : List a -> a
unsafeHead xs =
    case xs of
        x :: _ ->
            x

        _ ->
            Debug.crash "unsafeHead with empty list"


unsafeTail : List a -> List a
unsafeTail xs =
    case xs of
        _ :: ys ->
            ys

        _ ->
            Debug.crash "unsafeTail with empty list"


unsafeMaybe : Maybe a -> a
unsafeMaybe x =
    case x of
        Just y ->
            y

        _ ->
            Debug.crash "unsafeMaybe with Nothing"
