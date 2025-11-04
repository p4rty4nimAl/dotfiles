# i3 config file (v4)

set $key Mod4+Shift+e
set $mode close

mode "$mode" {
	bindsym i exec --no-startup-id "i3-msg exit"; mode "default" 
	bindsym r exec --no-startup-id "systemctl reboot"; mode "default"
	bindsym s exec --no-startup-id "systemctl poweroff"; mode "default"
	bindsym b exec --no-startup-id "systemctl reboot --firmware-setup"; mode "default"
	bindsym h exec --no-startup-id "systemctl hibernate"; mode "default"
	bindsym l exec --no-startup-id "loginctl kill-user $USER"; mode "default"

	bindsym $key mode "default"
	bindsym Return mode "default"
	bindsym Escape mode "default"
}

bindsym $key mode "$mode"

