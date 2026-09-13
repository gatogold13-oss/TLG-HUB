--====================================================================--
--              TLG GOLD HUB - PC & MOBILE EDITION                    --
--      Compatible con PC y Celular | Sin errores | Camera Fly        --
--====================================================================--

-- ✅ Servicios con pcall por si fallan en algún ejecutor
local services = {}
for _, name in ipairs({"TweenService","UserInputService","Players","RunService","CoreGui","VirtualUser","Debris"}) do
    local ok, s = pcall(function() return game:GetService(name) end)
    services[name] = ok and s or nil
end

local TS = services.TweenService
local UI = services.UserInputService
local P = services.Players
local RS = services.RunService
local CG = services.CoreGui
local VU = services.VirtualUser
local Debris = services.Debris

local LP = P.LocalPlayer
local Cam = workspace.CurrentCamera

-- ✅ Detección de plataforma
local IS_MOBILE = false
local IS_PC = false
pcall(function()
    if UI.TouchEnabled and not UI.KeyboardEnabled then
        IS_MOBILE = true
    else
        IS_PC = true
    end
end)

-- ✅ Drawing opcional
local HAS_DRAWING = false
pcall(function()
    if typeof(Drawing) == "table" and Drawing.new then
        local t = Drawing.new("Square")
        if t then t:Remove(); HAS_DRAWING = true end
    end
end)

-- ✅ Parent de GUI con múltiples fallbacks
local function GetGUIParent()
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    if CG then
        local ok = pcall(function()
            local test = Instance.new("Folder")
            test.Parent = CG
            test:Destroy()
        end)
        if ok then return CG end
    end
    return LP:WaitForChild("PlayerGui")
end

local SP = GetGUIParent()

-- Limpiar GUIs anteriores
for _, n in ipairs({"TLG_GoldHub","TLG_FloatButtons"}) do
    pcall(function()
        local o = SP:FindFirstChild(n)
        if o then o:Destroy() end
    end)
    pcall(function()
        local o = CG and CG:FindFirstChild(n)
        if o then o:Destroy() end
    end)
end

----------------------------------------------------------------
-- 🎨 PALETA
----------------------------------------------------------------
local C = {
    BG = Color3.fromRGB(18, 18, 20),
    Panel = Color3.fromRGB(28, 28, 32),
    Box = Color3.fromRGB(22, 22, 26),
    BoxBorder = Color3.fromRGB(70, 70, 80),
    Btn = Color3.fromRGB(50, 50, 58),
    BtnHover = Color3.fromRGB(65, 65, 75),
    Gold = Color3.fromRGB(255, 200, 50),
    GoldDim = Color3.fromRGB(200, 155, 40),
    Text = Color3.fromRGB(240, 240, 240),
    Text2 = Color3.fromRGB(150, 150, 155),
    Green = Color3.fromRGB(80, 220, 100),
    Red = Color3.fromRGB(240, 70, 80)
}

----------------------------------------------------------------
-- ✅ DECLARACIÓN ANTICIPADA
----------------------------------------------------------------
local FlyBtn, FugaBtn, FlyStatusRef, MapOrbitStatusRef
local ShowFlyButton = true
local ShowFugaButton = true

local V3, VSpd = false, 100000
local MapOrbitOn = false
local MapOrbitSpeed = 3000
local MapOrbitAngle = 0
local MapOrbitRadius = 300
local MapOrbitHeight = 100
local MapOrbitConn = nil

local PC = nil
pcall(function()
    local pm = LP:WaitForChild("PlayerScripts", 10)
    if pm then
        local ps = pm:WaitForChild("PlayerModule", 5)
        if ps then
            local mod = require(ps)
            if mod then PC = mod:GetControls() end
        end
    end
end)

----------------------------------------------------------------
-- 🪟 VENTANA
----------------------------------------------------------------
local SG = Instance.new("ScreenGui")
SG.Name = "TLG_GoldHub"
SG.ResetOnSpawn = false
SG.IgnoreGuiInset = true
pcall(function() SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling end)
SG.Parent = SP

local Window = Instance.new("Frame", SG)
Window.Size = UDim2.new(0, 0, 0, 0)
Window.Position = UDim2.new(0.5, 0, 0.5, 0)
Window.BackgroundColor3 = C.BG
Window.BorderSizePixel = 0
Window.ClipsDescendants = true
Window.Active = true
Instance.new("UICorner", Window).CornerRadius = UDim.new(0, 8)
local WinStroke = Instance.new("UIStroke", Window)
WinStroke.Color = C.Gold
WinStroke.Thickness = 1.5
WinStroke.Transparency = 0.2

local W_SIZE = UDim2.new(0, 500, 0, 300)
local W_POS = UDim2.new(0.5, -250, 0.5, -150)

local function MakeDraggable(obj, handle)
    local drag, ds, sp = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; ds = i.Position; sp = obj.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)
    UI.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ds
            obj.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end)
end

local function MakeButtonDraggable(btn)
    local dragStart, startPos
    local isDragging = false
    local moved = false

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            moved = false
            dragStart = input.Position
            startPos = btn.Position
        end
    end)

    UI.InputChanged:Connect(function(input)
        if isDragging and dragStart and startPos then
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStart
                if math.abs(delta.X) > 10 or math.abs(delta.Y) > 10 then
                    moved = true
                    btn.Position = UDim2.new(
                        startPos.X.Scale, startPos.X.Offset + delta.X,
                        startPos.Y.Scale, startPos.Y.Offset + delta.Y
                    )
                end
            end
        end
    end)

    UI.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
            dragStart = nil
            task.delay(0.15, function() moved = false end)
        end
    end)

    return function() return moved end
