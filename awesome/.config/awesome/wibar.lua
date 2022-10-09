local battery_widget = require("battery-widget")

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

local function update_cpu_widget()
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

local battery_popup = awful.popup {
    widget = {
        {
            {
                {
                    {
                        id = 'icon',
                        text = '',
                        align = 'center',
                        valign = 'center',
                        font = "monospace 25",
                        widget = wibox.widget.textbox,
                    },
                    id = 'inner',
                    fg = xrdb.color2,
                    widget = wibox.container.background
                },
                id = 'graph',
                thickness = 8,
                bg = xrdb.color8,
                colors = { xrdb.color2 },
                value = 40,
                min_value = 0,
                max_value = 100,
                rounded_edge = true,
                forced_width = 100,
                forced_height = 100,
                start_angle = 1.5 * math.pi,
                widget = wibox.container.arcchart
            },
            {
                opacity = 0,
                forced_width = 0,
                forced_height = 20,
                widget = wibox.widget.separator
            },
            {
                {
                    id = 'label',
                    text = 'Battery: ',
                    align = 'left',
                    valign = 'center',
                    widget = wibox.widget.textbox,
                },
                {
                    id = 'value',
                    text = '100%',
                    align = 'right',
                    valign = 'center',
                    widget = wibox.widget.textbox,
                },
                id = 'percentage',
                forced_width = 120,
                widget = wibox.layout.align.horizontal
            },
            {
                {
                    id = 'label',
                    text = 'Time left: ',
                    align = 'left',
                    valign = 'center',
                    widget = wibox.widget.textbox,
                },
                {
                    id = 'value',
                    text = '1h',
                    align = 'right',
                    valign = 'center',
                    widget = wibox.widget.textbox,
                },
                id = 'timeleft',
                forced_width = 120,
                widget = wibox.layout.align.horizontal
            },
            id = 'inner',
            layout = wibox.layout.fixed.vertical,
        },
        margins = 10,
        widget  = wibox.container.margin
    },
    border_color = xrdb.color8,
    border_width = 2,
    offset = { y = 5, x = 10 },
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 8)
    end,
    visible      = false,
    ontop        = true,
    hide_on_right_click = true,
    opacity      = 0.85,
}

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
    widget = wibox.container.background,
    buttons = gears.table.join(
        awful.button({ }, 1, function()
            if battery_popup.visible then
                battery_popup.visible = false
            else
                battery_popup:move_next_to(mouse.current_widget_geometry)
            end
        end)
    )
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

-- Update widget {{{2
battery_widget:connect_signal('upower::update', function (widget, device)
    local battery_icon
    local battery_color = xrdb.color2
    local time_left
    if device.state == 1 then
        -- Device is charging (state 1)
        time_left = device.time_to_full / 3600

        -- Set the brightness to maximum after plugging in the cable
        if was_discharging then
            awful.spawn("xbacklight -set 100 -time 500")
            was_discharging = false
        end

        battery_icon = ""

        brightness_reduced_warning = false
        brightness_reduced_critical = false
    elseif device.state == 2 then
        -- Device is discharging (state 2)
        time_left = device.time_to_empty / 3600

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
            battery_color = xrdb.color1
        elseif device.percentage <= 20 then
            battery_color = xrdb.color3
        end
    end

    if device.state == 4 then
        -- Device is fully charged (state 4)
        battery_popup.widget.inner.timeleft.visible = false
        battery_icon = ""
    else
        battery_popup.widget.inner.timeleft.visible = true
    end


    widget.fg = battery_color
    battery_popup.widget.inner.graph.colors = { battery_color }
    battery_popup.widget.inner.graph.inner.fg = battery_color

    widget.inner.icon.text = string.format('%s', battery_icon)
    widget.inner.number.text = string.format("%2d%%", device.percentage)
    battery_popup.widget.inner.graph.inner.icon.text = string.format('%s', battery_icon)
    battery_popup.widget.inner.graph.value = device.percentage
    battery_popup.widget.inner.percentage.value.text = string.format("%2d%%", device.percentage)
    battery_popup.widget.inner.timeleft.value.text = string.format("%.1fh", time_left)
end)
-- }}}2

