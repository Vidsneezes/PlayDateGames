GameName = nil
ScoreLabel = nil

function SetBackground()
    local backgroundImage = playdate.graphics.image.new("Images/background")
    playdate.graphics.sprite.setBackgroundDrawingCallback(function (x, y, width, height)
        backgroundImage:draw(0,0)
    end)
end

function ReadJson()
    local json = playdate.datastore.read("Data")
    GameName = json.gameName
    ScoreLabel = json.scoreLabel
end

function ReadFile()
    local f = playdate.file.open("Data.json")
    print(f:readline())
    f:close()
end
