local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- File lưu Waypoint riêng biệt cho từng Game theo PlaceId
local FILE_NAME = "Waypoints_Game_" .. tostring(game.PlaceId) .. ".json"

-- ==========================================
-- 1. FIX SHIFTLOCK SYSTEM
-- ==========================================
local shiftLockActive = false

local function toggleShiftLock()
	shiftLockActive = not shiftLockActive
	if shiftLockActive then
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		camera.CameraType = Enum.CameraType.Custom
	else
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end
end

-- ==========================================
-- 2. MAIN GUI SETUP
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomUtilityGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Menu Chính
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 220)
mainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Viền Menu to hơn để dễ kéo thả
local uiStroke = Instance.new("UIStroke")
uiStroke.Thickness = 6
uiStroke.Color = Color3.fromRGB(85, 170, 255)
uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uiStroke.Parent = mainFrame

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = mainFrame

-- Title Bar
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
titleLabel.Text = "  HỆ THỐNG TỔNG HỢP"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 18
titleLabel.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleLabel

-- Container Chứa Tab
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -20, 1, -50)
tabContainer.Position = UDim2.new(0, 10, 0, 45)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 8)
listLayout.Parent = tabContainer

-- ==========================================
-- 3. AUTO CLICK SYSTEM & FLOATING PANEL
-- ==========================================
local autoClicking = false
local clickDelay = 0.1
local clickCircles = {} -- Danh sách các điểm vòng tròn click màn hình

local autoClickBtn = Instance.new("TextButton")
autoClickBtn.Size = UDim2.new(1, 0, 0, 35)
autoClickBtn.BackgroundColor3 = Color3.fromRGB(60, 170, 90)
autoClickBtn.Text = "Bật Auto Click: OFF"
autoClickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoClickBtn.Font = Enum.Font.SourceSansBold
autoClickBtn.TextSize = 16
autoClickBtn.Parent = tabContainer

-- Luồng thực thi Auto Click
task.spawn(function()
	while true do
		if autoClicking then
			if #clickCircles > 0 then
				-- Click lần lượt vào các điểm vòng tròn đã tạo
				for _, circle in ipairs(clickCircles) do
					if not autoClicking then break end
					local pos = circle.AbsolutePosition + (circle.AbsoluteSize / 2)
					VirtualInputManager = VirtualInputManager or game:GetService("VirtualInputManager")
					VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
					VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
					task.wait(clickDelay)
				end
			else
				-- Nếu không có vòng tròn, click tại vị trí chuột hiện tại
				mouse1click()
				task.wait(clickDelay)
			end
		else
			task.wait(0.1)
		end
	end
end)

autoClickBtn.MouseButton1Click:Connect(function()
	autoClicking = not autoClicking
	autoClickBtn.Text = "Bật Auto Click: " .. (autoClicking and "ON" or "OFF")
	autoClickBtn.BackgroundColor3 = autoClicking and Color3.fromRGB(220, 60, 60) or Color3.fromRGB(60, 170, 90)
end)

-- Nút ShiftLock trên Menu
local shiftLockBtn = Instance.new("TextButton")
shiftLockBtn.Size = UDim2.new(1, 0, 0, 35)
shiftLockBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
shiftLockBtn.Text = "Bật / Tắt ShiftLock"
shiftLockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
shiftLockBtn.Font = Enum.Font.SourceSansBold
shiftLockBtn.TextSize = 16
shiftLockBtn.Parent = tabContainer

shiftLockBtn.MouseButton1Click:Connect(toggleShiftLock)

-- Cấu hình Tốc độ Click
local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(1, 0, 0, 35)
speedFrame.BackgroundTransparency = 1
speedFrame.Parent = tabContainer

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 160, 1, 0)
speedLabel.Text = "Tốc độ Click (giây):"
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.Font = Enum.Font.SourceSans
speedLabel.TextSize = 14
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = speedFrame

local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(1, -165, 1, 0)
speedInput.Position = UDim2.new(0, 165, 0, 0)
speedInput.Text = tostring(clickDelay)
speedInput.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.Font = Enum.Font.SourceSans
speedInput.TextSize = 14
speedInput.Parent = speedFrame

