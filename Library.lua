local HttpService = game:GetService("HttpService")

local Library = {}

Library.ErrorPrinting = false

function Library.BuildEmbed()
	return {
		Info = {
			Settings = {
				Color = nil
			},
			Embed = {
				Title = "",
				Description = "",
				Footer = ""
			}
		}
	}
end

function Library.ColorConverter(color)
	-- Roblox Color3 -> Discord integer color
	if typeof(color) == "Color3" then
		local r = math.floor(color.R * 255)
		local g = math.floor(color.G * 255)
		local b = math.floor(color.B * 255)

		return (r * 65536) + (g * 256) + b
	end

	return color
end

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
