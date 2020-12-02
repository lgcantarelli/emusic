module EmusicWorker exposing (main)

import Emusic exposing (..)


mySong =
    Song
        [ Track FMSynth (MPattern (repeat 3 [ X, O, X, O, X, O, X, O ]))
        , Track AMSynth (MPattern (repeat 3 [ O, X, O, X, O, O, O, O ]))
        , Track MBSynth (MPattern (repeat 3 [ X, O, X, O, O, X, O, O ]))
        ]


anotherSong =
  Song
      [ Track MBSynth (MPattern (repeat 2 [ X, X, X, O, O, X ]))
      , Track MBSynth (MPattern (repeat 4 [ X, O, X, O, X, X ]))
      , Track AMSynth (MPattern (repeat 4 [ O, X, O, X, O, O ]))
      , Track FMSynth (MPattern (repeat 8 [ X, X, O, O, X, O ]))
      ]


registerSongs : () -> ( Model, Cmd Msg )
registerSongs _ =
    init
        [ SongIdentifier "mySong" mySong
        , SongIdentifier "anotherSong" anotherSong
        ]


main : Program () Model Msg
main =
    Platform.worker
        { init = registerSongs
        , update = update
        , subscriptions = subscriptions
        }