speedInput.FocusLost:Connect(function()
	local val = tonumber(speedInput.Text)
	if val and val > 0 then
		clickDelay = val
	else
		speedInput.Text = tostring(clickDelay)
	end
end)

-- Bảng Nổi Auto Click (Floating Click Panel)
local floatClickFrame = Instance.new("Frame")
floatClickFrame.Size = UDim2.new(0, 130, 0, 105)
floatClickFrame.Position = UDim2.new(0.02, 0, 0.4, 0)
floatClickFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
floatClickFrame.Active = true
floatClickFrame.Draggable = true
floatClickFrame.Parent = screenGui

local floatLayout = Instance.new("UIListLayout")
floatLayout.Padding = UDim.new(0, 5)
floatLayout.Parent = floatClickFrame

local btnAddClick = Instance.new("TextButton")
btnAddClick.Size = UDim2.new(1, 0, 0, 30)
btnAddClick.Text = "+ Thêm Vòng Tròn"
btnAddClick.Parent = floatClickFrame

local btnDelClick = Instance.new("TextButton")
btnDelClick.Size = UDim2.new(1, 0, 0, 30)
btnDelClick.Text = "- Xoá Điểm"
btnDelClick.Parent = floatClickFrame

local btnClearAllClick = Instance.new("TextButton")
btnClearAllClick.Size = UDim2.new(1, 0, 0, 30)
btnClearAllClick.Text = "Xoá Tất Cả Điểm"
btnClearAllClick.Parent = floatClickFrame

-- Tạo vòng tròn điểm click trên màn hình
btnAddClick.MouseButton1Click:Connect(function()
	local index = #clickCircles + 1
	local circle = Instance.new("Frame")
	circle.Name = "ClickCircle_" .. index
	circle.Size = UDim2.new(0, 35, 0, 35)
	circle.Position = UDim2.new(0.5, -17, 0.5, -17)
	circle.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
	circle.BackgroundTransparency = 0.3
	circle.Active = true
	circle.Draggable = true
	circle.Parent = screenGui

	local cCorner = Instance.new("UICorner")
	cCorner.CornerRadius = UDim.new(1, 0)
	cCorner.Parent = circle

	local cLabel = Instance.new("TextLabel")
	cLabel.Size = UDim2.new(1, 0, 1, 0)
	cLabel.BackgroundTransparency = 1
	cLabel.Text = tostring(index)
	cLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	cLabel.Font = Enum.Font.SourceSansBold
	cLabel.TextSize = 16
	cLabel.Parent = circle

	table.insert(clickCircles, circle)
end)

