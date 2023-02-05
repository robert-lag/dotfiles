-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- {{{ Library calls
awful = require("awful")
require("awful.autofocus")
gears = require("gears")
wibox = require("wibox")
beautiful = require("beautiful")
xresources = require("beautiful.xresources")
xrdb = xresources.get_current_theme()
menubar = require("menubar")
-- local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
-- require("awful.hotkeys_popup.keys")

image_path = "/home/robert/.config/awesome/images/"

-- }}}

-- {{{ Helper functions
require("helper-functions")
-- }}}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    awful.spawn(string.format("notify-send --urgency critical --expire-time=10000 -- 'Oops, there were errors during startup!' '%s'", awesome.startup_errors))
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        awful.spawn(string.format("notify-send --urgency critical --expire-time=10000 -- 'Oops, an error happenend!' '%s'", err))

        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("/home/robert/.config/awesome/theme/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = os.getenv("TERMINAL") or "st"
shell = os.getenv("SHELL") or "zsh"
editor = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

image_path = "/home/robert/.config/awesome/images/"

middle_widgets = {}

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile,
    -- awful.layout.suit.floating,
    -- awful.layout.suit.tile.left,
    -- awful.layout.suit.tile.bottom,
    -- awful.layout.suit.tile.top,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}

awful.mouse.snap.edge_enabled = false
-- }}}

-- {{{ Menu

-- Create a awesome submenu
awesomemenu = {
    -- { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { " manual", terminal .. " -e man awesome", image_path.."placeholder.png" },
    { " edit config", editor_cmd .. " " .. awesome.conffile, image_path.."placeholder.png" },
    { " restart", awesome.restart, image_path.."placeholder.png" },
    { " quit", function() awesome.quit() end, image_path.."placeholder.png" },
}

systemmenu = {
    { " reboot", "systemctl reboot", image_path.."placeholder.png" },
    { " shutdown", "systemctl poweroff -i", image_path.."placeholder.png" },
}

-- Create a launcher widget and a main menu
mymainmenu = awful.menu({
    { " lock", "xautolock -locknow", image_path.."placeholder.png" },
    { " system", systemmenu, image_path.."placeholder.png" },
    { " awesome", awesomemenu, image_path.."placeholder.png" },
    { " terminal", terminal, image_path.."placeholder.png" },
})
-- }}}

-- {{{ Wibar

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it

require("wibar")
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
require("keybindings")
-- }}}

-- {{{ Rules
require("rules")
-- }}}

-- {{{ Signals
require("signals")
-- }}}

awful.spawn("setbg")
