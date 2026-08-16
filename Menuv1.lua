-- Roblox Mobile Hub - Ultimate Custom Edition
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Cấu hình hệ thống
local Settings = {
    AimbotMode = "None",
    FOVRadius = 120,
    
    WalkSpeedActive = false,
    WalkSpeedVal = 16,
    
    JumpPowerActive = false,
    JumpPowerVal = 50,
    
    FlyActive = false,
    FlySpeed = 50,
    
    InfJumpActive = false,
    GravityActive = false,
    GravityVal = 196.2,
    
    ShiftLockActive = false,
    
    FullBrightActive = false,
    UnlockCamActive = false,
    RemoveFogActive = false,
    
    ESP_Name = false,
    ESP_Highlight = false,
    ESP_Full = false,
    
    TargetPlayerName = "",
    
    -- Auto Click
    AC_LoopInfinite = true,
    AC_LoopCount = 5,
    AC_CircleSize = 40,
    AC_Running = false
}

local ServerStartTime = os.time()

-- Anti AFK
LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

-- Vòng tròn FOV Aimbot
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 50, 50)
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = false

---------------------------------------------------------
-- KHUNG GIAO DIỆN CHÍNH (UI)
---------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "UltimateMobileHub"
ScreenGui.ResetOnSpawn = false

-- Nút Bật/Tắt Menu Chính
local ToggleMenuBtn = Instance.new("TextButton", ScreenGui)
ToggleMenuBtn.Size = UDim2.new(0, 80, 0, 35)
ToggleMenuBtn.Position = UDim2.new(0.02, 0, 0.15, 0)
ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleMenuBtn.Text = "MENU HUB"
ToggleMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 0)
ToggleMenuBtn.TextSize = 13
ToggleMenuBtn.Active = true
ToggleMenuBtn.Draggable = true

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 500, 0, 250)
MainFrame.Position = UDim2.new(0.5, -250, 0.4, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Draggable = true

ToggleMenuBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Header Bar
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Color3.fromRGB(10, 10, 10)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -10, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "MOBILE ADVANCED HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Navigation Bar (7 Tabs)
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Position = UDim2.new(0, 0, 0, 30)
TabBar.Size = UDim2.new(1, 0, 0, 30)
TabBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection = Enum.FillDirection.Horizontal

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Position = UDim2.new(0, 0, 0, 60)
ContentFrame.Size = UDim2.new(1, 0, 1, -60)
ContentFrame.BackgroundTransparency = 1

local Pages = {}

local function createTab(name, order)
    local btn = Instance.new("TextButton", TabBar)
    btn.Size = UDim2.new(1/7, 0, 1, 0)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextSize = 10

    local page = Instance.new("ScrollingFrame", ContentFrame)
    page.Size = UDim2.new(1, -10, 1, -10)
    page.Position = UDim2.new(0, 5, 0, 5)
    page.BackgroundTransparency = 1
    page.Visible = (order == 1)
    page.CanvasSize = UDim2.new(0, 0, 3, 0)
    page.ScrollBarThickness = 4

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 5)

    Pages[name] = page

    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(ContentFrame:GetChildren()) do p.Visible = false end
        for _, b in pairs(TabBar:GetChildren()) do
            if b:IsA("TextButton") then b.TextColor3 = Color3.fromRGB(180, 180, 180) end
        end
        page.Visible = true
        btn.TextColor3 = Color3.fromRGB(255, 255, 0)
    end)
    return page
end

local ServerPage   = createTab("SERVER", 1)
local CombatPage   = createTab("COMBAT", 2)
local MovePage     = createTab("MOVE", 3)
local VisualPage   = createTab("ESP", 4)
local WorldPage    = createTab("WORLD", 5)
local PlayerPage   = createTab("PLAYER", 6)
local AutoClickPage= createTab("CLICK", 7)

