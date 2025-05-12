local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ESPEnabledPlayers = {}

-- 📦 GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "ESP_UI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- 🔘 ปุ่มเปิด/ปิด UI
local toggleButton = Instance.new("TextButton", gui)
toggleButton.Size = UDim2.new(0, 100, 0, 40)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Text = "Menu" -- แก้ตรงนี้
toggleButton.TextSize = 16
toggleButton.Font = Enum.Font.SourceSans
toggleButton.Active = true
toggleButton.Draggable = true

-- 🪟 Frame หลัก
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 320, 0, 160)
frame.Position = UDim2.new(0, 10, 0, 60)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Visible = true
frame.Active = true
frame.Draggable = true

-- หัวข้อ
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "เลือกชื่อผู้เล่น"
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.SourceSansBold

-- รายชื่อ
local scrolling = Instance.new("ScrollingFrame", frame)
scrolling.Size = UDim2.new(1, -40, 1, -30)
scrolling.Position = UDim2.new(0, 0, 0, 30)
scrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
scrolling.ScrollBarThickness = 6
scrolling.ScrollingDirection = Enum.ScrollingDirection.X
scrolling.BackgroundTransparency = 1

-- ปุ่มรีเฟรชชื่อ
local refreshButton = Instance.new("TextButton", frame)
refreshButton.Size = UDim2.new(1, 0, 0, 30)
refreshButton.Position = UDim2.new(0, 0, 1, -30)
refreshButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
refreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
refreshButton.Font = Enum.Font.SourceSansBold
refreshButton.TextSize = 16
refreshButton.Text = "🔁 รีเซ็ตรายชื่อ"

-- ✅ สร้าง ESP
local function addESP(player)
	local char = player.Character
	if not (char and char:FindFirstChild("Head")) then return end
	if char.Head:FindFirstChild("ESP") then return end

	local esp = Instance.new("BillboardGui", char.Head)
	esp.Name = "ESP"
	esp.Adornee = char.Head
	esp.Size = UDim2.new(0, 50, 0, 15)
	esp.StudsOffset = Vector3.new(0, 3.5, 0)
	esp.AlwaysOnTop = true

	local label = Instance.new("TextLabel", esp)
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = player.Name
	label.TextColor3 = Color3.fromRGB(0, 255, 0)
	label.TextStrokeTransparency = 0.5
	label.TextScaled = false
	label.TextSize = 18
	label.Font = Enum.Font.SourceSans
end

-- ❌ ลบ ESP
local function removeESP(player)
	if player.Character and player.Character:FindFirstChild("Head") then
		local esp = player.Character.Head:FindFirstChild("ESP")
		if esp then
			esp:Destroy()
		end
	end
end

-- 🔁 อัปเดตรายชื่อใน UI
local function updatePlayerList()
	scrolling:ClearAllChildren()
	local players = Players:GetPlayers()
	local x = 0

	for _, player in ipairs(players) do
		if player ~= LocalPlayer then
			local button = Instance.new("TextButton", scrolling)
			button.Size = UDim2.new(0, 100, 0, 30)
			button.Position = UDim2.new(0, x, 0, 0)
			button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			button.TextColor3 = Color3.fromRGB(255, 255, 255)
			button.Font = Enum.Font.SourceSans
			button.TextSize = 16
			button.TextWrapped = true
			button.Text = player.Name .. (ESPEnabledPlayers[player.Name] and " ✓" or "")

			button.MouseButton1Click:Connect(function()
				if ESPEnabledPlayers[player.Name] then
					ESPEnabledPlayers[player.Name] = nil
					removeESP(player)
				else
					ESPEnabledPlayers[player.Name] = true
					addESP(player)
				end
				updatePlayerList()
			end)

			x = x + 105
		end
	end

	scrolling.CanvasSize = UDim2.new(0, x, 0, 0)
end

-- ♻️ ตัวละครเกิดใหม่
local function onCharacterAdded(player)
	wait(1)
	if ESPEnabledPlayers[player.Name] then
		addESP(player)
	end
end

-- ผู้เล่นใหม่เข้า
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		onCharacterAdded(player)
	end)
	updatePlayerList()
end)

-- ผู้เล่นออก
Players.PlayerRemoving:Connect(function(player)
	ESPEnabledPlayers[player.Name] = nil
	updatePlayerList()
end)

-- โหลดครั้งแรก
for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LocalPlayer then
		player.CharacterAdded:Connect(function()
			onCharacterAdded(player)
		end)
	end
end

-- 🔘 ปุ่ม toggle menu
toggleButton.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)

-- 🔁 ปุ่มรีเฟรชชื่อ
refreshButton.MouseButton1Click:Connect(function()
	updatePlayerList()
end)

-- เริ่มต้น
updatePlayerList()
