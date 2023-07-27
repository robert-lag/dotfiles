local battery_widget = require("battery-widget")

-- CPU Widget {{{1

-- Popup {{{2
local name_column_width = 150
local usage_column_width = 50
local cpu_popup = awful.popup {
    widget = {
        {
            {
                {
                    {
                        id = 'icon',
                        text = '',
                        align = 'left',
                        valign = 'center',
                        font = "Monospace 20",
                        forced_width = 30,
                        widget = wibox.widget.textbox,
                    },
                    {
                        text = 'CPU',
                        align = 'left',
                        valign = 'center',
                        font = 'Monospace Bold 15',
                        widget = wibox.widget.textbox,
                    },
                    widget = wibox.layout.fixed.horizontal,
                },
                fg = xrdb.color4,
                widget = wibox.container.background,
            },
            {
                opacity = 0,
                forced_width = 0,
                forced_height = 10,
                widget = wibox.widget.separator
            },
            {
                {
                    id = 'label',
                    markup = '<b>Total usage:</b> ',
                    align = 'left',
                    valign = 'center',
                    widget = wibox.widget.textbox,
                },
                {
                    id = 'value',
                    text = '0%',
                    align = 'right',
                    valign = 'center',
                    widget = wibox.widget.textbox,
                },
                id = 'total_usage',
                forced_width = 120,
                widget = wibox.layout.align.horizontal
            },
            {
                forced_width = 0,
                forced_height = 20,
                color = darker(xrdb.color0, -40),
                widget = wibox.widget.separator
            },
            {
                {
                    {
                        markup = '<b>Command</b>',
                        valign = 'center',
                        forced_width = name_column_width,
                        widget = wibox.widget.textbox,
                    },
                    fg = xrdb.color4,
                    widget = wibox.container.background
                },
                {
                    {
                        markup = '<b>Usage</b>',
                        valign = 'center',
                        align = 'right',
                        forced_width = usage_column_width,
                        widget = wibox.widget.textbox,
                    },
                    fg = xrdb.color4,
                    widget = wibox.container.background
                },
                {
                    id = 'name_1',
                    markup = '-',
                    valign = 'center',
                    forced_width = name_column_width,
                    widget = wibox.widget.textbox,
                },
                {
                    id = 'usage_1',
                    markup = '-',
                    valign = 'center',
                    align = 'right',
                    forced_width = usage_column_width,
                    widget = wibox.widget.textbox,
                },
                {
                    id = 'name_2',
                    markup = '-',
                    valign = 'center',
                    forced_width = name_column_width,
                    widget = wibox.widget.textbox,
                },
                {
                    id = 'usage_2',
                    markup = '-',
                    valign = 'center',
                    align = 'right',
                    forced_width = usage_column_width,
                    widget = wibox.widget.textbox,
                },
                {
                    id = 'name_3',
                    markup = '-',
                    valign = 'center',
                    forced_width = name_column_width,
                    widget = wibox.widget.textbox,
                },
                {
                    id = 'usage_3',
                    markup = '-',
                    valign = 'center',
                    align = 'right',
                    forced_width = usage_column_width,
                    widget = wibox.widget.textbox,
                },
                {
                    id = 'name_4',
                    markup = '-',
                    valign = 'center',
                    forced_width = name_column_width,
                    widget = wibox.widget.textbox,
                },
                {
                    id = 'usage_4',
                    markup = '-',
                    valign = 'center',
                    align = 'right',
                    forced_width = usage_column_width,
                    widget = wibox.widget.textbox,
                },
                {
                    id = 'name_5',
                    markup = '-',
                    valign = 'center',
                    forced_width = name_column_width,
                    widget = wibox.widget.textbox,
                },
                {
                    id = 'usage_5',
                    markup = '-',
                    valign = 'center',
                    align = 'right',
                    forced_width = usage_column_width,
                    widget = wibox.widget.textbox,
                },
                id = 'usage_grid',
                forced_num_cols = 2,
                forced_num_rows = 2,
                homogeneous = false,
                expand = true,
                layout = wibox.layout.grid,
            },
            id = 'inner',
            layout = wibox.layout.fixed.vertical
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
    fg = xrdb.color7,
    bg = xrdb.color0,
}

-- Widget {{{2
local cpu_widget = wibox.widget {
    {
        {
            id = 'icon',
            text = '',
            align = 'left',
            valign = 'center',
            font = "monospace 15",
            forced_width = 20,
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
        awful.button({ }, 1, function()
            if cpu_popup.visible then
                cpu_popup.visible = false
            else
                hide_popups()
                cpu_popup:move_next_to(mouse.current_widget_geometry)
            end
        end),
        awful.button({ }, 3, function() awful.spawn(string.format("%s -e htop", terminal)) end)
    )
}

-- Update widget {{{2
local function update_cpu_widget()
    awful.spawn.easy_async_with_shell("top -b -n2 | grep '%Cpu' | tail -1 | grep -P '(....|...) id,'|awk '{print 100-$8 }'", function(out)
        local usage = string.format("%2d%%",math.floor(out))
        cpu_widget.inner.number.text = usage
        cpu_popup.widget.inner.total_usage.value.text = usage
    end)
    awful.spawn.easy_async_with_shell("top -b -n2 -w 200 | grep -A 5 '%CPU' | tail -5 | awk '{print $9,$12 }'", function(out)
        result = {}
        for match in string.gmatch(out, '[^ \n]+') do
            table.insert(result, match)
        end

        cpu_popup.widget.inner.usage_grid.usage_1.text = result[1] .. "%"
        cpu_popup.widget.inner.usage_grid.name_1.text = result[2]
        cpu_popup.widget.inner.usage_grid.usage_2.text = result[3] .. "%"
        cpu_popup.widget.inner.usage_grid.name_2.text = result[4]
        cpu_popup.widget.inner.usage_grid.usage_3.text = result[5] .. "%"
        cpu_popup.widget.inner.usage_grid.name_3.text = result[6]
        cpu_popup.widget.inner.usage_grid.usage_4.text = result[7] .. "%"
        cpu_popup.widget.inner.usage_grid.name_4.text = result[8]
        cpu_popup.widget.inner.usage_grid.usage_5.text = result[9] .. "%"
        cpu_popup.widget.inner.usage_grid.name_5.text = result[10]
    end)
end

update_cpu_widget()

cpu_widget_timer = timer({ timeout = 4.0 })
cpu_widget_timer:connect_signal("timeout", update_cpu_widget)
cpu_widget_timer:start()
-- }}}2

-- Volume Widget {{{1

-- Popup {{{2
local slider_height = 12
local volume_popup_width = 250
local volume_popup = awful.popup {
    widget = {
        {
            {
                {
                    {
                        id = 'icon',
                        text = '墳',
                        align = 'center',
                        valign = 'center',
                        font = 'Monospace 15',
                        forced_width = 25,
                        widget = wibox.widget.textbox,
                    },
                    id = 'margins',
                    right = 10,
                    widget = wibox.container.margin
                },
                {
                    id = 'slider',
                    bar_shape = function(cr, width, height)
                        gears.shape.rounded_rect(cr, width, height, 2)
                    end,
                    bar_color = darker(xrdb.color8, -20),
                    bar_active_color = xrdb.color5,
                    bar_height = 4,
                    handle_shape = gears.shape.circle,
                    handle_color = xrdb.color5,
                    handle_width = slider_height,
                    forced_height = slider_height,
                    widget = wibox.widget.slider,
                },
                {
                    id = 'value',
                    markup = ' 0%',
                    align = 'right',
                    valign = 'center',
                    widget = wibox.widget.textbox,
                },
                id = 'volume',
                forced_width = volume_popup_width,
                widget = wibox.layout.align.horizontal
            },
            {
                opacity = 0,
                forced_width = 0,
                forced_height = 8,
                widget = wibox.widget.separator
            },
            {
                {
                    {
                        id = 'icon',
                        text = ' ',
                        align = 'center',
                        valign = 'center',
                        font = 'Monospace 15',
                        forced_width = 25,
                        widget = wibox.widget.textbox,
                    },
                    id = 'margins',
                    right = 10,
                    widget = wibox.container.margin
                },
                {
                    id = 'slider',
                    bar_shape = function(cr, width, height)
                        gears.shape.rounded_rect(cr, width, height, 2)
                    end,
                    bar_color = darker(xrdb.color8, -20),
                    bar_active_color = xrdb.color5,
                    bar_height = 4,
                    handle_shape = gears.shape.circle,
                    handle_color = xrdb.color5,
                    handle_width = slider_height,
                    forced_height = slider_height,
                    widget = wibox.widget.slider,
                },
                {
                    id = 'value',
                    markup = ' 0%',
                    align = 'right',
                    valign = 'center',
                    widget = wibox.widget.textbox,
                },
                id = 'microphone',
                forced_width = volume_popup_width,
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
    opacity      = 0.85,
    fg = xrdb.color7,
    bg = xrdb.color0,
}

-- Widget {{{2
local volume_widget = wibox.widget {
    {
        {
            id = 'icon',
            text = '墳',
            align = 'center',
            valign = 'center',
            font = "Monospace 15",
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
    widget = wibox.container.background,
    buttons = gears.table.join(
        awful.button({ }, 1, function()
            if volume_popup.visible then
                volume_popup.visible = false
            else
                hide_popups()
                volume_popup:move_next_to(mouse.current_widget_geometry)
            end
        end)
    )
}

-- Update widget {{{2
local volume_slider_initialized = false
local microphone_slider_initialized = false
function update_volume_widget()
    awful.spawn.easy_async_with_shell("get-volume", function(out)
        local volume = tonumber(out)

        if volume == nil then
            return
        end

        if volume <= 0 then
            volume_widget.inner.icon.text = '󰝟'
            volume_popup.widget.inner.volume.margins.icon.text = '󰝟'
        else
            volume_widget.inner.icon.text = '󰕾'
            volume_popup.widget.inner.volume.margins.icon.text = '󰕾'
        end
        volume_widget.inner.number.text = string.format("%2d%%", volume)
        volume_popup.widget.inner.volume.value.text = string.format(" %2d%%", volume)
    end)
    awful.spawn.easy_async_with_shell("get-microphone-volume", function(out)
        local mic_volume = tonumber(out)
        if mic_volume <= 0 then
            volume_popup.widget.inner.microphone.margins.icon.text = '󰍭'
        else
            volume_popup.widget.inner.microphone.margins.icon.text = '󰍬'
        end
        volume_popup.widget.inner.microphone.value.text = string.format(" %2d%%", mic_volume)
    end)
end

local manual_set_of_volume_slider = false
local manual_set_of_microphone_slider = false

local function set_volume_slider_without_signal(value)
    manual_set_of_volume_slider = true
    volume_popup.widget.inner.volume.slider.value = value
end

local function set_microphone_slider_without_signal(value)
    manual_set_of_microphone_slider = true
    volume_popup.widget.inner.microphone.slider.value = value
end

function set_volume_sliders()
    awful.spawn.easy_async_with_shell("get-volume", function(out)
        local volume = tonumber(out)
        volume_popup.widget.inner.volume.value.text = string.format(" %2d%%", volume)
        set_volume_slider_without_signal(volume)
    end)
    awful.spawn.easy_async_with_shell("get-microphone-volume", function(out)
        local mic_volume = tonumber(out)
        volume_popup.widget.inner.microphone.value.text = string.format(" %2d%%", mic_volume)
        volume_popup.widget.inner.microphone.slider.value = mic_volume
        set_microphone_slider_without_signal(mic_volume)
    end)
end

update_volume_widget()
set_volume_sliders()

volume_popup.widget.inner.volume.slider:connect_signal("property::value", function(widget, new_value)
    if manual_set_of_volume_slider then
        manual_set_of_volume_slider = false
        return
    end

    awful.spawn(string.format("pactl set-sink-volume @DEFAULT_SINK@ %d%%", new_value))
    awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ 0")
    update_volume_widget()
end)
volume_popup.widget.inner.microphone.slider:connect_signal("property::value", function(widget, new_value)
    if manual_set_of_microphone_slider then
        manual_set_of_microphone_slider = false
        return
    end

    awful.spawn(string.format("pactl set-source-volume @DEFAULT_SOURCE@ %d%%", new_value))
    awful.spawn("pactl set-source-mute @DEFAULT_SOURCE@ 0")
    update_volume_widget()
end)

volume_popup.widget.inner.volume.margins.icon:connect_signal("button::press", function()
    awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
    update_volume_widget()
    set_volume_sliders()
end)

volume_popup.widget.inner.microphone.margins.icon:connect_signal("button::press", function()
    awful.spawn("pactl set-source-mute @DEFAULT_SOURCE@ toggle")
    update_volume_widget()
    set_volume_sliders()
end)

volume_widget_timer = timer({ timeout = 10.0 })
volume_widget_timer:connect_signal("timeout", update_volume_widget)
volume_widget_timer:start()
-- }}}2

-- Battery Widget {{{1

-- Popup {{{2
local battery_popup = awful.popup {
    widget = {
        {
            {
                {
                    {
                        id = 'icon',
                        text = '󰁹',
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
                    markup = '<b>Battery:</b> ',
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
                    markup = '<b>Time left:</b> ',
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
    fg = xrdb.color7,
    bg = xrdb.color0,
}

-- Widget {{{2
local battery_widget_ui = wibox.widget {
    {
        {
            id = 'icon',
            text = '󰁹',
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
                hide_popups()
                battery_popup:move_next_to(mouse.current_widget_geometry)
            end
        end)
    )
}

-- Create the battery widget
local battery_widget = battery_widget {
    screen = screen,
    use_display_device = true,
    instant_update = true,
    widget_template = battery_widget_ui
}

-- Update widget {{{2
local was_discharging = false
local brightness_reduced_warning = false
local brightness_reduced_critical = false

battery_widget:connect_signal('upower::update', function (widget, device)
    local battery_icon
    local battery_color = xrdb.color2
    local time_left
    if device.state == 1 or device.state == 5 then
        -- Device is charging (state 1) or pending charging (state 5)
        time_left = device.time_to_full / 3600

        -- Set the brightness to maximum after plugging in the cable
        if was_discharging then
            awful.spawn("xbacklight -set 100 -time 500")
            was_discharging = false
        end

        battery_icon = "󰂄"

        brightness_reduced_warning = false
        brightness_reduced_critical = false
    elseif device.state == 2 then
        -- Device is discharging (state 2)
        time_left = device.time_to_empty / 3600

        was_discharging = true

        if device.percentage <= 5 then
            battery_icon = "󰂃"
            if not brightness_reduced_critical then
                awful.spawn("set-max-brightness 10")
                awful.spawn("notify-send --urgency critical --icon=~/.local/share/dunst/icons/battery-alert.png -- 'Very Low Battery'")
                brightness_reduced_critical = true
            end
        elseif device.percentage <= 10 then
            battery_icon = "󰁺"
            if not brightness_reduced_warning then
                awful.spawn("set-max-brightness 50")
                awful.spawn("notify-send --icon=~/.local/share/dunst/icons/battery-alert.png -- 'Low Battery'")
                brightness_reduced_warning = true
            end
        elseif device.percentage <= 20 then
            battery_icon = "󰁻"
            if not brightness_reduced_warning then
                awful.spawn("set-max-brightness 50")
                awful.spawn("notify-send --icon=~/.local/share/dunst/icons/battery-alert.png -- 'Low Battery'")
                brightness_reduced_warning = true
            end
        elseif device.percentage <= 30 then
            battery_icon = "󰁼"
        elseif device.percentage <= 40 then
            battery_icon = "󰁽"
        elseif device.percentage <= 50 then
            battery_icon = "󰁾"
        elseif device.percentage <= 60 then
            battery_icon = "󰁿"
        elseif device.percentage <= 70 then
            battery_icon = "󰂀"
        elseif device.percentage <= 80 then
            battery_icon = "󰂁"
        elseif device.percentage <= 90 then
            battery_icon = "󰂂"
        else
            battery_icon = "󰁹"
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
        battery_icon = "󰁹"
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

-- Popup {{{2
local wifi_popup_width = 220
local wifi_popup = awful.popup {
    widget = {
        {
            {
                {
                    {
                        id = 'value',
                        markup = '<b>Not Connected</b>',
                        align = 'center',
                        valign = 'center',
                        font = 'Monospace 14',
                        widget = wibox.widget.textbox,
                    },
                    id = 'inner',
                    widget = wibox.layout.fixed.horizontal,
                },
                id = 'connected',
                fg = xrdb.color6,
                widget = wibox.container.background,
            },
            {
                forced_width = 0,
                forced_height = 20,
                color = darker(xrdb.color0, -40),
                widget = wibox.widget.separator
            },
            {
                {
                    id = 'icon',
                    text = '󰒢',
                    align = 'left',
                    valign = 'center',
                    font = 'Monospace 15',
                    forced_width = 25,
                    widget = wibox.widget.textbox,
                },
                {
                    id = 'label',
                    markup = '<b>Signal:</b> ',
                    align = 'left',
                    valign = 'center',
                    widget = wibox.widget.textbox,
                },
                {
                    id = 'value',
                    text = '- dBm',
                    align = 'right',
                    valign = 'center',
                    widget = wibox.widget.textbox,
                },
                id = 'signal',
                forced_width = wifi_popup_width,
                widget = wibox.layout.align.horizontal
            },
            {
                {
                    id = 'icon',
                    text = '󰕒',
                    align = 'left',
                    valign = 'center',
                    font = 'Monospace 15',
                    forced_width = 25,
                    widget = wibox.widget.textbox,
                },
                {
                    id = 'label',
                    markup = '<b>Upload:</b> ',
                    align = 'left',
                    valign = 'center',
                    widget = wibox.widget.textbox,
                },
                {
                    id = 'value',
                    text = '- MBit/s',
                    align = 'right',
                    valign = 'center',
                    widget = wibox.widget.textbox,
                },
                id = 'upload',
                forced_width = wifi_popup_width,
                widget = wibox.layout.align.horizontal
            },
            {
                {
                    id = 'icon',
                    text = '󰇚',
                    align = 'left',
                    valign = 'center',
                    font = 'Monospace 15',
                    forced_width = 25,
                    widget = wibox.widget.textbox,
                },
                {
                    id = 'label',
                    markup = '<b>Download:</b> ',
                    align = 'left',
                    valign = 'center',
                    widget = wibox.widget.textbox,
                },
                {
                    id = 'value',
                    text = '- MBit/s',
                    align = 'right',
                    valign = 'center',
                    widget = wibox.widget.textbox,
                },
                id = 'download',
                forced_width = wifi_popup_width,
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
    fg = xrdb.color7,
    bg = xrdb.color0,
}

-- Widget {{{2
local connected_to_ethernet = true
local current_wifi = ""
local wifi_ui_collapsed = false
local wifi_widget = wibox.widget {
    {
        {
            id = 'icon',
            text = '󰌗',
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
                if wifi_popup.visible then
                    wifi_popup.visible = false
                else
                    hide_popups()
                    wifi_popup:move_next_to(mouse.current_widget_geometry)
                end
                -- if connected_to_ethernet then
                --     awful.spawn("notify-send --expire-time 4000 --icon=~/.local/share/dunst/icons/lan.png -- 'Ethernet'")
                -- else
                --     awful.spawn(string.format("notify-send --expire-time 4000 --icon=~/.local/share/dunst/icons/wifi.png -- '%s'", current_wifi))
                -- end
            end),
            awful.button({ }, 2, function() awful.spawn("dmenu-wlan-scanner") end),
            awful.button({ }, 3, function() awful.spawn(string.format("%s -e %s -c 'iwctl station wlan0 show; iwctl'", terminal, shell)) end)
    )
}

-- Update widget {{{2
awful.widget.watch(
    "iw dev wlan0 link", 5,
    function(widget, stdout, stderr, exitreason, exitcode)
        if connected_to_ethernet == true then
            return
        end

        local wifi = string.match(stdout, "SSID:.*\n")
        local index_1, index_2 = string.find(stdout, "SSID: [^\n]*")
        local index_3, index_4 = string.find(stdout, "signal: [^\n]*")
        local index_5, index_6 = string.find(stdout, "tx bitrate:%s%d+%p+%d+%s%a+%p%a")
        local index_7, index_8 = string.find(stdout, "rx bitrate:%s%d+%p+%d+%s%a+%p%a")

        if ( wifi == '' or wifi == nil ) then
            widget.inner.icon.text = "󰖪"
            current_wifi = ""
            wifi_popup.widget.inner.connected.inner.value.markup = "<b>Not Connected</b>"
            wifi_popup.widget.inner.download.value.text = "- Mbit/s"
            wifi_popup.widget.inner.upload.value.text = "- Mbit/s"
            wifi_popup.widget.inner.signal.value.text = "- dBm"
        else
            wifi = string.sub(stdout, index_1+6, index_2)
            wifi_signal = string.sub(stdout, index_3+8, index_4)
            wifi_bitrate_tx = string.sub(stdout, index_5+12, index_6)
            wifi_bitrate_rx = string.sub(stdout, index_7+12, index_8)
            widget.inner.icon.text = "󰖩"
            current_wifi = wifi
            wifi_popup.widget.inner.connected.inner.value.markup = "<b>" .. wifi .. "</b>"
            wifi_popup.widget.inner.download.value.text = wifi_bitrate_rx
            wifi_popup.widget.inner.upload.value.text = wifi_bitrate_tx
            wifi_popup.widget.inner.signal.value.text = wifi_signal
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
            widget.inner.icon.text = "󰌗"
            wifi_popup.widget.inner.connected.inner.value.markup = "<b>Ethernet</b>"
            wifi_popup.widget.inner.download.value.text = "- Mbit/s"
            wifi_popup.widget.inner.upload.value.text = "- Mbit/s"
            wifi_popup.widget.inner.signal.value.text = "- dBm"
        end
    end,
    wifi_widget
)
-- }}}2

-- Calendar widget {{{1

-- Popup {{{2
local styles = {}
local function rounded_shape(size, partial)
    if partial then
        return function(cr, width, height)
                   gears.shape.partially_rounded_rect(cr, width, height,
                        false, true, false, true, 5)
               end
    else
        return function(cr, width, height)
                   gears.shape.rounded_rect(cr, width, height, size)
               end
    end
end
styles.month = {
    padding      = 10,
    shape        = rounded_shape(5),
}
styles.normal  = {
    shape    = rounded_shape(5),
}
styles.focus = {
    fg_color = xrdb.color0,
    bg_color = xrdb.color3,
    markup   = function(t) return '<b>' .. t .. '</b>' end,
    shape    = rounded_shape(5, true),
}
styles.header = {
    fg_color = xrdb.color3,
    markup   = function(t) return '<b>' .. t .. '</b>' end,
    shape    = rounded_shape(10),
}
styles.weekday = {
    -- fg_color = xrdb.color6,
    markup   = function(t) return '<b>' .. t .. '</b>' end,
}
styles.weeknumber = {
    fg_color = darker(xrdb.color7, 60),
}
styles.weekend = {
    bg_color = darker(xrdb.color0, -10),
}

local function decorate_cell(widget, flag, date)
    -- Replace flag 'monthheader' with 'header'
    if flag=='monthheader' and not styles.monthheader then
        flag = 'header'
    end

    -- Get style for current cell
    local props = styles[flag] or {}
    local weekend_props = styles['weekend']

    local default = {
        shape = rounded_shape(5),
        border_color = xrdb.color8,
        border_width = 0,
        fg_color = xrdb.color15,
        bg_color = xrdb.color0 .. "00",
        padding = 4,
        markup   = function(t) return t end,
    }

    local result_props = default

    -- Different 'normal' style for weekends
    local d = {year=date.year, month=(date.month or 1), day=(date.day or 1)}
    local weekday = tonumber(os.date('%w', os.time(d)))

    if (weekday==0 or weekday==6) and flag=='normal' then
        -- awful.spawn(string.format("notify-send '%d %s'", weekday, flag))
        result_props.shape          = weekend_props.shape or props.shape or default.shape
        result_props.border_color   = weekend_props.border_color or props.border_color or default.border_color
        result_props.border_width   = weekend_props.border_width or props.border_width or default.border_width
        result_props.fg_color       = weekend_props.fg_color or props.fg_color or default.fg_color
        result_props.bg_color       = weekend_props.bg_color or props.bg_color or default.bg_color
        result_props.padding        = weekend_props.padding or props.padding or default.padding
        result_props.markup         = weekend_props.markup or props.markup or default.markup
    else
        result_props.shape          = props.shape or default.shape
        result_props.border_color   = props.border_color or default.border_color
        result_props.border_width   = props.border_width or default.border_width
        result_props.fg_color       = props.fg_color or default.fg_color
        result_props.bg_color       = props.bg_color or default.bg_color
        result_props.padding        = props.padding or default.padding
        result_props.markup         = props.markup or default.markup
    end

    -- Apply style
    if widget.get_text and widget.set_markup then
        widget:set_markup(result_props.markup(widget:get_text()))
    end

    local ret = wibox.widget {
        {
            widget,
            margins = result_props.padding + result_props.border_width,
            widget  = wibox.container.margin
        },
        shape              = result_props.shape,
        shape_border_color = result_props.border_color,
        shape_border_width = result_props.border_width,
        fg                 = result_props.fg_color,
        bg                 = result_props.bg_color,
        widget             = wibox.container.background
    }
    return ret
end

local calendar_popup = awful.popup {
    widget = {
        {
            {
                id = 'icon',
                text = '󰀀',
                align = 'center',
                valign = 'center',
                font = 'ClockFaceFatSolid 50',
                widget = wibox.widget.textbox,
            },
            {
                id = 'value',
                refresh = 1,
                format = '%H:%M:%S',
                font = 'Monospace 25',
                align = 'center',
                widget = wibox.widget.textclock(),
            },
            {
                forced_width = 0,
                forced_height = 20,
                color = darker(xrdb.color0, -40),
                widget = wibox.widget.separator
            },
            {
                id = 'calendar',
                date = os.date('*t'),
                week_numbers = true,
                spacing = 10,
                fn_embed = decorate_cell,
                widget = wibox.widget.calendar.month
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
    fg = xrdb.color3,
    bg = xrdb.color0,
}

-- Widget {{{2
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
            if calendar_popup.visible then
                calendar_popup.visible = false
            else
                hide_popups()
                calendar_popup:move_next_to(mouse.current_widget_geometry)
            end
        end)
    )
}

-- Update widget {{{2
local function get_clock_icon(time)
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

    return hexdecode(string.format("%x",textclock_icon))
end

calendar_popup.widget.inner.icon.text = get_clock_icon(textclock.inner.clock.text)
textclock.inner.icon.text = get_clock_icon(textclock.inner.clock.text)

textclock.inner.clock:connect_signal("widget::redraw_needed", function()
    calendar_popup.widget.inner.calendar.date = os.date('*t')
    calendar_popup.widget.inner.icon.text = get_clock_icon(textclock.inner.clock.text)
    textclock.inner.icon.text = get_clock_icon(textclock.inner.clock.text)
end)

textclock.inner.clock:connect_signal("button::press", function()
    textclock.inner.clock:force_update()
end)
-- }}}2

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
    -- Create tags {{{2
    for i = 1, 10 do
        awful.tag.add(tostring(i), {
            layout = awful.layout.layouts[1],
            screen = s,
            selected = (i == 1)     -- Select first tag
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

    awful.tag.add(" ", {
        layout = awful.layout.layouts[1],
        screen = s,
    })

    -- Create a promptbox for each screen {{{2
    s.mypromptbox = awful.widget.prompt()

    -- Create a taglist widget {{{2
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = function(t)
            -- Hide empty tags and tags 11 - 14
            return awful.widget.taglist.filter.noempty(t) and
                   t.index ~= 11 and
                   t.index ~= 12 and
                   t.index ~= 13 and
                   t.index ~= 14
        end,
        buttons = taglist_buttons,
        widget_template = {
            {
                {
                    id = "bottom_border",
                    widget = wibox.widget.separator,
                    forced_height = 2,
                    thickness = 2,
                    forced_width = 5,
                    orientation = "horizontal",
                    color = beautiful.taglist_border_color
                },
                {
                    {
                        id = 'text_role',
                        widget = wibox.widget.textbox,
                    },
                    left  = 5,
                    right = 5,
                    top = 4,
                    bottom = 4,
                    id = 'text_margin_role',
                    widget = wibox.container.margin
                },
                layout = wibox.layout.fixed.vertical,
            },
            id     = 'background_role',
            widget = wibox.container.background,

            -- Add support for hover colors
            create_callback = function(self, tag, _, _)
                if tag.selected then
                    self:get_children_by_id("bottom_border")[1].color = beautiful.taglist_border_color
                else
                    self:get_children_by_id("bottom_border")[1].color = beautiful.taglist_bg_normal
                end

                self:connect_signal('mouse::enter', function()
                    if self.bg ~= beautiful.taglist_bg_hover then
                        self.fg_backup = self.fg
                        self.bg_backup = self.bg
                        self.has_color_backup = true
                    end
                    self.fg = beautiful.taglist_fg_hover
                    self.bg = beautiful.taglist_bg_hover
                end)
                self:connect_signal('mouse::leave', function()
                    if self.has_color_backup then
                        self.fg = self.fg_backup
                        self.bg = self.bg_backup
                    end
                end)
            end,
            update_callback = function(self, tag, _, _)
                if tag.selected then
                    self:get_children_by_id("bottom_border")[1].color = beautiful.taglist_border_color
                else
                    self:get_children_by_id("bottom_border")[1].color = beautiful.taglist_bg_normal
                end
            end,
        },
    }

    -- Create a tasklist widget {{{2
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.focused,
        buttons = tasklist_buttons,
        style   = {
            shape  = function(cr,w,h) gears.shape.rounded_rect(cr,w,h, 4) end,
            align = "center"
        },
    }

    -- Create the middle widget {{{2
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

-- Hide popups {{{1
function hide_popups()
    cpu_popup.visible = false
    volume_popup.visible = false
    calendar_popup.visible = false
    battery_popup.visible = false
    wifi_popup.visible = false
end
