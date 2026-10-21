-- Only these kits need a nominal-effect tooltip: their loose/native-load
-- WeightModifier is deliberately zero and MFS replaces the normal description.
require "Items/Codex_PetGunWeightKits"

local C = CodexPetGunWeightKits
local YELLOW = { 1.0, 1.0, 0.8 }
local WHITE = { 1.0, 1.0, 1.0 }
local GREY = { 0.7, 0.7, 0.7 }
local GREEN = { 0.2, 0.8, 0.2 }

local function translated(key, fallback)
    local text = getText(key)
    return text and text ~= key and text or fallback
end

local function addText(lines, text, color)
    lines[#lines + 1] = { type = "simple", text = text, color = color or GREY }
end

local function addValue(lines, label, value, color)
    lines[#lines + 1] = { type = "labelvalue", label = label .. ": ", value = value,
        labelColor = YELLOW, valueColor = color or WHITE }
end

function C.BuildKitTooltipLines(item)
    if not C.IsKit(item) then return nil end
    local reduction = C.GetNominalReduction(item)
    local lines = {}
    addText(lines, item:getDisplayName(), YELLOW)
    addValue(lines, translated("Tooltip_item_Weight", "Weight"), string.format("%.2f", item:getActualWeight()))
    local slot = item:getPartType()
    local slotName = slot == "Misc"
        and translated("UI_CodexPetKit_Misc", "Misc")
        or translated("UI_CodexPetKit_Sling", "Sling (legacy kit)")
    addValue(lines, translated("UI_CodexPetKit_Slot", "Attachment slot"), slotName)
    lines[#lines + 1] = { type = "separator" }
    addValue(lines, translated("UI_CodexPetKit_Reduction", "Maximum weight reduction"),
        string.format("-%.1f", reduction), GREEN)
    addValue(lines, translated("UI_CodexPetKit_Scope", "Compatible with"), reduction > 1.5
        and translated("UI_CodexPetKit_HeavyFirearms", "Firearms with bare weight above 5.0")
        or translated("UI_CodexPetKit_AllFirearms", "All firearms"))
    addValue(lines, translated("UI_CodexPetKit_Minimum", "Minimum gun plus attachment weight"), "0.1")
    lines[#lines + 1] = { type = "separator" }
    addText(lines, translated("UI_CodexPetKit_Equipped", "Equipped and hotbar burden follow native multipliers."))
    addText(lines, translated("UI_CodexPetKit_Exclusive", "Shares its slot with other parts; light and heavy cannot stack."))
    addText(lines, translated("UI_CodexPetKit_NoVisual", "Does not change the gun's appearance."))
    if C.IsMigrationBlocked and C.IsMigrationBlocked(item) then
        addText(lines, translated("UI_CodexPetKit_MigrationBlocked",
            "Misc is occupied: this legacy kit stays active here and migrates when that slot is free."))
    end
    return lines
end

-- Kahlua strings use Java character indices. Use measured character slices;
-- byte-oriented UTF-8 patterns would discard Chinese characters in this VM.
local function wrapText(text, font, width)
    local lines, current = {}, ""
    for index = 1, #text do
        local character = string.sub(text, index, index)
        if current ~= "" and getTextManager():MeasureStringX(font, current .. character) > width then
            lines[#lines + 1] = current
            current = character
        else
            current = current .. character
        end
    end
    if current ~= "" then lines[#lines + 1] = current end
    return lines
end

local function renderKitTooltip(self, lines)
    local font = ISToolTip.GetFont()
    local padding, gap = 6, 24
    local lineHeight = getTextManager():getFontHeight(font)
    local screenW, screenH = getCore():getScreenWidth(), getCore():getScreenHeight()
    local availableWidth = math.max(80, math.min(520, screenW - padding * 2 - 4))
    local drawLines, width, height = {}, 0, lineHeight / 2
    for _, line in ipairs(lines) do
        if line.type == "separator" then
            drawLines[#drawLines + 1] = line
            height = height + 4
        else
            local text = line.type == "labelvalue" and line.label .. line.value or line.text
            local textWidth = getTextManager():MeasureStringX(font, text)
            if line.type == "labelvalue" and textWidth <= availableWidth then
                drawLines[#drawLines + 1] = line
                width = math.max(width, textWidth)
                height = height + lineHeight
            else
                for _, wrapped in ipairs(wrapText(text, font, availableWidth)) do
                    addText(drawLines, wrapped, line.color or line.valueColor or WHITE)
                    width = math.max(width, getTextManager():MeasureStringX(font, wrapped))
                    height = height + lineHeight
                end
            end
        end
    end
    width, height = width + padding * 2 + 2, height + padding * 2 + 2
    local mouseX, mouseY = getMouseX(), getMouseY()
    local leftSpace, rightSpace = mouseX - gap, screenW - mouseX - gap
    local x
    if leftSpace >= rightSpace and leftSpace >= width then x = mouseX - gap - width
    elseif rightSpace >= width then x = mouseX + gap
    elseif leftSpace >= width then x = mouseX - gap - width
    else x = math.max(0, math.min(mouseX + gap, screenW - width - 1)) end
    local y = math.max(0, math.min(mouseY + gap, screenH - height - 1))
    self:setX(x) self:setY(y) self:setWidth(width) self:setHeight(height)
    self:drawRect(0, 0, width, height, 0.9, 0, 0, 0)
    self:drawRectBorder(0, 0, width, height, 1, 0.4, 0.4, 0.4)
    local offsetY = padding
    for index, line in ipairs(drawLines) do
        if line.type == "separator" then
            self:drawRect(padding, offsetY + 2, width - padding * 2, 1, 1, 0.4, 0.4, 0.4)
            offsetY = offsetY + 4
        elseif line.type == "labelvalue" then
            local a, b = line.labelColor, line.valueColor
            self:drawText(line.label, padding, offsetY, a[1], a[2], a[3], 1, font)
            self:drawText(line.value, padding + getTextManager():MeasureStringX(font, line.label), offsetY,
                b[1], b[2], b[3], 1, font)
            offsetY = offsetY + lineHeight
        else
            local color = line.color
            self:drawText(line.text, padding, offsetY, color[1], color[2], color[3], 1, font)
            offsetY = offsetY + lineHeight
            if index == 1 then offsetY = offsetY + lineHeight / 2 end
        end
    end
end

function C.InstallTooltipHook()
    if C._kitTooltipHookInstalled or not ISToolTipInv or not ISToolTipInv.render then return end
    local original = ISToolTipInv.render
    ISToolTipInv.render = function(self, ...)
        if not C.IsKit(self.item) or (ISContextMenu.instance and ISContextMenu.instance.visibleCheck) then
            return original(self, ...)
        end
        renderKitTooltip(self, C.BuildKitTooltipLines(self.item))
    end
    C._kitTooltipHookInstalled = true
end

-- MFS installs several render wrappers while loading. Wrap the final chain.
Events.OnGameStart.Add(C.InstallTooltipHook)
