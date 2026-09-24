local HttpService = game:GetService("HttpService")
local FontLibrary = {}
FontLibrary.List = {}

local fonts = "https://raw.githubusercontent.com/iusearchbtwn/storage/refs/heads/main/fonts/fonts.json"

function FontLibrary:Init()
    local success, response = pcall(function()
        return game:HttpGet(fonts)
    end)
    
    if not success then 
        warn("Failed to load font list")
        return self
    end
    
    local fontList = HttpService:JSONDecode(response)
    
    if makefolder then makefolder("DownloadedFonts") end

    for _, fontData in ipairs(fontList) do
        local fileName = "DownloadedFonts/" .. fontData.name .. ".ttf"
        
        if not isfile(fileName) then
            local fontDownloaded, fontBytes = pcall(function()
                return game:HttpGet(fontData.url)
            end)
            
            if fontDownloaded then
                writefile(fileName, fontBytes)
            end
        end
        
        if isfile(fileName) then
            local customAsset = getcustomasset(fileName)
            self.List[fontData.name] = Font.new(customAsset, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        end
    end
    
    return self
end

return FontLibrary
