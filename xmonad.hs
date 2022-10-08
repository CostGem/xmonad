{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications    #-}
{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE RankNTypes          #-}
{-# LANGUAGE FlexibleContexts    #-}
{-# LANGUAGE BlockArguments      #-}

module Main where

import qualified Data.Map as M
import Data.List (sortBy)
import Data.Function (on)
import Control.Monad (forM_, join)

import XMonad
import qualified XMonad.StackSet as W
import XMonad.Operations (windows)

import XMonad.Util.EZConfig (mkKeymap)
import XMonad.Util.Ungrab (unGrab)
import XMonad.Util.SpawnOnce (spawnOnce, spawnOnOnce)
import XMonad.Util.Loggers
import XMonad.Util.Run (safeSpawn)
import XMonad.Util.NamedWindows (getName)
import XMonad.Util.PureX (toX)

import XMonad.Hooks.EwmhDesktops (ewmh, ewmhFullscreen)
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog

import XMonad.Layout
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Grid
import XMonad.Layout.IfMax
import XMonad.Layout.Maximize
import XMonad.Layout.Minimize
import XMonad.Layout.NoBorders
import XMonad.Layout.Gaps

import XMonad.Actions.Minimize
import XMonad.Actions.Navigation2D
import XMonad.Actions.Search
import XMonad.Actions.Submap
import XMonad.Actions.DynamicWorkspaces

import XMonad.Prompt
import XMonad.Prompt.FuzzyMatch (fuzzyMatch, fuzzySort)
import XMonad.Prompt.Input
import XMonad.Prompt.Shell

main :: IO ()
main = 
  xmonad
    $ withNavigation2DConfig def
    $ ewmhFullscreen
    $ ewmh
    $ docks
    $ myXConfig
  
myXConfig = def
  { terminal           = "alacritty"
  , modMask            = mod4Mask
  , workspaces         = myWorkspaces
  
  , borderWidth        = 2
  , normalBorderColor  = "#928374"
  , focusedBorderColor = "#b16286"

  , keys               = \c -> mkKeymap c (myKeymap c)

  , startupHook        = myStartupHook
  , layoutHook         = myLayoutHook
  , manageHook         = manageHook def <+> myManageHook
  }

myXPConfig = def
  { bgColor           = "#282828"
  , fgColor           = "#ebdbb2"
  , bgHLight          = "#ebdbb2"
  , fgHLight          = "#282828"
  , borderColor       = "#928374"
  , promptBorderWidth = 2
  , height            = 30
  , searchPredicate   = fuzzyMatch
  , sorter            = fuzzySort
  }

myWorkspaces = digitKeys

myKeymap = \c
  -> appKeys c
  ++ webpageKeys c
  ++ windowsFocus
  ++ windowsSwap
  ++ layoutKeys
  ++ workspaceSwitchKeys
  ++ workspaceKeys c
  ++ screenshotKeys
  ++ promptKeys
  ++ popupKeys
  ++ audioKeys

windowsFocus =
  [ ("M1-<Tab>"     , windows W.focusDown)
  , ("M1-S-<Tab>"   , windows W.focusUp  )
  , ("M1-C-<Left>"  , windowGo L True    )
  , ("M1-C-<Down>"  , windowGo D True    )
  , ("M1-C-<Up>"    , windowGo U True    )
  , ("M1-C-<Right>" , windowGo R True    )
  ]

windowsSwap =
  [ ("M-<Tab>"      , windows W.swapDown)
  , ("M-S-<Tab>"    , windows W.swapUp  )
  , ("M1-S-<Left>"  , windowSwap L True )
  , ("M1-S-<Down>"  , windowSwap D True )
  , ("M1-S-<Up>"    , windowSwap U True )
  , ("M1-S-<Right>" , windowSwap R True )
  ]

layoutKeys =
  [ ("M-<Up>"    , withFocused (sendMessage . maximizeRestore))
  , ("M-<Down>"  , withFocused minimizeWindow                 )
  , ("M-S-<Down>", withLastMinimized maximizeWindowAndFocus   )
  , ("M-S-t"     , withFocused $ windows . W.sink             )
  , ("M-l"       , sendMessage NextLayout                     )
  ] ++
  [("M-C-" ++ k, sendMessage $ JumpToLayout l)
  | (k, l) <- zip digitKeys [ "Tall", "ThreeCol", "Grid", "Full"]
  ]

workspaceSwitchKeys =
  [ ("M-" ++ m ++ k, windows $ f i)
  | (i, k) <- zip myWorkspaces digitKeys
  , (f, m) <- [(W.greedyView, ""), (W.shift, "S-")]
  ]

workspaceKeys = \c ->
  [ ("M-S-w", submap $ mkKeymap c keymap)
  ]
  where
    keymap = 
      [ ("g", gamingWorkspace)
      , ("S-g", removeWorkspaceByTag "Game")
      , ("q", selectWorkspace myXPConfig)
      ]
    gamingWorkspace = addWorkspace "Game" >> spawn "steam" >> spawn "discord"

appKeys = \c ->
  [ ("M-S-c"       , kill                    ) 
  , ("M-S-<Return>", spawn $ terminal c      )
  , ("M-e"         , spawn "nautilus"        )
  , ("M-f"         , spawn "firefox"         )
  , ("M-w"         , spawn "codium"          )
  , ("M-t"         , spawn "telegram-desktop")
  , ("M-d"         , spawn "discord"         )
  , ("M-a"         , spawn "annotator"       )      
  ]  

webpageKeys = \c ->
  [ ("M-p", submap $ mkKeymap c keymap)
  ]
  where
    keymap = 
      [ ("a", openPage aur       )
      , ("h", openPage hoogle    )
      , ("y", openPage youtube   )
      , ("v", openPage vkMessages)
      , ("m", openPage gMail     )
      , ("c", openPage gCalendar )
      ]
    
    openPage p = spawn $ "firefox " ++ p

    aur        = "https://aur.archlinux.org/"
    hoogle     = "https://hoogle.haskell.org/"
    youtube    = "https://www.youtube.com/"
    vkMessages = "https://vk.com/im"
    gMail      = "https://mail.google.com/"
    gCalendar  = "https://calendar.google.com"

screenshotKeys = 
  [ ("<Print>"    , spawn $ select     ++ toClipImg)
  , ("S-<Print>"  , spawn $ fullscreen ++ toClipImg)
 
  , ("M-<Print>"  , spawn $ select     ++ toClipImg ++ toEdit)
  , ("M-S-<Print>", spawn $ fullscreen ++ toClipImg ++ toEdit)

  , ("C-<Print>"  , spawn $ select     ++ toFile)
  , ("C-S-<Print>", spawn $ fullscreen ++ toFile)
  ]
  where
    fullscreen = "maim -u"
    select     = "maim -su"
    active     = "maim -u -i $(xdotool getactivewindow)"
    toClip     = "| xclip -selection clipboard"
    toClipImg  = toClip ++ " -t image/png"
    toFile     = " ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"
    toEdit     = " && com.github.phase1geo.annotator --use-clipboard"

popupKeys =
  [ ("M-o"  , spawn launcher )
  , ("M-s"  , spawn leftPopup)
  , ("M-S-s", spawn ewwclose )  
  , ("M-v"  , spawn clipboard)
  , ("M-b"  , sendMessage ToggleStruts)
  ]
  where
    launcher  = "rofi -no-lazy-grab -show drun -modi run,drun,window -theme ~/.xmonad/rofi/style.rasi"
    ewwclose  = "exec ~/bin/eww close-all"
    leftPopup = "exec ~/bin/eww open-many weather_side time_side smol_calendar player_side sys_side sliders_side"    
    clipboard = "rofi -modi \"clipboard:greenclip print\" -show clipboard -run-command '{cmd}' -theme ~/.xmonad/rofi/style.rasi"

audioKeys =
  [ ("<XF86AudioPlay>", spawn "playerctl play-pause" )
  , ("<XF86AudioPrev>", spawn "playerctl previous"   )
  , ("<XF86AudioNext>", spawn "playerctl next"       )
  ]

promptKeys = 
  [ ("M-x"    , shellPrompt myXPConfig)
  ]

myStartupHook = do
  spawnOnce "polybar -r -c ~/.xmonad/polybar/polybar top"
  spawnOnce "exec ~/bin/eww daemon"
  spawnOnce "xsetroot -cursor_name left_ptr"
  spawnOnce "feh --bg-scale ~/.xmonad/assets/images/bg-gruvbox.png"
  spawnOnce "picom"
  spawnOnce "greenclip daemon"
  spawnOnce "python ~/bin/jakowlew/getweather.py"
  spawnOnce "sleep 3 && setxkbmap -model pc105 -layout us,ru -option grp:win_space_toggle"
  spawnOnce "/etc/X11/xinit/xinitrc.d/50-systemd-user.sh ~/.xinitrc"
  spawnOnce "exec redshift -l 54.790311:32.050366"

myLayoutHook = avoidStruts
             $ smartBorders
             $ minimize
             $ maximizeWithPadding 0
             $ layout
  where
    layout = tiled
         ||| threeColMid
         ||| Grid
         ||| Full

    tiled = Tall nmaster delta ratio
    threeColMid = ThreeColMid nmaster delta ratio

    nmaster = 1
    ratio = 1 / 2
    delta = 5 / 100

myManageHook = composeAll
  [ isDialog   --> doFloat
  , isPolybar  --> doLower
  , isPicInPic --> doPicInPic
  ]

isPolybar  = className =? "Polybar"
isPicInPic = title     =? "Picture-in-Picture"

doPicInPic = hasBorder False >> doSideFloat SE

moveTo i = doF $ W.shift (myWorkspaces !! i)

digitKeys :: [String]
digitKeys = map (:[]) ['1'..'9']

class MyPrompt a where
  name    :: String
  compl   :: [String]
  handler :: String -> X ()

buildPrompt :: forall a. MyPrompt a => X ()
buildPrompt = inputPromptWithCompl myXPConfig (name @a) promptCompl ?+ (handler @a)
  where
    promptCompl = mkComplFunFromList' myXPConfig (compl @a)
    