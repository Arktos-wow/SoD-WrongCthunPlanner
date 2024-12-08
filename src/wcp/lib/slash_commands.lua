WCP.LIB.SlashCommands = {}

local private = {}

-- Handles slash commands
function WCP.LIB.SlashCommands.handle(cmd)
    if cmd == "help" then
        private.help()
    elseif cmd == "show" or cmd == "" or cmd == nil then
        private.show()
    elseif cmd == "hide" then
        private.hide()
    elseif cmd == "reset" then
        private.reset()
    elseif cmd == "refresh" then
        private.refresh()
    elseif cmd == "share" then
        private.share()
    elseif cmd == "marks" then
        private.marks()
    elseif cmd == "check" then
        private.check()
    elseif cmd == "version" then
        private.version()
    else
        WCP.alert("Command not found. Use /wcp help for a list of commands.")
    end
end

-- /wcp help
function private.help()
    local function add_help_message(cmd, message)
        DEFAULT_CHAT_FRAME:AddMessage("   /wcp |cff00d2d6" .. cmd .. " |r-- " .. message, 1.0, 1.0, 0)
    end

    WCP.info("Commands:")
    add_help_message("help", "Show this help menu")
    add_help_message("show", "Show the planner")
    add_help_message("hide", "Hide the planner")
    add_help_message("reset", "Reset position and scale of the planner")
    add_help_message("refresh", "Refresh positions (e.g., someone died/went offline)")

    if IsInGroup() and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) then
        add_help_message("marks", "Set raid target markers for melees")
        add_help_message("check", "Check if all raiders have the addon installed")
    end

    if IsInGroup() and UnitIsGroupLeader("player") then
        add_help_message("share", "Display the planner to your raid")
    end

    add_help_message("version", "Show current version")
end

-- /wcp version
function private.version()
    WCP.info(WCP.Version.to_string())
end

-- /wcp show
function private.show()
    if WCP.frame then
        WCP.frame:Show()
    else
        WCP.alert("The planner frame is not initialized.")
    end
end

-- /wcp hide
function private.hide()
    if WCP.frame then
        WCP.frame:Hide()
    else
        WCP.alert("The planner frame is not initialized.")
    end
end

-- /wcp reset
function private.reset()
    if WCP.frame and WCP.frame.reset then
        WCP.frame:reset()
    else
        WCP.alert("The planner frame is not initialized or cannot be reset.")
    end
end

-- /wcp refresh
function private.refresh()
    if WCP.grid and WCP.grid.refresh then
        WCP.grid:refresh()
    else
        WCP.alert("The grid is not initialized or cannot be refreshed.")
    end
end

-- /wcp share
function private.share()
    if IsInGroup() then
        if UnitIsGroupLeader("player") then
            if WCP.frame then
                WCP.frame:Show()
            end

            WCP.submit_event({ type = "SHARE" })
            if WCP.UI and WCP.UI.Dot and WCP.UI.Dot.share_positions then
                WCP.UI.Dot.share_positions()
            else
                WCP.alert("Cannot share positions. Missing functionality.")
            end
        else
            WCP.alert("Only the group leader can share.")
        end
    else
        WCP.alert("You need to be in a raid to use this command.")
    end
end

-- /wcp marks
function private.marks()
    if WCP.grid and WCP.grid.set_marks then
        WCP.grid:set_marks()
    else
        WCP.alert("The grid is not initialized or cannot set marks.")
    end
end

-- /wcp check
function private.check()
    if IsInGroup() and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) then
        if WCP.LIB.CheckAddon and WCP.LIB.CheckAddon.run then
            WCP.LIB.CheckAddon.run()
        else
            WCP.alert("Addon check functionality is missing.")
        end
    else
        WCP.alert("This command is only available to group leaders or assistants.")
    end
end

