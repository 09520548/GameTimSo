local composer = require( "composer" )
local scene = composer.newScene()
local progressRing = require("utils.progressRing")


local _W = display.viewableContentWidth
local _H = display.viewableContentHeight

local arrData = {1,2,3,4}
local arrGameBoard = {1,2,3,4}
local buttonImages = {1,1, 2,2, 3,3, 4,4, 5,5, 6,6, 7,7, 8,8, 9,9, 10,10}
local cardGroup = display.newGroup()
local coverGroup = display.newGroup()
local selectFirst = 0
local selectSecond = 0
local lastSelect = "0/0"
local tmpStoreSelect = {}
local timeCountDown = 60;
local groupPopup = display.newGroup();
local numCoupleCardFound = 0
local isConselect = true
local isBeginCheck = false
local isAllowSelect = false
local mainGroup = display.newGroup()
local arrCircleCountDown = display.newGroup()

print = function() end

function checkMatch()
	if (selectFirst == selectSecond) then
		audio.play( matchSoundFile )
		return true
	else
		return false
	end
end

function checkWin()
	isWin = true
	for i=1,4 do
		for j=1,5 do
			if (arrData[i][j] ~= 100) then
				isWin = false
			end
		end
	end
	return isWin
end

function checkTimeout(event)
	local numCardFound = 0
	if (timeCountDown>0) then

		for i=1,cardGroup.numChildren do
			card = cardGroup[i]
			if (card.tag == 100) then
				numCardFound = numCardFound + 1
			end
		end
		numCoupleCardFound = numCardFound/2
	else
		if(timerCountDown ~= nil) then
			timer.cancel(timerCountDown)
			-- cicleCountDown:pause()
		end
		if (checkWin()) then
			txtDialog2.alpha = 0
			txtDialog.alpha = 1
			txtDialog3.text = "Số điểm của bạn là 1500 điểm"
			groupPopup:toFront()
		else
			txtDialog2.alpha = 1
			txtDialog2.text = "CHÚC MỪNG BẠN ĐÃ TÌM RA "..numCoupleCardFound.."/10 HÌNH"
			txtDialog.alpha = 0
			txtDialog3.text = "Số điểm của bạn là "..(numCoupleCardFound*50).." điểm"
			groupPopup:toFront()
		end
	end
end

function selectImage( event )
	local target = event.target
	if	(event.phase == "ended") then
		local positionRow = tonumber(string.sub(event.target.name,1,1))
		local positionCol = tonumber(string.sub(event.target.name,3))
		if (isConselect) then
			audio.play( clickSoundFile )
			isConselect = false
			transition.scaleTo(target, {time=300, xScale=0, onComplete=function()
				target.alpha = 0
				for i=1,cardGroup.numChildren do
					card = cardGroup[i]
					if (card.name== target.name) then
						transition.scaleTo(card, {time=300, xScale=1, onComplete=function()
							if (selectFirst == 0 and selectSecond == 0) then
								selectFirst = target.tag
								isConselect = true
							elseif (selectFirst ~= 0 and selectSecond == 0) then
								selectSecond = target.tag
								isBeginCheck = true
							end
						end})
					end
				end
			end})
		end

	end

	return true
end

function drawImage()

	cardGroup:removeSelf()
	cardGroup = nil
	cardGroup = display.newGroup()
	mainGroup:insert(cardGroup)
	coverGroup:removeSelf()
	coverGroup = nil
	coverGroup = display.newGroup()
	mainGroup:insert(coverGroup)

	local currX = 200
	local currY = 90
	for i=1,4 do
		for j=1,5 do
			local card = display.newImageRect( "images/img_"..arrGameBoard[i][j]..".png", 62, 159 )
			card.anchorX = 0.5
			card.anchorY = 0
			card.x = currX
			card.y = currY
			card.tag = arrGameBoard[i][j]
			card.name = i.."/"..j
			card:scale(0, 1)
			cardGroup:insert(card)

			local cardCover = display.newImageRect( "images/img_cover.png", 62, 159 )
			cardCover.anchorX = 0.5
			cardCover.anchorY = 0
			cardCover.x = currX
			cardCover.y = currY
			cardCover.name = i.."/"..j
			cardCover.tag = arrGameBoard[i][j]
			cardCover:addEventListener("touch", selectImage)
			coverGroup:insert(cardCover)
			currX = currX + 150
		end
		currX = 200
		currY = currY + 165
	end
end

