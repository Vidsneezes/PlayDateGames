import "CoreLibs/graphics"
import "CoreLibs/ui"
import "Corelibs/object"
import "CoreLibs/animation"

local pd <const> = playdate
local gfx <const> = playdate.graphics

local centerScreen = {x= 200, y = 120}
local deathBallStartPosition = {x = 200, y = 200}

blobSpawner = {x = 200, y = 80, horizontalExpand = 200, verticalExpand = 50}

local averageSpeed = 5

-- Procedural Graphics
local rectUI = gfx.image.new(400, 20)
gfx.pushContext(rectUI)
    gfx.drawRect(0,0,400,20)
gfx.popContext()

local smallDotImage1 = gfx.image.new(24,24)
gfx.pushContext(smallDotImage1)
    gfx.setBackgroundColor(gfx.kColorBlack)
    gfx.fillCircleInRect(0,0,24,24)
gfx.popContext()

local smallDotImage2 = gfx.image.new(26,26)
gfx.pushContext(smallDotImage2)
    gfx.setBackgroundColor(gfx.kColorBlack)
    gfx.fillCircleInRect(0,0,26,26)
gfx.popContext()

local smallDotImage3 = gfx.image.new(30,30)
gfx.pushContext(smallDotImage3)
    gfx.setBackgroundColor(gfx.kColorBlack)
    gfx.fillCircleInRect(0,0,30,30)
gfx.popContext()

local smallDotImage4 = gfx.image.new(32,32)
gfx.pushContext(smallDotImage4)
    gfx.setBackgroundColor(gfx.kColorBlack)
    gfx.fillCircleInRect(0,0,32,32)
gfx.popContext()

local tinyDot = gfx.image.new(14,14)
gfx.pushContext(tinyDot)
    gfx.setBackgroundColor(gfx.kColorBlack)
    gfx.drawCircleInRect(0,0,14,14)
gfx.popContext()

local tinyDot2 = gfx.image.new(9,9)
gfx.pushContext(tinyDot2)
    gfx.setBackgroundColor(gfx.kColorBlack)
    gfx.drawCircleInRect(0,0,9,9)
gfx.popContext()

local tinyDot3 = gfx.image.new(11, 11)
gfx.pushContext(tinyDot3)
    gfx.setBackgroundColor(gfx.kColorBlack)
    gfx.drawCircleInRect(0,0,11,11)
gfx.popContext()
-- end procedural graphics

-- animations image tables
local blobpulseframetime = 150
local blobpulse = gfx.imagetable.new(4)
blobpulse:setImage(1, tinyDot)
blobpulse:setImage(2, tinyDot3)
blobpulse:setImage(3, tinyDot2)
blobpulse:setImage(4, tinyDot3)

local blobbgft = 95
local blobbgpulse = gfx.imagetable.new(9)
blobbgpulse:setImage(1,smallDotImage1)
blobbgpulse:setImage(2,smallDotImage1)
blobbgpulse:setImage(3,smallDotImage2)
blobbgpulse:setImage(4,smallDotImage3)
blobbgpulse:setImage(5,smallDotImage4)
blobbgpulse:setImage(6,smallDotImage4)
blobbgpulse:setImage(7,smallDotImage4)
blobbgpulse:setImage(8,smallDotImage3)
blobbgpulse:setImage(9,smallDotImage2)
-- end animation image tables

-- Death ball class
class("DeathBall").extends()

function DeathBall:init()

    self.position = pd.geometry.vector2D.new(deathBallStartPosition.x, deathBallStartPosition.y)
    self.direction = pd.geometry.vector2D.new(0,0)
    self.aim = 0
    self.speed = 7
    self.sprite = gfx.sprite.new(tinyDot)
    
    self.sprite:setCollideRect(0,0,self.sprite:getSize())
    self.sprite:setGroups({2})
    self.sprite:setCollidesWithGroups({1})
    self.sprite.collisionResponse = gfx.sprite.kCollisionTypeOverlap
    self.sprite:moveTo(self.position.dx, self.position.dy)
    self.sprite:add()

    self.animation = gfx.animation.loop.new(blobpulseframetime, blobpulse, true)
end

function DeathBall:reset()
    self.position.dx = deathBallStartPosition.x
    self.position.dy = deathBallStartPosition.y

    self.direction.dx = 0
    self.direction.dy = 0

    self.sprite:moveTo(self.position.dx, self.position.dy)
end

