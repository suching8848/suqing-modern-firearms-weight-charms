require "Items/Codex_PetGunWeightKits"
require "TimedActions/ISUpgradeWeapon"
require "TimedActions/ISRemoveWeaponUpgrade"
require "TimedActions/ISTransferAction"
require "TimedActions/ISInventoryTransferAction"

local C = CodexPetGunWeightKits
local lastSweep = setmetatable({}, { __mode = "k" })
local lastPageScan = setmetatable({}, { __mode = "k" })
local lastQueueService

local function scanAllPlayers(force)
    for index = 0, getNumActivePlayers() - 1 do C.ScanPlayerCached(getSpecificPlayer(index), force) end
end

-- Install these after all client Lua files have loaded.  In particular MFS
-- replaces isValid() and omits native canAttach(); reinstate it for our kits.
function C.InstallActionHooks()
    if not C._upgradeIsValidHook then
        C._upgradeIsValidHook = true
        local original = ISUpgradeWeapon.isValid
        ISUpgradeWeapon.isValid = function(self, ...)
            self.part = C.ResolveItem(self.part)
            if C.IsKit(self.part) and not C.CanAttach(self.character, self.weapon, self.part) then
                return false
            end
            return original(self, ...)
        end
    end
    if not C._upgradeCompleteHook then
        C._upgradeCompleteHook = true
        local original = ISUpgradeWeapon.complete
        ISUpgradeWeapon.complete = function(self, ...)
            self.part = C.ResolveItem(self.part)
            -- Defensive validity check for direct callers that skip isValid().
            if C.IsKit(self.part) and not C.CanAttach(self.character, self.weapon, self.part) then
                return false
            end
            local result = original(self, ...)
            C.NormalizeWeapon(self.weapon)
            return result
        end
    end
    if not C._removeCompleteHook then
        C._removeCompleteHook = true
        local original = ISRemoveWeaponUpgrade.complete
        ISRemoveWeaponUpgrade.complete = function(self, ...)
            local result = original(self, ...)
            -- A removed legacy kit becomes the current Misc item in inventory.
            C.ScanPlayer(self.character)
            C.NormalizeWeapon(self.weapon)
            return result
        end
    end
    if not C._transferHook then
        C._transferHook = true
        local original = ISTransferAction.transferItem
        ISTransferAction.transferItem = function(self, character, item, ...)
            item = C.ResolveItem(item)
            C.ScanItem(item)
            C._busyItems[item] = true
            local succeeded, result = pcall(original, self, character, item, ...)
            C._busyItems[item] = nil
            if not succeeded then error(result, 0) end
            if C.IsLegacyKit(result) then result = C.MigrateLooseKit(result) end
            C.ScanItem(item)
            return result
        end
    end
    if not C._inventoryTransferHook then
        C._inventoryTransferHook = true
        local originalValid = ISInventoryTransferAction.isValid
        ISInventoryTransferAction.isValid = function(self, ...)
            self.item = C.ResolveItem(self.item)
            return originalValid(self, ...)
        end
        local originalTransfer = ISInventoryTransferAction.transferItem
        ISInventoryTransferAction.transferItem = function(self, item, ...)
            item = C.ResolveItem(item)
            self.item = C.ResolveItem(self.item)
            return originalTransfer(self, item, ...)
        end
    end
end

local function onGameStart()
    C.Initialize(true)
    C.InstallActionHooks()
    scanAllPlayers(true)
    print("[Codex PetGunWeightKits] " .. C.VERSION .. " ready; slot=Misc; light=-1.5; heavy=-5, bare>5; minimum=0.1; legacy=Sling-safe-migration")
end

local function onCreatePlayer(index, player)
    C.ScanPlayerCached(player or getSpecificPlayer(index), true)
end

local function onEquip(character, item)
    C.ScanItem(item)
    C.ScanPlayerCached(character)
end

local function onInventoryContainers(page, stage)
    if not page or (stage ~= "buttonsAdded" and stage ~= "end") then return end
    local now = getTimestampMs()
    local previous = lastPageScan[page]
    -- The two phases describe the same page refresh. First-seen containers have
    -- already been normalized before display during buttonsAdded.
    if stage == "end" and previous and now >= previous and now - previous < 100 then return end
    lastPageScan[page] = now
    local visited = {}
    C.ScanContainerCached(page.inventory, visited)
    for _, button in ipairs(page.backpacks or {}) do C.ScanContainerCached(button.inventory, visited) end
end

local function onContainerUpdate(object)
    -- The event's object is optional and can be an IsoObject or ItemContainer.
    if object and instanceof(object, "ItemContainer") then
        C.QueueContainerScan(object)
    elseif object and instanceof(object, "IsoObject") then
        for index = 0, object:getContainerCount() - 1 do C.QueueContainerScan(object:getContainerByIndex(index)) end
    else
        -- A nil event provides no affected container. Queue player roots rather
        -- than recursively sweeping them synchronously for each transferred item.
        for index = 0, getNumActivePlayers() - 1 do
            local player = getSpecificPlayer(index)
            if player then C.QueueContainerScan(player:getInventory()) end
        end
    end
end

local function onPlayerUpdate(player)
    local now = getTimestampMs()
    if not lastQueueService or now < lastQueueService or now - lastQueueService >= 250 then
        lastQueueService = now
        C.ProcessPendingContainerScans(1)
    end
    local previous = lastSweep[player]
    if previous and now >= previous and now - previous < C.SCAN_NORMALIZE_MS then return end
    lastSweep[player] = now
    -- Covers other mods that modify attachments without a native timed action,
    -- without reclassifying every ordinary item in all bags once per second.
    -- All intervals are wall-clock milliseconds, unaffected by game fast-forward.
    C.ScanPlayerCached(player)
end

local function onInventoryContextMenu(playerIndex, context, items)
    local visited = {}
    for _, entry in ipairs(items or {}) do
        if type(entry) == "table" and entry.items then
            for _, item in ipairs(entry.items) do C.ScanItem(item, visited) end
        else
            C.ScanItem(entry, visited)
        end
    end
end

Events.OnGameStart.Add(onGameStart)
Events.OnCreatePlayer.Add(onCreatePlayer)
Events.OnEquipPrimary.Add(onEquip)
Events.OnEquipSecondary.Add(onEquip)
Events.OnRefreshInventoryWindowContainers.Add(onInventoryContainers)
Events.OnContainerUpdate.Add(onContainerUpdate)
Events.OnPlayerUpdate.Add(onPlayerUpdate)
Events.OnFillInventoryObjectContextMenu.Add(onInventoryContextMenu)
