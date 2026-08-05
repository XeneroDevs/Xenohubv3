local Library = {}

Library.ErrorPrinting = false

function Library.BuildEmbed()
    return {
        Info = {
            Settings = {},
            Embed = {}
        }
    }
end

function Library.ColorConverter(color)
    -- convert Color3 to whatever format your embed needs
    return color
end

function Library:Send(data)
    -- send webhook request here
    print("Webhook:", data.url)
end

return Library
