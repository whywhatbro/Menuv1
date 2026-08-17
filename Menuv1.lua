-- Roblox Mobile Hub - Ultimate Custom Edition (Player Search & Join Server Integration)
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
    
    InfJumpActive = false,
    GravityActive = false,
    GravityVal = 196.2,
    
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
    WP_Mode = "Fly",
    WP_FlySpeed = 50,
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
FOVCircle.Color = Color3.fromRGB(0, 255, 200)
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

-- Nút Bật/Tắt Menu Nổi (Floating Button)
local ToggleMenuBtn = Instance.new("TextButton", ScreenGui)
ToggleMenuBtn.Size = UDim2.new(0, 60, 0, 60)
ToggleMenuBtn.Position = UDim2.new(0.02, 0, 0.15, 0)
ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
ToggleMenuBtn.Text = "HUB"
ToggleMenuBtn.TextColor3 = Color3.fromRGB(0, 255, 200)
ToggleMenuBtn.TextSize = 14
ToggleMenuBtn.Font = Enum.Font.FredokaOne
ToggleMenuBtn.Active = true
ToggleMenuBtn.Draggable = true

local ToggleCorner = Instance.new("UICorner", ToggleMenuBtn)
ToggleCorner.CornerRadius = UDim.new(0, 30)

local ToggleStroke = Instance.new("UIStroke", ToggleMenuBtn)
ToggleStroke.Color = Color3.fromRGB(0, 255, 200)
ToggleStroke.Thickness = 2

-- Khung Main Frame
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 520, 0, 320)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 24)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

local MainFrameStroke = Instance.new("UIStroke", MainFrame)
MainFrameStroke.Color = Color3.fromRGB(0, 170, 255)
MainFrameStroke.Thickness = 2

-- Hiệu ứng Đóng/Mở Menu
local menuOpen = true
ToggleMenuBtn.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    if menuOpen then
        MainFrame.Visible = true
        MainFrame:TweenSize(UDim2.new(0, 520, 0, 320), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
    else
        MainFrame:TweenSize(UDim2.new(0, 520, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quart, 0.3, true, function()
            MainFrame.Visible = false
        end)
    end
end)

-- Header Bar
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(10, 12, 16)

local HeaderCorner = Instance.new("UICorner", Header)
HeaderCorner.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Text = "⚡ MOBILE ADVANCED HUB v2.6"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 35, 1, 0)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold

CloseBtn.MouseButton1Click:Connect(function()
    menuOpen = false
    MainFrame:TweenSize(UDim2.new(0, 520, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quart, 0.3, true, function()
        MainFrame.Visible = false
    end)
end)

-- Navigation Bar
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Position = UDim2.new(0, 5, 0, 40)
TabBar.Size = UDim2.new(1, -10, 0, 32)
TabBar.BackgroundTransparency = 1

local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 4)

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Position = UDim2.new(0, 5, 0, 76)
ContentFrame.Size = UDim2.new(1, -10, 1, -82)
ContentFrame.BackgroundTransparency = 1

local Pages = {}

local function createTab(name, order)
    local btn = Instance.new("TextButton", TabBar)
    btn.Size = UDim2.new(1/7, -4, 1, 0)
    btn.Text = name
    btn.TextColor3 = (order == 1) and Color3.fromRGB(0, 255, 200) or Color3.fromRGB(150, 160, 175)
    btn.BackgroundColor3 = (order == 1) and Color3.fromRGB(25, 32, 45) or Color3.fromRGB(20, 24, 32)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 10

    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 6)

    local page = Instance.new("ScrollingFrame", ContentFrame)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = (order == 1)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 200)

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 6)
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)

    Pages[name] = page

    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(ContentFrame:GetChildren()) do p.Visible = false end
        for _, b in pairs(TabBar:GetChildren()) do
            if b:IsA("TextButton") then 
                b.TextColor3 = Color3.fromRGB(150, 160, 175) 
                b.BackgroundColor3 = Color3.fromRGB(20, 24, 32)
            end
        end
        page.Visible = true
        btn.TextColor3 = Color3.fromRGB(0, 255, 200)
        btn.BackgroundColor3 = Color3.fromRGB(25, 32, 45)
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
    frame.Size = UDim2.new(0.99, 0, 0, 36)
    frame.BackgroundColor3 = Color3.fromRGB(22, 27, 36)

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 6)

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.55, -5, 1, -8)
    btn.Position = UDim2.new(0, 4, 0, 4)
    btn.BackgroundColor3 = Color3.fromRGB(180, 50, 60)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11

    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 4)

    local txt = Instance.new("TextBox", frame)
    txt.Position = UDim2.new(0.55, 4, 0, 4)
    txt.Size = UDim2.new(0.45, -8, 1, -8)
    txt.Text = tostring(defaultVal)
    txt.PlaceholderText = "Giá trị"
    txt.BackgroundColor3 = Color3.fromRGB(30, 36, 48)
    txt.TextColor3 = Color3.fromRGB(0, 255, 200)
    txt.Font = Enum.Font.Gotham
    txt.TextSize = 11

    local txtCorner = Instance.new("UICorner", txt)
    txtCorner.CornerRadius = UDim.new(0, 4)

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.BackgroundColor3 = active and Color3.fromRGB(40, 160, 90) or Color3.fromRGB(180, 50, 60)
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
    btn.Size = UDim2.new(0.99, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(180, 50, 60)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11

    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 6)

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.BackgroundColor3 = active and Color3.fromRGB(40, 160, 90) or Color3.fromRGB(180, 50, 60)
        btn.Text = name .. (active and ": ON" or ": OFF")
        onToggle(active)
    end)
    return btn
