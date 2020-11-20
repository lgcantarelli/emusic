module Emusic exposing
    ( Instrument(..), MAction(..), MPattern(..), Song(..), Track(..)
    , play
    , repeat
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


repeat : Int -> List MAction -> List MAction
repeat n drumActions =
    if n <= 1 then
        drumActions

    else
        drumActions ++ repeat (n - 1) drumActions


type alias TrackObject =
    { instrument : Int
    , actions : List String
    }


type alias SongData =
    List TrackObject


play : Song -> SongData
play song =
    parseData song


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

        MPattern (dp :: dps) ->
            [ toString dp ] ++ toStringList (MPattern dps)


toString : MAction -> String
toString drumAction =
    case drumAction of
        X ->
            "X"

        O ->
            "O"
