function initToneAdapter(worker) {
  const synths = {
    1: new Tone.AMSynth(),
    2: new Tone.FMSynth(),
    3: new Tone.MembraneSynth()
  }
  
  function subscribe() {
    worker.ports.sendSongData.subscribe(async (songTracks) => {
      await Tone.start()
      const now = Tone.now()

      let iteration = 0
      const loop = new Tone.Loop(function (time) {
        songTracks.forEach(track => {
          play(track, time, iteration)
        })

        iteration++
      }, '8n')

      const longestTrack = songTracks.sort((t1, t2) => (
        t2.actions.length - t1.actions.length
      ))[0]

      loop.iterations = longestTrack.actions.length
      loop.start(now)

      Tone.Transport.start()
    })
  }

  function play(track, time, iteration) {
    const { actions, instrument } = track

    const synth  = synths[instrument].toDestination()
    const action = actions[iteration]

    if (action == 'X')
      synth.triggerAttackRelease('C2', '8n', time)
  }
  
  subscribe()

  return {
    playSong(name) {
      worker.ports.playSong.send(name)
    }
  }
}