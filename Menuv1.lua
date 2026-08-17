-- Roblox Mobile Hub - Ultimate Custom Edition Fixed & Upgraded
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

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
    
    -- Auto Click Settings
    AC_LoopInfinite = true,
    AC_LoopCount = 5,
    AC_CircleSize = 40,
    AC_Delay = 0.1,
    AC_Running = false,

    -- Waypoint Settings
    WP_Mode = "Fly", -- "Fly" hoặc "Teleport"
    WP_FlySpeed = 50, -- Studs/Giây
    WP_Running = false
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
-- TẠO VÀ XỬ LÝ KHUNG GIAO DIỆN CHÍNH
---------------------------------------------------------
local function GetSafeParent()
    local success, parent = pcall(function()
        if gethui then
            return gethui()
        elseif game:GetService("CoreGui") then
            return game:GetService("CoreGui")
        end
    end)
    if success and parent then
        return parent
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local TargetParent = GetSafeParent()

if TargetParent:FindFirstChild("UltimateMobileHub") then
    TargetParent.UltimateMobileHub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltimateMobileHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = TargetParent

-- Nút Bật/Tắt Menu Chính
local ToggleMenuBtn = Instance.new("TextButton", ScreenGui)
ToggleMenuBtn.Size = UDim2.new(0, 90, 0, 35)
ToggleMenuBtn.Position = UDim2.new(0.02, 0, 0.15, 0)
ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleMenuBtn.Text = "MENU HUB"
ToggleMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 0)
ToggleMenuBtn.TextSize = 13
ToggleMenuBtn.Active = true
ToggleMenuBtn.Draggable = true

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 500, 0, 260)
MainFrame.Position = UDim2.new(0.5, -250, 0.4, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Draggable = true

-- Viền Menu to giúp dễ di chuyển / kéo thả
local MainFrameStroke = Instance.new("UIStroke", MainFrame)
MainFrameStroke.Color = Color3.fromRGB(0, 170, 255)
MainFrameStroke.Thickness = 3
MainFrameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

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

-- Navigation Bar (6 Tabs)
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
    btn.Size = UDim2.new(1/6, 0, 1, 0)
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
local MiscPage     = createTab("TỔNG HỢP", 7)

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
        pcall(function()
            img.Image = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        end)

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
    pcall(function()
        local api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local list = HttpService:JSONDecode(game:HttpGet(api)).data
        if list and #list > 0 then
            local s = list[math.random(1, #list)]
            TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
        end
    end)
end)

local LowHopBtn = Instance.new("TextButton", ServerPage)
LowHopBtn.Size = UDim2.new(0.98, 0, 0, 30)
LowHopBtn.Text = "Join Low Server (1-5 Người)"
LowHopBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local list = HttpService:JSONDecode(game:HttpGet(api)).data
        for _, s in pairs(list) do
            if s.playing >= 1 and s.playing <= 5 and s.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                break
            end
        end
    end)
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
-- 3. TAB MOVEMENT & FIXED SHIFTLOCK
---------------------------------------------------------
addToggleWithInput(MovePage, "Chạy Nhanh", Settings.WalkSpeedVal, function(state) Settings.WalkSpeedActive = state end, function(val) Settings.WalkSpeedVal = val end)
addToggleWithInput(MovePage, "Nhảy Cao", Settings.JumpPowerVal, function(state) Settings.JumpPowerActive = state end, function(val) Settings.JumpPowerVal = val end)
addToggleWithInput(MovePage, "Trọng Lực (Gravity)", Settings.GravityVal, function(state) Settings.GravityActive = state end, function(val) Settings.GravityVal = val end)
addSimpleToggle(MovePage, "Nhảy Vô Hạn", function(state) Settings.InfJumpActive = state end)

addSimpleToggle(MovePage, "Bật Script Bay (FlyGui V3)", function(state)
    if state then
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
        end)
    end
end)

