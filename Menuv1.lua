-- Roblox Mobile Hub - Ultimate Custom Edition (Fixed Engine Render V3)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")

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
    
    InfJumpActive = false,
    GravityActive = false,
    GravityVal = 196.2,
    
    FullBrightActive = false,
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
-- KHUNG GIAO DIỆN CHÍNH
---------------------------------------------------------
local function GetSafeParent()
    local success, parent = pcall(function()
        if gethui then return gethui() end
        return game:GetService("CoreGui")
    end)
    if success and parent then return parent end
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
MainFrame.Size = UDim2.new(0, 480, 0, 270)
MainFrame.Position = UDim2.new(0.5, -240, 0.4, -135)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Draggable = true

local MainFrameStroke = Instance.new("UIStroke", MainFrame)
MainFrameStroke.Color = Color3.fromRGB(0, 170, 255)
MainFrameStroke.Thickness = 3

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
Title.Text = "MOBILE ADVANCED HUB (FIXED V3)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left

---------------------------------------------------------
-- FIX RENDER NỘI DUNG TAB (V3 ENGINE FIX)
---------------------------------------------------------
local TabBarScroll = Instance.new("ScrollingFrame", MainFrame)
TabBarScroll.Position = UDim2.new(0, 0, 0, 30)
TabBarScroll.Size = UDim2.new(1, 0, 0, 35)
TabBarScroll.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TabBarScroll.ScrollBarThickness = 2
TabBarScroll.ScrollingDirection = Enum.ScrollingDirection.Horizontal
TabBarScroll.CanvasSize = UDim2.new(0, 600, 0, 0)

local TabLayout = Instance.new("UIListLayout", TabBarScroll)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 4)

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Position = UDim2.new(0, 0, 0, 65)
ContentFrame.Size = UDim2.new(1, 0, 1, -65)
ContentFrame.BackgroundTransparency = 1

local Pages = {}
local TabButtons = {}

local function createTab(name, order)
    local btn = Instance.new("TextButton", TabBarScroll)
    btn.Size = UDim2.new(0, 80, 1, 0)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.TextSize = 11
    btn.LayoutOrder = order

    local page = Instance.new("ScrollingFrame", ContentFrame)
    page.Size = UDim2.new(1, -10, 1, -10)
    page.Position = UDim2.new(0, 5, 0, 5)
    page.BackgroundTransparency = 1
    page.Visible = (order == 1)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.ScrollBarThickness = 5

    local layout = Instance.new("UIListLayout", page)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)

    Pages[name] = page
    table.insert(TabButtons, btn)

    if order == 1 then
        btn.TextColor3 = Color3.fromRGB(255, 255, 0)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end

    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, b in pairs(TabButtons) do
            b.TextColor3 = Color3.fromRGB(180, 180, 180)
            b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        end
        page.Visible = true
        btn.TextColor3 = Color3.fromRGB(255, 255, 0)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
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
-- CÁC HÀM TẠO WIDGET NÚT BẤM (CHẮC CHẮN HIỂN THỊ)
---------------------------------------------------------
local function addToggleWithInput(page, name, defaultVal, onToggle, onValChange)
    local frame = Instance.new("Frame", page)
    frame.Size = UDim2.new(0.96, 0, 0, 35)
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
    btn.Size = UDim2.new(0.96, 0, 0, 32)
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
ServerAgeLabel.Size = UDim2.new(0.96, 0, 0, 25)
ServerAgeLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ServerAgeLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
ServerAgeLabel.Text = "Đang tải thời gian Server..."

task.spawn(function()
    while task.wait(1) do
        local diff = os.time() - ServerStartTime
        local d = math.floor(diff / 86400)
        local h = math.floor((diff % 86400) / 3600)
        local m = math.floor((diff % 3600) / 60)
        local s = diff % 60
        ServerAgeLabel.Text = string.format("Tuổi Server: %dd %dh %dm %ds", d, h, m, s)
    end
end)