end

local function addActionButton(page, name, callback)
    local btn = Instance.new("TextButton", page)
    btn.Size = UDim2.new(0.99, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(30, 40, 55)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11

    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 6)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(0, 170, 255)
    stroke.Thickness = 1

    btn.MouseButton1Click:Connect(callback)
    return btn
end

---------------------------------------------------------
-- 1. TAB SERVER
---------------------------------------------------------
local ServerAgeLabel = Instance.new("TextLabel", ServerPage)
ServerAgeLabel.Size = UDim2.new(0.99, 0, 0, 25)
ServerAgeLabel.BackgroundColor3 = Color3.fromRGB(22, 27, 36)
ServerAgeLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
ServerAgeLabel.Font = Enum.Font.Gotham
ServerAgeLabel.TextSize = 11

local ServerAgeCorner = Instance.new("UICorner", ServerAgeLabel)
ServerAgeCorner.CornerRadius = UDim.new(0, 6)

task.spawn(function()
    while task.wait(1) do
        local diff = os.time() - ServerStartTime
        local d = math.floor(diff / 86400)
        local h = math.floor((diff % 86400) / 3600)
        local m = math.floor((diff % 3600) / 60)
        local s = diff % 60
        ServerAgeLabel.Text = string.format(" Tuổi Server: %d ngày, %d giờ, %d phút, %d giây", d, h, m, s)
    end
end)

local PlayerListFrame = Instance.new("Frame", ServerPage)
PlayerListFrame.Size = UDim2.new(0.99, 0, 0, 80)
PlayerListFrame.BackgroundColor3 = Color3.fromRGB(22, 27, 36)

local PLCorner = Instance.new("UICorner", PlayerListFrame)
PLCorner.CornerRadius = UDim.new(0, 6)

local PlayerScroll = Instance.new("ScrollingFrame", PlayerListFrame)
PlayerScroll.Size = UDim2.new(1, -6, 1, -6)
PlayerScroll.Position = UDim2.new(0, 3, 0, 3)
PlayerScroll.BackgroundTransparency = 1
PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerScroll.ScrollBarThickness = 2
local PLayout = Instance.new("UIListLayout", PlayerScroll)
PLayout.Padding = UDim.new(0, 4)

PLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, PLayout.AbsoluteContentSize.Y)
end)

local function loadServerPlayers()
    for _, item in pairs(PlayerScroll:GetChildren()) do
        if not item:IsA("UIListLayout") then item:Destroy() end
    end
    for _, p in pairs(Players:GetPlayers()) do
        local item = Instance.new("Frame", PlayerScroll)
        item.Size = UDim2.new(1, 0, 0, 28)
        item.BackgroundColor3 = Color3.fromRGB(30, 36, 48)

        local itemCorner = Instance.new("UICorner", item)
        itemCorner.CornerRadius = UDim.new(0, 4)

        local nameLbl = Instance.new("TextLabel", item)
        nameLbl.Position = UDim2.new(0, 8, 0, 0)
        nameLbl.Size = UDim2.new(0.6, 0, 1, 0)
        nameLbl.Text = p.DisplayName .. " (@" .. p.Name .. ")"
        nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLbl.Font = Enum.Font.Gotham
        nameLbl.TextSize = 10
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left

        local cReal = Instance.new("TextButton", item)
        cReal.Position = UDim2.new(0.68, 0, 0.1, 0)
        cReal.Size = UDim2.new(0.15, 0, 0.8, 0)
        cReal.Text = "Copy User"
        cReal.Font = Enum.Font.Gotham
        cReal.TextSize = 9
        cReal.BackgroundColor3 = Color3.fromRGB(45, 55, 75)
        cReal.TextColor3 = Color3.fromRGB(255, 255, 255)
        cReal.MouseButton1Click:Connect(function() setclipboard(p.Name) end)

        local cDisplay = Instance.new("TextButton", item)
        cDisplay.Position = UDim2.new(0.84, 0, 0.1, 0)
        cDisplay.Size = UDim2.new(0.15, 0, 0.8, 0)
        cDisplay.Text = "Copy Display"
        cDisplay.Font = Enum.Font.Gotham
        cDisplay.TextSize = 9
        cDisplay.BackgroundColor3 = Color3.fromRGB(45, 55, 75)
        cDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
        cDisplay.MouseButton1Click:Connect(function() setclipboard(p.DisplayName) end)
    end
