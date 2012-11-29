local widget = require("widget")
local screenW, screenH = display.contentWidth, display.contentHeight
local myMessage
local txtName
local btnClick
local imgWCA
--this is a comment
--[[this is another bigger comment]]--


local function onPlayBtnRelease(event)
	myMessage = "hi, Jen"
	print("hello " ..myMessage)
	txtName = display.newText(myMessage,0,0, "Arial", 70)
	txtName:setTextColor(255,0,0)
	txtName.x = screenW/2
	txtName.y = screenH/3
	display.remove(btnClick)
	btnClick = nil
end

local function addButton()
	btnClick = widget.newButton{
		label="click me",
		labelColor = { default={0,0,0},over={0,0,0}},
		width=254, height=140,
		defaultColor = {255,0,0},
		overColor = {0,255,0},
		onRelease = onPlayBtnRelease
	}

btnClick.x = screenW/2
btnClick.y = screenH/2
print(btnClick)

imgWCA:removeSelf()
imgWCA = nil
end

local function launch()

display.setStatusBar( display.HiddenStatusBar )

--add bg color
local background = display.newRect(0,0,screenW,screenH)
background:setFillColor (255,255,255)

--add background image
imgWCA = display.newImage( "logo.png" )
imgWCA.x = screenW/2
imgWCA.y = screenH/2

transition.to(imgWCA,{time=2500,alpha=0,onComplete=addButton})

end



launch()

