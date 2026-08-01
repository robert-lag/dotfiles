-- Helper functions {{{1

awesome.register_xproperty("_AWESOME_SOLE_TILING_CLIENT", "boolean")

-- Update gap for a single tag based on number of tiled clients
local function updateTagGap(t)
    if not t then return end

    -- Floating layout: always no gap
    if t.layout == awful.layout.suit.floating then
        t.gap = 0
        return
    end
    
    local count = 0
    for _, c in ipairs(t:clients()) do
        -- Only count clients that are tiled (not floating, maximized, or fullscreen)
        if not c.floating and not c.maximized and not c.fullscreen then
            count = count + 1
        end
    end
    
    if count > 1 then
        t.gap = beautiful.useless_gap
    else
        t.gap = 0
    end
end

-- Update gap for all tags on all screens
local function updateAllTagGaps()
    for s in screen do
        for _,t in ipairs(s.tags) do
            updateTagGap(t)
        end
    end
end

-- Returns, if a specific client wants to be styled like a floating client (with titlebar, appropriate border, etc.)
local function wantsFloatingSettings(c)
    return c.floating or (c.first_tag ~= nil and c.first_tag.layout == awful.layout.suit.floating) and not c.fullscreen
end

local function updateBorder(client)
    -- use tiled_clients so that other floating windows don't affect the count
    -- but iterate over clients instead of tiled_clients as tiled_clients doesn't include maximized windows
    local s = client.screen
    local only_one = #s.tiled_clients == 1

    client:set_xproperty("_AWESOME_SOLE_TILING_CLIENT", only_one)

    -- A client should have a border only if it isn't floating and if at least
    -- one other non-floating client is shown next to it
    if (only_one and not client.floating) or client.maximized then
        client.border_width = 0
    elseif client.floating then
        client.border_width = beautiful.border_width_floating
        -- Floating clients always have border_floating
        client.border_color = beautiful.border_floating
    else
        client.border_width = beautiful.border_width_tiling
    end
end

-- Show or hide titlebar in the specified window
local function setTitlebar(client, showBar)
    if showBar then
        if client.titlebar == nil then
            client:emit_signal("request::titlebars", "rules", {})
        end
        awful.titlebar.show(client)
    else
        awful.titlebar.hide(client)
    end
end

-- Use tile.bottom in portrait and tile in landscape mode
local function updateLayoutBasedOnScreenGeometry(s, t)
    if s.geometry.width >= s.geometry.height then
        if t.layout == awful.layout.suit.tile.bottom then
            t.layout = awful.layout.suit.tile
        end
    else
        if t.layout == awful.layout.suit.tile then
            t.layout = awful.layout.suit.tile.bottom
        end
    end
end


-- Signals {{{1

-- manage {{{2

-- Signal function to execute when a new client appears
client.connect_signal("manage", function (c)
    if not c.valid then return end
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
    setTitlebar(c, wantsFloatingSettings(c))

    -- Delay a tiny bit to ensure the client is fully added to the tag
    gears.timer.delayed_call(function()
        updateTagGap(c.first_tag)
    end)
end)

-- request::titlebars {{{2
-- Add a titlebar if titlebars_enabled is set to true in the rules
client.connect_signal("request::titlebars", function(c)
    if not c.valid then return end
    -- Buttons for the titlebar
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
        size = beautiful.titlebar_size,
    })

    top_titlebar : setup {
        { -- Left
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                font   = beautiful.titlebar_font,
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- mouse::enter {{{2
-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if not c.valid then return end
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

-- focus / unfocus {{{2
client.connect_signal("focus", function(c)
    if not c.valid then return end
    updateBorder(c)

    -- Only change border color when tiling
    -- On floating windows the title name changes color instead, to highlight the window
    if wantsFloatingSettings(c) then
        c.border_color = beautiful.border_focus_floating
    else
        c.border_color = beautiful.border_focus
    end
end)

client.connect_signal("unfocus", function(c)
    if not c.valid then return end
    updateBorder(c)

    if wantsFloatingSettings(c) then
        c.border_color = beautiful.border_floating
    else
        c.border_color = beautiful.border_normal
    end
end)

-- property::layout {{{2
-- Called when the layout of a tag changes (floating, tiled, etc.)
tag.connect_signal("property::layout", function(t)
    -- Show titlebars on tags with the floating layout
    for _, c in pairs(t:clients()) do
        if ((t.layout == awful.layout.suit.floating or c.floating)) and not c.fullscreen then
            setTitlebar(c, not c.requests_no_titlebar)
        else
            setTitlebar(c, false)
        end
        updateBorder(c)
    end

    updateTagGap(t)
end)

-- property::size {{{2
client.connect_signal("property::size", function (c)
    if not c.valid then return end

    gears.timer.delayed_call(function()
        if not c.valid then return end

        if wantsFloatingSettings(c) then
            -- Show titlebar
            setTitlebar(c, not c.requests_no_titlebar)
        else
            -- Hide titlebar
            setTitlebar(c, false)
        end

        updateBorder(c)
        updateTagGap(c.first_tag)
    end)
end)

-- property::tags {{{2
-- When a client is moved to a different tag (or set of tags)
client.connect_signal("property::tags", function(c)
    if not c.valid then return end
    updateAllTagGaps()
end)


-- property::floating {{{2
awesome.register_xproperty("_AWESOME_FLOATING", "boolean")

client.connect_signal("property::floating", function(c)
    if not c.valid then return end
    gears.timer.delayed_call(function()
        if not c.valid then return end
        setTitlebar(c, c.floating)
        updateBorder(c)
        updateTagGap(c.first_tag)

        c:set_xproperty("_AWESOME_FLOATING", c.floating)

        if c.floating then
            c:raise()
        end
    end)
end)

-- property::maximized {{{2
client.connect_signal("property::maximized", function(c)
    if not c.valid then return end
    updateTagGap(c.first_tag)
end)

-- property::fullscreen {{{2
client.connect_signal("property::fullscreen", function(c)
    if not c.valid then return end
    updateTagGap(c.first_tag)
end)

-- Listen for screen rotation change {{{2

awful.spawn.with_line_callback({"sh", "-c", "xev -root -event randr"}, {
    stdout = function(line)
        -- Listen for screen rotation (can happen on notebooks)
        if line:match("RRScreenChangeNotify") then
            for s in screen do
                for _,t in ipairs(s.tags) do
                    updateLayoutBasedOnScreenGeometry(s,t)
                end
            end
        end
    end,
    stderr = function(line)
        awful.spawn(string.format("notify-send -u critical -- 'xev Error' '%s'", line))
    end,
})