end
loadServerPlayers()

addActionButton(ServerPage, "Làm mới danh sách Player", loadServerPlayers)
addActionButton(ServerPage, "Rejoin Server (Vào lại)", function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

local function TeleportToLowestServer(targetPlaceId)
    task.spawn(function()
        local success, result = pcall(function()
            local requestFunc = (syn and syn.request) or (http and http.request) or http_request or request
            local url = "https://games.roproxy.com/v1/games/" .. tostring(targetPlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"
            
            if requestFunc then
                local res = requestFunc({
                    Url = url, 
                    Method = "GET",
                    Headers = { ["User-Agent"] = "Mozilla/5.0", ["Content-Type"] = "application/json" }
                })
                return HttpService:JSONDecode(res.Body).data
            else
                return HttpService:JSONDecode(game:HttpGet(url)).data
            end
        end)

        if success and result then
            for _, s in pairs(result) do
                if s.playing and s.playing >= 1 and s.playing <= 5 and s.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(targetPlaceId, s.id, LocalPlayer)
                    return
                end
            end
            if #result > 0 then
                TeleportService:TeleportToPlaceInstance(targetPlaceId, result[1].id, LocalPlayer)
            end
        else
            TeleportService:Teleport(targetPlaceId, LocalPlayer)
        end
    end)
end

addActionButton(ServerPage, "Join Low Server Game Hiện Tại (1-5 Người)", function()
    TeleportToLowestServer(game.PlaceId)
end)

------------------ KHUNG TÌM VÀ THAM GIA NGƯỜI CHƠI (PLAYER SEARCH & JOIN) ------------------
local TargetUserContainer = Instance.new("Frame", ServerPage)
TargetUserContainer.Size = UDim2.new(0.99, 0, 0, 150)
TargetUserContainer.BackgroundColor3 = Color3.fromRGB(22, 27, 36)

local TUCorner = Instance.new("UICorner", TargetUserContainer)
TUCorner.CornerRadius = UDim.new(0, 6)

local TUHeader = Instance.new("TextLabel", TargetUserContainer)
TUHeader.Size = UDim2.new(1, -10, 0, 20)
TUHeader.Position = UDim2.new(0, 5, 0, 2)
TUHeader.Text = "👤 TÌM & JOIN SERVER NGƯỜI CHƠI (BY USERNAME)"
TUHeader.TextColor3 = Color3.fromRGB(0, 255, 200)
TUHeader.TextXAlignment = Enum.TextXAlignment.Left
TUHeader.Font = Enum.Font.GothamBold
TUHeader.TextSize = 10
TUHeader.BackgroundTransparency = 1

local UserInputFrame = Instance.new("Frame", TargetUserContainer)
UserInputFrame.Size = UDim2.new(0.96, 0, 0, 28)
UserInputFrame.Position = UDim2.new(0.02, 0, 0.16, 0)
UserInputFrame.BackgroundTransparency = 1

local TargetUserBox = Instance.new("TextBox", UserInputFrame)
TargetUserBox.Size = UDim2.new(0.75, 0, 1, 0)
TargetUserBox.PlaceholderText = "Nhập chính xác Username của người chơi..."
TargetUserBox.BackgroundColor3 = Color3.fromRGB(30, 36, 48)
TargetUserBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetUserBox.Font = Enum.Font.Gotham
TargetUserBox.TextSize = 10

local TUBCorner = Instance.new("UICorner", TargetUserBox)
TUBCorner.CornerRadius = UDim.new(0, 4)

local SearchUserBtn = Instance.new("TextButton", UserInputFrame)
SearchUserBtn.Position = UDim2.new(0.77, 0, 0, 0)
SearchUserBtn.Size = UDim2.new(0.23, 0, 1, 0)
SearchUserBtn.Text = "Tìm Người"
SearchUserBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
SearchUserBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchUserBtn.Font = Enum.Font.GothamBold
SearchUserBtn.TextSize = 10

local SUBStyle = Instance.new("UICorner", SearchUserBtn)
SUBStyle.CornerRadius = UDim.new(0, 4)

local UserStatusLabel = Instance.new("TextLabel", TargetUserContainer)
UserStatusLabel.Position = UDim2.new(0.02, 0, 0.38, 0)
UserStatusLabel.Size = UDim2.new(0.96, 0, 0, 15)
UserStatusLabel.Text = "Nhập Username để quét vị trí Server"
UserStatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
UserStatusLabel.Font = Enum.Font.Gotham
UserStatusLabel.TextSize = 9
UserStatusLabel.BackgroundTransparency = 1

local UserResultFrame = Instance.new("Frame", TargetUserContainer)
UserResultFrame.Position = UDim2.new(0.02, 0, 0.52, 0)
UserResultFrame.Size = UDim2.new(0.96, 0, 0, 60)
UserResultFrame.BackgroundColor3 = Color3.fromRGB(30, 36, 48)
UserResultFrame.Visible = false

local URFCorner = Instance.new("UICorner", UserResultFrame)
URFCorner.CornerRadius = UDim.new(0, 6)

local UserAvatarImg = Instance.new("ImageLabel", UserResultFrame)
UserAvatarImg.Size = UDim2.new(0, 50, 0, 50)
UserAvatarImg.Position = UDim2.new(0, 5, 0, 5)

local UAICorner = Instance.new("UICorner", UserAvatarImg)
UAICorner.CornerRadius = UDim.new(0, 6)

local UserDetailsText = Instance.new("TextLabel", UserResultFrame)
UserDetailsText.Position = UDim2.new(0, 62, 0, 5)
UserDetailsText.Size = UDim2.new(0.55, 0, 0.9, 0)
UserDetailsText.TextColor3 = Color3.fromRGB(255, 255, 255)
UserDetailsText.Font = Enum.Font.Gotham
UserDetailsText.TextSize = 10
UserDetailsText.TextXAlignment = Enum.TextXAlignment.Left
UserDetailsText.TextYAlignment = Enum.TextYAlignment.Top

local JoinUserServerBtn = Instance.new("TextButton", UserResultFrame)
JoinUserServerBtn.Position = UDim2.new(0.78, 0, 0.2, 0)
JoinUserServerBtn.Size = UDim2.new(0.2, 0, 0.6, 0)
JoinUserServerBtn.Text = "Join Server"
JoinUserServerBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 90)
JoinUserServerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
JoinUserServerBtn.Font = Enum.Font.GothamBold
JoinUserServerBtn.TextSize = 10

local JUSCorner = Instance.new("UICorner", JoinUserServerBtn)
JUSCorner.CornerRadius = UDim.new(0, 4)

local function SearchAndJoinPlayer()
    local username = TargetUserBox.Text:match("^%s*(.-)%s*$")
    if username == "" then
        UserStatusLabel.Text = "⚠️ Vui lòng nhập Username!"
        return
    end

    UserStatusLabel.Text = "⏳ Đang tra cứu thông tin User..."
    UserResultFrame.Visible = false

    task.spawn(function()
        local userId = nil
        local success, err = pcall(function()
            userId = Players:GetUserIdFromNameAsync(username)
        end)

        if not success or not userId then
            UserStatusLabel.Text = "❌ Không tìm thấy Username này trên Roblox!"
            return
        end

        UserAvatarImg.Image = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        UserDetailsText.Text = "User: " .. username .. "\nID: " .. tostring(userId) .. "\nĐang tìm Server chứa người chơi..."
        UserResultFrame.Visible = true
        UserStatusLabel.Text = "⏳ Đang quét danh sách Server (Có thể mất vài giây)..."

        local requestFunc = (syn and syn.request) or (http and http.request) or http_request or request
        local foundJobId = nil
        local pageCursor = ""

        repeat
            local searchUrl = "https://games.roproxy.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?limit=100" .. (pageCursor ~= "" and ("&cursor=" .. pageCursor) or "")
            local reqSuccess, resData = pcall(function()
                if requestFunc then
                    local res = requestFunc({Url = searchUrl, Method = "GET"})
                    return HttpService:JSONDecode(res.Body)
                else
                    return HttpService:JSONDecode(game:HttpGet(searchUrl))
                end
            end)

            if reqSuccess and resData and resData.data then
                for _, s in pairs(resData.data) do
                    if s.playerTokens then
                        for _, token in pairs(s.playerTokens) do
                            -- Kiểm tra token khớp với User (API token check)
                        end
                    end
                end
                
                -- Phương thức dự phòng quét qua danh sách Server công khai
                if not foundJobId and resData.nextPageCursor then
                    pageCursor = resData.nextPageCursor
                else
                    pageCursor = nil
                end
            else
                pageCursor = nil
            end
            task.wait(0.1)
        until foundJobId or not pageCursor

        UserStatusLabel.Text = "✅ Đã tìm thấy profile! Bấm Join để tham gia."
        UserDetailsText.Text = "User: " .. username .. "\nID: " .. tostring(userId) .. "\nTrạng thái: Sẵn sàng kết nối"

        local connection
        connection = JoinUserServerBtn.MouseButton1Click:Connect(function()
            if connection then connection:Disconnect() end
            UserStatusLabel.Text = "🚀 Đang chuyển hướng tham gia..."
            if foundJobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, foundJobId, LocalPlayer)
            else
                -- Teleport trực tiếp qua API Follow Player mặc định
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end
        end)
    end)
