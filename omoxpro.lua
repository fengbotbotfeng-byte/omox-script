-- ================================================
-- Script Name : OMOX PRO (Final & Optimized Version)
-- Developer   : FengXiu
-- Target Game : Break and Steal an Egg
-- ================================================

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local Window = OrionLib:MakeWindow({
    Name = "OMOX PRO | Break and Steal an Egg",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "OmoxProConfig",
    IntroText = "OMOX PRO by FengXiu"
})

-- Global Variables
_G.AutoBestZone = false
_G.AutoBreak = false
_G.AutoStealFilter = false
_G.MinPetValue = 100000000000 -- Default 100B
_G.SafeZoneCFrame = nil

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Safe Character Loader
local function getHRP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

-- Fixed Converter for Values (100B, 1M, 500K)
local function parseValue(valInput)
    if type(valInput) == "number" then return valInput end
    if type(valInput) ~= "string" then return 0 end
    
    local str = valInput:upper():gsub(",", ""):gsub("%$", ""):gsub("%s+", "")
    local num = tonumber(str:match("[%d%.]+")) or 0
    
    if str:find("B") then
        return num * 1000000000 -- 1 Billion = 10^9
    elseif str:find("M") then
        return num * 1000000
    elseif str:find("K") then
        return num * 1000
    end
    return num
end

-- Best Zone Finder Logic
local function getBestZone()
    local bestZone = nil
    local maxDistance = -1
    local origin = Vector3.new(0, 0, 0)
    
    local possibleContainers = {workspace:FindFirstChild("Zones"), workspace:FindFirstChild("Areas"), workspace}
    
    for _, container in pairs(possibleContainers) do
        if container then
            for _, obj in pairs(container:GetChildren()) do
                if obj:IsA("BasePart") or (obj:IsA("Model") and obj.PrimaryPart) then
                    local name = obj.Name:lower()
                    if name:find("zone") or name:find("area") or name:find("egg") then
                        local pos = obj:IsA("BasePart") and obj.Position or obj.PrimaryPart.Position
                        local dist = (pos - origin).Magnitude
                        if dist > maxDistance then
                            maxDistance = dist
                            bestZone = obj
                        end
                    end
                end
            end
        end
    end
    return bestZone
end

-- Universal Interactor (Prompt / Click)
local function interactWith(obj)
    if not obj or not obj.Parent then return end
    pcall(function()
        local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt then fireproximityprompt(prompt) end
        local click = obj:FindFirstChildWhichIsA("ClickDetector", true)
        if click then fireclickdetector(click) end
    end)
end

-- Tabs
local MainTab = Window:MakeTab({ Name = "Auto Farm & Zone", Icon = "rbxassetid://4483345998" })
local FilterTab = Window:MakeTab({ Name = "Pet Filter & Safe Zone", Icon = "rbxassetid://4483345998" })
local CreditsTab = Window:MakeTab({ Name = "Credits", Icon = "rbxassetid://4483345998" })

-- Feature 1: Auto Best Zone
MainTab:AddToggle({
    Name = "Auto Go to Best Zone",
    Default = false,
    Callback = function(Value)
        _G.AutoBestZone = Value
        task.spawn(function()
            while _G.AutoBestZone do
                task.wait(1)
                pcall(function()
                    local hrp = getHRP()
                    local zone = getBestZone()
                    if hrp and zone then
                        local targetCF = zone:IsA("BasePart") and zone.CFrame or zone.PrimaryPart.CFrame
                        hrp.CFrame = targetCF + Vector3.new(0, 4, 0)
                    end
                end)
            end
        end)
    end
})

-- Feature 2: Auto Break
MainTab:AddToggle({
    Name = "Auto Break Eggs (Smart Radius)",
    Default = false,
    Callback = function(Value)
        _G.AutoBreak = Value
        task.spawn(function()
            while _G.AutoBreak do
                task.wait(0.1)
                pcall(function()
                    local hrp = getHRP()
                    if hrp then
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if not _G.AutoBreak then break end
                            if obj:IsA("BasePart") and (obj.Name:lower():find("egg") or obj.Name:lower():find("telur")) then
                                if (hrp.Position - obj.Position).Magnitude <= 25 then
                                    firetouchinterest(hrp, obj, 0)
                                    firetouchinterest(hrp, obj, 1)
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end
})

-- Feature 3: Set Safe Zone
FilterTab:AddButton({
    Name = "Set Safe Zone Position",
    Callback = function()
        local hrp = getHRP()
        if hrp then
            _G.SafeZoneCFrame = hrp.CFrame
            OrionLib:MakeNotification({
                Name = "OMOX PRO",
                Content = "Posisi Safe Zone berhasil disimpan!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Feature 4: Value Input
FilterTab:AddTextbox({
    Name = "Minimal Pet Value (Contoh: 100B)",
    Default = "100B",
    TextDisappear = false,
    Callback = function(Value)
        _G.MinPetValue = parseValue(Value)
    end
})

-- Feature 5: Auto Steal & Secure (> Min Value)
FilterTab:AddToggle({
    Name = "Auto Steal Best Pet (> Min Value)",
    Default = false,
    Callback = function(Value)
        _G.AutoStealFilter = Value
        
        -- Auto save safezone jika belum diset manual
        if Value and not _G.SafeZoneCFrame then
            local hrp = getHRP()
            if hrp then _G.SafeZoneCFrame = hrp.CFrame end
        end

        task.spawn(function()
            while _G.AutoStealFilter do
                task.wait(0.3)
                pcall(function()
                    local hrp = getHRP()
                    if not hrp then return end

                    for _, item in pairs(workspace:GetChildren()) do
                        if not _G.AutoStealFilter then break end
                        if item:IsA("Model") or item:IsA("Tool") then
                            local nameLower = item.Name:lower()
                            
                            -- Filter hanya objek yang berkaitan dengan pet / hasil curian
                            if nameLower:find("pet") or nameLower:find("animal") or name:find("egg") or item:IsA("Tool") then
                                local valHolder = item:FindFirstChild("Value") or item:FindFirstChild("PetValue") or item:FindFirstChild("Price")
                                local itemVal = 0

                                if valHolder and valHolder:IsA("ValueBase") then
                                    itemVal = parseValue(tostring(valHolder.Value))
                                else
                                    itemVal = parseValue(item.Name)
                                end

                                -- Jika nilai pet >= minimal value (di atas 100B)
                                if itemVal >= _G.MinPetValue or itemVal == 0 then
                                    local targetPart = item:FindFirstChild("Handle") or item.PrimaryPart or item:FindFirstChildOfClass("BasePart")
                                    if targetPart then
                                        -- 1. Teleport ke lokasi Pet
                                        hrp.CFrame = targetPart.CFrame
                                        task.wait(0.1)
                                        interactWith(item)
                                        task.wait(0.2)

                                        -- 2. Bawa balik ke Safe Zone
                                        if _G.SafeZoneCFrame then
                                            hrp.CFrame = _G.SafeZoneCFrame
                                            task.wait(0.4)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end
})

-- Info
CreditsTab:AddLabel("Script Name: OMOX PRO")
CreditsTab:AddLabel("Developer: FengXiu")
CreditsTab:AddLabel("Status: Verified & Fixed")

OrionLib:Init()
