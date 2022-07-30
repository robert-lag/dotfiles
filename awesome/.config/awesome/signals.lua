local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local wibox = require("wibox")

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
        client.border_width = beautiful.border_width
    end
end

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end

    -- Show titlebar only on floating windows
    setTitlebar(c, c.floating or c.first_tag.layout == awful.layout.suit.floating)
end)


-- Add a titlebar if titlebars_enabled is set to true in the rules.
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

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

tag.connect_signal("property::layout", function(t)
    -- Show titlebars on tags with the floating layout
    for _, c in pairs(t:clients()) do
        if t.layout == awful.layout.suit.floating or c.floating and not c.fullscreen then
            setTitlebar(c, true)

            -- Make rounded borders around clients
            gears.timer.delayed_call(function()
                gears.surface.apply_shape_bounding(c, gears.shape.rounded_rect, 30)
            end)
        else
            setTitlebar(c, false)
        end
    end
end)

local function apply_shape(draw, shape, ...)
  local geo = draw:geometry()
  local shape_args = ...

  local img = cairo.ImageSurface(cairo.Format.A1, geo.width, geo.height)
  local cr = cairo.Context(img)

  cr:set_operator(cairo.Operator.CLEAR)
  cr:set_source_rgba(0,0,0,1)
  cr:paint()
  cr:set_operator(cairo.Operator.SOURCE)
  cr:set_source_rgba(1,1,1,1)

  shape(cr, geo.width, geo.height, shape_args)

  cr:fill()

  draw.shape_bounding = img._native

  cr:set_operator(cairo.Operator.CLEAR)
  cr:set_source_rgba(0,0,0,1)
  cr:paint()
  cr:set_operator(cairo.Operator.SOURCE)
  cr:set_source_rgba(1,1,1,1)

  local border = beautiful.base_border_width
  --local titlebar_height = titlebar.is_enabled(draw) and beautiful.titlebar_height or border
  local titlebar_height = border
  gears.shape.transform(shape):translate(
    border, titlebar_height
  )(
    cr,
    geo.width-border*2,
    geo.height-titlebar_height-border,
    --shape_args
    8
  )

  cr:fill()

  draw.shape_clip = img._native

  img:finish()
end

client.connect_signal("property::size", function (c)
    if (c.floating or c.first_tag.layout == awful.layout.suit.floating) and not c.fullscreen then
        gears.timer.delayed_call(function()
            -- Show titlebar
            setTitlebar(c, true)

            -- Make rounded borders around clients
            gears.surface.apply_shape_bounding(c, gears.shape.rounded_rect, 10)
        end)
    else
        -- Hide titlebar
        gears.timer.delayed_call(function()
            setTitlebar(c, false)
        end)
    end
end)
