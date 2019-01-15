module Data.MatchResult exposing (Finished, InProgress, Invalid, MatchResult)

import Data.Game exposing (Game)
import Data.Player exposing (Player)
import Data.Variant as Variant exposing (Variant)


type MatchResult status
    = MatchResult Variant (List Game)


type Invalid
    = Invalid


type InProgress
    = InProgress


type Finished
    = Winner Player
    | Draw
