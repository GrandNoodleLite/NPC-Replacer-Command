-- NPC Replacer Addon (Final Working Version)
-- Save as: addons/npc_replacer/lua/autorun/server/npc_replacer.lua

if SERVER then
    -- Define a table of restricted NPC classes
    local RESTRICTED_NPC_CLASSES = {
        ["npc_enemyfinder"] = true, -- Prevent this class from being targeted or spawned
    }

    -- Helper function to get colored chat messages
    local function GetColoredChatMsg(colorCode, message)
        return colorCode .. message .. "\x08" -- \x08 is default white to reset color
    end

    -- Modified function signature to include spawnWeapon
    local function ReplaceNPCs(targetClass, targetModel, newClass, newModel, spawnWeapon, ply)
        -- NEW: Check for restricted classes
        if RESTRICTED_NPC_CLASSES[string.lower(targetClass)] then
            local msg = GetColoredChatMsg("\x04", "❌ Error: Cannot target '" .. targetClass .. "'. This NPC class is restricted.")
            print(msg)
            if IsValid(ply) then ply:ChatPrint(msg) ply:SendLua("surface.PlaySound(\"buttons/button2.wav\")") end
            return
        end
        if RESTRICTED_NPC_CLASSES[string.lower(newClass)] then
            local msg = GetColoredChatMsg("\x04", "❌ Error: Cannot spawn '" .. newClass .. "'. This NPC class is restricted.")
            print(msg)
            if IsValid(ply) then ply:ChatPrint(msg) ply:SendLua("surface.PlaySound(\"buttons/button2.wav\")") end
            return
        end

        local dissolveType = 0 -- 0 = Energy, 1 = Heavy, 2 = Light
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
        if spawnWeapon and spawnWeapon ~= "" then
            specificSpawnWeapon = string.lower(spawnWeapon)
            print("New NPCs will spawn with weapon: " .. specificSpawnWeapon)
        end

        ----------------------------------------------------------------------
        -- Pre-check if the new NPC class and model can be spawned
        ----------------------------------------------------------------------
        local canSpawnNewNPC = false
        local dummyNPC = ents.Create(newClass)
        if IsValid(dummyNPC) then
            if specificNewModel then
                -- Attempt to set the model and check if it's valid
                dummyNPC:SetModel(specificNewModel)
                if dummyNPC:GetModel() == specificNewModel then -- Check if the model actually took
                    canSpawnNewNPC = true
                else
                    print(GetColoredChatMsg("\x04", "❌ Error: New model '" .. specificNewModel .. "' for class '" .. newClass .. "' could not be applied. Check model path."))
                    if IsValid(ply) then ply:ChatPrint(GetColoredChatMsg("\x04", "❌ Error: New model '" .. specificNewModel .. "' for class '" .. newClass .. "' could not be applied.")) end
                end
            else
                -- If no specific model is given, assume default model works
                canSpawnNewNPC = true
            end
            dummyNPC:Remove() -- Remove the dummy NPC immediately
        else
            print(GetColoredChatMsg("\x04", "❌ Error: New NPC class '" .. newClass .. "' could not be created. Check class name."))
            if IsValid(ply) then ply:ChatPrint(GetColoredChatMsg("\x04", "❌ Error: New NPC class '" .. newClass .. "' could not be created.")) end
        end

        if not canSpawnNewNPC then
            local msg = GetColoredChatMsg("\x04", "❌ Replacement aborted due to invalid new NPC class or model.")
            print(msg)
            if IsValid(ply) then
                ply:ChatPrint(msg)
                ply:SendLua("surface.PlaySound(\"buttons/button2.wav\")")
            end
            return
        end
        ----------------------------------------------------------------------

        -- Collect NPCs first, filtering by model if specified
        local npcsToReplace = {}
        for _, npc in ipairs(ents.FindByClass(targetClass)) do
            if IsValid(npc) then
                local npcModel = npc:GetModel()
                if type(npcModel) ~= "string" or npcModel == "" then
                    print("Skipping invalid NPC model for " .. targetClass .. ": " .. tostring(npcModel))
                    continue -- Skip this NPC if its model is not a valid string
                end
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
            local msg = GetColoredChatMsg("\x07", "❌ No " .. targetClass .. " NPCs" .. (specificTargetModel and " with model " .. specificTargetModel or "") .. " found!")
            print(msg)
            if IsValid(ply) then
                ply:ChatPrint(msg)
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
            local npcAng = npc:GetAngles()

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
                        
                        if specificNewModel then
                            newNPC:SetModel(specificNewModel)
                        end

                        newNPC:Spawn()
                        newNPC:Activate()
                        newNPC:SetCreator(ply)

                        if specificSpawnWeapon then
                            newNPC:Give(specificSpawnWeapon)
                        end

                        replacedCount = replacedCount + 1
                    end
                    
                    if IsValid(dissolver) then
                        dissolver:Remove()
                    end

                    pendingReplacements = pendingReplacements - 1

                    if pendingReplacements == 0 then
                        local msg
                        local weaponInfo = specificSpawnWeapon and (" with " .. specificSpawnWeapon) or ""
                        if replacedCount == 0 then
                            msg = GetColoredChatMsg("\x07", "⚠️ Failed to replace " .. targetClass .. (specificTargetModel and " with model " .. specificTargetModel or "") .. "!")
                        else
                            msg = GetColoredChatMsg("\x05", string.format("✅ Replaced %d/%d %s%s with %s%s%s", 
                                replacedCount, 
                                totalFound, 
                                targetClass, 
                                (specificTargetModel and " (model: " .. specificTargetModel .. ")" or ""), 
                                newClass,
                                (specificNewModel and " (model: " .. specificNewModel .. ")" or ""),
                                weaponInfo
                            ))
                        end

                        print(msg)
                        if IsValid(ply) then
                            ply:ChatPrint(msg)
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
                pendingReplacements = pendingReplacements - 1 -- Fix typo: changed pendingRepllemts to pendingReplacements
                if pendingReplacements == 0 then
                    local msg
                    local weaponInfo = specificSpawnWeapon and (" with " .. specificSpawnWeapon) or ""
                    if replacedCount == 0 then
                        msg = GetColoredChatMsg("\x07", "⚠️ Failed to replace " .. targetClass .. (specificTargetModel and " with model " .. specificTargetModel or "") .. "!")
                    else
                        msg = GetColoredChatMsg("\x05", string.format("✅ Replaced %d/%d %s%s with %s%s%s", 
                            replacedCount, 
                            totalFound, 
                            targetClass, 
                            (specificTargetModel and " (model: " .. specificTargetModel .. ")" or ""), 
                            newClass,
                            (specificNewModel and " (model: " .. specificNewModel .. ")" or ""),
                            weaponInfo
                        ))
                    end

                    print(msg)
                    if IsValid(ply) then
                        ply:ChatPrint(msg)
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

    -- Helper function to check if a string looks like a model path
    local function IsModelPath(str)
        return string.find(string.lower(str), "models/") and string.find(string.lower(str), ".mdl$")
    end

    -- Helper function to parse arguments (for npcreplace command)
    local function ParseReplaceArgs(args)
        local parsed = {
            targetClass = args[1],
            targetModel = nil,
            newClass = nil,
            newModel = nil,
            spawnWeapon = nil
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

        if args[currentArgIndex] then
            parsed.spawnWeapon = args[currentArgIndex]
        end

        return parsed
    end


    -- Console command for npcreplace
    concommand.Add("npcreplace", function(ply, cmd, args)
        local parsedArgs = ParseReplaceArgs(args)

        if not parsedArgs or not parsedArgs.newClass then
            ply:ChatPrint(GetColoredChatMsg("\x07", "❗ Usage: npcreplace <target_class> [target_model (optional)] <new_class> [new_model (optional)] [spawn_weapon (optional)]"))
            ply:ChatPrint(GetColoredChatMsg("\x07", "💡 Example 1: npcreplace npc_combine_s npc_metropolice"))
            ply:ChatPrint(GetColoredChatMsg("\x07", "💡 Example 2: npcreplace npc_combine_s models/combine_soldier.mdl npc_metropolice models/combine_elite.mdl"))
            ply:ChatPrint(GetColoredChatMsg("\x07", "💡 Example 3: npcreplace npc_citizen models/player/group01/male_01.mdl npc_citizen models/player/group01/female_01.mdl weapon_smg1"))
            ply:ChatPrint(GetColoredChatMsg("\x07", "💡 Example 4: npcreplace npc_zombie npc_antlion weapon_shotgun"))
            ply:ChatPrint(GetColoredChatMsg("\x07", "💡 For custom models, use the FULL model path, e.g., models/mymod/mymodel.mdl"))
            ply:ChatPrint(GetColoredChatMsg("\x07", "⛔ Note: npc_enemyfinder is a restricted class and cannot be used."))
            return
        end

        ReplaceNPCs(parsedArgs.targetClass, parsedArgs.targetModel, parsedArgs.newClass, parsedArgs.newModel, parsedArgs.spawnWeapon, ply)
    end)

    -- Chat command for npcreplace
    hook.Add("PlayerSay", "NPCReplacerChatCommand", function(ply, text)
        local lowerText = string.lower(text)
        if lowerText:sub(1, 12) == "!npcreplace " then
            local parts = string.Explode(" ", text:sub(13))
            
            local parsedArgs = ParseReplaceArgs(parts)

            if not parsedArgs or not parsedArgs.newClass then
                ply:ChatPrint(GetColoredChatMsg("\x07", "❗ Usage: !npcreplace <target_class> [target_model (optional)] <new_class> [new_model (optional)] [spawn_weapon (optional)]"))
                ply:ChatPrint(GetColoredChatMsg("\x07", "💡 Example 1: !npcreplace npc_combine_s npc_metropolice"))
                ply:ChatPrint(GetColoredChatMsg("\x07", "💡 Example 2: !npcreplace npc_combine_s models/combine_soldier.mdl npc_metropolice models/combine_elite.mdl"))
                ply:ChatPrint(GetColoredChatMsg("\x07", "💡 Example 3: !npcreplace npc_citizen models/player/group01/male_01.mdl npc_citizen models/player/group01/female_01.mdl weapon_smg1"))
                ply:ChatPrint(GetColoredChatMsg("\x07", "💡 Example 4: !npcreplace npc_zombie npc_antlion weapon_shotgun"))
                ply:ChatPrint(GetColoredChatMsg("\x07", "💡 For custom models, use the FULL model path, e.g., models/mymod/mymodel.mdl"))
                ply:ChatPrint(GetColoredChatMsg("\x07", "⛔ Note: npc_enemyfinder is a restricted class and cannot be used."))
                return ""
            end
            
            ReplaceNPCs(parsedArgs.targetClass, parsedArgs.targetModel, parsedArgs.newClass, parsedArgs.newModel, parsedArgs.spawnWeapon, ply)
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
            if IsValid(ent) and ent:IsNPC() then -- Ensure IsValid check first
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
            local msg = GetColoredChatMsg("\x07", "ℹ️ No non-restricted NPCs found on the map.")
            print(msg) -- Print to console
            if IsValid(ply) then ply:ChatPrint(msg) ply:SendLua("buttons/button2.wav") end
            return
        end

        -- Prepare messages for console (detailed breakdown)
        local consoleMessages = {}
        table.insert(consoleMessages, "📊 Current NPC Breakdown (excluding restricted classes) - " .. totalNPCs .. " total:")

        for class, models in sortedPairs(npcModelCounts) do -- sortedPairs for consistent output
            table.insert(consoleMessages, "  " .. class .. " (" .. npcCounts[class] .. " total):")
            for model, count in sortedPairs(models) do
                table.insert(consoleMessages, "    - " .. model .. ": " .. count)
            end
        end

        -- Prepare messages for chat (summary only)
        local chatSummary = GetColoredChatMsg("\x06", "📊 Current NPC Summary (excluding restricted classes) - " .. totalNPCs .. " total:") .. "\n"
        local classSummaries = {}
        for class, count in sortedPairs(npcCounts) do
            table.insert(classSummaries, class .. ": " .. count)
        end
        chatSummary = chatSummary .. GetColoredChatMsg("\x03", table.concat(classSummaries, GetColoredChatMsg("\x08", ", ")))

        -- Print to console
        for _, msg in ipairs(consoleMessages) do
            print(msg)
        end

        -- Send summary to player's chat
        if IsValid(ply) then
            ply:ChatPrint(chatSummary)
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