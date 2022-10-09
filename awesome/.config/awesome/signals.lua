-- Helper functions {{{1

local function getBorderWidthOfTiledClient(client)
    -- use tiled_clients so that other floating windows don't affect the count
    -- but iterate over clients instead of tiled_clients as tiled_clients doesn't include maximized windows
    local s = client.screen
    local only_one = #s.tiled_clients == 1

    if (only_one and not client.floating) or client.maximized then
        return 0
    else
        return beautiful.border_width
    end
end

-- Show or hide titlebar in the specified window
local function setTitlebar(client, showBar)
    if showBar then
        if client.titlebar == nil then
            client:emit_signal("request::titlebars", "rules", {})
        end
        awful.titlebar.show(client)
        client.border_width = 0
    else
        awful.titlebar.hide(client)
        client.border_width = getBorderWidthOfTiledClient(client)
    end
end

-- Signals {{{1

-- Signal function to execute when a new client appears
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes
        awful.placement.no_offscreen(c)
    end

    -- Show titlebar only on floating windows
    setTitlebar(c, c.floating or (c.first_tag ~= nil and c.first_tag.layout == awful.layout.suit.floating))
end)


-- Add a titlebar if titlebars_enabled is set to true in the rules
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    local top_titlebar = awful.titlebar(c, {
        size = 35,
    })

    top_titlebar : setup {
        { -- Left
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c)
    client.border_width = getBorderWidthOfTiledClient(c)
    c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

tag.connect_signal("property::layout", function(t)
    -- Show titlebars on tags with the floating layout
    for _, c in pairs(t:clients()) do
        if t.layout == awful.layout.suit.floating or c.floating and not c.fullscreen then
            setTitlebar(c, true)

            -- Make rounded borders around clients
            gears.timer.delayed_call(function()
                gears.surface.apply_shape_bounding(c, gears.shape.rounded_rect, 10)
            end)
        else
            setTitlebar(c, false)
        end
    end
end)

client.connect_signal("property::size", function (c)
    if (c.floating or (c.first_tag ~= nil and c.first_tag.layout == awful.layout.suit.floating)) and not c.fullscreen then
        gears.timer.delayed_call(function()
            -- Show titlebar
            setTitlebar(c, true)

            -- Make rounded borders around clients
            gears.surface.apply_shape_bounding(c, gears.shape.rounded_rect, 10)
        end)
    else
        gears.timer.delayed_call(function()
            -- Hide titlebar
            setTitlebar(c, false)
        end)
    end
end)
