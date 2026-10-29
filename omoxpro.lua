--[[
    OMOX PRO - Break and Steal an Egg (V7.0)
    Developer: FengXiu
    Inspired by: Serenity Hub, Ouroboros Hub, Spiritual Gaming
    Features: Auto Farm, Instant Steal, Event, Filter, Hatch, Sell, ESP, Movement.
]]

-- ==========================================
-- 1. LOAD UI LIBRARY (Linoria)
-- ==========================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/addons/SaveManager.lua"))()

local Window = Library:CreateWindow({
    Title = 'OMOX PRO | Break & Steal',
    Footer = 'Dev: FengXiu | V7.0 (Ultimate)',
    Size = UDim2.fromOffset(620, 500),
    Transparency = 0.2,
    Theme = 'Dark',
    MinimizeKey = Enum.KeyCode.RightShift
})

local Tabs = {
    Farm = Window:AddTab('Auto Farm', 'home'),
    Event = Window:AddTab('Event & Hell', 'zap'),
    Pets = Window:AddTab('Pets & Bank', 'box'),
    Visuals = Window:AddTab('ESP & Visuals', 'eye'),
    Misc = Window:AddTab('Settings', 'settings')
}

local Options = Library.Options
local Toggles = Library.Toggles

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- State Variables
local AutoFarm = false
local InstantSteal = false
local AutoHatch = false
local AutoPlace = false
local AutoSell = false
local AutoUpgrade = false
local AutoEquip = false
local AutoDemon = false
local TargetZone = "All"
local TargetRarity = "All"
local MinValue = 0
local SpecificPet = ""
local WalkSpeed = 16
local FlyEnabled = false
local NoClip = false

-- ==========================================
-- 2. CORE FUNCTIONS
-- ==========================================

-- Helper: Cari Base / Safe Zone
local function getBase()
    for _, name in pairs({"SafeZone", "Safe Zone", "Base", "Spawn", "Home", "Pen"}) do
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name:lower():find(name:lower()) and (obj:IsA("BasePart") or obj:IsA("Model")) then
                return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart") or obj
            end
        end
    end
    return nil
end

-- Helper: Fire ProximityPrompt
local function firePrompt(obj)
    local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        fireproximityprompt(prompt)
        return true
    end
    return false
end

-- Helper: Filter Telur / Pet
local function isTarget(obj)
    local name = obj.Name:lower()
    if TargetZone ~= "All" and not name:find(TargetZone:lower()) then return false end
    if TargetRarity ~= "All" and not name:find(TargetRarity:lower()) then return false end
    if SpecificPet ~= "" and not name:find(SpecificPet:lower()) then return false end
    return true
end

-- Helper: Cari Objek Terdekat
local function getNearest(targetName, isEgg)
    local nearest, minDist = nil, math.huge
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp = char.HumanoidRootPart

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find(targetName:lower()) then
            if isEgg and not isTarget(obj) then continue end
            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if part then
                local dist = (part.Position - hrp.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = obj
                end
            end
        end
    end
    return nearest
end

-- ==========================================
-- 3. TAB FARM (AUTO FARM & INSTANT STEAL)
-- ==========================================
local FarmGroup = Tabs.Farm:AddLeftGroupbox('Auto Farm')

FarmGroup:AddToggle('AutoFarmToggle', {
    Text = 'Auto Farm (Break & Steal)',
    Default = false,
    Callback = function(Value)
        AutoFarm = Value
        if AutoFarm then
            task.spawn(function()
                while AutoFarm do
                    task.wait(0.5)
                    pcall(function()
                        local egg = getNearest("egg", true)
                        if egg then
                            local part = egg.PrimaryPart or egg:FindFirstChildWhichIsA("BasePart")
                            if part then
                                LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame * CFrame.new(0, 3, 0)
                                task.wait(0.1)
                                firePrompt(egg)
                                -- Cari pet & balik ke base
                                task.wait(0.3)
                                local pet = getNearest("pet", false) or getNearest("animal", false)
                                if pet then
                                    local pPart = pet.PrimaryPart or pet:FindFirstChildWhichIsA("BasePart")
                                    if pPart then
                                        LocalPlayer.Character.HumanoidRootPart.CFrame = pPart.CFrame * CFrame.new(0, 3, 0)
                                        task.wait(0.1)
                                        firePrompt(pet)
                                        local base = getBase()
                                        if base then LocalPlayer.Character.HumanoidRootPart.CFrame = base.CFrame * CFrame.new(0, 5, 0) end
                                    end
                                end
                            end
                        end
                    end)
                end
            end)
        end
    end
})

FarmGroup:AddToggle('InstantStealToggle', {
    Text = 'Instant Steal (Tembus Map)',
    Default = false,
    Callback = function(Value)
        InstantSteal = Value
        if InstantSteal then
            task.spawn(function()
                while InstantSteal do
                    task.wait(0.1)
                    pcall(function()
                        for _, obj in pairs(Workspace:GetDescendants()) do
                            if obj:IsA("Model") and (obj.Name:lower():find("pet") or obj.Name:lower():find("animal")) then
                                local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                                if part then
                                    LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame * CFrame.new(0, 3, 0)
                                    task.wait(0.05)
                                    firePrompt(obj)
                                end
                            end
                        end
                    end)
                end
            end)
        end
    end
})

-- ==========================================
-- 4. TAB EVENT (DEMON & HELL)
-- ==========================================
local EventGroup = Tabs.Event:AddLeftGroupbox('Demon Event')

EventGroup:AddToggle('AutoDemonToggle', {
    Text = 'Auto Demon Event',
    Default = false,
    Callback = function(Value)
        AutoDemon = Value
        if AutoDemon then
            task.spawn(function()
                while AutoDemon do
                    task.wait(1)
                    pcall(function()
                        local boss = getNearest("demon", false) or getNearest("boss", false)
                        if boss then
                            local part = boss.PrimaryPart or boss:FindFirstChildWhichIsA("BasePart")
                            if part then
                                LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame * CFrame.new(0, 5, 0)
                                local tool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
                                if tool then tool:Activate() end
                            end
                        end
                    end)
                end
            end)
        end
    end
})

EventGroup:AddButton('Auto Join Hell', function()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("hell") or obj.Name:lower():find("portal")) then
            LocalPlayer.Character.HumanoidRootPart.CFrame = obj.CFrame * CFrame.new(0, 5, 0)
            break
        end
    end
end)

