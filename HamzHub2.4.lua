-- 🌱 HamzHub v2.4 FIXED - Garden Horizons (Feb 2026 Update)
-- Load Library (pakai mirror yang lebih stabil 2026)
local success, Library = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua", true))()
end)

if not success or not Library then
    -- Fallback sederhana kalau Kavo down (simple notify + print)
    warn("Kavo UI gagal load! Pakai executor lain atau cek koneksi.")
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "HamzHub Error",
        Text = "UI Library gagal dimuat. Coba executor lain atau update script.",
        Duration = 10
    })
    return
end

local Window = Library.CreateLib("HamzHub 🌱 v2.4 | Garden Horizons FIXED", "Ocean")

-- Tabs
local FarmTab    = Window:NewTab("🌱 Auto Farm")
local PlantTab   = Window:NewTab("🌿 Plant & Lush")
local MoneyTab   = Window:NewTab("💰 Money & Dupe")
local PlayerTab  = Window:NewTab("🏃 Player")
local MiscTab    = Window:NewTab("🔧 Misc")

-- States
local states = {
    harvest = false, lush = false, plant = false, water = false,
    sell = false, infmoney = false, walkspeed = false, jumppower = false
}

-- Variables
local selectedSeed = "Carrot Seed"
local walkSpeedValue = 16
local jumpPowerValue = 50

local player = game.Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local run = game:GetService("RunService")

-- Better notify
local function notify(msg, dur)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "HamzHub", Text = msg, Duration = dur or 4
        })
    end)
end

-- Wait character safely
local character = player.Character or player.CharacterAdded:Wait()
player.CharacterAdded:Connect(function(new)
    character = new
    task.wait(0.5)
    if states.walkspeed then character.Humanoid.WalkSpeed = walkSpeedValue end
    if states.jumppower then character.Humanoid.JumpPower = jumpPowerValue end
end)

-- Improved equip seed (lebih toleran nama)
local function equipSeed(seedName)
    pcall(function()
        local keyword = seedName:lower():gsub(" seed", ""):gsub(" ", "")
        for _, item in ipairs(player.Backpack:GetChildren()) do
            if item:IsA("Tool") and item.Name:lower():find(keyword) then
                item.Parent = character
                notify("Equipped: " .. item.Name, 2)
                return true
            end
        end
        local hand = character:FindFirstChildOfClass("Tool")
        if hand and hand.Name:lower():find(keyword) then return true end
        notify("Seed '" .. seedName .. "' tidak ditemukan!", 3)
        return false
    end)
end

-- AUTO HARVEST ALL (dengan rate limit lebih aman)
FarmTab:NewToggle("🔄 Auto Harvest All", "Harvest semua dalam 50 studs", false, function(state)
    states.harvest = state
    if state then
        spawn(function()
            while states.harvest and task.wait(0.4) do
                pcall(function()
                    local hrp = character:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end
                    for _, v in ipairs(workspace:GetDescendants()) do
                        if v:IsA("ProximityPrompt") and v.ActionText:lower():find("harvest") then
                            local dist = (v.Parent.Position - hrp.Position).Magnitude
                            if dist < 50 then
                                fireproximityprompt(v)
                            end
                        end
                    end
                end)
            end
        end)
    end
end)

-- AUTO LUSH (prioritas lush)
PlantTab:NewToggle("🌿 Auto Harvest LUSH Only (x3)", "", false, function(state)
    states.lush = state
    if state then
        spawn(function()
            while states.lush and task.wait(0.45) do
                pcall(function()
                    local hrp = character.HumanoidRootPart
                    for _, v in ipairs(workspace:GetDescendants()) do
                        if v:IsA("ProximityPrompt") and (v.ActionText:lower():find("lush") or v.ActionText:lower():find("harvest")) then
                            if (v.Parent.Position - hrp.Position).Magnitude < 50 then
                                fireproximityprompt(v)
                            end
                        end
                    end
                end)
            end
        end)
    end
end)

