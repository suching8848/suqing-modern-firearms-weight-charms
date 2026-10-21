-- Independent single-player gun weight kits.  Only this mod's WeaponParts are
-- changed; weapons, ammunition, models and other attachments retain their data.
CodexPetGunWeightKits = CodexPetGunWeightKits or {}
local C = CodexPetGunWeightKits

C.VERSION = "1.1.1"
C.MIN_WEIGHT = 0.1
C.HEAVY_MIN_BASE = 5.0 -- strictly greater than this value
C.LIGHT_TYPE = "CodexPetGunWeightKits.LightWeightKitMisc"
C.HEAVY_TYPE = "CodexPetGunWeightKits.HeavyWeightKitMisc"
C.LEGACY_LIGHT_TYPE = "CodexPetGunWeightKits.LightWeightKit"
C.LEGACY_HEAVY_TYPE = "CodexPetGunWeightKits.HeavyWeightKit"
C.KIT_SLOT = "Misc"
C.LEGACY_SLOT = "Sling"
C._preparedParts = C._preparedParts or setmetatable({}, { __mode = "k" })
C._replacementItems = C._replacementItems or setmetatable({}, { __mode = "k" })
C._migrationBlocked = C._migrationBlocked or setmetatable({}, { __mode = "k" })
C._migratingWeapons = C._migratingWeapons or setmetatable({}, { __mode = "k" })
C._busyItems = C._busyItems or setmetatable({}, { __mode = "k" })
C._generation = C._generation or 0

local function isFiniteNumber(value)
    return type(value) == "number" and value == value and math.abs(value) < math.huge
end

function C.IsKit(part)
    if not part or not instanceof(part, "WeaponPart") then return false end
    local fullType = part:getFullType()
    return fullType == C.LIGHT_TYPE or fullType == C.HEAVY_TYPE
        or fullType == C.LEGACY_LIGHT_TYPE or fullType == C.LEGACY_HEAVY_TYPE
end

function C.IsLegacyKit(part)
    if not C.IsKit(part) then return false end
    local fullType = part:getFullType()
    return fullType == C.LEGACY_LIGHT_TYPE or fullType == C.LEGACY_HEAVY_TYPE
end

function C.IsHeavyKit(part)
    if not C.IsKit(part) then return false end
    local fullType = part:getFullType()
    return fullType == C.HEAVY_TYPE or fullType == C.LEGACY_HEAVY_TYPE
end

function C.GetKitSlot(part)
    if not C.IsKit(part) then return nil end
    return C.IsLegacyKit(part) and C.LEGACY_SLOT or C.KIT_SLOT
end

function C.IsMigrationBlocked(part)
    return C.IsLegacyKit(part) and C._migrationBlocked[part] == true
end

function C.ResolveItem(item)
    return C._replacementItems[item] or item
end

function C.GetWeaponKit(weapon)
    if not weapon or not instanceof(weapon, "HandWeapon") then return nil end
    local part = weapon:getWeaponPart(C.KIT_SLOT)
    if C.IsKit(part) then return part, C.KIT_SLOT end
    part = weapon:getWeaponPart(C.LEGACY_SLOT)
    if C.IsKit(part) then return part, C.LEGACY_SLOT end
    return nil
end

function C.GetNominalReduction(part)
    if not C.IsKit(part) then return 0 end
    return C.IsHeavyKit(part) and 5.0 or 1.5
end

-- Matching the ranged/ammunition script predicate keeps the mount list valid
-- for vanilla and newly installed firearm mods without a fixed gun whitelist.
function C.IsFirearm(weapon)
    return weapon ~= nil and instanceof(weapon, "HandWeapon")
        and weapon:isRanged() and weapon:getAmmoType() ~= nil
end

function C.GetBareWeight(weapon)
    if not weapon or not instanceof(weapon, "HandWeapon") then return nil end
    local script = weapon:getScriptItem()
    if not script then return nil end
    local weight = script:getActualWeight()
    if not isFiniteNumber(weight) then return nil end
    return weight
end

