# My XMonad config
This config is a fork. It implements a handy polybar to work on ArchLinux. <br />
Author: https://github.com/JoshuaJakowlew/xmonad

# Screenshots
![Screenshot](/assets/images/screenshots/screen.png)

# Hotkeys
Window focus

* `M1-<Tab>` - switch focus up
* `M1-S-<Tab>` - switch focus back
* `M1-C-<Left>` - switch focus left
* `M1-C-<Down>` - switch focus down
* `M1-C-<Up>` - switch focus up
* `M1-C-<Right>` - switch focus right

Window swap

* `M-<Tab>`  - swap windows back
* `M-S-<Tab>`  - swap windows up
* `M1-S-<Left>` - switch focus left
* `M1-S-<Down>` - switch focus down
* `M1-S-<Up>` - switch focus up
* `M1-S-<Right>` - switch focus right

Layouts 

* `M-<Up>` - toggle maximize
* `M-<Down>` - minimize window
* `M-S-<Down>` - restore last minimized window and focus on it
* `M-S-t` - force window to tiling mode
* `M-l` - switch to next layout
* `M-C-1` - 1st layout (Tall)
* `M-C-2` - 2nd layout (ThreeColMid)
* `M-C-3` - 3rd layout (Grid)
* `M-C-4` - 4th layout (Full)

Workspaces

* `M-1` .. `M-9` - switch to workspace
* `M-S-1` .. `M-S-9` - move window to workspace

Application keys

* `M-S-c` - kill
* `M-S-<Return>` - start terminal
* `M-e` - start Nautilus
* `M-t` - start Telegram (Flatpak)
* `M-c` - start Chrome (Flatpak)

Pop-up keys

* `M-o` - spawn rofi-launcher
* `M-v` - spawn greenclip
* `M-s` - spawn left popup (eww)
* `M-S-s` - close all eww windows
* `M-b` - toggle top bars

Screenshots

* `<Print>` - selection (to clipboard)
* `S-<Print>` - fullscreen (to clipboard)
* `C-<Print>` - selection (to file)
* `C-S-<Print>` - fullscreen (to file)
* `M-<Print>` - selection (to Annotator)
* `M-S-<Print>` - fullscreen (to Annotator)

Volume keys

* `XF86AudioMute` - mute volume
* `<XF86AudioLowerVolume>` - reduce volume by 5%
* `<XF86AudioRaiseVolume>` - increase volume by 5%

Prompt

* `M-x` - shell prompt

# Dependencies

* `rofi`
* `dbus`
* `polybar`
* `pulseaudio`
* `pavucontrol`
