module Main (..) where

import Color exposing (lightBlue)
import Graphics.Element exposing (Element, link, container, widthOf, midTop, flow, right, image, down, heightOf, spacer, color, width, topLeft)
import Graphics.Input exposing (dropDown, checkbox, customButton)
import Graphics.Input.Field as Field
import Date
import List exposing (any, map, sortBy, reverse, filter, length, map2, repeat, intersperse, head, (::), take, drop, maximum)
import Text
import Time exposing (every, minute, Time, second, hour)
import Signal exposing (Signal)
import Signal
import String
import Window
import Unsafe exposing (unsafeHead, unsafeMaybe)
import Layout exposing (defaultSpacer, pageWidth, bgColor, toDefText, toSizedText, toSizedTextMod, doubleDefSpacer, quadDefSpacer, defTextSize)
import Skeleton exposing (showPage)
import About exposing (about)
import Suggestions exposing (genSuggestions, showSuggestion, maxSuggestions, overflowIndicator, suggestionClick, useRegexCheck, useRegexDefault)
import Footer exposing (pageClick, readPage, showPageName, Page(MainPage, AboutPage))
import DateTools exposing (lastNDaySpans, showDateAsInts, timeToDateAsInts, lastNWeekSpans, lastNMonthsSpans, lastNYearsSpans)
import Amount exposing (showAmount, amountDropDown, Amount, readAmount, amountInput)
import SfwSwitches exposing (toIntDef, sfwCheck, nsfwCheck, Subreddits, showBool, sfw, nsfw, readBoolDef, sfwDefault, nsfwDefault)
import Criterion exposing (Criterion, showCriterion, criterionDropDown, readCriterion, criterionInput)
import Interval exposing (showInterval, Interval(Days, Weeks, Months, Years), intervalDropDown, readInterval, intervalInput)
import SearchType exposing (SearchType, showSearchType, searchTypeDropDown, readSearchType, searchTypeInput)


-- To keep the query text input from swallowing characters
-- if the generation of suggestions is too slow for the typing speed,
-- the edit box is provided by the containing html page.
-- https://groups.google.com/forum/#!topic/elm-discuss/Lm-M-PPM2zQ
--
-- And there is no possibility to set the initial keyboard focus in elm.
-- https://groups.google.com/forum/#!topic/elm-discuss/d6B3D6suJNw
--
-- And the elm generated input field works badly in Android browser
-- because after redrawing the text is selected and thus you would
-- overwrite every character with the next one with normal typing.


port query : Signal String
port timezoneOffsetInMinutes : Signal Int



-- for static links with paramters in URL


port useRegexInStr : Signal String
port sfwInStr : Signal String
port nsfwInStr : Signal String
port sortedByInStr : Signal String
port intervalInStr : Signal String
port amountInStr : Signal String
port pageInStr : Signal String
port searchTypeInStr : Signal String
port search : Signal String
currentPage : Signal Page
currentPage =
    Signal.merge (Signal.map readPage pageInStr) pageClick.signal


andMap : Signal (a -> b) -> Signal a -> Signal b
andMap =
    Signal.map2 (<|)


port staticLinkOut : Signal String
port staticLinkOut =
    Signal.map genStaticLink query `andMap` useRegex `andMap` sfwOn `andMap` nsfwOn `andMap` criterion `andMap` searchType `andMap` search `andMap` interval `andMap` amount `andMap` currentPage


port selected : Signal String
port selected =
    suggestionClick.signal


port showQueryAndSearch : Signal Bool
port showQueryAndSearch =
    Signal.map (\x -> x == MainPage) currentPage


port queryColor : Signal String
port queryColor =
    Signal.map
        (\b ->
            if b then
                "PaleGreen"
            else
                "LightYellow"
        )
        isQuerySurelyFound


isQuerySurelyFound : Signal Bool
isQuerySurelyFound =
    let
        f srs q =
            String.isEmpty q
                || q
                == "all"
                || any (\x -> x == q) (map fst srs)
    in
        Signal.map2 f subreddits query


now : Signal Time
now =
    every minute


goBackFrom : Signal Time
goBackFrom =
    Signal.mergeMany
        [ Signal.constant 0
        , nearerClick.signal
        , furtherClick.signal
        ]


