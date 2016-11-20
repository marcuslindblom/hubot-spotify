# Description:
#   hey i'm a dj for spotify on mac os x
#
# Dependencies:
#   none
#
# Configuration:
#   none
#
# Commands:
#   hubot play <1|2|3|query> - Play/pause, play a song that you searched (1,2,3) or play a track by title
#   hubot pause - Pause the current song
#   hubot toggle - Play/pause the current song
#   hubot stop - Stop current song
#   hubot next - Play the next song from the playlist
#   hubot previous - Play the previous song from the playlist
#   hubot current song - Shows what song I'm currently playing
#   hubot volume <0..9|up|down> - Change volume using a specific number between 0 (mute) and 9 or by up and down
#   hubot mute - Mute/unmute the sound
#   hubot dj me (some) <track|album|artist> <query> - Search for a track on Spotify and play it
#
# Author:
#   David van Leeuwen (http://www.davidvanleeuwen.nl)
#

{join} = require "path"
sh = require "sh"
spotify = require "spotify"

module.exports = (robot) ->
  options = volume: 100

  # controls
  robot.respond /toggle$/i, (msg) ->
    msg.send "Okay, toggling play/pause in Spotify"
    sh('osascript -e \'tell app "Spotify" to playpause\'')
  robot.respond /play$/i, (msg) ->
    msg.send "Playing the current song in Spotify"
    sh('osascript -e \'tell app "Spotify" to playpause\'')
  robot.respond /(pause|stop)$/i, (msg) ->
    msg.send "Pausing the current song in Spotify"
    sh('osascript -e \'tell app "Spotify" to playpause\'')
  robot.respond /(next|play next|play the next song)$/i, (msg) ->
    sh('osascript -e \'tell app "Spotify" to next track\'')
    song = sh("osascript #{join __dirname, "current_song.scpt"}")
    song.result (obj) ->
      msg.send "And now I'm playing "+ obj
  robot.respond /(previous|prev|play previous|play the previous song)$/i, (msg) ->
    sh('osascript -e \'tell app "Spotify" to previous track\'')
    song = sh("osascript #{join __dirname, "current_song.scpt"}")
    song.result (obj) ->
      msg.send "Playing this song again: "+ obj
  robot.respond /volume ((\d{1,2})|up|down)$/i, (msg) ->
    volume = msg.match[1]

    switch volume
      when "up"
        if options.volume < 100
          options.volume+=10
          msg.send "Louder, louder!"
      when "down"
        if options.volume > 0
          options.volume-=10
          msg.send "Ah, I was trying to say it, but nobody could hear me. Oh wait, I don't have a voice"
      else
        if volume < (options.volume/10)
          msg.send "Yes, this is too loud for me"
        else
          msg.send "Turning up the volume! w00t"
        options.volume = Math.round(volume)*10 if volume <= 100

    sh('osascript -e \'tell application "Spotify" to set sound volume to '+options.volume+'\'')
  robot.respond /mute$/i, (msg) ->
    if options.muted
      sh('osascript -e \'tell application "Spotify" to set sound volume to '+options.volume+'\'')
      msg.send "That was a quiet moment"
    else
      sh('osascript -e \'tell application "Spotify" to set sound volume to 0\'')
      msg.send "Silence"
    options.muted = !options.muted
  robot.respond /unmute$/i, (msg) ->
    if options.muted
      sh('osascript -e \'tell application "Spotify" to set sound volume to '+options.volume+'\'')
      msg.send "That was a quiet moment"

  # show what song I'm currently playing
  robot.respond /(current|song|track|current song|current track)$/i, (msg) ->
    song = sh("osascript #{join __dirname, "current_song.scpt"}")
    song.result (obj) ->
      msg.send "The current song I'm playing is "+ obj

  # search through Spotify
  robot.respond /dj\s*me\s+(some\s+)?(track|soong|album|artist)?\s*(.*)$/i, (msg) ->
    query = msg.match[3]
    if msg.match[2]?
      switch msg.match[2]
        when "track" or "song" then type = "track"
        when "album" then type = "album"
        when "artist" then type = "artist"
    else
      type = "track"

    spotify.search
      type: type
      query: query
      (err, data) ->
        unless err
          switch type
            when "track"
              if data.tracks.items.length is 1
                song = data.tracks.items[0]
                msg.send "Found it.. use #{robot.name} play 1 for “#{song.name}” by #{song.artists[0].name}"
                options.result = {first: data.tracks.items[0].uri}
              else if data.tracks.items.length is 2
                msg.send """Use #{robot.name} play 1 for “#{data.tracks.items[0].name}” by #{data.tracks.items[0].artists[0].name}"
                or use #{robot.name} play 2 for “#{data.tracks.items[1].name}” by #{data.tracks.items[1].artists[0].name}
                """
                options.result = {first: data.tracks.items[0].uri, second: data.tracks.items[1].uri}
              else if data.tracks.items.length > 2
                msg.send """Use #{robot.name} play 1 for “#{data.tracks.items[0].name}” by #{data.tracks.items[0].artists[0].name}
                or use #{robot.name} play 2 for “#{data.tracks.items[1].name}” by #{data.tracks.items[1].artists[0].name}
                or play 3 for “#{data.tracks.items[2].name}” by #{data.tracks.items[2].artists[0].name}
                """
                options.result =
                  first: data.tracks.items[0].uri
                  second: data.tracks.items[1].uri
                  third: data.tracks.items[2].uri

            # can't play a song by album or artist at this moment... maybe in the feature
            when "album"
              album = data.albums.items[0]
              if album
                msg.send "Found a album by the name of #{album.name}. Now, to continue this quiz... Can you name a song?"
            when "artist"
              artist = data.artists.items[0]
              if artist
                msg.send "Got it. I found #{artist.name}. Now, to continue this quiz... Can you name a song?"

  # play a track or add a searched song to the play queue and play it
  robot.respond /play (.*)$/i, (msg) ->
    query = msg.match[1]
    switch query
      when "1"
        msg.send "Okay, sure why not"
        sh('osascript -e \'tell application "Spotify" to play track "' + options.result.first + '" \'') if options.result? and options.result.first?
      when "2"
        msg.send "Hah, this is my favorite song"
        sh('osascript -e \'tell application "Spotify" to play track "' + options.result.second + '" \'') if options.result? and options.result.second?
      when "3"
        msg.send "Are you really sure? Okay, I'll play it anyway"
        sh('osascript -e \'tell application "Spotify" to play track "' + options.result.third + '" \'') if options.result? and options.result.third?
      else
        spotify.search
          type: "track"
          query: msg.match[1]
          (err, data) ->
            unless err
              song = data.tracks.items[0]
              if song
                sh('osascript -e \'tell application "Spotify" to play track "' + +song.uri + '" \'')
                msg.send "Found it, playing: “#{song.name}” by #{song.artists[0].name} from #{song.album.name}"
