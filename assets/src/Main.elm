module Main exposing (main)

import Browser
import Html exposing (Html, div, text, textarea)
import Html.Events exposing (onInput)


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- Model containg the capture text


type alias Model =
    { capture : String }



-- Msg


type Msg
    = Capture String



-- init


initModel : Model
initModel =
    { capture = "" }


type alias Flags =
    ()


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( initModel, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Capture text ->
            ( { model | capture = text }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Html Msg
view model =
    div []
        [ textarea [ onInput Capture ] []
        ]
