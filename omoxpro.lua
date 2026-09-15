-- =========================================================
-- SCRIPT INFORMATION & CONFIGURATION
-- =========================================================
local SCRIPT_NAME = "OMOX PRO"
local DEVELOPER_NAME = "FENGXIU"
local PASSWORD_CORRECT = "fengxomo"

-- [ LINK FOTO / LOGO TOP4TOP KAMU ]
local SCRIPT_LOGO_URL = "https://f.top4top.io/p_39100kq8x0.jpg" 

-- =========================================================
-- LOAD SERVICES & LIBRARIES
-- =========================================================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local PasswordInput = ""

-- ---------------------------------------------------------
-- TAMPILAN LOGIN PASSWORD
-- ---------------------------------------------------------
local PassWindow = Fluent:CreateWindow({
    Title = SCRIPT_NAME .. " ✦ Authentication",
    SubTitle = "Developer: " .. DEVELOPER_NAME,
    TabWidth = 160,
    Size = UDim2.fromOffset(420, 240),
    Theme = "Amethyst", -- Tema Ungu-Biru Mewah
    MinimizeKey = Enum.KeyCode.RightControl
})

local PassTab = PassWindow:AddTab({ Title = "Login", Icon = "lock" })

PassTab:AddInput("InputPass", {
    Title = "Masukkan Password",
    Default = "",
    Placeholder = "Password di sini...",
    Numeric = false,
    Finished = true,
    Callback = function(Value)
        PasswordInput = Value
    end
})

PassTab:AddButton({
    Title = "Unlock Script",
    Description = "Akses Menu Utama OMOX PRO",
    Callback = function()
        if PasswordInput == PASSWORD_CORRECT then
            Fluent:Destroy()
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

-- ---------------------------------------------------------
-- SCRIPT UTAMA (ADVANCED AUTO STEAL & FLY TARGET)
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
        AutoFarm = Window:AddTab({ Title = "Auto Target", Icon = "target" }),
        Main = Window:AddTab({ Title = "Egg Features", Icon = "egg" }),
        Player = Window:AddTab({ Title = "Player", Icon = "user" }),
        Credits = Window:AddTab({ Title = "Info & Logo", Icon = "info" })
    }

    -- TOGGLE VARIABLES
    local AutoTargetRareToggle = false
    local InstantHoldToggle = false
    local FlySpeed = 120
    local BaseCFrame = nil

    -- ---------------------------------------------------------
    -- HELPER FUNCTIONS (TERBANG / TWEEN METHOD)
    -- ---------------------------------------------------------
    
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
    -- TAB 1: AUTO TARGET RARE EGGS (SECRET / ETERNAL / DIVINE)
    ---------------------------------------------------------
    
    Tabs.AutoFarm:AddButton({
        Title = "1. Set Posisi Base / Tanaman (Wajib)",
        Description = "Berdiri di area tempat menyimpan telur lalu klik ini",
        Callback = function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                BaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
                Fluent:Notify({
                    Title = "Base Saved!",
                    Content = "Lokasi penyimpanan telur berhasil didaftarkan.",
                    Duration = 3
                })
            end
        end
    })

    Tabs.AutoFarm:AddToggle("AutoRareSteal", {
        Title = "Auto Snipe (Secret / Eternal / Divine)",
        Default = false,
        Callback = function(Value)
            AutoTargetRareToggle = Value
            task.spawn(function()
                while AutoTargetRareToggle do
                    pcall(function()
                        local targetPrompt = GetPriorityEgg()
                        
                        if targetPrompt and BaseCFrame then
                            local eggPart = targetPrompt.Parent:IsA("BasePart") and targetPrompt.Parent or targetPrompt.Parent:FindFirstChildWhichIsA("BasePart")
                            
                            if eggPart then
                                FlyToCFrame(eggPart.CFrame)
                                task.wait(0.1)
                                
                                targetPrompt.HoldDuration = 0
                                fireproximityprompt(targetPrompt)
                                task.wait(0.2)
                                
                                FlyToCFrame(BaseCFrame)
                                task.wait(0.5)
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
        Content = "Developed by " .. DEVELOPER_NAME .. ".\nSpecial Features: Auto Detect Secret, Eternal, Divine Eggs."
    })

    -- MENAMPILKAN LOGO TOP4TOP
    Tabs.Credits:AddImage("ScriptLogo", {
        Title = "Logo Script OMOX PRO",
        Image = SCRIPT_LOGO_URL
    })

    Fluent:Notify({
        Title = SCRIPT_NAME,
        Content = "Script Berhasil Di-load! Logo & Fitur Siap Digunakan.",
        Duration = 4
    })
end
