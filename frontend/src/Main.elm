module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Page
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


view : Model -> Browser.Document Msg
view model =
    case model of
        Index _ ->
            Page.view Page.Home { title = "Home", content = p [] [ text "helo" ] }

        NotFound _ ->
            Page.view Page.Other { title = "Page Not Found", content = p [] [ text "Page not found" ] }



-- SUBS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = UrlRequest
        , onUrlChange = UrlChange
        }
