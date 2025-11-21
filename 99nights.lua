-- Load WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

WindUI:SetNotificationLower(true)
WindUI:GetTransparency(true)

WindUI:AddTheme({
    Name = "Green-Black Gradient",
    Accent = WindUI:Gradient({
        ["0"] = { Color = Color3.fromHex("#00FF7F"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#000000"), Transparency = 0 },
    }, {
        Rotation = 0,
    }),
    Dialog = Color3.fromHex("#161616"),
    Outline = Color3.fromHex("#00C060"),
    Text = Color3.fromHex("#00FF7F"),
    Placeholder = Color3.fromHex("#018141"),
    Background = Color3.fromHex("#101010"),
    Button = Color3.fromHex("#00C060"),
    Icon = Color3.fromHex("#00FF7F")
})
WindUI:SetTheme("Green-Black Gradient")

local Window = WindUI:CreateWindow({
    Title = "Project Infra",
    Icon = "rbxassetid://107232731410445",
    Author = "99 Nights In The Forest",
    Folder = "Infra",
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = true,
    Theme = "Green-Black Gradient",
    Resizable = true,
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = false,
    ScrollBarEnabled = true,
})

Window:SetToggleKey(Enum.KeyCode.K)
Window:EditOpenButton({
    Title = "Project Infra",
    Icon = "rbxassetid://107232731410445",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("00FF7F"),
        Color3.fromHex("00C060")
    ),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})


local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

-- MAIN TAB
local MainTab = Window:Tab({ Title = "Main", Icon = "rocket", Locked = false })


MainTab:Section({ Title = "Misc", Icon = "settings" })
MainTab:Toggle({
    Title = "Instant Interact",
    Value = instantInteractEnabled,
    Callback = function(state)
        instantInteractEnabled = state
        if state then
            originalHoldDurations = {}
            task.spawn(function()
                while instantInteractEnabled do
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") then
                            if not originalHoldDurations[obj] then originalHoldDurations[obj] = obj.HoldDuration end
                            obj.HoldDuration = 0
                        end
                    end
                    task.wait(0.5)
                end
            end)
        else
            for obj, val in pairs(originalHoldDurations) do
                if obj and obj:IsA("ProximityPrompt") then obj.HoldDuration = val end
            end
            originalHoldDurations = {}
        end
    end,
})

-- AUTO TAB
local AutoTab = Window:Tab({ Title = "Auto", Icon = "wrench", Locked = false })

local campfireFuelItems = {"Log", "Coal", "Chair", "Fuel Canister", "Oil Barrel", "Biofuel"}
local campfireDropPos = Vector3.new(0, 19, 0)
local selectedCampfireItems = {}  -- Multi-select array

local scrapjunkItems = {"Log", "Chair", "Tyre", "Bolt", "Broken Fan", "Broken Microwave", "Sheet Metal", "Old Radio", "Washing Machine", "Old Car Engine", "Cultist Gem", "Gem of the Forest Fragment"}
local autoScrapPos = Vector3.new(21, 20, -5)
local selectedScrapItems = {}  -- Multi-select array

local autocookItems = {"Morsel", "Steak", "Ribs", "Salmon", "Mackerel"}
local autoCookEnabledItems = {}
local autoCookEnabled = false

local autoUpgradeCampfireEnabled = false
local autoScrapItemsEnabled = false

local function moveItemToPos(item, position)
    if not item or not item:IsDescendantOf(workspace) or (not item:IsA("BasePart") and not item:IsA("Model")) then return end
    local part = item:IsA("Model") and item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart") or item:FindFirstChild("Handle") or item
    if not part or not part:IsA("BasePart") then return end
    if item:IsA("Model") and not item.PrimaryPart then pcall(function() item.PrimaryPart = part end) end
    pcall(function()
        ReplicatedStorage.RemoteEvents.RequestStartDraggingItem:FireServer(item)
        if item:IsA("Model") then item:SetPrimaryPartCFrame(CFrame.new(position)) else part.CFrame = CFrame.new(position) end
        ReplicatedStorage.RemoteEvents.StopDraggingItem:FireServer(item)
    end)
end

AutoTab:Section({ Title = "Auto Upgrade Campfire", Icon = "flame" })
AutoTab:Dropdown({
    Title = "Select Fuel",
    Desc = "Choose fuel items for campfire",
    Values = campfireFuelItems,
    Multi = true,  -- Changed to multi-select
    AllowNone = true,
    Callback = function(options) selectedCampfireItems = options end  -- Stores array
})
AutoTab:Toggle({
    Title = "Auto Upgrade Campfire",
    Value = false,
    Callback = function(checked)
        autoUpgradeCampfireEnabled = checked
        if checked then
            task.spawn(function()
                while autoUpgradeCampfireEnabled do
                    for _, selectedItem in ipairs(selectedCampfireItems) do  -- Iterate multi-select
                        local items = {}
                        for _, item in ipairs(workspace:WaitForChild("Items"):GetChildren()) do
                            if item.Name == selectedItem then
                                table.insert(items, item)
                            end
                        end
                        local count = math.min(10, #items)
                        for i = 1, count do moveItemToPos(items[i], campfireDropPos) end
                    end
                    task.wait(1)
                end
            end)
        end
    end,
})

AutoTab:Section({ Title = "Auto Scrap Items", Icon = "cog" })
AutoTab:Dropdown({
    Title = "Select Scrap Items",
    Desc = "Choose items to scrap",
    Values = scrapjunkItems,
    Multi = true,  -- Changed to multi-select
    AllowNone = true,
    Callback = function(options) selectedScrapItems = options end  -- Stores array
})
AutoTab:Toggle({
    Title = "Auto Scrap Items",
    Value = false,
    Callback = function(checked)
        autoScrapItemsEnabled = checked
        if checked then
            task.spawn(function()
                while autoScrapItemsEnabled do
                    for _, selectedItem in ipairs(selectedScrapItems) do  -- Iterate multi-select
                        local items = {}
                        for _, item in ipairs(workspace:WaitForChild("Items"):GetChildren()) do
                            if item.Name == selectedItem then
                                table.insert(items, item)
                            end
                        end
                        local count = math.min(10, #items)
                        for i = 1, count do moveItemToPos(items[i], autoScrapPos) end
                    end
                    task.wait(1)
                end
            end)
        end
    end,
})

AutoTab:Section({ Title = "Auto Cook Food", Icon = "flame" })
AutoTab:Dropdown({
    Title = "Select Food to Cook",
    Desc = "Choose food items to auto cook",
    Values = autocookItems,
    Multi = true,
    AllowNone = true,
    Callback = function(options)
        for _, itemName in ipairs(autocookItems) do
            autoCookEnabledItems[itemName] = table.find(options, itemName) ~= nil
        end
    end,
})
AutoTab:Toggle({
    Title = "Auto Cook Food",
    Value = false,
    Callback = function(state) autoCookEnabled = state end,
})

coroutine.wrap(function()
    while true do
        if autoCookEnabled then
            for itemName, enabled in pairs(autoCookEnabledItems) do
                if enabled then
                    for _, item in ipairs(Workspace:WaitForChild("Items"):GetChildren()) do
                        if item.Name == itemName then moveItemToPos(item, campfireDropPos) end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)()

local SAPLING_NAME = 'sapling'
local PLANT_COUNT = 75
local PLANT_DISTANCE = 44
local SHOW_BLUEPRINT = true
local BETWEEN_PLANT_WAIT = 0.06
local MARKER_LIFETIME = 6
local START_CFRAME = CFrame.new(
    -1.29994965,
    1.99994278,
    -1.50001144,
    -0.249999881,
    0.432982802,
    0.866040468,
    0.865997314,
    0.500048637,
    -1.5437603e-05,
    -0.43306911,
    0.74998486,
    -0.499974132
)
local plantPattern = "Circle"

-- Utility functions (unchanged)
local function findPlantRemote()
    if ReplicatedStorage:FindFirstChild("RemoteEvents") then
        local r = ReplicatedStorage.RemoteEvents:FindFirstChild("RequestPlantItem")
        if r then return r end
    end
    return nil
end
local PlantRemote = findPlantRemote()

local function findSaplingInstance()
    local items = workspace:FindFirstChild("Items")
    if items then
        for _, c in ipairs(items:GetChildren()) do
            if c.Name:lower():find(SAPLING_NAME:lower()) then return c end
        end
    end
    for _, c in ipairs(ReplicatedStorage:GetDescendants()) do
        if (c:IsA("Model") or c:IsA("Tool")) and c.Name:lower():find(SAPLING_NAME:lower()) then return c end
    end
    for _, cont in ipairs({Players.LocalPlayer:FindFirstChild("Backpack"), Players.LocalPlayer:FindFirstChild("Inventory")}) do
        if cont then
            for _, c in ipairs(cont:GetChildren()) do
                if c.Name:lower():find(SAPLING_NAME:lower()) then return c end
            end
        end
    end
    return nil
end

local function getGroundY(pos, defaultY)
    local origin = Vector3.new(pos.X, (defaultY or pos.Y) + 50, pos.Z)
    local rayDir = Vector3.new(0, -200, 0)
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances = {Players.LocalPlayer.Character or Players.LocalPlayer}
    rp.FilterType = Enum.RaycastFilterType.Blacklist
    local res = workspace:Raycast(origin, rayDir, rp)
    return (res and res.Position and res.Position.Y) or (defaultY or pos.Y)
end

local function createMarker(pos)
    if not SHOW_BLUEPRINT then return end
    local p = Instance.new("Part")
    p.Size = Vector3.new(1, 1, 1)
    p.Anchored = true
    p.CanCollide = false
    p.Transparency = 0.45
    p.Color = Color3.fromRGB(45, 200, 45)
    p.Name = "SaplingMarker"
    p.CFrame = CFrame.new(pos + Vector3.new(0, 0.5, 0))
    p.Parent = workspace
    Debris:AddItem(p, MARKER_LIFETIME)
end

local function tryCallRemote(remote, args)
    if not remote then return false end
    local ok = false
    if remote.ClassName == "RemoteFunction" or remote.InvokeServer then
        ok = pcall(function() remote:InvokeServer(table.unpack(args or {})) end)
    elseif remote.ClassName == "RemoteEvent" or remote.FireServer then
        ok = pcall(function() remote:FireServer(table.unpack(args or {})) end)
    end
    return ok
end

local function robustPlantCall(remote, saplingArg, position)
    if not remote then return false end
    local attempts = {
        {saplingArg, position},
        {position, saplingArg},
        {tostring(saplingArg), position},
        {position, tostring(saplingArg)}
    }
    for _, args in ipairs(attempts) do
        if tryCallRemote(remote, args) then return true end
        task.wait(0.03)
    end
    return false
end

-- Planting Patterns

local function plantCircle(centerPos, count, distance)
    local sapInst = findSaplingInstance()
    local firstArg = sapInst or SAPLING_NAME
    for i = 1, math.max(1, count) do
        local angle = (2 * math.pi / count) * (i - 1)
        local x = centerPos.X + math.cos(angle) * distance
        local z = centerPos.Z + math.sin(angle) * distance
        local groundY = getGroundY(Vector3.new(x, centerPos.Y, z), centerPos.Y)
        local finalPos = Vector3.new(x, groundY, z)
        createMarker(finalPos)
        robustPlantCall(PlantRemote, firstArg, finalPos)
        task.wait(BETWEEN_PLANT_WAIT)
    end
end

local function plantSquare(centerPos, totalCount, distance)
    local side = math.max(1, math.floor(math.sqrt(totalCount)))
    local startOffset = (side - 1) / 2
    local index = 0
    local sapInst = findSaplingInstance()
    local firstArg = sapInst or SAPLING_NAME
    for x = 0, side - 1 do
        for z = 0, side - 1 do
            if index >= totalCount then break end
            local xx = centerPos.X + (x - startOffset) * distance
            local zz = centerPos.Z + (z - startOffset) * distance
            local groundY = getGroundY(Vector3.new(xx, centerPos.Y, zz), centerPos.Y)
            local finalPos = Vector3.new(xx, groundY, zz)
            createMarker(finalPos)
            robustPlantCall(PlantRemote, firstArg, finalPos)
            index = index + 1
            task.wait(BETWEEN_PLANT_WAIT)
        end
    end
end

local function plantSpiral(centerPos, count, distance)
    local sapInst = findSaplingInstance()
    local firstArg = sapInst or SAPLING_NAME
    local angle = 0
    local radius = 0
    local angleIncrement = math.pi / 4
    local radiusIncrement = distance / (2 * math.pi)
    for i = 1, math.max(1, count) do
        local x = centerPos.X + radius * math.cos(angle)
        local z = centerPos.Z + radius * math.sin(angle)
        local groundY = getGroundY(Vector3.new(x, centerPos.Y, z), centerPos.Y)
        local finalPos = Vector3.new(x, groundY, z)
        createMarker(finalPos)
        robustPlantCall(PlantRemote, firstArg, finalPos)
        angle = angle + angleIncrement
        radius = radius + radiusIncrement
        task.wait(BETWEEN_PLANT_WAIT)
    end
end

local function plantLine(centerPos, count, distance)
    local sapInst = findSaplingInstance()
    local firstArg = sapInst or SAPLING_NAME
    for i = 0, count - 1 do
        local x = centerPos.X + i * distance
        local z = centerPos.Z
        local groundY = getGroundY(Vector3.new(x, centerPos.Y, z), centerPos.Y)
        local finalPos = Vector3.new(x, groundY, z)
        createMarker(finalPos)
        robustPlantCall(PlantRemote, firstArg, finalPos)
        task.wait(BETWEEN_PLANT_WAIT)
    end
end

local function plantStar(centerPos, count, distance)
    local sapInst = findSaplingInstance()
    local firstArg = sapInst or SAPLING_NAME
    local points = 5
    local step = math.pi / points
    local radius = distance
    local index = 0
    for i = 0, 2 * points - 1 do
        if index >= count then break end
        local r = (i % 2 == 0) and radius or radius / 2
        local x = centerPos.X + r * math.cos(i * step)
        local z = centerPos.Z + r * math.sin(i * step)
        local groundY = getGroundY(Vector3.new(x, centerPos.Y, z), centerPos.Y)
        local finalPos = Vector3.new(x, groundY, z)
        createMarker(finalPos)
        robustPlantCall(PlantRemote, firstArg, finalPos)
        index = index + 1
        task.wait(BETWEEN_PLANT_WAIT)
    end
end

local function plantFromStart(mode)
    local origin = START_CFRAME.Position
    if mode == "Circle" then
        plantCircle(origin, PLANT_COUNT, PLANT_DISTANCE)
    elseif mode == "Square" then
        plantSquare(origin, PLANT_COUNT, PLANT_DISTANCE)
    elseif mode == "Spiral" then
        plantSpiral(origin, PLANT_COUNT, PLANT_DISTANCE)
    elseif mode == "Line" then
        plantLine(origin, PLANT_COUNT, PLANT_DISTANCE)
    elseif mode == "Star" then
        plantStar(origin, PLANT_COUNT, PLANT_DISTANCE)
    end
end

local autoPlantEnabled = false

local function autoPlantLoop()
    while autoPlantEnabled do
        plantFromStart(plantPattern)
        task.wait(0.5)
    end
end

AutoTab:Section({ Title = "Auto Plant", Icon = "tree-deciduous" })
AutoTab:Dropdown({
    Title = "Plant Pattern",
    Desc = "Choose planting pattern",
    Values = {"Circle", "Square", "Spiral", "Line", "Star"},
    Multi = false,
    Value = plantPattern,
    Callback = function(value) plantPattern = value end,
})
AutoTab:Toggle({
    Title = "Auto Plant",
    Value = autoPlantEnabled,
    Callback = function(state)
        autoPlantEnabled = state
        if state then task.spawn(autoPlantLoop) end
    end,
})

-- ESP TAB (YOUR EXACT ESP - NO CHANGES)
local EspTab = Window:Tab({ Title = "ESP", Icon = "eye", Locked = false })

local espItemTypes = {
    "Bandage","Bolt","Broken Fan","Broken Microwave","Cake","Carrot","Chair","Coal",
    "Coin Stack","Cooked Morsel","Cooked Steak","Fuel Canister","Iron Body","Leather Armor",
    "Log","MadKit","Metal Chair","MedKit","Old Car Engine","Old Flashlight","Old Radio",
    "Revolver","Revolver Ammo","Rifle","Rifle Ammo","Morsel","Sheet Metal","Steak","Tyre",
    "Washing Machine","Cultist Gem","Gem of the Forest Fragment"
}
local espEntityTypes = {
    "Bunny","Wolf","Alpha Wolf","Bear","Crossbow Cultist","Alien","Alien Elite",
    "Polar Bear","Arctic Fox","Mammoth","Cultist","Cultist Melee","Cultist Crossbow","Cultist Juggernaut"
}
local espItemsEnabled = {}
local espEntitiesEnabled = {}
for _, itemType in pairs(espItemTypes) do espItemsEnabled[itemType] = false end
for _, entityType in pairs(espEntityTypes) do espEntitiesEnabled[entityType] = false end

local function createBillboardGui(parent, text, color)
    if not parent or not parent:IsA("BasePart") then return nil end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ProjectInfra_ESP"
    billboard.Adornee = parent
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.MaxDistance = 300
    local label = Instance.new("TextLabel", billboard)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.TextColor3 = color or Color3.new(1, 1, 1)
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextStrokeTransparency = 0.5
    label.Text = text
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    billboard.Parent = parent
    return billboard
end

local function setItemESP(enabled, itemType)
    local itemsFolder = Workspace:FindFirstChild("Items")
    if not itemsFolder then return end
    for _, item in pairs(itemsFolder:GetChildren()) do
        if item.Name == itemType then
            local primaryPart = nil
            if item:IsA("Model") then
                primaryPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
            elseif item:IsA("BasePart") then
                primaryPart = item
            end
            if primaryPart then
                local existingGui = primaryPart:FindFirstChild("ProjectInfra_ESP")
                if enabled and not existingGui then
                    createBillboardGui(primaryPart, itemType, Color3.fromRGB(0, 255, 0))
                elseif not enabled and existingGui then
                    existingGui:Destroy()
                end
            end
        end
    end
end

local function setEntityESP(enabled, entityType)
    local entityFolder = Workspace:FindFirstChild("Characters")
    if not entityFolder then return end
    for _, entity in pairs(entityFolder:GetChildren()) do
        if entity:IsA("Model") and entity.Name == entityType then
            local humanoidRootPart = entity:FindFirstChild("HumanoidRootPart") or entity.PrimaryPart or entity:FindFirstChildWhichIsA("BasePart")
            if humanoidRootPart then
                local existingGui = humanoidRootPart:FindFirstChild("ProjectInfra_ESP")
                if enabled and not existingGui then
                    createBillboardGui(humanoidRootPart, entityType, Color3.fromRGB(255, 255, 0))
                elseif not enabled and existingGui then
                    existingGui:Destroy()
                end
            end
        end
    end
end

EspTab:Section({ Title = "Item ESP", Icon = "box" })
for _, itemType in pairs(espItemTypes) do
    EspTab:Toggle({
        Title = itemType,
        Value = false,
        Callback = function(state)
            espItemsEnabled[itemType] = state
            setItemESP(state, itemType)
        end
    })
end

EspTab:Section({ Title = "Entity ESP", Icon = "users" })
for _, entityType in pairs(espEntityTypes) do
    EspTab:Toggle({
        Title = entityType,
        Value = false,
        Callback = function(state)
            espEntitiesEnabled[entityType] = state
            setEntityESP(state, entityType)
        end
    })
end

local itemsFolder = Workspace:FindFirstChild("Items")
if itemsFolder then
    itemsFolder.ChildAdded:Connect(function(child)
        task.wait(0.1)
        for itemType, enabled in pairs(espItemsEnabled) do
            if enabled and child.Name == itemType then
                setItemESP(true, itemType)
            end
        end
    end)
end

local entityFolder = Workspace:FindFirstChild("Characters")
if entityFolder then
    entityFolder.ChildAdded:Connect(function(child)
        task.wait(0.1)
        for entityType, enabled in pairs(espEntitiesEnabled) do
            if enabled and child.Name == entityType then
                setEntityESP(true, entityType)
            end
        end
    end)
end

-- BRING TAB
local BringTab = Window:Tab({
    Title = "Bring",
    Icon = "package",
    Locked = false,
})

-- Item categories with multi-select dropdowns and selected item tables
local junkItems = {
    "Tyre", "Bolt", "Broken Fan", "Broken Microwave", "Sheet Metal", "Old Radio",
    "Washing Machine", "Old Car Engine"
}
local fuelItems = {
    "Log", "Chair", "Coal", "Fuel Canister", "Oil Barrel"
}
local foodItems = {
    "Cake", "Cooked Steak", "Cooked Morsel", "Steak", "Morsel", "Berry", "Carrot"
}
local medicalItems = {
    "Bandage", "MedKit"
}
local equipmentItems = {
    "Revolver", "Rifle", "Leather Body", "Iron Body", "Revolver Ammo",
    "Rifle Ammo", "Giant Sack", "Good Sack", "Strong Axe", "Good Axe"
}

local selectedJunkItems = {}
local selectedFuelItems = {}
local selectedFoodItems = {}
local selectedMedicalItems = {}
local selectedEquipmentItems = {}

-- Shared function to move item to player vicinity via remote events
local function moveItemToPos(item, position)
    if not item or not item:IsDescendantOf(workspace) then return end
    local part = nil
    if item:IsA("Model") then
        part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart") or item:FindFirstChild("Handle")
    elseif item:IsA("BasePart") then
        part = item
    end
    if not part or not part:IsA("BasePart") then return end
    if item:IsA("Model") and not item.PrimaryPart then
        pcall(function() item.PrimaryPart = part end)
    end
    pcall(function()
        ReplicatedStorage.RemoteEvents.RequestStartDraggingItem:FireServer(item)
        if item:IsA("Model") then
            item:SetPrimaryPartCFrame(CFrame.new(position))
        else
            part.CFrame = CFrame.new(position)
        end
        ReplicatedStorage.RemoteEvents.StopDraggingItem:FireServer(item)
    end)
end

local function bringSelectedItems(selectedItems)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = LocalPlayer.Character.HumanoidRootPart
    local targetPos = hrp.Position + Vector3.new(2, 0, 0)

    for _, itemName in ipairs(selectedItems) do
        for _, item in ipairs(workspace:GetDescendants()) do
            if item.Name == itemName and (item:IsA("BasePart") or item:IsA("Model")) then
                moveItemToPos(item, targetPos)
            end
        end
    end
end

-- Create dropdowns and buttons for each category
BringTab:Section({ Title = "Junk Items", Icon = "box" })
BringTab:Dropdown({
    Title = "Select Junk Items",
    Desc = "Choose items to bring",
    Values = junkItems,
    Multi = true,
    AllowNone = true,
    Callback = function(options) selectedJunkItems = options end,
})
BringTab:Button({
    Title = "Bring Junk Items",
    Callback = function() bringSelectedItems(selectedJunkItems) end,
})

BringTab:Section({ Title = "Fuel Items", Icon = "flame" })
BringTab:Dropdown({
    Title = "Select Fuel Items",
    Desc = "Choose items to bring",
    Values = fuelItems,
    Multi = true,
    AllowNone = true,
    Callback = function(options) selectedFuelItems = options end,
})
BringTab:Button({
    Title = "Bring Fuel Items",
    Callback = function() bringSelectedItems(selectedFuelItems) end,
})

BringTab:Section({ Title = "Food Items", Icon = "utensils" })
BringTab:Dropdown({
    Title = "Select Food Items",
    Desc = "Choose items to bring",
    Values = foodItems,
    Multi = true,
    AllowNone = true,
    Callback = function(options) selectedFoodItems = options end,
})
BringTab:Button({
    Title = "Bring Food Items",
    Callback = function() bringSelectedItems(selectedFoodItems) end,
})

BringTab:Section({ Title = "Medical Items", Icon = "bandage" })
BringTab:Dropdown({
    Title = "Select Medical Items",
    Desc = "Choose items to bring",
    Values = medicalItems,
    Multi = true,
    AllowNone = true,
    Callback = function(options) selectedMedicalItems = options end,
})
BringTab:Button({
    Title = "Bring Medical Items",
    Callback = function() bringSelectedItems(selectedMedicalItems) end,
})

BringTab:Section({ Title = "Equipment Items", Icon = "sword" })
BringTab:Dropdown({
    Title = "Select Equipment Items",
    Desc = "Choose items to bring",
    Values = equipmentItems,
    Multi = true,
    AllowNone = true,
    Callback = function(options) selectedEquipmentItems = options end,
})
BringTab:Button({
    Title = "Bring Equipment Items",
    Callback = function() bringSelectedItems(selectedEquipmentItems) end,
})

-- Pelts and Blueprints Bring Setup for Bring Tab
local peltsItems = {
    "Bunny Foot", "Wolf Pelt", "Alpha Wolf Pelt", "Bear Pelt", "Arctic Fox Pelt", "Polar Bear Pelt"
}
local blueprintItems = {
    "Crafting Blueprint", "Defense Blueprint", "Furniture Blueprint"
}

local selectedPeltsItems = {}
local selectedBlueprintItems = {}

-- Bring Pelts function (similar to existing bringSelectedItems)
local function bringPeltsItems(selectedItems)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = LocalPlayer.Character.HumanoidRootPart
    local targetPos = hrp.Position + Vector3.new(2, 0, 0)

    for _, itemName in ipairs(selectedItems) do
        for _, item in ipairs(workspace:GetDescendants()) do
            if item.Name == itemName and (item:IsA("BasePart") or item:IsA("Model")) then
                -- Move item near player
                local part = nil
                if item:IsA("Model") then
                    part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart") or item:FindFirstChild("Handle")
                elseif item:IsA("BasePart") then
                    part = item
                end
                if not part then continue end
                if item:IsA("Model") and not item.PrimaryPart then
                    pcall(function() item.PrimaryPart = part end)
                end
                pcall(function()
                    ReplicatedStorage.RemoteEvents.RequestStartDraggingItem:FireServer(item)
                    if item:IsA("Model") then
                        item:SetPrimaryPartCFrame(CFrame.new(targetPos))
                    else
                        part.CFrame = CFrame.new(targetPos)
                    end
                    ReplicatedStorage.RemoteEvents.StopDraggingItem:FireServer(item)
                end)
            end
        end
    end
end

-- Bring Blueprints function (same as Pelts, with Blueprint items)
local function bringBlueprintItems(selectedItems)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = LocalPlayer.Character.HumanoidRootPart
    local targetPos = hrp.Position + Vector3.new(2, 0, 0)

    for _, itemName in ipairs(selectedItems) do
        for _, item in ipairs(workspace:GetDescendants()) do
            if item.Name == itemName and (item:IsA("BasePart") or item:IsA("Model")) then
                local part = nil
                if item:IsA("Model") then
                    part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart") or item:FindFirstChild("Handle")
                elseif item:IsA("BasePart") then
                    part = item
                end
                if not part then continue end
                if item:IsA("Model") and not item.PrimaryPart then
                    pcall(function() item.PrimaryPart = part end)
                end
                pcall(function()
                    ReplicatedStorage.RemoteEvents.RequestStartDraggingItem:FireServer(item)
                    if item:IsA("Model") then
                        item:SetPrimaryPartCFrame(CFrame.new(targetPos))
                    else
                        part.CFrame = CFrame.new(targetPos)
                    end
                    ReplicatedStorage.RemoteEvents.StopDraggingItem:FireServer(item)
                end)
            end
        end
    end
end

-- Add Pelts section to BringTab
BringTab:Section({ Title = "Pelts", Icon = "paw" })
BringTab:Dropdown({
    Title = "Select Pelts to Bring",
    Desc = "Choose pelts to bring",
    Values = peltsItems,
    Multi = true,
    AllowNone = true,
    Callback = function(options)
        selectedPeltsItems = options
    end,
})
BringTab:Button({
    Title = "Bring Pelts",
    Callback = function()
        bringPeltsItems(selectedPeltsItems)
    end,
})

-- Add Blueprints section to BringTab
BringTab:Section({ Title = "Blueprints", Icon = "clipboard" })
BringTab:Dropdown({
    Title = "Select Blueprints to Bring",
    Desc = "Choose blueprints to bring",
    Values = blueprintItems,
    Multi = true,
    AllowNone = true,
    Callback = function(options)
        selectedBlueprintItems = options
    end,
})
BringTab:Button({
    Title = "Bring Blueprints",
    Callback = function()
        bringBlueprintItems(selectedBlueprintItems)
    end,
})

-- TELEPORT TAB
local TeleportTab = Window:Tab({
    Title = "Teleport",
    Icon = "map-pin",
    Locked = false,
})

-- Scan Map toggle (move player along map parts to scan)
local scanMapEnabled = false
TeleportTab:Toggle({
    Title = "Scan Map (Essential)",
    Default = false,
    Callback = function(state)
        scanMapEnabled = state
        local player = Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart", 3)
        if not hrp then return end

        local map = workspace:FindFirstChild("Map")
        if not map then return end

        local foliage = map:FindFirstChild("Foliage") or map:FindFirstChild("Landmarks")
        if not foliage then return end

        if state then
            task.spawn(function()
                while scanMapEnabled do
                    local trees = {}
                    for _, obj in ipairs(foliage:GetChildren()) do
                        if obj.Name == "Small Tree" and obj:IsA("Model") then
                            local trunk = obj:FindFirstChild("Trunk") or obj.PrimaryPart
                            if trunk then
                                table.insert(trees, trunk)
                            end
                        end
                    end

                    for _, trunk in ipairs(trees) do
                        if not scanMapEnabled then break end
                        if trunk and trunk.Parent then
                            local treeCFrame = trunk.CFrame
                            local rightVector = treeCFrame.RightVector
                            local targetPosition = treeCFrame.Position + rightVector * 69
                            hrp.CFrame = CFrame.new(targetPosition)
                            task.wait(0.01)
                        end
                    end
                end
            end)
        end
    end,
})

-- Hardcoded teleport positions (Example locations)
local function tp1()
    local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(0.43, 15.77, -1.88, -0.27, 0.10, 0.95, 0.63, 0.76, 0.09, -0.71, 0.63, -0.27)
end

local function tp2()
    local targetPart = workspace:FindFirstChild("Map")
        and workspace.Map:FindFirstChild("Landmarks")
        and workspace.Map.Landmarks:FindFirstChild("Stronghold")
        and workspace.Map.Landmarks.Stronghold:FindFirstChild("Functional")
        and workspace.Map.Landmarks.Stronghold.Functional:FindFirstChild("EntryDoors")
        and workspace.Map.Landmarks.Stronghold.Functional.EntryDoors:FindFirstChild("DoorRight")
        and workspace.Map.Landmarks.Stronghold.Functional.EntryDoors.DoorRight:FindFirstChild("Model")
    if targetPart then
        local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        hrp.CFrame = targetPart.CFrame + Vector3.new(0, 5, 0)
    end
end

-- Sections with buttons for teleporting to locations

TeleportTab:Section({ Title = "Teleport", Icon = "map" })

TeleportTab:Button({
    Title = "Teleport to Campfire",
    Callback = tp1,
})

TeleportTab:Button({
    Title = "Teleport to Stronghold",
    Callback = tp2,
})

TeleportTab:Button({
    Title = "Teleport to Safe Zone",
    Callback = function()
        if not workspace:FindFirstChild("SafeZonePart") then
            local createpart = Instance.new("Part")
            createpart.Name = "SafeZonePart"
            createpart.Size = Vector3.new(50, 50, 50)
            createpart.Position = Vector3.new(0, 105, 0)
            createpart.Anchored = true
            createpart.CanCollide = false
            createpart.Transparency = 0.8
            createpart.Color = Color3.fromRGB(255, 255, 255)
            createpart.Parent = workspace
        end
        local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        hrp.CFrame = CFrame.new(0, 110, 0)
    end,
})

TeleportTab:Button({
    Title = "Teleport to Trader (Bunny Foot)",
    Callback = function()
        local pos = Vector3.new(-37.08, 3.98, -16.33)
        local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        hrp.CFrame = CFrame.new(pos)
    end,
})

-- Random Tree teleports

TeleportTab:Section({ Title = "Tree", Icon = "tree-deciduous" })

TeleportTab:Button({
    Title = "Teleport to Random Tree",
    Callback = function()
        local player = Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:FindFirstChild("HumanoidRootPart", 3)
        if not hrp then return end

        local map = workspace:FindFirstChild("Map")
        if not map then return end

        local foliage = map:FindFirstChild("Foliage") or map:FindFirstChild("Landmarks")
        if not foliage then return end

        local trees = {}
        for _, obj in ipairs(foliage:GetChildren()) do
            if obj.Name == "Small Tree" and obj:IsA("Model") then
                local trunk = obj:FindFirstChild("Trunk") or obj.PrimaryPart
                if trunk then
                    table.insert(trees, trunk)
                end
            end
        end

        if #trees > 0 then
            local trunk = trees[math.random(1, #trees)]
            local treeCFrame = trunk.CFrame
            local rightVector = treeCFrame.RightVector
            local targetPosition = treeCFrame.Position + rightVector * 3
            hrp.CFrame = CFrame.new(targetPosition)
        end
    end,
})

-- Child mobs teleport section

TeleportTab:Section({ Title = "Children", Icon = "eye" })

local currentMobs, currentMobNames = {}, {}
local selectedMob = nil

local function getMobs()
    currentMobs, currentMobNames = {}, {}
    local characters = workspace:FindFirstChild("Characters")
    if characters then
        for _, character in pairs(characters:GetChildren()) do
            if character.Name:match("^Lost Child") and character:GetAttribute("Lost") == true then
                table.insert(currentMobs, character)
                table.insert(currentMobNames, character.Name)
            end
        end
    end
end

getMobs()

local mobDropdown = TeleportTab:Dropdown({
    Title = "Select Child",
    Values = currentMobNames,
    Multi = false,
    AllowNone = true,
    Callback = function(value)
        selectedMob = value
    end,
})

TeleportTab:Button({
    Title = "Refresh List",
    Callback = function()
        getMobs()
        if #currentMobNames > 0 then
            selectedMob = currentMobNames[1]
            mobDropdown:Refresh(currentMobNames)
        else
            selectedMob = nil
            mobDropdown:Refresh({ "No child found" })
        end
    end,
})

TeleportTab:Button({
    Title = "Teleport to Child",
    Callback = function()
        if selectedMob and currentMobs then
            for i, name in ipairs(currentMobNames) do
                if name == selectedMob then
                    local targetMob = currentMobs[i]
                    if targetMob then
                        local part = targetMob.PrimaryPart or targetMob:FindFirstChildWhichIsA("BasePart")
                        if part and Players.LocalPlayer.Character then
                            local hrp = Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                hrp.CFrame = part.CFrame + Vector3.new(0, 5, 0)
                            end
                        end
                    end
                    break
                end
            end
        end
    end,
})

-- Chest teleports section

TeleportTab:Section({ Title = "Chest", Icon = "box" })

local currentChests, currentChestNames = {}, {}
local selectedChest = nil

local function getChests()
    currentChests, currentChestNames = {}, {}
    local items = workspace:FindFirstChild("Items")
    if items then
        for _, item in pairs(items:GetChildren()) do
            if item.Name:match("^Item Chest") and not item:GetAttribute("8721081708Opened") then
                table.insert(currentChests, item)
                table.insert(currentChestNames, "Chest " .. #currentChestNames + 1)
            end
        end
    end
end

getChests()

local chestDropdown = TeleportTab:Dropdown({
    Title = "Select Chest",
    Values = currentChestNames,
    Multi = false,
    AllowNone = true,
    Callback = function(value)
        selectedChest = value
    end,
})

TeleportTab:Button({
    Title = "Refresh List",
    Callback = function()
        getChests()
        if #currentChestNames > 0 then
            selectedChest = currentChestNames[1]
            chestDropdown:Refresh(currentChestNames)
        else
            selectedChest = nil
            chestDropdown:Refresh({ "No chests found" })
        end
    end,
})

TeleportTab:Button({
    Title = "Teleport to Chest",
    Callback = function()
        if selectedChest and currentChests then
            for i, name in ipairs(currentChestNames) do
                if name == selectedChest then
                    local targetChest = currentChests[i]
                    if targetChest then
                        local part = targetChest.PrimaryPart or targetChest:FindFirstChildWhichIsA("BasePart")
                        if part and Players.LocalPlayer.Character then
                            local hrp = Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                hrp.CFrame = part.CFrame + Vector3.new(0, 5, 0)
                            end
                        end
                    end
                    break
                end
            end
        end
    end,
})

-- FLY TAB (Exact from Source 1)
local FlyTab = Window:Tab({
    Title = "Player",
    Icon = "user",
    Locked = false,
})

local flyToggle = false
local flySpeed = 1
local FLYING = false
local flyKeyDown, flyKeyUp, mfly1, mfly2
local IYMouse = game:GetService("UserInputService")

-- Fly PC
local function sFLY()
    repeat task.wait() until Players.LocalPlayer and Players.LocalPlayer.Character and Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart") and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    repeat task.wait() until IYMouse
    if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect(); flyKeyUp:Disconnect() end

    local T = Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    local SPEED = flySpeed

    local function FLY()
        FLYING = true
        local BG = Instance.new('BodyGyro')
        local BV = Instance.new('BodyVelocity')
        BG.P = 9e4
        BG.Parent = T
        BV.Parent = T
        BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        BG.CFrame = T.CFrame
        BV.Velocity = Vector3.new(0, 0, 0)
        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        task.spawn(function()
            while FLYING do
                task.wait()
                if not flyToggle and Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
                    Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
                end
                if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
                    SPEED = flySpeed
                elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0) and SPEED ~= 0 then
                    SPEED = 0
                end
                if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
                    BV.Velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (CONTROL.F + CONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
                    lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
                elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
                    BV.Velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (lCONTROL.F + lCONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
                else
                    BV.Velocity = Vector3.new(0, 0, 0)
                end
                BG.CFrame = workspace.CurrentCamera.CoordinateFrame
            end
            CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
            lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
            SPEED = 0
            BG:Destroy()
            BV:Destroy()
            if Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
                Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
            end
        end)
    end
    flyKeyDown = IYMouse.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local KEY = input.KeyCode.Name
            if KEY == "W" then
                CONTROL.F = flySpeed
            elseif KEY == "S" then
                CONTROL.B = -flySpeed
            elseif KEY == "A" then
                CONTROL.L = -flySpeed
            elseif KEY == "D" then 
                CONTROL.R = flySpeed
            elseif KEY == "E" then
                CONTROL.Q = flySpeed * 2
            elseif KEY == "Q" then
                CONTROL.E = -flySpeed * 2
            end
            pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Track end)
        end
    end)
    flyKeyUp = IYMouse.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local KEY = input.KeyCode.Name
            if KEY == "W" then
                CONTROL.F = 0
            elseif KEY == "S" then
                CONTROL.B = 0
            elseif KEY == "A" then
                CONTROL.L = 0
            elseif KEY == "D" then
                CONTROL.R = 0
            elseif KEY == "E" then
                CONTROL.Q = 0
            elseif KEY == "Q" then
                CONTROL.E = 0
            end
        end
    end)
    FLY()
end

-- Fly Mobile
local function NOFLY()
    FLYING = false
    if flyKeyDown then flyKeyDown:Disconnect() end
    if flyKeyUp then flyKeyUp:Disconnect() end
    if mfly1 then mfly1:Disconnect() end
    if mfly2 then mfly2:Disconnect() end
    if Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
        Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
    end
    pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
end

local function UnMobileFly()
    pcall(function()
        FLYING = false
        local root = Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
        if root:FindFirstChild("BodyVelocity") then root:FindFirstChild("BodyVelocity"):Destroy() end
        if root:FindFirstChild("BodyGyro") then root:FindFirstChild("BodyGyro"):Destroy() end
        if Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid") then
            Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid").PlatformStand = false
        end
        if mfly1 then mfly1:Disconnect() end
        if mfly2 then mfly2:Disconnect() end
    end)
end

local function MobileFly()
    UnMobileFly()
    FLYING = true

    local root = Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    local camera = workspace.CurrentCamera
    local v3none = Vector3.new()
    local v3zero = Vector3.new(0, 0, 0)
    local v3inf = Vector3.new(9e9, 9e9, 9e9)

    local controlModule = require(Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
    local bv = Instance.new("BodyVelocity")
    bv.Name = "BodyVelocity"
    bv.Parent = root
    bv.MaxForce = v3zero
    bv.Velocity = v3zero

    local bg = Instance.new("BodyGyro")
    bg.Name = "BodyGyro"
    bg.Parent = root
    bg.MaxTorque = v3inf
    bg.P = 1000
    bg.D = 50

    mfly1 = Players.LocalPlayer.CharacterAdded:Connect(function()
        local newRoot = Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
        local newBv = Instance.new("BodyVelocity")
        newBv.Name = "BodyVelocity"
        newBv.Parent = newRoot
        newBv.MaxForce = v3zero
        newBv.Velocity = v3zero

        local newBg = Instance.new("BodyGyro")
        newBg.Name = "BodyGyro"
        newBg.Parent = newRoot
        newBg.MaxTorque = v3inf
        newBg.P = 1000
        newBg.D = 50
    end)

    mfly2 = game:GetService("RunService").RenderStepped:Connect(function()
        root = Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
        camera = workspace.CurrentCamera
        if Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid") and root and root:FindFirstChild("BodyVelocity") and root:FindFirstChild("BodyGyro") then
            local humanoid = Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
            local VelocityHandler = root:FindFirstChild("BodyVelocity")
            local GyroHandler = root:FindFirstChild("BodyGyro")

            VelocityHandler.MaxForce = v3inf
            GyroHandler.MaxTorque = v3inf
            humanoid.PlatformStand = true
            GyroHandler.CFrame = camera.CoordinateFrame
            VelocityHandler.Velocity = v3none

            local direction = controlModule:GetMoveVector()
            if direction.X > 0 then
                VelocityHandler.Velocity = VelocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * (flySpeed * 50))
            end
            if direction.X < 0 then
                VelocityHandler.Velocity = VelocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * (flySpeed * 50))
            end
            if direction.Z > 0 then
                VelocityHandler.Velocity = VelocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * (flySpeed * 50))
            end
            if direction.Z < 0 then
                VelocityHandler.Velocity = VelocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * (flySpeed * 50))
            end
        end
    end)
end

FlyTab:Section({ Title = "Main", Icon = "eye" })

FlyTab:Slider({
    Title = "Fly Speed",
    Value = { Min = 1, Max = 20, Default = 1 },
    Callback = function(value)
        flySpeed = value
        if FLYING then
            task.spawn(function()
                while FLYING do
                    task.wait(0.1)
                    if game:GetService("UserInputService").TouchEnabled then
                        local root = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if root and root:FindFirstChild("BodyVelocity") then
                            local bv = root:FindFirstChild("BodyVelocity")
                            bv.Velocity = bv.Velocity.Unit * (flySpeed * 50)
                        end
                    end
                end
            end)
        end
    end
})

FlyTab:Toggle({
    Title = "Enable Fly",
    Value = false,
    Callback = function(state)
        flyToggle = state
        if flyToggle then
            if game:GetService("UserInputService").TouchEnabled then
                MobileFly()
            else
                sFLY()
            end
        else
            NOFLY()
            UnMobileFly()
        end
    end
})

local speed = 16
local jump = 50

local function setSpeed(val)
    local humanoid = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.WalkSpeed = val end
end

local function setJump(val)
    local humanoid = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.JumpPower = val
    end
end

FlyTab:Slider({
    Title = "Speed",
    Value = { Min = 16, Max = 300, Default = 16 },
    Callback = function(value)
        speed = value
    end
})

FlyTab:Toggle({
    Title = "Enable Speed",
    Value = false,
    Callback = function(state)
        setSpeed(state and speed or 16)
    end
})

FlyTab:Slider({
    Title = "Jump",
    Value = { Min = 10, Max = 300, Default = 50 },
    Callback = function(value)
        jump = value
    end
})

FlyTab:Toggle({
    Title = "Enable Jump",
    Value = false,
    Callback = function(state)
        setJump(state and jump or 50)
    end
})

local noclipConnection

FlyTab:Toggle({
    Title = "No Clip",
    Value = false,
    Callback = function(state)
        if state then
            noclipConnection = game:GetService("RunService").Stepped:Connect(function()
                local char = Players.LocalPlayer.Character
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
        end
    end
})

local infJumpConnection

FlyTab:Toggle({
    Title = "Infinite Jump",
    Value = false,
    Callback = function(state)
        if state then
            infJumpConnection = UserInputService.JumpRequest:Connect(function()
                local char = Players.LocalPlayer.Character
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            if infJumpConnection then
                infJumpConnection:Disconnect()
                infJumpConnection = nil
            end
        end
    end
})


-- COMBAT TAB
local CombatTab = Window:Tab({
    Title = "Combat",
    Icon = "sword",
    Locked = false,
})

-- Variables
local killAuraToggle = false
local chopAuraToggle = false
local auraRadius = 50
local currentammount = 0
local godmodeToggle = false

local toolsDamageIDs = {
    ["Old Axe"] = "3_7367831688",
    ["Good Axe"] = "112_7367831688",
    ["Strong Axe"] = "116_7367831688",
    ["Chainsaw"] = "647_8992824875",
    ["Spear"] = "196_8999010016"
}

-- Helper functions
local function getAnyToolWithDamageID(isChopAura)
    for toolName, damageID in pairs(toolsDamageIDs) do
        if isChopAura and toolName ~= "Old Axe" and toolName ~= "Good Axe" and toolName ~= "Strong Axe" and toolName ~= "Chainsaw" then
            continue
        end
        local tool = LocalPlayer:FindFirstChild("Inventory") and LocalPlayer.Inventory:FindFirstChild(toolName)
        if tool then
            return tool, damageID
        end
    end
    return nil, nil
end

local function equipTool(tool)
    if tool then
        ReplicatedStorage:WaitForChild("RemoteEvents").EquipItemHandle:FireServer("FireAllClients", tool)
    end
end

local function unequipTool(tool)
    if tool then
        ReplicatedStorage:WaitForChild("RemoteEvents").UnequipItemHandle:FireServer("FireAllClients", tool)
    end
end

-- Kill Aura Loop
local function killAuraLoop()
    while killAuraToggle do
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local tool, damageID = getAnyToolWithDamageID(false)
            if tool and damageID then
                equipTool(tool)
                for _, mob in ipairs(Workspace.Characters:GetChildren()) do
                    if mob:IsA("Model") then
                        local part = mob:FindFirstChildWhichIsA("BasePart")
                        if part and (part.Position - hrp.Position).Magnitude <= auraRadius then
                            pcall(function()
                                ReplicatedStorage:WaitForChild("RemoteEvents").ToolDamageObject:InvokeServer(
                                    mob,
                                    tool,
                                    damageID,
                                    CFrame.new(part.Position)
                                )
                            end)
                        end
                    end
                end
                task.wait(0.1)
            else
                task.wait(1)
            end
        else
            task.wait(0.5)
        end
    end
end

-- Chop Aura Loop
local function chopAuraLoop()
    while chopAuraToggle do
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local tool, baseDamageID = getAnyToolWithDamageID(true)
            if tool and baseDamageID then
                equipTool(tool)
                currentammount = currentammount + 1
                local trees = {}
                local map = Workspace:FindFirstChild("Map")
                if map then
                    if map:FindFirstChild("Foliage") then
                        for _, obj in ipairs(map.Foliage:GetChildren()) do
                            if obj:IsA("Model") and obj.Name == "Small Tree" then
                                table.insert(trees, obj)
                            end
                        end
                    end
                    if map:FindFirstChild("Landmarks") then
                        for _, obj in ipairs(map.Landmarks:GetChildren()) do
                            if obj:IsA("Model") and obj.Name == "Small Tree" then
                                table.insert(trees, obj)
                            end
                        end
                    end
                end
                for _, tree in ipairs(trees) do
                    local trunk = tree:FindFirstChild("Trunk")
                    if trunk and trunk:IsA("BasePart") and (trunk.Position - hrp.Position).Magnitude <= auraRadius then
                        local alreadyammount = false
                        task.spawn(function()
                            while chopAuraToggle and tree and tree.Parent and not alreadyammount do
                                alreadyammount = true
                                currentammount = currentammount + 1
                                pcall(function()
                                    ReplicatedStorage:WaitForChild("RemoteEvents").ToolDamageObject:InvokeServer(
                                        tree,
                                        tool,
                                        tostring(currentammount) .. "_7367831688",
                                        CFrame.new(-2.962610244751, 4.5547881126404, -75.950843811035, 0.89621275663376, -1.3894891459643e-08, 0.44362446665764, -7.994568895775e-10, 1, 3.293635941759e-08, -0.44362446665764, -2.9872644802253e-08, 0.89621275663376)
                                    )
                                end)
                                task.wait(0.5)
                            end
                        end)
                    end
                end
                task.wait(0.1)
            else
                task.wait(1)
            end
        else
            task.wait(0.5)
        end
    end
end

-- UI Elements
CombatTab:Section({ Title = "Aura", Icon = "star" })

CombatTab:Toggle({
    Title = "Kill Aura",
    Value = false,
    Callback = function(state)
        killAuraToggle = state
        if state then
            task.spawn(killAuraLoop)
        else
            local tool, _ = getAnyToolWithDamageID(false)
            unequipTool(tool)
        end
    end
})

CombatTab:Toggle({
    Title = "Chop Aura",
    Value = false,
    Callback = function(state)
        chopAuraToggle = state
        if state then
            task.spawn(chopAuraLoop)
        else
            local tool, _ = getAnyToolWithDamageID(true)
            unequipTool(tool)
        end
    end
})

CombatTab:Section({ Title = "Settings", Icon = "settings" })

CombatTab:Slider({
    Title = "Aura Radius",
    Value = { Min = 50, Max = 500, Default = 50 },
    Callback = function(value)
        auraRadius = math.clamp(value, 10, 500)
    end
})

CombatTab:Section({ Title = "Godmode", Icon = "shield" })

CombatTab:Toggle({
    Title = "Godmode",
    Value = false,
    Callback = function(state)
        godmodeToggle = state
        if state then
            task.spawn(function()
                while godmodeToggle do
                    pcall(function()
                        local rs = game:GetService("ReplicatedStorage")
                        local re = rs:WaitForChild("RemoteEvents")
                        local dmg = re:WaitForChild("DamagePlayer")
                        dmg:FireServer(-(1/0))
                    end)
                    task.wait()
                end
            end)
        end
    end
})



-- OTHER TAB
local OtherTab = Window:Tab({
    Title = "Other",
    Icon = "crown",
    Locked = false,
})

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- Store previous lighting values for restoration
local oldAmbient = Lighting.Ambient
local oldBrightness = Lighting.Brightness
local oldClockTime = Lighting.ClockTime

local fullBrightConnection

OtherTab:Toggle({
    Title = "Full Bright",
    Default = false,
    Callback = function(state)
        if state then
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.Brightness = 10
            Lighting.ClockTime = 14

            fullBrightConnection = RunService.RenderStepped:Connect(function()
                Lighting.ClockTime = 14
                Lighting.Brightness = 10
                Lighting.Ambient = Color3.new(1, 1, 1)
            end)
        else
            if fullBrightConnection then
                fullBrightConnection:Disconnect()
                fullBrightConnection = nil
            end
            Lighting.Ambient = oldAmbient
            Lighting.Brightness = oldBrightness
            Lighting.ClockTime = oldClockTime
        end
    end,
})

local oldFogStart = Lighting.FogStart
local oldFogEnd = Lighting.FogEnd
local oldFogColor = Lighting.FogColor

local noFogConnection

OtherTab:Toggle({
    Title = "No Fog",
    Default = false,
    Callback = function(state)
        if state then
            Lighting.FogStart = 0
            Lighting.FogEnd = 1e10
            Lighting.FogColor = Color3.fromRGB(255, 255, 255)

            noFogConnection = RunService.RenderStepped:Connect(function()
                Lighting.FogStart = 0
                Lighting.FogEnd = 1e10
                Lighting.FogColor = Color3.fromRGB(255, 255, 255)
            end)
        else
            if noFogConnection then
                noFogConnection:Disconnect()
                noFogConnection = nil
            end
            Lighting.FogStart = oldFogStart
            Lighting.FogEnd = oldFogEnd
            Lighting.FogColor = oldFogColor
        end
    end,
})

local vibrantEffect = Lighting:FindFirstChild("VibrantEffect") or Instance.new("ColorCorrectionEffect")
vibrantEffect.Name = "VibrantEffect"
vibrantEffect.Saturation = 0.9
vibrantEffect.Contrast = 0.4
vibrantEffect.Brightness = 0.1
vibrantEffect.Enabled = false
vibrantEffect.Parent = Lighting

OtherTab:Toggle({
    Title = "Vibrant Colors",
    Default = false,
    Callback = function(state)
        if state then
            Lighting.Ambient = Color3.fromRGB(180, 180, 180)
            Lighting.OutdoorAmbient = Color3.fromRGB(170, 170, 170)
            Lighting.ColorShift_Top = Color3.fromRGB(255, 230, 200)
            Lighting.ColorShift_Bottom = Color3.fromRGB(200, 240, 255)
            vibrantEffect.Enabled = true
        else
            Lighting.Ambient = Color3.new(0, 0, 0)
            Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
            Lighting.ColorShift_Top = Color3.new(0, 0, 0)
            Lighting.ColorShift_Bottom = Color3.new(0, 0, 0)
            vibrantEffect.Enabled = false
        end
    end,
})

OtherTab:Button({
    Title = "FPS Boost",
    Callback = function()
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

            Lighting.Brightness = 0
            Lighting.FogEnd = 100
            Lighting.GlobalShadows = false
            Lighting.EnvironmentDiffuseScale = 0
            Lighting.EnvironmentSpecularScale = 0
            Lighting.ClockTime = 14
            Lighting.OutdoorAmbient = Color3.new(0, 0, 0)

            local terrain = workspace:FindFirstChildOfClass("Terrain")
            if terrain then
                terrain.WaterWaveSize = 0
                terrain.WaterWaveSpeed = 0
                terrain.WaterReflectance = 0
                terrain.WaterTransparency = 1
            end

            for _, obj in ipairs(Lighting:GetDescendants()) do
                if obj:IsA("PostEffect") or obj:IsA("BloomEffect") or obj:IsA("ColorCorrectionEffect") or obj:IsA("SunRaysEffect") or obj:IsA("BlurEffect") then
                    obj.Enabled = false
                end
            end

            for _, obj in ipairs(game:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                    obj.Enabled = false
                elseif obj:IsA("Texture") or obj:IsA("Decal") then
                    obj.Transparency = 1
                end
            end

            for _, part in ipairs(workspace:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CastShadow = false
                end
            end
        end)
        WindUI:Notify({
            Title = "FPS Boost",
            Content = "FPS boost applied successfully.",
            Duration = 3,
            Icon = "check"
        })
    end,
})

-- CAMPFIRE EFFECT TOGGLE
local Lighting = game:GetService("Lighting")
local originalColorCorrectionParent = nil

OtherTab:Toggle({
    Title = "Disable NightCampFire Effect",
    Value = false,
    Callback = function(state)
        local colorCorrection = Lighting:FindFirstChild("ColorCorrection")
        if state then
            if colorCorrection then
                if not originalColorCorrectionParent then
                    originalColorCorrectionParent = colorCorrection.Parent
                end
                colorCorrection.Parent = nil
            end
        else
            local colorCorrection = game:FindFirstChild("ColorCorrection", true)
            if colorCorrection then
                colorCorrection.Parent = originalColorCorrectionParent or Lighting
            end
        end
    end
})

-- SERVER HOPPING BUTTON
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

OtherTab:Section({
    Title = "Server",
    Icon = "server"
})

OtherTab:Button({
    Title = "Server Hop (Rejoin)",
    Callback = function()
        local placeId = game.PlaceId
        local player = Players.LocalPlayer
        TeleportService:Teleport(placeId, player)
    end
})

-- Create Anti tab
local AntiTab = Window:Tab({
    Title = "Anti",
    Icon = "skull",
    Locked = false,
})

AntiTab:Section({
    Title = "Anti Monster"
})

-- Auto Stun Deer toggle
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local torchLoop = nil

AntiTab:Toggle({
    Title = "Auto Stun Deer (Need Flashlight)",
    Value = false,
    Callback = function(state)
        if state then
            torchLoop = RunService.RenderStepped:Connect(function()
                pcall(function()
                    local remote = ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild("DeerHitByTorch")
                    local deer = workspace:FindFirstChild("Characters") and workspace.Characters:FindFirstChild("Deer")
                    if remote and deer then
                        remote:InvokeServer(deer)
                    end
                end)
                task.wait(0.1)
            end)
        else
            if torchLoop then
                torchLoop:Disconnect()
                torchLoop = nil
            end
        end
    end
})

-- Escape From Owl toggle
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local HumanoidRootPart = character:WaitForChild("HumanoidRootPart")

local ESCAPE_DISTANCE_OWL = 80
local ESCAPE_SPEED_OWL = 5

local escapeLoopOwl = nil

AntiTab:Toggle({
    Title = "Escape From Owl",
    Value = false,
    Callback = function(state)
        if state then
            escapeLoopOwl = RunService.RenderStepped:Connect(function()
                pcall(function()
                    local owl = workspace:FindFirstChild("Characters") and workspace.Characters:FindFirstChild("Owl")
                    if owl and owl:FindFirstChild("HumanoidRootPart") then
                        local myPos = HumanoidRootPart.Position
                        local owlPos = owl.HumanoidRootPart.Position
                        local distance = (myPos - owlPos).Magnitude
                        if distance < ESCAPE_DISTANCE_OWL then
                            local direction = (myPos - owlPos).Unit
                            HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + (direction * ESCAPE_SPEED_OWL)
                        end
                    end
                end)
            end)
        else
            if escapeLoopOwl then
                escapeLoopOwl:Disconnect()
                escapeLoopOwl = nil
            end
        end
    end
})

-- Escape From Deer toggle
local ESCAPE_DISTANCE_DEER = 60
local ESCAPE_SPEED_DEER = 4

local escapeLoopDeer = nil

AntiTab:Toggle({
    Title = "Escape From Deer",
    Value = false,
    Callback = function(state)
        if state then
            escapeLoopDeer = RunService.RenderStepped:Connect(function()
                pcall(function()
                    local deer = workspace:FindFirstChild("Characters") and workspace.Characters:FindFirstChild("Deer")
                    if deer and deer:FindFirstChild("HumanoidRootPart") then
                        local myPos = HumanoidRootPart.Position
                        local deerPos = deer.HumanoidRootPart.Position
                        local distance = (myPos - deerPos).Magnitude
                        if distance < ESCAPE_DISTANCE_DEER then
                            local direction = (myPos - deerPos).Unit
                            HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + (direction * ESCAPE_SPEED_DEER)
                        end
                    end
                end)
            end)
        else
            if escapeLoopDeer then
                escapeLoopDeer:Disconnect()
                escapeLoopDeer = nil
            end
        end
    end
})
