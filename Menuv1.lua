-- Roblox Mobile Hub - Extended UI Edition
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Lưu trữ trạng thái & Thông số cài đặt
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
    
    FullBrightActive = false,
    UnlockCamActive = false,
    
    -- ESP Tùy chỉnh
    ESP_Name = false,
    ESP_Highlight = false,
    ESP_Full = false,
    
    TargetPlayerName = ""
}

local ServerStartTime = os.time()

-- Anti AFK
LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

-- Vòng tròn FOV Aimbot Cố Định Ở Chính Giữa Màn Hình
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 50, 50)
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = false

-- UI Setup (Khung Nằm Ngang & Nút Nổi Kéo Thả)
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "UltimateMobileHub"
ScreenGui.ResetOnSpawn = false

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
MainFrame.Size = UDim2.new(0, 500, 0, 240)
MainFrame.Position = UDim2.new(0.5, -250, 0.4, -120)
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

-- Navigation Bar (5 Tab)
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
    btn.Size = UDim2.new(1/5, 0, 1, 0)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextSize = 11

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

-- Tạo 5 Tabs (Server nằm ở vị trí đầu tiên)
local ServerPage  = createTab("SERVER", 1)
local CombatPage  = createTab("COMBAT", 2)
local MovePage    = createTab("MOVEMENT", 3)
local VisualPage  = createTab("ESP", 4)
local PlayerPage  = createTab("PLAYER", 5)

---------------------------------------------------------
-- CÁC COMPONENT UI (Nút Bật/Tắt & Hiển thị thông số)
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
-- 2. TAB COMBAT (AIMBOT)
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
-- 3. TAB MOVEMENT
---------------------------------------------------------
addToggleWithInput(MovePage, "Chạy Nhanh", Settings.WalkSpeedVal, function(state) Settings.WalkSpeedActive = state end, function(val) Settings.WalkSpeedVal = val end)
addToggleWithInput(MovePage, "Nhảy Cao", Settings.JumpPowerVal, function(state) Settings.JumpPowerActive = state end, function(val) Settings.JumpPowerVal = val end)
addToggleWithInput(MovePage, "Bay (Joysticks Directional)", Settings.FlySpeed, function(state) Settings.FlyActive = state end, function(val) Settings.FlySpeed = val end)
addToggleWithInput(MovePage, "Trọng Lực (Gravity)", Settings.GravityVal, function(state) Settings.GravityActive = state end, function(val) Settings.GravityVal = val end)
addSimpleToggle(MovePage, "Nhảy Vô Hạn", function(state) Settings.InfJumpActive = state end)

---------------------------------------------------------
-- 4. TAB VISUAL (ESP)
---------------------------------------------------------
addSimpleToggle(VisualPage, "ESP Tên", function(val) Settings.ESP_Name = val end)
addSimpleToggle(VisualPage, "ESP Viền Sáng", function(val) Settings.ESP_Highlight = val end)
addSimpleToggle(VisualPage, "Full ESP (Auto Đổi Màu Theo Máu)", function(val) Settings.ESP_Full = val end)
addSimpleToggle(VisualPage, "Full Bright (Sáng Toàn Màn Hình)", function(val)
    Settings.FullBrightActive = val
    Lighting.Ambient = val and Color3.new(1,1,1) or Color3.fromRGB(127,127,127)
    Lighting.GlobalShadows = not val
end)
addSimpleToggle(VisualPage, "Mở Khoá Góc Nhìn Camera", function(val)
    LocalPlayer.CameraMaxZoomDistance = val and 99999 or 128
end)

---------------------------------------------------------
-- 5. TAB PLAYER (PROFILE & TARGETING)
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
SearchBox.PlaceholderText = "Nhập tên hoặc tên tắt người chơi..."
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
        local ageInDays = targetSelectedPlayer.AccountAge
        InfoLabel.Text = string.format("Tên: %s\n@User: %s\nTuổi Acc: %d ngày", targetSelectedPlayer.DisplayName, targetSelectedPlayer.Name, ageInDays)
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

local AimTargetBtn = Instance.new("TextButton", PlayerPage)
AimTargetBtn.Size = UDim2.new(0.98, 0, 0, 30)
AimTargetBtn.Text = "Aim Người Chơi Này"
AimTargetBtn.MouseButton1Click:Connect(function()
    if targetSelectedPlayer and targetSelectedPlayer.Character and targetSelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetSelectedPlayer.Character.HumanoidRootPart.Position)
    end