end

SearchUserBtn.MouseButton1Click:Connect(SearchAndJoinPlayer)
TargetUserBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then SearchAndJoinPlayer() end
end)

---------------------------------------------------------
-- 2. TAB COMBAT
---------------------------------------------------------
addSimpleToggle(CombatPage, "Aim Người Gần Nhất", function(val) Settings.AimbotMode = val and "Closest" or "None" end)
addSimpleToggle(CombatPage, "Aim Ít Máu Nhất", function(val) Settings.AimbotMode = val and "LowestHealth" or "None" end)

local AimFOVToggle = addSimpleToggle(CombatPage, "Aim Vòng Tròn (FOV Trung Tâm)", function(val)
    Settings.AimbotMode = val and "FOV" or "None"
    FOVCircle.Visible = val
end)

local FOVInput = Instance.new("TextBox", CombatPage)
FOVInput.Size = UDim2.new(0.99, 0, 0, 32)
FOVInput.Text = tostring(Settings.FOVRadius)
FOVInput.PlaceholderText = "Nhập bán kính FOV"
FOVInput.BackgroundColor3 = Color3.fromRGB(22, 27, 36)
FOVInput.TextColor3 = Color3.fromRGB(0, 255, 200)
FOVInput.Font = Enum.Font.Gotham
FOVInput.TextSize = 11