end

----------------------------------------------------------------
-- HEADER
----------------------------------------------------------------
local Header = Instance.new("Frame", Window)
Header.Size = UDim2.new(1, 0, 0, 24)
Header.BackgroundColor3 = C.BG
Header.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "👑 TLG GOLD HUB 👑"
Title.TextColor3 = C.Gold
Title.TextSize = 10

task.spawn(function()
    while Title.Parent do
        pcall(function()
            TS:Create(Title, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(255, 230, 130)}):Play()
        end)
        task.wait(1.8)
        if not Title.Parent then break end
        pcall(function()
            TS:Create(Title, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextColor3 = C.Gold}):Play()
        end)
        task.wait(1.8)
    end
end)

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -26, 0.5, -11)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextColor3 = C.Red
CloseBtn.TextSize = 12
CloseBtn.AutoButtonColor = false

MakeDraggable(Window, Header)

local Divider = Instance.new("Frame", Window)
Divider.Size = UDim2.new(1, -10, 0, 1)
Divider.Position = UDim2.new(0, 5, 0, 25)
Divider.BackgroundColor3 = C.Gold
Divider.BackgroundTransparency = 0.6
Divider.BorderSizePixel = 0

----------------------------------------------------------------
-- 3 COLUMNAS
----------------------------------------------------------------
local ColumnsFrame = Instance.new("Frame", Window)
ColumnsFrame.Size = UDim2.new(1, -10, 1, -34)
ColumnsFrame.Position = UDim2.new(0, 5, 0, 30)
ColumnsFrame.BackgroundTransparency = 1

local ColumnsLayout = Instance.new("UIListLayout", ColumnsFrame)
ColumnsLayout.FillDirection = Enum.FillDirection.Horizontal
ColumnsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ColumnsLayout.VerticalAlignment = Enum.VerticalAlignment.Top
ColumnsLayout.Padding = UDim.new(0, 4)

local function CreateColumn(parent, width)
    local panel = Instance.new("Frame", parent)
    panel.Size = UDim2.new(0, width, 1, 0)
    panel.BackgroundColor3 = C.Panel
    panel.BorderSizePixel = 0
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 6)
    local pStroke = Instance.new("UIStroke", panel)
    pStroke.Color = C.GoldDim
    pStroke.Thickness = 1
    pStroke.Transparency = 0.4

    local content = Instance.new("ScrollingFrame", panel)
    content.Size = UDim2.new(1, -6, 1, -6)
    content.Position = UDim2.new(0, 3, 0, 3)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 2
    content.ScrollBarImageColor3 = C.Gold
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    pcall(function() content.AutomaticCanvasSize = Enum.AutomaticSize.Y end)
    Instance.new("UIListLayout", content).Padding = UDim.new(0, 4)

    return content
end

local function CreateBox(parent, title, icon)
    local box = Instance.new("Frame", parent)
    box.Size = UDim2.new(1, 0, 0, 0)
    box.BackgroundColor3 = C.Box
    box.BorderSizePixel = 0
    box.AutomaticSize = Enum.AutomaticSize.Y
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)
    Instance.new("UIStroke", box).Color = C.BoxBorder

    local inner = Instance.new("Frame", box)
    inner.Size = UDim2.new(1, -6, 0, 0)
    inner.Position = UDim2.new(0, 3, 0, 0)
    inner.BackgroundTransparency = 1
    inner.AutomaticSize = Enum.AutomaticSize.Y
    Instance.new("UIListLayout", inner).Padding = UDim.new(0, 2)
    local pad = Instance.new("UIPadding", inner)
    pad.PaddingTop = UDim.new(0, 3)
    pad.PaddingBottom = UDim.new(0, 4)

    local header = Instance.new("Frame", inner)
    header.Size = UDim2.new(1, 0, 0, 14)
    header.BackgroundTransparency = 1

    local t = Instance.new("TextLabel", header)
    t.Size = UDim2.new(1, 0, 1, 0)
    t.BackgroundTransparency = 1
    t.Font = Enum.Font.GothamBold
    t.Text = (icon and (icon .. " ") or "") .. title
    t.TextColor3 = C.Gold
    t.TextSize = 9
    t.TextXAlignment = Enum.TextXAlignment.Left

    local line = Instance.new("Frame", header)
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 1, 0)
    line.BackgroundColor3 = C.GoldDim
    line.BackgroundTransparency = 0.6
    line.BorderSizePixel = 0

    local options = Instance.new("Frame", inner)
    options.Size = UDim2.new(1, 0, 0, 0)
    options.BackgroundTransparency = 1
    options.AutomaticSize = Enum.AutomaticSize.Y
    Instance.new("UIListLayout", options).Padding = UDim.new(0, 2)

    return options
end

local function CreateButton(parent, text, color, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 20)
    btn.BackgroundColor3 = C.Btn
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = text
    btn.TextColor3 = color or C.Text
    btn.TextSize = 8
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.TextTruncate = Enum.TextTruncate.AtEnd
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    local s = Instance.new("UIStroke", btn)
    s.Color = C.GoldDim
    s.Thickness = 1
    s.Transparency = 0.7

    btn.MouseEnter:Connect(function()
        pcall(function()
            TS:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = C.BtnHover}):Play()
            TS:Create(s, TweenInfo.new(0.15), {Transparency = 0}):Play()
        end)
    end)
    btn.MouseLeave:Connect(function()
        pcall(function()
            TS:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = C.Btn}):Play()
            TS:Create(s, TweenInfo.new(0.15), {Transparency = 0.7}):Play()
        end)
    end)
    btn.MouseButton1Click:Connect(function() pcall(callback) end)
    return btn
