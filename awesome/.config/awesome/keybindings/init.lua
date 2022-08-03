local awful = require("awful")
local gears = require("gears")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
-- require("awful.hotkeys_popup.keys")

-- Global keys{{{1
globalkeys = gears.table.join(
    -- General {{{2
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    -- Navigation {{{2
    awful.key({ modkey,           }, "j",
        function () awful.client.focus.byidx( 1) end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function () awful.client.focus.byidx(-1) end,
        {description = "focus previous by index", group = "client"}
    ),

    -- Layout manipulation {{{2
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program {{{2
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", function ()
        local screen_geometry = awful.screen.focused().geometry

        mymainmenu:show { coords = {
            x = screen_geometry.x + screen_geometry.width / 2 - mymainmenu.theme.width / 2,
            y = screen_geometry.y + screen_geometry.height / 2 - mymainmenu.theme.height * #mymainmenu.items / 2
        }}
    end,
              {description = "show main menu", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Control" }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt {{{2
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Application launcher {{{2
    awful.key({ modkey }, "p", function() awful.spawn("dmenu_run") end,
              {description = "show application launcher", group = "launcher"}),
    awful.key({ }, "XF86Search", function() awful.spawn("dmenu_run") end,
              {description = "show application launcher", group = "launcher"}),
    awful.key({ modkey }, "o", nil, function()
            keygrabber.run(function(mods, key, action)
                if key == "Super_L" and action == "release" then
                    -- Continue to wait after the Super key was released
                    return
                end

                local app_shortcuts = {
                    b = "firefox",
                    m = "thunderbird",
                    v = "vscodium",
                    p = terminal .. " -e ncmpcpp",
                    g = "gimp",
                    y = "gtk-youtube-viewer",
                }

                if action == "press" then
                    awful.spawn(app_shortcuts[key])
                end

                keygrabber.stop()
            end)
        end,
              {description = "start hotkey application launcher", group = "launcher"}),

    -- Volume {{{2
    awful.key({ }, "XF86AudioMute", function() awful.spawn("volume-notification toggle_mute") end,
              {description = "(un)mute volume", group = "volume"}),
    awful.key({ }, "XF86AudioRaiseVolume", function() awful.spawn("volume-notification inc") end,
              {description = "raise volume", group = "volume"}),
    awful.key({ }, "XF86AudioLowerVolume", function() awful.spawn("volume-notification dec") end,
              {description = "lower volume", group = "volume"}),

    -- Music {{{2
    awful.key({ }, "XF86AudioPrev", function() awful.spawn("mpc prev") end,
              {description = "previous song", group = "music"}),
    awful.key({ }, "XF86AudioNext", function() awful.spawn("mpc next") end,
              {description = "next song", group = "music"}),
    awful.key({ }, "XF86AudioPlay", function() awful.spawn("mpc toggle") end,
              {description = "(un)pause music", group = "music"}),

    -- Brightness {{{2
    awful.key({ }, "XF86MonBrightnessUp", function() awful.spawn("brightness-notification inc") end,
              {description = "raise screen brightness", group = "brightness"}),
    awful.key({ }, "XF86MonBrightnessDown", function() awful.spawn("brightness-notification dec") end,
              {description = "lower screen brightness", group = "brightness"}),

    -- Screenshot {{{2
    awful.key({ modkey }, "Print", function() awful.spawn("screenshot") end,
              {description = "create a screenshot", group = "screenshot"})
)
-- }}}1

-- Client keys {{{1
clientkeys = gears.table.join(
    awful.key({ modkey            }, ",",       function (c)
        local screen = awful.screen.focused()
        local tag = screen.tags[11]
        if tag then
            awful.tag.viewtoggle(tag)

            -- Focus scratchpad
            if tag.selected then
                for _, c in ipairs(client.get()) do
                    if c.instance == "dropdown-general" then
                        client.focus = c
                    end
                end
            end
        end
    end,
              {description = "toggle general scratchpad",   group = "client"}),
    awful.key({ modkey            }, ".",       function (c)
        local screen = awful.screen.focused()
        local tag = screen.tags[12]
        if tag then
            awful.tag.viewtoggle(tag)

            -- Focus scratchpad
            if tag.selected then
                for _, c in ipairs(client.get()) do
                    if c.instance == "dropdown-math" then
                        client.focus = c
                    end
                end
            end
        end
    end,
              {description = "toggle math scratchpad",   group = "client"}),
    awful.key({ modkey            }, "q",       function (c) c:kill() end,
              {description = "close",               group = "client"}),
    awful.key({ modkey,           }, "space",  awful.client.floating.toggle,
              {description = "toggle floating",     group = "client"}),
    awful.key({ modkey, "Shift"   }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master",      group = "client"}),
    -- awful.key({ modkey,           }, "o",      function (c) c:move_to_screen() end,
    --           {description = "move to screen",      group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop end,
              {description = "toggle keep on top",  group = "client"}),
    awful.key({ modkey, "Shift"   }, "f",
       function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
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