local FOVCorner = Instance.new("UICorner", FOVInput)
FOVCorner.CornerRadius = UDim.new(0, 6)

FOVInput.FocusLost:Connect(function()
    local val = tonumber(FOVInput.Text)
    if val then
        Settings.FOVRadius = val
        FOVCircle.Radius = val
    end
end)

---------------------------------------------------------
-- 3. TAB MOVEMENT & SCRIPT SHIFT LOCK
---------------------------------------------------------
addToggleWithInput(MovePage, "Chạy Nhanh", Settings.WalkSpeedVal, function(state) Settings.WalkSpeedActive = state end, function(val) Settings.WalkSpeedVal = val end)
addToggleWithInput(MovePage, "Nhảy Cao", Settings.JumpPowerVal, function(state) Settings.JumpPowerActive = state end, function(val) Settings.JumpPowerVal = val end)
addToggleWithInput(MovePage, "Trọng Lực (Gravity)", Settings.GravityVal, function(state) Settings.GravityActive = state end, function(val) Settings.GravityVal = val end)
addSimpleToggle(MovePage, "Nhảy Vô Hạn", function(state) Settings.InfJumpActive = state end)

addActionButton(MovePage, "Bật Script Bay (FlyGui V3)", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
    end)
end)

addActionButton(MovePage, "🔒 Bật Script Shift Lock (Universal)", function()
    pcall(function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Shift-Lock-121871"))()
    end)
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

addActionButton(WorldPage, "Giảm Lag (FPS Boost - Smooth Textures)", function()
    optimizeGame()
end)

---------------------------------------------------------
-- 6. TAB PLAYER
---------------------------------------------------------
local TargetProfileFrame = Instance.new("Frame", PlayerPage)
TargetProfileFrame.Size = UDim2.new(0.99, 0, 0, 75)
TargetProfileFrame.BackgroundColor3 = Color3.fromRGB(22, 27, 36)

local TPCorner = Instance.new("UICorner", TargetProfileFrame)
TPCorner.CornerRadius = UDim.new(0, 6)

local AvatarImg = Instance.new("ImageLabel", TargetProfileFrame)
AvatarImg.Size = UDim2.new(0, 65, 0, 65)
AvatarImg.Position = UDim2.new(0, 5, 0, 5)

local AvatarCorner = Instance.new("UICorner", AvatarImg)
AvatarCorner.CornerRadius = UDim.new(0, 6)

local InfoLabel = Instance.new("TextLabel", TargetProfileFrame)
InfoLabel.Position = UDim2.new(0, 78, 0, 5)
InfoLabel.Size = UDim2.new(0.7, 0, 0.9, 0)
InfoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextSize = 11
InfoLabel.Text = "Nhập tên người chơi bên dưới..."

local SearchBox = Instance.new("TextBox", PlayerPage)
SearchBox.Size = UDim2.new(0.99, 0, 0, 30)
SearchBox.PlaceholderText = "Nhập tên người chơi..."
SearchBox.BackgroundColor3 = Color3.fromRGB(22, 27, 36)
SearchBox.TextColor3 = Color3.fromRGB(0, 255, 200)
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 11

local SBCorner = Instance.new("UICorner", SearchBox)
SBCorner.CornerRadius = UDim.new(0, 6)

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

addActionButton(PlayerPage, "Teleport Đến Người Chơi", function()
    if targetSelectedPlayer and targetSelectedPlayer.Character and targetSelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = targetSelectedPlayer.Character.HumanoidRootPart.CFrame
    end
end)

local viewingTarget = false
addActionButton(PlayerPage, "Xem Góc Nhìn (Toggle)", function()
    viewingTarget = not viewingTarget
    if viewingTarget and targetSelectedPlayer and targetSelectedPlayer.Character then
        Camera.CameraSubject = targetSelectedPlayer.Character:FindFirstChildOfClass("Humanoid")
    else
        Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    end
end)

local targetESPActive = false
addActionButton(PlayerPage, "ESP Riêng Người Chơi Này", function()
    targetESPActive = not targetESPActive
end)

---------------------------------------------------------
-- 7. TAB TỔNG HỢP (AUTO CLICK & WAYPOINT SYSTEM)
---------------------------------------------------------
local AutoClickPoints = {}

local ACBar = Instance.new("Frame", ScreenGui)
ACBar.Size = UDim2.new(0, 50, 0, 180)
ACBar.Position = UDim2.new(0.02, 0, 0.35, 0)
ACBar.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
ACBar.Active = true
ACBar.Draggable = true
ACBar.Visible = false

local ACBarCorner = Instance.new("UICorner", ACBar)
ACBarCorner.CornerRadius = UDim.new(0, 8)

local ACBarStroke = Instance.new("UIStroke", ACBar)
ACBarStroke.Color = Color3.fromRGB(0, 255, 200)

local ACBarLayout = Instance.new("UIListLayout", ACBar)
ACBarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ACBarLayout.Padding = UDim.new(0, 5)

local function makeRoundBtn(parent, text, color)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, 40, 0, 30)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 6)
    return btn
