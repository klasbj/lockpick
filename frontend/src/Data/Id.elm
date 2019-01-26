module Data.Id exposing (Id(..), Set, empty, insert, member, remove)

import Set as OgSet


type Id
    = Guid String
    | Numeric Int


type Set
    = Set (OgSet.Set String) (OgSet.Set Int)


empty =
    Set OgSet.empty OgSet.empty


member : Id -> Set -> Bool
member m (Set guids nums) =
    case m of
        Guid g ->
            OgSet.member g guids

        Numeric i ->
            OgSet.member i nums


insert : Id -> Set -> Set
insert m (Set guids nums) =
    case m of
        Guid g ->
            Set (OgSet.insert g guids) nums

        Numeric i ->
            Set guids (OgSet.insert i nums)


remove : Id -> Set -> Set
remove m (Set guids nums) =
    case m of
        Guid g ->
            Set (OgSet.remove g guids) nums

        Numeric i ->
            Set guids (OgSet.remove i nums)