-- ==========================================
-- 5. TAB PETS (HATCH, SELL, EQUIP)
-- ==========================================
local PetGroup = Tabs.Pets:AddLeftGroupbox('Pet Management')

PetGroup:AddToggle('AutoHatchToggle', {
    Text = 'Auto Hatch',
    Default = false,
    Callback = function(Value)
        AutoHatch = Value
        if AutoHatch then
            task.spawn(function()
                while AutoHatch do
                    task.wait(1)
                    pcall(function()
                        for _, obj in pairs(Workspace:GetDescendants()) do
                            if obj:IsA("Model") and (obj.Name:lower():find("hatch") or obj.Name:lower():find("incubator")) then
                                firePrompt(obj)
                            end
                        end
                    end)
                end
            end)
        end
    end
})

PetGroup:AddToggle('AutoSellToggle', {
    Text = 'Auto Sell Junk Pets',
    Default = false,
    Callback = function(Value)
        AutoSell = Value
        if AutoSell then
            task.spawn(function()
                while AutoSell do
                    task.wait(2)
                    pcall(function()
                        for _, obj in pairs(Workspace:GetDescendants()) do
                            if obj:IsA("Model") and (obj.Name:lower():find("sell") or obj.Name:lower():find("shop")) then
                                firePrompt(obj)
                            end
                        end
                    end)
                end
            end)
        end
    end
})

PetGroup:AddToggle('AutoEquipToggle', {
    Text = 'Auto Equip Best Pets',
    Default = false,
    Callback = function(Value)
        AutoEquip = Value
        if AutoEquip then
            task.spawn(function()
                while AutoEquip do
                    task.wait(3)
                    pcall(function()
                        for _, obj in pairs(Workspace:GetDescendants()) do
                            if obj:IsA("Model") and (obj.Name:lower():find("equip") or obj.Name:lower():find("index")) then
                                firePrompt(obj)
                            end
                        end
                    end)
                end
            end)
        end
    end
})

-- ==========================================
-- 6. TAB VISUALS (ESP)
-- ==========================================
local VisGroup = Tabs.Visuals:AddLeftGroupbox('ESP Settings')

VisGroup:AddToggle('EggESP', {
    Text = 'Egg ESP',
    Default = false,
    Callback = function(Value)
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local old = obj:FindFirstChild("OMOX_ESP")
                if Value then
                    if not old and obj.Name:lower():find("egg") and isTarget(obj) then
                        local hl = Instance.new("Highlight")
                        hl.Parent = obj
                        hl.FillColor = Color3.fromRGB(0, 255, 0)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.Name = "OMOX_ESP"
                    end
                else
                    if old then old:Destroy() end
                end
            end
        end
    end
})

VisGroup:AddToggle('DemonESP', {
    Text = 'Demon/Boss ESP',
    Default = false,
    Callback = function(Value)
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and (obj.Name:lower():find("demon") or obj.Name:lower():find("boss")) then
                local old = obj:FindFirstChild("OMOX_DEMON_ESP")
                if Value then
                    if not old then
                        local hl = Instance.new("Highlight")
                        hl.Parent = obj
                        hl.FillColor = Color3.fromRGB(255, 0, 255)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.Name = "OMOX_DEMON_ESP"
                    end
                else
                    if old then old:Destroy() end
                end
            end
        end
    end
})

-- ==========================================
-- 7. TAB MISC (MOVEMENT)
-- ==========================================
local MiscGroup = Tabs.Misc:AddLeftGroupbox('Character')

MiscGroup:AddSlider('SpeedSlider', {
    Text = 'WalkSpeed',
    Default = 16, Min = 16, Max = 250, Rounding = 1,
    Callback = function(Value) WalkSpeed = Value end
})

MiscGroup:AddToggle('FlyToggle', {
    Text = 'Fly',
    Default = false,
    Callback = function(Value)
        FlyEnabled = Value
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            local bg = hrp:FindFirstChild("OMOX_FLY")
            if FlyEnabled and not bg then
                bg = Instance.new("BodyVelocity")
                bg.Name = "OMOX_FLY"
                bg.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bg.Velocity = Vector3.new(0,0,0)
                bg.Parent = hrp
            elseif not FlyEnabled and bg then
                bg:Destroy()
            end
        end
    end
})

MiscGroup:AddToggle('NoClipToggle', {
    Text = 'No Clip',
    Default = false,
    Callback = function(Value) NoClip = Value end
})

-- Fly & Speed & NoClip Loop
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = WalkSpeed
        
        if NoClip then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end

        if FlyEnabled and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            local bg = hrp:FindFirstChild("OMOX_FLY")
            if bg then
                local moveDir = Workspace.CurrentCamera.CFrame.LookVector
                bg.Velocity = moveDir * 50
            end
        end
    end
end)

Library:Init()
