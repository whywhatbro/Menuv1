-- Roblox Mobile Hub - Fix Tuyệt Đối Cho Mọi Executor Mobile
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
    
    TargetPlayerName = "",
    AC_Delay = 0.1,
    AC_Running = false
}

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
-- TẠO KHUNG MENU CHÍNH
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
if TargetParent:FindFirstChild("UltimateMobileHubFixed") then
    TargetParent.UltimateMobileHubFixed:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltimateMobileHubFixed"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = TargetParent

-- Nút Bật/Tắt Menu Chính
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 90, 0, 35)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.15, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleBtn.Text = "MENU HUB"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 0)
ToggleBtn.TextSize = 13
ToggleBtn.Active = true
ToggleBtn.Draggable = true

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 460, 0, 260)
MainFrame.Position = UDim2.new(0.5, -230, 0.4, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Draggable = true

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 170, 255)
MainStroke.Thickness = 2

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Tiêu đề
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Color3.fromRGB(10, 10, 10)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Text = "   MOBILE HUB (HARD-FIXED)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left

---------------------------------------------------------
-- CẤU TRÚC TAB KHÔNG DÙNG SCROLLING DỄ LỖI
---------------------------------------------------------
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Position = UDim2.new(0, 5, 0, 35)
TabBar.Size = UDim2.new(0, 450, 0, 30)
TabBar.BackgroundTransparency = 1

local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Position = UDim2.new(0, 5, 0, 70)
ContentArea.Size = UDim2.new(0, 450, 0, 185)
ContentArea.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

local Pages = {}
local TabBtns = {}
local tabNames = {"SERVER", "COMBAT", "MOVE", "ESP", "WORLD", "TỔNG HỢP"}

for i, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton", TabBar)
    btn.Size = UDim2.new(0, 72, 1, 0)
    btn.Position = UDim2.new(0, (i - 1) * 75, 0, 0)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.TextSize = 10

    local page = Instance.new("ScrollingFrame", ContentArea)
    page.Size = UDim2.new(1, -10, 1, -10)
    page.Position = UDim2.new(0, 5, 0, 5)
    page.BackgroundTransparency = 1
    page.Visible = (i == 1)
    page.CanvasSize = UDim2.new(0, 0, 0, 400) -- Chiều cao cố định đảm bảo cuộn bình thường
    page.ScrollBarThickness = 4

    local layout = Instance.new("UIListLayout", page)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)

    Pages[name] = page
    table.insert(TabBtns, btn)

    if i == 1 then
        btn.TextColor3 = Color3.fromRGB(255, 255, 0)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end

    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, b in pairs(TabBtns) do
            b.TextColor3 = Color3.fromRGB(180, 180, 180)
            b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        end
        page.Visible = true
        btn.TextColor3 = Color3.fromRGB(255, 255, 0)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end)
end

