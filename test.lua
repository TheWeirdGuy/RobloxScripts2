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
local ESPSection = ESPTab:Section("Advanced Visuals")

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

local ESP = {
    Enabled = false,
    Boxes = false,
    Names = false,
    Tracers = false,
    HealthBar = false,
    Distance = false,
    Chams = false,
    TeamCheck = false,
    VisibilityCheck = false
}

local Drawings = {}

-- Create drawing objects for each player
local function NewDrawing(type)
    local obj = Drawing.new(type)
    obj.Visible = false
    return obj
end

local function SetupPlayer(plr)
    if plr == lp then return end

    Drawings[plr] = {
        BoxOutline = NewDrawing("Square"),
        Box = NewDrawing("Square"),
        Name = NewDrawing("Text"),
        Tracer = NewDrawing("Line"),
        HealthBarOutline = NewDrawing("Square"),
        HealthBar = NewDrawing("Square"),
        Distance = NewDrawing("Text"),
        Cham = Instance.new("Highlight")
    }

    local cham = Drawings[plr].Cham
    cham.FillColor = Color3.fromRGB(255, 0, 0)
    cham.OutlineColor = Color3.fromRGB(255, 255, 255)
    cham.FillTransparency = 0.5
    cham.OutlineTransparency = 0
    cham.Enabled = false
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

-- Setup existing players
for _, plr in pairs(Players:GetPlayers()) do
    SetupPlayer(plr)
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Wait()
    SetupPlayer(plr)
end)

-- ESP Loop
task.spawn(function()
    while task.wait() do
        if not ESP.Enabled then
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
            local char = plr.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then
                for _, obj in pairs(objs) do
                    if typeof(obj) ~= "Instance" then obj.Visible = false end
                end
                continue
            end

            local hrp = char.HumanoidRootPart
            local hum = char:FindFirstChild("Humanoid")

            -- Team check
            if ESP.TeamCheck and plr.Team == lp.Team then
                for _, obj in pairs(objs) do
                    if typeof(obj) ~= "Instance" then obj.Visible = false end
                end
                objs.Cham.Enabled = false
                continue
            end

            local pos, onScreen = cam:WorldToViewportPoint(hrp.Position)
            if not onScreen then
                for _, obj in pairs(objs) do
                    if typeof(obj) ~= "Instance" then obj.Visible = false end
                end
                objs.Cham.Enabled = false
                continue
            end

            -- Visibility check (raycast)
            local visible = true
            if ESP.VisibilityCheck then
                local ray = Ray.new(cam.CFrame.Position, (hrp.Position - cam.CFrame.Position).Unit * 500)
                local hit = workspace:FindPartOnRay(ray, lp.Character)
                visible = hit and hit:IsDescendantOf(char)
            end

            local color = visible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)

            -- Box ESP (dynamic size)
            if ESP.Boxes then
                local scale = 1 / (pos.Z * 0.002)
                local width = 35 * scale
                local height = 55 * scale

                objs.BoxOutline.Visible = true
                objs.BoxOutline.Color = Color3.new(0, 0, 0)
                objs.BoxOutline.Thickness = 3
                objs.BoxOutline.Size = Vector2.new(width, height)
                objs.BoxOutline.Position = Vector2.new(pos.X - width/2, pos.Y - height)

                objs.Box.Visible = true
                objs.Box.Color = color
                objs.Box.Thickness = 1
                objs.Box.Size = Vector2.new(width, height)
                objs.Box.Position = Vector2.new(pos.X - width/2, pos.Y - height)
            else
                objs.Box.Visible = false
                objs.BoxOutline.Visible = false
            end

            -- Name ESP
            if ESP.Names then
                objs.Name.Visible = true
                objs.Name.Text = plr.Name
                objs.Name.Color = color
                objs.Name.Size = 16
                objs.Name.Center = true
                objs.Name.Position = Vector2.new(pos.X, pos.Y - 60)
            else
                objs.Name.Visible = false
            end

            -- Tracers
            if ESP.Tracers then
                objs.Tracer.Visible = true
                objs.Tracer.Color = color
                objs.Tracer.Thickness = 1
                objs.Tracer.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
                objs.Tracer.To = Vector2.new(pos.X, pos.Y)
            else
                objs.Tracer.Visible = false
            end

            -- Health bar
            if ESP.HealthBar then
                local hp = hum.Health / hum.MaxHealth
                local barHeight = 55 * (1 / (pos.Z * 0.002))

                objs.HealthBarOutline.Visible = true
                objs.HealthBarOutline.Color = Color3.new(0, 0, 0)
                objs.HealthBarOutline.Size = Vector2.new(4, barHeight)
                objs.HealthBarOutline.Position = Vector2.new(pos.X - 40, pos.Y - barHeight)

                objs.HealthBar.Visible = true
                objs.HealthBar.Color = Color3.fromRGB(0, 255, 0)
                objs.HealthBar.Size = Vector2.new(2, barHeight * hp)
                objs.HealthBar.Position = Vector2.new(pos.X - 39, pos.Y - (barHeight * hp))
            else
                objs.HealthBar.Visible = false
                objs.HealthBarOutline.Visible = false
            end

            -- Distance ESP
            if ESP.Distance then
                local dist = math.floor((lp.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                objs.Distance.Visible = true
                objs.Distance.Text = dist .. "m"
                objs.Distance.Color = color
                objs.Distance.Size = 14
                objs.Distance.Center = true
                objs.Distance.Position = Vector2.new(pos.X, pos.Y + 60)
            else
                objs.Distance.Visible = false
            end

            -- Chams
            objs.Cham.Enabled = ESP.Chams
            objs.Cham.FillColor = color
            objs.Cham.Parent = char
        end
    end
end)

----------------------------------------------------
-- UI Toggles
----------------------------------------------------

ESPSection:Toggle("Enable ESP", false, function(v) ESP.Enabled = v end)
ESPSection:Toggle("Boxes", false, function(v) ESP.Boxes = v end)
ESPSection:Toggle("Names", false, function(v) ESP.Names = v end)
ESPSection:Toggle("Tracers", false, function(v) ESP.Tracers = v end)
ESPSection:Toggle("Health Bar", false, function(v) ESP.HealthBar = v end)
ESPSection:Toggle("Distance", false, function(v) ESP.Distance = v end)
ESPSection:Toggle("Chams", false, function(v) ESP.Chams = v end)
ESPSection:Toggle("Team Check", false, function(v) ESP.TeamCheck = v end)
ESPSection:Toggle("Visibility Check", false, function(v) ESP.VisibilityCheck = v end)



