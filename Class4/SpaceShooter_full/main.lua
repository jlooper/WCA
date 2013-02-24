display.setStatusBar(display.HiddenStatusBar)


local physics = require('physics')
physics.start()
physics.setGravity(0, 0)

local sprite = require("sprite")

local title, playBtn, creditsBtn, titleView, ship, boss, score, lives, timerSource

local bg = display.newImage('assets/images/bg.png')

local shot = audio.loadSound('assets/sounds/shot.mp3')
local explo = audio.loadSound('assets/sounds/explo.mp3')
local bossSound = audio.loadSound('assets/sounds/boss.mp3')

local lives = display.newGroup()
local bullets = display.newGroup()
local enemies = display.newGroup()
local scoreN = 0
local bossHealth = 20

local Main = {}
local addTitleView = {}
local removeTitleView = {}
local addShip = {}
local addScore = {}
local addLives = {}
local listeners = {}
local moveShip = {}
local shoot = {}
local addEnemy = {}
local alert = {}
local alertView = {}
local update = {}
local collisionHandler = {}
local restart = {}

-- Main Function

function Main()
	addTitleView()
	bullets = display.newGroup()
	lives = display.newGroup()
	enemies = display.newGroup()
	bossHealth = 20

end

function addTitleView()
	title = display.newImage('assets/images/title.png')
	playBtn = display.newImage('assets/images/playBtn.png')
	playBtn.x = display.contentCenterX
	playBtn.y = display.contentCenterY + 10
	playBtn:addEventListener('tap', removeTitleView)
	
	titleView = display.newGroup(title, playBtn)
end

function removeTitleView:tap(e)
	transition.to(titleView,  {
		time = 300, 
		y = -display.contentHeight, 
		onComplete = function() 
		display.remove(titleView) 
		titleView = null
		addShip() end
	})
end

function addShip()

			local shipSheet = sprite.newSpriteSheet( "assets/images/ship_spritesheet_default.png", 30, 38 )
			local shipSpriteSet = sprite.newSpriteSet(shipSheet,1,2)
			sprite.add( shipSpriteSet, "shipSheet",1,2,10)
			ship = sprite.newSprite( shipSpriteSet )
			ship.x = display.contentWidth * 0.5
			ship.y = display.contentHeight - ship.height
			ship.name = 'ship'
			ship:prepare("shipSheet")
			ship:play()
			physics.addBody(ship)
			addScore()
end

function addScore()


	score = display.newText('Score: ', 1, 0, native.systemFontBold, 14)
	score.y = display.contentHeight - score.height * 0.5
	score.text = score.text .. tostring(scoreN)
	score:setReferencePoint(display.TopLeftReferencePoint)
	score.x = 1
	
	addLives()
end

function addLives()
	for i = 1, 3 do
		live = display.newImage('assets/images/live.png')
		live.x = (display.contentWidth - live.width * 0.7) - (5 * i+1) - live.width * i + 20
		live.y = display.contentHeight - live.height * 0.7		
		lives.insert(lives, live)
	end
	listeners('add')
end

function listeners(action)
	if(action == 'add') then	
		bg:addEventListener('touch', moveShip)
		bg:addEventListener('tap', shoot)
		Runtime:addEventListener('enterFrame', update)
		timerSource = timer.performWithDelay(800, addEnemy, 0)
	else
		bg:removeEventListener('touch', moveShip)
		bg:removeEventListener('tap', shoot)
		Runtime:removeEventListener('enterFrame', update)
		timer.cancel(timerSource)
	end
end

function moveShip:touch(e)
	if(e.phase == 'began') then
		lastX = e.x - ship.x
	elseif(e.phase == 'moved') then
		ship.x = e.x - lastX
	end
end

function shoot:tap(e)
	local bullet = display.newImage('assets/images/bullet.png')
	bullet.x = ship.x
	bullet.y = ship.y - ship.height
	bullet.name = 'bullet'
	physics.addBody(bullet)	
	audio.play(shot)	
	bullets.insert(bullets, bullet)
end

