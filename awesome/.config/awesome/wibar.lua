local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local xrdb = xresources.get_current_theme()

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

local battery_widget = require 'battery-widget'

local cpu_widget = wibox.widget {
    {

        {
            {
                id = 'number',
                text = '',
                align = 'center',
                valign = 'center',
                widget = wibox.widget.textbox,
            },
            id = 'inner',
            fg = xrdb.color4,
            widget = wibox.container.background
        },
        colors = {
            xrdb.color4
        },
        id = 'chart',
        thickness = 2,
        min_value = 0,
        max_value = 100,
        value = 0,
        rounded_edge = true,
        widget = wibox.container.arcchart
    },
    margins = 1,
    widget = wibox.container.margin
}

function update_cpu_widget()
    awful.spawn.easy_async_with_shell("top -bn2 | grep '%Cpu' | tail -1 | grep -P '(....|...) id,'|awk '{print 100-$8 }'", function(out)
        cpu_widget.chart.value = out
        -- cpu_widget.chart.inner.number.text = string.format("%2d",math.floor(out))
    end)
end

update_cpu_widget()

cpu_widget_timer = timer({ timeout = 4.0 })
cpu_widget_timer:connect_signal("timeout", update_cpu_widget)
cpu_widget_timer:start()


local volume_widget = wibox.widget {
    {

        {
            {
                id = 'number',
                text = '墳',
                align = 'center',
                valign = 'center',
                widget = wibox.widget.textbox,
            },
            id = 'inner',
            fg = xrdb.color3,
            widget = wibox.container.background
        },
        colors = {
            xrdb.color3
        },
        id = 'chart',
        thickness = 2,
        min_value = 0,
        max_value = 100,
        value = 0,
        rounded_edge = true,
        widget = wibox.container.arcchart
    },
    margins = 1,
    widget = wibox.container.margin
}

function update_volume_widget()
    awful.spawn.easy_async_with_shell("get-volume", function(out)
        volume_widget.chart.value = out
    end)
end

update_volume_widget()

volume_widget_timer = timer({ timeout = 10.0 })
volume_widget_timer:connect_signal("timeout", update_volume_widget)
volume_widget_timer:start()

local battery_widget_ui = wibox.widget {
    {

        {
            {
                id = 'number',
                text = '0',
                align = 'center',
                valign = 'center',
                widget = wibox.widget.textbox,
            },
            id = 'inner',
            widget = wibox.container.background
        },
        colors = {
            xrdb.color2
        },
        id = 'chart',
        thickness = 2,
        min_value = 0,
        max_value = 100,
        value = 0,
        rounded_edge = true,
        widget = wibox.container.arcchart
    },
    margins = 1,
    widget = wibox.container.margin
}

-- Create the battery widget:
local battery_widget = battery_widget {
    screen = screen,
    use_display_device = true,
    instant_update = true,
    widget_template = battery_widget_ui
}


local was_discharging = false

-- When UPower updates the battery status, the widget is notified
-- and calls a signal you need to connect to:
battery_widget:connect_signal('upower::update', function (widget, device)
    local battery_icon
    if device.state == 1 then
        -- Device is charging
        widget.chart.colors = {
            xrdb.color2
        }
        widget.chart.inner.fg = xrdb.color2

        if was_discharging then
            awful.spawn("xbacklight -set 100 -time 500")
            was_discharging = false
        end

        if device.percentage < 100 then
            -- battery_icon = ""
            battery_icon = ""
        else
            battery_icon = ""
        end
    else
        -- Device is discharging

        was_discharging = true

        if device.percentage <= 5 then
            battery_icon = ""
            awful.spawn("set-max-brightness 10")
        elseif device.percentage <= 10 then
            battery_icon = ""
            awful.spawn("set-max-brightness 50")
        elseif device.percentage <= 20 then
            battery_icon = ""
            awful.spawn("set-max-brightness 50")
        elseif device.percentage <= 30 then
            battery_icon = ""
        elseif device.percentage <= 40 then
            battery_icon = ""
        elseif device.percentage <= 50 then
            battery_icon = ""
        elseif device.percentage <= 60 then
            battery_icon = ""
        elseif device.percentage <= 70 then
            battery_icon = ""
        elseif device.percentage <= 80 then
            battery_icon = ""
        elseif device.percentage <= 90 then
            battery_icon = ""
        else
            battery_icon = ""
        end

        if device.percentage <= 5 then
            if device.percentage % 5 == 0 then
                awful.spawn("notify-send --urgency critical --icon=/home/robert/.config/awesome/battery-alert.png -- 'Very Low Battery'")
            end
            widget.chart.colors = {
                xrdb.color1
            }
            widget.chart.inner.fg = xrdb.color1
        elseif device.percentage <= 20 then
            if device.percentage % 5 == 0 then
                awful.spawn("notify-send --icon=/home/robert/.config/awesome/battery-alert.png -- 'Low Battery'")
            end
            widget.chart.colors = {
                xrdb.color11
            }
            widget.chart.inner.fg = xrdb.color11
        else
            widget.chart.colors = {
                xrdb.color2
            }
            widget.chart.inner.fg = xrdb.color2
        end
    end

    widget.chart.value = device.percentage
    widget.chart.inner.number.text = string.format('%s', battery_icon)
end)

