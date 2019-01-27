module Page.Games exposing (Model, Msg, init, toSession, update, view)

import Data.Deck exposing (Deck(..), House(..))
import Data.Game as Game exposing (Game(..))
import Data.Id as Id exposing (Id)
import Data.Match as Match exposing (Match)
import Data.Player as Player exposing (Player(..))
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events as Events
import Session exposing (Session)
import Set exposing (Set)
import Task



-- MODEL


type alias Model =
    { session : Session
    , matches : List Match
    , expanded : Id.Set
    }


toSession : Model -> Session
toSession m =
    m.session


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session, matches = [], expanded = Id.empty }, Task.perform identity <| Task.succeed LoadGames )



-- UPDATE


type Msg
    = LoadGames
    | ToggleDetails Id


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
                        (Id.Guid "m1")
                        Match.Archon
                        (player "a" deckA)
                        (player "b" deckB)
                        [ makeGame (player "a" deckA) (player "b" deckB) "a"
                        , makeGame (player "b" deckB) (player "a" deckA) "b"
                        , makeGame (player "a" deckA) (player "b" deckB) "b"
                        ]

                    --, BestOfThree Archon (player "a" deckA) (player "b" deckB) (Just SecondPlayer) (Just SecondPlayer) Nothing
                    --, SingleGame Sealed (player "c" deckC) (player "d" deckD) (Just SecondPlayer)
                    ]
              }
            , Cmd.none
            )

        ToggleDetails id ->
            if Id.member id model.expanded then
                ( { model | expanded = Id.remove id model.expanded }, Cmd.none )

            else
                ( { model | expanded = Id.insert id model.expanded }, Cmd.none )


makeDeck name id h1 h2 h3 =
    Deck { id = Data.Deck.Guid id, name = name, houses = ( h1, h2, h3 ) }


player name deck =
    ( Player name, deck )


makeGame : ( Player, Deck ) -> ( Player, Deck ) -> String -> Game
makeGame ( p1, d1 ) ( p2, d2 ) winner =
    Game <| Game.GameData ( ( p1, d1, 0 ), ( p2, d2, 0 ) ) (Game.Winner (Player winner))



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Games"
    , content =
        div []
            [ p [] [ text "Games all around" ]
            , viewMatches model.expanded model.matches
            ]
    }


viewMatches : Id.Set -> List Match -> Html Msg
viewMatches expanded matches =
    ul [ Attr.class "matchlist" ] <|
        List.map (viewMatch expanded) matches


viewMatch : Id.Set -> Match -> Html Msg
viewMatch expanded match =
    let
        showDetails =
            Id.member (Match.id match) expanded

        row elems =
            li [ Attr.classList [ ( "Match", True ), ( "Expanded", showDetails ), ( "Unexpanded", not showDetails ) ] ] elems

        viewPlayers ( p1, p2 ) score result =
            div [ Attr.class "Players" ]
                [ viewPlayer p1 result
                , viewScore score
                , viewPlayer p2 result
                ]

        viewPlayer ( p, deck ) result =
            div [ Attr.classList [ ( "Player", True ), ( "Winner", result == Match.Winner p ) ] ]
                [ div [ Attr.class "PlayerName" ] [ text <| Player.name p ]
                , viewDeck deck
                ]

        viewDeck : Deck -> Html Msg
        viewDeck (Deck deckData) =
            div [ Attr.class "Deck" ] [ small [] [ text deckData.name ] ]

        viewScore ( score1, score2 ) =
            div [ Attr.class "Scores" ] [ text <| String.fromInt score1 ++ " – " ++ String.fromInt score2 ]
    in
    row
        [ viewPlayers (Match.players match) (Match.score match) (Match.matchResult match)
        , div [ Attr.class "Format" ] [ text (Match.variant match), text " ", viewFormat (Match.format match) ]
        , viewGames match
        , div [ Attr.class "ExpandButton", Events.onClick <| ToggleDetails <| Match.id match ] [ text "▼" ]
        ]


viewFormat : Match.Format -> Html Msg
viewFormat f =
    case f of
        Match.Archon ->
            text "Archon"

        Match.Sealed ->
            text "Sealed"


viewGames : Match -> Html Msg
viewGames match =
    let
        leftPlayer =
            Tuple.first << Tuple.first << Match.players <| match

        rightPlayer =
            Tuple.first << Tuple.second << Match.players <| match

        games =
            List.map (viewGame leftPlayer rightPlayer) <| Match.games match
    in
    ul [ Attr.class "GamesList" ]
        games


viewGame : Player -> Player -> Game -> Html Msg
viewGame leftPlayer rightPlayer (Game gameData) =
    let
        ( ( startingPlayer, _, _ ), ( secondPlayer, _, _ ) ) =
            gameData.players

        ( leftData, rightData ) =
            if leftPlayer == startingPlayer then
                gameData.players

            else
                ( Tuple.second gameData.players, Tuple.first gameData.players )
    in
    viewGame2 leftData rightData startingPlayer gameData.result


viewGame2 : ( Player, Deck, Game.Chains ) -> ( Player, Deck, Game.Chains ) -> Player -> Game.GameResult -> Html Msg
viewGame2 ( player1, deck1, chains1 ) ( player2, deck2, chains2 ) startingPlayer winner =
    let
        score =
            case winner of
                Game.Winner winningPlayer ->
                    if winningPlayer == player1 then
                        text "1 – 0"

                    else
                        text "0 – 1"

                Game.InProgress ->
                    text "0 – 0"

        viewPlayer ( p, Deck d, c ) =
            let
                chains =
                    if c > 0 then
                        span [ Attr.class "Chains" ] [ text <| String.fromInt c ]

                    else
                        text ""
            in
            div [ Attr.classList [ ( "Player", True ), ( "StartingPlayer", startingPlayer == p ) ] ]
                [ chains
                , text d.name
                ]
    in
    div [ Attr.class "GameResult" ]
        [ viewPlayer ( player1, deck1, chains1 )
        , div [ Attr.class "Scores" ] [ score ]
        , viewPlayer ( player2, deck2, chains2 )
        ]
