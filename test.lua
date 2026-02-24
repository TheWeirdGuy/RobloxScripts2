local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/Rain-Design/Unnamed/main/Library.lua'))()
Library.Theme = "Dark"
local Flags = Library.Flags

local Window = Library:Window({
    Text = "Baseplate"
})

local Tab = Window:Tab({
    Text = "Main"
})

local Section = Tab:Section({
    Text = "Player Settings"
})

Section:Slider({
    Text = "Speed",
    Default = 16,
    Minimum = 0,
    Maximum = 200,
    Callback = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
})

Section:Slider({
    Text = "Jump",
    Default = 50,
    Minimum = 0,
    Maximum = 200,
    Callback = function(value)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
    end
})

Tab:Select()