function C.IsEligible(weapon, part)
    if not C.IsKit(part) or not C.IsFirearm(weapon) then return false end
    local bare = C.GetBareWeight(weapon)
    if not bare then return false end
    return not C.IsHeavyKit(part) or bare > C.HEAVY_MIN_BASE
end

function C.Initialize(force)
    if C._mountLists and not force then return true end
    local manager = getScriptManager()
    if not manager then return false end
    local lightScript = manager:getItem(C.LIGHT_TYPE)
    local heavyScript = manager:getItem(C.HEAVY_TYPE)
    -- Avoid caching a partial catalog during an unusual early/hot load.
    if not lightScript or not heavyScript then return false end
    local allItems = manager:getAllItems()
    if not allItems then return false end
    local names = { light = {}, heavy = {} }
    local lists = { light = ArrayList.new(), heavy = ArrayList.new() }
    for index = 0, allItems:size() - 1 do
        local script = allItems:get(index)
        if script:isRanged() and script:getAmmoType() ~= nil then
            local fullType = script:getFullName()
            names.light[#names.light + 1] = fullType
            lists.light:add(fullType)
            if script:getActualWeight() > C.HEAVY_MIN_BASE then
                names.heavy[#names.heavy + 1] = fullType
                lists.heavy:add(fullType)
            end
        end
    end
    lightScript:DoParam("MountOn", table.concat(names.light, ";"))
    heavyScript:DoParam("MountOn", table.concat(names.heavy, ";"))
    local legacyLight = manager:getItem(C.LEGACY_LIGHT_TYPE)
    local legacyHeavy = manager:getItem(C.LEGACY_HEAVY_TYPE)
    if legacyLight then legacyLight:DoParam("MountOn", table.concat(names.light, ";")) end
    if legacyHeavy then legacyHeavy:DoParam("MountOn", table.concat(names.heavy, ";")) end
    C._mountLists = lists
    C._mountNames = names
    C._generation = C._generation + 1
    return true
end

function C.PreparePart(part)
    if not C.IsKit(part) then return false end
    if not C.Initialize() then return false end
    if C._preparedParts[part] ~= C._generation then
        local key = C.IsHeavyKit(part) and "heavy" or "light"
        part:setMountOn(C._mountLists[key])
        C._preparedParts[part] = C._generation
    end
    return true
end

-- Native callback order is (character, weapon, part).
function C.CanAttach(character, weapon, part)
    part = C.ResolveItem(part)
    if not C.IsEligible(weapon, part) then return false end
    C.PreparePart(part)
    if C.GetWeaponKit(weapon) then return false end
    if weapon:getWeaponPart(C.KIT_SLOT) then return false end
    -- A not-yet-converted legacy part briefly attaches to Sling, then migrates.
    return weapon:getWeaponPart(C.GetKitSlot(part)) == nil
end

local function createReplacement(part)
    local fullType = C.IsHeavyKit(part) and C.HEAVY_TYPE or C.LIGHT_TYPE
    if not getScriptManager():getItem(fullType) then return nil end
    local replacement = instanceItem(fullType)
    if not replacement or not C.IsKit(replacement) then return nil end
    -- Its fresh ID is retained until the old item has actually been removed.
    replacement:setCondition(part:getCondition())
    replacement:setFavorite(part:isFavorite())
    replacement:copyModData(part:getModData())
    replacement:setAge(part:getAge())
    replacement:setTimesRepaired(part:getTimesRepaired())
    replacement:setContainerX(part:getContainerX())
    replacement:setContainerY(part:getContainerY())
    if part:isCustomName() then
        replacement:setName(part:getName())
        replacement:setCustomName(true)
    end
    if part:isCustomColor() then
        replacement:setColor(part:getColor())
        replacement:setCustomColor(true)
    end
    return replacement
end

-- Keep the old script IDs as Sling forever: native load rebuilds each part's
-- slot from its current script, before Lua can rescue any same-slot collision.
function C.MigrateWeaponKit(weapon)
    if not weapon or not instanceof(weapon, "HandWeapon") then return nil end
    local legacy = weapon:getWeaponPart(C.LEGACY_SLOT)
    if not C.IsLegacyKit(legacy) or C._migratingWeapons[weapon] then
        return C.GetWeaponKit(weapon)
    end
    if weapon:getWeaponPart(C.KIT_SLOT) then
        C._migrationBlocked[legacy] = true
        return C.GetWeaponKit(weapon)
    end
    C._migrationBlocked[legacy] = nil
    local created, replacement = pcall(createReplacement, legacy)
    if not created or not replacement then return legacy, C.LEGACY_SLOT end
    if weapon:getWeaponPart(C.KIT_SLOT) then
        C._migrationBlocked[legacy] = true
        return legacy, C.LEGACY_SLOT
    end
    C._migratingWeapons[weapon] = true
    -- Kits have no native damage/range/etc modifiers.  Moving map entries avoids
    -- changing gun identity, ammunition, model state or unrelated attachment stats.
    local moved = pcall(function()
        weapon:clearWeaponPart(C.LEGACY_SLOT)
        weapon:setWeaponPart(C.KIT_SLOT, replacement)
    end)
    if not moved or weapon:getWeaponPart(C.KIT_SLOT) ~= replacement then
        if weapon:getWeaponPart(C.KIT_SLOT) == replacement then weapon:clearWeaponPart(C.KIT_SLOT) end
        if not weapon:getWeaponPart(C.LEGACY_SLOT) then weapon:setWeaponPart(C.LEGACY_SLOT, legacy) end
        C._migratingWeapons[weapon] = nil
        return legacy, C.LEGACY_SLOT
    end
    replacement:setID(legacy:getID())
    legacy:setWeightModifier(0)
    C._replacementItems[legacy] = replacement
    C.NormalizeWeapon(weapon, replacement)
    C._migratingWeapons[weapon] = nil
    local container = weapon:getContainer()
    if container then container:setDrawDirty(true) end
    return replacement, C.KIT_SLOT
end

function C.MigrateLooseKit(part, container)
    part = C.ResolveItem(part)
    if not C.IsLegacyKit(part) or C._busyItems[part] then return part end
    container = container or part:getContainer()
    if not container or not container:contains(part) then return part end
    -- Ground items also belong to IsoWorldInventoryObjects.  Convert after
    -- pickup instead of leaving a stale world object behind.
    if container:getType() == "floor" or part:getWorldItem() then return part end
    local created, replacement = pcall(createReplacement, part)
    if not created or not replacement then return part end
    C._busyItems[part] = true
    local character = container:getCharacter()
    local primary = character and character:getPrimaryHandItem() == part
    local secondary = character and character:getSecondaryHandItem() == part
    pcall(function() container:AddItem(replacement) end)
    if not container:contains(replacement) then
        C._busyItems[part] = nil
        return part
    end
    pcall(function() container:Remove(part) end)
    if container:contains(part) then
        container:Remove(replacement)
        C._busyItems[part] = nil
        return part
    end
    replacement:setID(part:getID())
    C._replacementItems[part] = replacement
    C._migrationBlocked[part] = nil
    C._busyItems[part] = nil
    if primary then character:setPrimaryHandItem(replacement) end
    if secondary then character:setSecondaryHandItem(replacement) end
    container:setDrawDirty(true)
    return replacement
end

-- Recompute from the immutable bare script weight and OTHER parts every time.
-- No previous kit discount, ammunition or magazine contents enter this sum.
-- explicitPart also permits safe use before insertion into the attachment map.
function C.NormalizeWeapon(weapon, explicitPart)
    if not weapon or not instanceof(weapon, "HandWeapon") then return false end
    if not C._migratingWeapons[weapon] then C.MigrateWeaponKit(weapon) end
    local kit = C.ResolveItem(explicitPart)
    if not C.IsKit(kit) then kit = C.GetWeaponKit(weapon) end
    if not C.IsKit(kit) then return false end
    C.PreparePart(kit)
    local bare = C.GetBareWeight(weapon)
    if not bare then return false end
    local weightWithoutKit = bare
    local parts = weapon:getAllWeaponParts()
    for index = 0, parts:size() - 1 do
        local part = parts:get(index)
        if not C.IsKit(part) then
            weightWithoutKit = weightWithoutKit + part:getWeightModifier()
        elseif part ~= kit and part:getWeightModifier() ~= 0 then
            -- Defensive only: normal installation permits one kit in total.
            part:setWeightModifier(0)
        end
    end
    local modifier = 0
    if C.IsEligible(weapon, kit) then
        modifier = math.max(-C.GetNominalReduction(kit), C.MIN_WEIGHT - weightWithoutKit)
    end
    if math.abs(kit:getWeightModifier() - modifier) > 0.000001 then
        kit:setWeightModifier(modifier)
        return true
    end
    return false
end

function C.OnCreate(part)
    if not C.IsKit(part) then return end
    -- WeaponPart's native save format does not persist setWeightModifier().
    -- A zero script default is deliberately safe until load-time rehydration.
    part:setWeightModifier(0)
    C.PreparePart(part)
end

function C.OnAttach(character, weapon, part)
    if C.IsKit(part) then C.NormalizeWeapon(weapon, part) end
end

function C.OnDetach(character, weapon, part)
    if C.IsKit(part) then part:setWeightModifier(0) end
    C.NormalizeWeapon(weapon)
end

function C.ScanItem(item, visited, migrateLoose)
    item = C.ResolveItem(item)
    if not item then return end
    if C.IsKit(item) then
        if migrateLoose then item = C.MigrateLooseKit(item) end
        C.PreparePart(item)
    elseif instanceof(item, "HandWeapon") then
        C.NormalizeWeapon(item)
    elseif instanceof(item, "InventoryContainer") then
        C.ScanContainer(item:getInventory(), visited)
    end
    return item
end

function C.ScanContainer(container, visited)
    if not container then return end
    visited = visited or {}
    if visited[container] then return end
    visited[container] = true
    local items = container:getItems()
    local snapshot = {}
    for index = 0, items:size() - 1 do
        snapshot[#snapshot + 1] = items:get(index)
    end
    for _, item in ipairs(snapshot) do C.ScanItem(item, visited, true) end
end

function C.ScanPlayer(character)
    if not character or not instanceof(character, "IsoGameCharacter") then return end
    C.ScanContainer(character:getInventory())
    C.ScanItem(character:getPrimaryHandItem())
    C.ScanItem(character:getSecondaryHandItem())
end

-- UI/container events can fire once per moved item and multiple times per frame.
-- Keep the explicit Scan* APIs above immediate, but let background/UI callers
-- share a small index of weapons, our parts and nested bags. Ordinary inventory
-- items are only classified on discovery or a coalesced membership refresh.
C.SCAN_REFRESH_MS = 1000
C.SCAN_SAFETY_MS = 5000
C.SCAN_NORMALIZE_MS = 500
C._containerScanCache = C._containerScanCache or setmetatable({}, { __mode = "k" })
C._pendingContainerScans = C._pendingContainerScans or setmetatable({}, { __mode = "k" })

local function scanNow()
    return getTimestampMs()
end

local function scanElapsed(now, previous)
    -- A system-clock correction must not suspend normalization indefinitely.
    if not previous or now < previous then return math.huge end
    return now - previous
end

function C.QueueContainerScan(container)
    if not container then return end
    -- Keep the first request time: a continuous stream of transfers must not
    -- postpone a queued refresh forever.
    if not C._pendingContainerScans[container] then
        C._pendingContainerScans[container] = scanNow()
    end
end

local function refreshCachedItems(container, record, visited, normalize)
    for index = 1, record.itemCount do
        local item = C.ResolveItem(record.items[index])
        if not item then
            -- Java/Lua wrappers in this weak index may be collected while the
            -- inventory itself is still alive. Rebuild through the bounded queue.
            C.QueueContainerScan(container)
        elseif item:getContainer() == container then
            if instanceof(item, "InventoryContainer") then
                C.ScanContainerCached(item:getInventory(), visited)
            elseif normalize then
                record.items[index] = C.ScanItem(item, visited, true) or item
            end
        end
    end
end

function C.ScanContainerCached(container, visited, force)
    if not container then return end
    visited = visited or {}
    if visited[container] then return end
    visited[container] = true
    local now = scanNow()
    local record = C._containerScanCache[container]
    if record and record.scanning then return end

    if not record or force then
        record = record or {}
        record.scanning = true
        C._containerScanCache[container] = record
        C._pendingContainerScans[container] = nil

        local items = container:getItems()
        -- Loose-kit migration can remove/add items. Snapshot only candidates
        -- before normalization, rather than allocating a second 3000-item list.
        local relevant = {}
        local count = 0
        for index = 0, items:size() - 1 do
            local item = items:get(index)
            if C.IsKit(item) or instanceof(item, "HandWeapon")
                or instanceof(item, "InventoryContainer") then
                count = count + 1
                relevant[count] = item
            end
        end
        record.items = relevant
        record.itemCount = count
        record.lastFull = now
        record.lastNormalize = now
        refreshCachedItems(container, record, visited, true)
        record.count = container:getItems():size()
        record.scanning = false
        -- The discovery snapshot is strong until migration/normalization ends.
        -- The long-lived index must not keep moved/deleted Java items alive.
        setmetatable(relevant, { __mode = "v" })
        return
    end

    local count = container:getItems():size()
    if count ~= record.count or scanElapsed(now, record.lastFull) >= C.SCAN_SAFETY_MS then
        C.QueueContainerScan(container)
    end
    local normalize = scanElapsed(now, record.lastNormalize) >= C.SCAN_NORMALIZE_MS
    if normalize then record.lastNormalize = now end
    -- Always visit known bags, even if the outer inventory did not change:
    -- contents can change inside a bag without changing its parent's item count.
    refreshCachedItems(container, record, visited, normalize)
end

function C.ProcessPendingContainerScans(limit)
    local now = scanNow()
    for _ = 1, limit or 1 do
        local nextContainer, oldest
        for container, requested in pairs(C._pendingContainerScans) do
            local record = C._containerScanCache[container]
            if (not record or (not record.scanning
                and scanElapsed(now, record.lastFull) >= C.SCAN_REFRESH_MS))
                and (not oldest or requested < oldest) then
                nextContainer, oldest = container, requested
            end
        end
        if not nextContainer then return end
        C._pendingContainerScans[nextContainer] = nil
        C.ScanContainerCached(nextContainer, nil, true)
    end
end

function C.ScanPlayerCached(character, force)
    if not character or not instanceof(character, "IsoGameCharacter") then return end
    local visited = {}
    C.ScanContainerCached(character:getInventory(), visited, force)
    local function scanHand(item)
        if item and instanceof(item, "InventoryContainer") then
            C.ScanContainerCached(item:getInventory(), visited)
        else
            C.ScanItem(item)
        end
    end
    scanHand(character:getPrimaryHandItem())
    scanHand(character:getSecondaryHandItem())
end

-- Read-only developer diagnostics: no objects are spawned or saved.
function C.InspectWeapon(weapon)
    if not weapon or not instanceof(weapon, "HandWeapon") then return nil end
    local part, slot = C.GetWeaponKit(weapon)
    return {
        fullType = weapon:getFullType(),
        bareWeight = C.GetBareWeight(weapon),
        actualWeight = weapon:getActualWeight(),
        contentsWeight = weapon:getContentsWeight(),
        unequippedWeight = weapon:getUnequippedWeight(),
        equippedWeight = weapon:getEquippedWeight(),
        hotbarWeight = weapon:getHotbarEquippedWeight(),
        kitType = C.IsKit(part) and part:getFullType() or nil,
        kitModifier = C.IsKit(part) and part:getWeightModifier() or nil,
        kitEligible = C.IsKit(part) and C.IsEligible(weapon, part) or false,
        kitSlot = slot,
        legacyKit = C.IsLegacyKit(part),
        migrationBlocked = C.IsMigrationBlocked(part),
    }
end

if Events and Events.OnGameBoot then Events.OnGameBoot.Add(function() C.Initialize(true) end) end
