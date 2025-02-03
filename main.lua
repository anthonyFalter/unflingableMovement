local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local starterGui = game:GetService("StarterGui")

local speed = 5  -- Default movement speed
local jumpHeight = 10  -- Jump strength
local moveDirection = Vector3.new()
local isJumping = false
local walkEnabled = false
local ui
local walkConnection, renderConnection, movementConnection

-- Create UI
ui = Instance.new("ScreenGui")
ui.Parent = player:WaitForChild("PlayerGui")
local frame = Instance.new("Frame", ui)
frame.Size = UDim2.new(0, 200, 0, 150)
frame.Position = UDim2.new(0.4, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
frame.Active = true
frame.Draggable = true

local enableButton = Instance.new("TextButton", frame)
enableButton.Size = UDim2.new(0, 180, 0, 30)
enableButton.Position = UDim2.new(0, 10, 0, 10)
enableButton.Text = "Enable Walk"
enableButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)

local speedSlider = Instance.new("TextBox", frame)
speedSlider.Size = UDim2.new(0, 180, 0, 30)
speedSlider.Position = UDim2.new(0, 10, 0, 50)
speedSlider.Text = tostring(speed)
speedSlider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)

local exitButton = Instance.new("TextButton", frame)
exitButton.Size = UDim2.new(0, 180, 0, 30)
exitButton.Position = UDim2.new(0, 10, 0, 90)
exitButton.Text = "Exit"
exitButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)

local function updateMovement()
    if moveDirection.Magnitude > 0 then
        local moveVector = humanoidRootPart.CFrame:VectorToWorldSpace(moveDirection.Unit) * speed
        local newCFrame = humanoidRootPart.CFrame + moveVector
        local tween = tweenService:Create(humanoidRootPart, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = newCFrame})
        tween:Play()
    end
end

local function updateRotation()
    local mouseLocation = userInputService:GetMouseLocation()
    local rayOrigin = camera.CFrame.Position
    local rayDirection = (camera:ScreenPointToRay(mouseLocation.X, mouseLocation.Y)).Direction * 1000
    
    local newLookVector = Vector3.new(rayDirection.X, 0, rayDirection.Z).Unit
    local newCFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + newLookVector)
    humanoidRootPart.CFrame = newCFrame
end

local function toggleWalk()
    walkEnabled = not walkEnabled
    enableButton.Text = walkEnabled and "Disable Walk" or "Enable Walk"
    enableButton.BackgroundColor3 = walkEnabled and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
    moveDirection = Vector3.new()  -- Reset movement direction on toggle
    
    if walkEnabled then
        humanoidRootPart.Anchored = true
        movementConnection = runService.RenderStepped:Connect(updateMovement)
        walkConnection = runService.Heartbeat:Connect(function()
            speed = tonumber(speedSlider.Text) or speed
            updateRotation()
        end)
    else
        if walkConnection then walkConnection:Disconnect() end
        if movementConnection then movementConnection:Disconnect() end
        humanoidRootPart.Anchored = false
    end
end

enableButton.MouseButton1Click:Connect(toggleWalk)

speedSlider.FocusLost:Connect(function()
    speed = tonumber(speedSlider.Text) or speed
end)

exitButton.MouseButton1Click:Connect(function()
    if walkConnection then walkConnection:Disconnect() end
    if renderConnection then renderConnection:Disconnect() end
    if movementConnection then movementConnection:Disconnect() end
    ui:Destroy()
    walkEnabled = false
    humanoidRootPart.Anchored = false
    script:Destroy()
end)

userInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not walkEnabled then return end
    
    if input.KeyCode == Enum.KeyCode.W then
        moveDirection = moveDirection + Vector3.new(0, 0, -1)
    elseif input.KeyCode == Enum.KeyCode.S then
        moveDirection = moveDirection + Vector3.new(0, 0, 1)
    elseif input.KeyCode == Enum.KeyCode.A then
        moveDirection = moveDirection + Vector3.new(-1, 0, 0)
    elseif input.KeyCode == Enum.KeyCode.D then
        moveDirection = moveDirection + Vector3.new(1, 0, 0)
    end
end)

userInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.W then
        moveDirection = moveDirection - Vector3.new(0, 0, -1)
    elseif input.KeyCode == Enum.KeyCode.S then
        moveDirection = moveDirection - Vector3.new(0, 0, 1)
    elseif input.KeyCode == Enum.KeyCode.A then
        moveDirection = moveDirection - Vector3.new(-1, 0, 0)
    elseif input.KeyCode == Enum.KeyCode.D then
        moveDirection = moveDirection - Vector3.new(1, 0, 0)
    end
end)