-- Shift Lock UI (Fixed Parent)
local ShiftLockFloatBtn = Instance.new("ImageButton", ScreenGui)
ShiftLockFloatBtn.Name = "ShiftLockFloatBtn"
ShiftLockFloatBtn.Size = UDim2.new(0, 50, 0, 50)
ShiftLockFloatBtn.Position = UDim2.new(0.85, 0, 0.5, 0)
ShiftLockFloatBtn.BackgroundTransparency = 1
ShiftLockFloatBtn.Image = "rbxassetid://10734923617"
ShiftLockFloatBtn.Visible = false
ShiftLockFloatBtn.Active = true
ShiftLockFloatBtn.Draggable = true

local ShiftLockCrosshair = Instance.new("ImageLabel", ScreenGui)
ShiftLockCrosshair.Name = "ShiftLockCrosshair"
ShiftLockCrosshair.Size = UDim2.new(0, 32, 0, 32)
ShiftLockCrosshair.Position = UDim2.new(0.5, -16, 0.5, -16)
ShiftLockCrosshair.BackgroundTransparency = 1
ShiftLockCrosshair.Image = "rbxassetid://11822818625"
ShiftLockCrosshair.Visible = false

local shiftLockEnabled = false

ShiftLockFloatBtn.MouseButton1Click:Connect(function()
    shiftLockEnabled = not shiftLockEnabled
    if shiftLockEnabled then
        ShiftLockFloatBtn.Image = "rbxassetid://10734923868"
        ShiftLockCrosshair.Visible = true
    else
        ShiftLockFloatBtn.Image = "rbxassetid://10734923617"
        ShiftLockCrosshair.Visible = false
    end
end)

addSimpleToggle(MovePage, "Bật Nút Shift Lock Nổi Chuẩn PC", function(state)
    Settings.ShiftLockActive = state
    ShiftLockFloatBtn.Visible = state
    if not state then
        shiftLockEnabled = false
        ShiftLockCrosshair.Visible = false
        ShiftLockFloatBtn.Image = "rbxassetid://10734923617"
    end
end)

---------------------------------------------------------
-- 4. TAB VISUAL
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
-- 5. TAB WORLD
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
        pcall(function()
            AvatarImg.Image = Players:GetUserThumbnailAsync(targetSelectedPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        end)
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
-- 7. TAB TỔNG HỢP (AUTO CLICK & WAYPOINT SYSTEM)
---------------------------------------------------------

------------------ AUTO CLICK NỔI TỐI ƯU ------------------
local AutoClickPoints = {}

local ACBar = Instance.new("Frame", ScreenGui)
ACBar.Size = UDim2.new(0, 50, 0, 180)
ACBar.Position = UDim2.new(0.02, 0, 0.35, 0)
ACBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ACBar.Active = true
ACBar.Draggable = true
ACBar.Visible = false

local ACBarLayout = Instance.new("UIListLayout", ACBar)
ACBarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ACBarLayout.Padding = UDim.new(0, 5)

local ACAddBtn = Instance.new("TextButton", ACBar)
ACAddBtn.Size = UDim2.new(0, 40, 0, 30)
ACAddBtn.Text = "+"
ACAddBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
ACAddBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ACAddBtn.TextSize = 18

-- Nút Xóa Điểm Cuối Nằm Ngay Dưới Nút Thêm (+)
local ACDelBtn = Instance.new("TextButton", ACBar)
ACDelBtn.Size = UDim2.new(0, 40, 0, 30)
ACDelBtn.Text = "-"
ACDelBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
ACDelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ACDelBtn.TextSize = 18

-- Nút Xóa Tất Cả Nằm Bên Dưới
local ACClearBtn = Instance.new("TextButton", ACBar)
ACClearBtn.Size = UDim2.new(0, 40, 0, 30)
ACClearBtn.Text = "🗑"
ACClearBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ACClearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local ACRunBtn = Instance.new("TextButton", ACBar)
ACRunBtn.Size = UDim2.new(0, 40, 0, 30)
ACRunBtn.Text = "▶"
ACRunBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 50)
ACRunBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local ACSettingsBtn = Instance.new("TextButton", ACBar)
ACSettingsBtn.Size = UDim2.new(0, 40, 0, 30)
ACSettingsBtn.Text = "⚙"
ACSettingsBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 0)
ACSettingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local ACSettingsFrame = Instance.new("Frame", ScreenGui)
ACSettingsFrame.Size = UDim2.new(0, 200, 0, 170)
ACSettingsFrame.Position = UDim2.new(0.08, 0, 0.35, 0)
ACSettingsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ACSettingsFrame.Visible = false
ACSettingsFrame.Active = true
ACSettingsFrame.Draggable = true