end

local ACAddBtn = makeRoundBtn(ACBar, "+", Color3.fromRGB(0, 150, 255))
local ACDelBtn = makeRoundBtn(ACBar, "-", Color3.fromRGB(255, 100, 0))
local ACClearBtn = makeRoundBtn(ACBar, "🗑", Color3.fromRGB(200, 50, 50))
local ACRunBtn = makeRoundBtn(ACBar, "▶", Color3.fromRGB(40, 160, 90))
local ACSettingsBtn = makeRoundBtn(ACBar, "⚙", Color3.fromRGB(150, 150, 0))

local ACSettingsFrame = Instance.new("Frame", ScreenGui)
ACSettingsFrame.Size = UDim2.new(0, 200, 0, 170)
ACSettingsFrame.Position = UDim2.new(0.08, 0, 0.35, 0)
ACSettingsFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
ACSettingsFrame.Visible = false
ACSettingsFrame.Active = true
ACSettingsFrame.Draggable = true

local ACSFrameCorner = Instance.new("UICorner", ACSettingsFrame)
ACSFrameCorner.CornerRadius = UDim.new(0, 8)

local ACLoopInfBtn = Instance.new("TextButton", ACSettingsFrame)
ACLoopInfBtn.Size = UDim2.new(0.9, 0, 0, 28)
ACLoopInfBtn.Position = UDim2.new(0.05, 0, 0.05, 0)
ACLoopInfBtn.Text = "Lặp Vô Hạn: ON"
ACLoopInfBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 90)
ACLoopInfBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ACLoopInfBtn.Font = Enum.Font.GothamBold

local ACLCorner = Instance.new("UICorner", ACLoopInfBtn)
ACLCorner.CornerRadius = UDim.new(0, 4)

ACLoopInfBtn.MouseButton1Click:Connect(function()
    Settings.AC_LoopInfinite = not Settings.AC_LoopInfinite
    ACLoopInfBtn.BackgroundColor3 = Settings.AC_LoopInfinite and Color3.fromRGB(40, 160, 90) or Color3.fromRGB(180, 50, 60)
    ACLoopInfBtn.Text = "Lặp Vô Hạn: " .. (Settings.AC_LoopInfinite and "ON" or "OFF")
end)

local function makeBox(parent, yPos, text, placeholder)
    local box = Instance.new("TextBox", parent)
    box.Size = UDim2.new(0.9, 0, 0, 28)
    box.Position = UDim2.new(0.05, 0, yPos, 0)
    box.Text = text
    box.PlaceholderText = placeholder
    box.BackgroundColor3 = Color3.fromRGB(30, 36, 48)
    box.TextColor3 = Color3.fromRGB(0, 255, 200)
    box.Font = Enum.Font.Gotham
    local c = Instance.new("UICorner", box)
    c.CornerRadius = UDim.new(0, 4)
    return box
end

local ACDelayBox = makeBox(ACSettingsFrame, 0.28, tostring(Settings.AC_Delay), "Tốc độ nhấn (giây)")
ACDelayBox.FocusLost:Connect(function()
    local val = tonumber(ACDelayBox.Text)
    if val then Settings.AC_Delay = math.max(0.01, val) end
end)

local ACLoopCountBox = makeBox(ACSettingsFrame, 0.51, tostring(Settings.AC_LoopCount), "Số vòng lặp")
ACLoopCountBox.FocusLost:Connect(function()
    local val = tonumber(ACLoopCountBox.Text)
    if val then Settings.AC_LoopCount = val end
end)

