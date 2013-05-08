# hubot-spotify

this is just @davidvanleeuwen's [original
hubot-spotify](https://github.com/davidvanleeuwen/hubot-spotify), but it is
installed and versioned as an npm package. not really fancy at the moment, but
it does the job. thanks for the opensource AppleScripts and @dennus / @drblok.

## setup

you'll need to be running hubot on mac os x with Spotify.app installed. add
this as a dependency to your hubot:

    $ npm install --save hubot-spotify

and add it to the list of external dependencies in `external-scripts.json`:

    ["hubot-spotify"]

## Current commands

 - play <1|2|3|query> - Play/pause, play a song that you searched (1,2,3) or play a track by title
 - pause - Pause the current song
 - toggle - Play/pause the current song
 - stop - Stop current song
 - next - Play the next song from the playlist
 - previous - Play the previous song from the playlist
 - current song - Shows what song I'm currently playing",
 - volume <0..9|up|down> - Change volume using a specific number between 0 (mute) and 9 or by up and down
 - mute - Mute/unmute the sound
 - dj me <track|album|artist> <query> - Search for a track on Spotify and play it