local ACLoopInfBtn = Instance.new("TextButton", ACSettingsFrame)
ACLoopInfBtn.Size = UDim2.new(0.9, 0, 0, 28)
ACLoopInfBtn.Position = UDim2.new(0.05, 0, 0.05, 0)
ACLoopInfBtn.Text = "Lặp Vô Hạn: ON"
ACLoopInfBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
ACLoopInfBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

ACLoopInfBtn.MouseButton1Click:Connect(function()
    Settings.AC_LoopInfinite = not Settings.AC_LoopInfinite
    ACLoopInfBtn.BackgroundColor3 = Settings.AC_LoopInfinite and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
    ACLoopInfBtn.Text = "Lặp Vô Hạn: " .. (Settings.AC_LoopInfinite and "ON" or "OFF")
end)

local ACDelayBox = Instance.new("TextBox", ACSettingsFrame)
ACDelayBox.Size = UDim2.new(0.9, 0, 0, 28)
ACDelayBox.Position = UDim2.new(0.05, 0, 0.28, 0)
ACDelayBox.Text = tostring(Settings.AC_Delay)
ACDelayBox.PlaceholderText = "Tốc độ nhấn (giây)"
ACDelayBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ACDelayBox.TextColor3 = Color3.fromRGB(0, 255, 255)

ACDelayBox.FocusLost:Connect(function()
    local val = tonumber(ACDelayBox.Text)
    if val then Settings.AC_Delay = math.max(0.01, val) end
end)

local ACLoopCountBox = Instance.new("TextBox", ACSettingsFrame)
ACLoopCountBox.Size = UDim2.new(0.9, 0, 0, 28)
ACLoopCountBox.Position = UDim2.new(0.05, 0, 0.51, 0)
ACLoopCountBox.Text = tostring(Settings.AC_LoopCount)
ACLoopCountBox.PlaceholderText = "Số vòng lặp"
ACLoopCountBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ACLoopCountBox.TextColor3 = Color3.fromRGB(0, 255, 255)

ACLoopCountBox.FocusLost:Connect(function()
    local val = tonumber(ACLoopCountBox.Text)
    if val then Settings.AC_LoopCount = val end
end)

local ACSizeBox = Instance.new("TextBox", ACSettingsFrame)
ACSizeBox.Size = UDim2.new(0.9, 0, 0, 28)
ACSizeBox.Position = UDim2.new(0.05, 0, 0.74, 0)
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
        end
    end
end)

ACSettingsBtn.MouseButton1Click:Connect(function()
    ACSettingsFrame.Visible = not ACSettingsFrame.Visible
end)

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

    table.insert(AutoClickPoints, {Frame = pFrame})
end

ACAddBtn.MouseButton1Click:Connect(createAutoClickPoint)

