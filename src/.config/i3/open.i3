# i3 config file (v4)

set $key Mod4+Shift+o
set $mode open-root

set $exit-key bindsym Mod4+Shift+o mode "default"
set $exit-return bindsym Return mode "default"
set $exit-esc bindsym Escape mode "default"

set $; ; mode "default";
set $exec exec --no-startup-id

set $newterm exec i3-sensible-terminal -x /usr/bin/bash -c

mode "open-browser" {
	$exit-key
	$exit-return
	$exit-esc
}
mode "open-code" {
	$exit-key
	$exit-return
	$exit-esc
}
mode "open-security" {
	$exit-key
	$exit-return
	$exit-esc
}

mode "open-root" {
	bindsym b mode "open-browser";
	bindsym c mode "open-code";
	bindsym p mode "open-security";

	$exit-key
	$exit-return
	$exit-esc
}

bindsym $key mode "open-root"

# include open.d files for modularity
include $HOME/.config/i3/open.d/*.i3