---------------------------------------------------------
-- UI HELPER FUNCTIONS
---------------------------------------------------------
local function addToggleWithInput(page, name, defaultVal, onToggle, onValChange)
    local frame = Instance.new("Frame", page)
    frame.Size = UDim2.new(0.98, 0, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.5, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)

    local txt = Instance.new("TextBox", frame)
    txt.Position = UDim2.new(0.52, 0, 0, 0)
    txt.Size = UDim2.new(0.46, 0, 1, 0)
    txt.Text = tostring(defaultVal)
    txt.PlaceholderText = "Nhập giá trị"
    txt.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    txt.TextColor3 = Color3.fromRGB(0, 255, 255)

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.BackgroundColor3 = active and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
        btn.Text = name .. (active and ": ON" or ": OFF")
        onToggle(active)
    end)

    txt.FocusLost:Connect(function()
        local val = tonumber(txt.Text)
        if val then onValChange(val) end
    end)
end

local function addSimpleToggle(page, name, onToggle)
    local btn = Instance.new("TextButton", page)
    btn.Size = UDim2.new(0.98, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.BackgroundColor3 = active and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
        btn.Text = name .. (active and ": ON" or ": OFF")
        onToggle(active)
    end)
    return btn
end

---------------------------------------------------------
-- 1. TAB SERVER
---------------------------------------------------------
local ServerAgeLabel = Instance.new("TextLabel", ServerPage)
ServerAgeLabel.Size = UDim2.new(0.98, 0, 0, 25)
ServerAgeLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ServerAgeLabel.TextColor3 = Color3.fromRGB(0, 255, 0)

task.spawn(function()
    while task.wait(1) do
        local diff = os.time() - ServerStartTime
        local d = math.floor(diff / 86400)
        local h = math.floor((diff % 86400) / 3600)
        local m = math.floor((diff % 3600) / 60)
        local s = diff % 60
        ServerAgeLabel.Text = string.format("Tuổi Server: %d ngày, %d giờ, %d phút, %d giây", d, h, m, s)
    end
end)

local PlayerListFrame = Instance.new("Frame", ServerPage)
PlayerListFrame.Size = UDim2.new(0.98, 0, 0, 120)
PlayerListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local PlayerScroll = Instance.new("ScrollingFrame", PlayerListFrame)
PlayerScroll.Size = UDim2.new(1, 0, 1, 0)
PlayerScroll.CanvasSize = UDim2.new(0, 0, 5, 0)
local PLayout = Instance.new("UIListLayout", PlayerScroll)

local function loadServerPlayers()
    for _, item in pairs(PlayerScroll:GetChildren()) do
        if not item:IsA("UIListLayout") then item:Destroy() end
    end
    for _, p in pairs(Players:GetPlayers()) do
        local item = Instance.new("Frame", PlayerScroll)
        item.Size = UDim2.new(1, 0, 0, 30)
        item.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

        local img = Instance.new("ImageLabel", item)
        img.Size = UDim2.new(0, 30, 0, 30)
        img.Image = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)

        local nameLbl = Instance.new("TextLabel", item)
        nameLbl.Position = UDim2.new(0, 35, 0, 0)
        nameLbl.Size = UDim2.new(0.4, 0, 1, 0)
        nameLbl.Text = p.DisplayName .. " (@" .. p.Name .. ")"
        nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLbl.TextScaled = true

        local cReal = Instance.new("TextButton", item)
        cReal.Position = UDim2.new(0.72, 0, 0.1, 0)
        cReal.Size = UDim2.new(0.13, 0, 0.8, 0)
        cReal.Text = "Copy User"
        cReal.MouseButton1Click:Connect(function() setclipboard(p.Name) end)

        local cDisplay = Instance.new("TextButton", item)
        cDisplay.Position = UDim2.new(0.86, 0, 0.1, 0)
        cDisplay.Size = UDim2.new(0.13, 0, 0.8, 0)
        cDisplay.Text = "Copy Display"
        cDisplay.MouseButton1Click:Connect(function() setclipboard(p.DisplayName) end)
    end
end
loadServerPlayers()

local ResetBtn = Instance.new("TextButton", ServerPage)
ResetBtn.Size = UDim2.new(0.98, 0, 0, 30)
ResetBtn.Text = "Reset Player List"
ResetBtn.MouseButton1Click:Connect(loadServerPlayers)

