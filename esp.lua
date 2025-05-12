local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ตัวแปรเก็บค่าสีที่ผู้ใช้เลือก
local selectedNameColor = Color3.fromRGB(255, 0, 0)
local selectedBoxColor = Color3.fromRGB(255, 0, 0)
local ShowBoxESP = true  -- เปิด/ปิด Box ESP

local ESPEnabledPlayers = {}

-- 📦 GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "ESP_UI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- 🔘 ปุ่มเปิด/ปิด UI (เป็นสีเหลี่ยม)
local toggleButton = Instance.new("TextButton", gui)
toggleButton.Size = UDim2.new(0, 70, 0, 20) -- ขนาดเปลี่ยนเป็นสี่เหลี่ยม
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
toggleButton.TextColor3 = Color3.fromRGB(200, 200, 200)
toggleButton.Text = "menu"
toggleButton.TextSize = 15
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.Active = true
toggleButton.Draggable = true


-- ทำให้ปุ่มเปิด/ปิดเมนูเป็นวงกลม
local corner = Instance.new("UICorner", toggleButton)
corner.CornerRadius = UDim.new(0.1, 0)

-- 🪟 Frame หลัก
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 210)
frame.Position = UDim2.new(0, 10, 0, 60)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Visible = true
frame.Active = true
frame.Draggable = true
frame.BackgroundTransparency = 0.5  -- ทำให้โปร่งใส

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
scrolling.Size = UDim2.new(1, -40, 0, 80)
scrolling.Position = UDim2.new(0, 0, 0, 30)
scrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
scrolling.ScrollBarThickness = 6
scrolling.ScrollingDirection = Enum.ScrollingDirection.X
scrolling.BackgroundTransparency = 1

-- ปุ่มรีเฟรชชื่อ
local refreshButton = Instance.new("TextButton", frame)
refreshButton.Size = UDim2.new(1, 0, 0, 30)
refreshButton.Position = UDim2.new(0, 0, 0, 110)
refreshButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
refreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
refreshButton.Font = Enum.Font.SourceSansBold
refreshButton.TextSize = 16
refreshButton.Text = "🔁 รีเซ็ตรายชื่อ"

-- ✅ สร้าง ESP
local function addESP(player)
	local char = player.Character
	if not (char and char:FindFirstChild("Head") and char:FindFirstChild("HumanoidRootPart")) then return end

	if char.Head:FindFirstChild("ESP") or char:FindFirstChild("BoxESP") then return end

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
	label.TextColor3 = selectedNameColor
	label.TextStrokeTransparency = 0.5
	label.TextScaled = false
	label.TextSize = 18
	label.Font = Enum.Font.SourceSans

	-- เปิด Box ESP
	if ShowBoxESP then
		local box = Instance.new("BoxHandleAdornment")
		box.Name = "BoxESP"
		box.Adornee = char.HumanoidRootPart
		box.Size = Vector3.new(4, 6, 2)
		box.Color3 = selectedBoxColor
		box.Transparency = 0.5
		box.ZIndex = 0
		box.AlwaysOnTop = true
		box.Parent = char
	end
end

-- ❌ ลบ ESP
local function removeESP(player)
	local char = player.Character
	if not char then return end

	if char:FindFirstChild("Head") then
		local esp = char.Head:FindFirstChild("ESP")
		if esp then esp:Destroy() end
	end

	local box = char:FindFirstChild("BoxESP")
	if box then box:Destroy() end
end

-- 🔁 อัปเดตรายชื่อ
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
					if player.Character then
						addESP(player)
					end
					player.CharacterAdded:Connect(function()
						wait(1)
						if ESPEnabledPlayers[player.Name] then
							addESP(player)
						end
					end)
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

-- ผู้เล่นใหม่
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

-- ปุ่มเปิด/ปิด Box ESP
local boxToggle = Instance.new("TextButton", frame)
boxToggle.Size = UDim2.new(1, 0, 0, 30)
boxToggle.Position = UDim2.new(0, 0, 0, 150)
boxToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
boxToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
boxToggle.Font = Enum.Font.SourceSansBold
boxToggle.TextSize = 15
boxToggle.Text = ShowBoxESP and "of Box ESP" or "on Box ESP"

boxToggle.MouseButton1Click:Connect(function()
	ShowBoxESP = not ShowBoxESP
	boxToggle.Text = ShowBoxESP and "ปิด Box ESP" or "เปิด Box ESP"

	-- อัปเดตการแสดงผล ESP ทุกครั้งที่เปลี่ยนสถานะ
	for playerName, _ in pairs(ESPEnabledPlayers) do
		local player = Players:FindFirstChild(playerName)
		if player then
			removeESP(player)
			if player.Character then
				addESP(player)
			end
		end
	end
end)

-- ปุ่มเลือกสีสำหรับ Username
local nameColorButton = Instance.new("TextButton", frame)
nameColorButton.Size = UDim2.new(1, 0, 0, 30)
nameColorButton.Position = UDim2.new(0, 0, 0, 180)
nameColorButton.BackgroundColor3 = selectedNameColor
nameColorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
nameColorButton.Font = Enum.Font.SourceSansBold
nameColorButton.TextSize = 15
nameColorButton.Text = "เลือกสี Username"

nameColorButton.MouseButton1Click:Connect(function()
	-- เปลี่ยนสี Username ตามที่ผู้เล่นเลือก
	selectedNameColor = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
	nameColorButton.BackgroundColor3 = selectedNameColor

	-- อัปเดต ESP ของผู้เล่นทั้งหมด
	for playerName, _ in pairs(ESPEnabledPlayers) do
		local player = Players:FindFirstChild(playerName)
		if player then
			removeESP(player)
			if player.Character then
				addESP(player)
			end
		end
	end
end)

-- ปุ่มเลือกสีสำหรับ Box
local boxColorButton = Instance.new("TextButton", frame)
boxColorButton.Size = UDim2.new(1, 0, 0, 30)
boxColorButton.Position = UDim2.new(0, 0, 0, 210)
boxColorButton.BackgroundColor3 = selectedBoxColor
boxColorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
boxColorButton.Font = Enum.Font.SourceSansBold
boxColorButton.TextSize = 16
boxColorButton.Text = "เลือกสี Box"

boxColorButton.MouseButton1Click:Connect(function()
	-- เปลี่ยนสี Box ตามที่ผู้เล่นเลือก
	selectedBoxColor = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
	boxColorButton.BackgroundColor3 = selectedBoxColor

	-- อัปเดต ESP ของผู้เล่นทั้งหมด
	for playerName, _ in pairs(ESPEnabledPlayers) do
		local player = Players:FindFirstChild(playerName)
		if player then
			removeESP(player)
			if player.Character then
				addESP(player)
			end
		end
	end
end)

-- เริ่มต้น
updatePlayerList()
