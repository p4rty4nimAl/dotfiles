# i3 config file (v4)

set $key Mod4+r
set $mode resize

# resize window (you can also use the mouse for that)
mode "$mode" {
	bindsym Left resize shrink width 10 px or 10 ppt
	bindsym Down resize grow height 10 px or 10 ppt
	bindsym Up resize shrink height 10 px or 10 ppt
	bindsym Right resize grow width 10 px or 10 ppt

	bindsym $key mode "default"
	bindsym Return mode "default"
	bindsym Escape mode "default"
}

bindsym $key mode "$mode"
