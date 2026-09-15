-- =========================================================
-- SCRIPT CONFIGURATION
-- =========================================================
local SCRIPT_NAME = "OMOX PRO"
local DEVELOPER_NAME = "FENGXIU"
local PASSWORD_CORRECT = "fengxomo"

-- [ LINK FOTO / LOGO SCRIPT ]
local SCRIPT_LOGO_URL = "https://f.top4top.io/p_39100kq8x0.jpg" 

-- =========================================================
-- LOAD UI LIBRARY & SERVICES
-- =========================================================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
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
    Theme = "Sky",
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
    Description = "Verifikasi akses script OMOX PRO",
    Callback = function()
        if PasswordInput == PASSWORD_CORRECT then
            Fluent:Destroy()
            task.wait(0.3)
            LoadMainScript()
        else
            Fluent:Notify({
                Title = "Akses Ditolak!",
                Content = "Password salah! Silakan coba lagi.",
                Duration = 3
            })
        end
    end
})

-- ---------------------------------------------------------
-- SCRIPT UTAMA
-- ---------------------------------------------------------
function LoadMainScript()
    local Window = Fluent:CreateWindow({
        Title = SCRIPT_NAME,
        SubTitle = "By " .. DEVELOPER_NAME,
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 420),
        Theme = "Sky",
        MinimizeKey = Enum.KeyCode.RightControl
    })

    local Tabs = {
        Main = Window:AddTab({ Title = "Egg Features", Icon = "egg" }),
        Attack = Window:AddTab({ Title = "Pukul & Curi", Icon = "sword" }),
        Player = Window:AddTab({ Title = "Player", Icon = "user" }),
        Credits = Window:AddTab({ Title = "Info", Icon = "info" })
    }

    local AutoStealToggle = false
    local InstantHoldToggle = false
    local AttackStealToggle = false
    local BaseCFrame = nil

    -- FUNGSI MEMUKUL PRESISI (Melengkapi senjata & pemicu klik)
    local function EquipAndHit()
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            
            -- Cari alat pukul di Backpack atau Character
            local tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool") or char:FindFirstChildOfClass("Tool")
            if tool then
                tool.Parent = char
                task.wait(0.05)
                tool:Activate()
            end
        end)
    end

    ---------------------------------------------------------
    -- TAB 1: EGG FEATURES
    ---------------------------------------------------------
    
    -- INSTANT STEAL
    Tabs.Main:AddToggle("InstantHold", {
        Title = "Instant Steal (0s Hold)",
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
                    task.wait(0.3)
                end
            end)
        end
    })

    -- AUTO STEAL EGG
    Tabs.Main:AddToggle("AutoSteal", {
        Title = "Auto Steal Egg Loop",
        Default = false,
        Callback = function(Value)
            AutoStealToggle = Value
            task.spawn(function()
                while AutoStealToggle do
                    pcall(function()
                        for _, prompt in pairs(Workspace:GetDescendants()) do
                            if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                                fireproximityprompt(prompt)
                            end
                        end
                    end)
                    task.wait(0.05)
                end
            end)
        end
    })

    ---------------------------------------------------------
    -- TAB 2: PUKUL, AMBIL TELUR, LALU KE BASE
    ---------------------------------------------------------
    
    Tabs.Attack:AddButton({
        Title = "Set Posisi Base (Wajib)",
        Description = "Klik ini saat kamu berdiri di area Base milikmu",
        Callback = function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                BaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
                Fluent:Notify({
                    Title = "Base Terdaftar!",
                    Content = "Koordinat Base kamu berhasil disimpan.",
                    Duration = 3
                })
            end
        end
    })

    Tabs.Attack:AddToggle("AttackStealBase", {
        Title = "Auto Pukul + Curi + Base",
        Default = false,
        Callback = function(Value)
            AttackStealToggle = Value
            task.spawn(function()
                while AttackStealToggle do
                    pcall(function()
                        local myChar = LocalPlayer.Character
                        if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                            
                            -- Cari ProximityPrompt telur
                            for _, prompt in pairs(Workspace:GetDescendants()) do
                                if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                                    local eggPos = prompt.Parent:IsA("BasePart") and prompt.Parent.Position or prompt.Parent:GetPivot().Position
                                    
                                    -- Cek pemain lain yang sedang memegang/dekat telur itu
                                    for _, otherPlayer in pairs(Players:GetPlayers()) do
                                        if otherPlayer ~= LocalPlayer and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                            local dist = (otherPlayer.Character.HumanoidRootPart.Position - eggPos).Magnitude
                                            
                                            -- Jika pemain lain jaraknya kurang dari 15 stud dari telur
                                            if dist <= 15 then
                                                -- 1. Teleport ke target
                                                myChar.HumanoidRootPart.CFrame = otherPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2)
                                                
                                                -- 2. Pukul berkali-kali sampai telur lepas/jatuh
                                                for i = 1, 3 do
                                                    EquipAndHit()
                                                    task.wait(0.05)
                                                end
                                                
                                                -- 3. Curi Telur secara instan
                                                prompt.HoldDuration = 0
                                                fireproximityprompt(prompt)
                                                task.wait(0.1)
                                                
                                                -- 4. Langsung kembali ke Base
                                                if BaseCFrame then
                                                    myChar.HumanoidRootPart.CFrame = BaseCFrame
                                                end
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    })

    ---------------------------------------------------------
    -- TAB 3 & 4: PLAYER SETTINGS & INFO
    ---------------------------------------------------------
    Tabs.Player:AddSlider("WalkSpeed", {
        Title = "Speed Jalan",
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
        Content = "Script dikembangkan khusus untuk game Mencuri Sebuah Telur oleh " .. DEVELOPER_NAME .. "."
    })

    if SCRIPT_LOGO_URL ~= "" and SCRIPT_LOGO_URL ~= "rbxassetid://0" then
        Tabs.Credits:AddImage("ScriptLogo", { Title = "Logo", Image = SCRIPT_LOGO_URL })
    end

    Fluent:Notify({
        Title = SCRIPT_NAME,
        Content = "Berhasil Login! OMOX PRO Siap Digunakan.",
        Duration = 4
    })
end