-- Xóa 1 điểm vòng tròn cuối
btnDelClick.MouseButton1Click:Connect(function()
	if #clickCircles > 0 then
		local lastCircle = clickCircles[#clickCircles]
		lastCircle:Destroy()
		table.remove(clickCircles, #clickCircles)
	end
end)

-- Xóa tất cả các điểm vòng tròn
btnClearAllClick.MouseButton1Click:Connect(function()
	for _, circle in ipairs(clickCircles) do
		circle:Destroy()
	end
	clickCircles = {}
end)

-- ==========================================
-- 4. WAYPOINT SYSTEM (Bay / Dịch chuyển / Save / Load)
-- ==========================================
local waypoints = {}
local isRunningWP = false
local isTweenMode = true
local flySpeed = 50

-- Mở rộng bảng điều khiển Waypoint lên height 280px
local wpPanel = Instance.new("Frame")
wpPanel.Size = UDim2.new(0, 160, 0, 280)
wpPanel.Position = UDim2.new(0.85, 0, 0.25, 0)
wpPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
wpPanel.Active = true
wpPanel.Draggable = true
wpPanel.Parent = screenGui

local wpLayout = Instance.new("UIListLayout")
wpLayout.Padding = UDim.new(0, 4)
wpLayout.Parent = wpPanel

local btnAddWP = Instance.new("TextButton")
btnAddWP.Size = UDim2.new(1, 0, 0, 30)
btnAddWP.Text = "1. Đặt Điểm WP"
btnAddWP.Parent = wpPanel

local btnRunWP = Instance.new("TextButton")
btnRunWP.Size = UDim2.new(1, 0, 0, 30)
btnRunWP.Text = "2. Bật Chạy WP"
btnRunWP.BackgroundColor3 = Color3.fromRGB(60, 150, 60)
btnRunWP.Parent = wpPanel

local btnDelWP = Instance.new("TextButton")
btnDelWP.Size = UDim2.new(1, 0, 0, 30)
btnDelWP.Text = "3. Xoá 1 Điểm Cuối"
btnDelWP.Parent = wpPanel

local btnClearWP = Instance.new("TextButton")
btnClearWP.Size = UDim2.new(1, 0, 0, 30)
btnClearWP.Text = "4. Xoá Hết Điểm"
btnClearWP.Parent = wpPanel

local btnModeWP = Instance.new("TextButton")
btnModeWP.Size = UDim2.new(1, 0, 0, 30)
btnModeWP.Text = "Chế độ: Bay Waypoint"
btnModeWP.BackgroundColor3 = Color3.fromRGB(100, 80, 180)
btnModeWP.Parent = wpPanel

local speedBoxWP = Instance.new("TextBox")
speedBoxWP.Size = UDim2.new(1, 0, 0, 30)
speedBoxWP.PlaceholderText = "Nhập tốc độ bay..."
speedBoxWP.Text = "Tốc độ: " .. flySpeed
speedBoxWP.Parent = wpPanel

-- Nút Lưu & Tải File
local btnSaveWP = Instance.new("TextButton")
btnSaveWP.Size = UDim2.new(1, 0, 0, 25)
btnSaveWP.Text = "💾 Lưu Danh Sách WP"
btnSaveWP.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
btnSaveWP.TextColor3 = Color3.fromRGB(255, 255, 255)
btnSaveWP.Parent = wpPanel

local btnLoadWP = Instance.new("TextButton")
btnLoadWP.Size = UDim2.new(1, 0, 0, 25)
btnLoadWP.Text = "📂 Tải Danh Sách WP"
btnLoadWP.BackgroundColor3 = Color3.fromRGB(215, 120, 0)
btnLoadWP.TextColor3 = Color3.fromRGB(255, 255, 255)
btnLoadWP.Parent = wpPanel

-- Hàm khởi tạo hiển thị Cột Trắng Visual
local function createWaypointVisual(pos, index)
	local part = Instance.new("Part")
	part.Name = "Waypoint_" .. index
	part.Size = Vector3.new(0.6, 6, 0.6)
	part.Position = pos
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.SmoothPlastic
	part.Color = Color3.fromRGB(255, 255, 255)
	part.Parent = workspace
	
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.new(0, 50, 0, 50)
	bb.Adornee = part
	bb.AlwaysOnTop = true
	bb.StudsOffset = Vector3.new(0, 4, 0)
	bb.Parent = part
	
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = tostring(index)
	lbl.TextColor3 = Color3.fromRGB(255, 255, 0)
	lbl.TextScaled = true
	lbl.Font = Enum.Font.SourceSansBold
	lbl.Parent = bb

	return part
end

-- Chuyển đổi giữa chế độ Bay (Tween) & Dịch chuyển (Teleport)
btnModeWP.MouseButton1Click:Connect(function()
	isTweenMode = not isTweenMode
	if isTweenMode then
		btnModeWP.Text = "Chế độ: Bay Waypoint"
		speedBoxWP.Visible = true
	else
		btnModeWP.Text = "Chế độ: Dịch Chuyển"
		speedBoxWP.Visible = false
	end
end)

speedBoxWP.FocusLost:Connect(function()
	local val = tonumber(speedBoxWP.Text:match("%d+"))
	if val then
		flySpeed = val
		speedBoxWP.Text = "Tốc độ: " .. flySpeed
	end
end)

-- 1. Đặt Điểm Waypoint
btnAddWP.MouseButton1Click:Connect(function()
	local char = player.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		local pos = char.HumanoidRootPart.Position
		local index = #waypoints + 1
		local part = createWaypointVisual(pos, index)
		table.insert(waypoints, {Part = part, Position = pos})
	end
end)

-- 2. Chạy Waypoint
btnRunWP.MouseButton1Click:Connect(function()
	isRunningWP = not isRunningWP
	btnRunWP.Text = isRunningWP and "Đang Chạy..." or "2. Bật Chạy WP"
	btnRunWP.BackgroundColor3 = isRunningWP and Color3.fromRGB(200, 60, 60) or Color3.fromRGB(60, 150, 60)
	
	if isRunningWP then
		task.spawn(function()
			local char = player.Character
			if not char or not char:FindFirstChild("HumanoidRootPart") then return end
			local hrp = char.HumanoidRootPart
			
			for i, wp in ipairs(waypoints) do
				if not isRunningWP then break end
				
				if isTweenMode then
					local dist = (hrp.Position - wp.Position).Magnitude
					local time = dist / flySpeed
					local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Linear)
					local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(wp.Position)})
					tween:Play()
					tween.Completed:Wait()
				else
					hrp.CFrame = CFrame.new(wp.Position)
					task.wait(0.2)
				end
			end
			isRunningWP = false
			btnRunWP.Text = "2. Bật Chạy WP"
			btnRunWP.BackgroundColor3 = Color3.fromRGB(60, 150, 60)
		end)
	end
