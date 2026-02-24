local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Attrixx/FreeScripts/main/YTUILib1.lua"))():init("Baseplate Hub")

----------------------------------------------------
-- MAIN TAB
----------------------------------------------------
local MainTab = Library:Tab("Main")
local MainSection = MainTab:Section("Player Settings")

MainSection:Slider("Speed", 16, 16, 200, function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)

MainSection:Slider("Jump", 50, 50, 200, function(value)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
end)

----------------------------------------------------
-- COMBAT TAB
----------------------------------------------------
local CombatTab = Library:Tab("Combat")
local CombatSection = CombatTab:Section("Universal Combat")

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

CombatSection:Toggle("FOV Circle", false, function(state)
    FOV.Visible = state

    task.spawn(function()
        while state do
            task.wait()
            FOV.Position = UIS:GetMouseLocation()
        end
    end)
end)

CombatSection:Slider("FOV Size", 120, 50, 300, function(value)
    FOV.Radius = value
end)

----------------------------------------------------
-- AIMLOCK (RMB HOLD + FOV CHECK + WALL CHECK)
----------------------------------------------------
CombatSection:Toggle("Aimlock (Hold RMB)", false, function(state)
    getgenv().AimlockEnabled = state

    local holding = false

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

    task.spawn(function()
        while getgenv().AimlockEnabled do
            task.wait()

            if holding then
                local closest = nil
                local closestDist = 999

                for _, plr in pairs(game.Players:GetPlayers()) do
                    if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = plr.Character.HumanoidRootPart

                        local screenPos, onScreen = cam:WorldToViewportPoint(hrp.Position)
                        if onScreen then
                            local mousePos = UIS:GetMouseLocation()
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

                            if dist <= FOV.Radius then
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
CombatSection:Toggle("Hitbox Expander", false, function(state)
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

local ESPTab = Library:Tab("ESP")
local ESPSection = ESPTab:Section("Visuals")

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

local ESPSettings = {
    Enabled = false,
    Boxes = false,
    Names = false,
    Tracers = false,
    Health = false,
    Distance = false,
    Chams = false,
    TeamCheck = false
}

local Drawings = {}

-- Create drawing objects for each player
local function CreateESP(plr)
    if plr == lp then return end
    Drawings[plr] = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Tracer = Drawing.new("Line"),
        Health = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Cham = Instance.new("Highlight")
    }

    local cham = Drawings[plr].Cham
    cham.FillColor = Color3.fromRGB(255, 0, 0)
    cham.OutlineColor = Color3.fromRGB(255, 255, 255)
    cham.FillTransparency = 0.5
    cham.OutlineTransparency = 0
    cham.Enabled = false
    cham.Parent = plr.Character
end

-- Remove ESP when player leaves
Players.PlayerRemoving:Connect(function(plr)
    if Drawings[plr] then
        for _, obj in pairs(Drawings[plr]) do
            if typeof(obj) == "Instance" then
                obj:Destroy()
            else
                obj:Remove()
            end
        end
        Drawings[plr] = nil
    end
end)

-- Create ESP for existing players
for _, plr in pairs(Players:GetPlayers()) do
    CreateESP(plr)
end

-- Create ESP for new players
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Wait()
    CreateESP(plr)
end)

-- ESP Loop
task.spawn(function()
    while task.wait() do
        if not ESPSettings.Enabled then
            for _, objs in pairs(Drawings) do
                for _, obj in pairs(objs) do
                    if typeof(obj) ~= "Instance" then
                        obj.Visible = false
                    else
                        obj.Enabled = false
                    end
                end
            end
            continue
        end

        for plr, objs in pairs(Drawings) do
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = plr.Character.HumanoidRootPart
                local hum = plr.Character:FindFirstChild("Humanoid")

                if ESPSettings.TeamCheck and plr.Team == lp.Team then
                    objs.Box.Visible = false
                    objs.Name.Visible = false
                    objs.Tracer.Visible = false
                    objs.Health.Visible = false
                    objs.Distance.Visible = false
                    objs.Cham.Enabled = false
                    continue
                end

                local pos, onScreen = cam:WorldToViewportPoint(hrp.Position)
                if not onScreen then
                    objs.Box.Visible = false
                    objs.Name.Visible = false
                    objs.Tracer.Visible = false
                    objs.Health.Visible = false
                    objs.Distance.Visible = false
                    objs.Cham.Enabled = false
                    continue
                end

                -- BOX ESP
                if ESPSettings.Boxes then
                    objs.Box.Visible = true
                    objs.Box.Size = Vector2.new(50, 75)
                    objs.Box.Position = Vector2.new(pos.X - 25, pos.Y - 75)
                    objs.Box.Color = Color3.fromRGB(255, 255, 255)
                    objs.Box.Thickness = 2
                else
                    objs.Box.Visible = false
                end

                -- NAME ESP
                if ESPSettings.Names then
                    objs.Name.Visible = true
                    objs.Name.Text = plr.Name
                    objs.Name.Position = Vector2.new(pos.X, pos.Y - 90)
                    objs.Name.Color = Color3.fromRGB(255, 255, 255)
                    objs.Name.Size = 16
                    objs.Name.Center = true
                else
                    objs.Name.Visible = false
                end

                -- TRACERS
                if ESPSettings.Tracers then
                    objs.Tracer.Visible = true
                    objs.Tracer.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
                    objs.Tracer.To = Vector2.new(pos.X, pos.Y)
                    objs.Tracer.Color = Color3.fromRGB(255, 255, 255)
                    objs.Tracer.Thickness = 1
                else
                    objs.Tracer.Visible = false
                end

                -- HEALTH ESP
                if ESPSettings.Health then
                    objs.Health.Visible = true
                    objs.Health.Text = "HP: " .. math.floor(hum.Health)
                    objs.Health.Position = Vector2.new(pos.X, pos.Y + 40)
                    objs.Health.Color = Color3.fromRGB(0, 255, 0)
                    objs.Health.Size = 14
                    objs.Health.Center = true
                else
                    objs.Health.Visible = false
                end

                -- DISTANCE ESP
                if ESPSettings.Distance then
                    local dist = math.floor((lp.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                    objs.Distance.Visible = true
                    objs.Distance.Text = dist .. "m"
                    objs.Distance.Position = Vector2.new(pos.X, pos.Y + 55)
                    objs.Distance.Color = Color3.fromRGB(255, 255, 0)
                    objs.Distance.Size = 14
                    objs.Distance.Center = true
                else
                    objs.Distance.Visible = false
                end

                -- CHAMS
                objs.Cham.Enabled = ESPSettings.Chams
            end
        end
    end
end)

----------------------------------------------------
-- UI Toggles
----------------------------------------------------

ESPSection:Toggle("Enable ESP", false, function(v)
    ESPSettings.Enabled = v
end)

ESPSection:Toggle("Boxes", false, function(v)
    ESPSettings.Boxes = v
end)

ESPSection:Toggle("Names", false, function(v)
    ESPSettings.Names = v
end)

ESPSection:Toggle("Tracers", false, function(v)
    ESPSettings.Tracers = v
end)

ESPSection:Toggle("Health ESP", false, function(v)
    ESPSettings.Health = v
end)

ESPSection:Toggle("Distance ESP", false, function(v)
    ESPSettings.Distance = v
end)

ESPSection:Toggle("Chams (Highlight)", false, function(v)
    ESPSettings.Chams = v
end)

ESPSection:Toggle("Team Check", false, function(v)
    ESPSettings.TeamCheck = v
end)