function addEnemy(e)
	
			local enemySheet = sprite.newSpriteSheet( "assets/images/enemy_spritesheet_default.png", 32, 20 )
			local enemySpriteSet = sprite.newSpriteSet(enemySheet,1,2)
			sprite.add( enemySpriteSet, "enemySheet",1,2,1000)
			enemy = sprite.newSprite( enemySpriteSet )
			enemy.x = math.floor(math.random() * (display.contentWidth - enemy.width))
			enemy.y = -enemy.height
			enemy.name = 'enemy'
			enemy:prepare("enemySheet")
			enemy:play()

			physics.addBody(enemy)
			enemy.bodyType = 'static'
			enemies.insert(enemies, enemy)
			
			enemy:addEventListener('collision', collisionHandler)
end

function alert(e)
	listeners('remove')
	
	if(e == 'win') then
		alertView = display.newImage('assets/images/youWon.png')
		alertView.x = display.contentWidth * 0.5
		alertView.y = display.contentHeight * 0.5
	else
		alertView = display.newImage('assets/images/gameOver.png')
		alertView.x = display.contentWidth * 0.5
		alertView.y = display.contentHeight * 0.5
	end
	
	alertView:addEventListener('tap', restart)
end

function update(e)
	-- Move Bullets

	if(bullets.numChildren ~= 0) then
		for i = 1, bullets.numChildren do
			if(bullets[i] ~= nil) then

				bullets[i].y = bullets[i].y - 10

				if(bullets[i].y > display.contentHeight) then
					bullets:remove(bullets[i])
					display.remove(bullets[i])
				end
			end
		end
	end
	
	-- Move Enemies
	
	if(enemies.numChildren ~= 0) then
		for i = 1, enemies.numChildren do
			if(enemies[i] ~= nil) then
				
				enemies[i].y = enemies[i].y + 3
				
				if(enemies[i].y > display.contentHeight) then
					enemies:remove(enemies[i])
					display.remove(enemies[i])
				end
			end
		end
	end
	-- Show Boss
	
	if(scoreN == 50 and boss == nil) then
		audio.play(bossSound)
		
		local bossSheet = sprite.newSpriteSheet( "assets/images/boss_spritesheet_default.png", 106, 66 )
			local bossSpriteSet = sprite.newSpriteSet(bossSheet,1,2)
			sprite.add( bossSpriteSet, "bossSheet",1,2,1000)
			boss = sprite.newSprite( bossSpriteSet )
			boss.x = display.contentWidth * 0.5			
			boss:prepare("bossSheet")
			transition.to(boss, {time = 1500, y = boss.height + (boss.height * 0.5)})
			boss:play()
			boss.name = 'boss'
			physics.addBody(boss)
			boss.bodyType = 'static'
			boss:addEventListener('collision', collisionHandler)

	end
end

function collisionHandler(e)
	if(e.other.name == 'bullet' and e.target.name == 'enemy') then
		audio.play(explo)
		display.remove(e.other)
		display.remove(e.target)
		scoreN = scoreN + 50
		score.text = 'Score: ' .. tostring(scoreN)
		score:setReferencePoint(display.TopLeftReferencePoint)
		score.x = 1
	elseif(e.other.name == 'bullet' and e.target.name == 'boss') then
		audio.play(explo)
		display.remove(e.other)
		bossHealth = bossHealth - 1
		scoreN = scoreN + 50
		score.text = 'Score: ' .. tostring(scoreN)
		score:setReferencePoint(display.TopLeftReferencePoint)
		score.x = 1
		if(bossHealth <= 0) then
			display.remove(e.target)
			alert('win')
		end
	elseif(e.other.name == 'ship') then
		audio.play(explo)
		
		display.remove(e.target)
		
		display.remove(lives[lives.numChildren])
		
		if(lives.numChildren < 1) then
			alert('lose')
		end
	end
end

function restart()
	listeners('remove')
	
	display.remove(bullets)
	display.remove(enemies)
	display.remove(ship)
	display.remove(alertView)
	display.remove(lives)
	boss=nil

	--reset score
	score.text = ''
	scoreN = 0

	Main()
end

Main()