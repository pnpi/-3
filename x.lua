-- simple camlock took like 10 mins : </3

local heartAssetId = "rbxassetid://18285109409"

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "OpeningAnimation"
screenGui.Parent = game:GetService("CoreGui")

local heartImage = Instance.new("ImageLabel")
heartImage.Image = heartAssetId
heartImage.Size = UDim2.new(0, 150, 0, 150)
heartImage.Position = UDim2.new(0.5, -75, 0.5, -75)
heartImage.BackgroundTransparency = 1
heartImage.ImageTransparency = 1
heartImage.Parent = screenGui

local tweenService = game:GetService("TweenService")

local function createOpeningAnimation()
    local tweenInfoIn = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tweenInfoOut = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    
    local goalInHeart = {ImageTransparency = 0}
    local goalOutHeart = {ImageTransparency = 1}
    
    local tweenInHeart = tweenService:Create(heartImage, tweenInfoIn, goalInHeart)
    local tweenOutHeart = tweenService:Create(heartImage, tweenInfoOut, goalOutHeart)

    tweenInHeart:Play()
    tweenInHeart.Completed:Connect(function()
        wait(0.5)
        tweenOutHeart:Play()
    end)

    tweenOutHeart.Completed:Connect(function()
        screenGui:Destroy()
    end)
end

createOpeningAnimation()

getgenv()["</3"] = {
    ["FOV"] = {
        ["Color"] = Color3.fromRGB(0, 255, 255),
        ["Radius"] = 100,
        ["Filled"] = false,
        ["Visible"] = true,
        ["Thickness"] = 1,
        ["Position"] = "Target"
    },

    ["Spin"] = {
        ["Speed"] = 2,
        ["SpinKey"] = Enum.KeyCode.K
    },

    ["Aim"] = {
        ["AimKey"] = Enum.KeyCode.E,
        ["Mode"] = "Toggle",
        ["Alpha"] = 0.0611235,
        ["AlphaStyle"] = Enum.EasingStyle.Sine,
        ["AlphaDirection"] = Enum.EasingDirection.InOut,
        ["MovementDelta"] = 2,
        ["HitParts"] = {"Head", "UpperTorso"}
    }
}

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = game.Workspace.CurrentCamera
local runService = game:GetService("RunService")

local lockOn = false
local target = nil
local spinningEnabled = false
local rotationTotal = 0
local fullRotation = 2 * math.pi

local circle = Drawing.new("Circle")

local function inRadius(targetPosition)
    local screenPos, onScreen = camera:WorldToScreenPoint(targetPosition)
    if onScreen then
        local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mouse.X, mouse.Y)).magnitude
        return distance <= getgenv()["</3"]["FOV"]["Radius"]
    end
    return false
end

local function printBodyParts(character)
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            print(part.Name)
        end
    end
end

local function getNearestTargetToCursor()
    local closestTarget = nil
    local shortestDistance = math.huge
    local playerTeamColor = player.Team and player.Team.TeamColor  -- Check if the local player has a team and get the team color

    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= player and v.Character then
            local humanoid = v.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local targetTeamColor = v.Team and v.Team.TeamColor  -- Check if the target player has a team and get the team color
                if not playerTeamColor or not targetTeamColor or targetTeamColor ~= playerTeamColor then  -- Compare team colors if both exist
                    for _, partName in ipairs(getgenv()["</3"]["Aim"]["HitParts"]) do
                        local part = v.Character:FindFirstChild(partName)
                        if part then
                            local screenPos, onScreen = camera:WorldToScreenPoint(part.Position)
                            if onScreen then
                                local cursorDistance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mouse.X, mouse.Y)).magnitude
                                if cursorDistance < shortestDistance and cursorDistance < getgenv()["</3"]["FOV"]["Radius"] then
                                    closestTarget = v.Character
                                    shortestDistance = cursorDistance
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if closestTarget then
        print("Nearest Target's Body Parts:")
        printBodyParts(closestTarget)
    end

    return closestTarget
end

