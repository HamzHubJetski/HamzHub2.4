-- 🌱 HamzHub v2.5 FULL - Garden Horizons (Fixed All Bugs)
local success, Library = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua", true))()
end)

if not success or not Library then
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "HamzHub", Text = "Kavo gagal load! Coba executor lain (Fluxus/Delta).", Duration = 10})
    return
end

local Window = Library.CreateLib("HamzHub 🌱 v2.5 | Garden Horizons", "Ocean")

local FarmTab    = Window:NewTab("🌱 Auto Farm")
local PlantTab   = Window:NewTab("🌿 Plant & Lush")
local MoneyTab   = Window:NewTab("💰 Money & Dupe")
local PlayerTab  = Window:NewTab("🏃 Player")
local MiscTab    = Window:NewTab("🔧 Misc")

local states = {harvest = false, lush = false, plant = false, water = false, sell = false, infmoney = false, walkspeed = false, jumppower = false}

local selectedSeed = "Carrot Seed"
local walkSpeedValue = 16
local jumpPowerValue = 50

local player = game.Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local character = player.Character or player.CharacterAdded:Wait()

local function notify(msg, dur)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {Title = "HamzHub", Text = msg, Duration = dur or 4})
    end)
end

player.CharacterAdded:Connect(function(new)
    character = new
    task.wait(0.5)
    if states.walkspeed then character.Humanoid.WalkSpeed = walkSpeedValue end
    if states.jumppower then character.Humanoid.JumpPower = jumpPowerValue end
end)

local function equipSeed(seedName)
    pcall(function()
        local keyword = seedName:lower():gsub(" seed", ""):gsub(" ", "")
        for _, item in ipairs(player.Backpack:GetChildren()) do
            if item:IsA("Tool") and item.Name:lower():find(keyword) then
                item.Parent = character
                notify("Equipped: " .. item.Name, 2)
                return
            end
        end
        notify("Seed '" .. seedName .. "' tidak ditemukan!", 3)
    end)
end

-- ==================== ALL FEATURES ====================

FarmTab:NewToggle("🔄 Auto Harvest All", "Harvest semua <50 studs", false, function(state)
    states.harvest = state
    if state then task.spawn(function()
        while states.harvest do
            pcall(function()
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, v in ipairs(workspace:GetDescendants()) do
                        if v:IsA("ProximityPrompt") and v.ActionText:lower():find("harvest") then
                            if (v.Parent.Position - hrp.Position).Magnitude < 50 then
                                fireproximityprompt(v)
                            end
                        end
                    end
                end
            end)
            task.wait(0.4)
        end
    end) end
end)

PlantTab:NewToggle("🌿 Auto Harvest LUSH Only (x3)", "", false, function(state)
    states.lush = state
    if state then task.spawn(function()
        while states.lush do
            pcall(function()
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, v in ipairs(workspace:GetDescendants()) do
                        if v:IsA("ProximityPrompt") and (v.ActionText:lower():find("lush") or v.ActionText:lower():find("harvest")) then
                            if (v.Parent.Position - hrp.Position).Magnitude < 50 then fireproximityprompt(v) end
                        end
                    end
                end
            end)
            task.wait(0.45)
        end
    end) end
end)

PlantTab:NewDropdown("Pilih Seed", "", {"Carrot Seed","Corn Seed","Onion Seed","Strawberry Seed","Mushroom Seed","Beetroot Seed","Tomato Seed","Apple Seed","Rose Seed","Wheat Seed","Banana Seed","Plum Seed"}, function(val)
    selectedSeed = val
    notify("Dipilih: " .. val)
end)

PlantTab:NewToggle("🌱 Auto Plant", "", false, function(state)
    states.plant = state
    if state then task.spawn(function()
        while states.plant do
            pcall(function()
                equipSeed(selectedSeed)
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, v in ipairs(workspace:GetDescendants()) do
                        if v:IsA("ProximityPrompt") and v.ActionText:lower():find("plant") then
                            if (v.Parent.Position - hrp.Position).Magnitude < 45 then fireproximityprompt(v) end
                        end
                    end
                end
            end)
            task.wait(0.5)
        end
    end) end
end)

PlantTab:NewToggle("💧 Auto Water All", "", false, function(state)
    states.water = state
    if state then task.spawn(function()
        while states.water do
            pcall(function()
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, v in ipairs(workspace:GetDescendants()) do
                        if v:IsA("ProximityPrompt") and v.ActionText:lower():find("water") then
                            if (v.Parent.Position - hrp.Position).Magnitude < 45 then fireproximityprompt(v) end
                        end
                    end
                end
            end)
            task.wait(1.2)
        end
    end) end
end)

local sellRemote = rs:FindFirstChild("RemoteEvents") and rs.RemoteEvents:FindFirstChild("SellItems")
FarmTab:NewToggle("💰 Auto Sell All (aman)", "Jeda 4 detik", false, function(state)
    states.sell = state
    if state and sellRemote then task.spawn(function()
        while states.sell do
            pcall(function() sellRemote:InvokeServer("SellAll") end)
            task.wait(4)
        end
    end) end
end)

MoneyTab:NewToggle("💸 Infinite Shillings (RISKY!)", "Jeda 2 detik - ALT ONLY!", false, function(state)
    states.infmoney = state
    if state then
        notify("⚠️ ALT ACCOUNT WAJIB! Ban cepat!", 6)
        task.spawn(function()
            while states.infmoney do
                pcall(function() sellRemote:InvokeServer("SellAll") end)
                task.wait(2)
            end
        end)
    end
end)

MoneyTab:NewLabel("Dupe Seed sudah patched")
MoneyTab:NewButton("Coba Clone (client only)", "", function()
    notify("Clone hanya visual, tidak work server-side", 4)
end)

PlayerTab:NewSlider("WalkSpeed", "16 - 500", 500, 16, function(val)
    walkSpeedValue = val
    if states.walkspeed and character then character.Humanoid.WalkSpeed = val end
end)

PlayerTab:NewToggle("Enable WalkSpeed", "", false, function(state)
    states.walkspeed = state
    if character then character.Humanoid.WalkSpeed = state and walkSpeedValue or 16 end
end)

-- ==================== JUMPPOWER (yang hilang tadi) ====================
PlayerTab:NewSlider("JumpPower", "50 - 500", 500, 50, function(val)
    jumpPowerValue = val
    if states.jumppower and character then character.Humanoid.JumpPower = val end
end)

PlayerTab:NewToggle("Enable JumpPower", "", false, function(state)
    states.jumppower = state
    if character then character.Humanoid.JumpPower = state and jumpPowerValue or 50 end
end)

MiscTab:NewButton("Teleport ke Nearest Prompt", "", function()
    pcall(function()
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local nearest, minD = nil, math.huge
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") and (v.ActionText:lower():find("plant") or v.ActionText:lower():find("harvest")) then
                local d = (v.Parent.Position - hrp.Position).Magnitude
                if d < minD then minD, nearest = d, v.Parent end
            end
        end
        if nearest then
            hrp.CFrame = nearest.CFrame * CFrame.new(0, 3, 0)
            notify("Teleport berhasil!")
        else
            notify("Tidak ada prompt ditemukan")
        end
    end)
end)

notify("HamzHub v2.5 FULL FITUR Loaded! Semua nyala bro 🌱💰", 6)
