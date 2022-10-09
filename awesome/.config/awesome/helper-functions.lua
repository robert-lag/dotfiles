function darker(color_value, darker_n)
    local result = "#"
    for s in color_value:gmatch("[a-fA-F0-9][a-fA-F0-9]") do
        local bg_numeric_value = tonumber("0x"..s) - darker_n
        if bg_numeric_value < 0 then bg_numeric_value = 0 end
        if bg_numeric_value > 255 then bg_numeric_value = 255 end
        result = result .. string.format("%2.2x", bg_numeric_value)
    end
    return result
end

function hexdecode(hex)
   return (hex:gsub("%x%x", function(digits) return string.char(tonumber(digits, 16)) end))
end

function hexencode(str)
   return (str:gsub(".", function(char) return string.format("%2x", char:byte()) end))
end
