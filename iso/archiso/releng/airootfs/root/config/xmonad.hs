import XMonad
import XMonad.Config.Desktop
import XMonad.Hooks.ManageDocks
import XMonad.Layout.NoBorders
import XMonad.Util.EZConfig
import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import XMonad.Hooks.SetWMName
import XMonad.Hooks.EwmhDesktops
import XMonad.Util.SpawnOnce ( spawnOnce )
import Graphics.X11.ExtraTypes.XF86 (xF86XK_AudioLowerVolume, xF86XK_AudioRaiseVolume, xF86XK_AudioMute, xF86XK_MonBrightnessDown, xF86XK_MonBrightnessUp, xF86XK_AudioPlay, xF86XK_AudioPrev, xF86XK_AudioNext)

startup :: X ()
startup = do
    spawn "xsetroot -cursor_name left_ptr"
    spawnOnce "setxkbmap cz"
    spawnOnce "dunst"
    spawnOnce "bash /root/scripts/mirror.sh"
    spawnOnce "picom"
    spawnOnce "bash /root/startUI.sh"
    spawnOnce "numlockx on"

myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $
    [ ((modm, button1), (\_ -> return ()))
    , ((modm, button2), (\w -> focus w >> windows W.swapMaster))
    , ((modm, button3), (\_ -> return ()))
    ]

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
    [
    ((modm .|. shiftMask, xK_c     ), kill)

    , ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- Audio keys
    , ((0,                    xF86XK_AudioPlay), spawn "bash /root/scripts/media.sh play-pause")
    , ((0,                    xF86XK_AudioPrev), spawn "bash /root/scripts/media.sh previous")
    , ((0,                    xF86XK_AudioNext), spawn "bash /root/scripts/media.sh next")
    , ((0,                    xF86XK_AudioRaiseVolume), spawn "bash /root/scripts/media.sh up")
    , ((0,                    xF86XK_AudioLowerVolume), spawn "bash /root/scripts/media.sh down")
    , ((0,                    xF86XK_AudioMute), spawn "bash /root/scripts/media.sh mute")
    ]

main = xmonad $ desktopConfig
    { terminal           = "alacritty"
    , layoutHook         = smartBorders $ Full
    , manageHook         = manageDocks <+> manageHook desktopConfig
    , borderWidth        = 0
    , normalBorderColor  = "#000000"
    , focusedBorderColor = "#000000"
    , startupHook        = startup
    , keys               = myKeys
    , mouseBindings      = myMouseBindings
    , modMask            = mod4Mask
    }

