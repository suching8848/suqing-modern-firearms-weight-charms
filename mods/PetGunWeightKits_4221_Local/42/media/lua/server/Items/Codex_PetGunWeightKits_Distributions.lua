-- Natural container loot only.  Existing containers are never filled again.
require "Items/ProceduralDistributions"

CodexPetGunWeightKitsLoot = CodexPetGunWeightKitsLoot or {}
local L = CodexPetGunWeightKitsLoot
local previousCallback = L.Callback

L.VERSION = "1.2.0"
L._warned = L._warned or {}

local rules = {
    { list = "GunStoreAccessories", item = "CodexPetGunWeightKits.LightWeightKitMisc", weight = 1.0 },
    { list = "PoliceStorageGuns", item = "CodexPetGunWeightKits.LightWeightKitMisc", weight = 0.5 },
    { list = "ArmyStorageGuns", item = "CodexPetGunWeightKits.LightWeightKitMisc", weight = 0.8 },
    { list = "ArmyStorageGuns", item = "CodexPetGunWeightKits.HeavyWeightKitMisc", weight = 0.15 },
}

local function warnOnce(key, message)
    if L._warned[key] then return end
    L._warned[key] = true
    print("[Codex PetGunWeightKits Loot] " .. message)
end

local function appendPair(rule)
    local root = ProceduralDistributions and ProceduralDistributions.list
    local distribution = type(root) == "table" and root[rule.list] or nil
    local items = type(distribution) == "table" and distribution.items or nil
    if type(items) ~= "table" then
        warnOnce(rule.list .. ":missing", "skipped missing item list: " .. rule.list)
        return "skipped"
    end
    if #items % 2 ~= 0 then
        warnOnce(rule.list .. ":malformed", "skipped unpaired item list: " .. rule.list)
        return "skipped"
    end
    for index = 1, #items, 2 do
        if items[index] == rule.item then return "existing" end
    end
    -- Preserve every existing pair, weight, roll count and junk distribution.
    table.insert(items, rule.item)
    table.insert(items, rule.weight)
    return "added"
end

function L.Register()
    local result = { added = 0, existing = 0, skipped = 0 }
    for _, rule in ipairs(rules) do
        local outcome = appendPair(rule)
        result[outcome] = result[outcome] + 1
    end
    L.LastResult = result
    local summary = string.format("%s ready; added=%d existing=%d skipped=%d", L.VERSION,
        result.added, result.existing, result.skipped)
    if L._lastSummary ~= summary then
        print("[Codex PetGunWeightKits Loot] " .. summary)
        L._lastSummary = summary
    end
    return result
end

-- The native game merges/compiles distributions after this event.  Replace the
-- callback on a Lua reload, and make every insertion itself idempotent as well.
if previousCallback then Events.OnPreDistributionMerge.Remove(previousCallback) end
L.Callback = L.Register
Events.OnPreDistributionMerge.Add(L.Callback)
