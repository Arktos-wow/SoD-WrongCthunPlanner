-- Register Slash Commands
SLASH_WrongCthunPlanner1 = "/wcp"
SlashCmdList["WrongCthunPlanner"] = function(msg)
    if WCP and WCP.LIB and WCP.LIB.SlashCommands and WCP.LIB.SlashCommands.handle then
        WCP.LIB.SlashCommands.handle(msg)
    else
        print("Error: Slash command handler is not properly initialized.")
    end
end

-- Addon Initialization
function WCP:OnInitialize()
    -- Register communication prefix
    if self.RegisterComm then
        self:RegisterComm(WCP.messagePrefix, WCP.OnCommReceived)
    else
        print("Error: Communication system not available.")
    end

    -- Initialize UI and components
    if WCP.UI and WCP.UI.Dot and WCP.UI.Dot.init then
        WCP.UI.Dot.init()
    else
        print("Error: Dot UI system is not properly initialized.")
    end

    -- Create necessary objects
    WCP.player = WCP.LIB and WCP.LIB.Member and WCP.LIB.Member.create(0) or nil
    if not WCP.player then
        print("Error: Failed to initialize player member.")
    end

    WCP.grid = WCP.LIB and WCP.LIB.Grid and WCP.LIB.Grid.create() or nil
    if not WCP.grid then
        print("Error: Failed to initialize grid.")
    end

    WCP.frame = WCP.UI and WCP.UI.CthunFrame and WCP.UI.CthunFrame.create() or nil
    if not WCP.frame then
        print("Error: Failed to create main frame.")
    end
end

-- Handle Incoming Communication
function WCP.OnCommReceived(prefix, message, distribution, sender)
    if prefix ~= WCP.messagePrefix then
        print("Received unknown prefix:", prefix)
        return false
    end

    -- Deserialize the message
    local is_event, event = WCP:Deserialize(message)
    if is_event and event and event.type then
        local handler = WCP.LIB.Events["ON_" .. event.type]
        if handler then
            handler(event.payload, prefix, message, distribution, sender)
        else
            print("Warning: No handler found for event type:", event.type)
        end
    else
        print("Error: Failed to process message:", message)
    end
end