ACDelBtn.MouseButton1Click:Connect(function()
    if #AutoClickPoints > 0 then
        local last = AutoClickPoints[#AutoClickPoints]
        last.Frame:Destroy()
        table.remove(AutoClickPoints, #AutoClickPoints)
    end
end)

ACClearBtn.MouseButton1Click:Connect(function()
    for _, p in pairs(AutoClickPoints) do
        p.Frame:Destroy()
    end
    AutoClickPoints = {}
end)

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
                    task.wait(0.02)
                    VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y + 36, 0, false, game, 0)
                    task.wait(Settings.AC_Delay)
                end

                loops = loops + 1
                task.wait(0.05)
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

addSimpleToggle(MiscPage, "Bật Thanh Auto Click Nổi", function(state)
    ACBar.Visible = state
    if not state then
        ACSettingsFrame.Visible = false
        Settings.AC_Running = false
    end
end)


------------------ HỆ THỐNG WAYPOINT CAO CẤP ------------------
local WaypointList = {} -- Danh sách chứa Part + CFrame
local SavedWaypoints = {} -- Lưu vào file

local WPFolder = workspace:FindFirstChild("MobileHubWaypoints") or Instance.new("Folder", workspace)
WPFolder.Name = "MobileHubWaypoints"

local WPBar = Instance.new("Frame", ScreenGui)
WPBar.Size = UDim2.new(0, 50, 0, 180)
WPBar.Position = UDim2.new(0.92, 0, 0.35, 0)
WPBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
WPBar.Active = true
WPBar.Draggable = true
WPBar.Visible = false

local WPBarLayout = Instance.new("UIListLayout", WPBar)
WPBarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
WPBarLayout.Padding = UDim.new(0, 5)

-- Nút 1: Đặt điểm Waypoint
local WPAddBtn = Instance.new("TextButton", WPBar)
WPAddBtn.Size = UDim2.new(0, 40, 0, 30)
WPAddBtn.Text = "📍+"
WPAddBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
WPAddBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Nút 2: Chạy / Dừng Waypoint
local WPRunBtn = Instance.new("TextButton", WPBar)
WPRunBtn.Size = UDim2.new(0, 40, 0, 30)
WPRunBtn.Text = "▶"
WPRunBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 50)
WPRunBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Nút 3: Xóa điểm cuối
local WPDelBtn = Instance.new("TextButton", WPBar)
WPDelBtn.Size = UDim2.new(0, 40, 0, 30)
WPDelBtn.Text = "📍-"
WPDelBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
WPDelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Nút 4: Xóa hết điểm
local WPClearBtn = Instance.new("TextButton", WPBar)
WPClearBtn.Size = UDim2.new(0, 40, 0, 30)
WPClearBtn.Text = "🗑"
WPClearBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
WPClearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Nút 5: Cài đặt Waypoint
local WPSettingsBtn = Instance.new("TextButton", WPBar)
WPSettingsBtn.Size = UDim2.new(0, 40, 0, 30)
WPSettingsBtn.Text = "⚙"
WPSettingsBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 0)
WPSettingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local WPSettingsFrame = Instance.new("Frame", ScreenGui)
WPSettingsFrame.Size = UDim2.new(0, 210, 0, 120)
WPSettingsFrame.Position = UDim2.new(0.78, 0, 0.35, 0)
WPSettingsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
WPSettingsFrame.Visible = false
WPSettingsFrame.Active = true
WPSettingsFrame.Draggable = true

local WPModeBtn = Instance.new("TextButton", WPSettingsFrame)
WPModeBtn.Size = UDim2.new(0.9, 0, 0, 35)
WPModeBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
WPModeBtn.Text = "Chế độ: Bay Waypoint"
WPModeBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
WPModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local WPSpeedBox = Instance.new("TextBox", WPSettingsFrame)
WPSpeedBox.Size = UDim2.new(0.9, 0, 0, 35)
WPSpeedBox.Position = UDim2.new(0.05, 0, 0.5, 0)
WPSpeedBox.Text = tostring(Settings.WP_FlySpeed)
WPSpeedBox.PlaceholderText = "Tốc độ bay (Studs/s)"
WPSpeedBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
WPSpeedBox.TextColor3 = Color3.fromRGB(0, 255, 255)

WPSpeedBox.FocusLost:Connect(function()
    local val = tonumber(WPSpeedBox.Text)
    if val then Settings.WP_FlySpeed = math.max(5, val) end
end)

