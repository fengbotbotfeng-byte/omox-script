-- =========================================================
-- SCRIPT INFORMATION & CONFIGURATION
-- =========================================================
local SCRIPT_NAME = "OMOX PRO"
local DEVELOPER_NAME = "FENGXIU"
local PASSWORD_CORRECT = "fengxomo"

-- [ LINK FOTO / LOGO TOP4TOP ]
local SCRIPT_LOGO_URL = "https://f.top4top.io/p_39100kq8x0.jpg" 

-- =========================================================
-- LOAD SERVICES & LIBRARIES
-- =========================================================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local PasswordInput = ""

-- ---------------------------------------------------------
-- FLOATING WIDGET (TOMBOL LOGO MELAYANG DI HP)
-- ---------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OMOXPRO_Widget"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "LogoWidget"
FloatBtn.Parent = ScreenGui
FloatBtn.Size = UDim2.new(0, 50, 0, 50)
FloatBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
FloatBtn.Text = "OMOX"
FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatBtn.TextScaled = true
FloatBtn.Font = Enum.Font.SourceSansBold
FloatBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 200)
FloatBtn.Active = true
FloatBtn.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = FloatBtn

local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = FloatBtn
UIStroke.Color = Color3.fromRGB(180, 120, 255)
UIStroke.Thickness = 2

-- ---------------------------------------------------------
-- TAMPILAN LOGIN PASSWORD (MODERN AMETHYST)
-- ---------------------------------------------------------
local PassWindow = nil

local function ShowLoginUI()
    if PassWindow then return end
    
    PassWindow = Fluent:CreateWindow({
        Title = SCRIPT_NAME .. " ✦ Authentication",
        SubTitle = "Developer: " .. DEVELOPER_NAME,
        TabWidth = 140,
        Size = UDim2.fromOffset(420, 260),
        Theme = "Amethyst",
        MinimizeKey = Enum.KeyCode.RightControl
    })

    local PassTab = PassWindow:AddTab({ Title = "Login", Icon = "lock" })

    PassTab:AddInput("InputPass", {
        Title = "Masukkan Password",
        Default = "",
        Numeric = false,
        Finished = false,
        Callback = function(Value)
            PasswordInput = Value
        end
    })

    PassTab:AddButton({
        Title = "Unlock Script",
        Description = "Akses Menu Utama OMOX PRO",
        Callback = function()
            local cleanInput = string.gsub(PasswordInput or "", "^%s*(.-)%s*$", "%1")
            
            if string.lower(cleanInput) == string.lower(PASSWORD_CORRECT) then
                Fluent:Destroy()
                ScreenGui:Destroy()
                task.wait(0.3)
                LoadMainScript()
            else
                Fluent:Notify({
                    Title = "Password Salah!",
                    Content = "Password yang kamu masukkan tidak valid.",
                    Duration = 3
                })
            end
        end
    })
end

-- Klik Tombol OMOX di Layar Untuk Buka Login
FloatBtn.MouseButton1Click:Connect(function()
    ShowLoginUI()
end)

