module Data.Player exposing (Name, Player(..), name)


type alias Name =
    String


type Player
    = Player Name


name (Player n) =
    n
