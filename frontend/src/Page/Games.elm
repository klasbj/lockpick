module Page.Games exposing (Model, Msg, init, toSession, update, view)

import Data.Deck exposing (Deck(..), House(..))
import Data.Game
import Data.Match as Match exposing (Match)
import Data.Player exposing (Player(..))
import Html exposing (..)
import Html.Attributes as Attr
import Session exposing (Session)
import Task



-- MODEL


type alias Model =
    { session : Session
    , matches : List Match
    }


toSession : Model -> Session
toSession m =
    m.session


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session, matches = [] }, Task.perform identity <| Task.succeed LoadGames )



-- UPDATE


type Msg
    = LoadGames


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadGames ->
            ( { model
                | matches =
                    let
                        deckA =
                            makeDeck "deckA" "123" Dis Sanctum Mars

                        deckB =
                            makeDeck "deckB" "543" Mars Brobnar Shadows

                        deckC =
                            makeDeck "deckC" "9" Sanctum Shadows Brobnar

                        deckD =
                            makeDeck "deckD" "34" Untamed Logos Dis
                    in
                    [ Match.bestOfXMatch 3
                        Match.Archon
                        (player "a" deckA)
                        (player "b" deckB)
                        [ game (player "a" deckA) (player "b" deckB) "a"
                        , game (player "a" deckA) (player "b" deckB) "b"
                        , game (player "a" deckA) (player "b" deckB) "b"
                        ]

                    --, BestOfThree Archon (player "a" deckA) (player "b" deckB) (Just SecondPlayer) (Just SecondPlayer) Nothing
                    --, SingleGame Sealed (player "c" deckC) (player "d" deckD) (Just SecondPlayer)
                    ]
              }
            , Cmd.none
            )


makeDeck name id h1 h2 h3 =
    Deck { id = Data.Deck.Guid id, name = name, houses = ( h1, h2, h3 ) }


player name deck =
    ( Player name, deck )


game : ( Player, Deck ) -> ( Player, Deck ) -> String -> Data.Game.Game
game ( p1, d1 ) ( p2, d2 ) winner =
    Data.Game.Game <| Data.Game.GameData ( ( p1, d1, 0 ), ( p2, d2, 0 ) ) (Data.Game.Winner (Player winner))



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Games"
    , content =
        div []
            [ p [] [ text "Games all around" ]
            , viewMatches model.matches
            ]
    }


viewMatches : List Match -> Html Msg
viewMatches matches =
    ul [ Attr.class "matchlist" ] <|
        List.map viewMatch matches


viewMatch : Match -> Html Msg
viewMatch match =
    let
        row description format elems =
            li [] [ div [] <| small [] [ text description, text " ", viewFormat format ] :: elems ]

        viewPlayers ( p1, p2 ) score result =
            div [ Attr.class "Players" ]
                [ viewPlayer p1 result
                , viewScore score
                , viewPlayer p2 result
                ]

        viewPlayerName (Player name) =
            text name

        viewPlayer ( p, deck ) result =
            div [ Attr.classList [ ( "Player", True ), ( "Winner", result == Match.Winner p ) ] ]
                [ div [ Attr.class "PlayerName" ] [ viewPlayerName p ]
                , viewDeck deck
                ]

        viewDeck : Deck -> Html Msg
        viewDeck (Deck deckData) =
            div [ Attr.class "Deck" ] [ small [] [ text deckData.name ] ]

        viewScore ( score1, score2 ) =
            div [ Attr.class "Scores" ] [ text <| String.fromInt score1 ++ " – " ++ String.fromInt score2 ]
    in
    row (Match.variant match)
        (Match.format match)
        [ viewPlayers (Match.players match) (Match.score match) (Match.matchResult match)
        ]


viewFormat : Match.Format -> Html Msg
viewFormat f =
    case f of
        Match.Archon ->
            text "Archon"

        Match.Sealed ->
            text "Sealed"
