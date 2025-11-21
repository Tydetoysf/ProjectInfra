-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- CloudFramework UI
local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/7siyuzi/CloudFramework/refs/heads/main/Library.lua'))()
local ThemeManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/7siyuzi/CloudFramework/refs/heads/main/addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/7siyuzi/CloudFramework/refs/heads/main/addons/SaveManager.lua'))()

-- ✅ 100 random 12-character alphanumeric keys
local ValidKeys = {
    "A9X4B7C2D6E1","Z3M8N1P4Q7R2","L5K9J2H8G3F0","W7E2R6T9Y1U3","Q8A1S4D7F2G5",
    "P9O3I6U2Y7T1","M4N8B2V5C9X0","J1K7L3M9N2O6","H5G8F2D4S7A9","E3R9T6Y1U8I2",
    "C7V2B5N9M1K4","X8Z3L6K1J9H2","T5R7E2W9Q1A8","O9P4L7K2J6M1","U2Y8I3O9P5L7",
    "G6F1D9S3A7Q2","B9N2M5K8J1H4","V3C7X1Z9L2K6","R8T2Y5U9I1O4","S7D3F9G2H6J1",
    "N4M8K2J5L9P3","Z1X7C3V9B2N6","Y9U2I5O7P3L8","A6Q1W9E3R7T2","K5J9H2G6F1D8",
    "M8N3B7V1C9X4","P2O6L9K3J7M1","T9R4E7W2Q6A1","U3Y9I2O5P7L6","G1F8D3S9A2Q7",
    "H9J2K5L8M3N1","V6C1X9Z3L7K2","R5T9Y2U6I3O8","S1D7F3G9H2J6","N9M4K1J7L3P2",
    "Z8X2C7V1B9N5","Y3U7I9O2P6L1","A9Q4W1E7R3T6","K2J8H9G1F5D7","M7N1B9V3C6X2",
    "P4O9L2K7J1M8","T6R1E9W3Q7A2","U9Y5I2O8P1L3","G7F2D9S1A6Q4","H3J9K2L7M1N5",
    "V9C4X1Z7L2K8","R2T8Y9U1I5O3","S9D6F1G7H2J4","N1M9K3J2L8P7","Z5X9C2V7B1N3",
    "Y8U1I9O4P2L6","A3Q9W7E2R6T1","K9J4H1G8F2D7","M2N9B5V1C7X3","P7O1L9K2J6M4",
    "T1R9E4W7Q2A8","U6Y2I9O3P7L5","G9F7D1S2A8Q4","H2J9K6L1M7N3","V1C9X5Z2L8K7",
    "R9T3Y1U7I2O6","S2D9F4G1H7J5","N7M9K2J4L1P8","Z9X1C7V3B5N2","Y2U9I6O1P7L4",
    "A7Q9W2E6R1T5","K1J9H3G7F2D8","M9N5B1V7C2X4","P3O9L7K1J5M2","T9R2E6W1Q7A3",
    "U1Y9I4O2P6L8","G2F9D7S1A3Q5","H9J1K7L2M5N8","V7C9X3Z1L5K2","R1T9Y6U2I4O7",
    "S3D9F2G7H1J8","N2M9K5J1L7P4","Z7X9C1V5B2N8","Y9U3I1O7P2L6","A2Q9W5E1R7T3",
    "K7J9H2G1F8D4","M1N9B3V7C5X2","P9O2L6K1J7M4","T3R9E1W7Q2A6","U7Y9I5O1P3L2",
    "G9F4D2S7A1Q8","H1J9K3L7M2N5","V9C7X1Z5L2K4","R4T9Y2U1I7O3","S9D1F7G2H5J8",
    "N3M9K1J7L5P2","Z2X9C7V1B3N6","Y1U9I2O7P5L8","A9Q3W7E1R6T2","K5J9H7G1F2D8",
    "M9N2B7V5C1X4","P1O9L3K7J2M6","T7R9E2W1Q5A8","U9Y4I1O7P2L6","G3F9D7S2A1Q8",
}

-- Script to load if key is valid
local ScriptURL = "https://raw.githubusercontent.com/Tydetoysf/ProjectInfra/main/arsenal.lua"

-- Create Window
local Window = Library:CreateWindow({
    Title = "Project Infra | Key System",
    Center = true,
    AutoShow = true,
})

local Tabs = {
    Main = Window:AddTab("Key System"),
    ["UI Settings"] = Window:AddTab("UI Settings"),
}

local KeyBox = Tabs.Main:AddLeftGroupbox("Enter Key")

KeyBox:AddInput("KeyInput", {
    Default = "",
    Numeric = false,
    Finished = false,
    Text = "Enter Key",
    Tooltip = "Type your access key here",
})

KeyBox:AddButton("Submit Key", function()
    local enteredKey = Options.KeyInput.Value
    for _, key in ipairs(ValidKeys) do
        if enteredKey == key then
            Library:Notify("Key Accepted! Loading script...", 5)
            task.wait(1)
            Library:Unload() -- delete UI
            loadstring(game:HttpGet(ScriptURL))()
            return
        end
    end
    Library:Notify("Invalid Key. Try again.", 5)
end)

-- Theme + Save Manager setup
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({"KeyInput"})
ThemeManager:SetFolder("infra-keysystem")
SaveManager:SetFolder("infra-keysystem/configs")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
