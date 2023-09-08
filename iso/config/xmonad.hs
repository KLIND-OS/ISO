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



startup :: X ()
startup = do
    spawn "xsetroot -cursor_name left_ptr"
    spawnOnce "setxkbmap cz"
    spawnOnce "dunst"
    spawnOnce "~/client.AppImage --no-sandbox && poweroff"


myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
    [ 
    ((modm .|. shiftMask, xK_c     ), kill)

    , ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
    , ((modm .|. shiftMask, xK_s), spawn "/root/selectprogram.sh")
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
    , modMask            = mod4Mask
    }