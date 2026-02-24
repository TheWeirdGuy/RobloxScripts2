local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Baseplate", "DarkTheme")

local Main = Window:NewTab("Main")
local Section = Main:NewSection("Player Settings")

Section:NewSlider("Speed", "Change WalkSpeed", 200, 16, function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)

Section:NewSlider("Jump", "Change JumpPower", 200, 50, function(value)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
end)
