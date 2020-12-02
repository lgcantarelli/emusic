module Emusic exposing
    ( Instrument(..), MAction(..), MPattern(..), Song(..), Track(..)
    , repeat
    , Model, Msg(..), SongName, SongData, SongIdentifier, TrackObject, init, update
    )

{-| DSL that implements the music patterns and functions to make it easy
to write music and parse its structures to send to browser.


# Instrument type
@docs Instrument

# MAction type
@docs MAction

# MPattern type
@docs MPattern

# Song type
@docs Song

# Track type
@docs Track

# SongData type
@docs SongData

# SongIdentifier type
@docs SongIdentifier

# SongName type
@docs SongName

# TrackObject type
@docs TrackObject

# Msg type
@docs Msg

# Model type
@docs Model

# Exposed methods
@docs init, update, repeat
-}

-- EMUSIC LIB

{-| Music action
-}
type MAction
    = X
    | O

{-| Music pattern
-}
type MPattern
    = MPattern (List MAction)

{-| Intrument type
-}
type Instrument
    = AMSynth
    | FMSynth
    | MBSynth

{-| Track type
-}
type Track
    = Track Instrument MPattern

{-| Song type
-}
type Song
    = Song (List Track)

{-| Track data to send to JS
-}
type alias TrackObject =
    { instrument : Int
    , actions : List String
    }

{-| Song data to send to JS
-}
type alias SongData =
    List TrackObject



-- API

{-| Repeat action lists
-}
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

{-| Song name type
-}
type alias SongName =
    String

{-| Song identifier type
-}
type alias SongIdentifier =
    { songName : SongName, song : Song }

{-| Model type
-}
type alias Model =
    { songs : List SongIdentifier, currentSong : SongName }

{-| Msg type
-}
type Msg
    = Play SongName
    | Stop



-- API

{-| Init program with a list of song identifiers
-}
init : List SongIdentifier -> ( Model, Cmd Msg )
init songIdentifiers =
    ( Model songIdentifiers "", Cmd.none )

{-| Update program
-}
update : Msg -> Model -> (SongData -> Cmd Msg) -> ( Model, Cmd Msg )
update msg model sendSongData =
    case msg of
        Play songName ->
            ( { model | currentSong = songName }, sendSongData (play model.songs songName) )

        Stop ->
            ( { model | currentSong = "" }, sendSongData [ TrackObject 0 [ "" ] ] )