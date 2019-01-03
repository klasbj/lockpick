module Main exposing (main)
import Browser
import Html exposing (..)
import Html.Events exposing (onClick)

-- MODEL

type alias Model = Int

init : Model
init =
    0

-- UPDATE

type Msg = Reset | Increment

update : Msg -> Model -> Model
update msg model =
    case msg of
        Reset -> 0
        Increment -> model + 1

-- VIEW

view : Model -> Html Msg
view model =
    div [] [
          p [] [text ("woo " ++ String.fromInt model)]
        , button [onClick Increment] [text "+"]
        , button [onClick Reset] [text "Reset"]
    ]

-- SUBS
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

main =
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }