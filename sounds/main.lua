local HttpService = game:GetService("HttpService")
local SoundLibrary = {}
SoundLibrary.List = {}

local sounds = "https://raw.githubusercontent.com/iusearchbtwn/storage/refs/heads/main/sounds/sounds.json"

function SoundLibrary:Init()
    if sounds == "" or sounds == "https://raw.githubusercontent.com/iusearchbtwn/storage/refs/heads/main/sounds/sounds.json" then
        warn("Please provide a valid URL in the 'sounds' variable")
        return self
    end

    local success, response = pcall(function()
        return game:HttpGet(sounds)
    end)
    
    if not success then 
        warn("Failed to load sounds.json")
        return self
    end
    
    local soundData = HttpService:JSONDecode(response)
    if makefolder then makefolder("DownloadedSounds") end

    local baseUrl = sounds:gsub("sounds%.json$", "")

    for soundEventName, eventData in pairs(soundData) do
        if eventData.sounds and eventData.sounds then
            local rawSoundPath = eventData.sounds
            local cleanSoundName = rawSoundPath:gsub("^.-:", "")
            local fileName = "DownloadedSounds/" .. cleanSoundName .. ".ogg"
            
            if not isfile(fileName) then
                local fileUrl = baseUrl .. "sounds/" .. cleanSoundName .. ".ogg"
                local downloadSuccess, fileBytes = pcall(function()
                    return game:HttpGet(fileUrl)
                end)
                
                if downloadSuccess then
                    writefile(fileName, fileBytes)
                end
            end
            
            if isfile(fileName) then
                self.List[soundEventName] = getcustomasset(fileName)
            end
        end
    end
    
    return self
end

return SoundLibrary