local RejoinBtn = Instance.new("TextButton", ServerPage)
RejoinBtn.Size = UDim2.new(0.96, 0, 0, 32)
RejoinBtn.Text = "Rejoin Server"
RejoinBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
RejoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RejoinBtn.MouseButton1Click:Connect(function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

local HopBtn = Instance.new("TextButton", ServerPage)
HopBtn.Size = UDim2.new(0.96, 0, 0, 32)
HopBtn.Text = "Hop Server (Ngẫu nhiên)"
HopBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
HopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
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

---------------------------------------------------------
-- 2. TAB COMBAT
---------------------------------------------------------
addSimpleToggle(CombatPage, "Aim Người Gần Nhất", function(val) Settings.AimbotMode = val and "Closest" or "None" end)
addSimpleToggle(CombatPage, "Aim Ít Máu Nhất", function(val) Settings.AimbotMode = val and "LowestHealth" or "None" end)

local AimFOVToggle = Instance.new("TextButton", CombatPage)
AimFOVToggle.Size = UDim2.new(0.96, 0, 0, 32)
AimFOVToggle.Text = "Aim Vòng Tròn (FOV): OFF"
AimFOVToggle.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
AimFOVToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AimFOVToggle.MouseButton1Click:Connect(function()
    if Settings.AimbotMode == "FOV" then
        Settings.AimbotMode = "None"
        FOVCircle.Visible = false
        AimFOVToggle.Text = "Aim Vòng Tròn (FOV): OFF"
        AimFOVToggle.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    else
        Settings.AimbotMode = "FOV"
        FOVCircle.Visible = true
        AimFOVToggle.Text = "Aim Vòng Tròn (FOV): ON"
        AimFOVToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    end
end)

---------------------------------------------------------
-- 3. TAB MOVEMENT & SHIFT LOCK
---------------------------------------------------------
addToggleWithInput(MovePage, "Chạy Nhanh", Settings.WalkSpeedVal, function(state) Settings.WalkSpeedActive = state end, function(val) Settings.WalkSpeedVal = val end)
addToggleWithInput(MovePage, "Nhảy Cao", Settings.JumpPowerVal, function(state) Settings.JumpPowerActive = state end, function(val) Settings.JumpPowerVal = val end)
addToggleWithInput(MovePage, "Trọng Lực", Settings.GravityVal, function(state) Settings.GravityActive = state end, function(val) Settings.GravityVal = val end)
addSimpleToggle(MovePage, "Nhảy Vô Hạn", function(state) Settings.InfJumpActive = state end)

addSimpleToggle(MovePage, "Bật Script Bay (FlyGui V3)", function(state)
    if state then
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
        end)
    end
end)

addSimpleToggle(MovePage, "Bật Shift Lock Universal", function(state)
    if state then
        pcall(function()
            loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Shift-Lock-121871"))()
        end)
    end
end)

---------------------------------------------------------
-- 4. TAB VISUAL (ESP)
---------------------------------------------------------
addSimpleToggle(VisualPage, "ESP Tên Người Chơi", function(val) Settings.ESP_Name = val end)
addSimpleToggle(VisualPage, "ESP Viền Sáng (Highlight)", function(val) Settings.ESP_Highlight = val end)
addSimpleToggle(VisualPage, "Full ESP (Tên + Máu)", function(val) Settings.ESP_Full = val end)
addSimpleToggle(VisualPage, "Full Bright (Sáng Màn Hình)", function(val)
    Settings.FullBrightActive = val
    Lighting.Ambient = val and Color3.new(1,1,1) or Color3.fromRGB(127,127,127)
    Lighting.GlobalShadows = not val
end)

---------------------------------------------------------
-- 5. TAB WORLD
---------------------------------------------------------
addSimpleToggle(WorldPage, "Xóa Sương Mù (Remove Fog)", function(val)
    if val then
        Lighting.FogEnd = 9e9
    else
        Lighting.FogEnd = 1000
    end
end)

local AntiLagBtn = Instance.new("TextButton", WorldPage)
AntiLagBtn.Size = UDim2.new(0.96, 0, 0, 32)
AntiLagBtn.Text = "Giảm Lag (FPS Boost)"
AntiLagBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
AntiLagBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AntiLagBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v:Destroy()
        end
    end
    AntiLagBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    AntiLagBtn.Text = "Đã Xử Lý Giảm Lag!"
