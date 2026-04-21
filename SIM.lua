if game.PlaceId ~= 95630541662383 then
    warn("Failed to load: This script only supports World Fighter Simulator")
    return
end

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
WindUI:SetNotificationLower(true)

WindUI:AddTheme({
    Name                        = "GhostHub",
    Accent                      = Color3.fromHex("#1a0a0a"),
    Background                  = Color3.fromHex("#0d0d0d"),
    BackgroundTransparency      = 0,
    Outline                     = Color3.fromHex("#c0392b"),
    Text                        = Color3.fromHex("#f0f0f0"),
    Placeholder                 = Color3.fromHex("#7a3030"),
    Button                      = Color3.fromHex("#7f1d1d"),
    Icon                        = Color3.fromHex("#e87070"),
    Hover                       = Color3.fromHex("#f0f0f0"),
    WindowBackground            = Color3.fromHex("#0d0d0d"),
    WindowShadow                = Color3.fromHex("#000000"),
    DialogBackground            = Color3.fromHex("#0d0d0d"),
    DialogBackgroundTransparency = 0,
    DialogTitle                 = Color3.fromHex("#f0f0f0"),
    DialogContent               = Color3.fromHex("#cccccc"),
    DialogIcon                  = Color3.fromHex("#e87070"),
    WindowTopbarButtonIcon      = Color3.fromHex("#e87070"),
    WindowTopbarTitle           = Color3.fromHex("#f0f0f0"),
    WindowTopbarAuthor          = Color3.fromHex("#cccccc"),
    WindowTopbarIcon            = Color3.fromHex("#f0f0f0"),
    TabBackground               = Color3.fromHex("#1a0a0a"),
    TabTitle                    = Color3.fromHex("#f0f0f0"),
    TabIcon                     = Color3.fromHex("#e87070"),
    ElementBackground           = Color3.fromHex("#1f0d0d"),
    ElementTitle                = Color3.fromHex("#f0f0f0"),
    ElementDesc                 = Color3.fromHex("#aaaaaa"),
    ElementIcon                 = Color3.fromHex("#e87070"),
    PopupBackground             = Color3.fromHex("#0d0d0d"),
    PopupBackgroundTransparency = 0,
    PopupTitle                  = Color3.fromHex("#f0f0f0"),
    PopupContent                = Color3.fromHex("#cccccc"),
    PopupIcon                   = Color3.fromHex("#e87070"),
    Toggle                      = Color3.fromHex("#7f1d1d"),
    ToggleBar                   = Color3.fromHex("#e84040"),
    Checkbox                    = Color3.fromHex("#7f1d1d"),
    CheckboxIcon                = Color3.fromHex("#f0f0f0"),
    Slider                      = Color3.fromHex("#7f1d1d"),
    SliderThumb                 = Color3.fromHex("#e84040"),
})
local Window = WindUI:CreateWindow({
    Title                       = "World Fighter - Ghost Hub",
    Icon                        = "rbxassetid://110552700896064",
    Author                      = "by TEN",
    Folder                      = "GhostHub/WFS",
    Size                        = UDim2.fromOffset(600, 480),
    MinSize                     = Vector2.new(560, 350),
    MaxSize                     = Vector2.new(850, 560),
    Transparent                 = true,
    Theme                       = "GhostHub",
    AccentColor                 = Color3.fromHex("#c0392b"),
    Resizable                   = true,
    SideBarWidth                = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar               = true,
    ScrollBarEnabled            = false,
})

Window:Tag({Title="v0.0.5",  Icon="",      Color=Color3.fromHex("#30ff6a"), Radius=0})
Window:Tag({Title="GhostHub",Icon="crown", Color=Color3.fromHex("#7c3aed"), Radius=6})

task.defer(function()
    Window:SetToggleKey(Enum.KeyCode.LeftControl)
end)

local FarmTab    = Window:Tab({ Title="Farming",  Icon="swords" })
local GamemodeTab = Window:Tab({ Title="Gamemode", Icon="gamepad-2" })
local QuestTab   = Window:Tab({ Title="Quest",    Icon="list"   })
local SummonTab  = Window:Tab({ Title="Summon",   Icon="star"   })
local MiscTab    = Window:Tab({ Title="Misc",     Icon="gift"   })
local GachaTab   = Window:Tab({ Title="Gacha",    Icon="dices"  })
local UpgradeTab = Window:Tab({ Title="Upgrade",  Icon="arrow-up" })
local AutoDeleteTab = Window:Tab({ Title="Auto Delete", Icon="trash" })
local SettingTab = Window:Tab({ Title="Settings", Icon="cog"    })

-- ============================================================
-- Config System
-- ============================================================
local HttpService = game:GetService("HttpService")
local Options = {}

local function GetConfigPath()
    local userId = game.Players.LocalPlayer.UserId
    local file = tostring(userId) .. "_WFS"
    return "WFS_GH/" .. file .. ".json"
end

