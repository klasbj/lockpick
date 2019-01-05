module Route exposing (Route(..), fromUrl, href)

import Html
import Html.Attributes
import Url exposing (Url)
import Url.Parser as P exposing ((</>))


type Route
    = Index
    | Decks
    | Deck String
    | Games
    | Game Int


fromUrl : Url -> Maybe Route
fromUrl =
    P.parse routeParser


href : Route -> Html.Attribute msg
href =
    Html.Attributes.href << toString


toString : Route -> String
toString r =
    case r of
        Index ->
            "/"

        Decks ->
            "/decks"

        Deck id ->
            "/deck/" ++ id

        Games ->
            "/games"

        Game id ->
            "/game/" ++ String.fromInt id


routeParser : P.Parser (Route -> a) a
routeParser =
    P.oneOf
        [ P.map Index P.top
        , P.map Decks (P.s "decks")
        , P.map Deck (P.s "deck" </> P.string)
        , P.map Games (P.s "games")
        , P.map Game (P.s "game" </> P.int)
        ]