end

local function CreateStatus(parent, text, defaultOn, callback)
    local fr = Instance.new("Frame", parent)
    fr.Size = UDim2.new(1, 0, 0, 22)
    fr.BackgroundColor3 = C.Btn
    fr.BorderSizePixel = 0
    Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 4)
    local s = Instance.new("UIStroke", fr)
    s.Color = C.GoldDim
    s.Thickness = 1
    s.Transparency = 0.7

    local box = Instance.new("Frame", fr)
    box.Size = UDim2.new(0, 12, 0, 12)
    box.Position = UDim2.new(0, 6, 0.5, -6)
    box.BackgroundColor3 = defaultOn and C.Green or Color3.fromRGB(60, 60, 70)
    box.BorderSizePixel = 0
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 2)

    local check = Instance.new("TextLabel", box)
    check.Size = UDim2.new(1, 0, 1, 0)
    check.BackgroundTransparency = 1
    check.Font = Enum.Font.GothamBold
    check.Text = "✓"
    check.TextColor3 = C.BG
    check.TextSize = 9
    check.Visible = defaultOn

    local lbl = Instance.new("TextLabel", fr)
    lbl.Size = UDim2.new(1, -40, 1, 0)
    lbl.Position = UDim2.new(0, 22, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamSemibold
    lbl.Text = text
    lbl.TextColor3 = C.Text
    lbl.TextSize = 8
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd

    local stateLbl = Instance.new("TextLabel", fr)
    stateLbl.Size = UDim2.new(0, 30, 1, 0)
    stateLbl.Position = UDim2.new(1, -34, 0, 0)
    stateLbl.BackgroundTransparency = 1
    stateLbl.Font = Enum.Font.GothamBold
    stateLbl.Text = defaultOn and "ON" or "OFF"
    stateLbl.TextColor3 = defaultOn and C.Green or C.Red
    stateLbl.TextSize = 8
    stateLbl.TextXAlignment = Enum.TextXAlignment.Right

    local state = defaultOn
    local click = Instance.new("TextButton", fr)
    click.Size = UDim2.new(1, 0, 1, 0)
    click.BackgroundTransparency = 1
    click.Text = ""
    click.MouseButton1Click:Connect(function()
        state = not state
        if state then
            box.BackgroundColor3 = C.Green
            check.Visible = true
            stateLbl.Text = "ON"
            stateLbl.TextColor3 = C.Green
        else
            box.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            check.Visible = false
            stateLbl.Text = "OFF"
            stateLbl.TextColor3 = C.Red
        end
        pcall(callback, state)
    end)

    return fr, {
        SetState = function(newState)
            state = newState
            if state then
                box.BackgroundColor3 = C.Green
                check.Visible = true
                stateLbl.Text = "ON"
                stateLbl.TextColor3 = C.Green
            else
                box.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                check.Visible = false
                stateLbl.Text = "OFF"
                stateLbl.TextColor3 = C.Red
            end
        end,
        GetState = function() return state end
    }
end

local function CreateSlider(parent, text, min, max, default, callback)
    local fr = Instance.new("Frame", parent)
    fr.Size = UDim2.new(1, 0, 0, 28)
    fr.BackgroundColor3 = C.Btn
    fr.BorderSizePixel = 0
    Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 4)

    local lbl = Instance.new("TextLabel", fr)
    lbl.Size = UDim2.new(0.65, -8, 0, 11)
    lbl.Position = UDim2.new(0, 4, 0, 1)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamMedium
    lbl.Text = text
    lbl.TextColor3 = C.Text2
    lbl.TextSize = 8
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd

    local valLbl = Instance.new("TextLabel", fr)
    valLbl.Size = UDim2.new(0.35, -8, 0, 11)
    valLbl.Position = UDim2.new(0.65, 4, 0, 1)
    valLbl.BackgroundTransparency = 1
    valLbl.Font = Enum.Font.GothamBold
    valLbl.Text = tostring(default)
    valLbl.TextColor3 = C.Gold
    valLbl.TextSize = 8
    valLbl.TextXAlignment = Enum.TextXAlignment.Right

    local bar = Instance.new("Frame", fr)
    bar.Size = UDim2.new(1, -8, 0, 5)
    bar.Position = UDim2.new(0, 4, 0, 16)
    bar.BackgroundColor3 = C.BG
    bar.BorderSizePixel = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = C.Gold
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", fill)
    knob.Size = UDim2.new(0, 8, 0, 8)
    knob.Position = UDim2.new(1, -4, 0.5, -4)
    knob.BackgroundColor3 = C.Text
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local touchHeight = IS_MOBILE and 22 or 20
    local touch = Instance.new("TextButton", fr)
    touch.Size = UDim2.new(1, -4, 0, touchHeight)
    touch.Position = UDim2.new(0, 2, 0, 3)
    touch.BackgroundTransparency = 1
    touch.Text = ""

    local dragging = false
    local function update(i)
        local p = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local v = math.floor(min + (max - min) * p)
        fill.Size = UDim2.new(p, 0, 1, 0)
        valLbl.Text = tostring(v)
        pcall(callback, v)
    end

    touch.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; update(i)
        end
    end)
    UI.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            update(i)
        end
    end)
    UI.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    return fr