local lastSaveRequest = 0
local function SaveConfig()
    lastSaveRequest = tick()
    local currentRequest = lastSaveRequest
    task.delay(1, function()
        if lastSaveRequest ~= currentRequest then return end
        if not (writefile and makefolder) then return end
        local path = GetConfigPath()
        local folder = path:match("(.+)/")
        if not isfolder(folder) then
            local parts = folder:split("/")
            local current = ""
            for _, part in ipairs(parts) do
                current = current .. part
                if not isfolder(current) then makefolder(current) end
                current = current .. "/"
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
-- State Variables
-- ============================================================
local isAttacking         = false
local isAutoSecretBoss    = false  
local isFastFarming       = false
local isAutoFarm          = false
local isAutoEquip         = false
local isAutoAwaken        = false
local isAutoSummon        = false
local isAutoQuest         = false
local isAutoReward        = false
local isAutoAchieve       = false
local isAutoDailyReward   = false
local isAutoGacha         = false
local isAutoFruit         = false
local isAutoSword         = false
local isAutoRollRace      = false
local isAutoFightStyle    = false
local isAutoKiProgression = false
local isAutoDragonDefense = false
local isAutoAura          = false
local isAutoDemonlord     = false
local isAutoRollFightStyle = false
local isAutoRollClass      = false
local isAutoRollSlimePower = false
local isAutoDelete         = false  

local achieveConnections  = {}
local isClaimingAchieve   = false

local isAutoTrial       = false
local trialTargetWave   = Options.LeaveAtWave or 10
local isAutoLeaveTrial  = false
local isAutoFarmTrial   = false
local preTrialWorld     = ""
local preTrialZone      = 1
local isInsideTrial     = false

local selectedFarmEnemies = Options.SelectedEnemies or {}
local selectedStar        = Options.SelectedStar or "Dressrosa"
local selectedQuest       = Options.SelectedQuest or ""

local Players = game:GetService("Players")
local RS      = game:GetService("ReplicatedStorage")
local player  = Players.LocalPlayer
local dataRemoteEvent  = RS:WaitForChild("BridgeNet"):WaitForChild("dataRemoteEvent")
local serverEnemiesWorld = workspace:WaitForChild("Server"):WaitForChild("Enemies"):WaitForChild("World")

local function fireRemote(args)
    dataRemoteEvent:FireServer(unpack(args))
end

local function getCurrentWorldName()
    local char  = player.Character
    local myHRP = char and char:FindFirstChild("HumanoidRootPart")
    if not myHRP then return "", 1 end

    local myPos        = myHRP.Position
    local shortestDist = math.huge
    local bestWorld    = ""
    local bestZone     = 1

    for _, worldMap in ipairs(serverEnemiesWorld:GetChildren()) do
        for _, group in ipairs(worldMap:GetChildren()) do
            local enemy = group:FindFirstChildWhichIsA("Model") or group:FindFirstChildWhichIsA("BasePart")
            if enemy then
                local pos = enemy:IsA("Model") and enemy:GetPivot().Position or enemy.Position
                if pos then
                    local dist = (pos - myPos).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        bestWorld    = worldMap.Name
                        bestZone     = tonumber(group.Name) or 1
                    end
                end
            end
        end
    end
    return bestWorld, bestZone
end

-- ============================================================
-- Difficulty Dictionary & Sorting
-- ============================================================
local DifficultyRanks = {
    ["EASY"]   = 1,
    ["MEDIUM"] = 2,
    ["HARD"]   = 3,
    ["INSANE"] = 4,
    ["BOSS"]   = 5,
    ["SECRET"] = 6
}

local function getEnemyDifficulty(enemyName)
    local score = 0
    local ok, subtitle = pcall(function()
        return workspace.Client.Enemies[enemyName].Head.EnemyHUD.Main.Subtitle
    end)

    if ok and subtitle then
        local rawText = ""
        if subtitle:IsA("TextLabel") or subtitle:IsA("TextBox") then
            rawText = subtitle.ContentText ~= "" and subtitle.ContentText or subtitle.Text
        elseif subtitle:IsA("StringValue") then
            rawText = subtitle.Value
        end
        
        local upperText = string.upper(tostring(rawText))
        
        for diffWord, diffScore in pairs(DifficultyRanks) do
            if string.find(upperText, diffWord) then
                if diffScore > score then
                    score = diffScore
                end
            end
        end
        
        if score == 0 then
            local num = string.match(upperText, "%d+")
            if num then score = tonumber(num) end
        end
    end
    
    return score
end

local function getWorldsList()
    local names = {}
    for _, worldMap in ipairs(serverEnemiesWorld:GetChildren()) do
        table.insert(names, worldMap.Name)
    end
    table.sort(names)
    return names
end

local function getZonesList(worldName)
    local names = {}
    local world = serverEnemiesWorld:FindFirstChild(tostring(worldName))
    if world then
        for _, group in ipairs(world:GetChildren()) do
            table.insert(names, group.Name)
        end
    end
    table.sort(names, function(a, b) 
        return (tonumber(a) or 0) < (tonumber(b) or 0) 
    end)
    return names
end

local function getEnemiesList(worldName, zoneName)
    local names = {}
    local dict = {}
    local world = serverEnemiesWorld:FindFirstChild(tostring(worldName))
    if world then
        local zone = world:FindFirstChild(tostring(zoneName))
        if zone then
            for _, enemy in ipairs(zone:GetChildren()) do
                if not dict[enemy.Name] then
                    dict[enemy.Name] = true
                    table.insert(names, enemy.Name)
                end
            end
        end
    end
    
    table.sort(names, function(nameA, nameB)
        local diffA = getEnemyDifficulty(nameA)
        local diffB = getEnemyDifficulty(nameB)
        if diffA ~= diffB then return diffA > diffB end
        return nameA < nameB
    end)
    
    return names
end

local function scanTrialFolder(folder, bestTarget, bestID, shortestDist, myPos)
    for _, child in ipairs(folder:GetChildren()) do
        local sID    = child:GetAttribute("ID")
        local isDead = child:GetAttribute("Died")
        local hp     = child:GetAttribute("Health")

        if sID and not isDead and (not hp or tonumber(hp) > 0) then
            local tp = child:IsA("Model") and child:GetPivot().Position or (child:IsA("BasePart") and child.Position)
            if tp then
                local dist = (tp - myPos).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    bestTarget   = child
                    bestID       = sID
                end
            end
        else
            if child:IsA("Folder") or child:IsA("Model") then
                for _, sub in ipairs(child:GetChildren()) do
                    local sID2    = sub:GetAttribute("ID")
                    local isDead2 = sub:GetAttribute("Died")
                    local hp2     = sub:GetAttribute("Health")

                    if sID2 and not isDead2 and (not hp2 or tonumber(hp2) > 0) then
                        local tp2 = sub:IsA("Model") and sub:GetPivot().Position or (sub:IsA("BasePart") and sub.Position)
                        if tp2 then
                            local dist = (tp2 - myPos).Magnitude
                            if dist < shortestDist then
                                shortestDist = dist
                                bestTarget   = sub
                                bestID       = sID2
                            end
                        end
                    end
                end
            end
        end
    end
    return bestTarget, bestID, shortestDist
end

local function getTrialTarget()
    local char  = player.Character
    local myHRP = char and char:FindFirstChild("HumanoidRootPart")
    local myPos = myHRP and myHRP.Position or Vector3.zero

    local bestTarget   = nil
    local bestID       = nil
    local shortestDist = math.huge

    local ok1, t1 = pcall(function() return workspace.Server.Enemies.Gamemodes["Trial Easy"] end)
    if ok1 and t1 then
        bestTarget, bestID, shortestDist = scanTrialFolder(t1, bestTarget, bestID, shortestDist, myPos)
    end

    local ok2, t2 = pcall(function() return workspace.Client.Enemies end)
    if ok2 and t2 then
        bestTarget, bestID, shortestDist = scanTrialFolder(t2, bestTarget, bestID, shortestDist, myPos)
    end

    return bestTarget, bestID
end

local function getValidTarget()
    local currentWorld, _ = getCurrentWorldName()
    if currentWorld == "" then return nil, nil end
    local targetWorld = serverEnemiesWorld:FindFirstChild(currentWorld)
    if not targetWorld then return nil, nil end

    local char  = player.Character
    local myHRP = char and char:FindFirstChild("HumanoidRootPart")
    local myPos = myHRP and myHRP.Position or Vector3.zero

    local bestTarget   = nil
    local bestID       = nil
    local highestDiff  = -1
    local shortestDist = math.huge

    for _, group in ipairs(targetWorld:GetChildren()) do
        for _, serverEnemy in ipairs(group:GetChildren()) do
            local isDead = serverEnemy:GetAttribute("Died")
            local hp     = serverEnemy:GetAttribute("Health")

            if not isDead and (not hp or tonumber(hp) > 0) then
                local isAllowed = (#selectedFarmEnemies == 0)
                if not isAllowed then
                    for _, allowedName in ipairs(selectedFarmEnemies) do
                        if serverEnemy.Name == allowedName then
                            isAllowed = true
                            break
                        end
                    end
                end

                if isAllowed then
                    local sID = serverEnemy:GetAttribute("ID")
                    if sID then
                        local targetPos
                        if serverEnemy:IsA("Model") then
                            targetPos = serverEnemy:GetPivot().Position
                        elseif serverEnemy:IsA("BasePart") then
                            targetPos = serverEnemy.Position
                        end

                        if targetPos then
                            local dist = (targetPos - myPos).Magnitude
                            local diff = getEnemyDifficulty(serverEnemy.Name)

                            if diff > highestDiff or (diff == highestDiff and dist < shortestDist) then
                                highestDiff  = diff
                                shortestDist = dist
                                bestTarget   = serverEnemy
                                bestID       = sID
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
-- Quest helpers
-- ============================================================
local questsFolder = RS:FindFirstChild("Omni") and RS.Omni.Shared.Quests.Main
local questModules = {}
local questNames   = {}

if questsFolder then
    for _, child in pairs(questsFolder:GetChildren()) do
        questModules[child.Name] = child
        table.insert(questNames, child.Name)
    end
    table.sort(questNames)
    if selectedQuest == "" then
        selectedQuest = questNames[1] or ""
    end
end

local function getQuestData(questName)
    if not questModules[questName] then return nil end
    local ok, mod = pcall(function() return require(questModules[questName]) end)
    return (ok and mod) and mod or nil
end

local function getSlotProgress(slotName)
    local ok, title = pcall(function()
        return player.PlayerGui.UI.HUD.Quests.List[slotName].Progress.Title
    end)
    if not ok or not title then return 0, 0 end
    local current, max = title.ContentText:match("%[(%d+)/(%d+)%]")
    return tonumber(current) or 0, tonumber(max) or 0
end

local function isSlotDone(slotName)
    local current, max = getSlotProgress(slotName)
    return max > 0 and current >= max
end

local function getTargetEnemyFromQuest(slotName)
    local ok, desc = pcall(function()
        return player.PlayerGui.UI.HUD.Quests.List[slotName].Description.ContentText
    end)
    if not (ok and desc) then return nil end

    local bestMatch = nil
    local matchLen  = 0
    for _, worldMap in ipairs(serverEnemiesWorld:GetChildren()) do
        for _, group in ipairs(worldMap:GetChildren()) do
            for _, enemy in ipairs(group:GetChildren()) do
                if string.find(desc, enemy.Name, 1, true) then
                    if #enemy.Name > matchLen then
                        bestMatch = enemy.Name
                        matchLen  = #enemy.Name
                    end
                end
            end
        end
    end
    return bestMatch
end

local function getQuestTarget(targetEnemyName)
    local char  = player.Character
    local myHRP = char and char:FindFirstChild("HumanoidRootPart")
    local myPos = myHRP and myHRP.Position or Vector3.zero

    local bestTarget   = nil
    local bestID       = nil
    local bestWorld    = nil
    local bestZone     = nil
    local shortestDist = math.huge

    for _, worldMap in ipairs(serverEnemiesWorld:GetChildren()) do
        for _, group in ipairs(worldMap:GetChildren()) do
            for _, serverEnemy in ipairs(group:GetChildren()) do
                if serverEnemy.Name == targetEnemyName then
                    local isDead = serverEnemy:GetAttribute("Died")
                    local hp     = serverEnemy:GetAttribute("Health")

                    if not isDead and (not hp or tonumber(hp) > 0) then
                        local sID = serverEnemy:GetAttribute("ID")
                        if sID then
                            local targetPos = serverEnemy:IsA("Model") and serverEnemy:GetPivot().Position or serverEnemy.Position
                            if targetPos then
                                local dist = (targetPos - myPos).Magnitude
                                if dist < shortestDist then
                                    shortestDist = dist
                                    bestTarget   = serverEnemy
                                    bestID       = sID
                                    bestWorld    = worldMap.Name
                                    bestZone     = tonumber(group.Name) or 1
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
-- Misc helpers
-- ============================================================
local function teleportToStar(starName)
    local char = player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local ok, starModel = pcall(function() return workspace.Server.Stars[starName] end)
    if not ok or not starModel then
        WindUI:Notify({ Title = "Teleport Failed", Content = "Star not found: " .. tostring(starName), Duration = 3 })
        return
    end

    local ok2, cf = pcall(function() return starModel:GetPivot() end)
    if ok2 and cf then
        hrp.CFrame = cf * CFrame.new(0, 5, 0)
    else
        WindUI:Notify({ Title = "Teleport Failed", Content = "GetPivot() failed: " .. tostring(starName), Duration = 3 })
    end
end

-- ============================================================
-- FARM TAB UI 
-- ============================================================
local selectedFarmWorld   = Options.SelectedFarmWorld or getWorldsList()[1] or ""
local selectedFarmZone    = Options.SelectedFarmZone or getZonesList(selectedFarmWorld)[1] or ""

local WorldDropdown
local ZoneDropdown
local EnemyDropdown

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
        
        if EnemyDropdown then
            EnemyDropdown:Refresh(getEnemiesList(selectedFarmWorld, selectedFarmZone))
        end
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
        
        if EnemyDropdown then
            EnemyDropdown:Refresh(getEnemiesList(selectedFarmWorld, selectedFarmZone))
        end
    end
})