local function predictTargetPosition(target)
    for _, partName in ipairs(getgenv()["</3"]["Aim"]["HitParts"]) do
        local part = target:FindFirstChild(partName)
        if part then
            local humanoid = target:FindFirstChild("Humanoid")
            if humanoid then
                local moveDirection = humanoid.MoveDirection
                local speed = humanoid.WalkSpeed
                local futurePosition = part.Position + moveDirection * speed * getgenv()["</3"]["Aim"]["MovementDelta"]
                return futurePosition
            end
        end
    end
    return nil
end

mouse.KeyDown:Connect(function(key)
    if key == getgenv()["</3"]["Aim"]["AimKey"].Name:lower() then
        if getgenv()["</3"]["Aim"]["Mode"] == "Toggle" then
            lockOn = not lockOn
            if lockOn then
                target = getNearestTargetToCursor()
            else
                target = nil
            end
        elseif getgenv()["</3"]["Aim"]["Mode"] == "Hold" then
            lockOn = true
            target = getNearestTargetToCursor()
        end
    end
end)

mouse.KeyUp:Connect(function(key)
    if key == getgenv()["</3"]["Aim"]["AimKey"].Name:lower() and getgenv()["</3"]["Aim"]["Mode"] == "Hold" then
        lockOn = false
        target = nil
    end
end)

mouse.KeyDown:Connect(function(key)
    if key == Enum.KeyCode.R.Name:lower() then
        if getgenv()["</3"]["Aim"]["Mode"] == "Toggle" then
            getgenv()["</3"]["Aim"]["Mode"] = "Hold"
        else
            getgenv()["</3"]["Aim"]["Mode"] = "Toggle"
        end
    end
end)

mouse.KeyDown:Connect(function(key)
    if key == getgenv()["</3"]["Spin"]["SpinKey"].Name:lower() and not spinningEnabled then
        spinningEnabled = true
        rotationTotal = 0
    end
end)

local function complete360()
    if spinningEnabled then
        local rotationSpeed = 360 * getgenv()["</3"]["Spin"]["Speed"]
        local rotationAmount = math.rad(rotationSpeed * runService.RenderStepped:Wait())
        rotationTotal = rotationTotal + rotationAmount

        camera.CFrame = camera.CFrame * CFrame.Angles(0, rotationAmount, 0)

        if rotationTotal >= fullRotation then
            spinningEnabled = false
            rotationTotal = 0
        end
    end
end

runService.RenderStepped:Connect(function()
    complete360()

    -- Update circle position based on configuration
    if getgenv()["</3"]["FOV"]["Position"] == "Mouse" then
        circle.Position = Vector2.new(mouse.X, mouse.Y + 36)
    elseif getgenv()["</3"]["FOV"]["Position"] == "Target" and target then
        local futurePosition = predictTargetPosition(target)
        if futurePosition and inRadius(futurePosition) then
            local screenPos, onScreen = camera:WorldToScreenPoint(futurePosition)
            if onScreen then
                circle.Position = Vector2.new(screenPos.X, screenPos.Y)
            end
        end
    end

    if lockOn and target and target:FindFirstChild("HumanoidRootPart") then
        local futurePosition = predictTargetPosition(target)
        if futurePosition then
            local targetPosition = CFrame.new(camera.CFrame.Position, futurePosition)
            camera.CFrame = camera.CFrame:Lerp(targetPosition, getgenv()["</3"]["Aim"]["Alpha"], getgenv()["</3"]["Aim"]["AlphaStyle"], getgenv()["</3"]["Aim"]["AlphaDirection"])

            if getgenv()["</3"]["FOV"]["Position"] == "Target" and inRadius(futurePosition) then
                local circlePos = camera:WorldToViewportPoint(futurePosition)
                circle.Position = Vector2.new(circlePos.X, circlePos.Y)
            end
        end
    end

    circle.Visible = getgenv()["</3"]["FOV"]["Visible"]
    circle.Radius = getgenv()["</3"]["FOV"]["Radius"]
    circle.Color = getgenv()["</3"]["FOV"]["Color"]
    circle.Filled = getgenv()["</3"]["FOV"]["Filled"]
    circle.Thickness = getgenv()["</3"]["FOV"]["Thickness"]
end)
