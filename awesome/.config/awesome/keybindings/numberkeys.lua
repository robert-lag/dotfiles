-- The key represent the keycodes
-- The value represents the corresponding tag
local keycodes = {
    [10] = 1,
    [11] = 2,
    [12] = 3,
    [13] = 4,
    [14] = 5,
    [15] = 6,
    [16] = 7,
    [17] = 8,
    [18] = 9,
    [19] = 10,
    [87] = 1,
    [88] = 2,
    [89] = 3,
    [83] = 4,
    [84] = 5,
    [85] = 6,
    [79] = 7,
    [80] = 8,
    [81] = 9,
    [90] = 10
}

for keycode, keyvalue in pairs(keycodes) do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. keycode,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[keyvalue]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..keyvalue, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. keycode,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[keyvalue]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. keyvalue, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. keycode,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[keyvalue]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..keyvalue, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. keycode,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[keyvalue]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. keyvalue, group = "tag"})
    )
end
