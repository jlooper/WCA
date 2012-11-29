local widget = require("widget")
local screenW, screenH = display.contentWidth, display.contentHeight

local gameLayer    = display.newGroup()
local bulletsLayer = display.newGroup()
local enemiesLayer = display.newGroup()
local gameIsActive = true
local score = 0
local toRemove = {}
local timeLastBullet, timeLastEnemy = 0, 0
local bulletInterval = 1000

local splash,btnGo,btnPlay,background,player,halfPlayerWidth,scoreText,sounds

local physics = require("physics")
physics.start()
physics.setGravity(0, 20)

local textureCache = {}
textureCache[1] = display.newImage("assets/graphics/enemy.png"); textureCache[1].isVisible = false;
textureCache[2] = display.newImage("assets/graphics/bullet.png");  textureCache[2].isVisible = false;
local halfEnemyWidth = textureCache[1].contentWidth * .5

-- Take care of collisions
local function onCollision(self, event)
	-- Bullet hit enemy
	if self.name == "bullet" and event.other.name == "enemy" and gameIsActive then
		-- Increase score
		score = score + 1
		scoreText.text = score
		
		-- Play Sound
		audio.play(sounds.boom)
		
		-- We can't remove a body inside a collision event, so queue it to removal.
		-- It will be removed on the next frame inside the game loop.
		table.insert(toRemove, event.other)
	
	-- Player collision - GAME OVER	
	elseif self.name == "player" and event.other.name == "enemy" then
		audio.play(sounds.gameOver)
		
		local gameoverText = display.newText("Game Over!", 0, 0, "Arial", 35)
		gameoverText:setTextColor(255, 255, 255)
		gameoverText.x = display.contentCenterX
		gameoverText.y = display.contentCenterY
		gameLayer:insert(gameoverText)
		
		-- This will stop the gameLoop
		gameIsActive = true
	end
end



local function playerMovement(event)
	-- Doesn't respond if the game is ended
	if not gameIsActive then return false end
	
	-- Only move to the screen boundaries
	if event.x >= halfPlayerWidth and event.x <= display.contentWidth - halfPlayerWidth then
		-- Update player x axis
		player.x = event.x
	end
end

local function gameLoop(event)
	if gameIsActive then
		-- Remove collided enemy planes
		for i = 1, #toRemove do
			toRemove[i].parent:remove(toRemove[i])
			toRemove[i] = nil
		end
	
		-- Check if it's time to spawn another enemy,
		-- based on a random range and last spawn (timeLastEnemy)
		if event.time - timeLastEnemy >= math.random(600, 1000) then
			-- Randomly position it on the top of the screen
			local enemy = display.newImage("assets/graphics/enemy.png")
			enemy.x = math.random(halfEnemyWidth, display.contentWidth - halfEnemyWidth)
			enemy.y = -enemy.contentHeight

			-- This has to be dynamic, making it react to gravity, so it will
			-- fall to the bottom of the screen.
			physics.addBody(enemy, "dynamic", {bounce = 0})
			enemy.name = "enemy"
			
			enemiesLayer:insert(enemy)
			timeLastEnemy = event.time
		end
	
		-- Spawn a bullet
		if event.time - timeLastBullet >= math.random(250, 300) then
			local bullet = display.newImage("assets/graphics/bullet.png")
			bullet.x = player.x
			bullet.y = player.y - halfPlayerWidth
		
			-- Kinematic, so it doesn't react to gravity.
			physics.addBody(bullet, "kinematic", {bounce = 0})
			bullet.name = "bullet"
			
			-- Listen to collisions, so we may know when it hits an enemy.
			bullet.collision = onCollision
			bullet:addEventListener("collision", bullet)
		
			gameLayer:insert(bullet)
			
			-- Pew-pew sound!
			audio.play(sounds.pew)
			
			-- Move it to the top.
			-- When the movement is complete, it will remove itself: the onComplete event
			-- creates a function to will store information about this bullet and then remove it.
			transition.to(bullet, {time = 1000, y = -bullet.contentHeight,
				onComplete = function(self) self.parent:remove(self); self = nil; end
			})
						
			timeLastBullet = event.time
		end
	end
end



local function onPlayBtnRelease(event)
	--setup game
	display.remove(btnGo)
	btnGo = nil
	display.remove(splash)
	splash = nil

	audio.setMaxVolume( 0.85, { channel=1 } )

	-- Pre-load our sounds
	sounds = {
		pew = audio.loadSound("assets/sounds/pew.wav"),
		boom = audio.loadSound("assets/sounds/boom.wav"),
		gameOver = audio.loadSound("assets/sounds/gameOver.wav")
	}

	background = display.newRect(0, 0, display.contentWidth, display.contentHeight)
	background:setFillColor(21, 115, 193)
	gameLayer:insert(background)

	gameLayer:insert(bulletsLayer)
	gameLayer:insert(enemiesLayer)

	-- Load and position the player
	player = display.newImage("assets/graphics/player.png")
	player.x = display.contentCenterX
	player.y = display.contentHeight - player.contentHeight

	-- Store half width, used on the game loop
	halfPlayerWidth = player.contentWidth * .5

	-- Add a physics body. It is kinematic, so it doesn't react to gravity.
	physics.addBody(player, "kinematic", {bounce = 0})

	-- This is necessary so we know who hit who when taking care of a collision event
	player.name = "player"

	-- Listen to collisions
	player.collision = onCollision
	
	player:addEventListener("collision", player)

	player:addEventListener("touch", playerMovement)

	player:addEventListener("touch", gameLoop)

	
	-- Add to main layer
	gameLayer:insert(player)

	
	-- Show the score
	scoreText = display.newText(score, 0, 0, "Arial", 35)
	scoreText:setTextColor(255, 255, 255)
	scoreText.x = 30
	scoreText.y = 25
	
	gameLayer:insert(scoreText)

end



local function addButton()
	btnGo = widget.newButton{
		label="Play!",
		labelColor = { default={0,0,0},over={0,0,0}},
		width=254, height=140,
		defaultColor = {255,0,0},
		overColor = {0,255,0},
		onRelease = onPlayBtnRelease
	}

	btnGo.x = screenW/2
	btnGo.y = screenH/2

	imgWCA:removeSelf()
	imgWCA = nil
end

local function launch()

	display.setStatusBar( display.HiddenStatusBar )

	--add bg color
	splash = display.newRect(0,0,screenW,screenH)
	splash:setFillColor (255,255,255)

	--add background image
	imgWCA = display.newImage( "assets/graphics/logo.png" )
	imgWCA.x = screenW/2
	imgWCA.y = screenH/2

	transition.to(imgWCA,{time=2500,alpha=2500,onComplete=addButton})

end


launch()

