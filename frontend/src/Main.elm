module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Page
import Page.Games as Games
import Route
import Session exposing (Session)
import Url exposing (Url)



-- MODEL


type Model
    = Index Session
    | NotFound Session
    | Games Games.Model
    | Decks Session


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
            ( Decks session, Cmd.none )

        Just Route.Decks ->
            ( Decks session, Cmd.none )

        Just (Route.Game _) ->
            Games.init session
                |> wrapWith Games GamesMsg

        Just Route.Games ->
            Games.init session
                |> wrapWith Games GamesMsg


wrapWith : (subModel -> Model) -> (subMsg -> Msg) -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
wrapWith wrapModel wrapCmd ( model, cmd ) =
    ( wrapModel model, Cmd.map wrapCmd cmd )


toSession : Model -> Session
toSession model =
    case model of
        Index s ->
            s

        NotFound s ->
            s

        Games m ->
            Games.toSession m

        Decks s ->
            s



-- UPDATE


type Msg
    = UrlRequest Browser.UrlRequest
    | UrlChange Url
    | GamesMsg Games.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update outerMessage outerModel =
    let
        session =
            toSession outerModel
    in
    case ( outerMessage, outerModel ) of
        ( UrlRequest urlrequest, _ ) ->
            case urlrequest of
                Browser.Internal url ->
                    ( outerModel, Nav.pushUrl (Session.navKey session) <| Url.toString url )

                Browser.External url ->
                    ( outerModel, Nav.load url )

        ( UrlChange url, _ ) ->
            changePageTo session (Route.fromUrl url)

        ( GamesMsg msg, Games model ) ->
            Games.update msg model
                |> wrapWith Games GamesMsg

        _ ->
            ( outerModel, Cmd.none )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        viewPage page toMsg data =
            let
                { title, body } =
                    Page.view page data
            in
            { title = title, body = List.map (Html.map toMsg) body }
    in
    case model of
        Index _ ->
            Page.view Page.Home { title = "Home", content = p [] [ text "helo" ] }

        NotFound _ ->
            Page.view Page.Other { title = "Page Not Found", content = p [] [ text "Page not found" ] }

        Games m ->
            viewPage Page.Games GamesMsg (Games.view m)

        Decks _ ->
            Page.view Page.Decks { title = "Decks", content = p [] [ text "Decks" ] }



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
