-- Experimental
WCP.UI.Dot = {}
WCP.UI.Dot.__index = WCP.UI.Dot

WCP.UI.Dot.all = {}

local default_positions = {
  [1] = {1, 98},       --melee         --
  [2] = {-32, 131},    --healer        -|
  [3] = {-20, 170},    --ranged        -|Group 1
  [4] = {22, 171},     --ranged        -|
  [5] = {34, 132},     --healer/ranged --
  [6] = {67, 71},      -- melee        --
  [7] = {69, 118},     --healer        -|
  [8] = {105, 137},    --ranged        -|Group 2
  [9] = {134, 107},    --ranged        -|
  [10] = {115, 70},    --healer/ranged --
  [11] = {-66, 69},    -- melee        --
  [12] = {-113, 69},   --healer        -|
  [13] = {-132, 106},  --ranged        -|Group 3
  [14] = {-66, 116},   --ranged        -|
  [15] = {-103, 135},  --healer/ranged --
  [16] = {97, 4},      -- melee        --
  [17] = {130, 37},    --healer        -|
  [18] = {169, 24},    --ranged        -|Group 4
  [19] = {170, -17},   --ranged        -|
  [20] = {130, -30},   --healer/ranged --
  [21] = {-93, 2},     -- melee        --
  [22] = {-126, -31},  --healer        -|
  [23] = {-166, -19},  --ranged        -|Group 5
  [24] = {-166, 22},   --ranged        -|
  [25] = {-127, 35},   --healer/ranged --
  [26] = {69, -64},    -- melee        --
  [27] = {117, -64},   --healer        -|
  [28] = {135, -100},  --ranged        -|Group 6
  [29] = {107, -129},  --ranged        -|
  [30] = {70, -110},   --healer/ranged --
  [31] = {-65, -65},   -- melee        --
  [32] = {-65, -112},  --healer        -|
  [33] = {-101, -131}, --ranged        -|Group 7
  [34] = {-130, -102}, --ranged        -|
  [35] = {-112, -66},  --healer/ranged --
  [36] = {3, -92},     -- melee        --
  [37] = {36, -126},   --healer        -|
  [38] = {24, -165},   --ranged        -|Group 8
  [39] = {-18, -165},  --ranged        -|
  [40] = {-30, -126}   --healer/ranged --
}

local current_layout = "default"

function WCP.UI.Dot.init()
  WCP_POSITIONS = WCP_POSITIONS or { default = WCP.copy_table(default_positions) }
end

function WCP.UI.Dot.reset_positions()
  WCP_POSITIONS = { default = WCP.copy_table(default_positions) }
  WCP.UI.Dot.share_positions()
end

function WCP.UI.Dot.share_positions()
  WCP.submit_event({ type = "SHARE_POSITIONS", payload = WCP_POSITIONS[current_layout] })
end

function WCP.UI.Dot.set_positions(new_positions)
  WCP_POSITIONS[current_layout] = new_positions

  for _, dot in pairs(WCP.UI.Dot.all) do
    dot:reload_position()
  end
end

function WCP.UI.Dot.create_or_update(number, member)
  local dot = WCP.UI.Dot.all[number]

  if dot == nil then
    dot = WCP.UI.Dot.create(number, member)
    WCP.UI.Dot.all[number] = dot
  else
    dot:update(number, member)
  end

   for _, dot in pairs(dots) do
        if dot.frame then
            dot:refresh()
        else
            print("Skipping uninitialized dot.")
        end
    end
end


function WCP.UI.Dot.reset_all()
  for i = 1, 40 do
    WCP.UI.Dot.create_or_update(i, nil, nil)
  end
end

-- Initializer
function WCP.UI.Dot.create(number, member)
  local self = {}

  setmetatable(self, WCP.UI.Dot)

  self:update(number, member)
  self:create_frame(WCP.frame.frame)

  return self
end

function WCP.UI.Dot:update(number, member)
  self.number = number
  self.member = member
  self.name = member and member.name
  self.class = member and member.class

  if self.name == nil then self.name = "Empty" end
