local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Baseplate", "DarkTheme")

----------------------------------------------------
-- MAIN TAB
----------------------------------------------------
local Main = Window:NewTab("Main")
local MainSection = Main:NewSection("Player Settings")

MainSection:NewSlider("Speed", "Change WalkSpeed", 200, 16, function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)

MainSection:NewSlider("Jump", "Change JumpPower", 200, 50, function(value)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
end)

----------------------------------------------------
-- COMBAT TAB
----------------------------------------------------
local Combat = Window:NewTab("Combat")
local CombatSection = Combat:NewSection("Universal Combat")

----------------------------------------------------
-- FOV CIRCLE
----------------------------------------------------
local UIS = game:GetService("UserInputService")
local cam = workspace.CurrentCamera
local lp = game.Players.LocalPlayer

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
            FOV.Position = UIS:GetMouseLocation()
        end
    end)
end)

CombatSection:NewSlider("FOV Size", "Adjust the FOV radius", 300, 50, function(value)
    FOV.Radius = value
end)

----------------------------------------------------
-- AIMLOCK (RMB HOLD + FOV CHECK + WALL CHECK)
----------------------------------------------------
CombatSection:NewToggle("Aimlock (Hold RMB)", "Locks only inside FOV and no walls", function(state)
    getgenv().AimlockEnabled = state

    local holding = false

    -- Detect RMB hold
    UIS.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            holding = true
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            holding = false
        end
    end)

    -- Aimlock loop
    task.spawn(function()
        while getgenv().AimlockEnabled do
            task.wait()

            if holding then
                local closest = nil
                local closestDist = 999

                for _, plr in pairs(game.Players:GetPlayers()) do
                    if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = plr.Character.HumanoidRootPart

                        -- Screen position
                        local screenPos, onScreen = cam:WorldToViewportPoint(hrp.Position)
                        if onScreen then
                            local mousePos = UIS:GetMouseLocation()
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

                            -- Check inside FOV
                            if dist <= FOV.Radius then

                                -- WALL CHECK
                                local ray = Ray.new(cam.CFrame.Position, (hrp.Position - cam.CFrame.Position).Unit * 500)
                                local hit = workspace:FindPartOnRay(ray, lp.Character)

                                if hit and hit:IsDescendantOf(plr.Character) then
                                    if dist < closestDist then
                                        closestDist = dist
                                        closest = plr
                                    end
                                end
                            end
                        end
                    end
                end

                -- Lock onto closest valid target
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

----------------------------------------------------
-- HITBOX EXPANDER
----------------------------------------------------
CombatSection:NewToggle("Hitbox Expander", "Makes enemies easier to hit", function(state)
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= lp and plr.Character then
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