end

local function CreateLabel(parent, text, color)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, 0, 0, 12)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamMedium
    lbl.Text = text
    lbl.TextColor3 = color or C.Text2
    lbl.TextSize = 8
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true
    return lbl
end

----------------------------------------------------------------
-- VARIABLES DE ESTADO
----------------------------------------------------------------
local SHon, SHv = false, 100
local EH = 10000
local HBCelesteOn, HBCelesteSize = false, 10
local HBCelesteConn
local HBGiantOn, HBGiantSize = false, 60000
local HBGiantConn
local HBGiantCache = {}
local GOT, GOC, GOd, GOs, GOh, GOang = nil, nil, 5, 3, 0, 0
local ESPon = false
local ESPboxes = {}
local AntiStunOn = false

----------------------------------------------------------------
-- STOP FLY (para uso interno)
----------------------------------------------------------------
local function StopFlyInternal()
    V3 = false
    local c = LP.Character
    local h = c and c:FindFirstChild("HumanoidRootPart")
    local hu = c and c:FindFirstChildOfClass("Humanoid")
    if h then
        pcall(function()
            local bv = h:FindFirstChild("BodyVelocity"); if bv then bv:Destroy() end
            local bg = h:FindFirstChild("BodyGyro"); if bg then bg:Destroy() end
        end)
    end
    if hu then pcall(function() hu.PlatformStand = false end) end
    if FlyBtn then
        FlyBtn.Text = "✈ FLY: OFF"
        FlyBtn.BackgroundColor3 = C.BG
        FlyBtn.TextColor3 = C.Gold
    end
    if FlyStatusRef then
        FlyStatusRef.SetState(false)
    end
end

----------------------------------------------------------------
-- ✈️ FLY POR JOYSTICK (PC + Móvil)
----------------------------------------------------------------
local function StartFlyInternal()
    if V3 then return end

    if MapOrbitOn then
        MapOrbitOn = false
        if MapOrbitConn then MapOrbitConn:Disconnect() MapOrbitConn = nil end
        if MapOrbitStatusRef then MapOrbitStatusRef.SetState(false) end
    end

    V3 = true
    task.spawn(function()
        local c = LP.Character or LP.CharacterAdded:Wait()
        local h = c:WaitForChild("HumanoidRootPart", 5)
        local hu = c:FindFirstChildOfClass("Humanoid")
        if not h or not hu then V3 = false; return end

        local bv = Instance.new("BodyVelocity", h)
        bv.MaxForce = Vector3.new(1e10, 1e10, 1e10)
        bv.Velocity = Vector3.zero

        local bg = Instance.new("BodyGyro", h)
        bg.MaxTorque = Vector3.new(1e10, 1e10, 1e10)
        bg.P = 9e4
        bg.CFrame = h.CFrame

        hu.PlatformStand = true

        local cn
        cn = RS.RenderStepped:Connect(function()
            if not V3 or not h.Parent or not LP.Character or LP.Character ~= c then
                cn:Disconnect()
                pcall(function() if bv then bv:Destroy() end end)
                pcall(function() if bg then bg:Destroy() end end)
                pcall(function() if hu then hu.PlatformStand = false end end)
                return
            end

            if not bv.Parent then
                bv = Instance.new("BodyVelocity", h)
                bv.MaxForce = Vector3.new(1e10, 1e10, 1e10)
            end
            if not bg.Parent then
                bg = Instance.new("BodyGyro", h)
                bg.MaxTorque = Vector3.new(1e10, 1e10, 1e10)
                bg.P = 9e4
            end
            if not hu.PlatformStand then hu.PlatformStand = true end

            bg.CFrame = Cam.CFrame

            local moveInput = Vector3.zero
            if PC then
                local ok, v3 = pcall(function() return PC:GetMoveVector() end)
                if ok and v3 then moveInput = v3 end
            end

            if moveInput.Magnitude < 0.05 then
                bv.Velocity = Vector3.zero
            else
                local camCF = Cam.CFrame
                local moveDir = (camCF.LookVector * -moveInput.Z) + (camCF.RightVector * moveInput.X)

                if moveDir.Magnitude > 0.05 then
                    bv.Velocity = moveDir.Unit * VSpd
                else
                    bv.Velocity = Vector3.zero
                end
            end
        end)
    end)
end

----------------------------------------------------------------
-- 🪐 ORBIT MAPA
----------------------------------------------------------------
local function StartMapOrbit()
    if MapOrbitConn then return end

    if V3 then
        V3 = false
        if FlyStatusRef then FlyStatusRef.SetState(false) end
        if FlyBtn then
            FlyBtn.Text = "✈ FLY: OFF"
            FlyBtn.BackgroundColor3 = C.BG
            FlyBtn.TextColor3 = C.Gold
        end
    end

    MapOrbitOn = true
    MapOrbitAngle = 0

    task.spawn(function()
        local c = LP.Character or LP.CharacterAdded:Wait()
        local h = c:WaitForChild("HumanoidRootPart", 5)
        local hu = c:FindFirstChildOfClass("Humanoid")
        if not h or not hu then MapOrbitOn = false; return end

        hu.PlatformStand = true

        local centerX, centerZ = 0, 0

        MapOrbitConn = RS.Heartbeat:Connect(function(dt)
            if not MapOrbitOn or not h.Parent or not LP.Character or LP.Character ~= c then
                if MapOrbitConn then MapOrbitConn:Disconnect() MapOrbitConn = nil end
                pcall(function() if hu then hu.PlatformStand = false end end)
                return
            end

            if not hu.PlatformStand then hu.PlatformStand = true end

            local angularVelocity = MapOrbitSpeed / math.max(MapOrbitRadius, 1)
            if angularVelocity > 20 then angularVelocity = 20 end

            MapOrbitAngle = MapOrbitAngle + angularVelocity * dt
            if MapOrbitAngle > math.pi * 2 then
                MapOrbitAngle = MapOrbitAngle - math.pi * 2
            end

            local x = centerX + math.cos(MapOrbitAngle) * MapOrbitRadius
            local z = centerZ + math.sin(MapOrbitAngle) * MapOrbitRadius
            local targetPos = Vector3.new(x, MapOrbitHeight, z)

            local lookAt = Vector3.new(centerX, MapOrbitHeight, centerZ)
            h.CFrame = CFrame.new(targetPos, lookAt)
        end)
    end)