WPModeBtn.MouseButton1Click:Connect(function()
    if Settings.WP_Mode == "Fly" then
        Settings.WP_Mode = "Teleport"
        WPModeBtn.Text = "Chế độ: Dịch Chuyển WP"
        WPSpeedBox.Visible = false
    else
        Settings.WP_Mode = "Fly"
        WPModeBtn.Text = "Chế độ: Bay Waypoint"
        WPSpeedBox.Visible = true
    end
end)

WPSettingsBtn.MouseButton1Click:Connect(function()
    WPSettingsFrame.Visible = not WPSettingsFrame.Visible
end)

-- Tạo cột Cờ Waypoint ảo
local function createWaypointVisual(cframe, index)
    local pole = Instance.new("Part")
    pole.Name = "WP_" .. tostring(index)
    pole.Size = Vector3.new(0.4, 8, 0.4)
    pole.CFrame = cframe
    pole.Anchored = true
    pole.CanCollide = false
    pole.Material = Enum.Material.SmoothPlastic
    pole.Color = Color3.fromRGB(255, 255, 255)
    pole.Transparency = 0.2
    pole.Parent = WPFolder

    local bb = Instance.new("BillboardGui", pole)
    bb.Size = UDim2.new(0, 80, 0, 30)
    bb.AlwaysOnTop = true
    bb.ExtentsOffset = Vector3.new(0, 4.5, 0)

    local txt = Instance.new("TextLabel", bb)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Text = "WP " .. tostring(index)
    txt.TextColor3 = Color3.fromRGB(0, 255, 255)
    txt.TextScaled = true
    txt.Font = Enum.Font.SourceSansBold

    return pole
end

WPAddBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local cf = char.HumanoidRootPart.CFrame
        local index = #WaypointList + 1
        local pole = createWaypointVisual(cf, index)
        table.insert(WaypointList, {CFrame = cf, Part = pole})
    end
end)

WPDelBtn.MouseButton1Click:Connect(function()
    if #WaypointList > 0 then
        local last = WaypointList[#WaypointList]
        if last.Part then last.Part:Destroy() end
        table.remove(WaypointList, #WaypointList)
    end
end)

WPClearBtn.MouseButton1Click:Connect(function()
    for _, wp in pairs(WaypointList) do
        if wp.Part then wp.Part:Destroy() end
    end
    WaypointList = {}
end)

-- Chạy/Dừng Waypoint Loop
WPRunBtn.MouseButton1Click:Connect(function()
    if #WaypointList == 0 then return end
    Settings.WP_Running = not Settings.WP_Running

    if Settings.WP_Running then
        WPRunBtn.Text = "⏹"
        WPRunBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)

        task.spawn(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            while Settings.WP_Running do
                for i, wp in ipairs(WaypointList) do
                    if not Settings.WP_Running or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then break end
                    
                    hrp = LocalPlayer.Character.HumanoidRootPart

                    if Settings.WP_Mode == "Teleport" then
                        hrp.CFrame = wp.CFrame
                        task.wait(0.2)
                    elseif Settings.WP_Mode == "Fly" then
                        local distance = (hrp.Position - wp.CFrame.Position).Magnitude
                        local duration = distance / Settings.WP_FlySpeed
                        
                        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
                        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = wp.CFrame})
                        
                        tween:Play()
                        
                        local completed = false
                        local conn
                        conn = tween.Completed:Connect(function()
                            completed = true
                            if conn then conn:Disconnect() end
                        end)

                        while not completed and Settings.WP_Running do
                            task.wait(0.05)
                        end
                        if not Settings.WP_Running then
                            tween:Cancel()
                            break
                        end
                    end
                end
                task.wait(0.1)
            end

            Settings.WP_Running = false
            WPRunBtn.Text = "▶"
            WPRunBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 50)
        end)
    else
        WPRunBtn.Text = "▶"
        WPRunBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 50)
    end
end)

addSimpleToggle(MiscPage, "Bật Thanh Waypoint Nổi", function(state)
    WPBar.Visible = state
    if not state then
        WPSettingsFrame.Visible = false
        Settings.WP_Running = false
    end
end)


