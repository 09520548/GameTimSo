local composer = require( "composer" )
local scene = composer.newScene()
local progressRing = require("utils.progressRing")


local _W = display.viewableContentWidth
local _H = display.viewableContentHeight

local arrData = {1,2,3,4}
local arrGameBoard = {1,2,3,4}
local buttonImages = {1,1, 2,2, 3,3, 4,4, 5,5, 6,6, 7,7, 8,8, 9,9, 10,10}
local cardGroup = display.newGroup()
local selectFirst = 0
local selectSecond = 0
local lastSelect = "0/0"
local tmpStoreSelect = {}
local timeCountDown = 60;
local groupPopup = display.newGroup();
local numCoupleCardFound = 0

print = function() end

function checkMatch()
	if (selectFirst == selectSecond) then
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
		for i=1,4 do
			for j=1,5 do
				if (arrData[i][j] == 100) then
					numCardFound = numCardFound + 1
				end
			end
		end
		numCoupleCardFound = numCardFound/2
	else
		if(timerCountDown ~= nil) then
			timer.cancel(timerCountDown)
		end
		if (checkWin()) then
			txtDialog2.alpha = 0
			txtDialog.alpha = 1
			groupPopup:toFront()
		else
			txtDialog2.alpha = 1
			txtDialog2.text = "CHÚC MỪNG BẠN ĐÃ TÌM RA "..numCoupleCardFound.."/10 HÌNH"
			txtDialog.alpha = 0
			groupPopup:toFront()
		end
	end
end

function selectImage( event )
	local target = event.target
	if	(event.phase == "ended") then
		local positionRow = tonumber(string.sub(target.name,1,1))
		local positionCol = tonumber(string.sub(target.name,3))

		transition.scaleTo( target, {time=300, xScale=0, onComplete=function()
			if (lastSelect ~= target.name) then
				if (selectFirst == 0 and selectSecond == 0)  then
					selectFirst = arrGameBoard[positionRow][positionCol]
					arrData[positionRow][positionCol] = arrGameBoard[positionRow][positionCol]
					-- luu 1 la hang, 2 la cot cua lan chon 1, 3 la hang, 4 la cot cua lan chon 2
					tmpStoreSelect[1] = positionRow
					tmpStoreSelect[2] = positionCol
					drawImage()
				elseif (selectFirst ~= 0 and selectSecond == 0) then
					selectSecond = arrGameBoard[positionRow][positionCol]
					arrData[positionRow][positionCol] = arrGameBoard[positionRow][positionCol]
					tmpStoreSelect[3] = positionRow
					tmpStoreSelect[4] = positionCol
					drawImage()

					timer.performWithDelay( 100, function()
						if (checkMatch() == false) then
							if(cardGroup.numChildren > 0) then
								for i=1,cardGroup.numChildren do
									if (cardGroup[i]~=nil) then
										local row = tonumber(string.sub(cardGroup[i].name,1,1))
										local col = tonumber(string.sub(cardGroup[i].name,3))
										if (arrData[row][col] ~= 100 and arrData[row][col] ~= -1) then
											transition.scaleTo( cardGroup[i], {time=300, xScale=0, onComplete=function()
												selectFirst = 0
												selectSecond = 0
												lastSelect = "0/0"
												drawImage()
											end})
										end
									end
								end
							end
							for i=1,4 do
								for j=1,5 do
									if (arrData[i][j] ~= 100) then
										arrData[i][j] = -1
									end
								end
							end

						else 
							arrData[tmpStoreSelect[1]][tmpStoreSelect[2]] = 100
							arrData[tmpStoreSelect[3]][tmpStoreSelect[4]] = 100
							selectFirst = 0
							selectSecond = 0
							lastSelect = "0/0"
							drawImage()
						end
						
			      	end, 1 )
				end
				lastSelect = target.name
			end
		end} )

		
		
	end

	return true
end