-- Wifi widget
local wifi_widget = wibox.widget {
    {
        id = 'icon',
        text = '睊',
        align = 'left',
        valign = 'center',
        forced_width = 20,
        font = "monospace 15",
        widget = wibox.widget.textbox,
    },
    {
        id = 'name',
        text = '',
        align = 'left',
        valign = 'center',
        widget = wibox.widget.textbox,
    },
    spacing = 5,
    layout = wibox.layout.fixed.horizontal
}

awful.widget.watch(
    "iw dev wlan0 link", 5,
    function(widget, stdout, stderr, exitreason, exitcode)
        local wifi = string.match(stdout, "SSID:.*\n")
        local index_1, index_2 = string.find(stdout, "SSID: [^\n]*")
        local wifi_signal = string.match(stdout, "signal:.*\n")
        local index_3, index_4 = string.find(stdout, "signal: [^\n]*")
        local index_5, index_6 = string.find(stdout, "tx bitrate:%s%d+%p+%d+%s%a+%p%a")

        if ( wifi == '' or wifi == nil ) then
            widget.icon.text = "睊"
            widget.name.text =""
        else
            wifi = string.sub(stdout, index_1+6, index_2)
            wifi_signal = string.sub(stdout, index_3+8, index_4-1)
            wifi_bitrate = string.sub(stdout, index_5+12, index_6)
            widget.icon.text = "直"
            widget.name.text = wifi
        end
    end,
    wifi_widget
)

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function(c)
                                            c.fullscreen = not c.fullscreen
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Don't show the icons of the apps in the tasklist (= the bar at the top)
beautiful.tasklist_disable_icon = true

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
-- screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    -- set_wallpaper(s)

    -- Each screen has its own tag table.
    for i = 1, 10 do
        awful.tag.add(tostring(i), {
            layout = awful.layout.layouts[1],
            screen = s,
        })
    end

    awful.tag.add("-", {
        layout = awful.layout.suit.floating,
        screen = s,
    })

    awful.tag.add("+", {
        layout = awful.layout.suit.floating,
        screen = s,
    })

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    -- s.mylayoutbox = awful.widget.layoutbox(s)
    -- s.mylayoutbox:buttons(gears.table.join(
    --                        awful.button({ }, 1, function () awful.layout.inc( 1) end),
    --                        awful.button({ }, 3, function () awful.layout.inc(-1) end),
    --                        awful.button({ }, 4, function () awful.layout.inc( 1) end),
    --                        awful.button({ }, 5, function () awful.layout.inc(-1) end)))

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.noempty,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
        style    = {
            shape  = function(cr,w,h) gears.shape.rounded_rect(cr,w,h, 4) end,
            align = "center"
        },
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            {
                wifi_widget,
                cpu_widget,
                volume_widget,
                battery_widget,
                wibox.widget.textclock(),
                wibox.widget.systray(),

                -- spacing_widget = {
                --     text = '|',
                --     align = 'center',
                --     color = xrdb.color7,
                --     widget = wibox.widget.textbox,
                -- },
                spacing = 10,
                layout = wibox.layout.fixed.horizontal,
            },
            bg = xrdb.color8,
            fg = xrdb.color3,
            widget = wibox.container.background
        },
    }
end)