end)

---------------------------------------------------------
-- 6. TAB PLAYER
---------------------------------------------------------
local SearchBox = Instance.new("TextBox", PlayerPage)
SearchBox.Size = UDim2.new(0.96, 0, 0, 32)
SearchBox.PlaceholderText = "Nhập tên người chơi..."
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 0)
SearchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

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
end)

local TeleBtn = Instance.new("TextButton", PlayerPage)
TeleBtn.Size = UDim2.new(0.96, 0, 0, 32)
TeleBtn.Text = "Teleport Đến Người Chơi"
TeleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TeleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleBtn.MouseButton1Click:Connect(function()
    if targetSelectedPlayer and targetSelectedPlayer.Character and targetSelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = targetSelectedPlayer.Character.HumanoidRootPart.CFrame
    end
end)

---------------------------------------------------------
-- 7. TAB TỔNG HỢP (AUTO CLICK & WAYPOINT)
---------------------------------------------------------
local AutoClickPoints = {}

local ACBar = Instance.new("Frame", ScreenGui)
ACBar.Size = UDim2.new(0, 50, 0, 150)
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

local ACRunBtn = Instance.new("TextButton", ACBar)
ACRunBtn.Size = UDim2.new(0, 40, 0, 30)
ACRunBtn.Text = "▶"
ACRunBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 50)

ACAddBtn.MouseButton1Click:Connect(function()
    local id = #AutoClickPoints + 1
    local pFrame = Instance.new("Frame", ScreenGui)
    pFrame.Size = UDim2.new(0, 40, 0, 40)
    pFrame.Position = UDim2.new(0.5, -20, 0.5, -20)
    pFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    pFrame.BackgroundTransparency = 0.5
    pFrame.Active = true
    pFrame.Draggable = true

    local lbl = Instance.new("TextLabel", pFrame)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.Text = tostring(id)
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)

    table.insert(AutoClickPoints, {Frame = pFrame})
end)

ACRunBtn.MouseButton1Click:Connect(function()
    Settings.AC_Running = not Settings.AC_Running
    if Settings.AC_Running then
        ACRunBtn.Text = "⏹"
        task.spawn(function()
            while Settings.AC_Running do
                for _, p in ipairs(AutoClickPoints) do
                    if not Settings.AC_Running then break end
                    local pos = p.Frame.AbsolutePosition + (p.Frame.AbsoluteSize / 2)
                    VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y + 36, 0, true, game, 0)
                    task.wait(0.02)
                    VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y + 36, 0, false, game, 0)
                    task.wait(Settings.AC_Delay)
                end
                task.wait(0.05)
            end
        end)
    else
        ACRunBtn.Text = "▶"
    end
end)

addSimpleToggle(MiscPage, "Bật Thanh Auto Click Nổi", function(state)
    ACBar.Visible = state
end)

---------------------------------------------------------
-- ENGINE LOOP (RENDER & ESP)
---------------------------------------------------------
UserInputService.JumpRequest:Connect(function()
    if Settings.InfJumpActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- Cập nhật WalkSpeed / JumpPower / Gravity
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if Settings.WalkSpeedActive then hum.WalkSpeed = Settings.WalkSpeedVal end
        if Settings.JumpPowerActive then
            hum.UseJumpPower = true
            hum.JumpPower = Settings.JumpPowerVal
        end
        if Settings.GravityActive then workspace.Gravity = Settings.GravityVal end
    end

    -- Xử lý Aimbot
    if Settings.AimbotMode ~= "None" then
        local target = nil
        local shortestDist = math.huge

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local pHrp = player.Character.HumanoidRootPart
                local pos, onScreen = Camera:WorldToViewportPoint(pHrp.Position)
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude

                if Settings.AimbotMode == "FOV" and onScreen and dist <= Settings.FOVRadius then
                    if dist < shortestDist then
                        shortestDist = dist
                        target = pHrp
                    end
                elseif Settings.AimbotMode == "Closest" then
                    local pDist = (pHrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if pDist < shortestDist then
                        shortestDist = pDist
                        target = pHrp
                    end
                end
            end
        end

        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)