timezoneOffset : Signal Time
timezoneOffset =
    Signal.map
        (\x -> toFloat x * minute)
        (Signal.dropRepeats timezoneOffsetInMinutes)


interval : Signal Interval
interval =
    Signal.merge
        (Signal.map readInterval intervalInStr)
        intervalInput.signal


criterion : Signal Criterion
criterion =
    Signal.merge
        (Signal.map readCriterion sortedByInStr)
        criterionInput.signal


searchType : Signal SearchType
searchType =
    Signal.merge
        (Signal.map readSearchType sortedByInStr)
        searchTypeInput.signal


amount : Signal Amount
amount =
    Signal.merge
        (Signal.map readAmount amountInStr)
        amountInput.signal


useRegex : Signal Bool
useRegex =
    Signal.merge
        (Signal.map (readBoolDef useRegexDefault) useRegexInStr)
        useRegexCheck.signal


sfwOn : Signal Bool
sfwOn =
    Signal.merge
        (Signal.map (readBoolDef sfwDefault) sfwInStr)
        sfwCheck.signal


nsfwOn : Signal Bool
nsfwOn =
    Signal.merge
        (Signal.map (readBoolDef nsfwDefault) nsfwInStr)
        nsfwCheck.signal


subreddits : Signal Subreddits
subreddits =
    Signal.map2
        (\sfwOn nsfwOn ->
            (if sfwOn then
                sfw
             else
                []
            )
                ++ (if nsfwOn then
                        nsfw
                    else
                        []
                   )
                |> sortBy snd
                |> reverse
        )
        sfwOn
        nsfwOn



-- todo: outfactor search options


main : Signal Element
main =
    Signal.map scene Window.width
        `andMap` useRegex
        `andMap` sfwOn
        `andMap` nsfwOn
        `andMap` subreddits
        `andMap` Signal.merge
                    (Signal.map String.toLower query)
                    suggestionClick.signal
        `andMap` criterion
        `andMap` searchType
        `andMap` search
        `andMap` interval
        `andMap` amount
        `andMap` now
        `andMap` goBackFrom
        `andMap` timezoneOffset
        `andMap` currentPage


genLink : String -> Criterion -> SearchType -> String -> ( Time, Time ) -> String
genLink name criterion searchType search ( start, end ) =
    staticLink
        ("http://www.reddit.com/r/" ++ name ++ "/search")
        [ ( "q"
          , "(and+timestamp:"
                ++ toString (start / second)
                ++ ".."
                ++ toString (end / second)
                ++ "+"
                ++ showSearchType searchType
                ++ ":'"
                ++ search
                ++ "')"
          )
        , ( "sort", showCriterion criterion )
        , ( "restrict_sr", "on" )
        , ( "syntax", "cloudsearch" )
        ]


staticLink : String -> List ( String, String ) -> String
staticLink base parameters =
    let
        addon =
            map (\( name, value ) -> name ++ "=" ++ value) parameters
                |> String.join "&"
    in
        base
            ++ (if String.isEmpty addon then
                    ""
                else
                    "?" ++ addon
               )


genStaticLink : String -> Bool -> Bool -> Bool -> Criterion -> SearchType -> String -> Interval -> Int -> Page -> String
genStaticLink query useRegex sfwOn nsfwOn criterion searchType search interval amount page =
    staticLink
        ""
        [ ( "query", query )
        , ( "useregex", showBool useRegex )
        , ( "sfw", showBool sfwOn )
        , ( "nsfw", showBool nsfwOn )
        , ( "sortedby", showCriterion criterion )
        , ( "searchtype", showSearchType searchType )
        , ( "search", search )
        , ( "interval", showInterval interval )
        , ( "amount", showAmount amount )
        , ( "page", showPageName page )
        ]


notEmptyOr : String -> String -> String
notEmptyOr def s =
    if String.isEmpty s then
        def
    else
        s


avoidEmptySubredditName : String -> String
avoidEmptySubredditName =
    notEmptyOr "all"


showTimeSpan : (String -> String) -> Time -> ( Time, Time ) -> String
showTimeSpan transF timezoneOffset ( start, end ) =
    let
        showTimeAsDate =
            (\x -> x + timezoneOffset)
                >> timeToDateAsInts
                >> showDateAsInts

        -- aim at middle of day
        startStr = start + 12 * hour |> showTimeAsDate |> transF

        endStr = end - 12 * hour |> showTimeAsDate |> transF
    in
        startStr
            ++ if endStr /= startStr then
                " - " ++ endStr
               else
                ""


