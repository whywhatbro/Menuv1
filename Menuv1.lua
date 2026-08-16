-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Global Settings State (Lưu trạng thái)
local Settings = {
    AimbotMode = "None", -- "Closest", "LowestHealth", "FOV"
    FOVRadius = 120,
    WalkSpeed = 16,
    JumpPower = 50,
    Fly = false,
    FlySpeed = 50,
    InfJump = false,
    Gravity = 196.2,
    FullBright = false
}

-- Anti AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Tạo FOV Circle cho Aimbot
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 50, 50)
FOVCircle.Filled = false
FOVCircle.Transparency = 1

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileMenu"
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Nút Bật/Tắt Menu (Nút Nổi)
local ToggleMenuBtn = Instance.new("TextButton", ScreenGui)
ToggleMenuBtn.Size = UDim2.new(0, 70, 0, 35)
ToggleMenuBtn.Position = UDim2.new(0.02, 0, 0.2, 0)
ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleMenuBtn.Text = "MENU"
ToggleMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleMenuBtn.TextSize = 14
ToggleMenuBtn.Draggable = true
ToggleMenuBtn.Active = true

-- Khung Menu Chính (Nằm Ngang)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 460, 0, 220)
MainFrame.Position = UDim2.new(0.5, -230, 0.4, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Draggable = true
MainFrame.Active = true

ToggleMenuBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Thanh Tiêu Đề Menu
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Color3.fromRGB(15, 15, 15)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Text = "  HUB CHO MOBILE - 8 CHỨC NĂNG"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Container Chứa Tab
local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.Position = UDim2.new(0, 0, 0, 30)
TabContainer.Size = UDim2.new(1, 0, 0, 30)
TabContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

local TabLayout = Instance.new("UIListLayout", TabContainer)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Container Nội Dung Các Tab
local ContentContainer = Instance.new("Frame", MainFrame)
ContentContainer.Position = UDim2.new(0, 0, 0, 60)
ContentContainer.Size = UDim2.new(1, 0, 1, -60)
ContentContainer.BackgroundTransparency = 1

local Pages = {}
local function createTab(name, order)
    local tabBtn = Instance.new("TextButton", TabContainer)
    tabBtn.Size = UDim2.new(1/3, 0, 1, 0)
    tabBtn.Text = name
    tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    tabBtn.LayoutOrder = order

    local page = Instance.new("ScrollingFrame", ContentContainer)
    page.Size = UDim2.new(1, -10, 1, -10)
    page.Position = UDim2.new(0, 5, 0, 5)
    page.BackgroundTransparency = 1
    page.Visible = (order == 1)
    page.CanvasSize = UDim2.new(0, 0, 2, 0)

    local listLayout = Instance.new("UIListLayout", page)
    listLayout.Padding = UDim.new(0, 5)

    Pages[name] = page

    tabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(ContentContainer:GetChildren()) do
            p.Visible = false
        end
        for _, b in pairs(TabContainer:GetChildren()) do
            if b:IsA("TextButton") then b.TextColor3 = Color3.fromRGB(200, 200, 200) end
        end
        page.Visible = true
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 0)
    end)
    return page
end

local CombatPage = createTab("COMBAT", 1)
local MovePage = createTab("MOVEMENT", 2)
local VisualPage = createTab("VISUAL & GAME", 3)

-- Helper: Tạo Nút Bật Tắt
local function addToggle(page, text, callback)
    local btn = Instance.new("TextButton", page)
    btn.Size = UDim2.new(0.95, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
        btn.Text = text .. (state and ": ON" or ": OFF")
        callback(state)
    end)
end

-- Helper: Tạo Ô Nhập Số (TextBox)
local function addInput(page, placeholder, defaultVal, callback)
    local input = Instance.new("TextBox", page)
    input.Size = UDim2.new(0.95, 0, 0, 30)
    input.PlaceholderText = placeholder .. " (Hiện tại: " .. tostring(defaultVal) .. ")"
    input.Text = ""
    input.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    input.TextColor3 = Color3.fromRGB(255, 255, 255)

    input.FocusLost:Connect(function()
        local val = tonumber(input.Text)
        if val then
            callback(val)
        end
    end)