-- Dropdown seed
PlantTab:NewDropdown("Pilih Seed", "", {"Carrot Seed","Corn Seed","Onion Seed","Strawberry Seed","Mushroom Seed","Beetroot Seed","Tomato Seed","Apple Seed","Rose Seed","Wheat Seed","Banana Seed","Plum Seed"}, function(val)
    selectedSeed = val
    notify("Dipilih: " .. val)
end)

PlantTab:NewToggle("🌱 Auto Plant", "", false, function(state)
    states.plant = state
    if state then
        spawn(function()
            while states.plant and task.wait(0.5) do
                pcall(function()
                    equipSeed(selectedSeed)
                    local hrp = character.HumanoidRootPart
                    for _, v in ipairs(workspace:GetDescendants()) do
                        if v:IsA("ProximityPrompt") and v.ActionText:lower():find("plant") then
                            if (v.Parent.Position - hrp.Position).Magnitude < 45 then
                                fireproximityprompt(v)
                            end
                        end
                    end
                end)
            end
        end)
    end
end)

-- AUTO WATER (rate lebih lambat biar aman)
PlantTab:NewToggle("💧 Auto Water All", "", false, function(state)
    states.water = state
    if state then
        spawn(function()
            while states.water and task.wait(1.2) do
                pcall(function()
                    local hrp = character.HumanoidRootPart
                    for _, v in ipairs(workspace:GetDescendants()) do
                        if v:IsA("ProximityPrompt") and v.ActionText:lower():find("water") then
                            if (v.Parent.Position - hrp.Position).Magnitude < 45 then
                                fireproximityprompt(v)
                            end
                        end
                    end
                end)
            end
        end)
    end
end)

-- AUTO SELL (dengan check remote exist)
local sellRemote = rs:WaitForChild("RemoteEvents", 5) and rs.RemoteEvents:FindFirstChild("SellItems")
if not sellRemote then
    notify("Sell Remote tidak ditemukan! Auto Sell mati.", 6)
end

FarmTab:NewToggle("💰 Auto Sell All (aman)", "Jeda 4 detik", false, function(state)
    states.sell = state
    if state and sellRemote then
        spawn(function()
            while states.sell and task.wait(4) do
                pcall(function()
                    sellRemote:InvokeServer("SellAll")
                end)
            end
        end)
    end
end)

MoneyTab:NewToggle("💸 Infinite Shillings (RISKY!)", "Jeda 2 detik - BAN RISK TINGGI", false, function(state)
    states.infmoney = state
    if state then
        notify("⚠️ Gunakan ALT ACCOUNT! Cepat terdeteksi.", 6)
        spawn(function()
            while states.infmoney and task.wait(2) do
                pcall(function()
                    sellRemote:InvokeServer("SellAll")
                end)
            end
        end)
    end
end)

-- Dupe (hanya info, method lama gak work)
MoneyTab:NewLabel("Dupe Seed: Method lama sudah patched server-side.")
MoneyTab:NewButton("Coba Clone (client only)", "Cuma visual", function()
    notify("Clone hanya client-side, tidak work di server.", 4)
end)

-- Player Speed
PlayerTab:NewSlider("WalkSpeed", "", 500, 16, function(val)
    walkSpeedValue = val
    if states.walkspeed and character then
        character.Humanoid.WalkSpeed = val
    end
end)

PlayerTab:NewToggle("Enable WalkSpeed", "", false, function(state)
    states.walkspeed = state
    if character then
        character.Humanoid.WalkSpeed = state and walkSpeedValue or 16
    end
end)

-- Jump sama

-- Misc Teleport
MiscTab:NewButton("Teleport ke Nearest Prompt", "", function()
    pcall(function()
        local hrp = character.HumanoidRootPart
        local nearest, minD = nil, math.huge
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") and (v.ActionText:lower():find("plant") or v.ActionText:lower():find("harvest")) then
                local d = (v.Parent.Position - hrp.Position).Magnitude
                if d < minD then minD, nearest = d, v.Parent end
            end
        end
        if nearest then
            hrp.CFrame = nearest.CFrame * CFrame.new(0, 3, 0)
            notify("Teleport ke prompt terdekat!")
        else
            notify("Tidak ada prompt ditemukan.")
        end
    end)
end)

notify("HamzHub v2.4 FIXED Loaded! Pakai ALT ya bro \~", 6)
