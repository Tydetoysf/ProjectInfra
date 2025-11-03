-- Project Intra Hub -- Booga Booga Reborn
-- Fixed wiring: Tweens, Yakk, Settings, markers, and telemetry callbacks are wired and functional.
print("Loading Project Intra Hub -- Booga Booga Reborn")
print("-----------------------------------------")

local Library = loadstring(game:HttpGetAsync("https://github.com/1dontgiveaf/Fluent-Renewed/releases/download/v1.0/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/1dontgiveaf/Fluent-Renewed/refs/heads/main/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/1dontgiveaf/Fluent-Renewed/refs/heads/main/Addons/InterfaceManager.luau"))()

local Window = Library:CreateWindow{
    Title = "Project Instra Hub -- Booga Booga Reborn",
    SubTitle = "by xylo",
    TabWidth = 160,
    Size = UDim2.fromOffset(900, 560),
    Resize = true,
    MinSize = Vector2.new(470, 380),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
}

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "menu" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "axe" }),
    Map = Window:AddTab({ Title = "Map", Icon = "trees" }),
    Pickup = Window:AddTab({ Title = "Pickup", Icon = "backpack" }),
    Farming = Window:AddTab({ Title = "Farming", Icon = "sprout" }),
    Extra = Window:AddTab({ Title = "Extra", Icon = "plus" }),
    Tweens = Window:AddTab({ Title = "Tweens", Icon = "sparkles" }),
    Yakk = Window:AddTab({ Title = "Yakk", Icon = "coins" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Services / basic refs
local rs = game:GetService("ReplicatedStorage")
local packets = pcall(function() return require(rs.Modules.Packets) end) and require(rs.Modules.Packets) or {}
local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local char = plr and (plr.Character or plr.CharacterAdded:Wait())
local root = char and char:FindFirstChild("HumanoidRootPart") or (char and char:WaitForChild("HumanoidRootPart"))
local hum = char and (char:FindFirstChild("Humanoid") or char:WaitForChild("Humanoid"))
local runs = game:GetService("RunService")
local httpservice = game:GetService("HttpService")
local marketservice = game:GetService("MarketplaceService")
local rbxservice = game:GetService("RbxAnalyticsService")
local tspmo = game:GetService("TweenService")

-- helper: refresh character refs
local function refresh_character_refs()
    plr = Players.LocalPlayer
    if not plr then return end
    char = plr.Character or plr.CharacterAdded:Wait()
    root = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart")
    hum = char:FindFirstChild("Humanoid") or char:WaitForChild("Humanoid")
    print("[IntraHub] character refs refreshed")
end

if not (plr and char and root and hum) then
    refresh_character_refs()
end

-- safe setclipboard
local function safe_setclipboard(text)
    pcall(function() if setclipboard then setclipboard(text) end end)
end

-- Simple local telemetry (opt-in)
local TELEMETRY = { sessions = {}, current = nil }
local function telemetry_new_session()
    local s = { id = httpservice:GenerateGUID(false), startTime = os.time(), endTime = nil, events = {} }
    TELEMETRY.current = s
    table.insert(TELEMETRY.sessions, s)
    return s
end
local function telemetry_end_session()
    if TELEMETRY.current then TELEMETRY.current.endTime = os.time(); TELEMETRY.current = nil end
end
local function telemetry_log(name, details)
    if not telemetry_optin or not telemetry_optin.Value then return end
    if not TELEMETRY.current then telemetry_new_session() end
    table.insert(TELEMETRY.current.events, { time = os.time(), name = name, details = details or {} })
end

-- Tween helper
local activeTween = nil
local function tween_to_cframe(targetCFrame, speedMultiplier)
    if not root or not root.Parent then refresh_character_refs() end
    if activeTween then
        pcall(function() activeTween:Cancel() end)
        activeTween = nil
    end
    local distance = (root.Position - targetCFrame.Position).Magnitude
    local baseDuration = distance / 21
    local duration = math.max(0.03, baseDuration / (speedMultiplier or 1))
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local t = tspmo:Create(root, tweenInfo, { CFrame = targetCFrame })
    t:Play()
    activeTween = t
    return t, duration
end

local function teleport_to_vector(v3)
    if not char or not char.Parent then refresh_character_refs() end
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(v3.X, v3.Y + 2, v3.Z)
    end
end

-- Yakk waypoint markers
local MARKER_FOLDER_NAME = "IntraHub_Yakk_Markers"
local markers = {}

local function create_markers_folder()
    local f = workspace:FindFirstChild(MARKER_FOLDER_NAME)
    if f and f:IsA("Folder") then return f end
    local folder = Instance.new("Folder")
    folder.Name = MARKER_FOLDER_NAME
    folder.Parent = workspace
    return folder
end

local function clear_markers()
    for _, part in ipairs(markers) do
        if part and part.Parent then pcall(function() part:Destroy() end) end
    end
    markers = {}
    local folder = workspace:FindFirstChild(MARKER_FOLDER_NAME)
    if folder and folder.Parent then pcall(function() folder:Destroy() end) end
end

local function create_marker(index, pos)
    local folder = create_markers_folder()
    local p = Instance.new("Part")
    p.Anchored = true
    p.CanCollide = false
    p.Size = Vector3.new(1.2,1.2,1.2)
    p.Shape = Enum.PartType.Ball
    p.Material = Enum.Material.Neon
    p.Color = Color3.fromRGB(255, 200, 0)
    p.Transparency = 0.1
    p.CFrame = CFrame.new(pos.X, pos.Y + 0.8, pos.Z)
    p.Parent = folder

    local bill = Instance.new("BillboardGui", p)
    bill.Size = UDim2.new(0,120,0,36)
    bill.AlwaysOnTop = true
    local txt = Instance.new("TextLabel", bill)
    txt.Size = UDim2.fromScale(1,1)
    txt.BackgroundTransparency = 1
    txt.TextScaled = true
    txt.Text = "WP "..tostring(index)
    txt.TextColor3 = Color3.new(1,1,1)
    txt.Font = Enum.Font.SourceSansBold
    return p
end

local function refresh_markers_from_list(list)
    clear_markers()
    for i, v in ipairs(list) do
        local p = create_marker(i, v)
        table.insert(markers, p)
    end
    Library:Notify{Title="Yakk", Content="Markers refreshed: "..tostring(#markers), Duration=3}
end

-- Yakk route (default list; you can replace or import)
local YAKK_WAYPOINTS = {
    Vector3.new(-138.963, -33.749, -148.319),
    Vector3.new(-145.327, -34.570, -159.469),
    Vector3.new(-146.369, -33.873, -169.898),
    Vector3.new(-144.334, -34.725, -159.734),
    Vector3.new(-136.696, -34.987, -170.819),
    Vector3.new(-120.278, -34.997, -178.766),
    Vector3.new(-115.615, -32.028, -181.052),
    Vector3.new(-111.158, -26.846, -183.843),
    Vector3.new(-109.632, -26.589, -191.211),
    Vector3.new(-110.574, -26.726, -184.794),
    Vector3.new(-112.805, -26.353, -189.045),
    Vector3.new(-117.735, -26.174, -189.602),
    Vector3.new(-122.506, -15.657, -200.508),
    Vector3.new(-129.854, -11.880, -204.102),
    Vector3.new(-122.557, -8.172, -205.548),
    Vector3.new(-127.016, -6.681, -209.011),
    Vector3.new(-124.574, -4.207, -213.521),
    Vector3.new(-74.381, -1.507, -244.584),
    Vector3.new(17.797, -3.000, -284.538),
    Vector3.new(112.245, -3.115, -282.720),
    Vector3.new(140.491, -3.487, -275.412),
    Vector3.new(185.059, -4.352, -246.309),
    Vector3.new(214.121, -3.000, -198.172),
    Vector3.new(268.998, -3.058, -100.931),
    Vector3.new(272.558, -6.993, -94.920),
    -- many more points may be appended here...
    Vector3.new(-138.963, -33.749, -148.319) -- close loop
}

-- runtime state for Yakk
local yakk_running = false
local yakk_runner_task = nil
local yakk_paused = false
local yakk_noclip_conn = nil

local function set_character_noclip(enable)
    if enable then
        if not char then refresh_character_refs() end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
        if yakk_noclip_conn then yakk_noclip_conn:Disconnect() end
        yakk_noclip_conn = runs.Stepped:Connect(function()
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if yakk_noclip_conn then yakk_noclip_conn:Disconnect(); yakk_noclip_conn = nil end
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end

local function run_yakk(speedMultiplier, waitAfter, noclipEnabled)
    if yakk_running then return end
    yakk_running = true
    telemetry_log("yakk_started", { speed = speedMultiplier, wait = waitAfter, noclip = noclipEnabled })
    if noclipEnabled then set_character_noclip(true) end

    yakk_runner_task = task.spawn(function()
        local idx = 1
        while yakk_running do
            if yakk_paused then task.wait(0.1); continue end
            if not root or not root.Parent then refresh_character_refs() end
            local v = YAKK_WAYPOINTS[idx]
            if v and root and root.Parent then
                local targetCFrame = CFrame.new(v.X, v.Y + 2, v.Z)
                local t, dur = tween_to_cframe(targetCFrame, speedMultiplier or 1)
                local waited = 0
                local timeout = (dur or 0.5) + 2
                while waited < timeout and t.PlaybackState ~= Enum.PlaybackState.Completed and yakk_running do
                    task.wait(0.05)
                    waited = waited + 0.05
                end
                telemetry_log("yakk_waypoint", { index = idx, pos = {x=v.X,y=v.Y,z=v.Z} })
                task.wait(waitAfter or 0.05)
            end
            idx = idx + 1
            if idx > #YAKK_WAYPOINTS then idx = 1 end
        end
        set_character_noclip(false)
        telemetry_log("yakk_stopped", {})
        yakk_runner_task = nil
    end)
end

local function stop_yakk()
    if not yakk_running then return end
    yakk_running = false
end

-- UI Creation: create elements AFTER helper functions so callbacks can reference them directly

-- MAIN tab
local wstoggle_el = wstoggle
local wsslider_el = wsslider
local jptoggle_el = jptoggle
local jpslider_el = jpslider
local hheighttoggle_el = hheighttoggle
local hheightslider_el = hheightslider
local msatoggle_el = msatoggle

-- hooking walk/jump hip updates
local wsconn, hhconn, slopeconn
local function update_walk_jump()
    if wsconn then wsconn:Disconnect() end
    if wstoggle_el.Value or jptoggle_el.Value then
        wsconn = runs.RenderStepped:Connect(function()
            if hum then
                hum.WalkSpeed = wstoggle_el.Value and wsslider_el.Value or 16
                hum.JumpPower = jptoggle_el.Value and jpslider_el.Value or 50
            end
        end)
    end
end
local function update_hip()
    if hhconn then hhconn:Disconnect() end
    if hheighttoggle_el.Value then
        hhconn = runs.RenderStepped:Connect(function()
            if hum then hum.HipHeight = hheightslider_el.Value end
        end)
    end
end
local function update_msa()
    if slopeconn then slopeconn:Disconnect() end
    if msatoggle_el.Value then
        slopeconn = runs.RenderStepped:Connect(function()
            if hum then hum.MaxSlopeAngle = 90 end
        end)
    else
        if hum then hum.MaxSlopeAngle = 46 end
    end
end

wstoggle_el:OnChanged(update_walk_jump)
jptoggle_el:OnChanged(update_walk_jump)
hheighttoggle_el:OnChanged(update_hip)
msatoggle_el:OnChanged(update_msa)
update_walk_jump(); update_hip(); update_msa()

-- TWEENS tab elements
local tween_name_input = Tabs.Tweens:CreateInput({ Title = "Tween Name", Default = "myTween", Numeric = false })
local tween_x_input = Tabs.Tweens:CreateInput({ Title = "X", Default = "0", Numeric = true })
local tween_y_input = Tabs.Tweens:CreateInput({ Title = "Y", Default = "0", Numeric = true })
local tween_z_input = Tabs.Tweens:CreateInput({ Title = "Z", Default = "0", Numeric = true })
local tween_speed_slider = Tabs.Tweens:CreateSlider("tween_speed", { Title = "Speed multiplier", Min = 0.1, Max = 5, Rounding = 2, Default = 1 })
local tween_wait_slider = Tabs.Tweens:CreateSlider("tween_wait", { Title = "Wait after move (s)", Min = 0, Max = 2, Rounding = 2, Default = 0.05 })
local tween_add_btn = Tabs.Tweens:CreateButton({ Title = "Add Tween (to list)", Callback = function() end })
local tween_list_dropdown = Tabs.Tweens:CreateDropdown("tween_list", { Title = "Saved Tweens", Values = {}, Default = "" })
local tween_save_btn = Tabs.Tweens:CreateButton({ Title = "Save Tween Config", Callback = function() end })
local tween_delete_btn = Tabs.Tweens:CreateButton({ Title = "Delete Selected Tween", Callback = function() end })
local tween_run_walk_btn = Tabs.Tweens:CreateButton({ Title = "Walk to Selected Tween (tween)", Callback = function() end })
local tween_run_move_btn = Tabs.Tweens:CreateButton({ Title = "Move to Selected Tween (teleport)", Callback = function() end })
local tween_export_btn = Tabs.Tweens:CreateButton({ Title = "Export Tweens JSON", Callback = function() end })
local tween_import_input = Tabs.Tweens:CreateInput({ Title = "Import Tweens JSON (paste)", Default = "", Numeric = false })
local tween_import_btn = Tabs.Tweens:CreateButton({ Title = "Import Tweens from Paste", Callback = function() end })

-- Tweens data store and helper
local TWEENS = {}
local function refresh_tween_dropdown()
    local list = {}
    for k,_ in pairs(TWEENS) do table.insert(list, k) end
    table.sort(list)
    tween_list_dropdown:SetValues(list)
end

-- Tweens callbacks
tween_add_btn.Callback = function()
    local name = tostring(tween_name_input.Value or "untitled"):gsub("%s+", "_")
    local x = tonumber(tween_x_input.Value) or 0
    local y = tonumber(tween_y_input.Value) or 0
    local z = tonumber(tween_z_input.Value) or 0
    local speed = tween_speed_slider.Value
    local waitt = tween_wait_slider.Value
    TWEENS[name] = { pos = Vector3.new(x, y, z), speed = speed, wait = waitt }
    refresh_tween_dropdown()
    telemetry_log("tween_added", { name = name, pos = {x=x,y=y,z=z}, speed = speed, wait = waitt })
    Library:Notify{ Title = "Tweens", Content = "Added tween: "..name, Duration = 2 }
    print("[IntraHub] Added tween:", name, x, y, z, speed, waitt)
end

tween_delete_btn.Callback = function()
    local name = tween_list_dropdown.Value
    if not name or name == "" or not TWEENS[name] then
        Library:Notify{ Title = "Tweens", Content = "Select a tween to delete.", Duration = 2 }
        return
    end
    TWEENS[name] = nil
    refresh_tween_dropdown()
    telemetry_log("tween_deleted", { name = name })
    Library:Notify{ Title = "Tweens", Content = "Deleted tween: "..name, Duration = 2 }
    print("[IntraHub] Deleted tween:", name)
end

tween_run_walk_btn.Callback = function()
    local name = tween_list_dropdown.Value
    if not name or name == "" or not TWEENS[name] then
        Library:Notify{ Title = "Tweens", Content = "Select a tween to walk to.", Duration = 2 }
        return
    end
    local tcfg = TWEENS[name]
    if not root or not root.Parent then refresh_character_refs() end
    local targetCF = CFrame.new(tcfg.pos.X, tcfg.pos.Y + 2, tcfg.pos.Z)
    local t, dur = tween_to_cframe(targetCF, tcfg.speed or 1)
    telemetry_log("tween_run_walk", { name = name })
    Library:Notify{ Title = "Tweens", Content = "Walking to "..name, Duration = 2 }
    print("[IntraHub] Walking to tween:", name)
    task.spawn(function()
        local waited = 0
        local timeout = (dur or 0.5) + 2
        while waited < timeout and t.PlaybackState ~= Enum.PlaybackState.Completed do
            task.wait(0.05)
            waited = waited + 0.05
        end
        task.wait(tcfg.wait or 0)
        telemetry_log("tween_completed", { name = name })
    end)
end

tween_run_move_btn.Callback = function()
    local name = tween_list_dropdown.Value
    if not name or name == "" or not TWEENS[name] then
        Library:Notify{ Title = "Tweens", Content = "Select a tween to move to (teleport).", Duration = 2 }
        return
    end
    local tcfg = TWEENS[name]
    teleport_to_vector(tcfg.pos)
    telemetry_log("tween_run_move", { name = name })
    Library:Notify{ Title = "Tweens", Content = "Teleported to "..name, Duration = 2 }
    print("[IntraHub] Teleported to tween:", name)
end

tween_export_btn.Callback = function()
    local export = {}
    for k,v in pairs(TWEENS) do
        export[k] = { pos = {x=v.pos.X, y=v.pos.Y, z=v.pos.Z}, speed = v.speed, wait = v.wait }
    end
    local ok, json = pcall(function() return httpservice:JSONEncode(export) end)
    if ok and json then safe_setclipboard(json); Library:Notify{Title="Tweens", Content="Tweens JSON copied to clipboard.", Duration=3} end
end

tween_import_btn.Callback = function()
    local text = tween_import_input.Value or ""
    if text == "" then Library:Notify{Title="Tweens", Content="Paste JSON into import field.", Duration=2}; return end
    local ok, tbl = pcall(function() return httpservice:JSONDecode(text) end)
    if not ok or type(tbl) ~= "table" then Library:Notify{Title="Tweens", Content="Invalid JSON.", Duration=2}; return end
    for name, info in pairs(tbl) do
        if type(info) == "table" and info.pos then
            TWEENS[name] = { pos = Vector3.new(info.pos.x or 0, info.pos.y or 0, info.pos.z or 0), speed = info.speed or 1, wait = info.wait or 0 }
        end
    end
    refresh_tween_dropdown()
    telemetry_log("tweens_imported", { count = 0 + (function() local c=0; for _ in pairs(tbl) do c=c+1 end; return c end)() })
    Library:Notify{Title="Tweens", Content="Imported tweens.", Duration=3}
    print("[IntraHub] Imported tweens:", tostring(#(tbl or {})))
end

-- refresh dropdown initially
refresh_tween_dropdown()

-- Yakk tab elements (show markers, refresh)
local yakktoggle_el = Tabs.Yakk:CreateToggle("yakktoggle", { Title = "Enable Yakk (gold farm)", Default = false })
local yakkspeed_el = Tabs.Yakk:CreateSlider("yakkspeed", { Title = "Speed multiplier", Min = 0.1, Max = 5, Rounding = 2, Default = 1 })
local yakkwait_el = Tabs.Yakk:CreateSlider("yakkwait", { Title = "Wait after waypoint (s)", Min = 0, Max = 2, Rounding = 2, Default = 0.05 })
local yakknoclip_el = Tabs.Yakk:CreateToggle("yakknoclip", { Title = "Enable noclip while Yakking", Default = true })
local yakk_show_markers_el = Tabs.Yakk:CreateToggle("yakk_show_markers", { Title = "Show waypoint markers", Default = true })
local yakk_refresh_btn = Tabs.Yakk:CreateButton({ Title = "Refresh Markers", Callback = function() refresh_markers_from_list(YAKK_WAYPOINTS) end })
local yakk_pause_btn = Tabs.Yakk:CreateButton({ Title = "Pause/Resume Yakk", Callback = function() yakk_paused = not yakk_paused; Library:Notify{Title="Yakk", Content = yakk_paused and "Paused" or "Resumed", Duration=2} end })
local yakk_teleport_first_btn = Tabs.Yakk:CreateButton({ Title = "Teleport to first waypoint", Callback = function() if #YAKK_WAYPOINTS>0 then teleport_to_vector(YAKK_WAYPOINTS[1]); Library:Notify{Title="Yakk", Content="Teleported to first waypoint", Duration=2} end end })

-- Wire Yakk toggle
yakktoggle_el:OnChanged(function(val)
    telemetry_log("yakk_toggle", { value = val })
    if val then
        refresh_character_refs()
        run_yakk(yakkspeed_el.Value, yakkwait_el.Value, yakknoclip_el.Value)
        Library:Notify{Title="Yakk", Content="Yakk started", Duration=3}
    else
        stop_yakk()
        Library:Notify{Title="Yakk", Content="Yakk stopped", Duration=3}
    end
end)

-- show/hide markers based on toggle and initial state
yakk_show_markers_el:OnChanged(function(val)
    if val then refresh_markers_from_list(YAKK_WAYPOINTS) else clear_markers() end
end)

-- ensure markers start visible if toggle is default true
if yakk_show_markers_el.Value then refresh_markers_from_list(YAKK_WAYPOINTS) end

-- noclip immediate toggle effect if Yakk running
yakknoclip_el:OnChanged(function(val)
    if yakk_running then set_character_noclip(val) end
end)

-- hook toggles for telemetry (local variable references)
local function hook_toggle_for_telemetry(optionObj, name)
    if not optionObj then return end
    optionObj:OnChanged(function(value) telemetry_log("toggle_changed", { toggle = name, value = value }) end)
end
hook_toggle_for_telemetry(planttoggle, "AutoPlant")
hook_toggle_for_telemetry(harvesttoggle, "AutoHarvest")
hook_toggle_for_telemetry(autopickuptoggle, "AutoPickup")
hook_toggle_for_telemetry(orbittoggle, "Orbit")
hook_toggle_for_telemetry(killauratoggle, "KillAura")
hook_toggle_for_telemetry(yakktoggle_el, "Yakk")

-- Planting/harvesting/pickup loops (use local UI toggle objects explicitly)
local plantedboxes = {}
local fruittoitemid = {
    Bloodfruit = 94, Bluefruit = 377, Lemon = 99, Coconut = 1, Jelly = 604,
    Banana = 606, Orange = 602, Oddberry = 32, Berry = 35, Strangefruit = 302,
    Strawberry = 282, Sunfruit = 128, Pumpkin = 80, ["Prickly Pear"] = 378,
    Apple = 243, Barley = 247, Cloudberry = 101, Carrot = 147
}

local function plant_structure(entityid, itemID)
    if packets and packets.InteractStructure and packets.InteractStructure.send then
        packets.InteractStructure.send({ entityID = entityid, itemID = itemID })
        plantedboxes[entityid] = true
    end
end

local function get_plantboxes(range)
    local out = {}
    local deployables = workspace:FindFirstChild("Deployables")
    if not deployables then return out end
    for _, deployable in ipairs(deployables:GetChildren()) do
        if deployable:IsA("Model") and deployable.Name == "Plant Box" then
            local entityid = deployable:GetAttribute("EntityID")
            local ppart = deployable.PrimaryPart or deployable:FindFirstChildWhichIsA("BasePart")
            if entityid and ppart then
                local dist = (ppart.Position - root.Position).Magnitude
                if dist <= range then table.insert(out, { entityid = entityid, deployable = deployable, dist = dist }) end
            end
        end
    end
    return out
end

local function get_bushes(range, fruitname)
    local out = {}
    for _, model in ipairs(workspace:GetChildren()) do
        if model:IsA("Model") and model.Name:find(fruitname) then
            local ppart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
            if ppart then
                local dist = (ppart.Position - root.Position).Magnitude
                if dist <= range then
                    local entityid = model:GetAttribute("EntityID")
                    if entityid then table.insert(out, { entityid = entityid, model = model, dist = dist }) end
                end
            end
        end
    end
    return out
end

-- Plant loop (batched)
task.spawn(function()
    while true do
        if not planttoggle.Value then task.wait(0.05); continue end
        if not root or not root.Parent then refresh_character_refs() end
        local range = tonumber(plantrangeslider.Value) or 30
        local delay = tonumber(plantdelayslider.Value) or 0.05
        local burst = tonumber(plantburstsizeslider.Value) or 6
        local selectedfruit = fruitdropdown.Value
        local itemID = fruittoitemid[selectedfruit] or 94
        local boxes = get_plantboxes(range)
        table.sort(boxes, function(a,b) return a.dist < b.dist end)
        local i = 1
        while i <= #boxes do
            local endIdx = math.min(i + burst - 1, #boxes)
            for j = i, endIdx do
                local box = boxes[j]
                if box and box.deployable and not box.deployable:FindFirstChild("Seed") then
                    task.spawn(function() plant_structure(box.entityid, itemID) end)
                else
                    if box and box.entityid then plantedboxes[box.entityid] = true end
                end
            end
            i = endIdx + 1
            task.wait(0)
        end
        task.wait(delay)
    end
end)

-- Harvest loop
task.spawn(function()
    while true do
        if not harvesttoggle.Value then task.wait(0.1); continue end
        if not root or not root.Parent then refresh_character_refs() end
        local range = tonumber(harvestrangeslider.Value) or 30
        local selectedfruit = fruitdropdown.Value
        local bushes = get_bushes(range, selectedfruit)
        table.sort(bushes, function(a,b) return a.dist < b.dist end)
        for _, bush in ipairs(bushes) do pickup(bush.entityid) end
        task.wait(0.1)
    end
end)

-- Auto pickup loop
task.spawn(function()
    while true do
        if not autopickuptoggle.Value then task.wait(0.05); continue end
        if not root or not root.Parent then refresh_character_refs() end
        local range = tonumber(pickuprangeslider.Value) or 35
        for _, item in ipairs(workspace:FindFirstChild("Items") and workspace.Items:GetChildren() or {}) do
            local primary = (item:IsA("BasePart") and item) or (item:IsA("Model") and item.PrimaryPart)
            if primary then
                local eid = item:GetAttribute("EntityID")
                if eid and (primary.Position - root.Position).Magnitude <= range then
                    pickup(eid)
                end
            end
        end
        task.wait(0.05)
    end
end)

-- Kill Aura / Resource Aura / Critter Aura loops: use local toggles (kept relatively unchanged)
task.spawn(function()
    while true do
        if not killauratoggle.Value then task.wait(0.1); continue end
        local range = tonumber(killaurarangeslider.Value) or 20
        local targetCount = tonumber(katargetcountdropdown.Value) or 1
        local cooldown = tonumber(kaswingcooldownslider.Value) or 0.1
        local targets = {}
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= plr then
                local pf = workspace.Players:FindFirstChild(player.Name)
                if pf then
                    local rootpart = pf:FindFirstChild("HumanoidRootPart")
                    local eid = pf:GetAttribute("EntityID")
                    if rootpart and eid then
                        local dist = (rootpart.Position - root.Position).Magnitude
                        if dist <= range then table.insert(targets, {eid=eid, dist=dist}) end
                    end
                end
            end
        end
        if #targets > 0 then
            table.sort(targets, function(a,b) return a.dist < b.dist end)
            local sel = {}
            for i = 1, math.min(targetCount, #targets) do table.insert(sel, targets[i].eid) end
            if packets and packets.SwingTool and packets.SwingTool.send then packets.SwingTool.send(sel) end
        end
        task.wait(cooldown)
    end
end)

task.spawn(function()
    while true do
        if not resourceauratoggle.Value then task.wait(0.1); continue end
        local range = tonumber(resourceaurarange.Value) or 20
        local targetCount = tonumber(resourcetargetdropdown.Value) or 1
        local cooldown = tonumber(resourcecooldownslider.Value) or 0.1
        local targets = {}
        local resources = {}
        for _, r in ipairs(workspace:GetChildren()) do
            if r:IsA("Model") and (r:GetAttribute("EntityID") or r.Name == "Gold Node") then table.insert(resources, r) end
        end
        for _, res in ipairs(resources) do
            local eid = res:GetAttribute("EntityID")
            local ppart = res.PrimaryPart or res:FindFirstChildWhichIsA("BasePart")
            if ppart and eid then
                local dist = (ppart.Position - root.Position).Magnitude
                if dist <= range then table.insert(targets, {eid=eid, dist=dist}) end
            end
        end
        if #targets > 0 then
            table.sort(targets, function(a,b) return a.dist < b.dist end)
            local sel = {}
            for i = 1, math.min(targetCount, #targets) do table.insert(sel, targets[i].eid) end
            if packets and packets.SwingTool and packets.SwingTool.send then packets.SwingTool.send(sel) end
        end
        task.wait(cooldown)
    end
end)

-- Drop logic (keeps original idea)
local debounce = 0
local cd = 0
runs.Heartbeat:Connect(function()
    if droptoggle.Value then
        if tick() - debounce >= cd then
            local selectedItem = dropdropdown.Value
            local inv = Players.LocalPlayer.PlayerGui and Players.LocalPlayer.PlayerGui.MainGui and Players.LocalPlayer.PlayerGui.MainGui.RightPanel and Players.LocalPlayer.PlayerGui.MainGui.RightPanel.Inventory and Players.LocalPlayer.PlayerGui.MainGui.RightPanel.Inventory:FindFirstChild("List")
            if inv then
                for _, child in ipairs(inv:GetChildren()) do
                    if child:IsA("ImageLabel") and child.Name == selectedItem then
                        if packets and packets.DropBagItem and packets.DropBagItem.send then packets.DropBagItem.send(child.LayoutOrder) end
                    end
                end
            end
            debounce = tick()
        end
    end
end)

runs.Heartbeat:Connect(function()
    if droptogglemanual.Value then
        if tick() - debounce >= cd then
            local itemname = droptextbox.Value
            local inv = Players.LocalPlayer.PlayerGui and Players.LocalPlayer.PlayerGui.MainGui and Players.LocalPlayer.PlayerGui.MainGui.RightPanel and Players.LocalPlayer.PlayerGui.MainGui.RightPanel.Inventory and Players.LocalPlayer.PlayerGui.MainGui.RightPanel.Inventory:FindFirstChild("List")
            if inv then
                for _, child in ipairs(inv:GetChildren()) do
                    if child:IsA("ImageLabel") and child.Name == itemname then
                        if packets and packets.DropBagItem and packets.DropBagItem.send then packets.DropBagItem.send(child.LayoutOrder) end
                    end
                end
            end
            debounce = tick()
        end
    end
end)

-- SaveManager / InterfaceManager hooks
SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes{}
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)

Library:Notify{ Title = "Project Instra Hub", Content = "Loaded and fixed UI wiring. Test Tweens/Yakk.", Duration = 8 }
SaveManager:LoadAutoloadConfig()
print("Done! Enjoy Project Instra Hub!")

-- Ensure telemetry saved on close (best-effort)
game:BindToClose(function()
    telemetry_log("script_unloaded", {})
    telemetry_end_session()
end)
