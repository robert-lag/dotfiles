-- Original Source: https://gist.github.com/intrntbrn/65700d3d3ac1713b1d31c56a5fb09a04
--
-- Dependency: xdotool
--
-- Usage:
-- 1. Save as "virtual_keyboard.lua" in ~/.config/awesome/
-- 2. Add a virtual_keyboard for every screen:
--		awful.screen.connect_for_each_screen(function(s)
--			...
--			local virtual_keyboard = require("virtual_keyboard")
--			s.virtual_keyboard = virtual_keyboard:new({ screen = s } )
--			...
--		end)
-- 3. Toggle by using: awful.screen.focused().virtual_keyboard:toggle()

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local module = {}

local key_size = dpi(66)
local keyboard_bg = beautiful.keyboard_bg
local key_fg_color = beautiful.keyboard_key_fg
local key_bg_color = beautiful.keyboard_key_bg
local mod_fg_color = beautiful.keyboard_mod_fg
local mod_bg_color = beautiful.keyboard_mod_bg
local accent_fg_color = beautiful.keyboard_mod_accent_fg
local accent_bg_color = beautiful.keyboard_mod_accent_bg
local press_fg_color = beautiful.keyboard_mod_press_fg
local press_bg_color = beautiful.keyboard_mod_press_bg

local modifiers_to_clear = {}

function module.button(attributes)
	local attr = attributes or {}
    attr.toggled_on = false
	attr.toggleable = attr.toggleable or false
	attr.clear_after_one_use = attr.clear_after_one_use or false
	attr.size = attr.size or 1.0
	attr.name = attr.name or ""
	attr.keycode = attr.keycode or attr.name or nil
	attr.bg = attr.bg or key_bg_color
	attr.fg = attr.fg or key_fg_color
	attr.spacing = attr.spacing or dpi(3)
	local textbox = wibox.widget.textbox(attr.name)
	textbox.font = beautiful.keyboard_font
	local box = wibox.widget.base.make_widget_declarative({
			{
				{
					{
						{
							textbox,
							fill_vertical = false,
							fill_horizontal = false,
							valign = true,
							halign = true,
							widget = wibox.container.place
						},
						widget = wibox.container.margin
					},
					id = "bg",
					opacity = (string.len(attr.name) == 0) and 0 or 1,
					fg = attr.fg,
					bg = attr.bg,
					widget = wibox.container.background
				},
				right = attr.spacing,
				top = attr.spacing,
				forced_height = key_size,
				forced_width = key_size * attr.size,
				widget = wibox.container.margin
			},
			widget = wibox.container.background,
			bg = keyboard_bg

		})

	local boxbg = box:get_children_by_id("bg")[1]

    local time_until_long_press = 0.5
    local long_press_timer = gears.timer {
        timeout   = time_until_long_press,
        autostart = false,
        callback  = function(t)
            awful.spawn("xdotool key " .. attr.keycode)

            -- Decrease the time until the next event
            t.timeout = 0.05
            t:again()
        end
    }
	boxbg:connect_signal("button::press", function()
        if attr.toggleable then
            if attr.toggled_on then
                -- Release the key
                awful.spawn("xdotool keyup " .. attr.keycode)
                boxbg.bg = attr.bg
                boxbg.fg = attr.fg
            else
                -- Press the key
                awful.spawn("xdotool keydown " .. attr.keycode)
                boxbg.bg = press_bg_color
                boxbg.fg = press_fg_color

                -- Should it be toggled off after pressing another key?
                if attr.clear_after_one_use then
                    modifiers_to_clear[attr.keycode] = { attr = attr, bg_ctrl = boxbg }
                end
            end
            attr.toggled_on = not attr.toggled_on
        else
            awful.spawn("xdotool key " .. attr.keycode)
            boxbg.bg = press_bg_color
            boxbg.fg = press_fg_color
            -- Long press doesn't work on control keys
            long_press_timer:start()
        end
	end)
	boxbg:connect_signal("button::release", function()
        if attr.keycode == "Caps_Lock" then
            long_press_timer:stop()
            long_press_timer.timeout = time_until_long_press

            awful.spawn.easy_async_with_shell("xset -q | sed -n 's/^.*Caps Lock:[ \\t]*\\(\\S*\\).*$/\\1/p'", function(out)
                if out == "on\n" then
                    boxbg.bg = press_bg_color
                    boxbg.fg = press_fg_color
                elseif out == "off\n" then
                    boxbg.bg = attr.bg
                    boxbg.fg = attr.fg
                else
                    awful.spawn(string.format("notify-send -u critical 'Error' 'Unknown Caps Lock state: %s'", out))
                end
            end)
        else
            -- Toggle keys don't listen to release events
            if not attr.toggleable then
                long_press_timer:stop()
                long_press_timer.timeout = time_until_long_press

                boxbg.bg = attr.bg
                boxbg.fg = attr.fg

                for k,v in pairs(modifiers_to_clear) do
                    awful.spawn("xdotool keyup " .. v.attr.keycode)
                    v.attr.toggled_on = false
                    v.bg_ctrl.bg = v.attr.bg
                    v.bg_ctrl.fg = v.attr.fg

                    -- Delete the item from the list
                    modifiers_to_clear[k] = nil
                end
            end
        end
	end)
	return box