---------------------------------------------------------
-- TẠO CÁC NÚT BẤM VÀ CÔNG CỤ
---------------------------------------------------------
local function addToggleWithInput(page, name, defaultVal, onToggle, onValChange)
    local frame = Instance.new("Frame", page)
    frame.Size = UDim2.new(0, 420, 0, 32)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 200, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)

    local txt = Instance.new("TextBox", frame)
    txt.Position = UDim2.new(0, 210, 0, 0)
    txt.Size = UDim2.new(0, 200, 1, 0)
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
    btn.Size = UDim2.new(0, 420, 0, 30)
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
-- NỘI DUNG TỪNG TAB
---------------------------------------------------------
-- 1. TAB SERVER
local RejoinBtn = Instance.new("TextButton", Pages["SERVER"])
RejoinBtn.Size = UDim2.new(0, 420, 0, 30)
RejoinBtn.Text = "Rejoin Server"
RejoinBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
RejoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RejoinBtn.MouseButton1Click:Connect(function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

local HopBtn = Instance.new("TextButton", Pages["SERVER"])
HopBtn.Size = UDim2.new(0, 420, 0, 30)
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

-- 2. TAB COMBAT
addSimpleToggle(Pages["COMBAT"], "Aim Gần Nhất", function(val) Settings.AimbotMode = val and "Closest" or "None" end)

local AimFOVToggle = Instance.new("TextButton", Pages["COMBAT"])
AimFOVToggle.Size = UDim2.new(0, 420, 0, 30)
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

-- 3. TAB MOVE
addToggleWithInput(Pages["MOVE"], "Chạy Nhanh", Settings.WalkSpeedVal, function(state) Settings.WalkSpeedActive = state end, function(val) Settings.WalkSpeedVal = val end)
addToggleWithInput(Pages["MOVE"], "Nhảy Cao", Settings.JumpPowerVal, function(state) Settings.JumpPowerActive = state end, function(val) Settings.JumpPowerVal = val end)
addToggleWithInput(Pages["MOVE"], "Trọng Lực", Settings.GravityVal, function(state) Settings.GravityActive = state end, function(val) Settings.GravityVal = val end)
addSimpleToggle(Pages["MOVE"], "Nhảy Vô Hạn", function(state) Settings.InfJumpActive = state end)

addSimpleToggle(Pages["MOVE"], "Bật Script Bay (FlyGui V3)", function(state)
    if state then
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
        end)
    end
end)

addSimpleToggle(Pages["MOVE"], "Bật Shift Lock Universal", function(state)
    if state then
        pcall(function()
            loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Shift-Lock-121871"))()
        end)
    end
end)

-- 4. TAB ESP
addSimpleToggle(Pages["ESP"], "ESP Viền Sáng (Highlight)", function(val) Settings.ESP_Highlight = val end)
addSimpleToggle(Pages["ESP"], "Full Bright (Sáng Màn Hình)", function(val)
    Settings.FullBrightActive = val
    Lighting.Ambient = val and Color3.new(1,1,1) or Color3.fromRGB(127,127,127)
    Lighting.GlobalShadows = not val
end)

-- 5. TAB WORLD
local AntiLagBtn = Instance.new("TextButton", Pages["WORLD"])
AntiLagBtn.Size = UDim2.new(0, 420, 0, 30)
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

-- 6. TAB TỔNG HỢP (AUTO CLICK)
local ACBar = Instance.new("Frame", ScreenGui)
ACBar.Size = UDim2.new(0, 50, 0, 100)
ACBar.Position = UDim2.new(0.02, 0, 0.35, 0)
ACBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ACBar.Active = true
ACBar.Draggable = true
ACBar.Visible = false

local ACBarLayout = Instance.new("UIListLayout", ACBar)
ACBarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ACBarLayout.Padding = UDim.new(0, 5)

local AutoClickPoints = {}
local ACAddBtn = Instance.new("TextButton", ACBar)
ACAddBtn.Size = UDim2.new(0, 40, 0, 40)
ACAddBtn.Text = "+"
ACAddBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)

local ACRunBtn = Instance.new("TextButton", ACBar)
ACRunBtn.Size = UDim2.new(0, 40, 0, 40)
ACRunBtn.Text = "▶"
ACRunBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 50)

ACAddBtn.MouseButton1Click:Connect(function()
    local id = #AutoClickPoints + 1
    local pFrame = Instance.new("Frame", ScreenGui)
    pFrame.Size = UDim2.new(0, 35, 0, 35)
    pFrame.Position = UDim2.new(0.5, -17, 0.5, -17)
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

addSimpleToggle(Pages["TỔNG HỢP"], "Bật Thanh Auto Click Nổi", function(state)
    ACBar.Visible = state
end)

---------------------------------------------------------
-- ENGINE LOOP
---------------------------------------------------------
UserInputService.JumpRequest:Connect(function()
    if Settings.InfJumpActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

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

    if Settings.ESP_Highlight then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                if not p.Character:FindFirstChild("ESPHl") then
                    local hl = Instance.new("Highlight", p.Character)
                    hl.Name = "ESPHl"
                    hl.FillColor = Color3.fromRGB(0, 255, 0)
                end
            end
        end
    end

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
