# i3 config file (v4)


# Start i3bar to display a workspace bar (plus the system information i3status
# finds out, if available)

bar {
	tray_output primary
	position top
	output primary
	i3bar_command exec i3bar --transparency
	status_command "exec i3status -c ~/.config/i3/i3status.conf"
	colors {
		background $g$t
		statusline $w
		separator $w
		# class	border	backgr.	text
		focused_workspace $w	$w	$g$t
		inactive_workspace $g$t	$g$t	$w
		binding_mode $w	$w	$g$t
	}
}
bar {
	tray_output primary
	output nonprimary
	position top
	i3bar_command exec i3bar --transparency
	colors {
		background $g80
		statusline $w
		separator $w
		# class border  backgr. text
		focused_workspace $w    $w      $g$t
		inactive_workspace $g$t $g$t    $w
		binding_mode $w $w      $g$t
	}
}