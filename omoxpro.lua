--[[
    OMOX PRO - Break and Steal an Egg (V8.0)
    Developer: FengXiu
    UI: Rayfield (Stable)
    Fix: Smart Interaction (Prompt, Click, Remote)
]]

-- ==========================================
-- 1. LOAD UI (RAYFIELD)
-- ==========================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "OMOX PRO | Dev: FengXiu",
   LoadingTitle = "Memuat Script...",
   LoadingSubtitle = "by FengXiu",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "OmoxPro",
      FileName = "Config"
   },
   KeySystem = false
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- State
local AutoFarm = false
local AutoSteal = false
local InstantBreak = false
local AutoCandy = false
local WalkSpeed = 16

-- ==========================================
-- 2. SMART INTERACTION LOGIC (BIAR PASTI PECAH)
-- ==========================================
local function interactWith(obj)
    if not obj then return end

    -- 1. Coba Proximity Prompt
    local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        fireproximityprompt(prompt)
    end

    -- 2. Coba Click Detector
    local click = obj:FindFirstChildWhichIsA("ClickDetector", true)
    if click then
        fireclickdetector(click)
    end

    -- 3. Coba Remote Event (Spam Remote jika ada)
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local rName = remote.Name:lower()
            if rName:find("break") or rName:find("hit") or rName:find("mine") or rName:find("steal") then
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer(obj)
                    else
                        remote:InvokeServer(obj)
                    end
                end)
            end
        end
    end
end

local function teleportTo(obj)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
    if part then
        char.HumanoidRootPart.CFrame = part.CFrame * CFrame.new(0, 3, 0)
    end
end

local function getBase()
    for _, name in pairs({"safezone", "base", "spawn", "home", "pen"}) do
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name:lower():find(name) and (obj:IsA("BasePart") or obj:IsA("Model")) then
                return obj
            end
        end
    end
    return nil
end

-- ==========================================
-- 3. UI TABS
-- ==========================================
local FarmTab = Window:CreateTab("Auto Farm", 4483362458) -- Icon ID
local EventTab = Window:CreateTab("Event & Halloween", 4483362458)
local MiscTab = Window:CreateTab("Settings", 4483362458)

-- ==========================================
-- 4. TAB AUTO FARM
-- ==========================================
FarmTab:CreateToggle({
   Name = "Auto Farm Eggs (Break & Steal)",
   CurrentValue = false,
   Flag = "AutoFarm",
   Callback = function(Value)
       AutoFarm = Value
       if AutoFarm then
           task.spawn(function()
               while AutoFarm do
                   task.wait(0.3)
                   pcall(function()
                       local char = LocalPlayer.Character
                       if not char then return end
                       
                       -- Cari Telur
                       for _, obj in pairs(Workspace:GetDescendants()) do
                           if obj:IsA("Model") and obj.Name:lower():find("egg") then
                               teleportTo(obj)
                               task.wait(0.05)
                               interactWith(obj)
                               task.wait(0.1)
                               break -- Fokus ke satu telur dulu
                           end
                       end
                       
                       -- Cari Hewan Hasil
                       for _, pet in pairs(Workspace:GetDescendants()) do
                           if pet:IsA("Model") and (pet.Name:lower():find("pet") or pet.Name:lower():find("animal")) then
                               teleportTo(pet)
                               task.wait(0.05)
                               interactWith(pet)
                               task.wait(0.1)
                               
                               -- Balik ke Base
                               local base = getBase()
                               if base then
                                   local bp = base.PrimaryPart or base:FindFirstChildWhichIsA("BasePart") or base
                                   if bp then
                                       char.HumanoidRootPart.CFrame = bp.CFrame * CFrame.new(0, 5, 0)
                                   end
                               end
                               break
                           end
                       end
                   end)
               end
           end)
       end
   end,
})

FarmTab:CreateToggle({
   Name = "Instant Break (Spam Cepat)",
   CurrentValue = false,
   Flag = "InstantBreak",
   Callback = function(Value)
       InstantBreak = Value
       if InstantBreak then
           task.spawn(function()
               while InstantBreak do
                   task.wait(0.05)
                   pcall(function()
                       local char = LocalPlayer.Character
                       local tool = char and char:FindFirstChildWhichIsA("Tool")
                       if tool then tool:Activate() end
                       
                       for _, obj in pairs(Workspace:GetDescendants()) do
                           if obj:IsA("Model") and obj.Name:lower():find("egg") then
                               local hrp = char and char:FindFirstChild("HumanoidRootPart")
                               local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                               if hrp and part and (hrp.Position - part.Position).Magnitude < 15 then
                                   interactWith(obj)
                               end
                           end
                       end
                   end)
               end
           end)
       end
   end,
})

FarmTab:CreateToggle({
   Name = "Auto Steal Semua Pet di Map",
   CurrentValue = false,
   Flag = "AutoSteal",
   Callback = function(Value)
       AutoSteal = Value
       if AutoSteal then
           task.spawn(function()
               while AutoSteal do
                   task.wait(0.5)
                   pcall(function()
                       for _, pet in pairs(Workspace:GetDescendants()) do
                           if pet:IsA("Model") and (pet.Name:lower():find("pet") or pet.Name:lower():find("animal")) then
                               teleportTo(pet)
                               task.wait(0.05)
                               interactWith(pet)
                           end
                       end
                   end)
               end
           end)
       end
   end,
})

-- ==========================================
-- 5. TAB EVENT
-- ==========================================
EventTab:CreateToggle({
   Name = "Auto Candy (Halloween)",
   CurrentValue = false,
   Flag = "AutoCandy",
   Callback = function(Value)
       AutoCandy = Value
       if AutoCandy then
           task.spawn(function()
               while AutoCandy do
                   task.wait(0.2)
                   pcall(function()
                       for _, obj in pairs(Workspace:GetDescendants()) do
                           if (obj.Name:lower():find("candy") or obj.Name:lower():find("pumpkin")) then
                               if obj:IsA("Model") then
                                   teleportTo(obj)
                                   task.wait(0.05)
                                   interactWith(obj)
                               end
                           end
                       end
                   end)
               end
           end)
       end
   end,
})

EventTab:CreateButton({
   Name = "Teleport ke Hell / New Area",
   Callback = function()
       for _, obj in pairs(Workspace:GetDescendants()) do
           if obj:IsA("BasePart") and (obj.Name:lower():find("hell") or obj.Name:lower():find("portal")) then
               LocalPlayer.Character.HumanoidRootPart.CFrame = obj.CFrame * CFrame.new(0, 5, 0)
               break
           end
       end
   end,
})

-- ==========================================
-- 6. TAB SETTINGS
-- ==========================================
MiscTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 200},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "Speed",
   Callback = function(Value)
       WalkSpeed = Value
   end,
})

RunService.Stepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = WalkSpeed
    end
end)
