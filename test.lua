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

-----------------------------
-- AIMLOCK SETTINGS
-----------------------------
local Aimbot = {
    Enabled = false,
    HoldKey = Enum.UserInputType.MouseButton2,
    FOV = 120,
    Smoothness = 0.20,
    Prediction = 0.12,
    HitChance = 100,
    WallCheck = true,
    TeamCheck = false,
    TargetPart = "Head"
}

local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Holding = false

-----------------------------
-- FOV CIRCLE
-----------------------------
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Color = Color3.fromRGB(255, 255, 0)
FOVCircle.Thickness = 2
FOVCircle.Radius = Aimbot.FOV
FOVCircle.Filled = false
FOVCircle.NumSides = 100

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UIS:GetMouseLocation()
    FOVCircle.Radius = Aimbot.FOV
end)

-----------------------------
-- GET CLOSEST PLAYER
-----------------------------
local function GetClosest()
    local mousePos = UIS:GetMouseLocation()
    local closest = nil
    local closestDist = Aimbot.FOV

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild(Aimbot.TargetPart) then

            if Aimbot.TeamCheck and plr.Team == LocalPlayer.Team then
                continue
            end

            local part = plr.Character[Aimbot.TargetPart]
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)

            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if dist < closestDist then

                    -- WALL CHECK
                    if Aimbot.WallCheck then
                        local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 500)
                        local hit = workspace:FindPartOnRay(ray, LocalPlayer.Character)

                        if hit and not hit:IsDescendantOf(plr.Character) then
                            continue
                        end
                    end

                    closestDist = dist
                    closest = plr
                end
            end
        end
    end

    return closest
end

-----------------------------
-- AIMLOCK LOOP
-----------------------------
RunService.RenderStepped:Connect(function()
    if not Aimbot.Enabled or not Holding then return end

    if math.random(1, 100) > Aimbot.HitChance then return end

    local target = GetClosest()
    if not target then return end

    local part = target.Character[Aimbot.TargetPart]

    -- Prediction
    local predictedPos = part.Position
    if target.Character:FindFirstChild("HumanoidRootPart") then
        predictedPos = predictedPos + target.Character.HumanoidRootPart.Velocity * Aimbot.Prediction
    end

    -- Smooth aim
    local newCF = CFrame.new(Camera.CFrame.Position, predictedPos)
    Camera.CFrame = Camera.CFrame:Lerp(newCF, Aimbot.Smoothness)
end)

-----------------------------
-- INPUT HANDLING
-----------------------------
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Aimbot.HoldKey then
        Holding = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Aimbot.HoldKey then
        Holding = false
    end
end)

-----------------------------
-- UI IMPLEMENTATION
-----------------------------
local CombatTab = Library:Tab("Combat")
local Section = CombatTab:Section("Aimlock")

Section:Toggle("Enable Aimlock", false, function(v)
    Aimbot.Enabled = v
end)

Section:Slider("FOV", 120, 50, 300, function(v)
    Aimbot.FOV = v
end)

Section:Slider("Smoothness", 0.20, 0.01, 1, function(v)
    Aimbot.Smoothness = v
end)

Section:Slider("Prediction", 0.12, 0, 0.5, function(v)
    Aimbot.Prediction = v
end)

Section:Slider("Hit Chance", 100, 1, 100, function(v)
    Aimbot.HitChance = v
end)

Section:Toggle("Wall Check", true, function(v)
    Aimbot.WallCheck = v
end)

Section:Toggle("Team Check", false, function(v)
    Aimbot.TeamCheck = v
end)

Section:Dropdown("Target Part", {"Head", "HumanoidRootPart"}, "Head", function(v)
    Aimbot.TargetPart = v
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

-----------------------------
-- SETTINGS
-----------------------------
local Settings = {
    SkeletonESP = false,
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    SkeletonThickness = 1,
    SkeletonTransparency = 1,
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Drawings = {
    Skeleton = {}
}

-----------------------------
-- SKELETON BONES
-----------------------------
local Bones = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
}

-----------------------------
-- CREATE SKELETON ESP
-----------------------------
local function CreateESP(player)
    if Drawings.Skeleton[player] then return end

    Drawings.Skeleton[player] = {}

    for _, bone in ipairs(Bones) do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = Settings.SkeletonColor
        line.Thickness = Settings.SkeletonThickness
        line.Transparency = Settings.SkeletonTransparency
        table.insert(Drawings.Skeleton[player], line)
    end
end

-----------------------------
-- REMOVE ESP
-----------------------------
local function RemoveESP(player)
    if Drawings.Skeleton[player] then
        for _, line in ipairs(Drawings.Skeleton[player]) do
            line:Remove()
        end
        Drawings.Skeleton[player] = nil
    end
end

-----------------------------
-- UPDATE SKELETON ESP
-----------------------------
local function UpdateESP(player)
    if not Settings.SkeletonESP then
        if Drawings.Skeleton[player] then
            for _, line in ipairs(Drawings.Skeleton[player]) do
                line.Visible = false
            end
        end
        return
    end

    local char = player.Character
    if not char then return end

    local skeleton = Drawings.Skeleton[player]
    if not skeleton then return end

    local index = 1

    for _, bone in ipairs(Bones) do
        local part1 = char:FindFirstChild(bone[1])
        local part2 = char:FindFirstChild(bone[2])

        local line = skeleton[index]
        index += 1

        if part1 and part2 then
            local p1, v1 = Camera:WorldToViewportPoint(part1.Position)
            local p2, v2 = Camera:WorldToViewportPoint(part2.Position)

            if v1 and v2 then
                line.Visible = true
                line.From = Vector2.new(p1.X, p1.Y)
                line.To = Vector2.new(p2.X, p2.Y)
                line.Color = Settings.SkeletonColor
                line.Thickness = Settings.SkeletonThickness
                line.Transparency = Settings.SkeletonTransparency
            else
                line.Visible = false
            end
        else
            line.Visible = false
        end
    end
end

-----------------------------
-- PLAYER EVENTS
-----------------------------
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

-----------------------------
-- RENDER LOOP
-----------------------------
RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            UpdateESP(player)
        end
    end
end)

-----------------------------
-- UI IMPLEMENTATION
-----------------------------
local SkeletonTab = Library:Tab("ESP")
local Section = SkeletonTab:Section("Skeleton ESP")

Section:Toggle("Skeleton ESP", false, function(v)
    Settings.SkeletonESP = v
end)

Section:Slider("Line Thickness", 1, 1, 3, function(v)
    Settings.SkeletonThickness = v
end)

Section:Slider("Transparency", 1, 0, 1, function(v)
    Settings.SkeletonTransparency = v
end)

Section:Dropdown("Color", {"White", "Red", "Green", "Blue"}, "White", function(v)
    local colors = {
        White = Color3.fromRGB(255,255,255),
        Red = Color3.fromRGB(255,0,0),
        Green = Color3.fromRGB(0,255,0),
        Blue = Color3.fromRGB(0,0,255)
    }
    Settings.SkeletonColor = colors[v]
end)
