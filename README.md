-- MORI HUB AIMBOT (Fully Integrated UI + White FOV + Configurable)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

-- Aimbot Settings
local aimbotEnabled = true
local fovEnabled = true
local fovRadius = 100
local smoothness = 0.2
local aimPart = "Head"
local currentTarget = nil

-- Create White FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Thickness = 1
fovCircle.Radius = fovRadius
fovCircle.Filled = false
fovCircle.Transparency = 1

-- UI Setup
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "MORI_HUB_AIMBOT"
screenGui.ResetOnSpawn = false

local toggleButton = Instance.new("TextButton", screenGui)
toggleButton.Size = UDim2.new(0, 100, 0, 30)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.Text = "MENU"
toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleButton.TextColor3 = Color3.new(1,1,1)
toggleButton.Active = true
toggleButton.Draggable = true

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 250, 0, 200)
mainFrame.Position = UDim2.new(0, 120, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.Visible = true
mainFrame.Active = true
mainFrame.Draggable = true

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "MORI HUB AIMBOT"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextScaled = true

-- Toggle Buttons and Inputs
local function createToggle(name, default, yPos, callback)
	local btn = Instance.new("TextButton", mainFrame)
	btn.Size = UDim2.new(1, -20, 0, 25)
	btn.Position = UDim2.new(0, 10, 0, yPos)
	btn.Text = name .. ": " .. (default and "ON" or "OFF")
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.MouseButton1Click:Connect(function()
		default = not default
		btn.Text = name .. ": " .. (default and "ON" or "OFF")
		callback(default)
	end)
end

local function createInput(name, default, yPos, callback)
	local label = Instance.new("TextLabel", mainFrame)
	label.Size = UDim2.new(0.5, -15, 0, 25)
	label.Position = UDim2.new(0, 10, 0, yPos)
	label.Text = name
	label.TextColor3 = Color3.new(1, 1, 1)
	label.BackgroundTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left

	local input = Instance.new("TextBox", mainFrame)
	input.Size = UDim2.new(0.5, -15, 0, 25)
	input.Position = UDim2.new(0.5, 5, 0, yPos)
	input.Text = tostring(default)
	input.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	input.TextColor3 = Color3.new(1,1,1)

	input.FocusLost:Connect(function()
		local val = tonumber(input.Text)
		if val then
			callback(val)
		end
	end)
end

createToggle("Aimbot", aimbotEnabled, 35, function(val) aimbotEnabled = val end)
createToggle("FOV", fovEnabled, 65, function(val) fovEnabled = val end)
createInput("FOV Radius", fovRadius, 95, function(val) fovRadius = val; fovCircle.Radius = val end)
createInput("Smooth", smoothness, 125, function(val) smoothness = val end)

-- Toggle UI Visibility
toggleButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

-- Get Closest Target in FOV
local function getClosestTarget()
	local closest = nil
	local shortestDist = math.huge
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(aimPart) then
			local part = player.Character[aimPart]
			local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
			if onScreen then
				local dist = (Vector2.new(pos.X, pos.Y) - Camera.ViewportSize / 2).Magnitude
				if dist < fovRadius and dist < shortestDist then
					closest = player
					shortestDist = dist
				end
			end
		end
	end
	return closest
end

-- Box Highlight
local highlightBox = Instance.new("BoxHandleAdornment")
highlightBox.Adornee = nil
highlightBox.Color3 = Color3.new(1, 1, 1)
highlightBox.AlwaysOnTop = true
highlightBox.ZIndex = 10
highlightBox.Transparency = 0.7
highlightBox.Size = Vector3.new(3, 5, 1)
highlightBox.Parent = game.CoreGui

-- Main Loop
RunService.RenderStepped:Connect(function()
	fovCircle.Position = workspace.CurrentCamera.ViewportSize / 2
	fovCircle.Visible = fovEnabled

	if aimbotEnabled then
		local target = getClosestTarget()
		if target and target.Character and target.Character:FindFirstChild(aimPart) then
			local aimPos = target.Character[aimPart].Position
			local camPos = Camera.CFrame.Position
			local dir = (aimPos - camPos).Unit
			local newLook = Camera.CFrame:ToOrientation()
			local lookAt = CFrame.new(camPos, camPos + dir):ToOrientation()

			local smoothX = newLook
			local lerpedX = Vector3.new(
				newLook + (lookAt - newLook) * smoothness
			)
			Camera.CFrame = CFrame.new(camPos) * CFrame.fromOrientation(lerpedX.X, lerpedX.Y, lerpedX.Z)

			currentTarget = target
			highlightBox.Adornee = target.Character
		else
			currentTarget = nil
			highlightBox.Adornee = nil
		end
	else
		highlightBox.Adornee = nil
	end
end)
