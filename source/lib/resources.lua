

bodyImage = playdate.graphics.image.new("Images/chaos")
bubbleImage = playdate.graphics.image.new("Images/emotion")

boidRectangle = playdate.graphics.image.new("Images/boid_rectangle")

emotionSad = playdate.graphics.image.new("Images/bubble_sad")
emotionHappy = playdate.graphics.image.new("Images/bubble_happy")
emotionAngry = playdate.graphics.image.new("Images/bubble_angry")

boidSpriteSad = playdate.graphics.image.new("Images/boidspritesad")
boidSpriteAngry = playdate.graphics.image.new("Images/boidspriteangry")
boidSpriteHappy = playdate.graphics.image.new("Images/boidspritehappy")

bodyMoveAnimeTable = playdate.graphics.imagetable.new("Images/boidAnims-table-32-32")

explosionAnimeTable = playdate.graphics.imagetable.new("Images/explosion-table-32-32")

ghostAnimeTable = playdate.graphics.imagetable.new("Images/ghost-table-32-32")

uiEmotestable = playdate.graphics.imagetable.new("Images/ui-table-32-32")

maskFocusImage = playdate.graphics.image.new("Images/mask-focus")

titleScreen = playdate.graphics.image.new("Images/title-screen")

tombstoneImage = playdate.graphics.image.new("Images/rip")
bubbleHappyImage = playdate.graphics.image.new("Images/bubble_happy")

imageTableBodyMove = playdate.graphics.imagetable.new(8)
imageTableBodyMove:setImage(1, bodyMoveAnimeTable:getImage(1))
imageTableBodyMove:setImage(2, bodyMoveAnimeTable:getImage(2))
imageTableBodyMove:setImage(3, bodyMoveAnimeTable:getImage(3))
imageTableBodyMove:setImage(4, bodyMoveAnimeTable:getImage(4))
imageTableBodyMove:setImage(5, bodyMoveAnimeTable:getImage(5))
imageTableBodyMove:setImage(6, bodyMoveAnimeTable:getImage(6))
imageTableBodyMove:setImage(7, bodyMoveAnimeTable:getImage(7))
imageTableBodyMove:setImage(8, bodyMoveAnimeTable:getImage(8))

imageTableHeadHappy = playdate.graphics.imagetable.new(8)
imageTableHeadHappy:setImage(1, bodyMoveAnimeTable:getImage(9))
imageTableHeadHappy:setImage(2, bodyMoveAnimeTable:getImage(10))
imageTableHeadHappy:setImage(3, bodyMoveAnimeTable:getImage(11))
imageTableHeadHappy:setImage(4, bodyMoveAnimeTable:getImage(12))
imageTableHeadHappy:setImage(5, bodyMoveAnimeTable:getImage(13))
imageTableHeadHappy:setImage(6, bodyMoveAnimeTable:getImage(14))
imageTableHeadHappy:setImage(7, bodyMoveAnimeTable:getImage(15))
imageTableHeadHappy:setImage(8, bodyMoveAnimeTable:getImage(16))

imageTableHeadSad = playdate.graphics.imagetable.new(8)
imageTableHeadSad:setImage(1, bodyMoveAnimeTable:getImage(17))
imageTableHeadSad:setImage(2, bodyMoveAnimeTable:getImage(18))
imageTableHeadSad:setImage(3, bodyMoveAnimeTable:getImage(19))
imageTableHeadSad:setImage(4, bodyMoveAnimeTable:getImage(20))
imageTableHeadSad:setImage(5, bodyMoveAnimeTable:getImage(21))
imageTableHeadSad:setImage(6, bodyMoveAnimeTable:getImage(22))
imageTableHeadSad:setImage(7, bodyMoveAnimeTable:getImage(23))
imageTableHeadSad:setImage(8, bodyMoveAnimeTable:getImage(24))

imageTableHeadAngry = playdate.graphics.imagetable.new(8)
imageTableHeadAngry:setImage(1, bodyMoveAnimeTable:getImage(25))
imageTableHeadAngry:setImage(2, bodyMoveAnimeTable:getImage(26))
imageTableHeadAngry:setImage(3, bodyMoveAnimeTable:getImage(27))
imageTableHeadAngry:setImage(4, bodyMoveAnimeTable:getImage(28))
imageTableHeadAngry:setImage(5, bodyMoveAnimeTable:getImage(29))
imageTableHeadAngry:setImage(6, bodyMoveAnimeTable:getImage(30))
imageTableHeadAngry:setImage(7, bodyMoveAnimeTable:getImage(31))
imageTableHeadAngry:setImage(8, bodyMoveAnimeTable:getImage(32))

imageTableExplosion = playdate.graphics.imagetable.new(4)
imageTableExplosion:setImage(1, explosionAnimeTable:getImage(1))
imageTableExplosion:setImage(2, explosionAnimeTable:getImage(2))
imageTableExplosion:setImage(3, explosionAnimeTable:getImage(3))
imageTableExplosion:setImage(4, explosionAnimeTable:getImage(4))

imageTableHappy = playdate.graphics.imagetable.new(4)
imageTableHappy:setImage(1, uiEmotestable:getImage(9))
imageTableHappy:setImage(2, uiEmotestable:getImage(10))
imageTableHappy:setImage(3, uiEmotestable:getImage(11))
imageTableHappy:setImage(4, uiEmotestable:getImage(12))

imageTableBomb = playdate.graphics.imagetable.new(4)
imageTableBomb:setImage(1, uiEmotestable:getImage(21))
imageTableBomb:setImage(2, uiEmotestable:getImage(22))
imageTableBomb:setImage(3, uiEmotestable:getImage(23))
imageTableBomb:setImage(4, uiEmotestable:getImage(24))

imageTableUiNoMask = playdate.graphics.imagetable.new(4)
imageTableUiNoMask:setImage(1, uiEmotestable:getImage(1))
imageTableUiNoMask:setImage(2, uiEmotestable:getImage(2))
imageTableUiNoMask:setImage(3, uiEmotestable:getImage(3))
imageTableUiNoMask:setImage(4, uiEmotestable:getImage(4))

imageTableUiMask = playdate.graphics.imagetable.new(4)
imageTableUiMask:setImage(1, uiEmotestable:getImage(5))
imageTableUiMask:setImage(2, uiEmotestable:getImage(6))
imageTableUiMask:setImage(3, uiEmotestable:getImage(7))
imageTableUiMask:setImage(4, uiEmotestable:getImage(8))

animationBoidBodyMove = playdate.graphics.animation.loop.new(80, imageTableBodyMove, true)
animationBoidHeadHappy = playdate.graphics.animation.loop.new(80, imageTableHeadHappy, true)
animationBoidHeadSad = playdate.graphics.animation.loop.new(80, imageTableHeadSad, true)
animationBoidHeadAngry = playdate.graphics.animation.loop.new(80, imageTableHeadAngry, true)

animationBomb = playdate.graphics.animation.loop.new(120,imageTableBomb, true)
animationUIHappy = playdate.graphics.animation.loop.new(120,imageTableHappy, true)
animationUINoMask = playdate.graphics.animation.loop.new(120,imageTableUiNoMask,true)
animationUIMask = playdate.graphics.animation.loop.new(120,imageTableUiMask,true)

animationGhost = playdate.graphics.animation.loop.new(75,ghostAnimeTable, true)

