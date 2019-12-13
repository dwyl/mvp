module Main exposing (main)

import Browser
import Html exposing (Html, button, div, p, text, textarea)
import Html.Attributes exposing (class, value)
import Html.Events exposing (onClick, onInput)
import Http exposing (..)
import Json.Decode as JD
import Json.Encode as JE


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- Model containg the capture text


type alias Model =
    { capture : String, message : String }



-- Msg


type Msg
    = Capture String
    | CreateCapture
    | SaveCaptureResult (Result Http.Error String)



-- init


initModel : Model
initModel =
    { capture = "", message = "" }


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

        CreateCapture ->
            ( model, saveCapture model.capture )

        SaveCaptureResult (Ok response) ->
            ( { model | capture = "", message = "Capture saved" }, Cmd.none )

        SaveCaptureResult (Err e) ->
            ( { model | message = "The capture couldn't be saved" }, Cmd.none )


saveCapture : String -> Cmd Msg
saveCapture capture =
    Http.post
        { url = "/api/captures/create"
        , body = Http.jsonBody (captureEncode capture)
        , expect = Http.expectJson SaveCaptureResult captureDecoder
        }


captureEncode : String -> JE.Value
captureEncode capture =
    JE.object [ ( "text", JE.string capture ) ]


captureDecoder : JD.Decoder String
captureDecoder =
    JD.field "text" JD.string


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Html Msg
view model =
    div []
        [ p [] [ text model.message ]
        , textarea [ onInput Capture, value model.capture ] []
        , button [ class "db", onClick CreateCapture ] [ text "Save capture" ]
        ]
