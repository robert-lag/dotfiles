--     _
--    / \__      _____  ___  ___  _ __ ___   ___
--   / _ \ \ /\ / / _ \/ __|/ _ \| '_ ` _ \ / _ \
--  / ___ \ V  V /  __/\__ \ (_) | | | | | |  __/
-- /_/   \_\_/\_/ \___||___/\___/|_| |_| |_|\___|
--  _____ _
-- |_   _| |__   ___ _ __ ___   ___
--   | | | '_ \ / _ \ '_ ` _ \ / _ \
--   | | | | | |  __/ | | | | |  __/
--   |_| |_| |_|\___|_| |_| |_|\___|
--

local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local xrdb = xresources.get_current_theme()
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()
local current_path = "/home/robert/.config/awesome/theme/"
local image_path = "/home/robert/.config/awesome/images/"

local function darker(color_value, darker_n)
    local result = "#"
    for s in color_value:gmatch("[a-fA-F0-9][a-fA-F0-9]") do
        local bg_numeric_value = tonumber("0x"..s) - darker_n
        if bg_numeric_value < 0 then bg_numeric_value = 0 end
        if bg_numeric_value > 255 then bg_numeric_value = 255 end
        result = result .. string.format("%2.2x", bg_numeric_value)
    end
    return result
end

-- inherit default theme
local theme = dofile(themes_path.."default/theme.lua")
-- load vector assets' generators for this theme

-- General {{{1
theme.font          = "Monospace 10"

theme.bg_normal     = xrdb.color0
theme.bg_focus      = xrdb.color0
theme.bg_urgent     = xrdb.color1
theme.bg_minimize   = xrdb.background
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = xrdb.color7
theme.fg_focus      = xrdb.color3
theme.fg_urgent     = xrdb.color0
theme.fg_minimize   = darker(xrdb.color7, 50)

theme.useless_gap   = dpi(0)
theme.border_width  = dpi(3)
theme.border_normal = xrdb.color8
theme.border_focus  = darker(theme.border_normal, -25)
theme.border_marked = xrdb.color10

theme.master_width_factor = 0.6

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- Taglist {{{1

theme.taglist_font = "Monospace Bold 10"
theme.taglist_border_color = theme.fg_focus
theme.taglist_bg_normal = theme.bg_normal
theme.taglist_fg_hover = theme.fg_focus
theme.taglist_bg_hover = darker(theme.bg_normal, 10)

-- Unset taglist squares
theme.taglist_squares_sel = nil
theme.taglist_squares_unsel = nil

-- Tasklist {{{1
theme.tasklist_font = "Monospace Bold 10"
theme.tasklist_bg_normal = theme.bg_normal
theme.tasklist_bg_raised = darker(theme.tasklist_bg_normal, -20)
theme.tasklist_fg_normal = theme.fg_normal
theme.tasklist_fg_seperator = theme.fg_normal
theme.tasklist_fg_focus = theme.fg_focus
theme.tasklist_border_color = darker(theme.tasklist_bg_normal, -20)
theme.tasklist_wifi = xrdb.color6
theme.tasklist_cpu = xrdb.color4
theme.tasklist_sound = xrdb.color5
theme.tasklist_battery = xrdb.color2
theme.tasklist_battery_warning = xrdb.color3
theme.tasklist_battery_critical = xrdb.color1
theme.tasklist_datetime = xrdb.color3

-- Tooltip {{{1
theme.tooltip_fg = theme.fg_normal
theme.tooltip_bg = theme.bg_normal

-- Systray {{{1
theme.systray_icon_spacing = 5
theme.bg_systray = theme.tasklist_bg_normal

-- Titlebar {{{1
theme.titlebar_bg_normal = xrdb.color0
theme.titlebar_bg_focus = darker(xrdb.color0, -10)
theme.titlebar_size = 30
theme.titlebar_font = "Monospace Bold 10"

-- Menu {{{1
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = image_path.."submenu.png"
theme.menu_height = dpi(50)
theme.menu_width  = dpi(350)
theme.menu_font = "monospace 20"
theme.menu_border_color = xrdb.color8

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- Recolor Layout icons {{{1
theme = theme_assets.recolor_layout(theme, theme.fg_normal)

-- Recolor titlebar icons {{{1
theme = theme_assets.recolor_titlebar(
    theme, theme.fg_normal, "normal"
)
theme = theme_assets.recolor_titlebar(
    theme, darker(theme.fg_normal, -60), "normal", "hover"
)
theme = theme_assets.recolor_titlebar(
    theme, xrdb.color2, "normal", "press"
)
theme = theme_assets.recolor_titlebar(
    theme, theme.fg_focus, "focus"
)
theme = theme_assets.recolor_titlebar(
    theme, darker(theme.fg_focus, -60), "focus", "hover"
)
theme = theme_assets.recolor_titlebar(
    theme, xrdb.color1, "focus", "press"
)

-- Icons {{{1
-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil

-- Generate Awesome icon:    placement = awful.placement.bottom_right,
theme.awesome_icon = theme_assets.awesome_icon(
    theme.menu_height, theme.bg_focus, theme.fg_focus
)

-- Try to determine if we are running light or dark colorscheme {{{1
local bg_numberic_value = 0;
for s in theme.bg_normal:gmatch("[a-fA-F0-9][a-fA-F0-9]") do
    bg_numberic_value = bg_numberic_value + tonumber("0x"..s);
end
local is_dark_bg = (bg_numberic_value < 383)

-- Generate wallpaper {{{1
local wallpaper_bg = xrdb.color8
local wallpaper_fg = xrdb.color7
local wallpaper_alt_fg = xrdb.color12
if not is_dark_bg then
    wallpaper_bg, wallpaper_fg = wallpaper_fg, wallpaper_bg
end
theme.wallpaper = function(s)
    return theme_assets.wallpaper(wallpaper_bg, wallpaper_fg, wallpaper_alt_fg, s)
end

-- Define the image to load {{{1
theme.titlebar_close_button_normal = image_path.."close-normal.png"
theme.titlebar_close_button_normal_hover = image_path.."close-normal.png"
theme.titlebar_close_button_normal_press = image_path.."close-normal.png"
theme.titlebar_close_button_focus  = image_path.."close-focus.png"
theme.titlebar_close_button_focus_hover = image_path.."close-focus.png"
theme.titlebar_close_button_focus_press = image_path.."close-focus.png"

theme.titlebar_minimize_button_normal = themes_path.."default/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus  = themes_path.."default/titlebar/minimize_focus.png"

theme.titlebar_ontop_button_normal_inactive = themes_path.."default/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive  = themes_path.."default/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = themes_path.."default/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active  = themes_path.."default/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = themes_path.."default/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = themes_path.."default/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = themes_path.."default/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active  = themes_path.."default/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = themes_path.."default/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive  = themes_path.."default/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = themes_path.."default/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active  = themes_path.."default/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = themes_path.."default/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = themes_path.."default/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = themes_path.."default/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active  = themes_path.."default/titlebar/maximized_focus_active.png"

theme.wallpaper = themes_path.."default/background.png"

-- You can use your own layout icons like this {{{1
theme.layout_fairh = themes_path.."default/layouts/fairhw.png"
theme.layout_fairv = themes_path.."default/layouts/fairvw.png"
theme.layout_floating  = themes_path.."default/layouts/floatingw.png"
theme.layout_magnifier = themes_path.."default/layouts/magnifierw.png"
theme.layout_max = themes_path.."default/layouts/maxw.png"
theme.layout_fullscreen = themes_path.."default/layouts/fullscreenw.png"
theme.layout_tilebottom = themes_path.."default/layouts/tilebottomw.png"
theme.layout_tileleft   = themes_path.."default/layouts/tileleftw.png"
theme.layout_tile = themes_path.."default/layouts/tilew.png"
theme.layout_tiletop = themes_path.."default/layouts/tiletopw.png"
theme.layout_spiral  = themes_path.."default/layouts/spiralw.png"
theme.layout_dwindle = themes_path.."default/layouts/dwindlew.png"
theme.layout_cornernw = themes_path.."default/layouts/cornernww.png"
theme.layout_cornerne = themes_path.."default/layouts/cornernew.png"
theme.layout_cornersw = themes_path.."default/layouts/cornersww.png"
theme.layout_cornerse = themes_path.."default/layouts/cornersew.png"

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
