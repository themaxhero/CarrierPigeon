module Main exposing (..)
import Browser
import Html exposing (..)
import Html.Attributes exposing (..)

type alias Model = ()

initialModel : Model
initialModel = ()

type Msg
  = Ichi
  | Ni

update : Msg -> Model -> (Model, Cmd Msg)
update _ model = (model, Cmd.none)

view : Model -> Html Msg
view _ =
  text "Dipilik de UVA"

subs : Model -> Sub Msg
subs _ =
  Sub.none

main : Program () Model Msg
main =
  Browser.element
    { init = \_ -> (initialModel, Cmd.none)
    , view = view
    , update = update
    , subscriptions = subs
    }