if game.PlaceId ~= 95630541662383 then
    warn("Failed to load: This script only supports World Fighter Simulator")
    return
end

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
if not WindUI then
    warn("Failed to load UI! Please check your internet or try restarting your Executor")
    return
end

WindUI:SetNotificationLower(true)

WindUI:AddTheme({
    Name                         = "GhostHub",
    Accent                       = Color3.fromHex("#1a0a0a"),
    Background                   = Color3.fromHex("#0d0d0d"),
    BackgroundTransparency        = 0,
    Outline                      = Color3.fromHex("#c0392b"),
    Text                         = Color3.fromHex("#f0f0f0"),
    Placeholder                  = Color3.fromHex("#7a3030"),
    Button                       = Color3.fromHex("#7f1d1d"),
    Icon                         = Color3.fromHex("#e87070"),
    Hover                        = Color3.fromHex("#f0f0f0"),
    WindowBackground             = Color3.fromHex("#0d0d0d"),
    WindowShadow                 = Color3.fromHex("#000000"),
    DialogBackground             = Color3.fromHex("#0d0d0d"),
    DialogBackgroundTransparency  = 0,
    DialogTitle                  = Color3.fromHex("#f0f0f0"),
    DialogContent                = Color3.fromHex("#cccccc"),
    DialogIcon                   = Color3.fromHex("#e87070"),
    WindowTopbarButtonIcon        = Color3.fromHex("#e87070"),
    WindowTopbarTitle            = Color3.fromHex("#f0f0f0"),
    WindowTopbarAuthor           = Color3.fromHex("#cccccc"),
    WindowTopbarIcon             = Color3.fromHex("#f0f0f0"),
    TabBackground                = Color3.fromHex("#1a0a0a"),
    TabTitle                     = Color3.fromHex("#f0f0f0"),
    TabIcon                      = Color3.fromHex("#e87070"),
    ElementBackground            = Color3.fromHex("#1f0d0d"),
    ElementTitle                 = Color3.fromHex("#f0f0f0"),
    ElementDesc                  = Color3.fromHex("#aaaaaa"),
    ElementIcon                  = Color3.fromHex("#e87070"),
    PopupBackground              = Color3.fromHex("#0d0d0d"),
    PopupBackgroundTransparency   = 0,
    PopupTitle                   = Color3.fromHex("#f0f0f0"),
    PopupContent                 = Color3.fromHex("#cccccc"),
    PopupIcon                    = Color3.fromHex("#e87070"),
    Toggle                       = Color3.fromHex("#7f1d1d"),
    ToggleBar                    = Color3.fromHex("#e84040"),
    Checkbox                     = Color3.fromHex("#7f1d1d"),
    CheckboxIcon                 = Color3.fromHex("#f0f0f0"),
    Slider                       = Color3.fromHex("#7f1d1d"),
    SliderThumb                  = Color3.fromHex("#e84040"),
})

local Window = WindUI:CreateWindow({
    Title                       = "World Fighter — Ghost Hub",
    Icon                        = "rbxassetid://110552700896064",
    Author                      = "by TEN",
    Folder                      = "GhostHub/WFS",
    Size                        = UDim2.fromOffset(620, 500),
    MinSize                     = Vector2.new(560, 380),
    MaxSize                     = Vector2.new(860, 580),
    Transparent                 = true,
    Theme                       = "GhostHub",
    AccentColor                 = Color3.fromHex("#c0392b"),
    Resizable                   = true,
    SideBarWidth                = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar               = true,
    ScrollBarEnabled            = false,
})

Window:Tag({ Title = "v0.0.6",   Icon = "",      Color = Color3.fromHex("#30ff6a"), Radius = 0 })
Window:Tag({ Title = "GhostHub", Icon = "crown", Color = Color3.fromHex("#c0392b"), Radius = 6 })

task.defer(function() Window:SetToggleKey(Enum.KeyCode.LeftControl) end)

local FarmTab       = Window:Tab({ Title = "Farming",     Icon = "swords"    })
local GamemodeTab   = Window:Tab({ Title = "Gamemode",    Icon = "gamepad-2" })
local QuestTab      = Window:Tab({ Title = "Quest",       Icon = "list"      })
local SummonTab     = Window:Tab({ Title = "Summon",      Icon = "star"      })
local UnitTab       = Window:Tab({ Title = "Units",       Icon = "users"     })
local GachaTab      = Window:Tab({ Title = "Gacha",       Icon = "dices"     })
local UpgradeTab    = Window:Tab({ Title = "Upgrade",     Icon = "arrow-up"  })
local AutoDeleteTab = Window:Tab({ Title = "Auto Delete", Icon = "trash"     })
local MiscTab       = Window:Tab({ Title = "Misc",        Icon = "gift"      })
local SettingTab    = Window:Tab({ Title = "Settings",    Icon = "cog"       })

-- ============================================================
--  CONFIG SYSTEM
-- ============================================================
local HttpService = game:GetService("HttpService")
local Options     = {}

local function GetConfigPath()
    return "WFS_GH/" .. tostring(game.Players.LocalPlayer.UserId) .. "_WFS.json"
end

local lastSaveRequest = 0
local function SaveConfig()
    lastSaveRequest = tick()
    local snap = lastSaveRequest
    task.delay(1, function()
        if lastSaveRequest ~= snap then return end
        if not (writefile and makefolder) then return end
        local path   = GetConfigPath()
        local folder = path:match("(.+)/")
        if not isfolder(folder) then
            local cur = ""
            for _, p in ipairs(folder:split("/")) do
                cur = cur .. p
                if not isfolder(cur) then makefolder(cur) end
                cur = cur .. "/"
            end
        end
        writefile(path, HttpService:JSONEncode(Options))
    end)
end

local function LoadConfig()
    if not (readfile and isfile) then return end
    local path = GetConfigPath()
    if isfile(path) then
        local ok, result = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
        if ok and result then
            for k, v in pairs(result) do Options[k] = v end
        end
    end
end
LoadConfig()

-- ============================================================
--  SERVICES & GLOBALS
-- ============================================================
local Players            = game:GetService("Players")
local RS                 = game:GetService("ReplicatedStorage")
local player             = Players.LocalPlayer
local dataRemoteEvent    = RS:WaitForChild("BridgeNet"):WaitForChild("dataRemoteEvent")
local serverEnemiesWorld = workspace:WaitForChild("Server"):WaitForChild("Enemies"):WaitForChild("World")

local function fireRemote(args) dataRemoteEvent:FireServer(unpack(args)) end

-- ============================================================
--  STATE FLAGS
-- ============================================================
local isAttacking          = false
local isAutoFarm           = false
local isAutoEquip          = false
local isAutoAwaken         = false
local isAutoSummon         = false
local isAutoQuest          = false
local isAutoReward         = false
local isAutoAchieve        = false
local isAutoDailyReward    = false
local isAutoGacha          = false
local isAutoFruit          = false
local isAutoSword          = false
local isAutoRollRace       = false
local isAutoFightStyle     = false
local isAutoKiProgression  = false
local isAutoDragonDefense  = false
local isAutoAura           = false
local isAutoDemonlord      = false
local isAutoRollFightStyle = false
local isAutoRollClass      = false
local isAutoRollSlimePower = false
local isAutoPrimordial     = false
local isAutoTempestInvasion = false
local isAutoDelete         = false

local achieveConnections = {}
local isClaimingAchieve  = false

local isAutoTrial      = false
local isAutoLeaveTrial = false
local trialTargetWave  = Options.LeaveAtWave or 10
local preTrialWorld    = ""
local preTrialZone     = 1
local isInsideTrial    = false

local selectedFarmEnemies = Options.SelectedEnemies or {}
local selectedStar        = Options.SelectedStar     or "Dressrosa"
local selectedQuest       = Options.SelectedQuest    or ""

-- ============================================================
--  OMNI DATA
-- ============================================================
local Omni = require(RS:WaitForChild("Omni"))

local function getKeyCount(keyName)
    local ok, n = pcall(function() return Omni.Data.Inventory.Items[keyName] or 0 end)
    return (ok and tonumber(n)) or 0
end

-- ============================================================
--  HELPERS — WORLD / ZONE / ENEMY
-- ============================================================
local function getCurrentWorldName()
    local char  = player.Character
    local myHRP = char and char:FindFirstChild("HumanoidRootPart")
    if not myHRP then return "", 1 end
    local myPos, shortestDist, bestWorld, bestZone = myHRP.Position, math.huge, "", 1
    for _, worldMap in ipairs(serverEnemiesWorld:GetChildren()) do
        for _, group in ipairs(worldMap:GetChildren()) do
            local e = group:FindFirstChildWhichIsA("Model") or group:FindFirstChildWhichIsA("BasePart")
            if e then
                local pos = e:IsA("Model") and e:GetPivot().Position or e.Position
                if pos then
                    local d = (pos - myPos).Magnitude
                    if d < shortestDist then
                        shortestDist = d
                        bestWorld    = worldMap.Name
                        bestZone     = tonumber(group.Name) or 1
                    end
                end
            end
        end
    end
    return bestWorld, bestZone
end

local DifficultyRanks = { EASY=1, MEDIUM=2, HARD=3, INSANE=4, BOSS=5, SECRET=6 }

local function getEnemyDifficulty(enemyName)
    local score = 0
    local ok, subtitle = pcall(function()
        return workspace.Client.Enemies[enemyName].Head.EnemyHUD.Main.Subtitle
    end)
    if ok and subtitle then
        local raw = ""
        if subtitle:IsA("TextLabel") or subtitle:IsA("TextBox") then
            raw = subtitle.ContentText ~= "" and subtitle.ContentText or subtitle.Text
        elseif subtitle:IsA("StringValue") then raw = subtitle.Value end
        local up = string.upper(tostring(raw))
        for d, s in pairs(DifficultyRanks) do
            if string.find(up, d) and s > score then score = s end
        end
        if score == 0 then
            local n = string.match(up, "%d+")
            if n then score = tonumber(n) end
        end
    end
    return score
end

local function getWorldsList()
    local t = {}
    for _, w in ipairs(serverEnemiesWorld:GetChildren()) do table.insert(t, w.Name) end
    table.sort(t)
    return t
end

local function getZonesList(worldName)
    local t = {}
    local w = serverEnemiesWorld:FindFirstChild(tostring(worldName))
    if w then for _, g in ipairs(w:GetChildren()) do table.insert(t, g.Name) end end
    table.sort(t, function(a, b) return (tonumber(a) or 0) < (tonumber(b) or 0) end)
    return t
end

local function getEnemiesList(worldName, zoneName)
    local t, d = {}, {}
    local w = serverEnemiesWorld:FindFirstChild(tostring(worldName))
    if w then
        local z = w:FindFirstChild(tostring(zoneName))
        if z then
            for _, e in ipairs(z:GetChildren()) do
                if not d[e.Name] then d[e.Name]=true table.insert(t, e.Name) end
            end
        end
    end
    table.sort(t, function(a, b)
        local da, db = getEnemyDifficulty(a), getEnemyDifficulty(b)
        if da ~= db then return da > db end
        return a < b
    end)
    return t
