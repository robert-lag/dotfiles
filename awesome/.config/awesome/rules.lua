-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule {{{1
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     size_hints_honor = false,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients {{{1
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }
    },

    -- Fullscreen clients {{{1
    { rule_any = {
        class = {
            "Sxiv",
            "mpv"
        }
      }, properties = { fullscreen = true }
    },

    -- Firefox {{{1
    { rule = { class = "firefox" },
      properties = { tag = "1" }
    },

    -- Thunderbird {{{1
    { rule = { class = "thunderbird" },
      properties = { tag = "10" }
    },

    -- ncmpcpp {{{1
    { rule = { instance = "ncmpcpp" },
      properties = { screen = 1, tag = " " }
    },

    -- Scratchpads {{{1
    { rule = { instance = "dropdown-general" },
      properties = {
          screen = 1,
          tag = "-",
          floating = true,
          ontop = true,
          urgent = false,
          skip_taskbar = true,
          width = 1000,
          height = 600,
          placement = awful.placement.centered,
      }
    },
    { rule = { instance = "dropdown-math" },
      properties = {
          screen = 1,
          tag = "+",
          floating = true,
          ontop = true,
          urgent = false,
          skip_taskbar = true,
          width = 1000,
          height = 600,
          placement = awful.placement.centered,
      }
    },
}
