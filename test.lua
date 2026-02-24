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

-- UNIVERSAL AIMLOCK (RMB HOLD)
CombatSection:NewToggle("Aimlock (Hold RMB)", "Locks aim only while holding right mouse button", function(state)
    getgenv().AimlockEnabled = state

    local UserInputService = game:GetService("UserInputService")
    local cam = workspace.CurrentCamera
    local lp = game.Players.LocalPlayer

    local holding = false

    -- Detect RMB hold
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            holding = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            holding = false
        end
    end)

    -- Aimlock loop
    task.spawn(function()
        while getgenv().AimlockEnabled do
            task.wait()

            if holding then
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
                    cam.CFrame = CFrame.new(
                        cam.CFrame.Position,
                        closest.Character.HumanoidRootPart.Position
                    )
                end
            end
        end
    end)
end)

-- FOV CIRCLE
local FOV = Drawing.new("Circle")
FOV.Visible = false
FOV.Thickness = 2
FOV.Radius = 120
FOV.Color = Color3.fromRGB(255, 255, 0)
FOV.Filled = false
FOV.NumSides = 100

CombatSection:NewToggle("FOV Circle", "Shows your aimlock FOV", function(state)
    FOV.Visible = state

    task.spawn(function()
        while state do
            task.wait()
            FOV.Position = game:GetService("UserInputService"):GetMouseLocation()
        end
    end)
end)

CombatSection:NewSlider("FOV Size", "Adjust the FOV radius", 300, 50, function(value)
    FOV.Radius = value
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
