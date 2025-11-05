# i3 config file (v4)

# Use pactl to adjust volume in PulseAudio.
set $audio_notify killall -USR1 i3status
set $brightness exec --no-startup-id $HOME/.config/i3/sh/change_brightness.sh

# Sink volume
bindsym XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10% && $audio_notify
bindsym XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10% && $audio_notify
# Mute keys
bindsym XF86AudioMute exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle
bindsym XF86AudioMicMute exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle

# Brightness control
bindsym XF86MonBrightnessDown $brightness - 5
bindsym Shift+XF86MonBrightnessDown $brightness - 1
bindsym XF86MonBrightnessUp $brightness + 5
bindsym Shift+XF86MonBrightnessUp $brightness + 1

# Additional function keys
# TODO: Prevent XF86WLAN disconnecting WLAN?