nearerClick : Signal.Mailbox Time
nearerClick =
    Signal.mailbox 0


furtherClick : Signal.Mailbox Time
furtherClick =
    Signal.mailbox 0


last =
    reverse >> unsafeHead


showResult : Int -> String -> Bool -> Bool -> Criterion -> SearchType -> String -> Interval -> Int -> Time -> Time -> Time -> Element
showResult w rawName sfwOn nsfwOn criterion searchType search interval amount now goBackFromRaw timezoneOffset =
    let
        name = avoidEmptySubredditName rawName

        ( lastNFunc, transF ) =
            case interval of
                Days ->
                    ( lastNDaySpans, identity )

                Weeks ->
                    ( lastNWeekSpans, identity )

                Months ->
                    ( lastNMonthsSpans, String.dropRight 3 )

                Years ->
                    ( lastNYearsSpans, String.dropRight 6 )

        -- 2005-05-01 minus 12 hours
        validTime x = x > 1119398400 * second - 12 * 60 * 60 * second

        goBackFrom =
            (if validTime goBackFromRaw then
                goBackFromRaw
             else
                now
            )
                |> min now

        spans = lastNFunc amount goBackFrom |> filter (snd >> validTime)

        urls = map (genLink name criterion searchType search) spans

        texts = map (showTimeSpan transF timezoneOffset) spans

        spanCnt = length spans

        textSize =
            if spanCnt > 113 then
                16
            else if spanCnt > 93 then
                18
            else if spanCnt > 33 then
                20
            else if spanCnt > 13 then
                22
            else
                24

        linkElems = map2 (\t url -> toSizedText textSize t |> link url) texts urls

        nearerPossible = firstSeenEnd <= now

        furtherPossible = length spans >= amount

        doCenter h x = x |> container (widthOf columnElem) h midTop

        makeTimeElem img = repeat 4 img |> intersperse defaultSpacer |> flow right |> doCenter 24

        nearerElem = makeTimeElem <| image 24 24 "imgs/arrowup.png"

        furtherElem = makeTimeElem <| image 24 24 "imgs/arrowdown.png"

        firstSeenStart = unsafeHead spans |> fst

        firstSeenEnd = unsafeHead spans |> snd

        lastSeen = last spans |> fst

        seenSpan = firstSeenEnd - lastSeen

        oneSpan = firstSeenEnd - firstSeenStart

        nearerButton =
            customButton
                (Signal.message
                    nearerClick.address
                    (firstSeenStart + seenSpan - (oneSpan / 2))
                )
                nearerElem
                nearerElem
                nearerElem

        furtherButton =
            customButton
                (Signal.message furtherClick.address lastSeen)
                furtherElem
                furtherElem
                furtherElem

        noTimeBtnSpacer = makeTimeElem <| image 24 24 "imgs/bar.png"

        columnElem = linkElems |> asColumns w
    in
        [ if nearerPossible then
            nearerButton
          else
            noTimeBtnSpacer
        , columnElem
        , if furtherPossible then
            furtherButton
          else
            noTimeBtnSpacer
        ]
            |> intersperse defaultSpacer
            |> flow down


group : Int -> List a -> List (List a)
group n l =
    case l of
        [] ->
            []

        l ->
            if n > 0 then
                (take n l) :: (group n (drop n l))
            else
                []


sign : Int -> Int
sign x =
    if x < 0 then
        -1
    else if x == 0 then
        0
    else
        1


asColumns : Int -> List Element -> Element
asColumns w elems =
    let
        maxW = map widthOf elems |> maximum |> unsafeMaybe

        colCnt = w // (maxW + 2 * widthOf quadDefSpacer + 2) |> max 1

        rowCntRemainderSign = length elems `rem` colCnt |> sign

        rowCnt = length elems // colCnt + rowCntRemainderSign |> max 5

        rows = group rowCnt elems

        cols = map (flow down) rows

        maxH = map heightOf cols |> maximum |> unsafeMaybe

        colSpacer = spacer 2 maxH |> color lightBlue

        paddedColSpacer = flow right [ quadDefSpacer, colSpacer, quadDefSpacer ]
    in
        map (flow down) rows |> intersperse paddedColSpacer |> flow right