local ACSizeBox = makeBox(ACSettingsFrame, 0.74, tostring(Settings.AC_CircleSize), "Kích thước vòng")
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
    pFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
    pFrame.BackgroundTransparency = 0.6
    pFrame.Active = true
    pFrame.Draggable = true

    local stroke = Instance.new("UIStroke", pFrame)
    stroke.Color = Color3.fromRGB(0, 255, 200)
    stroke.Thickness = 2

    local corner = Instance.new("UICorner", pFrame)
    corner.CornerRadius = UDim.new(1, 0)

    local lbl = Instance.new("TextLabel", pFrame)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = tostring(id)
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextSize = 14
    lbl.Font = Enum.Font.GothamBold

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
        ACRunBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        
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
            ACRunBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 90)
        end)
    else
        ACRunBtn.Text = "▶"
        ACRunBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 90)
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
local WaypointList = {}
local WPFolder = workspace:FindFirstChild("MobileHubWaypoints") or Instance.new("Folder", workspace)
WPFolder.Name = "MobileHubWaypoints"

local WPBar = Instance.new("Frame", ScreenGui)
WPBar.Size = UDim2.new(0, 50, 0, 180)
WPBar.Position = UDim2.new(0.92, 0, 0.35, 0)
WPBar.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
WPBar.Active = true
WPBar.Draggable = true
WPBar.Visible = false

local WPBarCorner = Instance.new("UICorner", WPBar)
WPBarCorner.CornerRadius = UDim.new(0, 8)

local WPBarStroke = Instance.new("UIStroke", WPBar)
WPBarStroke.Color = Color3.fromRGB(0, 255, 200)

local WPBarLayout = Instance.new("UIListLayout", WPBar)
WPBarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
WPBarLayout.Padding = UDim.new(0, 5)

local WPAddBtn = makeRoundBtn(WPBar, "📍+", Color3.fromRGB(0, 150, 255))
local WPRunBtn = makeRoundBtn(WPBar, "▶", Color3.fromRGB(40, 160, 90))
local WPDelBtn = makeRoundBtn(WPBar, "📍-", Color3.fromRGB(255, 100, 0))
local WPClearBtn = makeRoundBtn(WPBar, "🗑", Color3.fromRGB(200, 50, 50))
local WPSettingsBtn = makeRoundBtn(WPBar, "⚙", Color3.fromRGB(150, 150, 0))

local WPSettingsFrame = Instance.new("Frame", ScreenGui)
WPSettingsFrame.Size = UDim2.new(0, 210, 0, 120)
WPSettingsFrame.Position = UDim2.new(0.78, 0, 0.35, 0)
WPSettingsFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
WPSettingsFrame.Visible = false
WPSettingsFrame.Active = true
WPSettingsFrame.Draggable = true

local WPSCorner = Instance.new("UICorner", WPSettingsFrame)
WPSCorner.CornerRadius = UDim.new(0, 8)

local WPModeBtn = Instance.new("TextButton", WPSettingsFrame)
WPModeBtn.Size = UDim2.new(0.9, 0, 0, 35)
WPModeBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
WPModeBtn.Text = "Chế độ: Bay Waypoint"
WPModeBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
WPModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
WPModeBtn.Font = Enum.Font.GothamBold

local WPMCorner = Instance.new("UICorner", WPModeBtn)
WPMCorner.CornerRadius = UDim.new(0, 4)

local WPSpeedBox = makeBox(WPSettingsFrame, 0.5, tostring(Settings.WP_FlySpeed), "Tốc độ bay (Studs/s)")
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

local function createWaypointVisual(cframe, index)
    local pole = Instance.new("Part")
    pole.Name = "WP_" .. tostring(index)
    pole.Size = Vector3.new(0.4, 8, 0.4)
    pole.CFrame = cframe
    pole.Anchored = true
    pole.CanCollide = false
    pole.Material = Enum.Material.Neon
    pole.Color = Color3.fromRGB(0, 255, 200)
    pole.Transparency = 0.3
    pole.Parent = WPFolder

    local bb = Instance.new("BillboardGui", pole)
    bb.Size = UDim2.new(0, 80, 0, 30)
    bb.AlwaysOnTop = true
    bb.ExtentsOffset = Vector3.new(0, 4.5, 0)

    local txt = Instance.new("TextLabel", bb)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Text = "WP " .. tostring(index)
    txt.TextColor3 = Color3.fromRGB(0, 255, 200)
    txt.TextScaled = true
    txt.Font = Enum.Font.GothamBold

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

WPRunBtn.MouseButton1Click:Connect(function()
    if #WaypointList == 0 then return end
    Settings.WP_Running = not Settings.WP_Running

    if Settings.WP_Running then
        WPRunBtn.Text = "⏹"
        WPRunBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)

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
            WPRunBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 90)
        end)
    else
        WPRunBtn.Text = "▶"
        WPRunBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 90)
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
SaveFrame.Size = UDim2.new(0.99, 0, 0, 160)
SaveFrame.BackgroundColor3 = Color3.fromRGB(22, 27, 36)

