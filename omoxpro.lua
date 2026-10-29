-- ================================================
-- Script Name : OMOX PRO (With Custom Profile/Image)
-- Developer   : FengXiu
-- Target Game : Break and Steal an Egg
-- ================================================

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local ImageUrl = "https://l.top4top.io/p_3954ea9t30.jpg"

local Window = OrionLib:MakeWindow({
    Name = "OMOX PRO v9.2 | FengXiu",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "OmoxProHub",
    IntroText = "OMOX PRO Loading...",
    IntroIcon = ImageUrl
})

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Configuration Variables
_G.AutoFarmBest = false
_G.AutoFilterSteal = false
_G.MinPetValue = 100000000000 -- 100B Default
_G.SafeZoneCFrame = nil

local function getHRP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function parseValue(valInput)
    if type(valInput) == "number" then return valInput end
    if type(valInput) ~= "string" then return 0 end
    local str = valInput:upper():gsub(",", ""):gsub("%$", ""):gsub("%s+", "")
    local num = tonumber(str:match("[%d%.]+")) or 0
    if str:find("B") then return num * 1e9
    elseif str:find("M") then return num * 1e6
    elseif str:find("K") then return num * 1e3 end
    return num
end

local function getBestZone()
    local bestZone = nil
    local maxDist = -1
    local origin = Vector3.new(0, 0, 0)
    
    local mapFolder = Workspace:FindFirstChild("Map") or Workspace:FindFirstChild("Zones") or Workspace
    for _, obj in pairs(mapFolder:GetChildren()) do
        if obj:IsA("BasePart") or (obj:IsA("Model") and obj.PrimaryPart) then
            local name = obj.Name:lower()
            if name:find("zone") or name:find("area") or name:find("island") or name:find("stage") then
                local pos = obj:IsA("BasePart") and obj.Position or obj.PrimaryPart.Position
                local dist = (pos - origin).Magnitude
                if dist > maxDist then
                    maxDist = dist
                    bestZone = obj
                end
            end
        end
    end
    return bestZone
end

-- Tabs
local FarmTab = Window:MakeTab({ Name = "Auto Farm", Icon = ImageUrl })
local FilterTab = Window:MakeTab({ Name = "Pet Filter & SafeZone", Icon = ImageUrl })

-- Auto Farm Best Zone
FarmTab:AddToggle({
    Name = "Auto Best Zone & Farm Eggs",
    Default = false,
    Callback = function(Value)
        _G.AutoFarmBest = Value
        task.spawn(function()
            while _G.AutoFarmBest do
                task.wait(0.5)
                pcall(function()
                    local hrp = getHRP()
                    if not hrp then return end

                    local zone = getBestZone()
                    if zone then
                        local targetCF = zone:IsA("BasePart") and zone.CFrame or zone.PrimaryPart.CFrame
                        hrp.CFrame = targetCF + Vector3.new(0, 5, 0)
                    end

                    for _, obj in pairs(Workspace:GetChildren()) do
                        if not _G.AutoFarmBest then break end
                        if obj:IsA("Model") and (obj.Name:lower():find("egg") or obj.Name:lower():find("telur")) then
                            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                            if part and (hrp.Position - part.Position).Magnitude < 40 then
                                hrp.CFrame = part.CFrame + Vector3.new(0, 2, 0)
                                local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if prompt then fireproximityprompt(prompt) end
                                task.wait(0.2)
                            end
                        end
                    end
                end)
            end
        end)
    end
})

-- Set Safe Zone Position
FilterTab:AddButton({
    Name = "Set Safe Zone Posisi Sekarang",
    Callback = function()
        local hrp = getHRP()
        if hrp then
            _G.SafeZoneCFrame = hrp.CFrame
            OrionLib:MakeNotification({
                Name = "OMOX PRO",
                Content = "Safe Zone terkunci!",
                Image = ImageUrl,
                Time = 3
            })
        end
    end
})

-- Min Value Input
FilterTab:AddTextbox({
    Name = "Minimal Pet Value (Contoh: 100B)",
    Default = "100B",
    TextDisappear = false,
    Callback = function(Value)
        _G.MinPetValue = parseValue(Value)
    end
})

-- Auto Steal (> Min Value)
FilterTab:AddToggle({
    Name = "Auto Steal Pet (> 100B) & Safe Zone",
    Default = false,
    Callback = function(Value)
        _G.AutoFilterSteal = Value
        if Value and not _G.SafeZoneCFrame then
            local hrp = getHRP()
            if hrp then _G.SafeZoneCFrame = hrp.CFrame end
        end

        task.spawn(function()
            while _G.AutoFilterSteal do
                task.wait(0.3)
                pcall(function()
                    local hrp = getHRP()
                    if not hrp then return end

                    for _, item in pairs(Workspace:GetChildren()) do
                        if not _G.AutoFilterSteal then break end
                        if item:IsA("Model") or item:IsA("Tool") then
                            local nameLower = item.Name:lower()
                            if nameLower:find("pet") or nameLower:find("animal") or nameLower:find("carrier") then
                                local valHolder = item:FindFirstChild("Value") or item:FindFirstChild("PetValue") or item:FindFirstChild("Price")
                                local itemVal = 0

                                if valHolder and valHolder:IsA("ValueBase") then
                                    itemVal = parseValue(tostring(valHolder.Value))
                                else
                                    itemVal = parseValue(item.Name)
                                end

                                if itemVal >= _G.MinPetValue then
                                    local targetPart = item:FindFirstChild("Handle") or item.PrimaryPart or item:FindFirstChildOfClass("BasePart")
                                    if targetPart then
                                        hrp.CFrame = targetPart.CFrame
                                        task.wait(0.1)

                                        local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                                        if prompt then fireproximityprompt(prompt) end
                                        task.wait(0.2)

                                        if _G.SafeZoneCFrame then
                                            hrp.CFrame = _G.SafeZoneCFrame
                                            task.wait(0.5)
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

OrionLib:Init()
