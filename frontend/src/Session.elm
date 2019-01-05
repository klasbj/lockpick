module Session exposing (Session, navKey, fromNavKey)

import Browser.Navigation as Nav

type Session
    = Guest Nav.Key


navKey : Session -> Nav.Key
navKey s =
    case s of
        Guest key ->
            key

fromNavKey : Nav.Key -> Session
fromNavKey =
    Guest