function drawImage()
	if (checkWin()) then
		txtDialog2.alpha = 0
		txtDialog.alpha = 1
		groupPopup:toFront()
	else
		if(cardGroup.numChildren > 0) then
			for i=1,cardGroup.numChildren do
				if (cardGroup[i]~=nil) then
					local row = tonumber(string.sub(cardGroup[i].name,1,1))
					local col = tonumber(string.sub(cardGroup[i].name,3))
					cardGroup[i]:removeEventListener("touch", selectImage)
					if (arrData[row][col] == -1) then
						cardGroup[i]:removeSelf()
						cardGroup[i] = nil;
					end
					
				end
				
			end
		end


		local currX = 200
		local currY = 90
		for i=1,4 do
			for j=1,5 do
				if (arrData[i][j] == -1) then
					local card = display.newImageRect( "images/img_cover.png", 62, 159 )
					card.anchorX = 0.5
					card.anchorY = 0
					card.x = currX
					card.y = currY
					card.name = i.."/"..j
					card.tag = arrData[i][j]
					card:addEventListener("touch", selectImage)
					cardGroup:insert(card)
				elseif (arrData[i][j] ~= 100) then
					local card = display.newImageRect( "images/img_"..arrData[i][j]..".png", 62, 159 )
					card.anchorX = 0.5
					card.anchorY = 0
					card.x = currX
					card.y = currY
					card.tag = arrData[i][j]
					card.name = i.."/"..j
					cardGroup:insert(card)
				end
				currX = currX + 150
			end
			currX = 200
			currY = currY + 165
		end
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
		
		ringObject:removeSelf()
		ringObject = nil;

		ringObject = progressRing.new({
	     radius = 50,
	     -- bgColor = {1, 0, 0, 1},
	     -- ringColor = {0, 1, 0, 1},
	     ringColor = {74/255, 99/255, 172, 1},
	     bgColor = {1, 1, 1, 1},
	     ringDepth = .22,
	     time = 60000,
	     position = 0
		})
		ringObject.anchorX = 0
		ringObject.anchorY = 0
		ringObject.x =  _W-60
		ringObject.y = 70
		ringObject:goTo(1);
		ringObject:resume()
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
	btnReplay:addEventListener("touch", replay)

	optDialog = 
	{
    	text = "CHÚC MỪNG BẠN ĐÃ HOÀN THÀNH NHIỆM VỤ",
    	x = display.contentWidth/2,
    	align = "center",
    	y = 350,
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
    	y = 350,
    	height = 150,
    	width = 500,     --required for multi-line and alignment
    	-- font = "UTM Cookies",
    	fontSize = 40
	}
	txtDialog2 = display.newText( optDialog2 )
	txtDialog2:setFillColor( 74/255, 99/255, 172/255  )
	groupPopup:insert(txtDialog2)
	txtDialog2.name = "txtDialog2"

	parentGroup:insert(groupPopup)
	groupPopup:toBack()
end

function scene:create( event )
	local sceneGroup = self.view

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

	options2 = 
	{
    	text = "00:60",
    	x = _W-60,
    	align = "center",
    	y = 70,
    	fontSize = 25
	}

	txtTime = display.newText( options2 )
	txtTime:setFillColor( 0, 0, 0 )
	sceneGroup:insert(txtTime)
	txtTime.name = "txtTime"

	timerCountDown = timer.performWithDelay( 1000, function()
		timeCountDown=timeCountDown-1;
		if(timeCountDown < 10) then
			txtTime.text = "00:".."0"..timeCountDown
		else
			txtTime.text = "00:"..timeCountDown
		end
	end,0 )

	ringObject = progressRing.new({
     radius = 50,
     -- bgColor = {1, 0, 0, 1},
     -- ringColor = {0, 1, 0, 1},
     ringColor = {74/255, 99/255, 172, 1},
     bgColor = {1, 1, 1, 1},
     ringDepth = .22,
     time = 60000,
     position = 0
	})
	ringObject.anchorX = 0
	ringObject.anchorY = 0
	ringObject.x =  _W-60
	ringObject.y = 70
	ringObject:goTo(1);
	ringObject:resume()
	sceneGroup:insert(ringObject)

	createPopup(sceneGroup)
	
end

function scene:show( event )
	local  sceneGroup = self.view
	local phase = event.phase
		
	if (phase == "will") then
		-- Called when the scene is still off screen (but is about to come on screen).
	elseif (phase == "did") then
		initData()
		Runtime:addEventListener("enterFrame", checkTimeout)
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