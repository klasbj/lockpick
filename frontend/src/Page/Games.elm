module Page.Games exposing (Model, Msg, init, toSession, update, view)

import Html exposing (..)
import Html.Attributes as Attr
import Session exposing (Session)
import Task



-- MODEL


type alias Model =
    { session : Session
    , matches : List Match
    }


type Match
    = SingleGame Format Player Player (Maybe Winner)
    | BestOfThree Format Player Player (Maybe Winner) (Maybe Winner) (Maybe Winner)


type alias Player =
    { playerName : String
    , deck : Deck
    }


type alias Deck =
    { name : String
    , id : String
    , houses : Houses
    }


type Houses
    = Houses House House House


type House
    = Dis
    | Sanctum
    | Brobnar
    | Logos
    | Mars
    | Untamed
    | Shadows


type Winner
    = FirstPlayer
    | SecondPlayer


type Format
    = Archon
    | Sealed


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
                    [ BestOfThree Archon (player "a" deckA) (player "b" deckB) (Just SecondPlayer) (Just FirstPlayer) (Just SecondPlayer)
                    , BestOfThree Archon (player "a" deckA) (player "b" deckB) (Just SecondPlayer) (Just SecondPlayer) Nothing
                    , SingleGame Sealed (player "c" deckC) (player "d" deckD) (Just SecondPlayer)
                    ]
              }
            , Cmd.none
            )


makeDeck name id h1 h2 h3 =
    { name = name, id = id, houses = Houses h1 h2 h3 }


player name deck =
    { playerName = name
    , deck = deck
    }



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

        viewPlayers ( p1, p2 ) score winner =
            div []
                [ viewPlayer p1 (winner == Just FirstPlayer)
                , viewScore score
                , viewPlayer p2 (winner == Just SecondPlayer)
                ]

        viewPlayer { playerName, deck } isWinner =
            div [ Attr.classList [ ( "Player", True ), ( "Winner", isWinner ) ] ]
                [ div [ Attr.class "PlayerName" ] [ text playerName ]
                , viewDeck deck
                ]

        viewDeck : Deck -> Html Msg
        viewDeck deck =
            div [ Attr.class "Deck" ] [ small [] [ text deck.name ] ]

        viewScore ( score1, score2 ) =
            div [ Attr.class "Scores" ] [ text <| String.fromInt score1 ++ " \u{2013} " ++ String.fromInt score2 ]
    in
    case match of
        SingleGame format player1 player2 winner ->
            let
                score =
                    if winner == Just FirstPlayer then
                        ( 1, 0 )

                    else
                        ( 0, 1 )
            in
            row "Single game"
                format
                [ viewPlayers ( player1, player2 ) score winner ]

        BestOfThree format player1 player2 game1 game2 game3 ->
            row "Best of three"
                format
                [ viewPlayers ( player1, player2 ) (bo3Score game1 game2 game3) (bo3Winner game1 game2 game3) ]


viewFormat : Format -> Html Msg
viewFormat f =
    case f of
        Archon ->
            text "Archon"

        Sealed ->
            text "Sealed"


bo3Score : Maybe Winner -> Maybe Winner -> Maybe Winner -> ( Int, Int )
bo3Score a b c =
    let
        winners =
            [ a, b, c ]
    in
    ( List.filter ((==) (Just FirstPlayer)) winners |> List.length
    , List.filter ((==) (Just SecondPlayer)) winners |> List.length
    )


bo3Winner : Maybe Winner -> Maybe Winner -> Maybe Winner -> Maybe Winner
bo3Winner a b c =
    case ( a, b, c ) of
        ( Just FirstPlayer, Just FirstPlayer, _ ) ->
            Just FirstPlayer

        ( Just SecondPlayer, Just SecondPlayer, _ ) ->
            Just SecondPlayer

        ( _, _, Just FirstPlayer ) ->
            Just FirstPlayer

        ( _, _, Just SecondPlayer ) ->
            Just SecondPlayer

        ( _, _, _ ) ->
            Nothing
