local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local xrdb = xresources.get_current_theme()
local battery_widget = require("battery-widget")

-- Helper functions {{{1
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

-- CPU Widget {{{1
local cpu_widget = wibox.widget {
    {
        {
            id = 'icon',
            text = '',
            align = 'left',
            valign = 'center',
            font = "monospace 15",
            forced_width = 15,
            widget = wibox.widget.textbox,
        },
        {
            id = 'number',
            text = ' 0%',
            align = 'left',
            valign = 'center',
            widget = wibox.widget.textbox,
        },
        id = 'inner',
        spacing = 5,
        layout = wibox.layout.fixed.horizontal,
    },
    fg = xrdb.color4,
    widget = wibox.container.background,
    buttons = gears.table.join(
            awful.button({ }, 1, function() awful.spawn(string.format("%s -e htop", terminal)) end)
    )
}

function update_cpu_widget()
    awful.spawn.easy_async_with_shell("top -bn2 | grep '%Cpu' | tail -1 | grep -P '(....|...) id,'|awk '{print 100-$8 }'", function(out)
        cpu_widget.inner.number.text = string.format("%2d%%",math.floor(out))
    end)
end

update_cpu_widget()

cpu_widget_timer = timer({ timeout = 4.0 })
cpu_widget_timer:connect_signal("timeout", update_cpu_widget)
cpu_widget_timer:start()

-- Volume Widget {{{1
local volume_widget = wibox.widget {
    {
        {
            id = 'icon',
            text = '墳',
            align = 'center',
            valign = 'center',
            font = "monospace 15",
            forced_width = 20,
            widget = wibox.widget.textbox,
        },
        {
            id = 'number',
            text = '100%',
            align = 'left',
            valign = 'center',
            widget = wibox.widget.textbox,
        },
        id = 'inner',
        spacing = 5,
        layout = wibox.layout.fixed.horizontal,
    },
    fg = xrdb.color5,
    widget = wibox.container.background
}

function update_volume_widget()
    awful.spawn.easy_async_with_shell("get-volume", function(out)
        local volume = tonumber(out)
        if volume <= 0 then
            volume_widget.inner.icon.text = 'ﱝ'
        else
            volume_widget.inner.icon.text = '墳'
        end
        volume_widget.inner.number.text = string.format("%2d%%", volume)
    end)
end

update_volume_widget()

volume_widget:connect_signal("button::press", function()
            -- awful.spawn("notify-send 'Hello world'")
            awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
            update_volume_widget()
        end)


volume_widget_timer = timer({ timeout = 10.0 })
volume_widget_timer:connect_signal("timeout", update_volume_widget)
volume_widget_timer:start()

-- Battery Widget {{{1
local battery_widget_ui = wibox.widget {
    {
        {
            id = 'icon',
            text = '',
            align = 'left',
            valign = 'center',
            font = "monospace 15",
            widget = wibox.widget.textbox,
        },
        {
            id = 'number',
            text = '100%',
            align = 'left',
            valign = 'center',
            widget = wibox.widget.textbox,
        },
        id = 'inner',
        spacing = 5,
        layout = wibox.layout.fixed.horizontal,
    },
    widget = wibox.container.background
}

-- Create the battery widget:
local battery_widget = battery_widget {
    screen = screen,
    use_display_device = true,
    instant_update = true,
    widget_template = battery_widget_ui
}


local was_discharging = false
local brightness_reduced_warning = false
local brightness_reduced_critical = false

-- When UPower updates the battery status, the widget is notified
-- and calls a signal you need to connect to:
battery_widget:connect_signal('upower::update', function (widget, device)
    local battery_icon
    if device.state == 1 then
        -- Device is charging
        widget.fg = xrdb.color2

        -- Set the brightness to maximum after plugging in the cable
        if was_discharging then
            awful.spawn("xbacklight -set 100 -time 500")
            was_discharging = false
        end

        if device.percentage < 100 then
            battery_icon = ""
        else
            battery_icon = ""
        end

        brightness_reduced_warning = false
        brightness_reduced_critical = false
    else
        -- Device is discharging

        was_discharging = true

        if device.percentage <= 5 then
            battery_icon = ""
            if not brightness_reduced_critical then
                awful.spawn("set-max-brightness 10")
                awful.spawn("notify-send --urgency critical --icon=~/.local/share/dunst/icons/battery-alert.png -- 'Very Low Battery'")
                brightness_reduced_critical = true
            end
        elseif device.percentage <= 10 then
            battery_icon = ""
            if not brightness_reduced_warning then
                awful.spawn("set-max-brightness 50")
                awful.spawn("notify-send --icon=~/.local/share/dunst/icons/battery-alert.png -- 'Low Battery'")
                brightness_reduced_warning = true
            end
        elseif device.percentage <= 20 then
            battery_icon = ""
            if not brightness_reduced_warning then
                awful.spawn("set-max-brightness 50")
                awful.spawn("notify-send --icon=~/.local/share/dunst/icons/battery-alert.png -- 'Low Battery'")
                brightness_reduced_warning = true
            end
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
            widget.fg = xrdb.color1
        elseif device.percentage <= 20 then
            widget.fg = xrdb.color3
        else
            widget.fg = xrdb.color2
        end
    end

    widget.inner.icon.text = string.format('%s', battery_icon)
    widget.inner.number.text = string.format("%2d%%", device.percentage)
end)

-- Wifi widget {{{1
local current_wifi = ""
local wifi_ui_collapsed = false
local wifi_widget = wibox.widget {
    {
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
        id = 'inner',
        spacing = 5,
        layout = wibox.layout.fixed.horizontal,
    },
    fg = xrdb.color6,
    widget = wibox.container.background,
    buttons = gears.table.join(
            awful.button({ }, 1, function()
                awful.spawn(string.format("notify-send --icon=~/.local/share/dunst/icons/wifi.png -- '%s'", current_wifi))
            end),
            awful.button({ }, 2, function() awful.spawn("dmenu-wlan-scanner") end),
            awful.button({ }, 3, function() awful.spawn(string.format("%s -e %s -c 'iwctl station wlan0 show; iwctl'", terminal, shell)) end)
    )
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
            widget.inner.icon.text = "睊"
            current_wifi = ""
        else
            wifi = string.sub(stdout, index_1+6, index_2)
            wifi_signal = string.sub(stdout, index_3+8, index_4-1)
            wifi_bitrate = string.sub(stdout, index_5+12, index_6)
            widget.inner.icon.text = "直"
            current_wifi = wifi
        end
    end,
    wifi_widget
)



-- Setup Mouse Bindings {{{1
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

-- Set Wallpaper {{{1
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

-- Create a wibox for each screen and add it {{{1
local index_of_screen = 1
awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    -- set_wallpaper(s)

    -- Each screen has its own tag table {{{2
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

    awful.tag.add("*", {
        layout = awful.layout.suit.floating,
        screen = s,
    })

    -- Hide specific tags {{{2
    local original_taglist_label = awful.widget.taglist.taglist_label
    function awful.widget.taglist.taglist_label(tag, args, tb)
      local text, bg, bg_image, icon, other_args =
        original_taglist_label(tag, args, tb)
    
      -- Hide tags 11, 12 and 13
      if tag.index == 11 or tag.index == 12 or tag.index == 13 then
          text = ""
      end
    
      return text, bg, bg_image, icon, other_args
    end

    -- Create a promptbox for each screen {{{2
    s.mypromptbox = awful.widget.prompt()

    -- Create a taglist widget {{{2
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.noempty,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget {{{2
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
        style    = {
            shape  = function(cr,w,h) gears.shape.rounded_rect(cr,w,h, 4) end,
            align = "center"
        },
    }

    -- Middle Widget {{{2
    middle_widgets[index_of_screen] = wibox.widget {
        s.mytasklist,
        {
            {
                {
                    id = 'inner',
                    text = 'Hello World',
                    widget = wibox.widget.textbox
                },
                id = 'margin',
                left = 5,
                right = 5,
                widget = wibox.container.margin
            },
            id = 'message',
            fg = xrdb.color0,
            bg = xrdb.color3,
            widget = wibox.container.background
        },
        layout = wibox.layout.ratio.horizontal
    }
    middle_widgets[index_of_screen]:ajust_ratio(2, 1, 0, 0)

    -- Create the wibox {{{2
    s.mywibox = awful.wibar({ position = "top", screen = s, opacity = 0.95 })

    -- Add widgets to the wibox {{{2
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
            s.mypromptbox,
        },
        middle_widgets[index_of_screen], -- Middle widget
        { -- Right widgets
            {
                {
                    wifi_widget,
                    cpu_widget,
                    volume_widget,
                    battery_widget,
                    {
                        {
                            format = '%b %d, %H:%M',
                            widget = wibox.widget.textclock(),
                        },
                        fg = xrdb.color3,
                        widget = wibox.container.background
                    },
                    {
                        {
                            widget = wibox.widget.systray(),
                        },
                        margins = 4,
                        widget = wibox.container.margin
                    },

                    spacing_widget = {
                        text = '|',
                        align = 'center',
                        widget = wibox.widget.textbox,
                    },
                    spacing = 20,
                    layout = wibox.layout.fixed.horizontal,
                },
                left = 8,
                widget = wibox.container.margin
            },
            bg = xrdb.color8,
            fg = xrdb.color7,
            widget = wibox.container.background
        },
    }
    -- }}}2

    index_of_screen = index_of_screen + 1
end)

-- Show / Hide message in wibar {{{1
function show_message(message)
    for _, middle_widget in ipairs(middle_widgets) do
        middle_widget.message.margin.inner.text = message
        middle_widget:ajust_ratio(2, 0, 1, 0)
    end
end

function hide_message()
    for _, middle_widget in ipairs(middle_widgets) do
        middle_widget:ajust_ratio(2, 1, 0, 0)
    end
end