-- Wifi widget {{{1
local connected_to_ethernet = true
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
                if connected_to_ethernet then
                    awful.spawn("notify-send --expire-time 4000 --icon=~/.local/share/dunst/icons/lan.png -- 'Ethernet'")
                else
                    awful.spawn(string.format("notify-send --expire-time 4000 --icon=~/.local/share/dunst/icons/wifi.png -- '%s'", current_wifi))
                end
            end),
            awful.button({ }, 2, function() awful.spawn("dmenu-wlan-scanner") end),
            awful.button({ }, 3, function() awful.spawn(string.format("%s -e %s -c 'iwctl station wlan0 show; iwctl'", terminal, shell)) end)
    )
}

awful.widget.watch(
    "iw dev wlan0 link", 5,
    function(widget, stdout, stderr, exitreason, exitcode)
        if connected_to_ethernet then
            return
        end

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

awful.widget.watch(
    "sh -c 'ip address show enp2s0 | grep inet'", 5,
    function(widget, stdout, stderr, exitreason, exitcode)
        if stdout == "" then
            connected_to_ethernet = false
        else
            connected_to_ethernet = true
            widget.inner.icon.text = ""
        end
    end,
    wifi_widget
)
-- Calendar widget {{{1
calendar_popup = awful.widget.calendar_popup.month({
    opacity = 0.85,
    margin = 5,
    week_numbers = true,
    style_month = {
        shape = function(cr,w,h) gears.shape.rounded_rect(cr,w,h, 5) end,
        border_width = 2,
        border_color = darker(xrdb.color8, 0)
    },
    style_focus = {
        shape = function(cr,w,h) gears.shape.rounded_rect(cr,w,h, 5) end,
        border_width = 1,
        border_color = darker(xrdb.color8, -20)
    },
    style_weeknumber = {
        fg_color = darker(xrdb.color8, -30)
    }
})

local textclock = wibox.widget {
    {
        {
            id = "icon",
            text = "󰀀",
            align = "left",
            valign = "center",
            font = "ClockFaceFatRectSolid 15",
            widget = wibox.widget.textbox,
        },
        {
            id = "clock",
            format = "%H:%M",
            widget = wibox.widget.textclock(),
        },
        id = 'inner',
        spacing = 5,
        layout = wibox.layout.fixed.horizontal,
    },
    fg = xrdb.color3,
    widget = wibox.container.background,
    buttons = gears.table.join(
        awful.button({ }, 1, function()
            calendar_popup:call_calendar(0, "tr", awful.screen.focused())
            calendar_popup:toggle()
        end)
    )
}

textclock.inner.clock:connect_signal("button::press", function()
    textclock.inner.clock:force_update()
end)

local function update_clock_icon(time)
    local hour_string, minute_string = time:match("^([0-9]+):([0-9]+)$")
    local hour = tonumber(hour_string) % 12
    local minute = tonumber(minute_string)

    -- Get icon (for every 5th minute)
    local textclock_icon = 0xf3b08080 + 12 * hour + (minute//5)

    if hour > 10 or (hour == 10 and minute >= 40) then
        textclock_icon = textclock_icon + 192*2
    elseif hour > 5 or (hour == 5 and minute >= 20) then
        textclock_icon = textclock_icon + 192
    end

    textclock.inner.icon.text = hexdecode(string.format("%x",textclock_icon))
end

update_clock_icon(textclock.inner.clock.text)

textclock.inner.clock:connect_signal("widget::redraw_needed", function()
    update_clock_icon(textclock.inner.clock.text)
end)

-- }}}1
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
    awful.button({ }, 1, function(c)
        c.fullscreen = not c.fullscreen
    end),
    awful.button({ }, 4, function()
        awful.client.focus.byidx(1)
    end),
    awful.button({ }, 5, function()
        awful.client.focus.byidx(-1)
    end)
)

-- Don't show the icons of the apps in the tasklist (= the bar at the top)
beautiful.tasklist_disable_icon = true

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
-- screen.connect_signal("property::geometry", set_wallpaper)

-- Create a wibox for each screen and add it {{{1
local index_of_screen = 1
awful.screen.connect_for_each_screen(function(s)
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
        filter  = awful.widget.tasklist.filter.focused,
        buttons = tasklist_buttons,
        style    = {
            shape  = function(cr,w,h) gears.shape.rounded_rect(cr,w,h, 4) end,
            align = "center"
        },
    }

    -- Create the middle Widget {{{2
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
            fg = xrdb.color3,
            bg = darker(xrdb.color8, -5),
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
                    textclock,
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