end

local function StopMapOrbit()
    MapOrbitOn = false
    if MapOrbitConn then
        MapOrbitConn:Disconnect()
        MapOrbitConn = nil
    end
    local c = LP.Character
    local h = c and c:FindFirstChild("HumanoidRootPart")
    local hu = c and c:FindFirstChildOfClass("Humanoid")
    if h then
        pcall(function()
            local bv = h:FindFirstChild("BodyVelocity"); if bv then bv:Destroy() end
            local bg = h:FindFirstChild("BodyGyro"); if bg then bg:Destroy() end
        end)
    end
    if hu then pcall(function() hu.PlatformStand = false end) end
end

----------------------------------------------------------------
-- GOD ORB
----------------------------------------------------------------
local function StopGO()
    GOT = nil; GOang = 0
    if GOC then GOC:Disconnect(); GOC = nil end
end

local function StartGO(plr)
    GOT = plr; GOang = 0
    if GOC then GOC:Disconnect() end
    GOC = RS.Heartbeat:Connect(function(dt)
        if not GOT then return end
        local tc = GOT.Character
        local mc = LP.Character
        local th = tc and tc:FindFirstChild("HumanoidRootPart")
        local mh = mc and mc:FindFirstChild("HumanoidRootPart")
        local thu = tc and tc:FindFirstChildOfClass("Humanoid")
        if not th or not mh or not thu or thu.Health <= 0 then StopGO(); return end
        GOang = GOang + GOs * dt
        if GOang > math.pi * 2 then GOang = GOang - math.pi * 2 end
        local off = Vector3.new(math.cos(GOang) * GOd, GOh, math.sin(GOang) * GOd)
        mh.CFrame = CFrame.new(th.Position + off, th.Position) * CFrame.Angles(0, math.pi, 0)
    end)
end

----------------------------------------------------------------
-- HITBOX
----------------------------------------------------------------
local function StartCeleste()
    if HBCelesteConn then return end
    local function apply()
        for _, plr in ipairs(P:GetPlayers()) do pcall(function()
            if plr == LP then return end
            local c = plr.Character
            local h = c and c:FindFirstChild("HumanoidRootPart")
            if not h or not h:IsA("Part") then return end
            h.Size = Vector3.new(HBCelesteSize, HBCelesteSize, HBCelesteSize)
            h.Transparency = 0.5
            h.Color = Color3.fromRGB(0, 230, 255)
            h.Material = Enum.Material.Neon
            h.Shape = Enum.PartType.Ball
            h.CanCollide = false
        end) end
    end
    apply()
    HBCelesteConn = task.spawn(function()
        while HBCelesteOn do task.wait(0.5); apply() end
    end)
end

local function StopCeleste()
    HBCelesteOn = false
    HBCelesteConn = nil
    for _, plr in ipairs(P:GetPlayers()) do pcall(function()
        local c = plr.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        if not h or not h:IsA("Part") then return end
        h.Size = Vector3.new(2, 2, 1)
        h.Transparency = 1
        h.Shape = Enum.PartType.Block
        h.CanCollide = false
        h.Material = Enum.Material.Plastic
        h.Color = Color3.fromRGB(255, 255, 0)
    end) end
end

local function StartGiant()
    if HBGiantConn then return end
    local function apply()
        for _, plr in ipairs(P:GetPlayers()) do pcall(function()
            if plr == LP then return end
            local c = plr.Character
            local h = c and c:FindFirstChild("HumanoidRootPart")
            if not h or not h:IsA("Part") then return end
            if not HBGiantCache[plr] then
                HBGiantCache[plr] = {Size=h.Size, Transparency=h.Transparency, CanCollide=h.CanCollide, Shape=h.Shape, Material=h.Material, Color=h.Color}
            end
            h.Size = Vector3.new(HBGiantSize, HBGiantSize, HBGiantSize)
            h.Transparency = 1
            h.CanCollide = false
            h.Shape = Enum.PartType.Block
        end) end
    end
    apply()
    HBGiantConn = task.spawn(function()
        while HBGiantOn do task.wait(0.5); apply() end
    end)
end

local function StopGiant()
    HBGiantOn = false
    HBGiantConn = nil
    for _, plr in ipairs(P:GetPlayers()) do pcall(function()
        local c = plr.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        if not h or not h:IsA("Part") then return end
        local o = HBGiantCache[plr]
        if o then
            h.Size = o.Size
            h.Transparency = o.Transparency
            h.CanCollide = o.CanCollide
            h.Shape = o.Shape
            h.Material = o.Material
            h.Color = o.Color
        else
            h.Size = Vector3.new(2, 2, 1)
            h.Transparency = 1
            h.CanCollide = false
            h.Shape = Enum.PartType.Block
        end
    end) end
    HBGiantCache = {}