end

---------------------------------------------------------
-- LOGIC CÁC CHỨC NĂNG
---------------------------------------------------------

-- 1. TAB COMBAT (AIMBOT)
addToggle(CombatPage, "Aim Người Gần Nhất", function(val)
    Settings.AimbotMode = val and "Closest" or "None"
end)

addToggle(CombatPage, "Aim Người Ít Máu Nhất", function(val)
    Settings.AimbotMode = val and "LowestHealth" or "None"
end)

addToggle(CombatPage, "Aim Vòng Tròn (FOV)", function(val)
    Settings.AimbotMode = val and "FOV" or "None"
    FOVCircle.Visible = val
end)

addInput(CombatPage, "Bán kính FOV Circle", Settings.FOVRadius, function(val)
    Settings.FOVRadius = val
    FOVCircle.Radius = val
end)

-- 2. TAB MOVEMENT
addInput(MovePage, "Chạy Nhanh (WalkSpeed)", Settings.WalkSpeed, function(val)
    Settings.WalkSpeed = val
end)

addInput(MovePage, "Nhảy Cao (JumpPower)", Settings.JumpPower, function(val)
    Settings.JumpPower = val
end)

addToggle(MovePage, "Bay (Fly)", function(val)
    Settings.Fly = val
end)

addInput(MovePage, "Tốc độ Bay (FlySpeed)", Settings.FlySpeed, function(val)
    Settings.FlySpeed = val
end)

addToggle(MovePage, "Nhảy Vô Hạn (Inf Jump)", function(val)
    Settings.InfJump = val
end)

addInput(MovePage, "Trọng Lực (Gravity)", Settings.Gravity, function(val)
    Settings.Gravity = val
    workspace.Gravity = val
end)

-- 3. TAB VISUAL & GAME
addToggle(VisualPage, "Full Bright (Sáng Toàn Bộ)", function(val)
    Settings.FullBright = val
    if val then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
        Lighting.ColorShift_Top = Color3.new(1, 1, 1)
        Lighting.GlobalShadows = false
    else
        Lighting.GlobalShadows = true
    end
end)

addToggle(VisualPage, "Mở Khoá Góc Nhìn Camera", function(val)
    if val then
        LocalPlayer.CameraMaxZoomDistance = 99999
        LocalPlayer.CameraMinZoomDistance = 0.5
    else
        LocalPlayer.CameraMaxZoomDistance = 128
    end
end)


-- XỬ LÝ VÒNG LẶP LIÊN TỤC (RUNSERVICE)

-- Nhảy vô hạn
UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- Aimbot Search Logic
local function getTarget()
    local target = nil
    local shortestDist = math.huge
    local lowestHP = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local hum = player.Character.Humanoid
            local hrp = player.Character.HumanoidRootPart

            if hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                local mousePos = UserInputService:GetMouseLocation()
                local distToMouse = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                local distToPlayer = (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude

                if Settings.AimbotMode == "Closest" and distToPlayer < shortestDist then
                    shortestDist = distToPlayer
                    target = hrp
                elseif Settings.AimbotMode == "LowestHealth" and hum.Health < lowestHP then
                    lowestHP = hum.Health
                    target = hrp
                elseif Settings.AimbotMode == "FOV" and onScreen and distToMouse <= Settings.FOVRadius then
                    if distToMouse < shortestDist then
                        shortestDist = distToMouse
                        target = hrp
                    end
                end
            end
        end
    end
    return target
end

-- RenderStepped Main Loop
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        local hrp = char:FindFirstChild("HumanoidRootPart")

        -- Tốc độ & Độ cao nhảy
        hum.WalkSpeed = Settings.WalkSpeed
        hum.UseJumpPower = true
        hum.JumpPower = Settings.JumpPower

        -- Logic Bay
        if Settings.Fly and hrp then
            hrp.Velocity = Camera.CFrame.LookVector * Settings.FlySpeed
        end
    end

    -- Cập nhật FOV Circle vị trí
    FOVCircle.Position = UserInputService:GetMouseLocation()

    -- Thực thi Aimbot
    if Settings.AimbotMode ~= "None" then
        local target = getTarget()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)