EnemyDropdown = FarmTab:Dropdown({
    Title    = "Select Enemies",
    Icon     = "target",
    Values   = getEnemiesList(selectedFarmWorld, selectedFarmZone),
    Value    = selectedFarmEnemies,
    Multi    = true,
    Callback = function(v)
        if type(v) == "table" then
            selectedFarmEnemies = v
        elseif type(v) == "string" then
            selectedFarmEnemies = {v}
        else
            selectedFarmEnemies = {}
        end
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
        WindUI:Notify({ Title = "List Updated", Content = "Refreshed!", Duration = 2 })
    end
})

serverEnemiesWorld.ChildAdded:Connect(function()
    task.wait(0.5)
    local newWorlds = getWorldsList()
    if WorldDropdown then WorldDropdown:Refresh(newWorlds) end
    if ZoneDropdown then ZoneDropdown:Refresh(getZonesList(selectedFarmWorld)) end
    if EnemyDropdown then EnemyDropdown:Refresh(getEnemiesList(selectedFarmWorld, selectedFarmZone)) end
end)

serverEnemiesWorld.ChildRemoved:Connect(function()
    task.wait(0.5)
    local newWorlds = getWorldsList()
    if WorldDropdown then WorldDropdown:Refresh(newWorlds) end
    if ZoneDropdown then ZoneDropdown:Refresh(getZonesList(selectedFarmWorld)) end
    if EnemyDropdown then EnemyDropdown:Refresh(getEnemiesList(selectedFarmWorld, selectedFarmZone)) end
end)

task.spawn(function()
    local lastDetectedWorld = ""
    local lastDetectedZone  = 0
    while true do
        task.wait(3)
        local currentWorld, currentZone = getCurrentWorldName()
        if currentWorld ~= "" and 
           (currentWorld ~= lastDetectedWorld or currentZone ~= lastDetectedZone) then
            lastDetectedWorld = currentWorld
            lastDetectedZone  = currentZone

            local worldList = getWorldsList()
            if table.find(worldList, currentWorld) then
                selectedFarmWorld = currentWorld
                Options.SelectedFarmWorld = currentWorld
                SaveConfig()
                if WorldDropdown then WorldDropdown:Refresh(worldList) end

                local zoneList = getZonesList(currentWorld)
                local zoneStr  = tostring(currentZone)
                if table.find(zoneList, zoneStr) then
                    selectedFarmZone = zoneStr
                    Options.SelectedFarmZone = zoneStr
                    SaveConfig()
                end
                if ZoneDropdown then ZoneDropdown:Refresh(zoneList) end
                if EnemyDropdown then
                    EnemyDropdown:Refresh(getEnemiesList(selectedFarmWorld, selectedFarmZone))
                end
            end
        end
    end
end)

-- ============================================================
-- Auto Farm
-- ============================================================
FarmTab:Toggle({
    Title = "Auto Farm",
    Icon  = "crosshair",
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

                    local char  = player.Character
                    local myHRP = char and char:FindFirstChild("HumanoidRootPart")

                    if myHRP then
                        local target, id = getValidTarget()
                        if target and id then
                            local targetCFrame = target:IsA("Model") and target:GetPivot() or (target:IsA("BasePart") and target.CFrame)
                            if targetCFrame then
                                local dist = (myHRP.Position - targetCFrame.Position).Magnitude
                                if dist > 8 then myHRP.CFrame = targetCFrame * CFrame.new(0, 3, 0) end
                            end

                            while isAutoFarm and not isInsideTrial and target and target.Parent do
                                local isDead = target:GetAttribute("Died")
                                local hp     = target:GetAttribute("Health")
                                if isDead or (hp and tonumber(hp) <= 0) then break end

                                local curChar = player.Character
                                local curHRP  = curChar and curChar:FindFirstChild("HumanoidRootPart")
                                if curHRP then
                                    local tCF = target:IsA("Model") and target:GetPivot() or (target:IsA("BasePart") and target.CFrame)
                                    if tCF then
                                        local d = (curHRP.Position - tCF.Position).Magnitude
                                        if d > 8 then curHRP.CFrame = tCF * CFrame.new(0, 3, 0) end
                                    end
                                end

                                task.wait(0.1)
                            end
                        else
                            task.wait(0.5)
                        end
                    else
                        task.wait(0.5)
                    end
                end
            end)
        end
    end
})

-- ============================================================
-- Auto Fast Clicker 
-- ============================================================
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
                        local bestID = nil
                        local shortestDist = math.huge 

                        local char = player.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        local myPos = hrp and hrp.Position or Vector3.zero

                        local function checkTarget(node)
                            local sID = node:GetAttribute("ID")
                            if sID and not node:GetAttribute("Died") then
                                local hp = node:GetAttribute("Health")
                                if not hp or tonumber(hp) > 0 then
                                    local pos = node:IsA("Model") and node:GetPivot().Position
                                             or (node:IsA("BasePart") and node.Position)
                                    if pos then
                                        local dist = (pos - myPos).Magnitude
                                        if dist < shortestDist then
                                            shortestDist = dist
                                            bestID = sID
                                        end
                                    end
                                end
                            end
                        end

                        local serverEnemiesWorld = workspace:FindFirstChild("Server")
                            and workspace.Server:FindFirstChild("Enemies")
                            and workspace.Server.Enemies:FindFirstChild("World")
                        if serverEnemiesWorld then
                            for _, worldMap in ipairs(serverEnemiesWorld:GetChildren()) do
                                for _, group in ipairs(worldMap:GetChildren()) do
                                    for _, enemy in ipairs(group:GetChildren()) do
                                        checkTarget(enemy)
                                    end
                                end
                            end
                        end

                        local clientEnemies = workspace:FindFirstChild("Client")
                            and workspace.Client:FindFirstChild("Enemies")
                        if clientEnemies then
                            for _, enemy in ipairs(clientEnemies:GetChildren()) do
                                checkTarget(enemy)
                                if enemy:IsA("Folder") or enemy:IsA("Model") then
                                    for _, sub in ipairs(enemy:GetChildren()) do
                                        checkTarget(sub)
                                    end
                                end
                            end
                        end

                        local serverGamemodes = workspace:FindFirstChild("Server")
                            and workspace.Server:FindFirstChild("Enemies")
                            and workspace.Server.Enemies:FindFirstChild("Gamemodes")
                        if serverGamemodes then
                            for _, gm in ipairs(serverGamemodes:GetChildren()) do
                                for _, enemy in ipairs(gm:GetChildren()) do
                                    checkTarget(enemy)
                                    if enemy:IsA("Folder") or enemy:IsA("Model") then
                                        for _, sub in ipairs(enemy:GetChildren()) do
                                            checkTarget(sub)
                                        end
                                    end
                                end
                            end
                        end

                        if bestID then
                            fireRemote({{{ "General", "Attack", "Click", { [tostring(bestID)] = true }, n = 4 }, "\002" }})
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

