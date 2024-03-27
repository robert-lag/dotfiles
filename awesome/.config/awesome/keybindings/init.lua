local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
-- require("awful.hotkeys_popup.keys")

-- Global keys {{{1
globalkeys = gears.table.join(
    -- General {{{2
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Tab", awful.tag.history.restore,
              {description = "go back", group = "tag"}),
    awful.key({ modkey,           }, "x", function() awful.spawn("xautolock -locknow") end,
              {description = "lock screen", group = "screen"}),
    awful.key({ modkey }, "-",
              function ()
                    local screen = awful.screen.focused()
                    local tag = screen.tags[14]

                    if screen.selected_tag == tag then
                        awful.tag.history.restore(screen, 1)
                    else
                        if tag then
                           tag:view_only()
                        end
                    end
              end,
              {description = "view tag  (#14)", group = "tag"}),

    -- Focus screen {{{2
    awful.key({ modkey }, "Escape", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Shift" }, "Escape", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),

    -- Layout manipulation {{{2
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc( 1) end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Control" }, "space", function () awful.layout.inc(-1) end,
              {description = "select previous", group = "layout"}),
    awful.key({ modkey }, "a", function ()
        local c = awful.client.restore()
        -- Focus restored client
        if c then
            c:emit_signal(
                "request::activate", "key.unminimize", {raise = true}
            )
        end
    end, {description = "restore minimized", group = "client"}),
    awful.key({ modkey,           }, "ö", nil, function ()
        show_message("(d)efault | (e)qual | (s)quare | (v)ertical")
        keygrabber.run(function(mods, key, action)
            if key == "Super_L" and action == "release" then
                -- Continue to wait after the Super key was released
                return
            end



            local master_width_factor = {
                e = 0.5,
                d = 0.6,
                s = 0.5,
                v = 0.5,
            }

            local master_count = {
                e = 1,
                d = 1,
                s = 2,
                v = 2,
            }

            local master_height_factor = {
                e = 0.5,
                d = 0.5,
                s = 0.5,
                v = 0.9,
            }

            if action == "press" then
                hide_message()

                local selected_tag = awful.tag.selected()
                if selected_tag == nil then
                    awful.spawn("notify-send -t 1500 'No tag selected'")
                else
                    if key ~= "Escape" then
                        if master_width_factor[key] == nil then
                            awful.spawn("notify-send -t 1500 'Key not assigned'")
                        else
                            local number_of_clients = 0
                            for _ in pairs(selected_tag:clients()) do
                                number_of_clients = number_of_clients + 1
                            end

                            if number_of_clients < 2 then
                                awful.spawn("notify-send -t 1500 'Open at least 2 clients on this tag'")
                            else
                                selected_tag.master_width_factor = master_width_factor[key]
                                selected_tag.master_count = master_count[key]
                                selected_tag.column_count = 1

                                -- Change the height factor of the master client
                                awful.client.setwfact(master_height_factor[key], awful.client.getmaster())
                            end
                        end
                    end
                end
            end

            keygrabber.stop()
        end)
    end, {description = "show layout menu", group = "layout"}),

    -- Open standard applications {{{2
    awful.key({ modkey            }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", function ()
        local screen_geometry = awful.screen.focused().geometry
        mainmenu:show { coords = {
            x = screen_geometry.x + screen_geometry.width / 2 - mainmenu.theme.width / 2,
            y = screen_geometry.y + screen_geometry.height / 2 - mainmenu.theme.height * #mainmenu.items / 2
        }}
    end,      {description = "show main menu", group = "awesome"}),


    -- Application launcher {{{2
    awful.key({ modkey }, "p", function() awful.spawn("dmenu_run") end,
              {description = "show application launcher", group = "launcher"}),
    awful.key({ }, "XF86Search", function() awful.spawn("dmenu_run") end,
              {description = "show application launcher", group = "launcher"}),
    awful.key({ modkey }, "o", nil, function()
        show_message("(b)rowser | (m)ail | (v)scodium | music (p)layer | (n)otes | ne(w)s | (g)imp | (y)outube | m(e)ssenger | (t)erminal | (s)ystem")
        keygrabber.run(function(mods, key, action)
            if key == "Super_L" and action == "release" then
                -- Continue to wait after the Super key was released
                return
            end

            local app_shortcuts = {
                b = os.getenv("BROWSER") or "firefox",
                m = "thunderbird",
                n = "notion-app-nativefier",
                v = "vscodium",
                p = terminal .. " -e ncmpcpp",
                g = "gimp",
                y = "gtk-youtube-viewer",
                e = "signal-desktop",
                w = terminal .. " -e newsboat",
                t = terminal,
                s = "system-monitoring-center",
                Return = terminal,
            }

            if action == "press" then
                hide_message()
                if key ~= "Escape" then
                    if app_shortcuts[key] == nil then
                        awful.spawn("notify-send -t 1500 'Key not assigned'")
                    else
                        awful.spawn(app_shortcuts[key])
                    end
                end
            end

            keygrabber.stop()
        end)
    end, {description = "start hotkey application launcher", group = "launcher"}),

    -- Volume {{{2
    awful.key({ }, "XF86AudioMute", function()
        awful.spawn("volume-notification toggle_mute")
        set_volume_sliders()
        update_volume_widget()
    end, {description = "(un)mute volume", group = "volume"}),
    awful.key({ }, "XF86AudioRaiseVolume", function()
        awful.spawn("volume-notification inc")
        set_volume_sliders()
        update_volume_widget()
    end, {description = "raise volume", group = "volume"}),
    awful.key({ }, "XF86AudioLowerVolume", function()
        awful.spawn("volume-notification dec")
        set_volume_sliders()
        update_volume_widget()
    end, {description = "lower volume", group = "volume"}),

    -- Music {{{2
    awful.key({ }, "XF86AudioPrev", function() awful.spawn("mpc prev") end,
              {description = "previous song", group = "music"}),
    awful.key({ }, "XF86AudioNext", function() awful.spawn("mpc next") end,
              {description = "next song", group = "music"}),
    awful.key({ }, "XF86AudioPlay", function() awful.spawn("mpc toggle") end,
              {description = "(un)pause music", group = "music"}),
    awful.key({ modkey }, "m", function() awful.spawn("mpc toggle") end,
              {description = "(un)pause music", group = "music"}),
    awful.key({ modkey }, "F9", function() awful.spawn("mpc prev") end,
              {description = "previous song", group = "music"}),
    awful.key({ modkey, "Shift" }, "F9", function() awful.spawn("mpc seek 0%") end,
              {description = "replay current song", group = "music"}),
    awful.key({ modkey }, "F10", function() awful.spawn("mpc seek -10") end,
              {description = "rewind song by 10 seconds", group = "music"}),
    awful.key({ modkey, "Shift" }, "F10", function() awful.spawn("mpc seek -60") end,
              {description = "rewind song by 60 seconds", group = "music"}),
    awful.key({ modkey }, "F11", function() awful.spawn("mpc seek +10") end,
              {description = "fast-forward song by 10 seconds", group = "music"}),
    awful.key({ modkey, "Shift" }, "F11", function() awful.spawn("mpc seek +60") end,
              {description = "fast-forward song by 60 seconds", group = "music"}),
    awful.key({ modkey }, "F12", function() awful.spawn("mpc next") end,
              {description = "next song", group = "music"}),
    awful.key({ modkey, "Shift" }, "F12", function() awful.spawn("mpc repeat") end,
              {description = "toggle repeat mode", group = "music"}),

    -- Brightness {{{2
    awful.key({ }, "XF86MonBrightnessUp", function() awful.spawn("brightness-notification inc") end,
              {description = "raise screen brightness", group = "brightness"}),
    awful.key({ }, "XF86MonBrightnessDown", function() awful.spawn("brightness-notification dec") end,
              {description = "lower screen brightness", group = "brightness"}),

    -- Screenshot {{{2
    awful.key({ modkey }, "Print", function() awful.spawn("screenshot") end,
              {description = "create a screenshot", group = "screenshot"}),
    awful.key({ modkey, "Shift" }, "Print", function() awful.spawn("screenshot all") end,
              {description = "create a screenshot of the whole screen", group = "screenshot"}),

    -- Color Picker {{{2
    awful.key({ modkey }, "c", function() awful.spawn("color-picker") end,
              {description = "copy a color to the clipboard", group = "other"}),

    -- Scratchpads {{{2
    awful.key({ modkey }, ",", function ()
        local focused_screen = awful.screen.focused()
        local tag = focused_screen.tags[11]
        if tag then
            awful.tag.viewtoggle(tag)

            if tag.selected then
                for _, c in ipairs(client.get()) do
                    if c.instance == "dropdown-general" then
                        -- Move scratchpad to current screen
                        c:move_to_tag(tag)

                        -- Hide the tags on all the other screens
                        for current_screen in screen do
                            if current_screen.index ~= focused_screen.index then
                                current_tag = current_screen.tags[11]

                                if current_tag.selected then
                                    awful.tag.viewtoggle(current_tag)
                                end
                            end
                        end

                        -- Center the client
                        local screen_geometry = awful.screen.focused().geometry
                        c.x = screen_geometry.x + screen_geometry.width / 2 - c.width / 2
                        c.y = screen_geometry.y + screen_geometry.height / 2 - c.height / 2

                        -- Focus scratchpad
                        client.focus = c

                        c:raise()
                    end
                end
            end
        end
    end, {description = "toggle general scratchpad",   group = "scratchpad"}),
    awful.key({ modkey }, ".", function ()
        local focused_screen = awful.screen.focused()
        local tag = focused_screen.tags[12]
        if tag then
            awful.tag.viewtoggle(tag)

            if tag.selected then
                for _, c in ipairs(client.get()) do
                    if c.instance == "dropdown-math" then
                        -- Move scratchpad to current screen
                        c:move_to_tag(tag)

                        -- Hide the tags on all the other screens
                        for current_screen in screen do
                            if current_screen.index ~= focused_screen.index then
                                current_tag = current_screen.tags[12]

                                if current_tag.selected then
                                    awful.tag.viewtoggle(current_tag)
                                end
                            end
                        end

                        -- Center the client
                        local screen_geometry = awful.screen.focused().geometry
                        c.x = screen_geometry.x + screen_geometry.width / 2 - c.width / 2
                        c.y = screen_geometry.y + screen_geometry.height / 2 - c.height / 2

                        -- Focus scratchpad
                        client.focus = c

                        c:raise()
                    end
                end
            end
        end
    end, {description = "toggle math scratchpad",   group = "scratchpad"})
    -- awful.key({ modkey }, "-", function ()
    --     local focused_screen = awful.screen.focused()
    --     local tag = focused_screen.tags[13]
    --     if tag then
    --         awful.tag.viewtoggle(tag)
    -- 
    --         if tag.selected then
    --             for _, c in ipairs(client.get()) do
    --                 if c.instance == "dropdown-music" then
    --                     -- Move scratchpad to current screen
    --                     c:move_to_tag(tag)
    -- 
    --                     -- Hide the tags on all the other screens
    --                     for current_screen in screen do
    --                         if current_screen.index ~= focused_screen.index then
    --                             current_tag = current_screen.tags[13]
    -- 
    --                             if current_tag.selected then
    --                                 awful.tag.viewtoggle(current_tag)
    --                             end
    --                         end
    --                     end
    -- 
    --                     -- Center the client
    --                     local screen_geometry = awful.screen.focused().geometry
    --                     c.x = screen_geometry.x + screen_geometry.width / 2 - c.width / 2
    --                     c.y = screen_geometry.y + screen_geometry.height / 2 - c.height / 2
    -- 
    --                     -- Focus scratchpad
    --                     client.focus = c
    -- 
    --                     c:raise()
    --                 end
    --             end
    --         end
    --     end
    -- end, {description = "toggle music scratchpad",   group = "scratchpad"})
)
-- }}}1

-- Client keys {{{1
-- These events only fire when a client is focused
clientkeys = gears.table.join(
    -- General bindings {{{2
    awful.key({ modkey            }, "q",       function (c) c:kill() end,
              {description = "close",               group = "client"}),

    -- Window states {{{2
    awful.key({ modkey,           }, "space",  awful.client.floating.toggle,
              {description = "toggle floating",     group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop end,
              {description = "toggle keep on top",  group = "client"}),
    awful.key({ modkey            }, "f",
       function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),

    -- Minimize / Maximize {{{2
    -- awful.key({ modkey,           }, "n", function (c)
    --     -- The client currently has the input focus, so it cannot be
    --     -- minimized, since minimized clients can't have the focus.
    --     c.minimized = true
    -- end , {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "b", function (c)
        c.maximized = not c.maximized
        c:raise()
    end, {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "b", function (c)
        c.maximized_vertical = not c.maximized_vertical
        c:raise()
    end, {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "b", function (c)
        c.maximized_horizontal = not c.maximized_horizontal
        c:raise()
    end, {description = "(un)maximize horizontally", group = "client"}),

    -- Focus manipulation {{{2
    awful.key({ modkey }, "h", function (c)
        awful.client.focus.global_bydirection("left")
        c:lower()
    end, {description = "focus left client", group = "client"}),
    awful.key({ modkey }, "l", function (c)
        awful.client.focus.global_bydirection("right")
        c:lower()
    end, {description = "focus right client", group = "client"}),
    awful.key({ modkey }, "k", function (c)
        awful.client.focus.global_bydirection("up")
        c:lower()
    end, {description = "focus upper client", group = "client"}),
    awful.key({ modkey }, "j", function (c)
        awful.client.focus.global_bydirection("down")
        c:lower()
    end, {description = "focus lower client", group = "client"}),
    awful.key({ modkey }, "u", awful.client.urgent.jumpto,
         {description = "jump to urgent client", group = "client"}),

    -- Movement {{{2
    awful.key({ modkey, "Shift"   }, "h", function (c)
        if c.floating then
            c:relative_move(-20,   0,   0,   0)
        else
            awful.client.swap.global_bydirection("left")
        end
        c:raise()
    end, {description = "move left", group = "client"}),
    awful.key({ modkey, "Shift"   }, "l", function (c)
        if c.floating then
            c:relative_move( 20,   0,   0,   0)
        else
            awful.client.swap.global_bydirection("right")
        end
        c:raise()
    end, {description = "move right", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function (c)
        if c.floating then
            c:relative_move(  0, -20,   0,   0)
        else
            awful.client.swap.global_bydirection("up")
        end
        c:raise()
    end, {description = "move up", group = "client"}),
    awful.key({ modkey, "Shift"   }, "j", function (c)
        if c.floating then
            c:relative_move(  0,  20,   0,   0)
        else
            awful.client.swap.global_bydirection("down")
        end
        c:raise()
    end, {description = "move down", group = "client"}),
    awful.key({ modkey, "Shift"   }, "Return", function (c)
        c:swap(awful.client.getmaster())
    end, {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "<", function (c)
        c:move_to_screen()
    end, {description = "move to screen", group = "client"}),

    -- Resize {{{2
    awful.key({ modkey, "Control" }, "h", function (c)
        if c.floating then
            c:relative_move( 0, 0, -20, 0)
            c:raise()
        else
            awful.tag.incmwfact(-0.05)
        end
    end, {description = "Decrease width", group = "client"}),
    awful.key({ modkey, "Control" }, "l", function (c)
        if c.floating then
            c:relative_move( 0, 0, 20, 0)
            c:raise()
        else
            awful.tag.incmwfact(0.05)
        end
    end, {description = "Increase width", group = "client"}),
    awful.key({ modkey, "Control" }, "k", function (c)
        if c.floating then
            c:relative_move( 0, 0, 0, -20)
            c:raise()
        else
            awful.client.incwfact(-0.05)
        end
    end, {description = "Decrease height", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function (c)
        if c.floating then
            c:relative_move( 0, 0, 0, 20)
            c:raise()
        else
            awful.client.incwfact(0.05)
        end
    end, {description = "Increase height", group = "client"})
)
-- }}}1

-- Bind all key numbers to tags {{{1
require(... .. ".numberkeys")
-- }}}1

-- Client buttons {{{1
clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)
-- }}}1

root.keys(globalkeys)