function DeathBall:update()

    self.sprite:setImage(self.animation:image())

    local x,y = self.sprite:getPosition()

    if y < -5 then
        self:reset()
        return
    end

    self.position.dx = x
    self.position.dy = y


    if self.direction.dy < 0 then
        self.direction.dx = self.aim
    end

    self.position += self.direction

    self.sprite:moveWithCollisions(self.position.dx, self.position.dy)
end

function DeathBall:launch()
    self.direction.dx = self.aim
    self.direction.dy = -self.speed
end

function DeathBall:SetAim(change)
    self.aim = clamp(self.aim + change * 0.2, -10, 10)
end

-- end death ball class

-- Blob class
class("Blob").extends()

function Blob:init(xPos,yPos)
    self.position = pd.geometry.vector2D.new(xPos, yPos)
    self.sprite = gfx.sprite.new(smallDotImage1)
    self.destination = pd.geometry.vector2D.new(xPos, yPos)
    self.direction = pd.geometry.vector2D.new(0,0)
    self.alive = 1
    
    self.sprite:setCollideRect(0,0,self.sprite:getSize())
    self.sprite:setGroups({1})
    self.sprite:setCollidesWithGroups({2})
    self.sprite.collisionResponse = gfx.sprite.kCollisionTypeOverlap
    self.sprite:moveTo(self.position.dx, self.position.dy)
    self.sprite:add()

    self.animation = gfx.animation.loop.new(blobbgft, blobbgpulse, true)
end

function Blob:cleanup()
    self.sprite:remove()
end

function Blob:update()

    self.sprite:setImage(self.animation:image())

    local x,y = self.sprite:getPosition()

    self.position.dx = x
    self.position.dy = y

    if self:AtDestination() then
        self:SetRandomDestination()
    end

    self.direction = self.destination - self.position
    self.direction:normalize()
    self.position += self.direction * averageSpeed

    local actualX,actualY,collisions,numberOfCollisions = self.sprite:moveWithCollisions(self.position.dx, self.position.dy)

    if numberOfCollisions > 0 then
        self.alive = -10
    end

    self.sprite:moveTo(self.position.dx, self.position.dy)
end

function Blob:SetRandomDestination()
    local rx = random_float(blobSpawner.x - blobSpawner.horizontalExpand, blobSpawner.x + blobSpawner.horizontalExpand)
    local ry = random_float(blobSpawner.y - blobSpawner.verticalExpand, blobSpawner.y + blobSpawner.verticalExpand)
    self.destination.dx = clamp(rx, 100,300)
    self.destination.dy = clamp(ry, 50, 240-50)
end

function Blob:AtDestination()
    return pd.geometry.squaredDistanceToPoint(self.position.dx, self.position.dy, self.destination.dx, self.destination.dy) < 10
end
-- end of blob class

-- Blob System
class("BlobSystem").extends()

function BlobSystem:init()
    self.group = {}
end

function BlobSystem:spawnBlob()
    self:createBlob(centerScreen.x, centerScreen.y - 100)
end

function BlobSystem:createBlob(x,y)
    local blobber = Blob(x,y)
    table.insert(self.group, blobber)
end

function BlobSystem:generateBlobs(amount)
    for i = 1, amount, 1 do
        self:createBlob(centerScreen.x,centerScreen.y - 100)
    end
end

function BlobSystem:update()
    for index, value in ipairs(self.group) do
        value:update()        
    end

    for index, value in ipairs(self.group) do
        if value.alive < 0 then
            value:cleanup()
            table.remove(self.group, index)
            break
        end
    end
end
-- end of blob system class


-- Helper Methods
function random_float(min, max)
    return min + math.random() * (max-min)
end

function clamp(x,min,max)
    return math.min(math.max(x,min),max)
end
-- end helper methods

-- Game initialize
local blobSystem = BlobSystem()
local gameDeathball = DeathBall()

local myInputHandlers = {

    AButtonDown = function()
        gameDeathball:launch()
    end,
    cranked = function(change, acceleratedChange)
        gameDeathball:SetAim(change)
    end
}

local function gameSetup()
    blobSystem:generateBlobs(30)
    pd.inputHandlers.push(myInputHandlers)
end

-- end game initialize

-- Start game
gameSetup()
-- end start game 

-- Play date main loop
function playdate.update()
    blobSystem:update()
    gameDeathball:update()

    gfx.clear()
    gfx.sprite.update()
    gfx.drawTextAligned("MiniBlob", 2, 220, kTextAlignment.left)
    gfx.drawTextAligned("Score : 9999 ", 398, 220, kTextAlignment.right)
    rectUI:draw(0,218)
end
-- end main loop