local HttpService = game:GetService("HttpService")

local Library = {}

-- Error printing toggle
Library.ErrorPrinting = false

-- Function to build a new embed structure
function Library.BuildEmbed()
    return {
        Info = {
            Settings = {
                Color = nil -- Will be set later
            },
            Embed = {
                Title = "",
                Description = "",
                Footer = ""
            }
        }
    }
end

-- Convert Color3 to Discord integer color
function Library.ColorConverter(color)
    if typeof(color) == "Color3" then
        local r = math.floor(color.R * 255)
        local g = math.floor(color.G * 255)
        local b = math.floor(color.B * 255)
        return (r * 65536) + (g * 256) + b
    end
    return color -- fallback if not Color3
end

-- Function to send data to webhook
function Library:Send(data)
    local payload = {
        content = data.content or "",
        embeds = {}
    }

    if data.embeds then
        for _, embed in pairs(data.embeds) do
            table.insert(payload.embeds, {
                title = embed.Info.Embed.Title,
                description = embed.Info.Embed.Description,
                footer = {
                    text = embed.Info.Embed.Footer
                },
                color = embed.Info.Settings.Color
            })
        end
    end

    local success, err = pcall(function()
        HttpService:PostAsync(
            data.url,
            HttpService:JSONEncode(payload),
            Enum.HttpContentType.ApplicationJson
        )
    end)

    if not success and Library.ErrorPrinting then
        warn("Webhook Error:", err)
    end
end

return Library