end

P.PlayerRemoving:Connect(function(plr) HBGiantCache[plr] = nil end)

----------------------------------------------------------------
-- CREAR COLUMNAS
----------------------------------------------------------------
local Col1 = CreateColumn(ColumnsFrame, 158)
local Col2 = CreateColumn(ColumnsFrame, 158)
local Col3 = CreateColumn(ColumnsFrame, 158)

----------------------------------------------------------------
-- COLUMNA 1
----------------------------------------------------------------
do
    local boxPlayers = CreateBox(Col1, "JUGADORES", "👥")
    local TargetLbl = Instance.new("TextLabel", boxPlayers)
    TargetLbl.Size = UDim2.new(1, 0, 0, 18)
    TargetLbl.BackgroundColor3 = C.Btn
    TargetLbl.Font = Enum.Font.GothamBold
    TargetLbl.Text = "Target: Ninguno"
    TargetLbl.TextColor3 = C.Gold
    TargetLbl.TextSize = 8
    TargetLbl.TextXAlignment = Enum.TextXAlignment.Center
    Instance.new("UICorner", TargetLbl).CornerRadius = UDim.new(0, 3)

    local PlayerListFrame = Instance.new("Frame", boxPlayers)
    PlayerListFrame.Size = UDim2.new(1, 0, 0, 70)
    PlayerListFrame.BackgroundTransparency = 1

    local PlayerScroll = Instance.new("ScrollingFrame", PlayerListFrame)
    PlayerScroll.Size = UDim2.new(1, 0, 1, 0)
    PlayerScroll.BackgroundTransparency = 1
    PlayerScroll.BorderSizePixel = 0
    PlayerScroll.ScrollBarThickness = 2
    PlayerScroll.ScrollBarImageColor3 = C.Gold
    PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    pcall(function() PlayerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y end)
    Instance.new("UIListLayout", PlayerScroll).Padding = UDim.new(0, 2)

    local function PopulatePlayerList()
        pcall(function()
            for _, c in ipairs(PlayerScroll:GetChildren()) do
                if c:IsA("TextButton") then c:Destroy() end
            end
            for _, plr in ipairs(P:GetPlayers()) do
                if plr ~= LP then
                    local b = Instance.new("TextButton", PlayerScroll)
                    b.Size = UDim2.new(1, -4, 0, 20)
                    b.BackgroundColor3 = C.Btn
                    b.Font = Enum.Font.GothamMedium
                    b.Text = "👤 " .. plr.DisplayName
                    b.TextColor3 = C.Text
                    b.TextSize = 8
                    b.BorderSizePixel = 0
                    b.AutoButtonColor = false
                    b.TextXAlignment = Enum.TextXAlignment.Left
                    b.TextTruncate = Enum.TextTruncate.AtEnd
                    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 3)
                    b.MouseButton1Click:Connect(function()
                        if GOT == plr then
                            StopGO()
                            b.BackgroundColor3 = C.Btn
                            b.TextColor3 = C.Text
                            TargetLbl.Text = "Target: Ninguno"
                        else
                            StartGO(plr)
                            for _, other in ipairs(PlayerScroll:GetChildren()) do
                                if other:IsA("TextButton") then
                                    other.BackgroundColor3 = C.Btn
                                    other.TextColor3 = C.Text
                                end
                            end
                            b.BackgroundColor3 = C.Gold
                            b.TextColor3 = C.BG
                            TargetLbl.Text = "Target: " .. plr.DisplayName
                        end
                    end)
                end
            end
        end)
    end

    P.PlayerAdded:Connect(function() task.wait(0.1); PopulatePlayerList() end)
    P.PlayerRemoving:Connect(function() task.wait(0.1); PopulatePlayerList() end)
    task.spawn(PopulatePlayerList)

    local boxOrb = CreateBox(Col1, "GOD ORB", "🌀")
    CreateSlider(boxOrb, "Distancia", 2, 30, 5, function(v) GOd = v end)
    CreateSlider(boxOrb, "Velocidad", 1, 20, 3, function(v) GOs = v end)
    CreateSlider(boxOrb, "Altura", 0, 20, 0, function(v) GOh = v end)
    CreateButton(boxOrb, "🛑 Detener", C.Text, function()
        StopGO()
        TargetLbl.Text = "Target: Ninguno"
        PopulatePlayerList()
    end)
end

