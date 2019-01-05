module Page exposing (Page(..), view)

import Browser
import Html exposing (..)
import Html.Attributes as Attr
import Route exposing (Route)


type Page
    = Other
    | Home
    | Decks
    | Games


view : Page -> { title : String, content : Html msg } -> Browser.Document msg
view page { title, content } =
    { title = title
    , body = [ viewHeader page, div [ Attr.class "main" ] [ content ] ]
    }


viewHeader : Page -> Html msg
viewHeader page =
    let
        link ( route, s ) =
            navLink page route [ text s ]
    in
    header []
        [ nav [] <|
            a [ Attr.href "/borked" ] [ text "Borked" ]
                :: List.map link [ ( Route.Index, "Home" ), ( Route.Games, "Games" ), ( Route.Decks, "Decks" ) ]
        ]


navLink : Page -> Route -> (List (Html msg) -> Html msg)
navLink page target =
    a [ Route.href target, Attr.classList [ ( "active", isActive page target ) ] ]


isActive : Page -> Route -> Bool
isActive page target =
    case ( page, target ) of
        ( Home, Route.Index ) ->
            True

        ( Games, Route.Games ) ->
            True

        ( Decks, Route.Decks ) ->
            True

        _ ->
            False
