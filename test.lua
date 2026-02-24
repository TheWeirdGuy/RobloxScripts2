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