end

function module:new(config)
	local conf = config or {}
	conf.visible = false

	conf.screen = conf.screen or awful.screen.focused()
	conf.position = conf.position or "bottom"

	-- wibox
	local bar = awful.wibar({
			position = conf.position,
			screen = conf.screen,
			height = (5 * key_size),
			bg = keyboard_bg,
			visible = conf.visible
		})
	bar:setup{
		widget = wibox.container.margin,
		{
			widget = wibox.container.background,
			{
				layout = wibox.layout.fixed.vertical,
				spacing = 0,
				{
					layout = wibox.layout.align.horizontal,
					expand = "none",
					{ layout = wibox.layout.fixed.horizontal },
					{
						layout = wibox.layout.grid,
						orientation = "horizontal",
						horizontal_expand = false,
						homogeneous = false,
						spacing = 0,
						forced_height = key_size,
						module.button({
								name = "Esc",
								keycode = "Escape",
								fg = accent_fg_color,
								bg = accent_bg_color,
							}),
						module.button({ name = "1" }),
						module.button({ name = "2" }),
						module.button({ name = "3" }),
						module.button({ name = "4" }),
						module.button({ name = "5" }),
						module.button({ name = "6" }),
						module.button({ name = "7" }),
						module.button({ name = "8" }),
						module.button({ name = "9" }),
						module.button({ name = "0" }),
						module.button({ name = "-", keycode = "minus" }),
						module.button({ name = "=", keycode = "equal" }),
						module.button({
								name = "Backspace",
								size = 2.0,
								keycode = "BackSpace",
								fg = mod_fg_color, bg = mod_bg_color,
							}),
                        module.button({
                            name = "",
                            size = 0.25
                        }),
                        module.button({
                            name = "Ins",
                            keycode = "Insert",
                            fg = mod_fg_color, bg = mod_bg_color,
                        }),
                        module.button({
                            name = "Home",
                            fg = mod_fg_color, bg = mod_bg_color,
                        }),
                        module.button({
                            name = "PgUp",
                            keycode = "Page_Up",
                            fg = mod_fg_color, bg = mod_bg_color,
                        })
                        
                        
					},
					{ layout = wibox.layout.fixed.horizontal }
				},
				{
					layout = wibox.layout.align.horizontal,
					expand = "none",
					{ layout = wibox.layout.fixed.horizontal },
					{
						layout = wibox.layout.grid,
						orientation = "horizontal",
						horizontal_expand = false,
						homogeneous = false,
						spacing = 0,
						forced_height = key_size,
						module.button({
								name = "Tab",
								size = 1.5,
								keycode = "Tab",
								fg = mod_fg_color, bg = mod_bg_color,
							}),
						module.button({ name = "q" }),
						module.button({ name = "w" }),
						module.button({ name = "e" }),
						module.button({ name = "r" }),
						module.button({ name = "t" }),
						module.button({ name = "y" }),
						module.button({ name = "u" }),
						module.button({ name = "i" }),
						module.button({ name = "o" }),
						module.button({ name = "p" }),
						module.button({ name = "[", keycode = "bracketleft" }),
						module.button({ name = "]", keycode = "bracketright" }),
						module.button({
								name = "\\",
								size = 1.5,
								keycode = "backslash",
								fg = mod_fg_color, bg = mod_bg_color,
							}),
                        module.button({
                            name = "",
                            size = 0.25
                        }),
                        module.button({
                            name = "Del",
                            keycode = "Delete",
                            fg = mod_fg_color, bg = mod_bg_color,
                        }),
                        module.button({
                            name = "End",
                            fg = mod_fg_color, bg = mod_bg_color,
                        }),
                        module.button({
                            name = "PgDn",
                            keycode = "Page_Down",
                            fg = mod_fg_color, bg = mod_bg_color,
                        })
					},
					{ layout = wibox.layout.fixed.horizontal }
				},
				{
					layout = wibox.layout.align.horizontal,
					expand = "none",
					{ layout = wibox.layout.fixed.horizontal },
					{
						layout = wibox.layout.grid,
						orientation = "horizontal",
						horizontal_expand = false,
						homogeneous = false,
						spacing = 0,
						module.button({
								name = "Caps",
								size = 1.75,
								keycode = "Caps_Lock",
								fg = mod_fg_color, bg = mod_bg_color,
							}),
						module.button({ name = "a" }),
						module.button({ name = "s" }),
						module.button({ name = "d" }),
						module.button({ name = "f" }),
						module.button({ name = "g" }),
						module.button({ name = "h" }),
						module.button({ name = "j" }),
						module.button({ name = "k" }),
						module.button({ name = "l" }),
						module.button({ name = ";", keycode = "semicolon" }),
						module.button({ name = "'", keycode = "apostrophe" }),
						module.button({
								name = "Enter",
								size = 2.25,
								keycode = "Return",
								fg = accent_fg_color,
								bg = accent_bg_color,
							}),
                        module.button({
                            name = "",
                            size = 0.25
                        }),
                        module.button({ name = "" }),
                        module.button({ name = "" }),
                        module.button({ name = "" })
					},
					{ layout = wibox.layout.fixed.horizontal }
				},
				{
					layout = wibox.layout.align.horizontal,
					expand = "none",
					{ layout = wibox.layout.fixed.horizontal },
					{
						layout = wibox.layout.grid,
						orientation = "horizontal",
						horizontal_expand = false,
						homogeneous = false,
						spacing = 0,
						module.button({
								name = "Shift",
								size = 2.25,
								keycode = "Shift_L",
								toggleable = true,
                                clear_after_one_use = true,
								fg = mod_fg_color, bg = mod_bg_color,
							}),
						module.button({ name = "z" }),
						module.button({ name = "x" }),
						module.button({ name = "c" }),
						module.button({ name = "v" }),
						module.button({ name = "b" }),
						module.button({ name = "n" }),
						module.button({ name = "m" }),
						module.button({ name = ",", keycode = "comma" }),
						module.button({ name = ".", keycode = "period" }),
						module.button({ name = "/", keycode = "slash" }),
						module.button({
								name = "Shift",
								size = 2.75,
								keycode = "Shift_R",
								toggleable = true,
                                clear_after_one_use = true,
								fg = mod_fg_color, bg = mod_bg_color,
							}),
                        module.button({
                            name = "",
                            size = 0.25
                        }),
                        module.button({ name = "" }),
                        module.button({
                            name = "Up",
                            fg = mod_fg_color, bg = mod_bg_color,
                        }),
                        module.button({ name = "" })
					},
					{ layout = wibox.layout.fixed.horizontal }
				},
				{
					layout = wibox.layout.align.horizontal,
					expand = "none",
					{ layout = wibox.layout.fixed.horizontal },
					{
						layout = wibox.layout.grid,
						orientation = "horizontal",
						horizontal_expand = false,
						homogeneous = false,
						spacing = 0,
						module.button({
								name = "Ctrl",
								keycode = "Control_L",
								size = 1.25,
                                toggleable = true,
                                clear_after_one_use = true,
								fg = mod_fg_color, bg = mod_bg_color,
							}),
						module.button({
								name = "Win",
								keycode = "Super_L",
								size = 1.25,
                                toggleable = true,
                                clear_after_one_use = true,
								fg = mod_fg_color, bg = mod_bg_color,
							}),
						module.button({
								name = "Alt",
								keycode = "Alt_L",
								size = 1.25,
                                toggleable = true,
                                clear_after_one_use = true,
								fg = mod_fg_color, bg = mod_bg_color,
							}),
						module.button({
								name = " ",
								size = 6.25,
								keycode = "space"
							}),
						module.button({
								name = "AltGr",
								keycode = "ISO_Level3_Shift",
								size = 1.25,
                                toggleable = true,
                                clear_after_one_use = true,
								fg = mod_fg_color, bg = mod_bg_color,
							}),
						module.button({
								name = "Win",
								keycode = "Super_R",
								size = 1.25,
                                toggleable = true,
                                clear_after_one_use = true,
								fg = mod_fg_color, bg = mod_bg_color,
							}),
						module.button({
								name = "Menu",
								keycode = "Hyper_R",
								size = 1.25,
                                toggleable = true,
                                clear_after_one_use = true,
								fg = mod_fg_color, bg = mod_bg_color,
							}),
						module.button({
								name = "Ctrl",
								keycode = "Ctrl_R",
								size = 1.25,
                                toggleable = true,
                                clear_after_one_use = true,
								fg = mod_fg_color, bg = mod_bg_color,
							}),
                        module.button({
                            name = "",
                            size = 0.25
                        }),
                        module.button({
                            name = "Left",
                            fg = mod_fg_color, bg = mod_bg_color,
                        }),
                        module.button({
                            name = "Down",
                            fg = mod_fg_color, bg = mod_bg_color,
                        }),
                        module.button({
                            name = "Right",
                            fg = mod_fg_color, bg = mod_bg_color,
                        })
					},
					{ layout = wibox.layout.fixed.horizontal }
				}
			}
		}
	}
	conf.bar = bar
	local dropdown = setmetatable(conf, { __index = module })
	return dropdown
end

function module:toggle()
	self.bar.visible = not self.bar.visible
end

return setmetatable(module, { __call = function(_, ...)
	return module:new(...)
end })
