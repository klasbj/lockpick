module Page.Games exposing (Model, Msg, toSession, init, update, view)

import Html exposing (..)
import Session exposing (Session)



-- MODEL


type alias Model =
    { session : Session
    }


toSession : Model -> Session
toSession m =
    m.session


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session }, Cmd.none )



-- UPDATE


type Msg
    = None


update : Msg -> Model -> ( Model, Cmd Msg )
update _ model =
    ( model, Cmd.none )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view _ =
    { title = "Games"
    , content = div [] [ p [] [ text "Games all around" ] ]
    }