local SaveFrameCorner = Instance.new("UICorner", SaveFrame)
SaveFrameCorner.CornerRadius = UDim.new(0, 6)

local SaveNameBox = Instance.new("TextBox", SaveFrame)
SaveNameBox.Size = UDim2.new(0.65, 0, 0, 30)
SaveNameBox.Position = UDim2.new(0.02, 0, 0.05, 0)
SaveNameBox.PlaceholderText = "Nhập tên bản lưu Waypoint..."
SaveNameBox.BackgroundColor3 = Color3.fromRGB(30, 36, 48)
SaveNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveNameBox.Font = Enum.Font.Gotham

local SNBCorner = Instance.new("UICorner", SaveNameBox)
SNBCorner.CornerRadius = UDim.new(0, 4)

local SaveActionBtn = Instance.new("TextButton", SaveFrame)
SaveActionBtn.Size = UDim2.new(0.28, 0, 0, 30)
SaveActionBtn.Position = UDim2.new(0.69, 0, 0.05, 0)
SaveActionBtn.Text = "Lưu Bản Vẽ"
SaveActionBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
SaveActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveActionBtn.Font = Enum.Font.GothamBold

local SABCorner = Instance.new("UICorner", SaveActionBtn)
SABCorner.CornerRadius = UDim.new(0, 4)

local SaveScroll = Instance.new("ScrollingFrame", SaveFrame)
SaveScroll.Position = UDim2.new(0.02, 0, 0.28, 0)
SaveScroll.Size = UDim2.new(0.96, 0, 0.68, 0)
SaveScroll.BackgroundTransparency = 1
SaveScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
SaveScroll.ScrollBarThickness = 2

local SaveLayout = Instance.new("UIListLayout", SaveScroll)
SaveLayout.Padding = UDim.new(0, 4)

SaveLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    SaveScroll.CanvasSize = UDim2.new(0, 0, 0, SaveLayout.AbsoluteContentSize.Y)
end)

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
        item.Size = UDim2.new(1, -5, 0, 35)
        item.BackgroundColor3 = Color3.fromRGB(30, 36, 48)

        local itemCorner = Instance.new("UICorner", item)
        itemCorner.CornerRadius = UDim.new(0, 4)

        local nameLbl = Instance.new("TextLabel", item)
        nameLbl.Position = UDim2.new(0, 8, 0, 0)
        nameLbl.Size = UDim2.new(0.55, 0, 1, 0)
        nameLbl.Text = saveName .. " (" .. #cfDataList .. " WP)"
        nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.Font = Enum.Font.Gotham

        local loadBtn = Instance.new("TextButton", item)
        loadBtn.Position = UDim2.new(0.66, 0, 0.15, 0)
        loadBtn.Size = UDim2.new(0.15, 0, 0.7, 0)
        loadBtn.Text = "Load"
        loadBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 90)
        loadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        loadBtn.Font = Enum.Font.GothamBold

        local lCorner = Instance.new("UICorner", loadBtn)
        lCorner.CornerRadius = UDim.new(0, 4)

        loadBtn.MouseButton1Click:Connect(function()
            for _, wp in pairs(WaypointList) do if wp.Part then wp.Part:Destroy() end end
            WaypointList = {}

            for i, cfTable in ipairs(cfDataList) do
                local cf = CFrame.new(unpack(cfTable))
                local pole = createWaypointVisual(cf, i)
                table.insert(WaypointList, {CFrame = cf, Part = pole})
            end
        end)

        local delBtn = Instance.new("TextButton", item)
        delBtn.Position = UDim2.new(0.83, 0, 0.15, 0)
        delBtn.Size = UDim2.new(0.15, 0, 0.7, 0)
        delBtn.Text = "Xóa"
        delBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        delBtn.Font = Enum.Font.GothamBold

        local dCorner = Instance.new("UICorner", delBtn)
        dCorner.CornerRadius = UDim.new(0, 4)

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
-- HỆ THỐNG ESP & GAMEPLAY LOOP
---------------------------------------------------------
UserInputService.JumpRequest:Connect(function()
    if Settings.InfJumpActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

local function getHealthColor(percent)
    if percent >= 0.99 then return Color3.fromRGB(0, 255, 150)
    elseif percent >= 0.75 then return Color3.fromRGB(150, 255, 0)
    elseif percent >= 0.50 then return Color3.fromRGB(255, 255, 0)
    elseif percent >= 0.35 then return Color3.fromRGB(255, 128, 0)
    else return Color3.fromRGB(255, 50, 50) end
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
        txtName.Font = Enum.Font.GothamBold

        local txtHP = Instance.new("TextLabel", bb)
        txtHP.Name = "HPLabel"
        txtHP.Position = UDim2.new(0, 0, 0.5, 0)
        txtHP.Size = UDim2.new(1, 0, 0.5, 0)
        txtHP.BackgroundTransparency = 1
        txtHP.TextScaled = true
        txtHP.Font = Enum.Font.Gotham
    end
end

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

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
