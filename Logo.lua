local Asset = "rbxassetid://18285109409"
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Heart"
ScreenGui.Parent = game:GetService("CoreGui")

local Heart = Instance.new("ImageLabel")
Heart.Image = Asset
Heart.Size = UDim2.new(0, 150, 0, 150)
Heart.Position = UDim2.new(0.5, -75, 0.5, -75)
Heart.BackgroundTransparency = 1
Heart.ImageTransparency = 1
Heart.Parent = ScreenGui

local TweenService = game:GetService("TweenService")

local Logo = {}

function Logo.DisplayHeart()
    local Config = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local In = TweenService:Create(Heart, Config, {ImageTransparency = 0})
    local Out = TweenService:Create(Heart, Config, {ImageTransparency = 1})
    
    In:Play()

    In.Completed:Connect(function()
        wait(0.5)
        Out:Play()
    end)

    Out.Completed:Connect(function()
        ScreenGui:Destroy()
    end)
end

return Logo
