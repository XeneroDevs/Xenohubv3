local Library = {}

Library.ErrorPrinting = false

function Library.BuildEmbed()
    return {
        Info = {}
    }
end

function Library.ColorConverter(color)
    return color
end

function Library:Send(data)
    print("Send called")
    print(data.url)
end

return Library