------------------ LƯU / TẢI BẢN LƯU WAYPOINT MAP ------------------
local SaveFrame = Instance.new("Frame", MiscPage)
SaveFrame.Size = UDim2.new(0.98, 0, 0, 180)
SaveFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local SaveNameBox = Instance.new("TextBox", SaveFrame)
SaveNameBox.Size = UDim2.new(0.65, 0, 0, 30)
SaveNameBox.Position = UDim2.new(0.02, 0, 0.05, 0)
SaveNameBox.PlaceholderText = "Nhập tên bản lưu Waypoint..."
SaveNameBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SaveNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)

local SaveActionBtn = Instance.new("TextButton", SaveFrame)
SaveActionBtn.Size = UDim2.new(0.28, 0, 0, 30)
SaveActionBtn.Position = UDim2.new(0.69, 0, 0.05, 0)
SaveActionBtn.Text = "Lưu Bản Vẽ"
SaveActionBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
SaveActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local SaveScroll = Instance.new("ScrollingFrame", SaveFrame)
SaveScroll.Position = UDim2.new(0.02, 0, 0.28, 0)
SaveScroll.Size = UDim2.new(0.96, 0, 0.68, 0)
SaveScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
SaveScroll.CanvasSize = UDim2.new(0, 0, 5, 0)

local SaveLayout = Instance.new("UIListLayout", SaveScroll)
SaveLayout.Padding = UDim.new(0, 5)

local function getFileName()
    return "MobileHub_WP_" .. tostring(game.PlaceId) .. ".json"
end

local function loadSavesFromFile()
    if isfile and isfile(getFileName()) then
        local content = readfile(getFileName())
        local success, data = pcall(function() return HttpService:JSONDecode(content) end)
        if success and data then
            return data
        end
    end
    return {}
end

local function saveSavesToFile(data)
    if writefile then
        writefile(getFileName(), HttpService:JSONEncode(data))
    end
end

local function renderSaveList()
    for _, item in pairs(SaveScroll:GetChildren()) do
        if not item:IsA("UIListLayout") then item:Destroy() end
    end

    local saves = loadSavesFromFile()

    for saveName, cfDataList in pairs(saves) do
        local item = Instance.new("Frame", SaveScroll)
        item.Size = UDim2.new(1, -5, 0, 45)
        item.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

        local img = Instance.new("ImageLabel", item)
        img.Size = UDim2.new(0, 40, 0, 40)
        img.Position = UDim2.new(0, 2, 0, 2)
        pcall(function()
            img.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
            img.Image = "https://www.roblox.com/asset-thumbnail/image?assetId=" .. game.PlaceId .. "&width=420&height=420&format=png"
        end)

        local nameLbl = Instance.new("TextLabel", item)
        nameLbl.Position = UDim2.new(0, 48, 0, 2)
        nameLbl.Size = UDim2.new(0.45, 0, 0.9, 0)
        nameLbl.Text = saveName .. "\n(" .. #cfDataList .. " Điểm)"
        nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.TextScaled = true

        local loadBtn = Instance.new("TextButton", item)
        loadBtn.Position = UDim2.new(0.68, 0, 0.15, 0)
        loadBtn.Size = UDim2.new(0.14, 0, 0.7, 0)
        loadBtn.Text = "Load"
        loadBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 50)
        loadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

        loadBtn.MouseButton1Click:Connect(function()
            -- Clear hiện tại
            for _, wp in pairs(WaypointList) do if wp.Part then wp.Part:Destroy() end end
            WaypointList = {}

            -- Load dữ liệu
            for i, cfTable in ipairs(cfDataList) do
                local cf = CFrame.new(unpack(cfTable))
                local pole = createWaypointVisual(cf, i)
                table.insert(WaypointList, {CFrame = cf, Part = pole})
            end
        end)

        local delBtn = Instance.new("TextButton", item)
        delBtn.Position = UDim2.new(0.83, 0, 0.15, 0)
        delBtn.Size = UDim2.new(0.14, 0, 0.7, 0)
        delBtn.Text = "Xóa"
        delBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

        delBtn.MouseButton1Click:Connect(function()
            saves[saveName] = nil
            saveSavesToFile(saves)
            renderSaveList()
        end)
    end
