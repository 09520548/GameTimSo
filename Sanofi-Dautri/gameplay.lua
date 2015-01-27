local composer = require( "composer" )
local scene = composer.newScene()

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

function checkMatch()
	if (selectFirst == selectSecond) then
		return true
	else
		return false
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
end

function drawImage()
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

	gameboard = display.newImageRect( "images/gameboard.png", 852, 681 )
	gameboard.anchorX = 0.5
	gameboard.anchorY = 0.5
	gameboard.x = _W/2 - 25
	gameboard.y = _H/2 + 30
	
	sceneGroup:insert( background )
	sceneGroup:insert( logo )
	sceneGroup:insert( gameboard )
	sceneGroup:insert( cardGroup)
	
end

function scene:show( event )
	local  sceneGroup = self.view
	local phase = event.phase
		
	if (phase == "will") then
		-- Called when the scene is still off screen (but is about to come on screen).
	elseif (phase == "did") then
		initData()
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