if not WCP then
    WCP = LibStub("AceAddon-3.0"):NewAddon("WCP", "AceComm-3.0", "AceSerializer-3.0")
    WCP.LIB = {}

    WCP.messagePrefix = "WCP"
    WCP.frame = {}
    WCP.player_name = UnitName("player")

    function WCP.info(message)
        DEFAULT_CHAT_FRAME:AddMessage("|cff00d2d6WCP:|r " .. tostring(message), 1.0, 1.0, 0)
    end

    function WCP.alert(message)
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000WCP:|r " .. tostring(message), 1.0, 1.0, 0)
    end

    function WCP.submit_event(event, target)
        local serialized_event = WCP:Serialize(event)
        if target then
            WCP.addon_whisper_message(serialized_event, target)
        else
            WCP.addon_raid_message(serialized_event)
        end
    end

    function WCP.addon_raid_message(message)
        WCP:SendCommMessage(WCP.messagePrefix, message, "RAID")
    end

    function WCP.addon_whisper_message(message, target)
        WCP:SendCommMessage(WCP.messagePrefix, message, "WHISPER", target)
    end

    function WCP.debug(object)
        print(WCP.dump(object))
    end

    function WCP.dump(object)
        if type(object) == "table" then
            local result = "{"
            for k, v in pairs(object) do
                local key = (type(k) == "number") and k or '"' .. k .. '"'
                result = result .. "[" .. key .. "] = " .. WCP.dump(v) .. ", "
            end
            return result .. "}"
        else
            return tostring(object)
        end
    end

    function WCP.split(...)
        return strsplit(...)
    end

    function WCP.copy_table(orig)
        if type(orig) ~= "table" then
            return orig
        end

        local copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[WCP.copy_table(orig_key)] = WCP.copy_table(orig_value)
        end
        return setmetatable(copy, WCP.copy_table(getmetatable(orig)))
    end
else
    print("WCP addon is already initialized.")
end
