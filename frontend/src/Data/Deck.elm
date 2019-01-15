module Data.Deck exposing (Deck(..), House(..), Id(..), Name)


type Deck
    = Deck
        { id : Id
        , name : Name
        , houses : ( House, House, House )
        }


type alias Name =
    String


type Id
    = Guid String


type House
    = Dis
    | Sanctum
    | Brobnar
    | Logos
    | Mars
    | Untamed
    | Shadows