----------------------------------------------------------------
-- COLUMNA 2
----------------------------------------------------------------
do
    local boxCeleste = CreateBox(Col2, "HITBOX CELESTE", "🔵")
    CreateStatus(boxCeleste, "Activar", false, function(v)
        HBCelesteOn = v
        if v then StartCeleste() else StopCeleste() end
    end)
    CreateSlider(boxCeleste, "Tamaño", 2, 50, 10, function(v) HBCelesteSize = v end)

    local boxGiant = CreateBox(Col2, "HITBOX GIGANTE", "🔴")
    CreateStatus(boxGiant, "Activar", false, function(v)
        HBGiantOn = v
        if v then StartGiant() else StopGiant() end
    end)
    CreateSlider(boxGiant, "Tamaño", 1000, 100000, 60000, function(v) HBGiantSize = v end)

    local boxESP = CreateBox(Col2, "ESP", "👁")
    CreateStatus(boxESP, "Activar ESP", false, function(v)
        ESPon = v
        if v then
            if not HAS_DRAWING then
                ESPon = false
                return
            end
            for _, plr in ipairs(P:GetPlayers()) do
                if plr ~= LP and not ESPboxes[plr] then
                    local ok, box, txt = pcall(function()
                        local b = Drawing.new("Square")
                        b.Thickness = 1.5; b.Filled = false; b.Visible = false; b.Color = C.Gold
                        local t = Drawing.new("Text")
                        t.Size = 13; t.Center = true; t.Outline = true
                        t.OutlineColor = Color3.fromRGB(0, 0, 0); t.Color = C.Gold; t.Visible = false
                        return b, t
                    end)
                    if ok then ESPboxes[plr] = {box = box, txt = txt} end
                end
            end
        else
            for _, d in pairs(ESPboxes) do
                pcall(function() if d.box then d.box.Visible = false end end)
                pcall(function() if d.txt then d.txt.Visible = false end end)
            end
        end
    end)

    local boxFly = CreateBox(Col2, "FLY (JOYSTICK)", "✈")
    _, FlyStatusRef = CreateStatus(boxFly, "Activar Fly", false, function(v)
        if v then StartFlyInternal() else StopFlyInternal() end
    end)
    CreateSlider(boxFly, "Velocidad", 100, 1000000, 100000, function(v) VSpd = v end)
    CreateLabel(boxFly, "Vuela hacia donde apunta el joystick", C.Text2)
    if IS_PC then
        CreateLabel(boxFly, "PC: usa WASD para volar", C.Text2)
    else
        CreateLabel(boxFly, "Móvil: mueve el joystick", C.Text2)
    end
end

----------------------------------------------------------------
-- COLUMNA 3
----------------------------------------------------------------
do
    local boxMapOrbit = CreateBox(Col3, "ORBIT MAPA", "🪐")
    _, MapOrbitStatusRef = CreateStatus(boxMapOrbit, "Activar", false, function(v)
        if v then StartMapOrbit() else StopMapOrbit() end
    end)
    CreateSlider(boxMapOrbit, "Velocidad", 500, 20000, 3000, function(v) MapOrbitSpeed = v end)
    CreateSlider(boxMapOrbit, "Radio", 50, 1000, 300, function(v) MapOrbitRadius = v end)
    CreateSlider(boxMapOrbit, "Altura", 10, 1000, 100, function(v) MapOrbitHeight = v end)

    local boxSpeed = CreateBox(Col3, "SPEEDHACK", "🏃")
    CreateStatus(boxSpeed, "Activar", false, function(v) SHon = v end)
    CreateSlider(boxSpeed, "Velocidad", 16, 500, 100, function(v) SHv = v end)

    local boxFuga = CreateBox(Col3, "FUGA", "🚀")
    CreateButton(boxFuga, "🚀 Ejecutar Fuga", C.Gold, function()
        local c = LP.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        if h then h.CFrame = h.CFrame + Vector3.new(0, EH, 0) end
    end)
    CreateSlider(boxFuga, "Altura", 1000, 50000, 10000, function(v) EH = v end)

    local boxFloat = CreateBox(Col3, "BOTONES FLOTANTES", "🎯")
    CreateStatus(boxFloat, "Mostrar Botón Fly", true, function(v)
        ShowFlyButton = v
        if FlyBtn then FlyBtn.Visible = v end
    end)
    CreateStatus(boxFloat, "Mostrar Botón Fuga", true, function(v)
        ShowFugaButton = v
        if FugaBtn then FugaBtn.Visible = v end
    end)

    local boxStun = CreateBox(Col3, "ANTI-STUN", "🛡")
    CreateStatus(boxStun, "Activar", false, function(v) AntiStunOn = v end)

    local boxCredits = CreateBox(Col3, "CRÉDITOS", "👑")
    CreateLabel(boxCredits, "GatoGold", C.Gold)
    CreateLabel(boxCredits, "TLG North America", C.Text2)
    CreateLabel(boxCredits, "TLG Team © 2025", C.Text2)
end

----------------------------------------------------------------
-- LOOPS
----------------------------------------------------------------
RS.RenderStepped:Connect(function()
    if SHon then
        local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = SHv end
    end
end)

RS.RenderStepped:Connect(function()
    if AntiStunOn then
        local c = LP.Character
        if not c then return end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        pcall(function()
            if not V3 and not MapOrbitOn then hum.PlatformStand = false end
            hum.Sit = false
            hum.AutoRotate = true
            hum.WalkSpeed = math.max(hum.WalkSpeed, 16)
            hum.JumpPower = 50
            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
        end)
    end
end)

RS.RenderStepped:Connect(function()
    if not ESPon then return end
    for plr, d in pairs(ESPboxes) do
        pcall(function()
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if char and hrp and hum and hum.Health > 0 then
                local _, onScreen = Cam:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local rp = Cam:WorldToViewportPoint(hrp.Position)
                    local hp = Cam:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
                    local lp = Cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.5, 0))
                    local hh = math.abs(hp.Y - lp.Y)
                    local w = hh / 1.8
                    d.box.Size = Vector2.new(w, hh)
                    d.box.Position = Vector2.new(rp.X - w/2, rp.Y - hh/2)
                    d.box.Visible = true
                    local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                    local dist = myHrp and math.floor((hrp.Position - myHrp.Position).Magnitude) or 0
                    d.txt.Text = plr.DisplayName .. " | " .. math.floor(hum.Health) .. "hp | [" .. dist .. "m]"
                    d.txt.Position = Vector2.new(rp.X, rp.Y - hh/2 - 16)
                    d.txt.Visible = true
                else
                    d.box.Visible = false; d.txt.Visible = false
                end
            else
                d.box.Visible = false; d.txt.Visible = false
            end
        end)
    end