-- ============================================================
-- GamemodeTab
-- ============================================================
GamemodeTab:Toggle({
    Title = "Auto Trial",
    Icon  = "clock",
    Type  = "Checkbox",
    Value = Options.AutoTrial or false,
    Callback = function(v)
        isAutoTrial = v
        Options.AutoTrial = v
        SaveConfig()
        if isAutoTrial then
            task.spawn(function()
                local lastMin = -1
                while isAutoTrial do
                    if not isInsideTrial then
                        local t = os.date("*t")
                        if (t.min == 15 or t.min == 45) and t.min ~= lastMin then
                            lastMin = t.min
                            isInsideTrial = true
                            preTrialWorld, preTrialZone = getCurrentWorldName()
                            if preTrialWorld == "" then preTrialWorld = "Fruits Verse" preTrialZone = 1 end
                            WindUI:Notify({ Title = "Trial", Content = "Saving world: " .. preTrialWorld .. " (Zone " .. preTrialZone .. ") → Joining Trial", Duration = 3 })
                            fireRemote({{{"General", "Gamemodes", "Join", "Trial Easy", n = 4}, "\002"}})
                            task.wait(3)
                        elseif t.min ~= 15 and t.min ~= 45 then
                            lastMin = -1
                        end
                        task.wait(1)
                    else
                        local char  = player.Character
                        local myHRP = char and char:FindFirstChild("HumanoidRootPart")

                        if myHRP then
                            local shouldLeave = false
                            local ok, waveText = pcall(function()
                                local waveObj = player.PlayerGui.UI.HUD.Gamemodes["Trial Easy"].Main.Wave.Value
                                if typeof(waveObj) == "Instance" then
                                    if waveObj:IsA("TextLabel") or waveObj:IsA("TextButton") or waveObj:IsA("TextBox") then
                                        return waveObj.ContentText ~= "" and waveObj.ContentText or waveObj.Text
                                    end
                                    return tostring(waveObj.Value)
                                end
                                return tostring(waveObj)
                            end)
                            
                            if ok and type(waveText) == "string" then
                                local currentWave = string.match(waveText, "(%d+)")
                                if isAutoLeaveTrial and currentWave and tonumber(currentWave) >= trialTargetWave then shouldLeave = true end
                            end

                            if shouldLeave then
                                fireRemote({{{"General", "Gamemodes", "Leave", "Trial Easy", n = 4}, "\002"}})
                                if isAutoDragonDefense then
                                    WindUI:Notify({ Title = "Trial Ended", Content = "Returning to Dragon Verse Zone 2 for Defense!", Duration = 5 })
                                    task.wait(3)
                                    fireRemote({{{"Player", "Teleport", "Teleport", "Dragon Verse", 2, n = 5}, "\002"}})
                                else
                                    WindUI:Notify({ Title = "Trial Ended", Content = "Left Trial → Returning to " .. preTrialWorld .. " (Zone " .. preTrialZone .. ")", Duration = 5 })
                                    task.wait(3)
                                    fireRemote({{{"Player", "Teleport", "Teleport", preTrialWorld, preTrialZone, n = 5}, "\002"}})
                                end
                                task.wait(3)
                                isInsideTrial = false
                            else
                                local target, id = getTrialTarget()
                                if target and id then
                                    local targetCFrame = target:IsA("Model") and target:GetPivot() or (target:IsA("BasePart") and target.CFrame)
                                    if targetCFrame then
                                        local dist = (myHRP.Position - targetCFrame.Position).Magnitude
                                        if dist > 8 then myHRP.CFrame = targetCFrame * CFrame.new(0, 3, 0) end
                                    end

                                    while isAutoTrial and isInsideTrial and target.Parent do
                                        local isDead = target:GetAttribute("Died")
                                        local hp     = target:GetAttribute("Health")
                                        if isDead or (hp and tonumber(hp) <= 0) then break end

                                        local ok2, wt2 = pcall(function()
                                            local wObj = player.PlayerGui.UI.HUD.Gamemodes["Trial Easy"].Main.Wave.Value
                                            if typeof(wObj) == "Instance" then
                                                if wObj:IsA("TextLabel") or wObj:IsA("TextButton") or wObj:IsA("TextBox") then
                                                    return wObj.ContentText ~= "" and wObj.ContentText or wObj.Text
                                                end
                                                return tostring(wObj.Value)
                                            end
                                            return tostring(wObj)
                                        end)
                                        
                                        if ok2 and type(wt2) == "string" then
                                            local cw2 = string.match(wt2, "(%d+)")
                                            if isAutoLeaveTrial and cw2 and tonumber(cw2) >= trialTargetWave then break end
                                        end

                                        local curChar = player.Character
                                        local curHRP  = curChar and curChar:FindFirstChild("HumanoidRootPart")
                                        if curHRP then
                                            local tCF = target:IsA("Model") and target:GetPivot() or (target:IsA("BasePart") and target.CFrame)
                                            if tCF then
                                                local d = (curHRP.Position - tCF.Position).Magnitude
                                                if d > 8 then curHRP.CFrame = tCF * CFrame.new(0, 3, 0) end
                                            end
                                        end
                                        task.wait(0.1)
                                    end
                                else
                                    task.wait(0.5)
                                end
                            end
                        else
                            task.wait(0.5)
                        end
                    end
                end
                isInsideTrial = false
            end)
        else
            isInsideTrial = false
        end
    end
})

GamemodeTab:Toggle({
    Title = "Auto Leave Trial",
    Icon  = "door-open",
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
    Value = {
        Min     = 1,
        Max     = 50,
        Default = Options.LeaveAtWave or 10
    },
    Callback = function(v)
        trialTargetWave = v
        Options.LeaveAtWave = v
        SaveConfig()
    end
})

local isAutoLeaveDragon = Options.AutoLeaveDragon or false
local dragonTargetWave  = Options.LeaveDragonAtWave or 50

GamemodeTab:Divider()

local function getSaiyanKeyCount()
    local ok, amountLabel = pcall(function()
        return player.PlayerGui.UI.Frames.Inventory.Background.Categories.Items.List["Saiyan Key"].Background.Amount
    end)
    if not (ok and amountLabel) then return 0 end
    
    local text = ""
    if amountLabel:IsA("TextLabel") or amountLabel:IsA("TextBox") then
        text = amountLabel.ContentText ~= "" and amountLabel.ContentText or amountLabel.Text
    end
    
    local num = tostring(text):match("(%d+)")
    return tonumber(num) or 0
end