-- ---------------------------------------------------------
-- SCRIPT UTAMA (ADVANCED AUTO STEAL & FLY ALL EGGS)
-- ---------------------------------------------------------
function LoadMainScript()
    local Window = Fluent:CreateWindow({
        Title = SCRIPT_NAME .. " ✦ Steal An Egg",
        SubTitle = "By " .. DEVELOPER_NAME,
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 420),
        Theme = "Amethyst",
        MinimizeKey = Enum.KeyCode.RightControl
    })

    local Tabs = {
        AutoFarm = Window:AddTab({ Title = "Auto Farm Base", Icon = "target" }),
        Main = Window:AddTab({ Title = "Egg Features", Icon = "egg" }),
        Player = Window:AddTab({ Title = "Player", Icon = "user" }),
        Credits = Window:AddTab({ Title = "Info & Logo", Icon = "info" })
    }

    local AutoAllEggsToggle = false
    local AutoRareEggsToggle = false
    local InstantHoldToggle = false
    local FlySpeed = 120
    local BaseWaitTime = 1.5
    local BaseCFrame = nil

    local function FlyToCFrame(targetCFrame)
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local hrp = char.HumanoidRootPart
        
        local distance = (hrp.Position - targetCFrame.Position).Magnitude
        local duration = distance / FlySpeed
        
        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame * CFrame.new(0, 3, 0)})
        tween:Play()
        tween.Completed:Wait()
    end

    local function GetNearestEgg()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
        
        local nearestPrompt = nil
        local shortestDist = math.huge
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                local parentPart = obj.Parent:IsA("BasePart") and obj.Parent or obj.Parent:FindFirstChildWhichIsA("BasePart")
                if parentPart then
                    local dist = (char.HumanoidRootPart.Position - parentPart.Position).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        nearestPrompt = obj
                    end
                end
            end
        end
        return nearestPrompt
    end

    local function GetPriorityEgg()
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                local eggName = string.lower(obj.Parent.Name .. " " .. obj.ObjectText .. " " .. obj.ActionText)
                if string.find(eggName, "secret") or string.find(eggName, "eternal") or string.find(eggName, "divine") then
                    return obj
                end
            end
        end
        return nil
    end

    ---------------------------------------------------------
    -- TAB 1: AUTO FARM (WITH BASE DELAY PROTECTION)
    ---------------------------------------------------------
    
    Tabs.AutoFarm:AddButton({
        Title = "1. Set Posisi Base / Tanaman (Wajib)",
        Description = "Berdiri di area Base kamu lalu klik tombol ini",
        Callback = function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                BaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
                Fluent:Notify({
                    Title = "Base Saved!",
                    Content = "Koordinat Base berhasil disimpan.",
                    Duration = 3
                })
            end
        end
    })

    Tabs.AutoFarm:AddSlider("BaseDelaySlider", {
        Title = "Jeda Diam di Base (Detik)",
        Description = "Atur waktu tunggu di Base agar telur tersimpan sempurna",
        Default = 1.5,
        Min = 0.5,
        Max = 5.0,
        Rounding = 1,
        Callback = function(Value)
            BaseWaitTime = Value
        end
    })

    Tabs.AutoFarm:AddToggle("AutoAllFarm", {
        Title = "Auto Farm SEMUA Telur (Fly + Base)",
        Default = false,
        Callback = function(Value)
            AutoAllEggsToggle = Value
            task.spawn(function()
                while AutoAllEggsToggle do
                    pcall(function()
                        if not BaseCFrame then
                            Fluent:Notify({ Title = "Warning!", Content = "Klik 'Set Posisi Base' terlebih dahulu!", Duration = 3 })
                            AutoAllEggsToggle = false
                            return
                        end
                        
                        local targetPrompt = GetNearestEgg()
                        if targetPrompt then
                            local eggPart = targetPrompt.Parent:IsA("BasePart") and targetPrompt.Parent or targetPrompt.Parent:FindFirstChildWhichIsA("BasePart")
                            if eggPart then
                                FlyToCFrame(eggPart.CFrame)
                                task.wait(0.1)
                                
                                targetPrompt.HoldDuration = 0
                                fireproximityprompt(targetPrompt)
                                task.wait(0.2)
                                
                                FlyToCFrame(BaseCFrame)
                                task.wait(BaseWaitTime)
                            end
                        end
                    end)
                    task.wait(0.2)
                end
            end)
        end
    })

    Tabs.AutoFarm:AddToggle("AutoRareSteal", {
        Title = "Auto Snipe RARE ONLY (Secret/Eternal/Divine)",
        Default = false,
        Callback = function(Value)
            AutoRareEggsToggle = Value
            task.spawn(function()
                while AutoRareEggsToggle do
                    pcall(function()
                        if not BaseCFrame then return end
                        
                        local targetPrompt = GetPriorityEgg()
                        if targetPrompt me then
                            local eggPart = targetPrompt.Parent:IsA("BasePart") and targetPrompt.Parent or targetPrompt.Parent:FindFirstChildWhichIsA("BasePart")
                            if eggPart then
                                FlyToCFrame(eggPart.CFrame)
                                task.wait(0.1)
                                
                                targetPrompt.HoldDuration = 0
                                fireproximityprompt(targetPrompt)
                                task.wait(0.2)
                                
                                FlyToCFrame(BaseCFrame)
                                task.wait(BaseWaitTime)
                            end
                        end
                    end)
                    task.wait(0.2)
                end
            end)
        end
    })

    ---------------------------------------------------------
    -- TAB 2: GENERAL EGG FEATURES
    ---------------------------------------------------------
    
    Tabs.Main:AddToggle("InstantHold", {
        Title = "Instant Steal All Prompts (0s Hold)",
        Default = false,
        Callback = function(Value)
            InstantHoldToggle = Value
            task.spawn(function()
                while InstantHoldToggle do
                    for _, v in pairs(Workspace:GetDescendants()) do
                        if v:IsA("ProximityPrompt") then
                            v.HoldDuration = 0
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    })

    ---------------------------------------------------------
    -- TAB 3 & 4: PLAYER SETTINGS & INFO
    ---------------------------------------------------------
    
    Tabs.Player:AddSlider("FlySpeedSlider", {
        Title = "Kecepatan Meluncur Terbang",
        Default = 120,
        Min = 50,
        Max = 300,
        Rounding = 0,
        Callback = function(Value)
            FlySpeed = Value
        end
    })

    Tabs.Player:AddSlider("WalkSpeed", {
        Title = "Kecepatan Jalan (WalkSpeed)",
        Default = 16,
        Min = 16,
        Max = 250,
        Rounding = 0,
        Callback = function(Value)
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = Value
                end
            end)
        end
    })

    Tabs.Credits:AddParagraph({
        Title = SCRIPT_NAME,
        Content = "Developed by " .. DEVELOPER_NAME .. ".\nFeatures: Fly Auto Farm All Eggs & Rare Egg Snipe with Base Safe-Delay."
    })

    Tabs.Credits:AddImage("ScriptLogo", {
        Title = "Logo Script OMOX PRO",
        Image = SCRIPT_LOGO_URL
    })

    Fluent:Notify({
        Title = SCRIPT_NAME,
        Content = "Script Berhasil Di-load! Enjoy OMOX PRO.",
        Duration = 4
    })
end
