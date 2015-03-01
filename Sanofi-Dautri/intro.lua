local composer = require( "composer" )
local scene = composer.newScene()

local _W = display.viewableContentWidth
local _H = display.viewableContentHeight

function startGame( event )
	if (event.phase == "ended") then
		composer.gotoScene( "gameplay" )
	end
end

function scene:create( event )
	local sceneGroup = self.view

	-- initialize the scene
	background = display.newImageRect( "images/bg.png", _W, _H )
	background.anchorX = 0
	background.anchorY = 0
	background.x = 0
	background.y = 0

	logoIntro = display.newImageRect("images/bg_intro.png", 872, 340)
	logoIntro.anchorX = 0.5
	logoIntro.anchorY = 0.5
	logoIntro.x = _W/2 - 50
	logoIntro.y = _H/2 - 100

	btnStart = display.newImageRect("images/btn_start.png", 151, 65)
	btnStart.anchorX = 0.5
	btnStart.anchorY = 0.5
	btnStart.x = _W/2
	btnStart.y = _H/2 + 100
	btnStart:addEventListener( "touch", startGame )
	
	sceneGroup:insert( background )
	sceneGroup:insert( logoIntro )
	sceneGroup:insert( btnStart )
	
end

function scene:show( event )
	local  sceneGroup = self.view
	local phase = event.phase
		
	if (phase == "will") then
		-- Called when the scene is still off screen (but is about to come on screen).
	elseif (phase == "did") then
		-- composer.removeScene( "gameplay" ) 
		composer.removeHidden()
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if (phase == "will") then
		-- Called when the scene is on screen (but is about to go off screen).
      	-- Insert code here to "pause" the scene.
      	-- Example: stop timers, stop animation, stop audio, etc.
      elseif (phase == "did") then
      	-- Called immediately after scene goes off screen.

	end
end

function scene:destroy( event )
	local sceneGroup = self.view
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene