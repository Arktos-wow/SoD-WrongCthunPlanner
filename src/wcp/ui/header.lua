WCP.UI.Header = {}

function WCP.UI.Header.attach_to(parent)
    -- Create the header frame with BackdropTemplateMixin
    local header = CreateFrame("Frame", nil, parent, BackdropTemplateMixin and "BackdropTemplate")
    header:SetPoint("TOP", parent, "TOP", 0, 12)
    header:SetSize(256, 64) -- Combines SetWidth and SetHeight

    -- Ensure BackdropTemplateMixin is available before setting the backdrop
    if header.SetBackdrop then
        header:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Header"
        })
    else
        print("Error: SetBackdrop is not available for the header frame.")
    end

    -- Allow dragging the parent frame using the header
    header:SetScript("OnMouseDown", function()
        if parent:IsMovable() then
            parent:StartMoving()
            parent:SetUserPlaced(true)
        end
    end)

    header:SetScript("OnMouseUp", function()
        if parent:IsMovable() then
            parent:StopMovingOrSizing()
        end
    end)

    -- Create the title text
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("CENTER", header, "CENTER", 0, 0)
    title:SetText("WrongCthun Planner")

    return header
end