end

function WCP.UI.Dot.can_interact()
  return (WCP.player:is_leader() or WCP.player:is_assist())
end

function WCP.UI.Dot:create_frame(parent)
  self.button = CreateFrame("Button", nil, parent)

  self.button:EnableMouse(true)
  self.button:SetFrameLevel(self.button:GetFrameLevel() + 3)

  self.button.texture = self.button:CreateTexture(nil, "OVERLAY")
  self.button.texture:SetAllPoints(self.button)

  self:reload_position()
  self:make_interactive()
  self:refresh()
end

function WCP.UI.Dot:reload_position()
  local positions = WCP_POSITIONS[current_layout]

  self:set_position(positions[self.number][1], positions[self.number][2])
end

function WCP.UI.Dot:make_interactive()
  self.button:SetMovable(true)
  self.button:SetScript("OnMouseDown", function(button, mouse_button)
    self:handle_mouse_down(button, mouse_button)
  end)
  self.button:SetScript("OnMouseUp", function(button, mouse_button)
    self:handle_mouse_up(button, mouse_button)
  end)
end

function WCP.UI.Dot:handle_mouse_down(button, mouse_button)
  if(not WCP.UI.Dot.can_interact()) then return false end

  if(button.isMoving) then return false end

  if mouse_button == "RightButton" then
    if(WCP.UI.DotSwap:is_in_progress())  then
      WCP.UI.DotSwap:finish(self)
    else
      if IsAltKeyDown() then
        WCP.UI.Dot.reset_positions()
      else
        WCP.UI.Cursor.set("UI-Cursor-Move")
        WCP.UI.Dot.DragHelper:start(button)
      end
    end
  elseif mouse_button == "LeftButton" then
    if WCP.UI.DotSwap:is_in_progress() then
      WCP.UI.DotSwap:finish(self)
    else
      WCP.UI.DotSwap:start(self)
    end
  end
end

function WCP.UI.Dot:handle_mouse_up(button, mouse_button)
  if mouse_button == "RightButton" and button.isMoving then
    WCP.UI.Dot.DragHelper:stop(self, button)
  end
end

function WCP.UI.Dot:set_position(x, y)
  self.button:ClearAllPoints()
  self.button:SetPoint("CENTER", WCP.frame.frame, "CENTER", x, y)

  WCP_POSITIONS[current_layout][self.number][1] = x
  WCP_POSITIONS[current_layout][self.number][2] = y
end

function WCP.UI.Dot:refresh()
    if self.isRefreshing then
        print("Refresh is already in progress. Skipping...")
        return
    end

    self.isRefreshing = true

    -- Check if the frame exists before creating it
    if not self.frame then
        print("Frame does not exist. Creating...")
        self:create_frame()
    else
        print("Frame exists. Refreshing...")
        -- Frame-specific refresh logic here
    end

  self.isRefreshing = false
  
  self:update_texture()
  self:update_tooltip()

  self.button:SetScale(WCP.frame.frame:GetEffectiveScale())
  WCP.frame:resize()
end

function WCP.UI.Dot:update_texture()
  if (self.member == nil) then
    self.button.texture:SetTexture("Interface/Buttons/UI-EmptySlot")
  elseif (not self.member.online) then
    self.button.texture:SetTexture("Interface/ICONS/Ability_Stealth")
  elseif (self.member.isDead) then
    self.button.texture:SetTexture("Interface/ICONS/INV_Misc_QuestionMark")
  else
    local capitalized_class = self.class:gsub("^%l", string.upper)
    self.button.texture:SetTexture("Interface/ICONS/ClassIcon_" .. capitalized_class)
  end

  if (WCP.player_name == self.name) then
    self.button:SetWidth(32)
    self.button:SetHeight(32)
  else
    self.button:SetWidth(16)
    self.button:SetHeight(16)
  end
end

