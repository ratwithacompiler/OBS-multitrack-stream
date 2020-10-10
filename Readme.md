#### Multi Track Stream Audio

Allows having two separate audio tracks on Twitch, one for live viewers and a completely separate one for Twitch VODs.
This uses the multi track audio support Twitch added for their new music tool but which can be used with any audio tracks in OBS.

#### Notes:
Clips made from stream still use the stream audio for now but Twitch plans to change that in the future according to their FAQ page for the music tool.

Sometimes it just doesn't seem to work and the VOD also just has the stream audio. Still in beta so hopefully should all be fixed soon. 

In order to exclude parts like music they need to be their own separate source in OBS. If all audio (game/browser/music) is captured just via one Desktop Audio Capture it's not possible to exclude a part of it.

Creating separate audio sources is left to the user and can be done in many different ways like capturing applications by themselves, using VoiceMeeter or using some mixer software like GoXLR has.

![OBS Track Mixer](https://i.imgur.com/MKeLFH1.png)

Open the OBS mixer via `OBS -> Edit -> Advanced Audio Properties`. In this example stream would hear all sources including `Music` while the VOD would not have the audio from the `Music` source.
Uncheck `Active Sources Only` in order to not miss sources from other scenes.

#### Installation:

* Download [multi_track_stream_audio.lua (right click, save as)](https://raw.githubusercontent.com/ratwithacompiler/OBS-multitrack-stream/master/src/multi_track_stream_audio.lua) and save it somewhere the file won't be moved
    * If the file is moved or renamed after adding it to OBS it will stop working until re-added.
* Go to `OBS -> Tools -> Scripts`
* Click `+` Button bottom left
* Select the downloaded file `multi_track_stream_audio.lua` and add it
* The script settings should be visible now

Select whatever OBS Audio Track you want Twitch to use for VODs. Track 1 is what OBS uses for stream by default so using 2 for VODs usually makes the most sense. Audio Bitrate 160 is the default OBS uses for streams and should be good. 

Select which sources are audible on which tracks in OBS via the mixer in `OBS -> Edit -> Advanced Audio Properties` or right clicking any audio source.

![Script Settings](https://i.imgur.com/B6WpmbT.png)

