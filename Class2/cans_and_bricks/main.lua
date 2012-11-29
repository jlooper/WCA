--
-- Abstract: Bullet sample project
-- Demonstrates "isBullet" attribute for continuous collision detection
-- 
-- Version: 1.1 (revised for Alpha 2)
-- 
-- Sample code is MIT licensed, see http://developer.anscamobile.com/code/license
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.

local physics = require("physics")
physics.start()

physics.setScale( 40 )

display.setStatusBar( display.HiddenStatusBar )

-- The final "true" parameter overrides Corona's auto-scaling of large images
local background = display.newImage( "images/bricks.png", 0, 0, true )
background.x = display.contentWidth / 2
background.y = display.contentHeight / 2

local floor = display.newImage( "images/floor.png", 0, 280, true )
physics.addBody( floor, "static", { friction=0.5 } )

local stand = display.newImage( "images/stand.png", 170, 220 )
physics.addBody( stand, "static", { friction=0.5 } )

local cans = {}

for i = 1, 7 do
	for j = 1, 8 do
	cans[i] = display.newImage( "images/soda_can.png", 190 + (i*24), 220 - (j*40) )
	physics.addBody( cans[i], { density=0.2, friction=0.1, bounce=0.5 } )
	end
end

local bricks = {}
local n = 0

local function throwBrick()
	n = n + 1
	bricks[n] = display.newImage( "images/brick.png", -20, 140 - (n*20) )
	physics.addBody( bricks[n], { density=3.0, friction=0.5, bounce=0.05 } )

	-- remove the "isBullet" setting below to see the brick pass through cans without colliding!
	bricks[n].isBullet = true

	bricks[n].angularVelocity = 100
	bricks[n]:applyForce( 1200, 0, bricks[n].x, bricks[n].y )
end

local function start()
	-- throw 3 bricks
	timer.performWithDelay( 360, throwBrick, 3 )
end

-- wait 800 milliseconds, then call start function above
timer.performWithDelay( 800, start )