function WCP.UI.Dot:update_tooltip()
  self.button:SetScript("OnEnter", function()
    GameTooltip:SetOwner(self.button, "ANCHOR_RIGHT")
    local tooltip = self.name

    if(WCP.UI.Dot.can_interact()) then
      if(not WCP.UI.Cursor.current) then
        WCP.UI.Cursor.set("Interact")
      end

      if WCP.UI.DotSwap:is_in_progress() then
        tooltip = "LMB: Swap " .. WCP.UI.DotSwap.source.name .. " with " .. self.name
      else
        tooltip = (
          tooltip .. "\n\n" ..
          "LMB: Swap Position" .. "\n" ..
          "RMB (hold): Drag" .. "\n" ..
          "Alt + RMB: Reset all positions"
        )
      end
    end

    GameTooltip:SetText(tooltip)
    GameTooltip:Show()
  end)

  self.button:SetScript("OnLeave", function()
    if(WCP.UI.DotSwap:is_in_progress()) then
      WCP.UI.Cursor.set("Crosshairs")
    else
      WCP.UI.Cursor.set(nil)
    end

    GameTooltip:Hide()
  end)
end

function WCP.UI.Dot:swap_position_with(other_dot)
  local _, _, _, x, y = self.button:GetPoint()
  local _, _, _, other_x, other_y = other_dot.button:GetPoint()

  x = math.floor(x)
  y = math.floor(y)
  other_x = math.floor(other_x)
  other_y = math.floor(other_y)

  self:set_position(other_x, other_y)
  other_dot:set_position(x, y)
end

-- @note DotSwap
WCP.UI.DotSwap = { source = nil }

function WCP.UI.DotSwap:start(source)
  self["source"] = source
  WCP.UI.Cursor.set("Crosshairs")
end

function WCP.UI.DotSwap:finish(target)
  if(self["source"] == target) then return false end

  self["source"]:swap_position_with(target)
  WCP.UI.Dot.share_positions()
  WCP.UI.DotSwap:reset()
end

function WCP.UI.DotSwap:reset()
  WCP.UI.Cursor.set(nil)
  self["source"] = nil
end

function WCP.UI.DotSwap:is_in_progress()
  return (self["source"] ~= nil)
end

-- @note "Immediately upon calling StartMoving(),
--        the frame will be de-anchored from any other frame it was previously anchored to"
-- @read https://wowwiki.fandom.com/wiki/API_Frame_StartMoving
WCP.UI.Dot.DragHelper = {
  start_at_relative = nil,
  start_at_absolute = nil,
  end_at_absolute = nil
}

function WCP.UI.Dot.DragHelper:start(frame)
  self.start_at_relative = WCP.UI.Dot.DragHelper.get_point(frame)
  frame:StartMoving();
  self.start_at_absolute = WCP.UI.Dot.DragHelper.get_point(frame)
  frame.isMoving = true;
end

function WCP.UI.Dot.DragHelper:stop(dot, frame)
  self.end_at_absolute = WCP.UI.Dot.DragHelper.get_point(frame)
  WCP.UI.Cursor.set(nil)
  frame:StopMovingOrSizing();
  frame.isMoving = false;

  local delta = WCP.UI.Dot.DragHelper.get_delta(
    self.start_at_absolute,
    self.end_at_absolute
  )

  local target_x = math.floor(self.start_at_relative.dx - delta.dx)
  local target_y = math.floor(self.start_at_relative.dy - delta.dy)

  dot:set_position(target_x, target_y)
  WCP.UI.Dot.share_positions()
end

function WCP.UI.Dot.DragHelper.get_point(frame)
  local point, relative_to, relative_point, dx, dy = frame:GetPoint()

  return {
    point = point,
    relative_to = relative_to,
    relative_point = relative_point,
    dx = dx,
    dy = dy,
  }
end

function WCP.UI.Dot.DragHelper.get_delta(point, other_point)
  return {
    dx = (point.dx - other_point.dx),
    dy = (point.dy - other_point.dy)
  }
end
