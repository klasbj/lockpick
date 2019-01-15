module Data.Game exposing (Game(..), GameData, GameResult(..))

import Data.Deck exposing (Deck)
import Data.Player exposing (Player)


type alias PlayerData = (Player, Deck, Chains)

type alias GameData =
    { players : (PlayerData, PlayerData)
    , result : GameResult
    }


type Game
    = Game GameData


type alias Chains =
    Int


type GameResult
    = Winner Player
    | InProgress