end)

local ViewPlayerBtn = Instance.new("TextButton", PlayerPage)
ViewPlayerBtn.Size = UDim2.new(0.98, 0, 0, 30)
ViewPlayerBtn.Text = "Xem Góc Nhìn Người Chơi (Toggle)"
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
TargetESPBtn.Text = "Full ESP Người Chơi Này (Độc Lập)"
local targetESPActive = false
TargetESPBtn.MouseButton1Click:Connect(function()
    targetESPActive = not targetESPActive
    TargetESPBtn.BackgroundColor3 = targetESPActive and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
end)

---------------------------------------------------------
-- CÁC VÒNG LẶP HỆ THỐNG XỬ LÝ GAMEPLAY
---------------------------------------------------------

-- 1. Nhảy vô hạn
UserInputService.JumpRequest:Connect(function()
    if Settings.InfJumpActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- 2. Hệ Thống ESP Tự Động (Bao Gồm Người Mới Tải/Hồi Sinh)
local function applyESP(p)
    if p == LocalPlayer then return end
    p.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        local hum = char:WaitForChild("Humanoid")
        local hrp = char:WaitForChild("HumanoidRootPart")
        
        -- Xóa ESP Cũ
        if char:FindFirstChild("ESP_Highlight") then char.ESP_Highlight:Destroy() end
        if hrp:FindFirstChild("ESP_Billboard") then hrp.ESP_Billboard:Destroy() end
        
        -- Khởi Tạo Highlight
        local hl = Instance.new("Highlight", char)
        hl.Name = "ESP_Highlight"
        hl.Enabled = false
        
        -- Khởi Tạo Billboard Gui
        local bb = Instance.new("BillboardGui", hrp)
        bb.Name = "ESP_Billboard"
        bb.Size = UDim2.new(0, 100, 0, 30)
        bb.AlwaysOnTop = true
        bb.ExtentsOffset = Vector3.new(0, 3, 0)
        bb.Enabled = false
        
        local txt = Instance.new("TextLabel", bb)
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.TextScaled = true
    end)
end

for _, p in pairs(Players:GetPlayers()) do applyESP(p) end
Players.PlayerAdded:Connect(applyESP)

-- Update ESP Mỗi Khung Hình
RunService.RenderStepped:Connect(function()
    -- Cập nhật FOV Cố định trung tâm màn hình
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

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
            
            if bb and bb:FindFirstChildOfClass("TextLabel") then
                local txt = bb:FindFirstChildOfClass("TextLabel")
                bb.Enabled = Settings.ESP_Name or Settings.ESP_Full or isTargetPlayer
                
                -- Tính màu sắc theo phần trăm máu (Green -> Yellow -> Red)
                local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                local healthColor = Color3.fromRGB(255 * (1 - hpPercent), 255 * hpPercent, 0)
                
                if Settings.ESP_Full or isTargetPlayer then
                    txt.Text = string.format("%s [%d/%d]", p.DisplayName, math.floor(hum.Health), math.floor(hum.MaxHealth))
                    txt.TextColor3 = healthColor
                    if hl then hl.FillColor = healthColor end
                else
                    txt.Text = p.DisplayName
                    txt.TextColor3 = Color3.fromRGB(255, 255, 255)
                    if hl then hl.FillColor = Color3.fromRGB(255, 0, 0) end
                end
            end
        end
    end
end)

-- 3. Xử Lý Di Chuyển & Bay Qua Cần Đẩy Joysticks Điện Thoại
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        local hrp = char:FindFirstChild("HumanoidRootPart")

        -- Speed & Jump
        if Settings.WalkSpeedActive then hum.WalkSpeed = Settings.WalkSpeedVal end
        if Settings.JumpPowerActive then
            hum.UseJumpPower = true
            hum.JumpPower = Settings.JumpPowerVal
        end
        if Settings.GravityActive then workspace.Gravity = Settings.GravityVal end

        -- Logic Bay Bằng Nút Vuốt/Joystick Điện Thoại
        if Settings.FlyActive and hrp then
            local moveDir = hum.MoveDirection -- Lấy hướng từ Cần đẩy (Joystick) điện thoại
            if moveDir.Magnitude > 0 then
                hrp.Velocity = moveDir * Settings.FlySpeed
            else
                hrp.Velocity = Vector3.new(0, 0, 0)
            end
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
