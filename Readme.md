#### Multi Track Stream Audio

Allows having two separate audio tracks on Twitch, one for live viewers and a completely separate one for Twitch VODs.
This uses the multi track audio support Twitch and OBS added for the new Twitch music tool but which can be used with any audio tracks in OBS.

#### Notes:

* Sometimes it just doesn't seem to work and the VOD also just has the stream audio. Still in beta so hopefully should all be fixed soon. 

* **In order to exclude certain parts like music they need to be their own separate source in OBS**. If all audio (game/browser/music) is captured just via a single Desktop Audio Capture or Input Capture it's not possible to exclude a part of it in OBS. 

* The plugin must be set up and enabled before going live, enabling it while already streaming is too late. 

* OBS will have this as a default feature as of the next OBS release.

Creating separate audio sources is left to the user and can be done in many different ways like capturing applications by themselves, using VoiceMeeter, Virtual Audio Cables or using some mixer software like GoXLR has and what's easiest will depend on the specific audio setup used.

![OBS Track Mixer](https://i.imgur.com/MKeLFH1.png)

Open the OBS mixer via `OBS -> Edit -> Advanced Audio Properties`. In this example live viewers would hear Track 1 with all sources including `Music` while the VOD would have Track 2 which has everything except the audio from the `Music` source.
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




##### Example Windows Single PC setup:

If you're on a single PC setup on Windows the easiest way to separate audio is probably using Voicemeeter. 

* play whatever music or audio you don't want on the VOD only to the Voicemeeter virtual audio device not to your default desktop audio device
  * select that virtual sound device for the application either via its settings if it has that or otherwise Windows 10 also now just lets you select separate audio devices for specific applications via "App volume and device properties" settings
* set Voicemeeter itself to play the music/audio going to that device to your headphones and back to the virtual device output
* add a audio input source in OBS that uses that virtual Voicemeeter device as input, call it Music
* in the OBS audio mixer just uncheck that Music source for track 2
* then in the multi track plugin just be sure that track 2 is selected for VOD audio (`OBS -> Tools -> Scripts`)
* now Track 1 with music is what live viewers hear while Track 2 without music is what gets put on the VOD and you still hear the music via voicemeeter

Just one example, there are a million ways that can be done on Windows.

##### Example setup for a 2 PC setup with GoXLR and Spotify both on the gaming PC:

This is just one of a million ways a setup for this could look like. This uses GoXLR connected to the gaming PC to play the music to the headphones but not to stream and then sends the music audio via NDI to the streaming PC so it's available as a separate source that goes to live viewers but not to VOD.

Gaming PC audio:

* use the Music input in GoXLR
* set GoXLR Music as audio device for Spotify (via Windows per App audio settings)
* in GoXLR routing set Music to go to your headphones but not to stream

Variant 1: Without OBS on Gaming PC:

* you can use NDI Scan Converter which is a little desktop tray icon tool NDI makes it easy to send things like mics/webcams/screens and can be used to just only send the music as a separate source to the streaming PC
* it's part of their NDI tools package available for free here https://ndi.tv/tools/
* you don't need to use NDI for anything else like video and NDI Scan Converter takes only around 10MB memory and basically no CPU when just sending audio
* in the Scan Converter tray icon menu set the GoXLR Music device as Webcam Audio Source and make sure Webcam video is None

Variant 2: With OBS on Gaming PC:

* add a Audio Capture Source
* select the Music audio device as input
* mute it
* for that new OBS source go to Filters
* add a NDI Output filter, name it music or whatever you'll recognize 

Streaming PC OBS:

* install OBS NDI plugin https://github.com/Palakis/obs-ndi/releases
* add a NDI source called Music and select the audio only NDI source from the Gaming PC as input
* in the OBS mixer just uncheck that Music source for track 2
* then in the multi track plugin just be sure that track 2 is selected for VOD audio (`OBS -> Tools -> Scripts`)
* now Track 1 with music is what live viewers hear while Track 2 without music is what gets put on the VOD
