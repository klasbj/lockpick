module Data.Match exposing (Format(..), Match, MatchResult(..), Variant(..), addGames, bestOfXMatch, format, games, matchResult, players, score, seriesMatch, singleGameMatch, variant)

import Data.Deck exposing (Deck)
import Data.Game exposing (Game)
import Data.Player exposing (Player)


type Format
    = Archon
    | Sealed


type Variant
    = BestOf Int
    | SingleGame
    | Series


type Match
    = Match Format Variant ( Player, Deck ) ( Player, Deck ) (List Game)


type MatchResult
    = Winner Player
    | Draw
    | InProgress
    | Invalid


bestOfXMatch : Int -> Format -> ( Player, Deck ) -> ( Player, Deck ) -> List Game -> Match
bestOfXMatch x f p1 p2 gs =
    Match f (BestOf x) p1 p2 gs


singleGameMatch : Format -> ( Player, Deck ) -> ( Player, Deck ) -> Game -> Match
singleGameMatch f p1 p2 game =
    Match f SingleGame p1 p2 [ game ]


seriesMatch : Format -> ( Player, Deck ) -> ( Player, Deck ) -> List Game -> Match
seriesMatch f p1 p2 gs =
    Match f Series p1 p2 gs


addGames : Match -> List Game -> Match
addGames (Match f v p1 p2 gs) =
    Match f v p1 p2 << (++) gs


games : Match -> List Game
games (Match _ _ _ _ gs) =
    gs


variant : Match -> String
variant (Match _ v _ _ _) =
    case v of
        BestOf x ->
            "Best of " ++ String.fromInt x

        Series ->
            "Series"

        SingleGame ->
            "SingleGame"


format : Match -> Format
format (Match f _ _ _ _) =
    f


players : Match -> ( ( Player, Deck ), ( Player, Deck ) )
players (Match _ _ p1 p2 _) =
    ( p1, p2 )


matchResult : Match -> MatchResult
matchResult m =
    let
        ( score1, score2 ) =
            score m
    in
    case m of
        Match _ SingleGame _ _ [ Data.Game.Game gameData ] ->
            case gameData.result of
                Data.Game.InProgress ->
                    InProgress

                Data.Game.Winner p ->
                    Winner p

        Match _ (BestOf numGames) ( p1, _ ) ( p2, _ ) gs ->
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

        Match _ Series ( p1, _ ) ( p2, _ ) gs ->
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
score (Match _ _ ( p1, _ ) ( p2, _ ) gs) =
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
