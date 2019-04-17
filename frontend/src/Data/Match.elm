module Data.Match exposing (Format(..), Match, MatchResult(..), Variant(..), addGames, bestOfXMatch, format, games, id, matchResult, players, score, seriesMatch, singleGameMatch, variant)

import Data.Deck exposing (Deck)
import Data.Game exposing (Game)
import Data.Id exposing (Id)
import Data.Player exposing (Player)


type Format
    = Archon
    | Sealed


type Variant
    = BestOf Int
    | SingleGame
    | Series


type Match
    = Match Id Format Variant ( Player, Deck ) ( Player, Deck ) (List Game)


matchData =
    """
{ "matches":
  [ { "id": "123-443"
    , "format": "archon"
    , "variant":    { "type": "bestof"
                    , "numGames": 3
                    , "players":
                        [ {"playerId": "f018682e-a0a3-4a29-8e7d-aefaf7ef871f", "deckId": "de866e4e-7080-4103-91d6-df36a2ed2c89"}
                        , {"playerId": "6a08cff5-a1be-4c00-8fd7-d1d33fc2c7a3", "deckId": "da5113b8-9947-4104-bf64-da8e1275deac"}
                        ]
                    }
    , "games":
        [ { "players":
            [ {"playerId": "f018682e-a0a3-4a29-8e7d-aefaf7ef871f", "deckId": "de866e4e-7080-4103-91d6-df36a2ed2c89", "chains": 0 }
            , {"playerId": "6a08cff5-a1be-4c00-8fd7-d1d33fc2c7a3", "deckId": "da5113b8-9947-4104-bf64-da8e1275deac", "chains": 0 }
            ]
          , "winner": "f018682e-a0a3-4a29-8e7d-aefaf7ef871f"
          , "time": "20190127T204916.000+0000"
          }
        , { "players":
            [ {"playerId": "6a08cff5-a1be-4c00-8fd7-d1d33fc2c7a3", "deckId": "da5113b8-9947-4104-bf64-da8e1275deac", "chains": 0 }
            , {"playerId": "f018682e-a0a3-4a29-8e7d-aefaf7ef871f", "deckId": "de866e4e-7080-4103-91d6-df36a2ed2c89", "chains": 0 }
            ]
          , "winner": "6a08cff5-a1be-4c00-8fd7-d1d33fc2c7a3"
          , "time": "20190127T204916.000+0000"
          }
        , { "players":
            [ {"playerId": "f018682e-a0a3-4a29-8e7d-aefaf7ef871f", "deckId": "de866e4e-7080-4103-91d6-df36a2ed2c89", "chains": 0 }
            , {"playerId": "6a08cff5-a1be-4c00-8fd7-d1d33fc2c7a3", "deckId": "da5113b8-9947-4104-bf64-da8e1275deac", "chains": 0 }
            ]
          , "winner": "6a08cff5-a1be-4c00-8fd7-d1d33fc2c7a3"
          , "time": "20190127T204916.000+0000"
          }
        ]
    }
  ]
, "_refs":
  { "players":
    { "f018682e-a0a3-4a29-8e7d-aefaf7ef871f": { "playerId": "f018682e-a0a3-4a29-8e7d-aefaf7ef871f", "name": "a" }
    , "6a08cff5-a1be-4c00-8fd7-d1d33fc2c7a3": { "playerId": "6a08cff5-a1be-4c00-8fd7-d1d33fc2c7a3", "name": "b" }
    }
  , "decks":
    { "de866e4e-7080-4103-91d6-df36a2ed2c89": { "deckId": "de866e4e-7080-4103-91d6-df36a2ed2c89", "name": "deckA", "houses": ["Dis", "Sanctum", "Mars"], "chains": 0 }
    , "da5113b8-9947-4104-bf64-da8e1275deac": { "deckId": "da5113b8-9947-4104-bf64-da8e1275deac", "name": "deckB", "houses": ["Mars", "Brobnar", "Shadows"], "chains": 0 }
    }
  }
}
    """


type MatchResult
    = Winner Player
    | Draw
    | InProgress
    | Invalid


bestOfXMatch : Int -> Id -> Format -> ( Player, Deck ) -> ( Player, Deck ) -> List Game -> Match
bestOfXMatch x i f p1 p2 gs =
    Match i f (BestOf x) p1 p2 gs


singleGameMatch : Id -> Format -> ( Player, Deck ) -> ( Player, Deck ) -> Game -> Match
singleGameMatch i f p1 p2 game =
    Match i f SingleGame p1 p2 [ game ]


seriesMatch : Id -> Format -> ( Player, Deck ) -> ( Player, Deck ) -> List Game -> Match
seriesMatch i f p1 p2 gs =
    Match i f Series p1 p2 gs


addGames : Match -> List Game -> Match
addGames (Match i f v p1 p2 gs) =
    Match i f v p1 p2 << (++) gs


games : Match -> List Game
games (Match _ _ _ _ _ gs) =
    gs


variant : Match -> String
variant (Match _ _ v _ _ _) =
    case v of
        BestOf x ->
            "Best of " ++ String.fromInt x

        Series ->
            "Series"

        SingleGame ->
            "SingleGame"


format : Match -> Format
format (Match _ f _ _ _ _) =
    f


players : Match -> ( ( Player, Deck ), ( Player, Deck ) )
players (Match _ _ _ p1 p2 _) =
    ( p1, p2 )


id : Match -> Id
id (Match i _ _ _ _ _) =
    i


matchResult : Match -> MatchResult
matchResult m =
    let
        ( score1, score2 ) =
            score m
    in
    case m of
        Match _ _ SingleGame _ _ [ Data.Game.Game gameData ] ->
            case gameData.result of
                Data.Game.InProgress ->
                    InProgress

                Data.Game.Winner p ->
                    Winner p

        Match _ _ (BestOf numGames) ( p1, _ ) ( p2, _ ) gs ->
            let
                targetScore =
                    (numGames + 1) // 2
            in
            if score1 > targetScore || score2 > targetScore then
                Invalid

            else if score1 == targetScore then
                Winner p1

            else if score2 == targetScore then
                Winner p2

            else
                InProgress

        Match _ _ Series ( p1, _ ) ( p2, _ ) gs ->
            if List.any (\(Data.Game.Game { result }) -> result == Data.Game.InProgress) gs then
                InProgress

            else if score1 > score2 then
                Winner p1

            else if score2 > score1 then
                Winner p2

            else
                Draw

        _ ->
            Invalid


score : Match -> ( Int, Int )
score (Match _ _ _ ( p1, _ ) ( p2, _ ) gs) =
    let
        gameScore (Data.Game.Game { result }) =
            case result of
                Data.Game.Winner p ->
                    if p == p1 then
                        ( 1, 0 )

                    else if p == p2 then
                        ( 0, 1 )

                    else
                        ( 0, 0 )

                _ ->
                    ( 0, 0 )

        add : ( Int, Int ) -> ( Int, Int ) -> ( Int, Int )
        add ( a1, b1 ) ( a2, b2 ) =
            ( a1 + a2, b1 + b2 )
    in
    List.foldl add ( 0, 0 ) <| List.map gameScore gs