end

local function scanTrialFolder(folder, bestTarget, bestID, shortestDist, myPos)
    for _, child in ipairs(folder:GetChildren()) do
        local sID, isDead, hp = child:GetAttribute("ID"), child:GetAttribute("Died"), child:GetAttribute("Health")
        if sID and not isDead and (not hp or tonumber(hp) > 0) then
            local tp = child:IsA("Model") and child:GetPivot().Position or (child:IsA("BasePart") and child.Position)
            if tp then
                local d = (tp - myPos).Magnitude
                if d < shortestDist then shortestDist=d bestTarget=child bestID=sID end
            end
        elseif child:IsA("Folder") or child:IsA("Model") then
            for _, sub in ipairs(child:GetChildren()) do
                local s2, d2, h2 = sub:GetAttribute("ID"), sub:GetAttribute("Died"), sub:GetAttribute("Health")
                if s2 and not d2 and (not h2 or tonumber(h2) > 0) then
                    local tp2 = sub:IsA("Model") and sub:GetPivot().Position or (sub:IsA("BasePart") and sub.Position)
                    if tp2 then
                        local d = (tp2 - myPos).Magnitude
                        if d < shortestDist then shortestDist=d bestTarget=sub bestID=s2 end
                    end
                end
            end
        end
    end
    return bestTarget, bestID, shortestDist
end