end)

-- 3. Xoá 1 điểm cuối
btnDelWP.MouseButton1Click:Connect(function()
	if #waypoints > 0 then
		local lastWP = waypoints[#waypoints]
		if lastWP.Part then lastWP.Part:Destroy() end
		table.remove(waypoints, #waypoints)
	end
end)

-- 4. Xoá tất cả điểm
btnClearWP.MouseButton1Click:Connect(function()
	for _, wp in ipairs(waypoints) do
		if wp.Part then wp.Part:Destroy() end
	end
	waypoints = {}
end)

-- Quản lý Save/Load Waypoint bằng JSON
local function loadWaypointsForCurrentGame()
	if not readfile or not isfile or not isfile(FILE_NAME) then return false end

	for _, wp in ipairs(waypoints) do
		if wp.Part then wp.Part:Destroy() end
	end
	waypoints = {}

	local success, result = pcall(function()
		return HttpService:JSONDecode(readfile(FILE_NAME))
	end)

	if success and result then
		for index, posData in ipairs(result) do
			local pos = Vector3.new(posData.X, posData.Y, posData.Z)
			local part = createWaypointVisual(pos, index)
			table.insert(waypoints, {Part = part, Position = pos})
		end
		return true
	end
	return false
end

local function saveWaypointsForCurrentGame()
	if #waypoints == 0 then
		if isfile and isfile(FILE_NAME) and delfile then
			delfile(FILE_NAME)
		end
		return true
	end

	local rawData = {}
	for _, wp in ipairs(waypoints) do
		table.insert(rawData, {X = wp.Position.X, Y = wp.Position.Y, Z = wp.Position.Z})
	end

	return pcall(function()
		writefile(FILE_NAME, HttpService:JSONEncode(rawData))
	end)
end

btnSaveWP.MouseButton1Click:Connect(function()
	if saveWaypointsForCurrentGame() then
		btnSaveWP.Text = "✅ Đã Lưu File!"
	else
		btnSaveWP.Text = "❌ Lỗi Khi Lưu!"
	end
	task.wait(1.5)
	btnSaveWP.Text = "💾 Lưu Danh Sách WP"
end)

btnLoadWP.MouseButton1Click:Connect(function()
	if loadWaypointsForCurrentGame() then
		btnLoadWP.Text = "✅ Đã Tải: " .. #waypoints .. " điểm"
	else
		btnLoadWP.Text = "⚠️ Không Có Dữ Liệu"
	end
	task.wait(1.5)
	btnLoadWP.Text = "📂 Tải Danh Sách WP"
end)

-- Tự động Load dữ liệu Waypoint khi chạy Script
task.spawn(function()
	task.wait(1)
	loadWaypointsForCurrentGame()
end)