end

SaveActionBtn.MouseButton1Click:Connect(function()
    local text = SaveNameBox.Text
    if text == "" or #WaypointList == 0 then return end

    local saves = loadSavesFromFile()
    local cfDataList = {}

    for _, wp in ipairs(WaypointList) do
        table.insert(cfDataList, {wp.CFrame:GetComponents()})
    end

    saves[text] = cfDataList
    saveSavesToFile(saves)
    SaveNameBox.Text = ""
    renderSaveList()
end)

renderSaveList()


---------------------------------------------------------
-- HỆ THỐNG ESP & GAMEPLAY LOOP FIX
---------------------------------------------------------
UserInputService.JumpRequest:Connect(function()
    if Settings.InfJumpActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

local function getHealthColor(percent)
    if percent >= 0.99 then
        return Color3.fromRGB(0, 255, 0)
    elseif percent >= 0.75 then
        return Color3.fromRGB(153, 255, 0)
    elseif percent >= 0.50 then
        return Color3.fromRGB(255, 255, 0)
    elseif percent >= 0.35 then
        return Color3.fromRGB(255, 128, 0)
    else
        return Color3.fromRGB(255, 0, 0)
    end
end

local function ensureESP(p)
    if p == LocalPlayer or not p.Character then return end
    local char = p.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local hl = char:FindFirstChild("ESP_Highlight")
    if not hl then
        hl = Instance.new("Highlight", char)
        hl.Name = "ESP_Highlight"
        hl.Enabled = false
    end

    local bb = hrp:FindFirstChild("ESP_Billboard")
    if not bb then
        bb = Instance.new("BillboardGui", hrp)
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
end

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- ESP Loop
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            ensureESP(p)
            
            local char = p.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")

            if hum and hrp then
                local hl = char:FindFirstChild("ESP_Highlight")
                local bb = hrp:FindFirstChild("ESP_Billboard")
                local isTarget = (p == targetSelectedPlayer and targetESPActive)

                if hl then
                    hl.Enabled = Settings.ESP_Highlight or Settings.ESP_Full or isTarget
                end

                if bb then
                    local txtName = bb:FindFirstChild("NameLabel")
                    local txtHP = bb:FindFirstChild("HPLabel")
                    
                    bb.Enabled = Settings.ESP_Name or Settings.ESP_Full or isTarget

                    local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    local currentColor = getHealthColor(hpPercent)

                    if txtName and txtHP then
                        txtName.Text = p.DisplayName
                        txtName.TextColor3 = currentColor

                        if Settings.ESP_Full or isTarget then
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
    end

    -- Movement Mechanic & Shift Lock Fix
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")

        if Settings.WalkSpeedActive then hum.WalkSpeed = Settings.WalkSpeedVal end
        if Settings.JumpPowerActive then
            hum.UseJumpPower = true
            hum.JumpPower = Settings.JumpPowerVal
        end
        if Settings.GravityActive then workspace.Gravity = Settings.GravityVal end

        -- Shift Lock Camera Control chuẩn PC
        if shiftLockEnabled and hrp then
            hum.AutoRotate = false
            local lookPos = Camera.CFrame.LookVector
            local rootPos = hrp.Position
            hrp.CFrame = CFrame.new(rootPos, rootPos + Vector3.new(lookPos.X, 0, lookPos.Z))
            
            Camera.CFrame = Camera.CFrame * CFrame.new(1.7, 0, 0)
        else
            hum.AutoRotate = true
        end
    end

    -- Aimbot Loop
    if Settings.AimbotMode ~= "None" then
        local target = nil
        local shortestDist = math.huge
        local lowestHP = math.huge
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") then
                local pChar = player.Character
                local pHum = pChar:FindFirstChildOfClass("Humanoid")
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
