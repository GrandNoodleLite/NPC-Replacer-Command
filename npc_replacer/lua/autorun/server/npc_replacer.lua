-- NPC Replacer Addon

if SERVER then
    -- Define a table of restricted NPC classes
    local RESTRICTED_NPC_CLASSES = {
        ["npc_enemyfinder"] = true, -- Prevent this class from being targeted or spawned
    }
    
    -- Define a table of classes that can be targets but not replacements
    local RESTRICTED_REPLACEMENT_CLASSES = {
        ["scripted_target"] = true, -- Can be target but not replacement
    }
	
local NPC_CLASSES = {
    "npc_citizen",
    "npc_metropolice",
    "npc_combine_s",
	"npc_turret_floor",
	"npc_cscanner",
	"npc_fisherman",
	"npc_clawscanner",
	"npc_manhack",
	"npc_rollermine",
	"npc_hunter",
	"npc_monk",
	"npc_alyx",
	"npc_barney",
	"npc_breen",
	"npc_dog",
	"npc_eli",
	"npc_gman",
	"npc_kleiner",
	"npc_mossman",
	"npc_magnusson",
	"npc_vortigaunt",
	"npc_antlion",
	"npc_antlion_grub",
	"npc_antlion_worker",
	"npc_antlionguard",
	"npc_fastzombie",
	"npc_fastzombie_torso",
	"npc_headcrab",
	"npc_headcrab_black",
	"npc_headcrab_fast",
	"npc_poisonzombie",
	"npc_zombie",
	"npc_zombie_torso",
	"npc_zombine",
	"npc_stalker",
}

local MODELS = {
    "models/humans/group01/male_01.mdl",
    "models/humans/group01/female_01.mdl",
	"models/police.mdl",
	"models/combine_soldier.mdl",
	"models/combine_soldier_prisonguard.mdl",
    "models/combine_super_soldier.mdl",
	"models/odessa.mdl",
	"models/monk.mdl",
	"models/breen.mdl",
	"models/mossman.mdl",
	"models/magnusson.mdl",
	"models/kleiner.mdl",
	"models/alyx.mdl",
	"models/barney.mdl",
	"models/eli.mdl",
	"models/lostcoast/fisherman/fisherman.mdl",
    "models/humans/group03/female_01.mdl",
    "models/humans/group03/female_02.mdl",
    "models/humans/group03/female_03.mdl",
    "models/humans/group03/female_04.mdl",
    "models/humans/group03/female_06.mdl",
    "models/humans/group03/male_01.mdl",
    "models/humans/group03/male_02.mdl",
    "models/humans/group03/male_03.mdl",
    "models/humans/group03/male_04.mdl",
    "models/humans/group03/male_05.mdl",
    "models/humans/group03/male_06.mdl",
    "models/humans/group03/male_07.mdl",
    "models/humans/group03/male_08.mdl",
    "models/humans/group03/male_09.mdl",
	"models/humans/group03m/female_01.mdl",
	"models/humans/group03m/female_02.mdl",
	"models/humans/group03m/female_03.mdl",
	"models/humans/group03m/female_04.mdl",
	"models/humans/group03m/female_06.mdl",
	"models/humans/group03m/male_01.mdl",
	"models/humans/group03m/male_02.mdl",
	"models/humans/group03m/male_03.mdl",
	"models/humans/group03m/male_04.mdl",
	"models/humans/group03m/male_05.mdl",
	"models/humans/group03m/male_06.mdl",
	"models/humans/group03m/male_07.mdl",
	"models/humans/group03m/male_08.mdl",
	"models/humans/group03m/male_09.mdl",
}

local WEAPONS = {
	"weapon_357",
	"weapon_ar2",
    "weapon_smg1",
    "weapon_shotgun",
    "weapon_pistol",
	"weapon_crossbow",
	"weapon_crowbar",
	"weapon_stunstick",
	"weapon_rpg",
	"weapon_annabelle",
	"none",
}

    -- Helper function to check if a string looks like a model path
    local function IsModelPath(str)
        return string.find(string.lower(str), "models/") and string.find(string.lower(str), ".mdl$")
    end