end)

----------------------------------------------------------------
-- BOTONES FLOTANTES
----------------------------------------------------------------
local FloatSG = Instance.new("ScreenGui", SP)
FloatSG.Name = "TLG_FloatButtons"
FloatSG.ResetOnSpawn = false
FloatSG.DisplayOrder = 999
FloatSG.IgnoreGuiInset = true

-- MENU
local MenuBtn = Instance.new("TextButton", FloatSG)
MenuBtn.Size = UDim2.new(0, 42, 0, 42)
MenuBtn.Position = UDim2.new(0.02, 0, 0.05, 0)
MenuBtn.BackgroundColor3 = C.Gold
MenuBtn.TextColor3 = C.BG
MenuBtn.Text = "✕"
MenuBtn.Font = Enum.Font.GothamBold
MenuBtn.TextSize = 16
MenuBtn.BorderSizePixel = 0
MenuBtn.AutoButtonColor = false
Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(0, 21)
Instance.new("UIStroke", MenuBtn).Color = C.BG

local menuWasDragged = MakeButtonDraggable(MenuBtn)

local MenuOpen = true
local function CloseMenu()
    MenuOpen = false
    pcall(function()
        TS:Create(Window, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
    end)
    MenuBtn.Text = "☰"
    MenuBtn.BackgroundColor3 = C.BG
    MenuBtn.TextColor3 = C.Gold
end
local function OpenMenu()
    MenuOpen = true
    Window.Size = UDim2.new(0, 0, 0, 0)
    Window.Position = UDim2.new(0.5, 0, 0.5, 0)
    pcall(function()
        TS:Create(Window, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = W_SIZE, Position = W_POS}):Play()
    end)
    MenuBtn.Text = "✕"
    MenuBtn.BackgroundColor3 = C.Gold
    MenuBtn.TextColor3 = C.BG
end
MenuBtn.MouseButton1Click:Connect(function()
    if menuWasDragged() then return end
    if MenuOpen then CloseMenu() else OpenMenu() end
end)
CloseBtn.MouseButton1Click:Connect(CloseMenu)

-- FLY
FlyBtn = Instance.new("TextButton", FloatSG)
FlyBtn.Size = UDim2.new(0, 95, 0, 42)
FlyBtn.Position = UDim2.new(0.02, 0, 0.55, 0)
FlyBtn.BackgroundColor3 = C.BG
FlyBtn.TextColor3 = C.Gold
FlyBtn.Text = "✈ FLY: OFF"
FlyBtn.Font = Enum.Font.GothamBold
FlyBtn.TextSize = 12
FlyBtn.BorderSizePixel = 0
FlyBtn.AutoButtonColor = false
FlyBtn.Visible = true
Instance.new("UICorner", FlyBtn).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", FlyBtn).Color = C.Gold
Instance.new("UIStroke", FlyBtn).Thickness = 1.5

local flyWasDragged = MakeButtonDraggable(FlyBtn)

FlyBtn.MouseButton1Click:Connect(function()
    if flyWasDragged() then return end
    if V3 then
        StopFlyInternal()
    else
        StartFlyInternal()
        FlyBtn.Text = "✈ FLY: ON"
        FlyBtn.BackgroundColor3 = C.Gold
        FlyBtn.TextColor3 = C.BG
    end
end)

-- FUGA
FugaBtn = Instance.new("TextButton", FloatSG)
FugaBtn.Size = UDim2.new(0, 95, 0, 42)
FugaBtn.Position = UDim2.new(0.02, 0, 0.63, 0)
FugaBtn.BackgroundColor3 = C.BG
FugaBtn.TextColor3 = C.Gold
FugaBtn.Text = "🚀 FUGA"
FugaBtn.Font = Enum.Font.GothamBold
FugaBtn.TextSize = 12
FugaBtn.BorderSizePixel = 0
FugaBtn.AutoButtonColor = false
FugaBtn.Visible = true
Instance.new("UICorner", FugaBtn).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", FugaBtn).Color = C.Gold
Instance.new("UIStroke", FugaBtn).Thickness = 1.5

local fugaWasDragged = MakeButtonDraggable(FugaBtn)

FugaBtn.MouseButton1Click:Connect(function()
    if fugaWasDragged() then return end
    local c = LP.Character
    if not c then return end
    local h = c:FindFirstChild("HumanoidRootPart")
    if not h then return end
    h.CFrame = h.CFrame + Vector3.new(0, EH, 0)
    FugaBtn.BackgroundColor3 = C.Gold
    FugaBtn.TextColor3 = C.BG
    task.delay(0.2, function()
        if FugaBtn and FugaBtn.Parent then
            FugaBtn.BackgroundColor3 = C.BG
            FugaBtn.TextColor3 = C.Gold
        end
    end)
end)

----------------------------------------------------------------
-- ABRIR
----------------------------------------------------------------
Window.Size = UDim2.new(0, 0, 0, 0)
Window.Position = UDim2.new(0.5, 0, 0.5, 0)
task.wait(0.05)
pcall(function()
    TS:Create(Window, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=W_SIZE, Position=W_POS}):Play()
end)

local platform = IS_MOBILE and "Móvil 📱" or "PC 💻"
print("[TLG Gold Hub] Cargado ✓ - Plataforma: " .. platform)