scene : Int -> Bool -> Bool -> Bool -> Subreddits -> String -> Criterion -> SearchType -> String -> Interval -> Int -> Time -> Time -> Time -> Page -> Element
scene w regexOn sfwOn nsfwOn names query criterion searchType search interval amount now goBackFrom timezoneOffset page =
    case page of
        MainPage ->
            mainPage
                w
                regexOn
                sfwOn
                nsfwOn
                names
                query
                criterion
                searchType
                search
                interval
                amount
                now
                goBackFrom
                timezoneOffset

        AboutPage ->
            about w


showInputs : Bool -> Bool -> Bool -> Criterion -> SearchType -> Interval -> Amount -> Element
showInputs useRegex sfwOn nsfwOn criterion searchType interval amount =
    let
        useRegexCheckBox =
            checkbox (Signal.message useRegexCheck.address) useRegex
                |> width 23

        sfwCheckBox = checkbox (Signal.message sfwCheck.address) sfwOn |> width 23

        nsfwCheckBox = checkbox (Signal.message nsfwCheck.address) nsfwOn |> width 23

        labelSizeF = width 120

        rows =
            [ spacer 0 0 |> color bgColor
            , flow
                right
                [ flow
                    right
                    [ toSizedText 16 "use "
                    , toSizedText 16 "regex"
                        |> link "http://en.wikipedia.org/wiki/Regular_expression"
                    , toSizedText 16 ":"
                    ]
                    |> labelSizeF
                , useRegexCheckBox
                ]
            , flow right [ toDefText "sfw:" |> labelSizeF, sfwCheckBox ]
            , flow right [ toDefText "nsfw:" |> labelSizeF, nsfwCheckBox ]
            , defaultSpacer
            , flow right [ toDefText "sorted by:" |> labelSizeF, criterionDropDown criterion ]
            , flow right [ toDefText "interval:" |> labelSizeF, intervalDropDown interval ]
            , flow right [ toDefText "amount:" |> labelSizeF, amountDropDown ]
            , defaultSpacer
            , flow right [ toDefText "search:" |> labelSizeF, searchTypeDropDown searchType ]
            , defaultSpacer
            ]
    in
        intersperse defaultSpacer rows |> flow down


showLeftBody : Bool -> Bool -> Bool -> Criterion -> SearchType -> Interval -> Amount -> Element
showLeftBody useRegex sfwOn nsfwOn criterion searchType interval amount =
    let
        inputElem =
            showInputs
                useRegex
                sfwOn
                nsfwOn
                criterion
                searchType
                interval
                amount
    in
        flow
            down
            [ spacer 1 30 |> color bgColor
              -- room for text input field
            , flow right [ inputElem, defaultSpacer, defaultSpacer ]
            ]


mainPage : Int -> Bool -> Bool -> Bool -> Subreddits -> String -> Criterion -> SearchType -> String -> Interval -> Amount -> Time -> Time -> Time -> Element
mainPage w useRegex sfwOn nsfwOn names query criterion searchType search interval amount now goBackFrom timezoneOffset =
    let
        suggestions = genSuggestions useRegex names query

        suggestionElems =
            suggestions
                |> take maxSuggestions
                |> map (showSuggestion query)

        suggestionsElemRaw =
            suggestionElems
                ++ (if length suggestions > maxSuggestions then
                        [ toDefText overflowIndicator ]
                    else
                        []
                   )
                |> flow down

        suggestionsElem =
            suggestionsElemRaw
                |> container 200 (heightOf suggestionsElemRaw) topLeft

        resultElem =
            showResult
                w
                query
                sfwOn
                nsfwOn
                criterion
                searchType
                search
                interval
                amount
                now
                goBackFrom
                timezoneOffset

        bodyLeft =
            showLeftBody
                useRegex
                sfwOn
                nsfwOn
                criterion
                searchType
                interval
                amount

        centerHorizontally : Element -> Element
        centerHorizontally elem = container w (heightOf elem) midTop elem

        contentRaw =
            flow
                down
                [ flow
                    right
                    [ bodyLeft
                    , suggestionsElem
                    ]
                    |> centerHorizontally
                , defaultSpacer
                , resultElem |> centerHorizontally
                , defaultSpacer
                ]

        content = contentRaw |> centerHorizontally
    in
        showPage w content