local function getValidTarget()
    local currentWorld = getCurrentWorldName()
    if currentWorld == "" then return nil, nil end
    local targetWorld = serverEnemiesWorld:FindFirstChild(currentWorld)
    if not targetWorld then return nil, nil end
    local myPos = (player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position) or Vector3.zero
    local bestTarget, bestID, highestDiff, shortestDist = nil, nil, -1, math.huge
    for _, group in ipairs(targetWorld:GetChildren()) do
        for _, e in ipairs(group:GetChildren()) do
            local isDead, hp = e:GetAttribute("Died"), e:GetAttribute("Health")
            if not isDead and (not hp or tonumber(hp) > 0) then
                local allowed = (#selectedFarmEnemies == 0)
                if not allowed then
                    for _, n in ipairs(selectedFarmEnemies) do if e.Name==n then allowed=true break end end
                end
                if allowed then
                    local sID = e:GetAttribute("ID")
                    if sID then
                        local pos = e:IsA("Model") and e:GetPivot().Position or (e:IsA("BasePart") and e.Position)
                        if pos then
                            local dist = (pos - myPos).Magnitude
                            local diff = getEnemyDifficulty(e.Name)
                            if diff > highestDiff or (diff == highestDiff and dist < shortestDist) then
                                highestDiff=diff shortestDist=dist bestTarget=e bestID=sID
                            end
                        end
                    end
                end
            end
        end
    end
    return bestTarget, bestID
end

-- ============================================================
--  HELPERS — QUEST
-- ============================================================
local questsFolder = RS:FindFirstChild("Omni") and RS.Omni.Shared.Quests.Main
local questModules, questNames = {}, {}
if questsFolder then
    for _, c in pairs(questsFolder:GetChildren()) do
        questModules[c.Name] = c
        table.insert(questNames, c.Name)
    end
    table.sort(questNames)
    if selectedQuest == "" then selectedQuest = questNames[1] or "" end
end

local function getQuestData(name)
    if not questModules[name] then return nil end
    local ok, m = pcall(function() return require(questModules[name]) end)
    return (ok and m) and m or nil
end

local function getSlotProgress(slot)
    local ok, title = pcall(function()
        return player.PlayerGui.UI.HUD.Quests.List[slot].Progress.Title
    end)
    if not ok or not title then return 0, 0 end
    local c, m = title.ContentText:match("%[(%d+)/(%d+)%]")
    return tonumber(c) or 0, tonumber(m) or 0
end

local function isSlotDone(slot)
    local c, m = getSlotProgress(slot)
    return m > 0 and c >= m
end

local function getTargetEnemyFromQuest(slot)
    local ok, desc = pcall(function()
        return player.PlayerGui.UI.HUD.Quests.List[slot].Description.ContentText
    end)
    if not (ok and desc) then return nil end
    local best, bestLen = nil, 0
    for _, wm in ipairs(serverEnemiesWorld:GetChildren()) do
        for _, g in ipairs(wm:GetChildren()) do
            for _, e in ipairs(g:GetChildren()) do
                if string.find(desc, e.Name, 1, true) and #e.Name > bestLen then
                    best = e.Name bestLen = #e.Name
                end
            end
        end
    end
    return best
end

local function getQuestTarget(targetName)
    local myPos = (player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position) or Vector3.zero
    local bestTarget, bestID, bestWorld, bestZone, shortestDist = nil, nil, nil, nil, math.huge
    for _, wm in ipairs(serverEnemiesWorld:GetChildren()) do
        for _, g in ipairs(wm:GetChildren()) do
            for _, e in ipairs(g:GetChildren()) do
                if e.Name == targetName then
                    local isDead, hp = e:GetAttribute("Died"), e:GetAttribute("Health")
                    if not isDead and (not hp or tonumber(hp) > 0) then
                        local sID = e:GetAttribute("ID")
                        if sID then
                            local pos = e:IsA("Model") and e:GetPivot().Position or e.Position
                            if pos then
                                local d = (pos - myPos).Magnitude
                                if d < shortestDist then
                                    shortestDist=d bestTarget=e bestID=sID
                                    bestWorld=wm.Name bestZone=tonumber(g.Name) or 1
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return bestTarget, bestID, bestWorld, bestZone
end

-- ============================================================
--  HELPERS — STAR / PASSIVE
-- ============================================================
local function teleportToStar(starName)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local ok, sm = pcall(function() return workspace.Server.Stars[starName] end)
    if not (ok and sm) then
        WindUI:Notify({ Title = "Teleport Failed", Content = "Star not found: " .. tostring(starName), Duration = 3 })
        return
    end
    local ok2, cf = pcall(function() return sm:GetPivot() end)
    if ok2 and cf then hrp.CFrame = cf * CFrame.new(0, 5, 0) end
end

local okPassive, PassivePunksData = pcall(function()
    return require(RS.Omni.Shared.PassivePunks)
end)
if not okPassive then PassivePunksData = {} end

local selectedUnitUID       = ""
local selectedTargetPassive = ""

local function getPassiveList()
    local t = {}
    for name in pairs(PassivePunksData) do table.insert(t, name) end
    table.sort(t)
    return t
end

local function getUnitList()
    local units = {}
    pcall(function()
        local inv = Omni.Data.Inventory.Units
        if type(inv) == "table" then
            for uid, ud in pairs(inv) do
                if type(ud) == "table" then
                    table.insert(units, tostring(ud.Name or "Unknown") .. " | " .. tostring(uid))
                end
            end
        end
    end)
    if #units == 0 then table.insert(units, "No Units Found | 0") end
    return units
end

-- ============================================================
--  HELPER — FARM UNTIL KEY
-- ============================================================
local function farmUntilKey(keyName, worldName, zoneNum, stopFn)
    fireRemote({{{"Player", "Teleport", "Teleport", worldName, zoneNum, n=5}, "\002"}})
    task.wait(3)
    WindUI:Notify({ Title = "⚔ Key Farming", Content = "Farming " .. keyName .. " at " .. worldName .. " Zone " .. zoneNum, Duration = 4 })
    while getKeyCount(keyName) < 1 and stopFn() do
        pcall(function()
            local zoneFolder = workspace.Server.Enemies.World[worldName][tostring(zoneNum)]
            local validEnemies = {}
            for _, e in ipairs(zoneFolder:GetChildren()) do
                local isDead, hp = e:GetAttribute("Died"), e:GetAttribute("Health")
                if not isDead and (not hp or tonumber(hp) > 0) then table.insert(validEnemies, e) end
            end
            if #validEnemies == 0 then task.wait(0.5) return end

            local myPos = (player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position) or Vector3.zero
            local best, bestID, bestD = nil, nil, math.huge
            for _, e in ipairs(validEnemies) do
                local p = e:IsA("Model") and e:GetPivot().Position or (e:IsA("BasePart") and e.Position)
                if p then
                    local d = (p - myPos).Magnitude
                    if d < bestD then bestD=d best=e bestID=e:GetAttribute("ID") end
                end
            end

            if best and best.Parent then
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                local tPos = best:IsA("Model") and best:GetPivot() or (best:IsA("BasePart") and best.CFrame)
                if hrp and tPos then hrp.CFrame = tPos * CFrame.new(0, 3, 0) end

                while best and best.Parent and getKeyCount(keyName) < 1 and stopFn() do
                    local isDead, hp = best:GetAttribute("Died"), best:GetAttribute("Health")
                    if isDead or (hp and tonumber(hp) <= 0) then break end
                    local curHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if curHRP then
                        local tCF = best:IsA("Model") and best:GetPivot() or (best:IsA("BasePart") and best.CFrame)
                        if tCF and (curHRP.Position - tCF.Position).Magnitude > 8 then curHRP.CFrame = tCF * CFrame.new(0, 3, 0) end
                    end
                    if bestID then
                        fireRemote({{{ "General", "Attack", "Click", { [tostring(bestID)] = true }, n=4 }, "\002" }})
                    end
                    task.wait(0.1)
                end
            end
        end)
    end
    if getKeyCount(keyName) >= 1 then
        WindUI:Notify({ Title = "✅ Key Obtained!", Content = keyName .. " x" .. getKeyCount(keyName) .. " — Returning to Gamemode...", Duration = 3 })
    end
end

-- ============================================================
--  TAB: FARMING
-- ============================================================
local selectedFarmWorld = Options.SelectedFarmWorld or getWorldsList()[1] or ""
local selectedFarmZone  = Options.SelectedFarmZone  or getZonesList(selectedFarmWorld)[1] or ""

local WorldDropdown, ZoneDropdown, EnemyDropdown

FarmTab:Section({ Title = "Map & Enemy Selection" })

WorldDropdown = FarmTab:Dropdown({
    Title    = "Select World",
    Icon     = "globe",
    Values   = getWorldsList(),
    Value    = selectedFarmWorld,
    Callback = function(v)
        selectedFarmWorld = v
        Options.SelectedFarmWorld = v
        SaveConfig()
        local newZones = getZonesList(v)
        if ZoneDropdown then ZoneDropdown:Refresh(newZones) end
        if not table.find(newZones, selectedFarmZone) then
            selectedFarmZone = newZones[1] or ""
            Options.SelectedFarmZone = selectedFarmZone
            SaveConfig()
        end
        if EnemyDropdown then EnemyDropdown:Refresh(getEnemiesList(selectedFarmWorld, selectedFarmZone)) end
    end
})

ZoneDropdown = FarmTab:Dropdown({
    Title    = "Select Zone",
    Icon     = "map-pin",
    Values   = getZonesList(selectedFarmWorld),
    Value    = selectedFarmZone,
    Callback = function(v)
        selectedFarmZone = v
        Options.SelectedFarmZone = v
        SaveConfig()
        if EnemyDropdown then EnemyDropdown:Refresh(getEnemiesList(selectedFarmWorld, selectedFarmZone)) end
    end
})

EnemyDropdown = FarmTab:Dropdown({
    Title    = "Select Enemies",
    Icon     = "target",
    Values   = getEnemiesList(selectedFarmWorld, selectedFarmZone),
    Value    = selectedFarmEnemies,
    Multi    = true,
    Callback = function(v)
        selectedFarmEnemies = type(v) == "table" and v or (type(v) == "string" and {v} or {})
        Options.SelectedEnemies = selectedFarmEnemies
        SaveConfig()
    end
})

FarmTab:Button({
    Title    = "Refresh Maps & Enemies",
    Icon     = "refresh-cw",
    Callback = function()
        WorldDropdown:Refresh(getWorldsList())
        ZoneDropdown:Refresh(getZonesList(selectedFarmWorld))
        EnemyDropdown:Refresh(getEnemiesList(selectedFarmWorld, selectedFarmZone))
        WindUI:Notify({ Title = "Updated", Content = "Map & Enemy list refreshed!", Duration = 2 })
    end
})

FarmTab:Divider()
FarmTab:Section({ Title = "Auto Actions" })

FarmTab:Toggle({
    Title = "Auto Farm",
    Icon  = "crosshair",
    Desc  = "Teleport to nearest allowed enemy and farm",
    Type  = "Checkbox",
    Value = Options.AutoFarm or false,
    Callback = function(v)
        isAutoFarm = v
        Options.AutoFarm = v
        SaveConfig()
        if isAutoFarm then
            task.spawn(function()
                while isAutoFarm do
                    if isInsideTrial then task.wait(1) continue end
                    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local target, id = getValidTarget()
                        if target and id then
                            local tCF = target:IsA("Model") and target:GetPivot() or (target:IsA("BasePart") and target.CFrame)
                            if tCF and (hrp.Position - tCF.Position).Magnitude > 8 then hrp.CFrame = tCF * CFrame.new(0,3,0) end
                            while isAutoFarm and not isInsideTrial and target and target.Parent do
                                local isDead, hp = target:GetAttribute("Died"), target:GetAttribute("Health")
                                if isDead or (hp and tonumber(hp) <= 0) then break end
                                local curHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                                if curHRP then
                                    local tCF2 = target:IsA("Model") and target:GetPivot() or (target:IsA("BasePart") and target.CFrame)
                                    if tCF2 and (curHRP.Position - tCF2.Position).Magnitude > 8 then curHRP.CFrame = tCF2 * CFrame.new(0,3,0) end
                                end
                                task.wait(0.1)
                            end
                        else task.wait(0.5) end
                    else task.wait(0.5) end
                end
            end)
        end
    end
})

FarmTab:Toggle({
    Title = "Auto Fast Clicker",
    Icon  = "sword",
    Type  = "Checkbox",
    Value = Options.AutoFastClicker or false,
    Callback = function(v)
        isAttacking = v
        Options.AutoFastClicker = v
        SaveConfig()
        if isAttacking then
            task.spawn(function()
                while isAttacking do
                    pcall(function()
                        local bestID, shortestDist = nil, math.huge
                        local myPos = (player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position) or Vector3.zero

                        local function checkTarget(node)
                            local sID = node:GetAttribute("ID")
                            if sID and not node:GetAttribute("Died") then
                                local hp = node:GetAttribute("Health")
                                if not hp or tonumber(hp) > 0 then
                                    local pos = node:IsA("Model") and node:GetPivot().Position or (node:IsA("BasePart") and node.Position)
                                    if pos then
                                        local d = (pos - myPos).Magnitude
                                        if d < shortestDist then shortestDist=d bestID=sID end
                                    end
                                end
                            end
                        end

                        local sew = workspace:FindFirstChild("Server") and workspace.Server:FindFirstChild("Enemies") and workspace.Server.Enemies:FindFirstChild("World")
                        if sew then
                            for _, wm in ipairs(sew:GetChildren()) do
                                for _, g in ipairs(wm:GetChildren()) do
                                    for _, e in ipairs(g:GetChildren()) do checkTarget(e) end
                                end
                            end
                        end
                        local ce = workspace:FindFirstChild("Client") and workspace.Client:FindFirstChild("Enemies")
                        if ce then
                            for _, e in ipairs(ce:GetChildren()) do
                                checkTarget(e)
                                if e:IsA("Folder") or e:IsA("Model") then
                                    for _, sub in ipairs(e:GetChildren()) do checkTarget(sub) end
                                end
                            end
                        end
                        local sg = workspace:FindFirstChild("Server") and workspace.Server:FindFirstChild("Enemies") and workspace.Server.Enemies:FindFirstChild("Gamemodes")
                        if sg then
                            for _, gm in ipairs(sg:GetChildren()) do
                                for _, e in ipairs(gm:GetChildren()) do
                                    checkTarget(e)
                                    if e:IsA("Folder") or e:IsA("Model") then
                                        for _, sub in ipairs(e:GetChildren()) do checkTarget(sub) end
                                    end
                                end
                            end
                        end
                        if bestID then
                            fireRemote({{{ "General", "Attack", "Click", { [tostring(bestID)] = true }, n=4 }, "\002" }})
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

serverEnemiesWorld.ChildAdded:Connect(function()
    task.wait(0.5)
    if WorldDropdown then WorldDropdown:Refresh(getWorldsList()) end
    if ZoneDropdown  then ZoneDropdown:Refresh(getZonesList(selectedFarmWorld)) end
    if EnemyDropdown then EnemyDropdown:Refresh(getEnemiesList(selectedFarmWorld, selectedFarmZone)) end
end)
serverEnemiesWorld.ChildRemoved:Connect(function()
    task.wait(0.5)
    if WorldDropdown then WorldDropdown:Refresh(getWorldsList()) end
    if ZoneDropdown  then ZoneDropdown:Refresh(getZonesList(selectedFarmWorld)) end
    if EnemyDropdown then EnemyDropdown:Refresh(getEnemiesList(selectedFarmWorld, selectedFarmZone)) end
end)

task.spawn(function()
    local lastWorld, lastZone = "", 0
    while true do
        task.wait(3)
        local cw, cz = getCurrentWorldName()
        if cw ~= "" and (cw ~= lastWorld or cz ~= lastZone) then
            lastWorld, lastZone = cw, cz
            local wl = getWorldsList()
            if table.find(wl, cw) then
                selectedFarmWorld = cw Options.SelectedFarmWorld = cw SaveConfig()
                if WorldDropdown then WorldDropdown:Refresh(wl) end
                local zl = getZonesList(cw)
                local zs = tostring(cz)
                if table.find(zl, zs) then
                    selectedFarmZone = zs Options.SelectedFarmZone = zs SaveConfig()
                end
                if ZoneDropdown  then ZoneDropdown:Refresh(zl) end
                if EnemyDropdown then EnemyDropdown:Refresh(getEnemiesList(selectedFarmWorld, selectedFarmZone)) end
            end
        end
    end
end)

-- ============================================================
--  TAB: GAMEMODE — TRIAL
-- ============================================================
GamemodeTab:Section({ Title = "Trial" })

GamemodeTab:Toggle({
    Title = "Auto Trial",
    Icon  = "clock",
    Desc  = "Join Trial at :15 and :45 every hour",
    Type  = "Checkbox",
    Value = Options.AutoTrial or false,
    Callback = function(v)
        isAutoTrial = v
        Options.AutoTrial = v
        SaveConfig()
        if not isAutoTrial then isInsideTrial = false end
    end
})

-- ============================================================
--  TRIAL WATCHER (FIXED Auto Leave)
-- ============================================================
task.spawn(function()
    local lastMin      = -1
    local noEnemyTimer = 0

    local function doLeaveAndReturn()
        local dest = isAutoDragonDefense and {"Dragon Verse", 2}
                  or {(preTrialWorld ~= "" and preTrialWorld or "Fruits Verse"), tonumber(preTrialZone) or 1}
        fireRemote({{{"Player","Teleport","Teleport","Fruits Verse",1,n=5},"\002"}})
        task.wait(2)
        fireRemote({{{"General","Gamemodes","Leave","Trial Easy",n=4},"\002"}})
        task.wait(3)
        fireRemote({{{"Player","Teleport","Teleport",dest[1],dest[2],n=5},"\002"}})
        WindUI:Notify({ Title = "Trial Ended", Content = "Returning to " .. dest[1] .. " Zone " .. dest[2], Duration = 4 })
        task.wait(2)
        isInsideTrial = false
        noEnemyTimer  = 0
    end

    -- อ่านเลข wave จาก HUD ด้วย path ที่ยืดหยุ่น
    local function getCurrentWave()
        local ok, wt = pcall(function()
            local hud = player.PlayerGui.UI.HUD.Gamemodes["Trial Easy"]
            if not hud then return "" end
            local main = hud:FindFirstChild("Main")
            if not main then return "" end
            local wave = main:FindFirstChild("Wave")
            if not wave then return "" end
            -- กรณี Wave เป็น TextLabel ตรงๆ
            if wave:IsA("TextLabel") or wave:IsA("TextBox") then
                return wave.ContentText ~= "" and wave.ContentText or wave.Text
            end
            -- กรณี Wave มี child TextLabel
            for _, child in ipairs(wave:GetChildren()) do
                if child:IsA("TextLabel") or child:IsA("TextBox") then
                    local t = child.ContentText ~= "" and child.ContentText or child.Text
                    if t ~= "" then return t end
                end
            end
            return ""
        end)
        if not ok or type(wt) ~= "string" then return nil end
        local num = string.match(wt, "(%d+)")
        return tonumber(num)
    end

    local function shouldLeaveNow()
        if not isAutoLeaveTrial then return false end
        local w = getCurrentWave()
        print("[Trial Wave]", w, "/ Target:", trialTargetWave)
        return w ~= nil and w >= trialTargetWave
    end

    local function getTrialServerTarget()
        local myPos = (player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            and player.Character.HumanoidRootPart.Position) or Vector3.zero
        local bestTarget, bestID, bestDist = nil, nil, math.huge
        local ok, folder = pcall(function()
            return workspace.Server.Enemies.Gamemodes["Trial Easy"]
        end)
        if ok and folder then
            for _, child in ipairs(folder:GetDescendants()) do
                local sID  = child:GetAttribute("ID")
                local dead = child:GetAttribute("Died")
                local hp   = child:GetAttribute("Health")
                if sID and not dead and (not hp or tonumber(hp) > 0) then
                    local pos = child:IsA("Model") and child:GetPivot().Position
                             or (child:IsA("BasePart") and child.Position)
                    if pos then
                        local d = (pos - myPos).Magnitude
                        if d < bestDist then bestDist=d bestTarget=child bestID=sID end
                    end
                end
            end
        end
        return bestTarget, bestID
    end

    while true do
        task.wait(1)

        if not isAutoTrial then
            if isInsideTrial then isInsideTrial = false end
            lastMin = -1
            continue
        end

        local t = os.date("*t")

        -- ── OUTSIDE TRIAL ──────────────────────────────────────
        if not isInsideTrial then
            if t.min ~= 15 and t.min ~= 45 then lastMin = -1 end

            if (t.min == 15 or t.min == 45) and t.min ~= lastMin then
                lastMin = t.min

                preTrialWorld, preTrialZone = getCurrentWorldName()
                if preTrialWorld == "" then preTrialWorld = "Fruits Verse" preTrialZone = 1 end

                isInsideTrial = true
                noEnemyTimer  = 0

                WindUI:Notify({ Title = "⚔ Trial", Content = "Saved: " .. preTrialWorld .. " → Joining Trial", Duration = 3 })
                task.wait(1.5)
                fireRemote({{{"General","Gamemodes","Join","Trial Easy",n=4},"\002"}})
                task.wait(3)
            end

        -- ── INSIDE TRIAL ───────────────────────────────────────
        else
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then task.wait(0.5) continue end

            -- เช็คก่อนเข้า combat loop
            if shouldLeaveNow() then
                WindUI:Notify({ Title = "⚔ Trial", Content = "Wave " .. trialTargetWave .. " reached! Leaving...", Duration = 3 })
                doLeaveAndReturn()
                continue
            end

            noEnemyTimer = 0
            while isInsideTrial do
                -- เช็ค leave ใน outer combat loop ทุก tick
                if shouldLeaveNow() then
                    WindUI:Notify({ Title = "⚔ Trial", Content = "Wave " .. trialTargetWave .. " reached! Leaving...", Duration = 3 })
                    doLeaveAndReturn()
                    break
                end

                local curHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if not curHRP then task.wait(0.2) break end

                local target, id = getTrialServerTarget()
                if not target then
                    noEnemyTimer = noEnemyTimer + 0.1
                    if noEnemyTimer >= 10 then
                        WindUI:Notify({ Title = "⚔ Trial", Content = "No enemies for 10s. Leaving...", Duration = 3 })
                        doLeaveAndReturn()
                        break
                    end
                    task.wait(0.1)
                else
                    noEnemyTimer = 0
                    local tCF = target:IsA("Model") and target:GetPivot() or (target:IsA("BasePart") and target.CFrame)
                    if tCF and (curHRP.Position - tCF.Position).Magnitude > 8 then
                        curHRP.CFrame = tCF * CFrame.new(0, 3, 0)
                    end

                    -- Inner loop ติดตาม target
                    while isInsideTrial do
                        -- เช็ค leave ใน inner loop ด้วย
                        if shouldLeaveNow() then break end

                        local hp   = target:GetAttribute("Health")
                        local dead = target:GetAttribute("Died")
                        if dead or (hp ~= nil and tonumber(hp) <= 0) or not target.Parent then break end

                        local freshHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if freshHRP then
                            local tCF2 = target:IsA("Model") and target:GetPivot() or (target:IsA("BasePart") and target.CFrame)
                            if tCF2 and (freshHRP.Position - tCF2.Position).Magnitude > 8 then
                                freshHRP.CFrame = tCF2 * CFrame.new(0, 3, 0)
                            end
                        end
                        task.wait(0.05)
                    end

                    -- ถ้า break จาก inner เพราะ shouldLeave → จัดการที่ outer
                    if shouldLeaveNow() then
                        WindUI:Notify({ Title = "⚔ Trial", Content = "Wave " .. trialTargetWave .. " reached! Leaving...", Duration = 3 })
                        doLeaveAndReturn()
                        break
                    end
                end
            end
        end
    end
end)

GamemodeTab:Toggle({
    Title = "Auto Leave Trial",
    Icon  = "door-open",
    Desc  = "Leave when reaching target wave",
    Type  = "Checkbox",
    Value = Options.AutoLeaveTrial or false,
    Callback = function(v)
        isAutoLeaveTrial = v
        Options.AutoLeaveTrial = v
        SaveConfig()
    end
})

GamemodeTab:Slider({
    Title = "Leave at Wave",
    Icon  = "skip-forward",
    Step  = 1,
    Value = { Min=1, Max=50, Default=Options.LeaveAtWave or 10 },
    Callback = function(v) trialTargetWave=v Options.LeaveAtWave=v SaveConfig() end
})

-- ─── Dragon Defense ──────────────────────────────────────────
GamemodeTab:Divider()
GamemodeTab:Section({ Title = "Dragon Defense" })

local isAutoLeaveDragon = Options.AutoLeaveDragon or false
local dragonTargetWave  = Options.LeaveDragonAtWave or 50

GamemodeTab:Toggle({
    Title = "Auto Dragon Defense",
    Icon  = "shield",
    Desc  = "Checks Saiyan Key → farms if empty → enters Dungeon",
    Type  = "Checkbox",
    Value = Options.AutoDragonDefense or false,
    Callback = function(v)
        isAutoDragonDefense = v
        Options.AutoDragonDefense = v
        SaveConfig()
        if isAutoDragonDefense then
            fireRemote({{{"Player","Teleport","Teleport","Dragon Verse",2,n=5},"\002"}})
            task.spawn(function()
                while isAutoDragonDefense do
                    if isInsideTrial then task.wait(1) continue end

                    if getKeyCount("Saiyan Key") < 1 then
                        WindUI:Notify({ Title = "🔑 No Saiyan Key!", Content = "Farming at Dragon Verse Zone 2...", Duration = 4 })
                        farmUntilKey("Saiyan Key", "Dragon Verse", 2, function()
                            return isAutoDragonDefense and not isInsideTrial
                        end)
                        if not isAutoDragonDefense then break end
                        fireRemote({{{"Player","Teleport","Teleport","Dragon Verse",2,n=5},"\002"}})
                        task.wait(3) continue
                    end

                    local curWorld, curZone = getCurrentWorldName()
                    if curWorld ~= "Dragon Verse" or curZone ~= 2 then
                        fireRemote({{{"Player","Teleport","Teleport","Dragon Verse",2,n=5},"\002"}})
                        task.wait(4) continue
                    end

                    local ok, dragonNode = pcall(function()
                        return workspace.Server.Interactable["Dragon Arena"]["Dragon Defense Gamemode"]
                    end)
                    if ok and dragonNode then
                        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local ok2, cf = pcall(function()
                                return dragonNode:IsA("Model") and dragonNode:GetPivot() or (dragonNode:IsA("BasePart") and dragonNode.CFrame)
                            end)
                            if ok2 and cf then hrp.CFrame = cf * CFrame.new(0,5,0) end
                        end
                    else task.wait(3) continue end

                    task.wait(0.5)
                    fireRemote({{{"General","Gamemodes","Join","Dragon Defense",n=4},"\002"}})
                    task.wait(2.5)

                    local okC, confirmBtn = pcall(function() return player.PlayerGui.Selection.Frames.Confirmation.Main.Buttons.Confirm end)
                    if okC and confirmBtn then
                        local vim = game:GetService("VirtualInputManager")
                        local ap, as = confirmBtn.AbsolutePosition, confirmBtn.AbsoluteSize
                        if as.X > 0 and as.Y > 0 then
                            vim:SendMouseButtonEvent(ap.X+as.X/2, ap.Y+as.Y/2, 0, true,  game, 1)
                            task.wait(0.05)
                            vim:SendMouseButtonEvent(ap.X+as.X/2, ap.Y+as.Y/2, 0, false, game, 1)
                        end
                    end
                    task.wait(5)
                    local okX, cancelBtn = pcall(function() return player.PlayerGui.Selection.Frames.Confirmation.Main.Buttons.Cancel end)
                    if okX and cancelBtn then
                        local vim = game:GetService("VirtualInputManager")
                        local ap, as = cancelBtn.AbsolutePosition, cancelBtn.AbsoluteSize
                        if as.X > 0 and as.Y > 0 then
                            vim:SendMouseButtonEvent(ap.X+as.X/2, ap.Y+as.Y/2, 0, true,  game, 1)
                            task.wait(0.05)
                            vim:SendMouseButtonEvent(ap.X+as.X/2, ap.Y+as.Y/2, 0, false, game, 1)
                        end
                        task.wait(0.5)
                    end
                    task.wait(2)

                    local okMap, defNode = pcall(function() return workspace.Client.Maps["Dragon Defense"].Map.Defense end)
                    if okMap and defNode then
                        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local ok2, cf = pcall(function()
                                return defNode:IsA("Model") and defNode:GetPivot() or (defNode:IsA("BasePart") and defNode.CFrame)
                            end)
                            if ok2 and cf then hrp.CFrame = cf * CFrame.new(0,5,0) end
                        end
                    else WindUI:Notify({ Title = "Dragon Defense", Content = "Map not loaded yet, retrying...", Duration = 2 }) task.wait(3) continue end

                    task.wait(1)

                    local function getDragonTarget()
                        local myPos = (player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position) or Vector3.zero
                        local bT, bID, bD = nil, nil, math.huge
                        local okC2, ce = pcall(function() return workspace.Client.Enemies end)
                        if okC2 and ce then
                            for _, child in ipairs(ce:GetDescendants()) do
                                local sID, isDead, hp = child:GetAttribute("ID"), child:GetAttribute("Died"), child:GetAttribute("Health")
                                if sID and not isDead and (not hp or tonumber(hp) > 0) then
                                    local tp = child:IsA("Model") and child:GetPivot().Position or (child:IsA("BasePart") and child.Position)
                                    if tp then local d=(tp-myPos).Magnitude if d<bD then bD=d bT=child bID=sID end end
                                end
                            end
                        end
                        if not bT then
                            local okS, sdd = pcall(function() return workspace.Server.Enemies.Gamemodes["Dragon Defense"] end)
                            if okS and sdd then
                                for _, child in ipairs(sdd:GetDescendants()) do
                                    local sID, isDead, hp = child:GetAttribute("ID"), child:GetAttribute("Died"), child:GetAttribute("Health")
                                    if sID and not isDead and (not hp or tonumber(hp) > 0) then
                                        local tp = child:IsA("Model") and child:GetPivot().Position or (child:IsA("BasePart") and child.Position)
                                        if tp then local d=(tp-myPos).Magnitude if d<bD then bD=d bT=child bID=sID end end
                                    end
                                end
                            end
                        end
                        return bT, bID
                    end

                    local farmStart = tick()
                    while isAutoDragonDefense do
                        if isInsideTrial then break end
                        local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if not myHRP then task.wait(0.5) continue end

                        local shouldLeave = false
                        local okW, wt = pcall(function()
                            local w = player.PlayerGui.UI.HUD.Gamemodes["Dragon Defense"].Main.Wave.Value
                            if typeof(w) == "Instance" then
                                return (w:IsA("TextLabel") or w:IsA("TextBox")) and (w.ContentText ~= "" and w.ContentText or w.Text) or tostring(w.Value)
                            end
                            return tostring(w)
                        end)
                        if okW and type(wt) == "string" then
                            local cw = string.match(wt, "(%d+)/") or string.match(wt, "(%d+)")
                            if isAutoLeaveDragon and cw and tonumber(cw) >= dragonTargetWave then shouldLeave = true end
                        end

                        if shouldLeave then
                            fireRemote({{{"Player","Teleport","Teleport","Dragon Verse",2,n=5},"\002"}})
                            task.wait(2)
                            fireRemote({{{"General","Gamemodes","Leave","Dragon Defense",n=4},"\002"}})
                            WindUI:Notify({ Title = "Dragon Defense", Content = "Target wave reached! Leaving...", Duration = 4 })
                            task.wait(3) break
                        end

                        local bT, bID = getDragonTarget()
                        if bT and bID then
                            farmStart = tick()
                            local tCF = bT:IsA("Model") and bT:GetPivot() or (bT:IsA("BasePart") and bT.CFrame)
                            if tCF and (myHRP.Position - tCF.Position).Magnitude > 8 then myHRP.CFrame = tCF * CFrame.new(0,3,0) end
                            while isAutoDragonDefense do
                                if isInsideTrial then break end
                                if not bT or not bT.Parent then break end
                                local isDead, hp = bT:GetAttribute("Died"), bT:GetAttribute("Health")
                                if isDead or (hp and tonumber(hp) <= 0) then task.wait(0.2) break end
                                local curHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                                if curHRP then
                                    local tCF2 = bT:IsA("Model") and bT:GetPivot() or (bT:IsA("BasePart") and bT.CFrame)
                                    if tCF2 and (curHRP.Position - tCF2.Position).Magnitude > 8 then curHRP.CFrame = tCF2 * CFrame.new(0,3,0) end
                                end
                                task.wait(0.1)
                            end
                        else
                            if tick() - farmStart > 600 then
                                WindUI:Notify({ Title = "Dragon Defense", Content = "Round ended, rejoining...", Duration = 3 }) break
                            end
                            task.wait(0.5)
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end
})

GamemodeTab:Toggle({
    Title = "Auto Leave Dragon Defense",
    Icon  = "door-open",
    Type  = "Checkbox",
    Value = Options.AutoLeaveDragon or false,
    Callback = function(v) isAutoLeaveDragon=v Options.AutoLeaveDragon=v SaveConfig() end
})

GamemodeTab:Slider({
    Title = "Leave at Wave (Dragon)",
    Icon  = "skip-forward",
    Step  = 1,
    Value = { Min=1, Max=100, Default=Options.LeaveDragonAtWave or 50 },
    Callback = function(v) dragonTargetWave=v Options.LeaveDragonAtWave=v SaveConfig() end
})

-- ─── Tempest Invasion ────────────────────────────────────────
GamemodeTab:Divider()
GamemodeTab:Section({ Title = "Tempest Invasion" })

local isAutoLeaveTempest = Options.AutoLeaveTempest or false
local tempestTargetWave  = Options.LeaveTempestAtWave or 50

GamemodeTab:Toggle({
    Title = "Auto Tempest Invasion",
    Icon  = "swords",
    Desc  = "Checks Slime Key → farms if empty → enters Dungeon",
    Type  = "Checkbox",
    Value = Options.AutoTempestInvasion or false,
    Callback = function(v)
        isAutoTempestInvasion = v
        Options.AutoTempestInvasion = v
        SaveConfig()
        if isAutoTempestInvasion then
            task.spawn(function()
                while isAutoTempestInvasion do
                    if isInsideTrial then task.wait(1) continue end

                    if getKeyCount("Slime Key") < 1 then
                        WindUI:Notify({ Title = "🔑 No Slime Key!", Content = "Farming at Slime Verse Zone 2...", Duration = 4 })
                        farmUntilKey("Slime Key", "Slime Verse", 2, function()
                            return isAutoTempestInvasion and not isInsideTrial
                        end)
                        if not isAutoTempestInvasion then break end
                        task.wait(1) continue
                    end

                    WindUI:Notify({ Title = "Tempest Invasion", Content = "Joining...", Duration = 3 })
                    fireRemote({{{"General","Gamemodes","Join","Tempest Invasion",n=4},"\002"}})
                    task.wait(4)

                    local inMatch = true
                    while inMatch and isAutoTempestInvasion do
                        if isInsideTrial then break end
                        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if not hrp then task.wait(0.5) continue end

                        local shouldLeave = false
                        local okW, wt = pcall(function()
                            local w = player.PlayerGui.UI.HUD.Gamemodes["Tempest Invasion"].Main.Wave.Value
                            if typeof(w) == "Instance" then
                                return (w:IsA("TextLabel") or w:IsA("TextBox")) and (w.ContentText ~= "" and w.ContentText or w.Text) or tostring(w.Value)
                            end
                            return tostring(w)
                        end)
                        if okW and type(wt) == "string" then
                            local cw = string.match(wt, "(%d+)/") or string.match(wt, "(%d+)")
                            if isAutoLeaveTempest and cw and tonumber(cw) >= tempestTargetWave then shouldLeave = true end
                        end

                        if shouldLeave then
                            fireRemote({{{"Player","Teleport","Teleport","Slime Verse",1,n=5},"\002"}})
                            task.wait(2)
                            fireRemote({{{"General","Gamemodes","Leave","Tempest Invasion",n=4},"\002"}})
                            WindUI:Notify({ Title = "Tempest Invasion", Content = "Target wave reached! Leaving...", Duration = 4 })
                            task.wait(3) inMatch=false break
                        end

                        local target, targetID, shortestDist = nil, nil, math.huge
                        local okS, st = pcall(function() return workspace.Server.Enemies.Gamemodes["Tempest Invasion"] end)
                        if okS and st then
                            for _, child in ipairs(st:GetDescendants()) do
                                local sID, isDead, hp = child:GetAttribute("ID"), child:GetAttribute("Died"), child:GetAttribute("Health")
                                if sID and not isDead and (not hp or tonumber(hp) > 0) then
                                    local tp = child:IsA("Model") and child:GetPivot().Position or (child:IsA("BasePart") and child.Position)
                                    if tp then
                                        local d = (tp - hrp.Position).Magnitude
                                        if d < shortestDist then shortestDist=d target=child targetID=sID end
                                    end
                                end
                            end
                        end

                        if target and targetID then
                            local tCF = target:IsA("Model") and target:GetPivot() or (target:IsA("BasePart") and target.CFrame)
                            if tCF and (hrp.Position - tCF.Position).Magnitude > 8 then hrp.CFrame = tCF * CFrame.new(0,3,0) end
                            while isAutoTempestInvasion and target and target.Parent do
                                local isDead, hp = target:GetAttribute("Died"), target:GetAttribute("Health")
                                if isDead or (hp and tonumber(hp) <= 0) then break end
                                local curHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                                if curHRP then
                                    local tCF2 = target:IsA("Model") and target:GetPivot() or (target:IsA("BasePart") and target.CFrame)
                                    if tCF2 and (curHRP.Position - tCF2.Position).Magnitude > 8 then curHRP.CFrame = tCF2 * CFrame.new(0,3,0) end
                                    fireRemote({{{ "General","Attack","Click",{ [tostring(targetID)]=true },n=4 },"\002" }})
                                end
                                task.wait(0.1)
                            end
                        else task.wait(0.5) end
                    end

                    if isAutoTempestInvasion and not isInsideTrial then
                        for i = 10, 1, -1 do
                            if not isAutoTempestInvasion then break end
                            WindUI:Notify({ Title = "Tempest Invasion", Content = "Rejoining in " .. i .. "s...", Duration = 1.2 })
                            task.wait(1)
                        end
                    end
                end
            end)
        end
    end
})

GamemodeTab:Toggle({
    Title = "Auto Leave Tempest Invasion",
    Icon  = "door-open",
    Type  = "Checkbox",
    Value = Options.AutoLeaveTempest or false,
    Callback = function(v) isAutoLeaveTempest=v Options.AutoLeaveTempest=v SaveConfig() end
})

GamemodeTab:Slider({
    Title = "Leave at Wave (Tempest)",
    Icon  = "skip-forward",
    Step  = 1,
    Value = { Min=1, Max=100, Default=Options.LeaveTempestAtWave or 50 },
    Callback = function(v) tempestTargetWave=v Options.LeaveTempestAtWave=v SaveConfig() end
})

-- ============================================================
--  TAB: QUEST
-- ============================================================
QuestTab:Section({ Title = "Quest Settings" })

QuestTab:Dropdown({
    Title    = "Select Quest",
    Icon     = "list",
    Values   = questNames,
    Value    = Options.SelectedQuest or (questNames[1] or ""),
    Callback = function(v) selectedQuest=v Options.SelectedQuest=v SaveConfig() end
})

QuestTab:Toggle({
    Title = "Auto Quest",
    Icon  = "circle-check-big",
    Desc  = "Complete selected quest automatically",
    Type  = "Checkbox",
    Value = Options.AutoQuest or false,
    Callback = function(v)
        isAutoQuest = v
        Options.AutoQuest = v
        SaveConfig()
        if isAutoQuest then
            task.spawn(function()
                while isAutoQuest do
                    if isInsideTrial then task.wait(1) continue end
                    local questData = getQuestData(selectedQuest)
                    if questData and questData.Missions then
                        for missionIndex, mission in ipairs(questData.Missions) do
                            if not isAutoQuest then break end
                            local slot, cachedEnemy = tostring(missionIndex), nil
                            while isAutoQuest and not isSlotDone(slot) do
                                if not cachedEnemy then
                                    cachedEnemy = getTargetEnemyFromQuest(slot)
                                    if cachedEnemy then
                                        WindUI:Notify({ Title = "Quest", Content = "Targeting: " .. cachedEnemy, Duration = 3 })
                                    end
                                end
                                if cachedEnemy then
                                    local target, enemyID, targetWorld, targetZone = getQuestTarget(cachedEnemy)
                                    if target and enemyID and targetWorld then
                                        local cw, cz = getCurrentWorldName()
                                        if (cw ~= "" and cw ~= targetWorld) or cz ~= targetZone then
                                            fireRemote({{{"Player","Teleport","Teleport",targetWorld,targetZone or 1,n=5},"\002"}})
                                            task.wait(2.5)
                                        end
                                        while isAutoQuest and not isSlotDone(slot) and target.Parent do
                                            local isDead, hp = target:GetAttribute("Died"), target:GetAttribute("Health")
                                            if isDead or (hp and tonumber(hp) <= 0) then break end
                                            local curHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                                            if curHRP then
                                                local tCF = target:IsA("Model") and target:GetPivot() or target.CFrame
                                                if tCF and (curHRP.Position - tCF.Position).Magnitude > 8 then curHRP.CFrame = tCF * CFrame.new(0,3,0) end
                                            end
                                            task.wait(0.1)
                                        end
                                    else task.wait(0.5) end
                                else task.wait(0.5) end
                            end
                            if isAutoQuest then
                                fireRemote({{{"General","Quests","Complete",selectedQuest,mission,n=5},"\002"}})
                                task.wait(0.3)
                            end
                        end
                        if isAutoQuest then
                            fireRemote({{{"General","Quests","Finish",selectedQuest,n=4},"\002"}})
                            task.wait(1)
                        end
                    else task.wait(1) end
                end
            end)
        end
    end
})

-- ============================================================
--  TAB: SUMMON
-- ============================================================
SummonTab:Section({ Title = "Auto Equip" })

SummonTab:Toggle({
    Title = "Auto Equip Best Unit", Icon = "user-check", Type = "Checkbox", Value = Options.AutoEquip or false,
    Callback = function(v)
        isAutoEquip = v Options.AutoEquip = v SaveConfig()
        if isAutoEquip then task.spawn(function() while isAutoEquip do fireRemote({{{"General","Units","EquipBest","Power",n=4},"\002"}}) task.wait(30) end end) end
    end
})

SummonTab:Toggle({
    Title = "Auto Equip Best Accessory", Icon = "gem", Type = "Checkbox", Value = Options.AutoEquipAcc or false,
    Callback = function(v)
        Options.AutoEquipAcc = v SaveConfig()
        if v then task.spawn(function() while Options.AutoEquipAcc do fireRemote({{{"General","Accessories","EquipBest","Power",n=4},"\002"}}) task.wait(60) end end) end
    end
})

SummonTab:Toggle({
    Title = "Auto Equip Best Sword", Icon = "swords", Type = "Checkbox", Value = Options.AutoEquipSword or false,
    Callback = function(v)
        Options.AutoEquipSword = v SaveConfig()
        if v then task.spawn(function() while Options.AutoEquipSword do fireRemote({{{"General","Swords","EquipBest","Power",n=4},"\002"}}) task.wait(60) end end) end
    end
})

SummonTab:Toggle({
    Title = "Auto Awaken", Icon = "zap", Type = "Checkbox", Value = Options.AutoAwaken or false,
    Callback = function(v)
        isAutoAwaken = v Options.AutoAwaken = v SaveConfig()
        if isAutoAwaken then task.spawn(function() while isAutoAwaken do fireRemote({{{"General","Awakening","Awaken",n=3},"\002"}}) task.wait(1) end end) end
    end
})

SummonTab:Divider()
SummonTab:Section({ Title = "Star Summon" })

SummonTab:Dropdown({
    Title    = "Select Star World", Icon = "map-pin",
    Values   = {"Dressrosa","Marine Fortress","Capsule Corp","Dragon Arena","Jura Forest","Tempest Federation"},
    Value    = Options.SelectedStar or "Dressrosa",
    Callback = function(v) selectedStar=v Options.SelectedStar=v SaveConfig() end
})

SummonTab:Toggle({
    Title = "Auto Summon (No Gamepass)", Icon = "star", Desc = "Teleport to Star then open", Type = "Checkbox", Value = Options.AutoSummonNoGP or false,
    Callback = function(v)
        isAutoSummon = v Options.AutoSummonNoGP = v SaveConfig()
        if isAutoSummon then
            task.spawn(function()
                teleportToStar(selectedStar) task.wait(0.5)
                while isAutoSummon do
                    teleportToStar(selectedStar) task.wait(0.2)
                    fireRemote({{{"General","Stars","Open",selectedStar,99,n=5},"\002"}}) task.wait(1)
                end
            end)
        end
    end
})

SummonTab:Toggle({
    Title = "Auto Summon (With Gamepass)", Icon = "star", Type = "Checkbox", Value = Options.AutoSummonGP or false,
    Callback = function(v)
        isAutoSummon = v Options.AutoSummonGP = v SaveConfig()
        if isAutoSummon then
            task.spawn(function()
                while isAutoSummon do fireRemote({{{"General","Stars","Open",selectedStar,99,n=5},"\002"}}) task.wait(1) end
            end)
        end
    end
})

-- ============================================================
--  TAB: UNITS
-- ============================================================
UnitTab:Section({ Title = "Auto Passive Punks" })

local UnitDropdown = UnitTab:Dropdown({
    Title = "Select Unit", Icon = "user", Values = { "Loading..." },
    Callback = function(v)
        if v and v ~= "" and v ~= "Loading..." and v ~= "No Units Found | 0" then
            local s = v:split(" | ")
            if #s > 1 and s[2] ~= "0" then selectedUnitUID = s[2] end
        end
    end
})

task.delay(3, function()
    local list = getUnitList()
    UnitDropdown:Refresh(list)
    if #list > 0 and list[1] ~= "No Units Found | 0" then
        local s = list[1]:split(" | ")
        if #s > 1 and s[2] ~= "0" then selectedUnitUID = s[2] end
    end
end)

UnitTab:Button({
    Title = "Refresh Unit List", Icon = "refresh-cw",
    Callback = function()
        UnitDropdown:Refresh(getUnitList())
        WindUI:Notify({ Title = "Refreshed", Content = "Unit list updated!", Duration = 2 })
    end
})

UnitTab:Dropdown({
    Title = "Target Passive", Icon = "target", Values = getPassiveList(),
    Callback = function(v) selectedTargetPassive = v end
})

UnitTab:Button({
    Title = "Forge Selected Passive", Icon = "hammer",
    Callback = function()
        if selectedUnitUID == "" or selectedUnitUID == "0" or selectedTargetPassive == "" then
            WindUI:Notify({ Title = "Error", Content = "Please select a Unit and Passive first!", Duration = 3 }) return
        end
        local currentPassive = ""
        pcall(function()
            local d = Omni.Data.Inventory.Units[selectedUnitUID]
            if d then currentPassive = d.Passive or "" end
        end)
        if currentPassive == selectedTargetPassive then
            WindUI:Notify({ Title = "Done!", Content = "This unit already has " .. selectedTargetPassive, Duration = 4 }) return
        end
        local config = PassivePunksData[selectedTargetPassive]
        if config and config.Items then
            fireRemote({{{"General","PassivePunks","Forge",selectedUnitUID,config.Items,n=5},"\002"}})
            WindUI:Notify({ Title = "Forge Sent", Content = "Forging: " .. selectedTargetPassive, Duration = 2 })
        else
            WindUI:Notify({ Title = "Error", Content = "Invalid Passive Configuration", Duration = 3 })
        end
    end
})

-- ============================================================
--  TAB: GACHA
-- ============================================================
GachaTab:Section({ Title = "Auto Roll" })

GachaTab:Toggle({ Title="Auto Roll Haki", Icon="dices", Type="Checkbox", Value=Options.AutoHaki or false,
    Callback=function(v) isAutoGacha=v Options.AutoHaki=v SaveConfig()
        if isAutoGacha then task.spawn(function() while isAutoGacha do fireRemote({{{"General","Gacha","Roll","Haki",{},n=5},"\002"}}) task.wait(0.5) end end) end end })

GachaTab:Toggle({ Title="Auto Roll Fruit", Icon="apple", Type="Checkbox", Value=Options.AutoFruit or false,
    Callback=function(v) isAutoFruit=v Options.AutoFruit=v SaveConfig()
        if isAutoFruit then task.spawn(function() while isAutoFruit do fireRemote({{{"General","Gacha","Roll","Fruit",{},n=5},"\002"}}) task.wait(0.5) end end) end end })

GachaTab:Toggle({ Title="Auto Roll Sword", Icon="swords", Type="Checkbox", Value=Options.AutoSword or false,
    Callback=function(v) isAutoSword=v Options.AutoSword=v SaveConfig()
        if isAutoSword then task.spawn(function() while isAutoSword do fireRemote({{{"General","Banner","Roll","Swords Banner",n=4},"\002"}}) task.wait(0.5) end end) end end })

GachaTab:Toggle({ Title="Auto Roll Race", Icon="dna", Type="Checkbox", Value=Options.AutoRace or false,
    Callback=function(v) isAutoRollRace=v Options.AutoRace=v SaveConfig()
        if isAutoRollRace then task.spawn(function() while isAutoRollRace do fireRemote({{{"General","Gacha","Roll","Race",{},n=5},"\002"}}) task.wait(0.5) end end) end end })

GachaTab:Toggle({ Title="Auto Spin Wheel", Icon="ferris-wheel", Type="Checkbox", Value=Options.AutoSpinWheel or false,
    Callback=function(v) isAutoRollFightStyle=v Options.AutoSpinWheel=v SaveConfig()
        if isAutoRollFightStyle then task.spawn(function() while isAutoRollFightStyle do fireRemote({{{"General","Roulette","Roll","Dragon Wish",{},n=4},"\002"}}) task.wait(0.5) end end) end end })

GachaTab:Toggle({ Title="Auto Roll Dragon Power", Icon="activity", Type="Checkbox", Value=Options.AutoDragonPower or false,
    Callback=function(v) isAutoRollClass=v Options.AutoDragonPower=v SaveConfig()
        if isAutoRollClass then task.spawn(function() while isAutoRollClass do fireRemote({{{"General","Gacha","Roll","Dragon Power",{},n=5},"\002"}}) task.wait(0.5) end end) end end })

GachaTab:Toggle({ Title="Auto Roll Slime Power", Icon="panda", Type="Checkbox", Value=Options.AutoSlimePower or false,
    Callback=function(v) isAutoRollSlimePower=v Options.AutoSlimePower=v SaveConfig()
        if isAutoRollSlimePower then task.spawn(function() while isAutoRollSlimePower do fireRemote({{{"General","Gacha","Roll","Slime Power",{},n=5},"\002"}}) task.wait(0.5) end end) end end })

GachaTab:Toggle({ Title="Auto Roll Primordial Demon", Icon="flame", Type="Checkbox", Value=Options.AutoPrimordial or false,
    Callback=function(v) isAutoPrimordial=v Options.AutoPrimordial=v SaveConfig()
        if isAutoPrimordial then task.spawn(function() while isAutoPrimordial do fireRemote({{{"General","Gacha","Roll","Primordial Demon",{},n=5},"\002"}}) task.wait(0.5) end end) end end })

-- ============================================================
--  TAB: UPGRADE
-- ============================================================
UpgradeTab:Section({ Title = "Auto Upgrade" })

UpgradeTab:Toggle({ Title="Auto Upgrade Fighting Style", Icon="dumbbell", Type="Checkbox", Value=Options.AutoFightStyle or false,
    Callback=function(v) isAutoFightStyle=v Options.AutoFightStyle=v SaveConfig()
        if isAutoFightStyle then task.spawn(function() while isAutoFightStyle do fireRemote({{{"General","Progression","Upgrade","Fighting Style",n=4},"\002"}}) task.wait(0.5) end end) end end })

UpgradeTab:Toggle({ Title="Auto Upgrade Ki Progression", Icon="flame", Type="Checkbox", Value=Options.AutoKiProgression or false,
    Callback=function(v) isAutoKiProgression=v Options.AutoKiProgression=v SaveConfig()
        if isAutoKiProgression then task.spawn(function() while isAutoKiProgression do fireRemote({{{"General","Progression","Upgrade","Ki Progression",n=4},"\002"}}) task.wait(0.5) end end) end end })

UpgradeTab:Toggle({ Title="Auto Upgrade Aura", Icon="lollipop", Type="Checkbox", Value=Options.AutoAura or false,
    Callback=function(v) isAutoAura=v Options.AutoAura=v SaveConfig()
        if isAutoAura then task.spawn(function() while isAutoAura do fireRemote({{{"General","Aura","Upgrade",n=3},"\002"}}) task.wait(0.5) end end) end end })

UpgradeTab:Toggle({ Title="Auto Upgrade Demon Lord", Icon="shrub", Type="Checkbox", Value=Options.AutoDemonLord or false,
    Callback=function(v) isAutoDemonlord=v Options.AutoDemonLord=v SaveConfig()
        if isAutoDemonlord then task.spawn(function() while isAutoDemonlord do fireRemote({{{"General","Progression","Upgrade","Demon Lord Progression",n=4},"\002"}}) task.wait(0.5) end end) end end })

-- ============================================================
-- AUTO DELETE TAB 
-- ============================================================

local rarityOrder = {"Legendary", "Epic", "Rare", "Uncommon", "Common"}

local function loadSavedRarities(prefix)
    local saved = {}
    for _, r in ipairs(rarityOrder) do
        if Options[prefix .. r] then
            table.insert(saved, r)
        end
    end
    return saved
end

local selectedDeleteAcc   = loadSavedRarities("Del_")
local selectedDeleteSword = loadSavedRarities("DelSword_")

local function isRaritySelected(list, rarity)
    for _, v in ipairs(list) do
        if v == rarity then return true end
    end
    return false
end

isAutoDelete = Options.AutoDeleteEnabled or false



AutoDeleteTab:Dropdown({
    Title    = "Acc Rarities to Delete",
    Icon     = "gem",
    Values   = rarityOrder,
    Value    = selectedDeleteAcc,
    Multi    = true,
    AllowNone = true,
    Callback = function(v)
        if type(v) == "table" then
            selectedDeleteAcc = v
        elseif type(v) == "string" then
            selectedDeleteAcc = {v}
        else
            selectedDeleteAcc = {}
        end
        for _, r in ipairs(rarityOrder) do
            Options["Del_" .. r] = isRaritySelected(selectedDeleteAcc, r)
        end
        SaveConfig()
    end
})

AutoDeleteTab:Dropdown({
    Title    = "Sword Rarities to Delete",
    Icon     = "swords",
    Values   = rarityOrder,
    Value    = selectedDeleteSword,
    Multi    = true,
    AllowNone = true,
    Callback = function(v)
        if type(v) == "table" then
            selectedDeleteSword = v
        elseif type(v) == "string" then
            selectedDeleteSword = {v}
        else
            selectedDeleteSword = {}
        end
        for _, r in ipairs(rarityOrder) do
            Options["DelSword_" .. r] = isRaritySelected(selectedDeleteSword, r)
        end
        SaveConfig()
    end
})
AutoDeleteTab:Toggle({
    Title = "Enable Auto Delete",
    Icon  = "trash-2",
    Type  = "Checkbox",
    Value = Options.AutoDeleteEnabled or false,
    Callback = function(v)
        isAutoDelete = v
        Options.AutoDeleteEnabled = v
        SaveConfig()
        if isAutoDelete then
            task.spawn(function()
                while isAutoDelete do
                    pcall(function()
                        local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
                        local categories = playerGui.UI.Frames.Inventory.Background.Categories

                        local function formatRarity(rawStr)
                            local str = tostring(rawStr)
                            if str == "" or str == "nil" then return "Unknown" end
                            return str:sub(1,1):upper() .. str:sub(2):lower()
                        end

                        local okAccs, accsList = pcall(function()
                            return categories.Accessories.Canvas.List
                        end)

                        if okAccs and accsList then
                            for _, itemNode in ipairs(accsList:GetChildren()) do
                                if not isAutoDelete then break end

                                if itemNode:IsA("GuiObject") then
                                    local uid = itemNode.Name

                                    local isEquipped = itemNode:FindFirstChild("Equipped") or (itemNode:FindFirstChild("Background") and itemNode.Background:FindFirstChild("Equipped"))
                                    if isEquipped and isEquipped.Visible then continue end

                                    local rarityNode = itemNode:FindFirstChild("Background") and itemNode.Background:FindFirstChild("Rarity")
                                    if rarityNode then
                                        local rawRarity = ""
                                        if rarityNode:IsA("TextLabel") or rarityNode:IsA("TextBox") then
                                            rawRarity = rarityNode.ContentText ~= "" and rarityNode.ContentText or rarityNode.Text
                                        elseif rarityNode:IsA("StringValue") then
                                            rawRarity = rarityNode.Value
                                        end

                                        local rarity = formatRarity(rawRarity)

                                        if isRaritySelected(selectedDeleteAcc, rarity) then
                                            print("[Auto Delete] Trashing Acc UID:", uid, "| Rarity:", rarity)
                                            fireRemote({{{ "General", "Accessories", "Delete", { tostring(uid) }, n = 4 }, "\002" }})
                                            task.wait(0.2)
                                        end
                                    end
                                end
                            end
                        end

                        local okSwords, swordsList = pcall(function()
                            return categories.Swords.Canvas.List
                        end)

                        if okSwords and swordsList then
                            for _, itemNode in ipairs(swordsList:GetChildren()) do
                                if not isAutoDelete then break end

                                if itemNode:IsA("GuiObject") then
                                    local uid = itemNode.Name

                                    local isEquipped = itemNode:FindFirstChild("Equipped") or (itemNode:FindFirstChild("Background") and itemNode.Background:FindFirstChild("Equipped"))
                                    if isEquipped and isEquipped.Visible then continue end

                                    local rarityNode = itemNode:FindFirstChild("Background") and itemNode.Background:FindFirstChild("Rarity")
                                    if rarityNode then
                                        local rawRarity = ""
                                        if rarityNode:IsA("TextLabel") or rarityNode:IsA("TextBox") then
                                            rawRarity = rarityNode.ContentText ~= "" and rarityNode.ContentText or rarityNode.Text
                                        elseif rarityNode:IsA("StringValue") then
                                            rawRarity = rarityNode.Value
                                        end

                                        local rarity = formatRarity(rawRarity)

                                        if isRaritySelected(selectedDeleteSword, rarity) then
                                            print("[Auto Delete] Trashing Sword UID:", uid, "| Rarity:", rarity)
                                            fireRemote({{{ "General", "Swords", "Delete", { tostring(uid) }, n = 4 }, "\002" }})
                                            task.wait(0.1)
                                        end
                                    end
                                end
                            end
                        end

                    end)
                    task.wait(5)
                end
            end)
        end
    end
})

AutoDeleteTab:Divider()
-- ============================================================
--  TAB: MISC
-- ============================================================
local redeemCodesList = {
    "RELEASE","SRRY4SHUTDOWN","SRRY4SHUTDOWN2","TIOGADIHIT!",
    "THX1KCCU","2KCCU!","THANKYOU3KCCU","4KONCHAMBER!",
    "ALREADY5K?","6KTHXSOMUCH","7KISALOT!","THANKS1KLIKES",
    "100KVISITSONCHAMBER!","SRRY4SHUTDOWN3","RELEASEPATCH",
    "TY2KLIKES!!","THXFOR200KVISITS!","300KVISITSTHANKYOU!",
    "400KVISITSINCREDIBLE","WOW500KVISITS!","1KFAVORITESTHX!",
    "RELEASEPT2","EVENT2.5K!",
}
Options.RedeemedCodes = Options.RedeemedCodes or {}

MiscTab:Section({ Title = "Codes" })

MiscTab:Button({
    Title = "Redeem New Codes", Icon = "ticket",
    Callback = function()
        task.spawn(function()
            local count = 0
            for _, code in ipairs(redeemCodesList) do
                if not Options.RedeemedCodes[code] then
                    fireRemote({{{"General","Codes","Redeem",code,n=4},"\002"}})
                    Options.RedeemedCodes[code] = true
                    count = count + 1
                    task.wait(2.5)
                end
            end
            SaveConfig()
            if count > 0 then
                WindUI:Notify({ Title = "Codes Redeemed", Content = "Redeemed " .. count .. " new code(s)!", Duration = 3 })
            else
                WindUI:Notify({ Title = "No New Codes", Content = "All codes have been redeemed!", Duration = 3 })
            end
        end)
    end
})

MiscTab:Button({
    Title = "Reset Redeemed History", Icon = "rotate-ccw",
    Callback = function()
        Options.RedeemedCodes = {}
        SaveConfig()
        WindUI:Notify({ Title = "Cleared", Content = "Redeemed code history cleared!", Duration = 3 })
    end
})

MiscTab:Divider()
MiscTab:Section({ Title = "Auto Rewards" })

MiscTab:Toggle({
    Title = "Auto Collect Time Reward", Icon = "clock", Type = "Checkbox", Value = Options.AutoTimeReward or false,
    Callback = function(v)
        isAutoReward = v Options.AutoTimeReward = v SaveConfig()
        if isAutoReward then
            task.spawn(function()
                while isAutoReward do
                    local okR, resetBtn = pcall(function() return player.PlayerGui.UI.Frames.TimeRewards.Background.Main.Reset end)
                    if okR and resetBtn and resetBtn.Visible then
                        fireRemote({{{ "General","TimeRewards","Reset",n=3 },"\002"}}) task.wait(0.5)
                    end
                    for i = 1, 7 do
                        if not isAutoReward then break end
                        local ok, tt = pcall(function()
                            local obj = player.PlayerGui.UI.Frames.TimeRewards.Background.Main.Rewards[tostring(i)].Main.Time
                            return (obj:IsA("TextLabel") or obj:IsA("TextBox")) and (obj.ContentText ~= "" and obj.ContentText or obj.Text) or tostring(obj.Text)
                        end)
                        if ok and type(tt) == "string" and string.lower(tt) == "ready" then
                            fireRemote({{{ "General","TimeRewards","Claim",i,n=4 },"\002"}}) task.wait(0.3)
                        end
                    end
                    task.wait(5)
                end
            end)
        end
    end
})

MiscTab:Toggle({
    Title = "Auto Claim Daily Reward", Icon = "calendar", Type = "Checkbox", Value = Options.AutoDailyReward or false,
    Callback = function(v)
        isAutoDailyReward = v Options.AutoDailyReward = v SaveConfig()
        if isAutoDailyReward then
            task.spawn(function()
                while isAutoDailyReward do
                    for i = 1, 7 do
                        if not isAutoDailyReward then break end
                        local ok, tt = pcall(function()
                            local obj = player.PlayerGui.UI.Frames.DailyRewards.Background.Main.Rewards[tostring(i)].Main.Time
                            return (obj:IsA("TextLabel") or obj:IsA("TextBox")) and (obj.ContentText ~= "" and obj.ContentText or obj.Text) or tostring(obj.Text)
                        end)
                        if ok and type(tt) == "string" and string.lower(tt) == "ready" then
                            fireRemote({{{"General","DailyRewards","Claim",i,n=4},"\002"}}) task.wait(0.3)
                        end
                    end
                    task.wait(60)
                end
            end)
        end
    end
})

MiscTab:Toggle({
    Title = "Auto Claim Achievement", Icon = "award", Type = "Checkbox", Value = Options.AutoAchieve or false,
    Callback = function(v)
        isAutoAchieve = v Options.AutoAchieve = v SaveConfig()
        for _, conn in ipairs(achieveConnections) do if conn.Connected then conn:Disconnect() end end
        achieveConnections = {}
        if isAutoAchieve then
            task.spawn(function()
                local ok, list = pcall(function() return player.PlayerGui.UI.Frames.Achievements.Background.Main.List end)
                if not (ok and list) then return end

                local function checkAndClaim(text)
                    if not isAutoAchieve then return end
                    local p = text:match("(%d+%.?%d*)")
                    if p and tonumber(p) and tonumber(p) >= 100 and not isClaimingAchieve then
                        isClaimingAchieve = true
                        fireRemote({{{ "General","Achievements","ClaimAll",n=3 },"\002" }})
                        task.wait(2) isClaimingAchieve = false
                    end
                end

                local function hookTitle(title)
                    checkAndClaim(title.ContentText ~= "" and title.ContentText or title.Text)
                    local c1 = title:GetPropertyChangedSignal("Text"):Connect(function() checkAndClaim(title.Text) end)
                    local c2 = title:GetPropertyChangedSignal("ContentText"):Connect(function() checkAndClaim(title.ContentText) end)
                    table.insert(achieveConnections, c1) table.insert(achieveConnections, c2)
                end

                local function setupItem(item)
                    if item:IsA("GuiObject") then
                        local title = item:FindFirstChild("Background") and item.Background:FindFirstChild("Main")
                            and item.Background.Main:FindFirstChild("Progress") and item.Background.Main.Progress:FindFirstChild("Title")
                        if title then hookTitle(title)
                        else
                            local c3 = item.DescendantAdded:Connect(function(desc)
                                if desc.Name == "Title" and desc.Parent and desc.Parent.Name == "Progress" then hookTitle(desc) end
                            end)
                            table.insert(achieveConnections, c3)
                        end
                    end
                end

                for _, item in ipairs(list:GetChildren()) do setupItem(item) end
                local c4 = list.ChildAdded:Connect(function(child) task.wait(0.1) setupItem(child) end)
                table.insert(achieveConnections, c4)
            end)
        end
    end
})

-- ============================================================
--  TAB: SETTINGS
-- ============================================================
local notifConnection = nil

SettingTab:Section({ Title = "General" })

SettingTab:Keybind({
    Title = "Toggle UI Key", Desc = "Keybind to show/hide the window",
    Value = Options.ToggleUIKey or "RightControl",
    Callback = function(v)
        Options.ToggleUIKey = tostring(v) SaveConfig()
        local key = typeof(v) == "EnumItem" and v or Enum.KeyCode[v]
        Window:SetToggleKey(key)
    end
})

SettingTab:Toggle({
    Title = "Anti AFK", Icon = "shield", Type = "Checkbox", Value = Options.AntiAFK or false,
    Callback = function(v)
        Options.AntiAFK = v SaveConfig()
        fireRemote({{{"General","Settings","Set","Anti Afk",v,n=5},"\002"}})
    end
})

SettingTab:Toggle({
    Title = "Hide Game Notifications", Icon = "eye-off", Desc = "Hide Notify messages", Type = "Checkbox", Value = Options.HideNotif or false,
    Callback = function(v)
        Options.HideNotif = v SaveConfig()
        if v then
            task.spawn(function()
                local ok, list = pcall(function() return player.PlayerGui.Notifications.List end)
                if not (ok and list) then return end
                local function checkAndHide(child)
                    task.wait(0.05)
                    for _, desc in ipairs(child:GetDescendants()) do
                        if desc:IsA("TextLabel") or desc:IsA("TextBox") then
                            local text = desc.ContentText ~= "" and desc.ContentText or desc.Text
                            if text and string.find(text, "^You don't") then child.Visible = false break end
                        end
                    end
                end
                for _, child in ipairs(list:GetChildren()) do checkAndHide(child) end
                notifConnection = list.ChildAdded:Connect(checkAndHide)
            end)
        else
            if notifConnection then notifConnection:Disconnect() notifConnection = nil end
            local ok, list = pcall(function() return player.PlayerGui.Notifications.List end)
            if ok and list then for _, child in ipairs(list:GetChildren()) do if child:IsA("GuiObject") then child.Visible = true end end end
        end
    end
})

SettingTab:Divider()
SettingTab:Section({ Title = "Performance & Network" })

SettingTab:Toggle({
    Title = "Auto Rejoin", Icon = "plug", Desc = "Reconnect automatically on disconnect", Type = "Checkbox", Value = Options.AutoRejoin or false,
    Callback = function(v)
        Options.AutoRejoin = v SaveConfig()
        if v then
            task.spawn(function()
                local CoreGui2        = game:GetService("CoreGui")
                local TeleportService = game:GetService("TeleportService")
                local promptOverlay   = CoreGui2:WaitForChild("RobloxPromptGui"):WaitForChild("promptOverlay")
                if not getgenv().RejoinConnection then
                    getgenv().RejoinConnection = promptOverlay.ChildAdded:Connect(function(child)
                        if Options.AutoRejoin and child.Name == "ErrorPrompt" then
                            task.wait(5)
                            TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
                        end
                    end)
                end
            end)
        end
    end
})

SettingTab:Toggle({
    Title = "Wipe VFX All (Anti-Lag)", Icon = "eye-off", Desc = "Disable particles, trails, beams, etc.", Type = "Checkbox", Value = Options.WipeVFX or false,
    Callback = function(v)
        Options.WipeVFX = v SaveConfig()
        if v then
            task.spawn(function()
                while Options.WipeVFX do
                    pcall(function()
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
                            or obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("Smoke") then
                                obj.Enabled = false
                            end
                        end
                        local cf = workspace:FindFirstChild("Client")
                        if cf and cf:FindFirstChild("VFX") then cf.VFX:ClearAllChildren() end
                        if workspace:FindFirstChild("VFX") then workspace.VFX:ClearAllChildren() end
                    end)
                    task.wait(2)
                end
            end)
        end
    end
})

-- Anti-AFK background loop
task.spawn(function()
    local VirtualUser = game:GetService("VirtualUser")
    local VIM         = game:GetService("VirtualInputManager")
    while true do
        task.wait(120)
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
        pcall(function()
            VIM:SendKeyEvent(true,  Enum.KeyCode.Space, false, game)
            task.wait(0.1)
            VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
        end)
    end
end)

-- ============================================================
--  STARTUP
-- ============================================================
task.defer(function()
    WindUI:Notify({ Title = "Ghost Hub", Content = "Config loaded successfully! v0.0.6", Duration = 3 })
    if Options.AntiAFK then
        fireRemote({{{"General","Settings","Set","Anti Afk",true,n=5},"\002"}})
    end
end)

FarmTab:Select()

-- ============================================================
--  DRAGGABLE TOGGLE BUTTON
-- ============================================================
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "WFSToggleGui"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local targetGui = (gethui and gethui()) or (pcall(function() return CoreGui.Name end) and CoreGui) or player.PlayerGui
ScreenGui.Parent = targetGui

local ToggleBtn = Instance.new("ImageButton")
ToggleBtn.Name                 = "ToggleButton"
ToggleBtn.Parent               = ScreenGui
ToggleBtn.BackgroundTransparency = 1
ToggleBtn.Position             = UDim2.new(0.5, 0, 0, 40)
ToggleBtn.Size                 = UDim2.new(0, 50, 0, 50)
ToggleBtn.Image                = "rbxassetid://110552700896064"
ToggleBtn.AnchorPoint          = Vector2.new(0.5, 0.5)

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(1, 0)
UICorner2.Parent       = ToggleBtn

local UIStroke2 = Instance.new("UIStroke")
UIStroke2.Parent          = ToggleBtn
UIStroke2.Thickness       = 2
UIStroke2.Color           = Color3.fromRGB(124, 58, 237)
UIStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local dragging, dragStart, startPos

ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = ToggleBtn.Position
        TweenService:Create(ToggleBtn, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Size = UDim2.new(0,42,0,42)}):Play()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            dragging = false
            TweenService:Create(ToggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Size = UDim2.new(0,50,0,50)}):Play()
            if dragStart and (input.Position - dragStart).Magnitude < 10 then
                local vim = game:GetService("VirtualInputManager")
                local keyStr = Options.ToggleUIKey or "RightControl"
                local key = typeof(keyStr) == "EnumItem" and keyStr or Enum.KeyCode[keyStr]
                if not key then key = Enum.KeyCode.RightControl end
                vim:SendKeyEvent(true,  key, false, game) task.wait(0.05)
                vim:SendKeyEvent(false, key, false, game)
            end
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
        local delta = input.Position - dragStart
        ToggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ============================================================
--  CUSTOM PLAYER HUD
-- ============================================================
local function customizePlayerHUD()
    local lp        = Players.LocalPlayer
    local character = lp.Character or lp.CharacterAdded:Wait()
    local head      = character:WaitForChild("Head", 10)
    if not head then return end
    local playerHUD = head:WaitForChild("PlayerHUD", 5)
    local mainUI    = playerHUD and playerHUD:FindFirstChild("Main")
    if mainUI then
        local titleUID2 = mainUI:FindFirstChild("Title")
        if titleUID2 then
            titleUID2.Text       = "discord.gg/GhostHub"
            titleUID2.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
        local titleUID = mainUI:FindFirstChild("Title") and mainUI.Title:FindFirstChild("UID")
        if titleUID then titleUID.Visible = false end
        local roleUID2 = mainUI:FindFirstChild("Role")
        if roleUID2 then
            roleUID2.RichText = true
            roleUID2.Text     = "<b><font color='#7c3aed'>[ GHOST HUB ]</font></b>"
        end
        local roleUID = mainUI:FindFirstChild("Role") and mainUI.Role:FindFirstChild("UID")
        if roleUID then roleUID.Visible = false end
        local titleSystem = mainUI:FindFirstChild("TitleSystem")
        if titleSystem then titleSystem.Visible = false end
    end
end

task.spawn(customizePlayerHUD)
Players.LocalPlayer.CharacterAdded:Connect(function()
    task.wait(3) customizePlayerHUD()
end)
task.spawn(function()
    while task.wait(5) do customizePlayerHUD() end
end)