local function NPReplaceAutocomplete(cmd, stringargs)
    stringargs = string.Trim(stringargs)
    if stringargs == "" then return {} end
    local args = string.Split(stringargs, " ")
    local partial = args[#args]
    local complete_args = {}
    for i = 1, #args - 1 do
        complete_args[i] = args[i]
    end
    local pos = 1
    local targetClass, targetModel, newClass, newModel, spawnWeapon
    if pos <= #complete_args then
        targetClass = complete_args[pos]
        pos = pos + 1
    end
    if pos <= #complete_args and IsModelPath(complete_args[pos]) then
        targetModel = complete_args[pos]
        pos = pos + 1
    end
    if pos <= #complete_args then
        newClass = complete_args[pos]
        pos = pos + 1
    end
    if pos <= #complete_args and IsModelPath(complete_args[pos]) then
        newModel = complete_args[pos]
        pos = pos + 1
    end
    if pos <= #complete_args then
        spawnWeapon = complete_args[pos]
        pos = pos + 1
    end
    local current_pos = pos
    local possible_values = {}
    if current_pos == 1 then
        possible_values = NPC_CLASSES
    elseif current_pos == 2 then
        possible_values = {}
        for _, v in ipairs(MODELS) do table.insert(possible_values, v) end
        for _, v in ipairs(NPC_CLASSES) do table.insert(possible_values, v) end
    elseif current_pos == 3 then
        if targetModel then
            possible_values = NPC_CLASSES
        else
            possible_values = {}
            for _, v in ipairs(MODELS) do table.insert(possible_values, v) end
            for _, v in ipairs(WEAPONS) do table.insert(possible_values, v) end
        end
    elseif current_pos == 4 then
        if targetModel then
            possible_values = {}
            for _, v in ipairs(MODELS) do table.insert(possible_values, v) end
            for _, v in ipairs(WEAPONS) do table.insert(possible_values, v) end
        else
            if newModel then
                possible_values = WEAPONS
            else
                possible_values = {}
            end
        end
    elseif current_pos == 5 then
        if targetModel and newModel then
            possible_values = WEAPONS
        else
            possible_values = {}
        end
    else
        return {}
    end
    local suggestions = {}
    for _, value in ipairs(possible_values) do
        if string.StartWith(string.lower(value), string.lower(partial)) then
            local prefix = cmd .. " " .. table.concat(complete_args, " ")
            if #complete_args > 0 then prefix = prefix .. " " end
            table.insert(suggestions, prefix.. value)
        end
    end
    table.sort(suggestions)
    return suggestions
end

local function NPCClassKillAutocomplete(cmd, stringargs)
    stringargs = string.Trim(stringargs)
    if stringargs == "" then return {} end
    local args = string.Split(stringargs, " ")
    local partial = args[#args]
    local complete_args = {}
    for i = 1, #args - 1 do
        complete_args[i] = args[i]
    end
    local pos = 1
    local targetClass, targetModel
    if pos <= #complete_args then
        targetClass = complete_args[pos]
        pos = pos + 1
    end
    if pos <= #complete_args and IsModelPath(complete_args[pos]) then
        targetModel = complete_args[pos]
        pos = pos + 1
    end
    local current_pos = pos
    local possible_values = {}
    if current_pos == 1 then
        possible_values = NPC_CLASSES
    elseif current_pos == 2 then
        possible_values = MODELS
    else
        possible_values = {}
    end
    local suggestions = {}
    for _, value in ipairs(possible_values) do
        if string.StartWith(string.lower(value), string.lower(partial)) then
            local prefix = cmd .. " " .. table.concat(complete_args, " ")
            if #complete_args > 0 then prefix = prefix .. " " end
            table.insert(suggestions, prefix .. value)
        end
    end
    table.sort(suggestions)
    return suggestions
end

    -- Color definitions for chat messages (used with chat.AddText via SendLua)
    local CHAT_COLORS = {
        ["\x03"] = "Color(100,150,255)",  -- Info / NPC entries (blue)
        ["\x04"] = "Color(255,80,80)",    -- Error (red)
        ["\x05"] = "Color(100,255,100)",  -- Success (green)
        ["\x06"] = "Color(130,200,255)",  -- Header (light blue)
        ["\x07"] = "Color(255,220,50)",   -- Warning / usage (yellow)
        ["\x08"] = "Color(255,255,255)",  -- Default (white)
    }

    -- Helper to escape a string for use inside a Lua double-quoted string
    local function EscapeForLua(str)
        str = string.gsub(str, "\\", "\\\\")
        str = string.gsub(str, '"', '\\"')
        str = string.gsub(str, "\n", "\\n")
        return str
    end

    -- Send a colored message ONLY to the chat HUD (not the console).
    -- Uses chat.AddText via SendLua so the message does not echo in console.
    local function ChatOnlyPrint(ply, colorCode, message)
        if not IsValid(ply) then return end
        local colorStr = CHAT_COLORS[colorCode] or "Color(255,255,255)"
        local escaped = EscapeForLua(message)
        ply:SendLua('chat.AddText(' .. colorStr .. ', "' .. escaped .. '")')
    end

    -- Modified function signature to include spawnWeapon and spawnHealth
    local function ReplaceNPCs(targetClass, targetModel, newClass, newModel, spawnWeapon, spawnHealth, ply)
        -- NEW: Check for restricted classes
        if RESTRICTED_NPC_CLASSES[string.lower(targetClass)] then
            ChatOnlyPrint(ply, "\x04", "❌ Error: Cannot target '" .. targetClass .. "'. This NPC class is restricted.")
            if IsValid(ply) then ply:SendLua("surface.PlaySound(\"buttons/button2.wav\")") end
            return
        end
        if RESTRICTED_NPC_CLASSES[string.lower(newClass)] then
            ChatOnlyPrint(ply, "\x04", "❌ Error: Cannot spawn '" .. newClass .. "'. This NPC class is restricted.")
            if IsValid(ply) then ply:SendLua("surface.PlaySound(\"buttons/button2.wav\")") end
            return
        end
        
        -- Check for replacement-restricted classes
        if RESTRICTED_REPLACEMENT_CLASSES[string.lower(newClass)] then
            ChatOnlyPrint(ply, "\x04", "❌ Error: Cannot spawn '" .. newClass .. "'. This NPC class is restricted for replacement.")
            if IsValid(ply) then ply:SendLua("surface.PlaySound(\"buttons/button2.wav\")") end
            return
        end

        local dissolveType = 1 -- 0 = Energy, 1 = Heavy, 2 = Light
        local replacedCount = 0
        local totalFound = 0
        local pendingReplacements = 0 -- Track how many replacements are still pending

        local specificTargetModel = nil
        if targetModel and targetModel ~= "" then
            -- Ensure targetModel is lowercased for consistent comparison
            specificTargetModel = string.lower(targetModel)
            print("Attempting to target model: " .. specificTargetModel)
        end

        local specificNewModel = nil
        if newModel and newModel ~= "" then
            -- Ensure newModel is lowercased
            specificNewModel = string.lower(newModel)
            print("New NPCs will use model: " .. specificNewModel)
        end

        local specificSpawnWeapon = nil
        local noWeapon = false -- Flag for explicitly spawning without weapons
        if spawnWeapon and spawnWeapon ~= "" then
            if string.lower(spawnWeapon) == "none" then
                noWeapon = true
                print("New NPCs will spawn without weapons (explicit none)")
            else
                specificSpawnWeapon = string.lower(spawnWeapon)
                print("New NPCs will spawn with weapon: " .. specificSpawnWeapon)
            end
        end

        -- Look up default NPC configuration from the spawn list
        -- The sandbox spawn menu uses list.Get("NPC") to find KeyValues and Weapons
        -- for each registered NPC class. We search by matching the Class field, not
        -- the table key, because keys can be display names (e.g. "Medic") rather than
        -- entity class names (e.g. "npc_citizen").
        local defaultWeapons = nil
        local npcListKeyValues = nil
        local npcList = list.Get("NPC")
        local npcListData = nil
        if npcList then
            -- First try direct key lookup (works for most NPCs where key == class)
            local directEntry = npcList[newClass]
            if directEntry and (not directEntry.Class or directEntry.Class == newClass) then
                npcListData = directEntry
            end
            -- If direct lookup failed, search all entries for matching Class field
            if not npcListData then
                for _, entry in pairs(npcList) do
                    if entry.Class == newClass then
                        npcListData = entry
                        break
                    end
                end
            end
        end
        if npcListData then
            if npcListData.KeyValues then
                npcListKeyValues = npcListData.KeyValues
            end
            if not noWeapon and npcListData.Weapons then
                -- Filter out empty strings from the weapons table
                local validWeapons = {}
                for _, w in ipairs(npcListData.Weapons) do
                    if w and w ~= "" then
                        table.insert(validWeapons, w)
                    end
                end
                if #validWeapons > 0 then
                    defaultWeapons = validWeapons
                    print("Default weapons found for " .. newClass .. ": " .. table.concat(defaultWeapons, ", "))
                end
            end
        end

        local specificSpawnHealth = nil
        if spawnHealth and spawnHealth > 0 then
            specificSpawnHealth = math.floor(spawnHealth)
            print("New NPCs will spawn with health: " .. specificSpawnHealth)
        end

        ----------------------------------------------------------------------
        -- Pre-check if the new NPC class and model can be spawned
        ----------------------------------------------------------------------
        local canSpawnNewNPC = true

        -- Validate model path first if one was specified (no entity creation needed)
        if specificNewModel then
            if not util.IsValidModel(specificNewModel) then
                canSpawnNewNPC = false
                if IsValid(ply) then ChatOnlyPrint(ply, "\x04", "❌ Error: New model '" .. specificNewModel .. "' for class '" .. newClass .. "' is not valid. Check model path.") end
            end
        end

        -- Validate the NPC class exists
        if canSpawnNewNPC then
            local classExists = false

            -- Check Lua scripted entities first (covers VJ-Base, ZBase, DrGBase, etc.)
            -- This avoids creating a dummy entity that would trigger OnRemove hooks
            -- on NPC bases whose cleanup code expects a fully initialized NPC
            if scripted_ents.GetStored(newClass) then
                classExists = true
            end

            -- Check engine-registered NPC spawn list (covers npc_combine_s, npc_zombie, etc.)
            -- Only accept if the entry's Class field matches newClass, because keys can be
            -- display names (e.g. "Medic") whose actual entity class is different (npc_citizen)
            if not classExists then
                local npcList = list.Get("NPC")
                if npcList then
                    local directEntry = npcList[newClass]
                    if directEntry and (not directEntry.Class or directEntry.Class == newClass) then
                        classExists = true
                    end
                    -- Also check if any entry has this as its Class field
                    if not classExists then
                        for _, entry in pairs(npcList) do
                            if entry.Class == newClass then
                                classExists = true
                                break
                            end
                        end
                    end
                end
            end

            -- Check the spawnable entities list (covers non-NPC entities)
            if not classExists then
                local entList = list.Get("SpawnableEntities")
                if entList and entList[newClass] then
                    classExists = true
                end
            end

            -- Final fallback: try creating the entity directly
            -- pcall protects against OnRemove errors from custom NPC bases
            if not classExists then
                local testEnt = ents.Create(newClass)
                if IsValid(testEnt) then
                    classExists = true
                    pcall(function() testEnt:Remove() end)
                end
            end

            if not classExists then
                canSpawnNewNPC = false
                if IsValid(ply) then ChatOnlyPrint(ply, "\x04", "❌ Error: New NPC class '" .. newClass .. "' could not be found. Check class name.") end
            end
        end

        if not canSpawnNewNPC then
            if IsValid(ply) then
                ChatOnlyPrint(ply, "\x04", "❌ Replacement aborted due to invalid new NPC class or model.")
                ply:SendLua("surface.PlaySound(\"buttons/button2.wav\")")
            end
            return
        end
        ----------------------------------------------------------------------

        -- Collect NPCs first, filtering by model if specified
        local npcsToReplace = {}
        for _, npc in ipairs(ents.FindByClass(targetClass)) do
            if IsValid(npc) then
                -- Get model as string or default to empty string
                local npcModel = tostring(npc:GetModel() or "")
                npcModel = string.lower(npcModel)
                local modelMatches = false

                if specificTargetModel then
                    if npcModel == specificTargetModel then
                        modelMatches = true
                    end
                else
                    modelMatches = true
                end

                if modelMatches then
                    table.insert(npcsToReplace, npc)
                    totalFound = totalFound + 1
                end
            end
        end

        if totalFound == 0 then
            if IsValid(ply) then
                ChatOnlyPrint(ply, "\x07", "❌ No " .. targetClass .. " NPCs" .. (specificTargetModel and " with model " .. specificTargetModel or "") .. " found!")
                ply:SendLua("surface.PlaySound(\"buttons/button2.wav\")")
            end
            return
        end

        pendingReplacements = totalFound -- Initialize with the total number of NPCs to process

        -- Replacement logic
        for _, npc in ipairs(npcsToReplace) do
            local dissolverName = "npc_replacer_diss_" .. CurTime() .. "_" .. math.random(10000)
            
            local npcOriginalName = npc:GetName()
            if npcOriginalName == "" then
                npc:SetName("temp_dissolve_target_" .. CurTime() .. "_" .. math.random(10000))
            end

            local npcPos = npc:GetPos()
            -- Only preserve the yaw (horizontal facing direction) from the original NPC.
            -- NPCs like rollermines, manhacks, and scanners can tumble freely, so their
            -- pitch and roll may be arbitrary. Zeroing those ensures the replacement
            -- always spawns upright.
            local npcAng = Angle(0, npc:GetAngles().y, 0)
            -- Get the actual world-space bottom of the original NPC using WorldSpaceAABB.
            -- This returns the axis-aligned bounding box in world coordinates, so it
            -- gives us the correct bottom Z regardless of the entity's rotation or
            -- origin convention (e.g. rollermines have origin at center, humanoids at feet).
            local oldWorldMins = select(1, npc:WorldSpaceAABB())
            local oldBottomZ = oldWorldMins.z

            local dissolver = ents.Create("env_entity_dissolver")
            if IsValid(dissolver) then
                dissolver:SetName(dissolverName)
                dissolver:SetKeyValue("dissolvetype", tostring(dissolveType))
                dissolver:Spawn()
                dissolver:Activate()
                
                dissolver:Fire("Dissolve", npc:GetName(), 0)
                
                timer.Simple(0.2, function()
                    if IsValid(npc) then
                        npc:Remove()
                    end
                    
                    local newNPC = ents.Create(newClass)
                    if IsValid(newNPC) then
                        newNPC:SetPos(npcPos)
                        newNPC:SetAngles(npcAng)

                        -- Apply registered KeyValues from NPC spawn list before Spawn()
                        -- This mirrors sandbox spawn menu behavior and handles default NPC
                        -- configuration (citizentype, spawnflags, etc.)
                        if npcListKeyValues then
                            for k, v in pairs(npcListKeyValues) do
                                -- Skip additionalequipment here; weapon is handled separately below
                                if k ~= "additionalequipment" then
                                    newNPC:SetKeyValue(k, v)
                                end
                            end
                        end

                        -- Weapon assignment via additionalequipment KeyValue (before Spawn)
                        -- This is how GMod's spawn menu equips NPCs - the engine processes
                        -- this KeyValue during Spawn() for proper weapon initialization
                        if specificSpawnWeapon then
                            -- Player specified an explicit weapon
                            newNPC:SetKeyValue("additionalequipment", specificSpawnWeapon)
                        elseif not noWeapon then
                            if defaultWeapons then
                                -- Pick a random weapon from the NPC's registered weapon list
                                -- (same behavior as the sandbox spawn menu)
                                local randomWeapon = defaultWeapons[math.random(#defaultWeapons)]
                                newNPC:SetKeyValue("additionalequipment", randomWeapon)
                            elseif npcListKeyValues and npcListKeyValues["additionalequipment"] then
                                -- Fall back to the KeyValues default if no Weapons list exists
                                newNPC:SetKeyValue("additionalequipment", npcListKeyValues["additionalequipment"])
                            end
                        end
                        -- If noWeapon is true: skip all weapon assignment, NPC spawns unarmed

                        newNPC:Spawn()
                        newNPC:Activate()
                        newNPC:SetCreator(ply)

                        -- Apply custom model AFTER Spawn()/Activate() so it overrides any
                        -- model that the engine sets during spawning. This is necessary for
                        -- NPCs like npc_citizen whose Spawn() sets the model based on internal
                        -- citizentype logic, which would otherwise override our SetModel call.
                        if specificNewModel then
                            newNPC:SetModel(specificNewModel)
                        end

                        -- Align the bottom of the replacement NPC to the same height as
                        -- the bottom of the original. oldBottomZ is the world-space bottom
                        -- of the original (via WorldSpaceAABB, correct regardless of rotation).
                        -- The new NPC is spawned upright, so OBBMins().z reliably tells us
                        -- how far below its origin its bottom extends. We set the origin so
                        -- that origin + OBBMins().z == oldBottomZ, i.e.:
                        --   origin = oldBottomZ - OBBMins().z
                        -- This works in all directions: humanoid-to-rollermine, rollermine-to-
                        -- humanoid, same-type, hovering NPCs, thin platforms, etc.
                        local newMinsZ = newNPC:OBBMins().z
                        newNPC:SetPos(Vector(npcPos.x, npcPos.y, oldBottomZ - newMinsZ))

                        -- Apply custom health to the replacement NPC if specified
                        if specificSpawnHealth and IsValid(newNPC) then
                            -- Standard GMod method: SetMaxHealth first, then SetHealth
                            newNPC:SetMaxHealth(specificSpawnHealth)
                            newNPC:SetHealth(specificSpawnHealth)

                            -- VJ-Base compatibility: set StartHealth so VJ-Base internal logic
                            -- recognizes the correct health value (used for regen, damage scaling, etc.)
                            newNPC.StartHealth = specificSpawnHealth

                            -- ZBase compatibility: set ZBase's internal health tracking if present
                            if newNPC.SetZBaseHealth then
                                pcall(function() newNPC:SetZBaseHealth(specificSpawnHealth) end)
                            end

                            -- Delayed re-application to override any base that sets health
                            -- during its own deferred initialization (VJ-Base uses a 0.15s timer,
                            -- ZBase may also defer). We apply at 0.2s to catch both.
                            local capturedNPC = newNPC
                            local capturedHealth = specificSpawnHealth
                            timer.Simple(0.3, function()
                                if IsValid(capturedNPC) then
                                    capturedNPC:SetMaxHealth(capturedHealth)
                                    capturedNPC:SetHealth(capturedHealth)
                                    capturedNPC.StartHealth = capturedHealth
                                end
                            end)
                        end

                        replacedCount = replacedCount + 1
                    end
                    
                    if IsValid(dissolver) then
                        dissolver:Remove()
                    end

                    pendingReplacements = pendingReplacements - 1

                    if pendingReplacements == 0 then
                        local weaponInfo = ""
                        if specificSpawnWeapon then
                            weaponInfo = " with " .. specificSpawnWeapon
                        elseif noWeapon then
                            weaponInfo = " with no weapon"
                        elseif defaultWeapons then
                            weaponInfo = " with default weapons"
                        end
                        local healthInfo = specificSpawnHealth and (" [HP: " .. specificSpawnHealth .. "]") or ""
                        if replacedCount == 0 then
                            ChatOnlyPrint(ply, "\x07", "⚠️ Failed to replace " .. targetClass .. (specificTargetModel and " with model " .. specificTargetModel or "") .. "!")
                        else
                            ChatOnlyPrint(ply, "\x05", string.format("✅ Replaced %d/%d %s%s with %s%s%s%s", 
                                replacedCount, 
                                totalFound, 
                                targetClass, 
                                (specificTargetModel and " (model: " .. specificTargetModel .. ")" or ""), 
                                newClass,
                                (specificNewModel and " (model: " .. specificNewModel .. ")" or ""),
                                weaponInfo,
                                healthInfo
                            ))
                        end

                        if IsValid(ply) then
                            if replacedCount > 0 then
                                ply:SendLua("surface.PlaySound(\"buttons/button14.wav\")")
                            else
                                ply:SendLua("surface.PlaySound(\"buttons/button2.wav\")")
                            end
                        end
                    end
                end)
            else
                if IsValid(npc) then
                    npc:Remove()
                end
                pendingReplacements = pendingReplacements - 1
                if pendingReplacements == 0 then
                    local weaponInfo = ""
                    if specificSpawnWeapon then
                        weaponInfo = " with " .. specificSpawnWeapon
                    elseif noWeapon then
                        weaponInfo = " with no weapon"
                    elseif defaultWeapons then
                        weaponInfo = " with default weapons"
                    end
                    local healthInfo = specificSpawnHealth and (" [HP: " .. specificSpawnHealth .. "]") or ""
                    if replacedCount == 0 then
                        ChatOnlyPrint(ply, "\x07", "⚠️ Failed to replace " .. targetClass .. (specificTargetModel and " with model " .. specificTargetModel or "") .. "!")
                    else
                        ChatOnlyPrint(ply, "\x05", string.format("✅ Replaced %d/%d %s%s with %s%s%s%s", 
                            replacedCount, 
                            totalFound, 
                            targetClass, 
                            (specificTargetModel and " (model: " .. specificTargetModel .. ")" or ""), 
                            newClass,
                            (specificNewModel and " (model: " .. specificNewModel .. ")" or ""),
                            weaponInfo,
                            healthInfo
                        ))
                    end

                    if IsValid(ply) then
                        if replacedCount > 0 then
                            ply:SendLua("surface.PlaySound(\"buttons/button14.wav\")")
                        else
                            ply:SendLua("surface.PlaySound(\"buttons/button2.wav\")")
                        end
                    end
                end
            end
        end
    end

    -- Helper function to parse arguments (for npcreplace command)
    local function ParseReplaceArgs(args)
        local parsed = {
            targetClass = args[1],
            targetModel = nil,
            newClass = nil,
            newModel = nil,
            spawnWeapon = nil,
            spawnHealth = nil
        }

        if not parsed.targetClass then return nil end

        local currentArgIndex = 2
        
        if args[currentArgIndex] and IsModelPath(args[currentArgIndex]) then
            parsed.targetModel = args[currentArgIndex]
            currentArgIndex = currentArgIndex + 1
        end

        if args[currentArgIndex] then
            parsed.newClass = args[currentArgIndex]
            currentArgIndex = currentArgIndex + 1
        else
            return nil
        end

        if args[currentArgIndex] and IsModelPath(args[currentArgIndex]) then
            parsed.newModel = args[currentArgIndex]
            currentArgIndex = currentArgIndex + 1
        end

        -- After newModel, remaining args are [spawn_weapon] [health]
        -- If next arg is a number, treat it as health (no weapon specified)
        -- If next arg is NOT a number, treat it as weapon, then check for health after
        if args[currentArgIndex] then
            if tonumber(args[currentArgIndex]) then
                -- It's a number, so it's health (no weapon)
                parsed.spawnHealth = tonumber(args[currentArgIndex])
            else
                -- It's a weapon
                parsed.spawnWeapon = args[currentArgIndex]
                currentArgIndex = currentArgIndex + 1
                -- Check for health after weapon
                if args[currentArgIndex] and tonumber(args[currentArgIndex]) then
                    parsed.spawnHealth = tonumber(args[currentArgIndex])
                end
            end
        end

        return parsed
    end

    ----------------------------------------------------------------------
    -- NPC Class Kill functionality
    ----------------------------------------------------------------------
    local function RemoveNPCs(targetClass, targetModel, ply)
        -- Check for restricted classes
        if RESTRICTED_NPC_CLASSES[string.lower(targetClass)] then
            ChatOnlyPrint(ply, "\x04", "❌ Error: Cannot kill '" .. targetClass .. "'. This NPC class is restricted.")
            if IsValid(ply) then ply:SendLua("surface.PlaySound(\"buttons/button2.wav\")") end
            return
        end

        local dissolveType = 0 -- 0 = Energy
        local removedCount = 0
        local totalFound = 0
        local pendingRemovals = 0

        local specificTargetModel = nil
        if targetModel and targetModel ~= "" then
            specificTargetModel = string.lower(targetModel)
            print("Attempting to target model: " .. specificTargetModel)
        end

        -- Collect NPCs to kill
        local npcsToKill = {}
        for _, npc in ipairs(ents.FindByClass(targetClass)) do
            if IsValid(npc) then
                local npcModel = npc:GetModel() or ""
                npcModel = string.lower(npcModel)
                local modelMatches = false

                if specificTargetModel then
                    if npcModel == specificTargetModel then
                        modelMatches = true
                    end
                else
                    modelMatches = true
                end

                if modelMatches then
                    table.insert(npcsToKill, npc)
                    totalFound = totalFound + 1
                end
            end
        end

        if totalFound == 0 then
            if IsValid(ply) then
                ChatOnlyPrint(ply, "\x07", "❌ No " .. targetClass .. " NPCs" .. (specificTargetModel and " with model " .. specificTargetModel or "") .. " found to kill!")
                ply:SendLua("surface.PlaySound(\"buttons/button2.wav\")")
            end
            return
        end

        pendingRemovals = totalFound

        -- Kill logic
        for _, npc in ipairs(npcsToKill) do
            local dissolverName = "npc_classkill_diss_" .. CurTime() .. "_" .. math.random(10000)
            
            local npcOriginalName = npc:GetName()
            if npcOriginalName == "" then
                npc:SetName("temp_dissolve_target_" .. CurTime() .. "_" .. math.random(10000))
            end

            local dissolver = ents.Create("env_entity_dissolver")
            if IsValid(dissolver) then
                dissolver:SetName(dissolverName)
                dissolver:SetKeyValue("dissolvetype", tostring(dissolveType))
                dissolver:Spawn()
                dissolver:Activate()
                
                dissolver:Fire("Dissolve", npc:GetName(), 0)
                
                timer.Simple(0.2, function()
                    if IsValid(npc) then
                        npc:Remove()
                    end
                    
                    if IsValid(dissolver) then
                        dissolver:Remove()
                    end

                    removedCount = removedCount + 1
                    pendingRemovals = pendingRemovals - 1

                    if pendingRemovals == 0 then
                        if removedCount == 0 then
                            ChatOnlyPrint(ply, "\x07", "⚠️ Failed to kill " .. targetClass .. (specificTargetModel and " with model " .. specificTargetModel or "") .. "!")
                        else
                            ChatOnlyPrint(ply, "\x05", string.format("✅ Killed %d/%d %s%s", 
                                removedCount, 
                                totalFound, 
                                targetClass, 
                                (specificTargetModel and " (model: " .. specificTargetModel .. ")" or "")
                            ))
                        end

                        if IsValid(ply) then
                            if removedCount > 0 then
                                ply:SendLua("surface.PlaySound(\"buttons/button14.wav\")")
                            else
                                ply:SendLua("surface.PlaySound(\"buttons/button2.wav\")")
                            end
                        end
                    end
                end)
            else
                if IsValid(npc) then
                    npc:Remove()
                end
                pendingRemovals = pendingRemovals - 1
                removedCount = removedCount + 1
                
                if pendingRemovals == 0 then
                    ChatOnlyPrint(ply, "\x05", string.format("✅ Killed %d/%d %s%s", 
                        removedCount, 
                        totalFound, 
                        targetClass, 
                        (specificTargetModel and " (model: " .. specificTargetModel .. ")" or "")
                    ))
                    if IsValid(ply) then
                        ply:SendLua("surface.PlaySound(\"buttons/button14.wav\")")
                    end
                end
            end
        end
    end

    -- Console command for npcreplace
    concommand.Add("npcreplace", function(ply, cmd, args)
        local parsedArgs = ParseReplaceArgs(args)

        if not parsedArgs or not parsedArgs.newClass then
            ChatOnlyPrint(ply, "\x07", "❗ Usage: npcreplace <target_class> [target_model (optional)] <new_class> [new_model (optional)] [spawn_weapon (optional, 'none' for no weapon)] [health (optional)]")
            ChatOnlyPrint(ply, "\x07", "💡 Example 1: npcreplace npc_combine_s npc_metropolice")
            ChatOnlyPrint(ply, "\x07", "💡 Example 2: npcreplace npc_combine_s models/combine_soldier.mdl npc_metropolice models/combine_elite.mdl")
            ChatOnlyPrint(ply, "\x07", "💡 Example 3: npcreplace npc_citizen models/humans/group01/male_01.mdl npc_citizen models/humans/group01/female_01.mdl weapon_smg1")
            ChatOnlyPrint(ply, "\x07", "💡 Example 4: npcreplace npc_zombie npc_antlion weapon_shotgun")
            ChatOnlyPrint(ply, "\x07", "💡 Example 5: npcreplace npc_combine_s npc_metropolice weapon_smg1 500")
            ChatOnlyPrint(ply, "\x07", "💡 Example 6: npcreplace npc_zombie npc_antlion 1000")
            ChatOnlyPrint(ply, "\x07", "💡 Example 7: npcreplace npc_combine_s npc_metropolice none")
            ChatOnlyPrint(ply, "\x07", "💡 For custom models, use the FULL model path, e.g., models/mymod/mymodel.mdl")
            return
        end

        ReplaceNPCs(parsedArgs.targetClass, parsedArgs.targetModel, parsedArgs.newClass, parsedArgs.newModel, parsedArgs.spawnWeapon, parsedArgs.spawnHealth, ply)
    end, NPReplaceAutocomplete)

    -- Chat command for npcreplace
    hook.Add("PlayerSay", "NPCReplacerChatCommand", function(ply, text)
        local lowerText = string.lower(text)
        if lowerText:sub(1, 12) == "!npcreplace " then
            local parts = string.Explode(" ", text:sub(13))
            
            local parsedArgs = ParseReplaceArgs(parts)

            if not parsedArgs or not parsedArgs.newClass then
                ChatOnlyPrint(ply, "\x07", "❗ Usage: !npcreplace <target_class> [target_model (optional)] <new_class> [new_model (optional)] [spawn_weapon (optional, 'none' for no weapon)] [health (optional)]")
                ChatOnlyPrint(ply, "\x07", "💡 Example 1: !npcreplace npc_combine_s npc_metropolice")
                ChatOnlyPrint(ply, "\x07", "💡 Example 2: !npcreplace npc_combine_s models/combine_soldier.mdl npc_metropolice models/combine_elite.mdl")
                ChatOnlyPrint(ply, "\x07", "💡 Example 3: !npcreplace npc_citizen models/humans/group01/male_01.mdl npc_citizen models/humans/group01/female_01.mdl weapon_smg1")
                ChatOnlyPrint(ply, "\x07", "💡 Example 4: !npcreplace npc_zombie npc_antlion weapon_shotgun")
                ChatOnlyPrint(ply, "\x07", "💡 Example 5: !npcreplace npc_combine_s npc_metropolice weapon_smg1 500")
                ChatOnlyPrint(ply, "\x07", "💡 Example 6: !npcreplace npc_zombie npc_antlion 1000")
                ChatOnlyPrint(ply, "\x07", "💡 Example 7: !npcreplace npc_combine_s npc_metropolice none")
                ChatOnlyPrint(ply, "\x07", "💡 For custom models, use the FULL model path, e.g., models/mymod/mymodel.mdl")
                return ""
            end
            
            ReplaceNPCs(parsedArgs.targetClass, parsedArgs.targetModel, parsedArgs.newClass, parsedArgs.newModel, parsedArgs.spawnWeapon, parsedArgs.spawnHealth, ply)
            return ""
        end
    end)

    -- Console command for npcclasskill
    concommand.Add("npcclasskill", function(ply, cmd, args)
        if #args < 1 then
            ChatOnlyPrint(ply, "\x07", "❗ Usage: npcclasskill <target_class> [target_model (optional)]")
            ChatOnlyPrint(ply, "\x07", "💡 Example 1: npcclasskill npc_zombie")
            ChatOnlyPrint(ply, "\x07", "💡 Example 2: npcclasskill npc_combine_s models/combine_soldier.mdl")
            ChatOnlyPrint(ply, "\x07", "⛔ Note: Restricted classes cannot be killed")
            return
        end
        
        local targetClass = args[1]
        local targetModel = (#args >= 2) and args[2] or nil
        
        -- Validate if second argument is a model path
        if targetModel and not IsModelPath(targetModel) then
            targetModel = nil
        end
        
        RemoveNPCs(targetClass, targetModel, ply)
    end, NPCClassKillAutocomplete)

    -- Chat command for npcclasskill
    hook.Add("PlayerSay", "NPCClassKillChatCommand", function(ply, text)
        local lowerText = string.lower(text)
        if lowerText:sub(1, 13) == "!npcclasskill " then
            local parts = string.Explode(" ", text:sub(14))
            
            if #parts < 1 then
                ChatOnlyPrint(ply, "\x07", "❗ Usage: !npcclasskill <target_class> [target_model (optional)]")
                ChatOnlyPrint(ply, "\x07", "💡 Example 1: !npcclasskill npc_zombie")
                ChatOnlyPrint(ply, "\x07", "💡 Example 2: !npcclasskill npc_combine_s models/combine_soldier.mdl")
                ChatOnlyPrint(ply, "\x07", "⛔ Note: Restricted classes cannot be killed")
                return ""
            end
            
            local targetClass = parts[1]
            local targetModel = (#parts >= 2) and parts[2] or nil
            
            -- Validate if second argument is a model path
            if targetModel and not IsModelPath(targetModel) then
                targetModel = nil
            end
            
            RemoveNPCs(targetClass, targetModel, ply)
            return ""
        end
    end)

    ----------------------------------------------------------------------
    -- NPC Check functionality
    ----------------------------------------------------------------------
    local function CheckNPCs(ply)
        local npcCounts = {} -- Stores counts for each class
        local npcModelCounts = {} -- Stores counts for each class + model combination

        -- Iterate over all entities on the server
        for _, ent in ipairs(ents.GetAll()) do
            -- Check for standard NPCs (IsNPC) and DrGBase nextbots (IsNextBot + IsDrGNextbot)
            -- DrGBase NPCs are nextbots rather than SNPCs, so IsNPC() returns false for them.
            -- We check ent.IsDrGNextbot to avoid counting non-NPC nextbot entities.
            if IsValid(ent) and (ent:IsNPC() or (ent:IsNextBot() and ent.IsDrGNextbot)) then
                local class = ent:GetClass()
                -- NEW: Ignore restricted NPC classes for checking
                if RESTRICTED_NPC_CLASSES[string.lower(class)] then
                    continue -- Skip this NPC
                end

                local model = ent:GetModel() or "N/A" -- Get model, default to "N/A" if nil

                -- Count by class
                npcCounts[class] = (npcCounts[class] or 0) + 1

                -- Count by class + model
                if not npcModelCounts[class] then
                    npcModelCounts[class] = {}
                end
                npcModelCounts[class][model] = (npcModelCounts[class][model] or 0) + 1
            end
        end

        local totalNPCs = 0
        for class, count in pairs(npcCounts) do
            totalNPCs = totalNPCs + count
        end

        if totalNPCs == 0 then
            ChatOnlyPrint(ply, "\x07", "❌ No NPCs found on the map.")
            if IsValid(ply) then ply:SendLua("surface.PlaySound(\"buttons/button2.wav\")") end
            return
        end

        -- Prepare messages for console (detailed breakdown)
        local consoleMessages = {}
        table.insert(consoleMessages, "NPC Breakdown - " .. totalNPCs .. " total:")
        for class, models in sortedPairs(npcModelCounts) do -- sortedPairs for consistent output
            table.insert(consoleMessages, "  " .. class .. " (" .. npcCounts[class] .. " total):")
            for model, count in sortedPairs(models) do
                table.insert(consoleMessages, "    - " .. model .. ": " .. count)
            end
        end

        -- Prepare messages for chat (summary only)
        -- chat.AddText via SendLua has practical limits, so we split the summary
        -- into multiple messages. Each entry is "class: count" separated by commas.
        -- We accumulate entries until adding another would exceed the limit, then send
        -- the current line and start a new one.
        local maxBytes = 200 -- Conservative limit for SendLua payload
        local chatLines = {}
        local currentLine = ""
        for class, count in sortedPairs(npcCounts) do
            local entry = class .. ": " .. count
            if currentLine == "" then
                currentLine = entry
            else
                local candidate = currentLine .. ", " .. entry
                if #candidate > maxBytes then
                    -- Current line is full, save it and start a new one
                    table.insert(chatLines, currentLine)
                    currentLine = entry
                else
                    currentLine = candidate
                end
            end
        end
        if currentLine ~= "" then
            table.insert(chatLines, currentLine)
        end

        -- Print to console
        for _, msg in ipairs(consoleMessages) do
            print(msg)
        end

        -- Send summary to player's chat only (not console) split across multiple messages if needed
        if IsValid(ply) then
            ChatOnlyPrint(ply, "\x06", "NPC Summary - " .. totalNPCs .. " total:")
            for _, line in ipairs(chatLines) do
                ChatOnlyPrint(ply, "\x03", line)
            end
            ply:SendLua("surface.PlaySound(\"buttons/combine_button1.wav\")")
        end
    end

    -- Utility function to sort table keys for consistent output
    function sortedPairs(t)
        local keys = {}
        for k in pairs(t) do table.insert(keys, k) end
        table.sort(keys)
        local i = 0
        return function()
            i = i + 1
            if keys[i] then
                return keys[i], t[keys[i]]
            end
        end
    end

    -- Console command for npccheck
    concommand.Add("npccheck", function(ply, cmd, args)
        CheckNPCs(ply)
    end)

    -- Chat command for npccheck
    hook.Add("PlayerSay", "NPCCheckChatCommand", function(ply, text)
        local lowerText = string.lower(text)
        if lowerText == "!npccheck" then
            CheckNPCs(ply)
            return "" -- Consume the chat command
        end
    end)
end