local RejoinBtn = Instance.new("TextButton", ServerPage)
RejoinBtn.Size = UDim2.new(0.98, 0, 0, 30)
RejoinBtn.Text = "Rejoin Server"
RejoinBtn.MouseButton1Click:Connect(function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

local HopBtn = Instance.new("TextButton", ServerPage)
HopBtn.Size = UDim2.new(0.98, 0, 0, 30)
HopBtn.Text = "Hop Server (Ngẫu nhiên)"
HopBtn.MouseButton1Click:Connect(function()
    local api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local list = HttpService:JSONDecode(game:HttpGet(api)).data
    if list and #list > 0 then
        local s = list[math.random(1, #list)]
        TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
    end
end)

local LowHopBtn = Instance.new("TextButton", ServerPage)
LowHopBtn.Size = UDim2.new(0.98, 0, 0, 30)
LowHopBtn.Text = "Join Low Server (1-5 Người)"
LowHopBtn.MouseButton1Click:Connect(function()
    local api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local list = HttpService:JSONDecode(game:HttpGet(api)).data
    for _, s in pairs(list) do
        if s.playing >= 1 and s.playing <= 5 and s.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
            break
        end
    end
end)

---------------------------------------------------------
-- 2. TAB COMBAT
---------------------------------------------------------
addSimpleToggle(CombatPage, "Aim Người Gần Nhất", function(val) Settings.AimbotMode = val and "Closest" or "None" end)
addSimpleToggle(CombatPage, "Aim Ít Máu Nhất", function(val) Settings.AimbotMode = val and "LowestHealth" or "None" end)

local AimFOVToggle = Instance.new("TextButton", CombatPage)
AimFOVToggle.Size = UDim2.new(0.98, 0, 0, 30)
AimFOVToggle.Text = "Aim Vòng Tròn (FOV Trung Tâm): OFF"
AimFOVToggle.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
AimFOVToggle.MouseButton1Click:Connect(function()
    if Settings.AimbotMode == "FOV" then
        Settings.AimbotMode = "None"
        FOVCircle.Visible = false
        AimFOVToggle.Text = "Aim Vòng Tròn (FOV Trung Tâm): OFF"
        AimFOVToggle.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    else
        Settings.AimbotMode = "FOV"
        FOVCircle.Visible = true
        AimFOVToggle.Text = "Aim Vòng Tròn (FOV Trung Tâm): ON"
        AimFOVToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    end
end)

local FOVInput = Instance.new("TextBox", CombatPage)
FOVInput.Size = UDim2.new(0.98, 0, 0, 30)
FOVInput.Text = tostring(Settings.FOVRadius)
FOVInput.PlaceholderText = "Nhập bán kính FOV"
FOVInput.FocusLost:Connect(function()
    local val = tonumber(FOVInput.Text)
    if val then
        Settings.FOVRadius = val
        FOVCircle.Radius = val
    end
end)

---------------------------------------------------------
-- 3. TAB MOVEMENT (BAY MỚI & SHIFT LOCK)
---------------------------------------------------------
addToggleWithInput(MovePage, "Chạy Nhanh", Settings.WalkSpeedVal, function(state) Settings.WalkSpeedActive = state end, function(val) Settings.WalkSpeedVal = val end)
addToggleWithInput(MovePage, "Nhảy Cao", Settings.JumpPowerVal, function(state) Settings.JumpPowerActive = state end, function(val) Settings.JumpPowerVal = val end)
addToggleWithInput(MovePage, "Trọng Lực (Gravity)", Settings.GravityVal, function(state) Settings.GravityActive = state end, function(val) Settings.GravityVal = val end)
addSimpleToggle(MovePage, "Nhảy Vô Hạn", function(state) Settings.InfJumpActive = state end)

-- Nút nổi Bay (Fly Toggle Floating Button)
local FlyFloatBtn = Instance.new("TextButton", ScreenGui)
FlyFloatBtn.Size = UDim2.new(0, 60, 0, 35)
FlyFloatBtn.Position = UDim2.new(0.02, 0, 0.25, 0)
FlyFloatBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
FlyFloatBtn.Text = "FLY: OFF"
FlyFloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyFloatBtn.TextSize = 11
FlyFloatBtn.Visible = false
FlyFloatBtn.Active = true
FlyFloatBtn.Draggable = true

local isFlyingToggle = false
FlyFloatBtn.MouseButton1Click:Connect(function()
    isFlyingToggle = not isFlyingToggle
    FlyFloatBtn.BackgroundColor3 = isFlyingToggle and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
    FlyFloatBtn.Text = isFlyingToggle and "FLY: ON" or "FLY: OFF"
end)

addToggleWithInput(MovePage, "Kích Hoạt Nút Bay Nổi", Settings.FlySpeed, function(state)
    Settings.FlyActive = state
    FlyFloatBtn.Visible = state
    if not state then
        isFlyingToggle = false
        FlyFloatBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        FlyFloatBtn.Text = "FLY: OFF"
    end
end, function(val) Settings.FlySpeed = val end)

-- Shift Lock Floating System
local ShiftLockFloatBtn = Instance.new("ImageButton", ScreenGui)
ShiftLockFloatBtn.Size = UDim2.new(0, 45, 0, 45)
ShiftLockFloatBtn.Position = UDim2.new(0.85, 0, 0.5, 0)
ShiftLockFloatBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ShiftLockFloatBtn.BackgroundTransparency = 0.5
ShiftLockFloatBtn.Image = "rbxassetid://6031068433" -- Icon Shift Lock chuẩn
ShiftLockFloatBtn.Visible = false
ShiftLockFloatBtn.Active = true
ShiftLockFloatBtn.Draggable = true

local ShiftLockCrosshair = Instance.new("ImageLabel", ScreenGui)
ShiftLockCrosshair.Size = UDim2.new(0, 16, 0, 16)
ShiftLockCrosshair.Position = UDim2.new(0.5, -8, 0.5, -8)
ShiftLockCrosshair.BackgroundTransparency = 1
ShiftLockCrosshair.Image = "rbxassetid://6031068433"
ShiftLockCrosshair.Visible = false

local shiftLockEnabled = false
ShiftLockFloatBtn.MouseButton1Click:Connect(function()
    shiftLockEnabled = not shiftLockEnabled
    ShiftLockCrosshair.Visible = shiftLockEnabled
    ShiftLockFloatBtn.BackgroundColor3 = shiftLockEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(0, 0, 0)
end)

addSimpleToggle(MovePage, "Bật Nút Shift Lock Nổi", function(state)
    Settings.ShiftLockActive = state
    ShiftLockFloatBtn.Visible = state
    if not state then
        shiftLockEnabled = false
        ShiftLockCrosshair.Visible = false
    end
end)

---------------------------------------------------------
-- 4. TAB VISUAL (ESP & LIGHTING)
---------------------------------------------------------
addSimpleToggle(VisualPage, "ESP Tên", function(val) Settings.ESP_Name = val end)
addSimpleToggle(VisualPage, "ESP Viền Sáng", function(val) Settings.ESP_Highlight = val end)
addSimpleToggle(VisualPage, "Full ESP (Hiển thị Máu + Tên)", function(val) Settings.ESP_Full = val end)
addSimpleToggle(VisualPage, "Full Bright (Màn Hình Sáng)", function(val)
    Settings.FullBrightActive = val
    Lighting.Ambient = val and Color3.new(1,1,1) or Color3.fromRGB(127,127,127)
    Lighting.GlobalShadows = not val
end)
addSimpleToggle(VisualPage, "Mở Khoá Góc Nhìn Camera", function(val)
    LocalPlayer.CameraMaxZoomDistance = val and 99999 or 128
end)

---------------------------------------------------------
-- 5. TAB WORLD (XÓA SƯƠNG MÙ & GIẢM LAG)
---------------------------------------------------------
addSimpleToggle(WorldPage, "Xóa Sương Mù (Remove Fog)", function(val)
    Settings.RemoveFogActive = val
    if val then
        Lighting.FogEnd = 9e9
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("Atmosphere") then v:Destroy() end
        end
    else
        Lighting.FogEnd = 1000
    end
end)

local function optimizeGame()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v:Destroy()
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false
        end
    end
end

local AntiLagBtn = Instance.new("TextButton", WorldPage)
AntiLagBtn.Size = UDim2.new(0.98, 0, 0, 30)
AntiLagBtn.Text = "Giảm Lag (FPS Boost - Smooth Textures)"
AntiLagBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
AntiLagBtn.MouseButton1Click:Connect(function()
    optimizeGame()
    AntiLagBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    AntiLagBtn.Text = "Đã Bật Giảm Lag!"
end)

---------------------------------------------------------
-- 6. TAB PLAYER
---------------------------------------------------------
local TargetProfileFrame = Instance.new("Frame", PlayerPage)
TargetProfileFrame.Size = UDim2.new(0.98, 0, 0, 80)
TargetProfileFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

local AvatarImg = Instance.new("ImageLabel", TargetProfileFrame)
AvatarImg.Size = UDim2.new(0, 75, 0, 75)
AvatarImg.Position = UDim2.new(0, 2, 0, 2)

local InfoLabel = Instance.new("TextLabel", TargetProfileFrame)
InfoLabel.Position = UDim2.new(0, 85, 0, 5)
InfoLabel.Size = UDim2.new(0.7, 0, 0.9, 0)
InfoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
InfoLabel.Text = "Nhập tên người chơi bên dưới..."

local SearchBox = Instance.new("TextBox", PlayerPage)
SearchBox.Size = UDim2.new(0.98, 0, 0, 30)
SearchBox.PlaceholderText = "Nhập tên người chơi..."
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 0)

local targetSelectedPlayer = nil

SearchBox.FocusLost:Connect(function()
    local text = SearchBox.Text:lower()
    targetSelectedPlayer = nil
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #text) == text or p.DisplayName:lower():sub(1, #text) == text then
            targetSelectedPlayer = p
            break
        end
    end
    
    if targetSelectedPlayer then
        AvatarImg.Image = Players:GetUserThumbnailAsync(targetSelectedPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        InfoLabel.Text = string.format("Tên: %s\n@User: %s\nTuổi Acc: %d ngày", targetSelectedPlayer.DisplayName, targetSelectedPlayer.Name, targetSelectedPlayer.AccountAge)
        Settings.TargetPlayerName = targetSelectedPlayer.Name
    else
        InfoLabel.Text = "Không tìm thấy người chơi!"
    end
end)

local TeleBtn = Instance.new("TextButton", PlayerPage)
TeleBtn.Size = UDim2.new(0.98, 0, 0, 30)
TeleBtn.Text = "Teleport Đến Người Chơi"
TeleBtn.MouseButton1Click:Connect(function()
    if targetSelectedPlayer and targetSelectedPlayer.Character and targetSelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = targetSelectedPlayer.Character.HumanoidRootPart.CFrame
    end
end)

local ViewPlayerBtn = Instance.new("TextButton", PlayerPage)
ViewPlayerBtn.Size = UDim2.new(0.98, 0, 0, 30)
ViewPlayerBtn.Text = "Xem Góc Nhìn (Toggle)"
local viewingTarget = false
ViewPlayerBtn.MouseButton1Click:Connect(function()
    viewingTarget = not viewingTarget
    if viewingTarget and targetSelectedPlayer and targetSelectedPlayer.Character then
        Camera.CameraSubject = targetSelectedPlayer.Character:FindFirstChildOfClass("Humanoid")
    else
        Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    end
end)

local TargetESPBtn = Instance.new("TextButton", PlayerPage)
TargetESPBtn.Size = UDim2.new(0.98, 0, 0, 30)
TargetESPBtn.Text = "Full ESP Người Chơi Này"
local targetESPActive = false
TargetESPBtn.MouseButton1Click:Connect(function()
    targetESPActive = not targetESPActive
    TargetESPBtn.BackgroundColor3 = targetESPActive and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
end)

---------------------------------------------------------
-- 7. TAB AUTO CLICK & FLOATING CONTROLLER
---------------------------------------------------------
local AutoClickPoints = {}

-- Thanh công cụ Auto Click Nổi ngoài màn hình
local ACBar = Instance.new("Frame", ScreenGui)
ACBar.Size = UDim2.new(0, 160, 0, 40)
ACBar.Position = UDim2.new(0.02, 0, 0.35, 0)
ACBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ACBar.Active = true
ACBar.Draggable = true
ACBar.Visible = false

local ACAddBtn = Instance.new("TextButton", ACBar)
ACAddBtn.Size = UDim2.new(0.3, -2, 0.8, 0)
ACAddBtn.Position = UDim2.new(0.03, 0, 0.1, 0)
ACAddBtn.Text = "+"
ACAddBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
ACAddBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ACAddBtn.TextSize = 18

local ACRunBtn = Instance.new("TextButton", ACBar)
ACRunBtn.Size = UDim2.new(0.3, -2, 0.8, 0)
ACRunBtn.Position = UDim2.new(0.35, 0, 0.1, 0)
ACRunBtn.Text = "▶"
ACRunBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 50)
ACRunBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ACRunBtn.TextSize = 14

local ACSettingsBtn = Instance.new("TextButton", ACBar)
ACSettingsBtn.Size = UDim2.new(0.3, -2, 0.8, 0)
ACSettingsBtn.Position = UDim2.new(0.67, 0, 0.1, 0)
ACSettingsBtn.Text = "⚙"
ACSettingsBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 0)
ACSettingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ACSettingsBtn.TextSize = 14

-- Menu Cài đặt Mini
local ACSettingsFrame = Instance.new("Frame", ScreenGui)
ACSettingsFrame.Size = UDim2.new(0, 200, 0, 140)
ACSettingsFrame.Position = UDim2.new(0.02, 0, 0.43, 0)
ACSettingsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ACSettingsFrame.Visible = false
ACSettingsFrame.Active = true
ACSettingsFrame.Draggable = true

local ACLoopInfBtn = Instance.new("TextButton", ACSettingsFrame)
ACLoopInfBtn.Size = UDim2.new(0.9, 0, 0, 30)
ACLoopInfBtn.Position = UDim2.new(0.05, 0, 0.08, 0)
ACLoopInfBtn.Text = "Lặp Vô Hạn: ON"
ACLoopInfBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
ACLoopInfBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

ACLoopInfBtn.MouseButton1Click:Connect(function()
    Settings.AC_LoopInfinite = not Settings.AC_LoopInfinite
    ACLoopInfBtn.BackgroundColor3 = Settings.AC_LoopInfinite and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
    ACLoopInfBtn.Text = "Lặp Vô Hạn: " .. (Settings.AC_LoopInfinite and "ON" or "OFF")
end)

local ACLoopCountBox = Instance.new("TextBox", ACSettingsFrame)
ACLoopCountBox.Size = UDim2.new(0.9, 0, 0, 30)
ACLoopCountBox.Position = UDim2.new(0.05, 0, 0.35, 0)
ACLoopCountBox.Text = tostring(Settings.AC_LoopCount)
ACLoopCountBox.PlaceholderText = "Số vòng lặp"
ACLoopCountBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ACLoopCountBox.TextColor3 = Color3.fromRGB(0, 255, 255)

ACLoopCountBox.FocusLost:Connect(function()
    local val = tonumber(ACLoopCountBox.Text)
    if val then Settings.AC_LoopCount = val end
end)

local ACSizeBox = Instance.new("TextBox", ACSettingsFrame)
ACSizeBox.Size = UDim2.new(0.9, 0, 0, 30)
ACSizeBox.Position = UDim2.new(0.05, 0, 0.62, 0)
ACSizeBox.Text = tostring(Settings.AC_CircleSize)
ACSizeBox.PlaceholderText = "Kích thước vòng"
ACSizeBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ACSizeBox.TextColor3 = Color3.fromRGB(0, 255, 255)

ACSizeBox.FocusLost:Connect(function()
    local val = tonumber(ACSizeBox.Text)
    if val then
        Settings.AC_CircleSize = val
        for _, p in pairs(AutoClickPoints) do
            p.Frame.Size = UDim2.new(0, val, 0, val)
            p.Frame.UICorner.CornerRadius = UDim.new(1, 0)
        end
    end
end)

ACSettingsBtn.MouseButton1Click:Connect(function()
    ACSettingsFrame.Visible = not ACSettingsFrame.Visible
end)

-- Tạo điểm Auto Click
local function createAutoClickPoint()
    local id = #AutoClickPoints + 1
    local pFrame = Instance.new("Frame", ScreenGui)
    pFrame.Size = UDim2.new(0, Settings.AC_CircleSize, 0, Settings.AC_CircleSize)
    pFrame.Position = UDim2.new(0.5, -20 + (id * 10), 0.5, -20)
    pFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    pFrame.BackgroundTransparency = 0.7
    pFrame.Active = true
    pFrame.Draggable = true

    local stroke = Instance.new("UIStroke", pFrame)
    stroke.Color = Color3.fromRGB(255, 0, 0)
    stroke.Thickness = 3

    local corner = Instance.new("UICorner", pFrame)
    corner.CornerRadius = UDim.new(1, 0)

    local lbl = Instance.new("TextLabel", pFrame)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = tostring(id)
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextSize = 14
    lbl.Font = Enum.Font.SourceSansBold

    table.insert(AutoClickPoints, {Frame = pFrame, UICorner = corner})
end

ACAddBtn.MouseButton1Click:Connect(createAutoClickPoint)

-- Logic Chạy Auto Click
local VirtualInputManager = game:GetService("VirtualInputManager")

ACRunBtn.MouseButton1Click:Connect(function()
    Settings.AC_Running = not Settings.AC_Running
    if Settings.AC_Running then
        ACRunBtn.Text = "⏹"
        ACRunBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        
        task.spawn(function()
            local loops = 0
            while Settings.AC_Running do
                if not Settings.AC_LoopInfinite and loops >= Settings.AC_LoopCount then
                    Settings.AC_Running = false
                    break
                end

                for i, p in ipairs(AutoClickPoints) do
                    if not Settings.AC_Running then break end
                    local pos = p.Frame.AbsolutePosition + (p.Frame.AbsoluteSize / 2)
                    VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y + 36, 0, true, game, 0)
                    task.wait(0.05)
                    VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y + 36, 0, false, game, 0)
                    task.wait(0.1)
                end

                loops = loops + 1
                task.wait(0.1)
            end
            
            Settings.AC_Running = false
            ACRunBtn.Text = "▶"
            ACRunBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 50)
        end)
    else
        ACRunBtn.Text = "▶"
        ACRunBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 50)
    end