function initData()
	for i=1,4 do
		arrData[i] = {1,2,3,4,5}
		arrGameBoard[i] = {1,2,3,4,5}
	end
	for i=1,4 do
		for j=1,5 do
			arrData[i][j] = -1
			temp = math.random(1,#buttonImages)
			arrGameBoard[i][j] = buttonImages[temp]
			table.remove(buttonImages, temp)
		end
	end
	drawImage()
end

function replay(event)
	if (event.phase == "ended") then
		buttonImages = {1,1, 2,2, 3,3, 4,4, 5,5, 6,6, 7,7, 8,8, 9,9, 10,10}
		initData()
		timeCountDown = 60
		numCoupleCardFound = 0;
		timerCountDown = timer.performWithDelay( 1000, function()
			timeCountDown=timeCountDown-1;
			if(timeCountDown < 10) then
				txtTime.text = "00:".."0"..timeCountDown
			else
				txtTime.text = "00:"..timeCountDown
			end
		end,0 )
		groupPopup:toBack()

		cicleCountDown:play()

		
		-- ringObject:removeSelf()
		-- ringObject = nil;

		-- ringObject = progressRing.new({
	 --     radius = 50,
	 --     -- bgColor = {1, 0, 0, 1},
	 --     -- ringColor = {0, 1, 0, 1},
	 --     ringColor = {74/255, 99/255, 172, 1},
	 --     bgColor = {1, 1, 1, 1},
	 --     ringDepth = .22,
	 --     time = 60000,
	 --     position = 0
		-- })
		-- ringObject.anchorX = 0
		-- ringObject.anchorY = 0
		-- ringObject.x =  _W-60
		-- ringObject.y = 70
		-- ringObject:goTo(1);
		-- ringObject:resume()
	end
	return true
end

function createPopup( parentGroup )

	bgPopup = display.newImageRect( "images/bg_popup.png", _W, _H )
	bgPopup.anchorX = 0.5
	bgPopup.anchorY = 0.5
	bgPopup.x = _W/2
	bgPopup.y = _H/2
	groupPopup:insert(bgPopup)

	btnReplay = display.newImageRect( "images/btn_replay.png", 151, 65 )
	btnReplay.anchorX = 0.5
	btnReplay.anchorY = 0.5
	btnReplay.x = _W/2
	btnReplay.y = _H/2+50
	groupPopup:insert(btnReplay)
	btnReplay:addEventListener("touch", back)

	optDialog = 
	{
    	text = "CHÚC MỪNG BẠN ĐÃ HOÀN THÀNH NHIỆM VỤ",
    	x = display.contentWidth/2,
    	align = "center",
    	y = 300,
    	height = 150,
    	width = 500,     --required for multi-line and alignment
    	-- font = "UTM Cookies",
    	fontSize = 40
	}
	txtDialog = display.newText( optDialog )
	txtDialog:setFillColor( 74/255, 99/255, 172/255  )
	groupPopup:insert(txtDialog)
	txtDialog.name = "txtDialog"

	optDialog2 = 
	{
    	text = "CHÚC MỪNG BẠN ĐÃ TÌM RA 4/10 HÌNH",
    	x = display.contentWidth/2,
    	align = "center",
    	y = 300,
    	height = 150,
    	width = 500,     --required for multi-line and alignment
    	-- font = "UTM Cookies",
    	fontSize = 40
	}
	txtDialog2 = display.newText( optDialog2 )
	txtDialog2:setFillColor( 74/255, 99/255, 172/255  )
	groupPopup:insert(txtDialog2)
	txtDialog2.name = "txtDialog2"

	optDialog3 = 
	{
    	text = "Số điểm của bạn là 1000 điểm",
    	x = display.contentWidth/2,
    	align = "center",
    	y = 410,
    	height = 150,
    	width = 500,     --required for multi-line and alignment
    	-- font = "UTM Cookies",
    	fontSize = 35
	}
	txtDialog3 = display.newText( optDialog3 )
	txtDialog3:setFillColor( 74/255, 99/255, 172/255  )
	groupPopup:insert(txtDialog3)
	txtDialog3.name = "txtDialog3"

	parentGroup:insert(groupPopup)
	groupPopup:toBack()

	-- optDialog3 = 
	-- {
 --    	text = "a",
 --    	x = display.contentWidth/2,
 --    	align = "center",
 --    	y = 100,
 --    	height = 150,
 --    	width = 500,     --required for multi-line and alignment
 --    	-- font = "UTM Cookies",
 --    	fontSize = 40
	-- }
	-- txtDialog3 = display.newText( optDialog3 )
	-- txtDialog3:setFillColor( 0, 0, 0 )
end

function reflipCard()
	if (isBeginCheck) then
		isBeginCheck = false
		if (checkMatch() == false) then
			for i=1,cardGroup.numChildren do
				card = cardGroup[i]
				if (card.xScale == 1 and card.tag ~= 100) then
					transition.scaleTo( card, {time=300, xScale=0, onComplete=function()
						coverGroup[i].alpha = 1
						transition.scaleTo( coverGroup[i], {time=300, xScale=1, onComplete=function()
							selectFirst = 0
							selectSecond = 0
							isConselect = true
						end})
					end})
				end
			end
		else
			for i=1,cardGroup.numChildren do
				card = cardGroup[i]
				if (card.tag == selectFirst) then
					card.tag = 100
				end
			end
			selectFirst = 0
			selectSecond = 0
			isConselect = true
		end
	end
end

function back( event )
	if (event.phase == "ended") then
		Runtime:removeEventListener( "enterFrame", checkTimeout )
		composer.gotoScene( "intro" )
	end
	return true
end

function scene:create( event )
	local sceneGroup = self.view
	mainGroup = sceneGroup

	-- initialize the scene
	background = display.newImageRect( "images/bg.png", _W, _H )
	background.anchorX = 0
	background.anchorY = 0
	background.x = 0
	background.y = 0

	logo = display.newImageRect("images/logo.png", 216, 46)
	logo.anchorX = 0
	logo.anchorY = 0
	logo.x = 10
	logo.y = 10

	gameboard = display.newImageRect( "images/gameboard.png", 852, 681 )
	gameboard.anchorX = 0.5
	gameboard.anchorY = 0.5
	gameboard.x = _W/2 - 25
	gameboard.y = _H/2 + 30
	
	sceneGroup:insert( background )
	sceneGroup:insert( logo )
	sceneGroup:insert( gameboard )
	sceneGroup:insert( cardGroup)
	sceneGroup:insert( coverGroup)

	options2 = 
	{
    	text = "00:60",
    	x = _W-65,
    	align = "center",
    	y = 65,
    	fontSize = 25
	}

	txtTime = display.newText( options2 )
	txtTime:setFillColor( 0, 0, 0 )
	sceneGroup:insert(txtTime)
	txtTime.name = "txtTime"
	sceneGroup:insert(txtTime)

	-- for i=0,timeCountDown-1 do
	-- 	local countDownCircle = display.newImageRect( "images/countdown_"..i..".png", 100, 100 )
	-- 	countDownCircle.anchorX = 0
	-- 	countDownCircle.anchorY = 0
		-- countDownCircle.x = _W - 110
		-- countDownCircle.y = 20
	-- 	-- countDownCircle.isVisible = false
	-- 	arrCircleCountDown:insert(countDownCircle)
	-- end

	local seqCircle = { 
	  { name="normal", start=1, count=60, time=60000, loopCount = 1}
	}
	local optionsCircle =
	{
    	--required parameters
    	width = 184,
    	height = 184,
    	numFrames = 60,

   		--optional parameters; used for dynamic resolution support
    	sheetContentWidth = 1840,  -- width of original 1x size of entire sheet
    	sheetContentHeight = 1104  -- height of original 1x size of entire sheet
	}
	circleSprite = graphics.newImageSheet( "images/sprite_circle.png", optionsCircle)
	cicleCountDown = display.newSprite( circleSprite, seqCircle )
	cicleCountDown:scale(0.5, 0.5)
	cicleCountDown.anchorX = 0
	cicleCountDown.anchorY = 0
	cicleCountDown.x = _W - 110
	cicleCountDown.y = 20
	cicleCountDown:play()
	sceneGroup:insert(cicleCountDown)
	

	timerCountDown = timer.performWithDelay( 1000, function()
		timeCountDown=timeCountDown-1;
		if(timeCountDown < 10) then
			txtTime.text = "00:".."0"..timeCountDown
		else
			txtTime.text = "00:"..timeCountDown
		end
	end,0 )

	btnBack = display.newImageRect("images/btn_back.png", 92, 62)
	btnBack.anchorX = 1
	btnBack.anchorY = 1
	btnBack.x = _W-10
	btnBack.y = _H - 10
	sceneGroup:insert(btnBack)
	btnBack:addEventListener("touch", back)

	-- ringObject = progressRing.new({
 --     radius = 50,
 --     -- bgColor = {1, 0, 0, 1},
 --     -- ringColor = {0, 1, 0, 1},
 --     ringColor = {74/255, 99/255, 172, 1},
 --     bgColor = {1, 1, 1, 1},
 --     ringDepth = .22,
 --     time = 60000,
 --     position = 0
	-- })
	-- ringObject.anchorX = 0
	-- ringObject.anchorY = 0
	-- ringObject.x =  _W-60
	-- ringObject.y = 70
	-- ringObject:goTo(1);
	-- ringObject:resume()
	-- sceneGroup:insert(ringObject)

	createPopup(sceneGroup)

	Runtime:addEventListener("enterFrame", reflipCard)
	
	
end

function scene:show( event )
	local  sceneGroup = self.view
	local phase = event.phase
		
	if (phase == "will") then
		-- Called when the scene is still off screen (but is about to come on screen).
	elseif (phase == "did") then
		initData()
		Runtime:addEventListener("enterFrame", checkTimeout)

		bgSoundFile = audio.loadSound("bg.mp3" )
		bgsound = audio.play( bgSoundFile, { channel=1, loops=-1} )

		clickSoundFile = audio.loadSound("click.mp3" )
		matchSoundFile = audio.loadSound("get.mp3")
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if (phase == "will") then
		-- Called when the scene is on screen (but is about to go off screen).
      	-- Insert code here to "pause" the scene.
      	-- Example: stop timers, stop animation, stop audio, etc.
      	timer.cancel(timerCountDown)
      	audio.stop(bgsound)
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