--
--  Copyright (C) 2020 by RatWithAShotgun
--
--  This program is free software; you can redistribute it and/or
--  modify it under the terms of the GNU General Public License
--  as published by the Free Software Foundation; either version 2
--  of the License, or (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
--

obs = obslua

g_recording_dev = false
--g_recording_dev = true

g_audio_track = nil -- [1-6]
g_audio_bitrate = nil
g_enabled = nil

ENCODER_NAME = "STREAM_MULTI_TRACK_AUDIO_ENCODER_V001__%s"

function get_create_encoder(wanted_track)
    if wanted_track == nil then
        print("no wanted_track")
        return nil
    end
    local target_name = ENCODER_NAME:format(wanted_track)
    local encoder = obs.obs_get_encoder_by_name(target_name)

    if encoder ~= nil then
        print(("got existing plugin encoder for track %s"):format(wanted_track))
        return encoder
    end

    local audio = obs.obs_get_audio()
    if audio == nil then
        print("couldn't get obs audio")
        return nil
    end

    print(("creating audio encoder on track %d"):format(wanted_track))
    encoder = obs.obs_audio_encoder_create("ffmpeg_aac", target_name, nil, wanted_track - 1, nil)
    if encoder == nil then
        print("failed creating encoder")
        return
    end

    print((("created encoder for track %d %s"):format(wanted_track, obs.obs_encoder_get_name(encoder))))
    obs.obs_encoder_set_audio(encoder, audio)
    return encoder
end

function get_encoder(wanted_track)
    if wanted_track == nil then
        return nil
    end

    local target_name = ENCODER_NAME:format(wanted_track)
    local encoder = obs.obs_get_encoder_by_name(target_name)
    return encoder
end

function update_encoder_settings(encoder)
    if encoder == nil then
        return false
    end

    local bitrate = g_audio_bitrate or 160

    settings = obs.obs_data_create()
    obs.obs_data_set_int(settings, "bitrate", bitrate)
    obs.obs_encoder_update(encoder, settings)
    obs.obs_data_release(settings)

    print("updated encoder settings")
    return true
end

function clear_encoder(output)
    if output ~= nil then
        print("clearing encoder")
        obs.obs_output_set_audio_encoder(output, nil, 1)
    end
end

function set_multi_tracks(output)
    if output == nil then
        return
    end

    if not g_enabled then
        print("not enabled, clearing")
        clear_encoder(output)
        return
    end

    if obs.obs_output_active(output) then
        local encoder = get_encoder()
        update_encoder_settings(encoder)
        obs.script_log(obs.LOG_ERROR, "set_multi_tracks: Can't change settings while output active")
        return
    end
    print("doing the thing")

    if g_audio_track == nil then
        print("no audio track")
        clear_encoder(output)
        return
    end

    local encoder = get_create_encoder(g_audio_track)
    if encoder == nil then
        clear_encoder(output)
        return
    end

    if not update_encoder_settings(encoder) then
        print('failed updating encoder')
        clear_encoder(output)
        obs.obs_encoder_release(encoder)
        return
    end

    print(("setting track %d encoder as VOD track"):format(g_audio_track))
    obs.obs_output_set_audio_encoder(output, encoder, 1) -- doesn't increase ref count, don't release encoder
end

function on_event(event)
    --print(("event %d"):format(event))
    if event == obs.OBS_FRONTEND_EVENT_STREAMING_STARTING then
        print("OBS_FRONTEND_EVENT_STREAMING_STARTING")

        local output = obs.obs_frontend_get_streaming_output()
        if output == nil then
            print("no streaming output")
            return
        end

        set_multi_tracks(output)
        obs.obs_output_release(output)

        --elseif g_recording_dev and event == obs.OBS_FRONTEND_EVENT_RECORDING_STARTING then
        --    print("OBS_FRONTEND_EVENT_RECORDING_STARTING")
        --
        --    local output = obs.obs_frontend_get_recording_output()
        --    if output == nil then
        --        print("no recording output")
        --        return
        --    end
        --
        --    set_multi_tracks(output)
        --    obs.obs_output_release(output)

    elseif event == obs.OBS_FRONTEND_EVENT_STREAMING_STOPPED then
        print("OBS_FRONTEND_EVENT_STREAMING_STOPPED")

        local output = obs.obs_frontend_get_streaming_output()
        clear_encoder(output)
        obs.obs_output_release(output)

        --elseif g_recording_dev and event == obs.OBS_FRONTEND_EVENT_RECORDING_STOPPED then
        --    print("OBS_FRONTEND_EVENT_RECORDING_STOPPED")
        --
        --    local output = obs.obs_frontend_get_recording_output()
        --    clear_encoder(output)
        --    obs.obs_output_release(output)
    end
end

function script_properties()
    local props = obs.obs_properties_create()

    obs.obs_properties_add_bool(props, "enabled", "Enabled")
    obs.obs_properties_add_int(props, "audio_track", "VOD Audio Track (1-6)", 1, 6, 1)
    obs.obs_properties_add_int(props, "bitrate", "Audio Bitrate", 60, 320, 1)

    return props
end

function script_description()
    return [[Use a different audio track on Twitch for VODs and streams. Version 0.0.2 by RatWithAShotgun.

Note: Sometimes it just doesn't seem to work and the VOD also has the stream audio. Clips from streams still have the stream audio too for now. Should hopefully be fixed by Twitch soon, still in beta.

Select Track Sources via OBS -> Edit-> Advanced Audio Properties. Changing the VOD Audio Track below will not take effect while the stream is live. Track 1 is used by OBS for the stream so Track 2 for VODs is usually easiest]]
end

function script_defaults(settings)
    obs.obs_data_set_default_bool(settings, "enabled", true)
    obs.obs_data_set_default_int(settings, "bitrate", 160)
    obs.obs_data_set_default_int(settings, "audio_track", 2)
end

function script_update(settings)
    g_audio_track = obs.obs_data_get_int(settings, "audio_track")
    if not g_audio_track or g_audio_track < 1 or g_audio_track > 6 then
        g_audio_track = nil
    end
    g_audio_bitrate = obs.obs_data_get_int(settings, "bitrate")
    g_enabled = obs.obs_data_get_bool(settings, "enabled")

    print(("multi_track_stream update: track: %d. bitrate: %d. enabled: %s"):format(g_audio_track, g_audio_bitrate, g_enabled))

    --print("sending fake recording started event")
    --on_event(obs.OBS_FRONTEND_EVENT_RECORDING_STARTING)

    if g_recording_dev then
        local output = obs.obs_frontend_get_recording_output()
        set_multi_tracks(output)
        obs.obs_output_release(output)
    end

    local output = obs.obs_frontend_get_streaming_output()
    set_multi_tracks(output)
    obs.obs_output_release(output)
end

function script_load(settings)
    --print("\n\nscript_load\n")
    obs.obs_frontend_add_event_callback(on_event)
end

function script_unload()
    --print("\n\nscript_unload\n")
end
