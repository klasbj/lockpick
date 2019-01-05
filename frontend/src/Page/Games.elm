module Page.Games exposing (Model, Msg, init, toSession, update, view)

import Html exposing (..)
import Html.Attributes as Attr
import Session exposing (Session)
import Task



-- MODEL


type alias Model =
    { session : Session
    , games : List Game
    }


type alias Game =
    { firstPlayer : Player
    , secondPlayer : Player
    , winner : Winner
    }


type alias Player =
    { playerName : String
    , deck : Deck
    , chains : Int
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


toSession : Model -> Session
toSession m =
    m.session


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session, games = [] }, Task.perform identity <| Task.succeed LoadGames )



-- UPDATE


type Msg
    = LoadGames


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadGames ->
            ( { model
                | games =
                    [ { firstPlayer = player "a" "deckA" "123" Dis Sanctum Mars 0
                      , secondPlayer = player "b" "deckB" "543" Mars Brobnar Shadows 0
                      , winner = SecondPlayer
                      }
                    , { firstPlayer = player "a" "deckB" "543" Mars Brobnar Shadows 0
                      , secondPlayer = player "b" "deckA" "123" Dis Sanctum Mars 0
                      , winner = FirstPlayer
                      }
                    , { firstPlayer = player "b" "deckB" "543" Mars Brobnar Shadows 12
                      , secondPlayer = player "a" "deckA" "123" Dis Sanctum Mars 0
                      , winner = FirstPlayer
                      }
                    ]
              }
            , Cmd.none
            )


player name deckName deckId h1 h2 h3 chains =
    { playerName = name
    , deck =
        { name = deckName
        , id = deckId
        , houses = Houses h1 h2 h3
        }
    , chains = chains
    }



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Games"
    , content =
        div []
            [ p [] [ text "Games all around" ]
            , viewGameTable model.games
            ]
    }


viewGameTable : List Game -> Html Msg
viewGameTable games =
    div [ Attr.class "gametable" ]
        [ table []
            ((tr [] <| List.map headerCell [ "Player", "Deck", "Chains", "vs", "Player", "Deck", "Chains" ]) :: List.map gameRow games)
        ]


headerCell s =
    th [] [ text s ]


gameRow { firstPlayer, secondPlayer, winner } =
    tr [] <| playerAndDeck firstPlayer (winner == FirstPlayer) ++ [td [] []] ++ playerAndDeck secondPlayer (winner == SecondPlayer)


playerAndDeck : Player -> Bool -> List (Html Msg)
playerAndDeck { playerName, deck, chains } isWinner =
    let
        cell s =
            td [ Attr.classList [ ("game-result", True), ( "winner", isWinner ) ] ] [ text s ]
    in
    [ cell playerName, cell deck.name, cell (String.fromInt chains) ]
