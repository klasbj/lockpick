module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Route
import Session exposing (Session)
import Url exposing (Url)



-- MODEL


type Model
    = Index Session
    | NotFound Session


init : flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        _ =
            Debug.log "" (Route.fromUrl url)
    in
    changePageTo (Session.fromNavKey key) (Route.fromUrl url)


changePageTo : Session -> Maybe Route.Route -> ( Model, Cmd Msg )
changePageTo session route =
    case route of
        Nothing ->
            ( NotFound session, Cmd.none )

        Just Route.Index ->
            ( Index session, Cmd.none )

        Just (Route.Deck _) ->
            ( Index session, Cmd.none )

        Just Route.Decks ->
            ( Index session, Cmd.none )

        Just (Route.Game _) ->
            ( Index session, Cmd.none )

        Just Route.Games ->
            ( Index session, Cmd.none )


toSession : Model -> Session
toSession model =
    case model of
        Index s ->
            s

        NotFound s ->
            s



-- UPDATE


type Msg
    = UrlRequest Browser.UrlRequest
    | UrlChange Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        session =
            toSession model
    in
    case msg of
        UrlRequest urlrequest ->
            case urlrequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl (Session.navKey session) <| Url.toString url )

                Browser.External url ->
                    ( model, Nav.load url )

        UrlChange url ->
            changePageTo session (Route.fromUrl url)



-- VIEW


view : Model -> Html Msg
view model =
    case model of
        Index _ ->
            header [ Attr.class "header" ]
                [ nav []
                    [ a [ Route.href Route.Index ] [ text "Home" ]
                    , a [ Route.href Route.Games ] [ text "Games" ]
                    , a [ Route.href Route.Decks ] [ text "Decks" ]
                    , a [ Attr.href "/borked" ] [ text "Borked" ]
                    ]
                ]

        NotFound _ ->
            div []
                [ p [] [ text "Page not found" ]
                , p [] [ a [ Route.href Route.Index ] [ text "Home" ] ]
                ]


viewDoc : Model -> Browser.Document Msg
viewDoc model =
    { title = "Title"
    , body = [ view model ]
    }



-- SUBS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = viewDoc
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = UrlRequest
        , onUrlChange = UrlChange
        }