-- ============================================================
-- Auto Dragon Defense
-- ============================================================
GamemodeTab:Toggle({
    Title = "Auto Dragon Defense",
    Icon  = "shield",
    Type  = "Checkbox",
    Value = Options.AutoDragonDefense or false,
    Callback = function(v)
        isAutoDragonDefense = v
        Options.AutoDragonDefense = v
        SaveConfig()
        if isAutoDragonDefense then
            fireRemote({{{"Player", "Teleport", "Teleport", "Dragon Verse", 2, n = 5}, "\002"}})
            
            task.spawn(function()
                while isAutoDragonDefense do
                    
                    if isInsideTrial then
                        task.wait(1)
                        continue
                    end

                    local curWorld, curZone = getCurrentWorldName()
                    if curWorld ~= "Dragon Verse" or curZone ~= 2 then
                        fireRemote({{{"Player", "Teleport", "Teleport", "Dragon Verse", 2, n = 5}, "\002"}})
                        task.wait(4)
                        continue
                    end

                    local keyCount = getSaiyanKeyCount()

                    if keyCount == 0 then
                        WindUI:Notify({ Title = "Key Alert", Content = "No Saiyan Keys! Farming in Zone 2...", Duration = 3 })
                        
                        while isAutoDragonDefense and getSaiyanKeyCount() == 0 and not isInsideTrial do
                    pcall(function()
                        local enemies = workspace.Server.Enemies.World["Dragon Verse"]["2"]:GetChildren()
                        local validEnemies = {}
                        for _, e in ipairs(enemies) do
                            local isDead = e:GetAttribute("Died")
                            local hp = e:GetAttribute("Health")
                            if not isDead and (not hp or tonumber(hp) > 0) then
                                table.insert(validEnemies, e)
                            end
                        end
                        
                        if #validEnemies == 0 then task.wait(0.5) return end
                        
                        local target = validEnemies[math.random(1, #validEnemies)]
                        if target and target.Parent then
                            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                            local tPos = target:IsA("Model") and target:GetPivot() or (target:IsA("BasePart") and target.CFrame)
                            if hrp and tPos then
                                hrp.CFrame = tPos * CFrame.new(0, 3, 0)
                            end
                            
                            while isAutoDragonDefense and target and target.Parent do
                                local isDead = target:GetAttribute("Died")
                                local hp = target:GetAttribute("Health")
                                if isDead or (hp and tonumber(hp) <= 0) then break end
                                
                                local curHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                                if curHRP then
                                    local tCF = target:IsA("Model") and target:GetPivot() or (target:IsA("BasePart") and target.CFrame)
                                    if tCF and (curHRP.Position - tCF.Position).Magnitude > 8 then
                                        curHRP.CFrame = tCF * CFrame.new(0, 3, 0)
                                    end
                                end
                                task.wait(0.1)
                            end
                        end
                    end)
                end
                    else
                        local ok, dragonNode = pcall(function()
                            return workspace.Server.Interactable["Dragon Arena"]["Dragon Defense Gamemode"]
                        end)
                        if ok and dragonNode then
                            local char = player.Character
                            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local ok2, cf = pcall(function()
                                    return dragonNode:IsA("Model") and dragonNode:GetPivot()
                                        or (dragonNode:IsA("BasePart") and dragonNode.CFrame)
                                end)
                                if ok2 and cf then hrp.CFrame = cf * CFrame.new(0, 5, 0) end
                            end
                        else
                            task.wait(3)
                            continue
                        end

                        task.wait(0.5)
                        fireRemote({{{"General", "Gamemodes", "Join", "Dragon Defense", n = 4}, "\002"}})
                        task.wait(1.5)

                        task.wait(1)

                        local okConfirm, confirmBtn = pcall(function()
                            return player.PlayerGui.Selection.Frames.Confirmation.Main.Buttons.Confirm
                        end)
                        if okConfirm and confirmBtn then
                            local vim = game:GetService("VirtualInputManager")
                            local ap = confirmBtn.AbsolutePosition
                            local as = confirmBtn.AbsoluteSize
                            if as.X > 0 and as.Y > 0 then
                                vim:SendMouseButtonEvent(ap.X + as.X/2, ap.Y + as.Y/2, 0, true,  game, 1)
                                task.wait(0.05)
                                vim:SendMouseButtonEvent(ap.X + as.X/2, ap.Y + as.Y/2, 0, false, game, 1)
                            end
                        end

                        task.wait(5)

                        local okCancel, cancelBtn = pcall(function()
                            return player.PlayerGui.Selection.Frames.Confirmation.Main.Buttons.Cancel
                        end)
                        if okCancel and cancelBtn then
                            local vim = game:GetService("VirtualInputManager")
                            local ap = cancelBtn.AbsolutePosition
                            local as = cancelBtn.AbsoluteSize
                            if as.X > 0 and as.Y > 0 then
                                vim:SendMouseButtonEvent(ap.X + as.X/2, ap.Y + as.Y/2, 0, true,  game, 1)
                                task.wait(0.05)
                                vim:SendMouseButtonEvent(ap.X + as.X/2, ap.Y + as.Y/2, 0, false, game, 1)
                            end
                            task.wait(0.5)
                        end
                        
                        

                        task.wait(2)
                        local okMap, defenseNode = pcall(function()
                            return workspace.Client.Maps["Dragon Defense"].Map.Defense
                        end)
                        if okMap and defenseNode then
                            local char = player.Character
                            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local ok2, cf = pcall(function()
                                    return defenseNode:IsA("Model") and defenseNode:GetPivot()
                                        or (defenseNode:IsA("BasePart") and defenseNode.CFrame)
                                end)
                                if ok2 and cf then
                                    hrp.CFrame = cf * CFrame.new(0, 5, 0)
                                    WindUI:Notify({ Title = "Dragon Defense", Content = "Teleported to Defense point!", Duration = 3 })
                                end
                            end
                        else
                            WindUI:Notify({ Title = "Dragon Defense", Content = "Map failed to load. Retrying...", Duration = 2 })
                            task.wait(3)
                            continue
                        end

                        task.wait(1)

                        local function getDragonTarget()
                            local char  = player.Character
                            local myHRP = char and char:FindFirstChild("HumanoidRootPart")
                            local myPos = myHRP and myHRP.Position or Vector3.zero

                            local bestTarget   = nil
                            local bestID       = nil
                            local shortestDist = math.huge

                            local okC, clientEnemies = pcall(function() return workspace.Client.Enemies end)
                            if okC and clientEnemies then
                                for _, child in ipairs(clientEnemies:GetDescendants()) do
                                    local sID    = child:GetAttribute("ID")
                                    local isDead = child:GetAttribute("Died")
                                    local hp     = child:GetAttribute("Health")

                                    if sID and not isDead and (not hp or tonumber(hp) > 0) then
                                        local tp = child:IsA("Model") and child:GetPivot().Position
                                            or (child:IsA("BasePart") and child.Position)
                                        if tp then
                                            local dist = (tp - myPos).Magnitude
                                            if dist < shortestDist then
                                                shortestDist = dist
                                                bestTarget   = child
                                                bestID       = sID
                                            end
                                        end
                                    end
                                end
                            end

                            if not bestTarget then
                                local okS, serverDD = pcall(function()
                                    return workspace.Server.Enemies.Gamemodes["Dragon Defense"]
                                end)
                                if okS and serverDD then
                                    for _, child in ipairs(serverDD:GetDescendants()) do
                                        local sID    = child:GetAttribute("ID")
                                        local isDead = child:GetAttribute("Died")
                                        local hp     = child:GetAttribute("Health")

                                        if sID and not isDead and (not hp or tonumber(hp) > 0) then
                                            local tp = child:IsA("Model") and child:GetPivot().Position
                                                or (child:IsA("BasePart") and child.Position)
                                            if tp then
                                                local dist = (tp - myPos).Magnitude
                                                if dist < shortestDist then
                                                    shortestDist = dist
                                                    bestTarget   = child
                                                    bestID       = sID
                                                end
                                            end
                                        end
                                    end
                                end
                            end

                            return bestTarget, bestID
                        end

                        local farmStart = tick()
                        while isAutoDragonDefense do
                            
                            if isInsideTrial then break end

                            local char  = player.Character
                            local myHRP = char and char:FindFirstChild("HumanoidRootPart")
                            if not myHRP then task.wait(0.5) continue end

                            local shouldLeave = false
                            local okWave, waveText = pcall(function()
                                local waveObj = player.PlayerGui.UI.HUD.Gamemodes["Dragon Defense"].Main.Wave.Value
                                if typeof(waveObj) == "Instance" then
                                    if waveObj:IsA("TextLabel") or waveObj:IsA("TextButton") or waveObj:IsA("TextBox") then
                                        return waveObj.ContentText ~= "" and waveObj.ContentText or waveObj.Text
                                    end
                                    return tostring(waveObj.Value)
                                end
                                return tostring(waveObj)
                            end)

                            if okWave and type(waveText) == "string" then
                                local currentWave = string.match(waveText, "(%d+)/") or string.match(waveText, "(%d+)")
                                if isAutoLeaveDragon and currentWave and tonumber(currentWave) >= dragonTargetWave then
                                    shouldLeave = true
                                end
                            end

                            if shouldLeave then
                                fireRemote({{{"General", "Gamemodes", "Leave", "Dragon Defense", n = 4}, "\002"}})
                                WindUI:Notify({ Title = "Dragon Defense", Content = "Reached target wave! Returning to Dragon Verse...", Duration = 5 })
                                task.wait(3)
                                
                                fireRemote({{{"Player", "Teleport", "Teleport", "Dragon Verse", 2, n = 5}, "\002"}})
                                task.wait(3)
                                break 
                            end

                            local bestTarget, bestID = getDragonTarget()

                            if bestTarget and bestID then
                                farmStart = tick()

                                local tCF = bestTarget:IsA("Model") and bestTarget:GetPivot()
                                          or (bestTarget:IsA("BasePart") and bestTarget.CFrame)
                                if tCF and (myHRP.Position - tCF.Position).Magnitude > 8 then
                                    myHRP.CFrame = tCF * CFrame.new(0, 3, 0)
                                end

                                while isAutoDragonDefense do
                                    
                                    if isInsideTrial then break end

                                    if not bestTarget or not bestTarget.Parent then break end

                                    local isDead = bestTarget:GetAttribute("Died")
                                    local hp     = bestTarget:GetAttribute("Health")
                                    if isDead or (hp and tonumber(hp) <= 0) then
                                        task.wait(0.2)
                                        break
                                    end

                                    local curHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                                    if curHRP then
                                        local tCF2 = bestTarget:IsA("Model") and bestTarget:GetPivot()
                                            or (bestTarget:IsA("BasePart") and bestTarget.CFrame)
                                        if tCF2 and (curHRP.Position - tCF2.Position).Magnitude > 8 then
                                            curHRP.CFrame = tCF2 * CFrame.new(0, 3, 0)
                                        end
                                    end

                                    task.wait(0.1)
                                end

                            else
                                if tick() - farmStart > 600 then
                                    WindUI:Notify({ Title = "Dragon Defense", Content = "Round ended. Rejoining...", Duration = 3 })
                                    break
                                end
                                task.wait(0.5)
                            end
                        end
                        task.wait(1)
                    end
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
    Callback = function(v)
        isAutoLeaveDragon = v
        Options.AutoLeaveDragon = v
        SaveConfig()
    end
})

GamemodeTab:Slider({
    Title = "Leave at Wave (Dragon)",
    Icon  = "skip-forward",
    Step  = 1,
    Value = {
        Min     = 1,
        Max     = 100,
        Default = Options.LeaveDragonAtWave or 50
    },
    Callback = function(v)
        dragonTargetWave = v
        Options.LeaveDragonAtWave = v
        SaveConfig()
    end
})

-- ============================================================
-- QUEST TAB
-- ============================================================
QuestTab:Dropdown({
    Title    = "Select Quest",
    Icon     = "list",
    Values   = questNames,
    Value    = Options.SelectedQuest or (questNames[1] or ""),
    Callback = function(v)
        selectedQuest = v
        Options.SelectedQuest = v
        SaveConfig()
    end
})

QuestTab:Toggle({
    Title = "Auto Quest",
    Icon  = "circle-check-big",
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
                            local slotName        = tostring(missionIndex)
                            local cachedEnemyName = nil

                            while isAutoQuest and not isSlotDone(slotName) do
                                if not cachedEnemyName then
                                    cachedEnemyName = getTargetEnemyFromQuest(slotName)
                                    if cachedEnemyName then
                                        WindUI:Notify({ Title = "Quest Setup", Content = "Targeting: " .. cachedEnemyName, Duration = 3 })
                                    end
                                end

                                if cachedEnemyName then
                                    local target, enemyID, targetWorld, targetZone = getQuestTarget(cachedEnemyName)
                                    if target and enemyID and targetWorld then
                                        local currentWorld, currentZone = getCurrentWorldName()
                                        if (currentWorld ~= "" and currentWorld ~= targetWorld) or (currentZone ~= targetZone) then
                                            fireRemote({{{"Player", "Teleport", "Teleport", targetWorld, targetZone or 1, n = 5}, "\002"}})
                                            task.wait(2.5)
                                        end

                                        while isAutoQuest and not isSlotDone(slotName) and target.Parent do
                                            local isDead = target:GetAttribute("Died")
                                            local hp     = target:GetAttribute("Health")
                                            if isDead or (hp and tonumber(hp) <= 0) then break end

                                            local curChar = player.Character
                                            local curHRP  = curChar and curChar:FindFirstChild("HumanoidRootPart")
                                            if curHRP then
                                                local tCF = target:IsA("Model") and target:GetPivot() or target.CFrame
                                                if tCF then
                                                    local dist = (curHRP.Position - tCF.Position).Magnitude
                                                    if dist > 8 then curHRP.CFrame = tCF * CFrame.new(0, 3, 0) end
                                                end
                                            end
                                            task.wait(0.1)

                                        end
                                    else
                                        task.wait(0.5)
                                    end
                                else
                                    task.wait(0.5)
                                end
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
                    else
                        task.wait(1)
                    end
                end
            end)
        end
    end
})

-- ============================================================
-- SUMMON TAB
-- ============================================================
SummonTab:Toggle({
    Title = "Auto Equip Best Unit",
    Icon  = "user-check",
    Type  = "Checkbox",
    Value = Options.AutoEquip or false,
    Callback = function(v)
        isAutoEquip = v
        Options.AutoEquip = v
        SaveConfig()
        if isAutoEquip then
            task.spawn(function()
                while isAutoEquip do
                    fireRemote({{{"General","Units","EquipBest","Power",n=4},"\002"}})
                    task.wait(30)
                end
            end)
        end
    end
})

SummonTab:Toggle({
    Title = "Auto Equip Accessories",
    Icon  = "gem",
    Type  = "Checkbox",
    Value = Options.AutoEquipAcc or false,
    Callback = function(v)
        Options.AutoEquipAcc = v
        SaveConfig()
        if v then
            task.spawn(function()
                while Options.AutoEquipAcc do
                    fireRemote({{{"General","Accessories","EquipBest","Power",n=4},"\002"}})
                    task.wait(60)
                end
            end)
        end
    end
})

SummonTab:Toggle({
    Title = "Auto Equip Best Sword",
    Icon  = "swords",
    Type  = "Checkbox",
    Value = Options.AutoEquipSword or false,
    Callback = function(v)
        Options.AutoEquipSword = v
        SaveConfig()
        if v then
            task.spawn(function()
                while Options.AutoEquipSword do
                    fireRemote({{{"General","Swords","EquipBest","Power",n=4},"\002"}})
                    task.wait(60)
                end
            end)
        end
    end
})

SummonTab:Toggle({
    Title = "Auto Awaken",
    Icon  = "zap",
    Type  = "Checkbox",
    Value = Options.AutoAwaken or false,
    Callback = function(v)
        isAutoAwaken = v
        Options.AutoAwaken = v
        SaveConfig()
        if isAutoAwaken then
            task.spawn(function()
                while isAutoAwaken do
                    fireRemote({{{"General","Awakening","Awaken",n=3},"\002"}})
                    task.wait(1)
                end
            end)
        end
    end
})

SummonTab:Divider()

SummonTab:Dropdown({
    Title    = "Select Star World",
    Icon     = "map-pin",
    Values   = {"Dressrosa", "Marine Fortress", "Capsule Corp","Dragon Arena","Jura Forest"},
    Value    = Options.SelectedStar or "Dressrosa",
    Callback = function(v)
        selectedStar = v
        Options.SelectedStar = v
        SaveConfig()
    end
})

SummonTab:Toggle({
    Title = "Auto Summon Star (No Gamepass)",
    Icon  = "star",
    Type  = "Checkbox",
    Value = Options.AutoSummonNoGP or false,
    Callback = function(v)
        isAutoSummon = v
        Options.AutoSummonNoGP = v
        SaveConfig()
        if isAutoSummon then
            task.spawn(function()
                teleportToStar(selectedStar)
                task.wait(0.5)
                while isAutoSummon do
                    teleportToStar(selectedStar)
                    task.wait(0.2)
                    fireRemote({{{"General","Stars","Open",selectedStar,99,n=5},"\002"}})
                    task.wait(1)
                end
            end)
        end
    end
})

SummonTab:Toggle({
    Title = "Auto Summon Star (With Gamepass)",
    Icon  = "star",
    Type  = "Checkbox",
    Value = Options.AutoSummonGP or false,
    Callback = function(v)
        isAutoSummon = v
        Options.AutoSummonGP = v
        SaveConfig()
        if isAutoSummon then
            task.spawn(function()
                while isAutoSummon do
                    fireRemote({{{"General","Stars","Open",selectedStar,99,n=5},"\002"}})
                    task.wait(1)
                end
            end)
        end
    end
})

-- ============================================================
-- MISC TAB
-- ============================================================
local redeemCodesList = {
    "RELEASE", 
    "SRRY4SHUTDOWN", 
    "SRRY4SHUTDOWN2", 
    "TIOGADIHIT!",
    "THX1KCCU", 
    "2KCCU!", 
    "THANKYOU3KCCU", 
    "4KONCHAMBER!",
    "ALREADY5K?", 
    "6KTHXSOMUCH", 
    "7KISALOT!", 
    "THANKS1KLIKES",
    "100KVISITSONCHAMBER!", 
    "SRRY4SHUTDOWN3",
    "RELEASEPATCH",
    "TY2KLIKES!!",
    "THXFOR200KVISITS!",
    "300KVISITSTHANKYOU!",
    "400KVISITSINCREDIBLE",
    "WOW500KVISITS!",
    "1KFAVORITESTHX!"
}

MiscTab:Button({
    Title    = "Redeem All Codes",
    Icon     = "ticket",
    Callback = function()
        task.spawn(function()
            for _, code in ipairs(redeemCodesList) do
                fireRemote({{{"General","Codes","Redeem",code,n=4},"\002"}})
                task.wait(0.5)
            end
            WindUI:Notify({ Title = "Codes Redeemed", Content = "All codes have been successfully redeemed!", Duration = 3 })
        end)
    end
})

MiscTab:Divider()

MiscTab:Toggle({
    Title = "Auto Collect Time Reward",
    Icon  = "clock",
    Type  = "Checkbox",
    Value = Options.AutoTimeReward or false,
    Callback = function(v)
        isAutoReward = v
        Options.AutoTimeReward = v
        SaveConfig()
        if isAutoReward then
            task.spawn(function()
                while isAutoReward do
                    local okReset, resetBtn = pcall(function()
                        return player.PlayerGui.UI.Frames.TimeRewards.Background.Main.Reset
                    end)
                    if okReset and resetBtn and resetBtn.Visible then
                        fireRemote({{{ "General", "TimeRewards", "Reset", n = 3 }, "\002"}})
                        task.wait(0.5)
                    end
                    for i = 1, 7 do
                        if not isAutoReward then break end
                        local ok, timeText = pcall(function()
                            local obj = player.PlayerGui.UI.Frames.TimeRewards.Background.Main.Rewards[tostring(i)].Main.Time
                            if obj:IsA("TextLabel") or obj:IsA("TextBox") then
                                return obj.ContentText ~= "" and obj.ContentText or obj.Text
                            end
                            return tostring(obj.Text)
                        end)
                        if ok and type(timeText) == "string" and string.lower(timeText) == "ready" then
                            fireRemote({{{
                                "General", "TimeRewards", "Claim", i, n = 4
                            }, "\002"}})
                            task.wait(0.3)
                        end
                    end
                    task.wait(5)
                end
            end)
        end
    end
})

MiscTab:Toggle({
    Title = "Auto Claim Achievement",
    Icon  = "award",
    Type  = "Checkbox",
    Value = Options.AutoAchieve or false,
    Callback = function(v)
        isAutoAchieve = v
        Options.AutoAchieve = v
        SaveConfig()
        
        if achieveConnections then
            for _, conn in ipairs(achieveConnections) do
                if conn.Connected then conn:Disconnect() end
            end
        end
        achieveConnections = {}

        if isAutoAchieve then
            task.spawn(function()
                local ok, list = pcall(function()
                    return player.PlayerGui.UI.Frames.Achievements.Background.Main.List
                end)
                
                if not (ok and list) then return end
                
                local function checkAndClaim(text)
                    if not isAutoAchieve then return end
                    local percentStr = text:match("(%d+%.?%d*)")
                    
                    if percentStr then
                        local percentNum = tonumber(percentStr)
                        if percentNum and percentNum >= 100 then
                            if not isClaimingAchieve then
                                isClaimingAchieve = true
                                fireRemote({{{ "General", "Achievements", "ClaimAll", n = 3 }, "\002" }})
                                task.wait(2)
                                isClaimingAchieve = false
                            end
                        end
                    end
                end

                local function hookTitle(title)
                    checkAndClaim(title.ContentText ~= "" and title.ContentText or title.Text)
                    
                    local c1 = title:GetPropertyChangedSignal("Text"):Connect(function()
                        checkAndClaim(title.Text)
                    end)
                    local c2 = title:GetPropertyChangedSignal("ContentText"):Connect(function()
                        checkAndClaim(title.ContentText)
                    end)
                    
                    table.insert(achieveConnections, c1)
                    table.insert(achieveConnections, c2)
                end

                local function setupItem(item)
                    if item:IsA("GuiObject") then
                        local title = item:FindFirstChild("Background") 
                            and item.Background:FindFirstChild("Main")
                            and item.Background.Main:FindFirstChild("Progress")
                            and item.Background.Main.Progress:FindFirstChild("Title")
                        
                        if title then
                            hookTitle(title)
                        else
                            local c3 = item.DescendantAdded:Connect(function(desc)
                                if desc.Name == "Title" and desc.Parent and desc.Parent.Name == "Progress" then
                                    hookTitle(desc)
                                end
                            end)
                            table.insert(achieveConnections, c3)
                        end
                    end
                end

                for _, item in ipairs(list:GetChildren()) do
                    setupItem(item)
                end

                local c4 = list.ChildAdded:Connect(function(child)
                    task.wait(0.1) 
                    setupItem(child)
                end)
                table.insert(achieveConnections, c4)
            end)
        end
    end
})

MiscTab:Toggle({
    Title = "Auto Claim Daily Reward",
    Icon  = "calendar",
    Type  = "Checkbox",
    Value = Options.AutoDailyReward or false,
    Callback = function(v)
        isAutoDailyReward = v
        Options.AutoDailyReward = v
        SaveConfig()
        if isAutoDailyReward then
            task.spawn(function()
                while isAutoDailyReward do
                    for i = 1, 7 do
                        if not isAutoDailyReward then break end
                        
                        local ok, timeText = pcall(function()
                            local obj = player.PlayerGui.UI.Frames.DailyRewards.Background.Main.Rewards[tostring(i)].Main.Time
                            if obj:IsA("TextLabel") or obj:IsA("TextBox") then
                                return obj.ContentText ~= "" and obj.ContentText or obj.Text
                            end
                            return tostring(obj.Text)
                        end)
                        
                        if ok and type(timeText) == "string" and string.lower(timeText) == "ready" then
                            fireRemote({{{"General","DailyRewards","Claim",i,n=4},"\002"}})
                            task.wait(0.3)
                        end
                    end
                    
                    task.wait(60)
                end
            end)
        end
    end
})

-- ============================================================
-- GACHA TAB
-- ============================================================
GachaTab:Toggle({
    Title = "Auto Roll Haki",
    Icon  = "dices",
    Type  = "Checkbox",
    Value = Options.AutoHaki or false,
    Callback = function(v)
        isAutoGacha = v
        Options.AutoHaki = v
        SaveConfig()
        if isAutoGacha then
            task.spawn(function()
                while isAutoGacha do
                    fireRemote({{{"General","Gacha","Roll","Haki",{},n=5},"\002"}})
                    task.wait(0.5)
                end
            end)
        end
    end
})

GachaTab:Toggle({
    Title = "Auto Roll Fruit",
    Icon  = "apple",
    Type  = "Checkbox",
    Value = Options.AutoFruit or false,
    Callback = function(v)
        isAutoFruit = v
        Options.AutoFruit = v
        SaveConfig()
        if isAutoFruit then
            task.spawn(function()
                while isAutoFruit do
                    fireRemote({{{"General","Gacha","Roll","Fruit",{},n=5},"\002"}})
                    task.wait(0.5)
                end
            end)
        end
    end
})

GachaTab:Toggle({
    Title = "Auto Roll Sword",
    Icon  = "swords",
    Type  = "Checkbox",
    Value = Options.AutoSword or false,
    Callback = function(v)
        isAutoSword = v
        Options.AutoSword = v
        SaveConfig()
        if isAutoSword then
            task.spawn(function()
                while isAutoSword do
                    fireRemote({{{"General","Banner","Roll","Swords Banner",n=4},"\002"}})
                    task.wait(0.5)
                end
            end)
        end
    end
})

GachaTab:Toggle({
    Title = "Auto Roll Race",
    Icon  = "dna",
    Type  = "Checkbox",
    Value = Options.AutoRace or false,
    Callback = function(v)
        isAutoRollRace = v
        Options.AutoRace = v
        SaveConfig()
        if isAutoRollRace then
            task.spawn(function()
                while isAutoRollRace do
                    fireRemote({{{"General","Gacha","Roll","Race",{},n=5},"\002"}})
                    task.wait(0.5)
                end
            end)
        end
    end
})

GachaTab:Toggle({
    Title = "Auto Spin Wheel",
    Icon  = "ferris-wheel",
    Type  = "Checkbox",
    Value = Options.AutoSpinWheel or false,
    Callback = function(v)
        isAutoRollFightStyle = v
        Options.AutoSpinWheel = v
        SaveConfig()
        if isAutoRollFightStyle then
            task.spawn(function()
                while isAutoRollFightStyle do
                    fireRemote({{{"General","Roulette","Roll","Dragon Wish",{},n=4},"\002"}})
                    task.wait(0.5)
                end
            end)
        end
    end
})

GachaTab:Toggle({
    Title = "Auto Roll Dragon Power",
    Icon  = "activity",
    Type  = "Checkbox",
    Value = Options.AutoDragonPower or false,
    Callback = function(v)
        isAutoRollClass = v
        Options.AutoDragonPower = v
        SaveConfig()
        if isAutoRollClass then
            task.spawn(function()
                while isAutoRollClass do
                    fireRemote({{{"General","Gacha","Roll","Dragon Power",{},n=5},"\002"}})
                    task.wait(0.5)
                end
             end)
        end
    end
})

GachaTab:Toggle({
    Title = "Auto Roll Slime Power",
    Icon  = "panda",
    Type  = "Checkbox",
    Value = Options.AutoSlimePower or false,
    Callback = function(v)
        isAutoRollSlimePower = v
        Options.AutoSlimePower = v
        SaveConfig()
        if isAutoRollSlimePower then
            task.spawn(function()
                while isAutoRollSlimePower do
                    fireRemote({{{"General","Gacha","Roll","Slime Power",{},n=5},"\002"}})
                    task.wait(0.5)
                end
             end)
        end
    end
})

-- ============================================================
-- UPGRADE TAB
-- ============================================================
UpgradeTab:Toggle({
    Title = "Auto Upgrade Fighting Style",
    Icon  = "dumbbell",
    Type  = "Checkbox",
    Value = Options.AutoFightStyle or false,
    Callback = function(v)
        isAutoFightStyle = v
        Options.AutoFightStyle = v
        SaveConfig()
        if isAutoFightStyle then
            task.spawn(function()
                while isAutoFightStyle do
                    fireRemote({{{"General","Progression","Upgrade","Fighting Style",n=4},"\002"}})
                    task.wait(0.5)
                end
            end)
        end
    end
})

UpgradeTab:Toggle({
    Title = "Auto Upgrade Ki Progression",
    Icon  = "flame",
    Type  = "Checkbox",
    Value = Options.AutoKiProgression or false,
    Callback = function(v)
        isAutoKiProgression = v
        Options.AutoKiProgression = v
        SaveConfig()
        if isAutoKiProgression then
            task.spawn(function()
                while isAutoKiProgression do
                    fireRemote({{{"General","Progression","Upgrade","Ki Progression",n=4},"\002"}})
                    task.wait(0.5)
                end
            end)
        end
    end
})

UpgradeTab:Toggle({
    Title = "Auto Upgrade Aura",
    Icon  = "lollipop",
    Type  = "Checkbox",
    Value = Options.AutoAura or false,
    Callback = function(v)
        isAutoAura = v
        Options.AutoAura = v
        SaveConfig()
        if isAutoAura then
            task.spawn(function()
                while isAutoAura do
                    fireRemote({{{"General","Aura","Upgrade",n=3},"\002"}})
                    task.wait(0.5)
                end
            end)
        end
    end
})

UpgradeTab:Toggle({
    Title = "Auto Upgrade Demon Lord",
    Icon  = "shrub",
    Type  = "Checkbox",
    Value = Options.AutoDemonLord or false,
    Callback = function(v)
        isAutoDemonlord = v
        Options.AutoDemonLord = v
        SaveConfig()
        if isAutoDemonlord then
            task.spawn(function()
                while isAutoDemonlord do
                    fireRemote({{{"General","Progression","Upgrade","Demon Lord Progression",n=4},"\002"}})
                    task.wait(0.5)
                end
            end)
        end
    end
})

-- ============================================================
-- AUTO DELETE TAB 
-- ============================================================

local rarityOrder = {"Legendary", "Epic", "Rare", "Uncommon", "Common"}

local targetDeleteAccessories = {
    ["Legendary"] = Options.Del_Legendary or false,
    ["Epic"]      = Options.Del_Epic or false,
    ["Rare"]      = Options.Del_Rare or false,
    ["Uncommon"]  = Options.Del_Uncommon or false,
    ["Common"]    = Options.Del_Common or false
}

local targetDeleteSwords = {
    ["Legendary"] = Options.DelSword_Legendary or false,
    ["Epic"]      = Options.DelSword_Epic or false,
    ["Rare"]      = Options.DelSword_Rare or false,
    ["Uncommon"]  = Options.DelSword_Uncommon or false,
    ["Common"]    = Options.DelSword_Common or false
}

isAutoDelete = Options.AutoDeleteEnabled or false

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
                                        
                                        if targetDeleteAccessories[rarity] then
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
                                        
                                        if targetDeleteSwords[rarity] then
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
AutoDeleteTab:Section({ Title = "Select Accessory Rarity to Delete" })

for _, rarityName in ipairs(rarityOrder) do
    AutoDeleteTab:Toggle({
        Title = "Delete Acc " .. rarityName,
        Type  = "Checkbox",
        Value = Options["Del_" .. rarityName] or false,
        Callback = function(v)
            targetDeleteAccessories[rarityName] = v
            Options["Del_" .. rarityName] = v
            SaveConfig()
        end
    })
end

AutoDeleteTab:Divider()
AutoDeleteTab:Section({ Title = "Select Sword Rarity to Delete" })

for _, rarityName in ipairs(rarityOrder) do
    AutoDeleteTab:Toggle({
        Title = "Delete Sword " .. rarityName,
        Type  = "Checkbox",
        Value = Options["DelSword_" .. rarityName] or false,
        Callback = function(v)
            targetDeleteSwords[rarityName] = v
            Options["DelSword_" .. rarityName] = v
            SaveConfig()
        end
    })
end

-- ============================================================
-- SETTINGS TAB
-- ============================================================
local isHideNotif = Options.HideNotif or false
local notifConnection = nil

SettingTab:Toggle({
    Title = "Hide 'You don't' Notifications",
    Icon  = "eye-off",
    Type  = "Checkbox",
    Value = Options.HideNotif or false,
    Callback = function(v)
        isHideNotif = v
        Options.HideNotif = v
        SaveConfig()
        
        if isHideNotif then
            task.spawn(function()
                local ok, list = pcall(function() return player.PlayerGui.Notifications.List end)
                if ok and list then
                    
                    local function checkAndHide(child)
                        task.wait(0.05) 
                        
                        for _, desc in ipairs(child:GetDescendants()) do
                            if desc:IsA("TextLabel") or desc:IsA("TextBox") then
                                local text = desc.ContentText ~= "" and desc.ContentText or desc.Text
                                
                                if text and string.find(text, "^You don't") then
                                    child.Visible = false
                                    break
                                end
                            end
                        end
                    end

                    for _, child in ipairs(list:GetChildren()) do
                        checkAndHide(child)
                    end

                    notifConnection = list.ChildAdded:Connect(checkAndHide)
                end
            end)
        else
            if notifConnection then
                notifConnection:Disconnect()
                notifConnection = nil
            end
            
            local ok, list = pcall(function() return player.PlayerGui.Notifications.List end)
            if ok and list then
                for _, child in ipairs(list:GetChildren()) do
                    if child:IsA("GuiObject") then child.Visible = true end
                end
            end
        end
    end
})

SettingTab:Toggle({
    Title = "Anti AFK",
    Icon  = "shield",
    Type  = "Checkbox",
    Value = Options.AntiAFK or false,
    Callback = function(v)
        Options.AntiAFK = v
        SaveConfig()
        if v then
            fireRemote({{{"General","Settings","Set","Anti Afk",true,n=5},"\002"}})
        else
            fireRemote({{{"General","Settings","Set","Anti Afk",false,n=5},"\002"}})
        end
    end
})

SettingTab:Keybind({
    Title    = "Toggle UI",
    Desc     = "Keybind to open/close UI",
    Value    = Options.ToggleUIKey or "RightControl",
    Callback = function(v)
        Options.ToggleUIKey = tostring(v)
        SaveConfig()
        local key = typeof(v) == "EnumItem" and v or Enum.KeyCode[v]
        Window:SetToggleKey(key)
    end
})

SettingTab:Divider()
SettingTab:Section({ Title = "Performance & Network" })

-- ============================================================
-- Auto Rejoin
-- ============================================================
SettingTab:Toggle({
    Title = "Auto Rejoin",
    Icon  = "plug",
    Type  = "Checkbox",
    Value = Options.AutoRejoin or false,
    Callback = function(v)
        Options.AutoRejoin = v
        SaveConfig()
        
        if v then
            task.spawn(function()
                local CoreGui = game:GetService("CoreGui")
                local TeleportService = game:GetService("TeleportService")
                local Players = game:GetService("Players")

                local promptOverlay = CoreGui:WaitForChild("RobloxPromptGui"):WaitForChild("promptOverlay")
                
                if not getgenv().RejoinConnection then
                    getgenv().RejoinConnection = promptOverlay.ChildAdded:Connect(function(child)
                        if Options.AutoRejoin and child.Name == "ErrorPrompt" then
                            print("[Auto Rejoin] Disconnected! Rejoining in 5 seconds...")
                            task.wait(5)
                            TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
                        end
                    end)
                end
            end)
        end
    end
})

-- ============================================================
-- Wipe VFX All
-- ============================================================
SettingTab:Toggle({
    Title = "Wipe VFX All (Anti-Lag)",
    Icon  = "eye-off",
    Type  = "Checkbox",
    Value = Options.WipeVFX or false,
    Callback = function(v)
        Options.WipeVFX = v
        SaveConfig()
        if v then
            task.spawn(function()
                while Options.WipeVFX do
                    pcall(function()
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("Smoke") then
                                obj.Enabled = false
                            end
                        end

                        local clientFolder = workspace:FindFirstChild("Client")
                        if clientFolder and clientFolder:FindFirstChild("VFX") then
                            clientFolder.VFX:ClearAllChildren()
                        end
                        if workspace:FindFirstChild("VFX") then
                            workspace.VFX:ClearAllChildren()
                        end
                    end)
                    
                    task.wait(2)
                end
            end)
        end
    end
})

-- ============================================================
-- LoadConfig
-- ============================================================
task.defer(function()
    WindUI:Notify({
        Title   = "WFS",
        Content = "Config loaded successfully!",
        Duration = 3
    })

    if Options.AntiAFK then
        fireRemote({{{"General","Settings","Set","Anti Afk",true,n=5},"\002"}})
    end
end)

FarmTab:Select()
-- ======================= UI BUTTON =======================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WFSToggleGui"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local targetGui = (gethui and gethui()) or (pcall(function() return CoreGui.Name end) and CoreGui) or player.PlayerGui
ScreenGui.Parent = targetGui

local ToggleBtn = Instance.new("ImageButton")
ToggleBtn.Name = "ToggleButton"
ToggleBtn.Parent = ScreenGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.BackgroundTransparency = 1
ToggleBtn.Position = UDim2.new(0.5, 0, 0, 40)
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Image = "rbxassetid://110552700896064"
ToggleBtn.AnchorPoint = Vector2.new(0.5, 0.5)

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = ToggleBtn

local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = ToggleBtn
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(124, 58, 237)
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local dragging, dragStart, startPos

ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = ToggleBtn.Position
        
        TweenService:Create(ToggleBtn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 42, 0, 42)}):Play()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            dragging = false
            TweenService:Create(ToggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 50, 0, 50)}):Play()
            
            if dragStart and (input.Position - dragStart).Magnitude < 10 then
                local vim = game:GetService("VirtualInputManager")
                local keyStr = Options.ToggleUIKey or "RightControl"
                local key = typeof(keyStr) == "EnumItem" and keyStr or Enum.KeyCode[keyStr]
                if not key then key = Enum.KeyCode.RightControl end
                
                vim:SendKeyEvent(true, key, false, game)
                task.wait(0.05)
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
