local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Baseplate", "DarkTheme")

-- MAIN TAB
local Main = Window:NewTab("Main")
local MainSection = Main:NewSection("Player Settings")

MainSection:NewSlider("Speed", "Change WalkSpeed", 200, 16, function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)

MainSection:NewSlider("Jump", "Change JumpPower", 200, 50, function(value)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
end)

-- COMBAT TAB
local Combat = Window:NewTab("Combat")
local CombatSection = Combat:NewSection("Universal Combat")

-- UNIVERSAL AIMLOCK
CombatSection:NewToggle("Aimlock", "Locks aim onto nearest player", function(state)
    getgenv().Aimlock = state

    local cam = workspace.CurrentCamera
    local lp = game.Players.LocalPlayer

    while getgenv().Aimlock do
        task.wait()

        local closest, dist = nil, 999

        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local mag = (lp.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                if mag < dist then
                    dist = mag
                    closest = plr
                end
            end
        end

        if closest then
            cam.CFrame = CFrame.new(cam.CFrame.Position, closest.Character.HumanoidRootPart.Position)
        end
    end
end)

-- UNIVERSAL HITBOX EXPANDER
CombatSection:NewToggle("Hitbox Expander", "Makes enemies easier to hit", function(state)
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= game.Players.LocalPlayer and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if state then
                    hrp.Size = Vector3.new(10, 10, 10)
                    hrp.Transparency = 0.7
                    hrp.Color = Color3.fromRGB(255, 0, 0)
                    hrp.Material = Enum.Material.Neon
                else
                    hrp.Size = Vector3.new(2, 2, 1)
                    hrp.Transparency = 1
                end
            end
        end
    end
end)
