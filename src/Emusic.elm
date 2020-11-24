port module Emusic exposing
    ( Instrument(..), MAction(..), MPattern(..), Song(..), Track(..)
    , repeat
    , Model, Msg, SongData, SongIdentifier, TrackObject, init, subscriptions, update
    )

{-| DSL that implements the music patterns and functions to make it easy
to write music and parse its structures to send to browser.


# Custom types

@docs Instrument, MAction, MPattern, Song, Track


# Play a song

@docs play


# Repeat a track

@docs repeat

-}

-- EMUSIC LIB


type MAction
    = X
    | O


type MPattern
    = MPattern (List MAction)


type Instrument
    = AMSynth
    | FMSynth
    | MBSynth


type Track
    = Track Instrument MPattern


type Song
    = Song (List Track)


type alias TrackObject =
    { instrument : Int
    , actions : List String
    }


type alias SongData =
    List TrackObject



-- API


repeat : Int -> List MAction -> List MAction
repeat n drumActions =
    if n <= 1 then
        drumActions

    else
        drumActions ++ repeat (n - 1) drumActions



-- DATA PROCESSORS


play : List SongIdentifier -> SongName -> SongData
play songIdentifiers songName =
    parseData (findSong songIdentifiers songName)


findSong : List SongIdentifier -> SongName -> Song
findSong songIdentifiers songName =
    case songIdentifiers of
        [] ->
            Song []

        songIdentifier :: otherIdentifiers ->
            if songIdentifier.songName == songName then
                songIdentifier.song

            else
                findSong otherIdentifiers songName


parseData : Song -> SongData
parseData song =
    case song of
        Song [] ->
            []

        Song (track :: otherTracks) ->
            [ toObject track ] ++ parseData (Song otherTracks)


toObject : Track -> TrackObject
toObject (Track instrument drumPattern) =
    TrackObject (code instrument) (toStringList drumPattern)


code : Instrument -> Int
code instrument =
    case instrument of
        AMSynth ->
            1

        FMSynth ->
            2

        MBSynth ->
            3


toStringList : MPattern -> List String
toStringList drumPattern =
    case drumPattern of
        MPattern [] ->
            []

        MPattern (mp :: mps) ->
            [ toString mp ] ++ toStringList (MPattern mps)


toString : MAction -> String
toString drumAction =
    case drumAction of
        X ->
            "X"

        O ->
            "O"



-- MODULE INTERFACE


type alias SongName =
    String


type alias SongIdentifier =
    { songName : SongName, song : Song }


type alias Model =
    { songs : List SongIdentifier, currentSong : SongName }


type Msg
    = Play SongName
    | Stop



-- API


init : List SongIdentifier -> ( Model, Cmd Msg )
init songIdentifiers =
    ( Model songIdentifiers "", Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Play songName ->
            ( { model | currentSong = songName }, sendSongData (play model.songs songName) )

        Stop ->
            ( { model | currentSong = "" }, sendSongData [ TrackObject 0 [ "" ] ] )



-- PORTS


port sendSongData : SongData -> Cmd msg


port playSong : (SongName -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions songName =
    playSong Play