end)

addSimpleToggle(AutoClickPage, "Bật Thanh Công Cụ Auto Click", function(state)
    ACBar.Visible = state
    if not state then
        ACSettingsFrame.Visible = false
        Settings.AC_Running = false
    end
end)

local ClearACBtn = Instance.new("TextButton", AutoClickPage)
ClearACBtn.Size = UDim2.new(0.98, 0, 0, 30)
ClearACBtn.Text = "Xóa Tất Cả Điểm Auto Click"
ClearACBtn.MouseButton1Click:Connect(function()
    for _, p in pairs(AutoClickPoints) do
        p.Frame:Destroy()
    end
    AutoClickPoints = {}
end)

---------------------------------------------------------
-- HỆ THỐNG XỬ LÝ VÒNG LẶP RENDERSTEPPED & GAMEPLAY
---------------------------------------------------------

-- 1. Nhảy Vô Hạn
UserInputService.JumpRequest:Connect(function()
    if Settings.InfJumpActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- 2. Hàm Tính Màu Máu Chi Tiết
local function getHealthColor(percent)
    if percent >= 0.99 then
        return Color3.fromRGB(0, 255, 0) -- 100% Xanh lá
    elseif percent >= 0.75 then
        return Color3.fromRGB(153, 255, 0) -- 75% Xanh chuối
    elseif percent >= 0.50 then
        return Color3.fromRGB(255, 255, 0) -- 50% Vàng
    elseif percent >= 0.35 then
        return Color3.fromRGB(255, 128, 0) -- 35% Cam
    else
        return Color3.fromRGB(255, 0, 0) -- <=20% Đỏ
    end
end

-- 3. Tạo ESP Cho Nhân Vật
local function setupESPForCharacter(char)
    if not char then return end
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if not hrp then return end

    if char:FindFirstChild("ESP_Highlight") then char.ESP_Highlight:Destroy() end
    if hrp:FindFirstChild("ESP_Billboard") then hrp.ESP_Billboard:Destroy() end

    local hl = Instance.new("Highlight", char)
    hl.Name = "ESP_Highlight"
    hl.Enabled = false

    local bb = Instance.new("BillboardGui", hrp)
    bb.Name = "ESP_Billboard"
    bb.Size = UDim2.new(0, 150, 0, 40)
    bb.AlwaysOnTop = true
    bb.ExtentsOffset = Vector3.new(0, 3.5, 0)
    bb.Enabled = false

    local txtName = Instance.new("TextLabel", bb)
    txtName.Name = "NameLabel"
    txtName.Size = UDim2.new(1, 0, 0.5, 0)
    txtName.BackgroundTransparency = 1
    txtName.TextScaled = true
    txtName.Font = Enum.Font.SourceSansBold

    local txtHP = Instance.new("TextLabel", bb)
    txtHP.Name = "HPLabel"
    txtHP.Position = UDim2.new(0, 0, 0.5, 0)
    txtHP.Size = UDim2.new(1, 0, 0.5, 0)
    txtHP.BackgroundTransparency = 1
    txtHP.TextScaled = true
    txtHP.Font = Enum.Font.SourceSans
end

local function applyESP(p)
    if p == LocalPlayer then return end
    if p.Character then setupESPForCharacter(p.Character) end
    p.CharacterAdded:Connect(setupESPForCharacter)
end

-- Áp dụng ngay lập tức cho người chơi hiện có & mới vào
for _, p in pairs(Players:GetPlayers()) do applyESP(p) end
Players.PlayerAdded:Connect(applyESP)

-- Vòng lặp RenderStepped
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- ESP Loop
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
            local char = p.Character
            local hum = char.Humanoid
            local hrp = char.HumanoidRootPart

            local hl = char:FindFirstChild("ESP_Highlight")
            local bb = hrp:FindFirstChild("ESP_Billboard")

            local isTargetPlayer = (p == targetSelectedPlayer and targetESPActive)

            if hl then
                hl.Enabled = Settings.ESP_Highlight or Settings.ESP_Full or isTargetPlayer
            end

            if bb then
                local txtName = bb:FindFirstChild("NameLabel")
                local txtHP = bb:FindFirstChild("HPLabel")
                
                bb.Enabled = Settings.ESP_Name or Settings.ESP_Full or isTargetPlayer

                local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                local currentColor = getHealthColor(hpPercent)

                if txtName and txtHP then
                    txtName.Text = p.DisplayName
                    txtName.TextColor3 = currentColor

                    if Settings.ESP_Full or isTargetPlayer then
                        txtHP.Text = string.format("[HP: %d/%d]", math.floor(hum.Health), math.floor(hum.MaxHealth))
                        txtHP.TextColor3 = currentColor
                        txtHP.Visible = true
                    else
                        txtHP.Visible = false
                    end
                end

                if hl then
                    hl.FillColor = currentColor
                    hl.OutlineColor = currentColor
                end
            end
        end
    end

    -- Character Movement & Fly Mechanics
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        local hrp = char:FindFirstChild("HumanoidRootPart")

        if Settings.WalkSpeedActive then hum.WalkSpeed = Settings.WalkSpeedVal end
        if Settings.JumpPowerActive then
            hum.UseJumpPower = true
            hum.JumpPower = Settings.JumpPowerVal
        end
        if Settings.GravityActive then workspace.Gravity = Settings.GravityVal end

        -- Bay theo đúng hướng nhìn Camera
        if Settings.FlyActive and isFlyingToggle and hrp then
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                -- Tính toán Vector hướng của Camera
                local camCFrame = Camera.CFrame
                local flyVector = (camCFrame.LookVector * -moveDir.Z) + (camCFrame.RightVector * moveDir.X)
                hrp.Velocity = flyVector.Unit * Settings.FlySpeed
            else
                hrp.Velocity = Vector3.new(0, 0, 0)
            end
        end

        -- Shift Lock Alignment
        if shiftLockEnabled and hrp then
            local lookPos = Camera.CFrame.LookVector
            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(lookPos.X, 0, lookPos.Z))
        end
    end

    -- Logic Aimbot
    if Settings.AimbotMode ~= "None" then
        local target = nil
        local shortestDist = math.huge
        local lowestHP = math.huge
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
                local pChar = player.Character
                local pHum = pChar.Humanoid
                local pHrp = pChar.HumanoidRootPart

                if pHum.Health > 0 then
                    local pos, onScreen = Camera:WorldToViewportPoint(pHrp.Position)
                    local distToCenter = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                    local distToPlayer = (pHrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude

                    if Settings.AimbotMode == "Closest" and distToPlayer < shortestDist then
                        shortestDist = distToPlayer
                        target = pHrp
                    elseif Settings.AimbotMode == "LowestHealth" and pHum.Health < lowestHP then
                        lowestHP = pHum.Health
                        target = pHrp
                    elseif Settings.AimbotMode == "FOV" and onScreen and distToCenter <= Settings.FOVRadius then
                        if distToCenter < shortestDist then
                            shortestDist = distToCenter
                            target = pHrp
                        end
                    end
                end
            end
        end

        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)
