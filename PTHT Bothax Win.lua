local stopPlant = false
local stopHarvest = false
local isPlantRunning = false
local isHarvestRunning = false

function place(id)
	pkt = {}
	pkt.type = 3
	pkt.int_data = id
	pkt.pos_x = GetLocal().pos.x
	pkt.pos_y = GetLocal().pos.y
	pkt.int_x = math.floor(GetLocal().pos.x // 32)
	pkt.int_y = math.floor(GetLocal().pos.y // 32)
	SendPacketRaw(false,pkt)
end

function Hold()
    local pkt = {}
    pkt.type = 0
    pkt.flags = 16779298
    SendPacketRaw(pkt)
end

function notif(text)
		var = {}
		var[0] = "OnTextOverlay"
		var[1] = text
		SendVariantList(var)
end

content = [[
set_default_color|`o

add_label_with_icon|big|Edit PTHT Configuration|left|6840
add_label|small| |left
add_text_input|plantId|Plant ID|]]..plantId..[[|5|
add_text_input|harvestId|Harvest ID|]]..harvestId..[[|5|
add_text_input|startY|Start Y|]]..startY..[[|5|
add_text_input|endX|End X|]]..endX..[[|5|
add_text_input|delayPlant|Delay Plant|]]..delayPlant..[[|5|
add_text_input|delayHarvest|Delay Harvest|]]..delayHarvest..[[|5|
add_text_input|farPlant|Far Plant|]]..farPlant..[[|5|
add_label|small| |left
add_checkbox|planting|Plants|0
add_checkbox|harvesting|Harvests|0
add_checkbox|looping|Loop|0
add_small_font_button|modfly|Turn Off ModFly|noflags|0|0|
end_dialog|ptht|Cancel|Ok
		]]

Sleep(500)
notif("Script Executed [PTHT]\n    `2Credit : `1Rtnt-#7940")
function dialog(types, packet)
function IsReady(tile)
	if tile and tile.extra and tile.extra.progress and tile.extra.progress == 1.0 then
		return true
	end 
	return false
end
function insert()
	plantId = tonumber(packet:match("plantId|(.*)harvestId"))
	harvestId = tonumber( packet:match("harvestId|(.*)startY"))
	startY = tonumber(packet:match("startY|(.*)endX"))
	endX = tonumber(packet:match("endX|(.*)delayPlant"))
	delayPlant = tonumber(packet:match("delayPlant|(.*)delayHarvest"))
	delayHarvest = tonumber(packet:match("delayHarvest|(.*)farPlant"))
	farPlant = tonumber(packet:match("farPlant|(.*)planting"))
end
--check checkbox value
if types == 2 then
	if packet:find("action|input\n|text") and packet:find(command) then
		var = {}
		var[0] = "OnDialogRequest"
		var[1] = content
	    SendVariantList(var)
	end
	if packet:find("action|dialog_return\ndialog_name|ptht") then
		insert()
		content = [[
set_default_color|`o

add_label_with_icon|big|Edit PTHT Configuration|left|6840
add_label|small| |left
add_text_input|plantId|Plant ID|]]..plantId..[[|5|
add_text_input|harvestId|Harvest ID|]]..harvestId..[[|5|
add_text_input|startY|Start Y|]]..startY..[[|5|
add_text_input|endX|End X|]]..endX..[[|5|
add_text_input|delayPlant|Delay Plant|]]..delayPlant..[[|5|
add_text_input|delayHarvest|Delay Harvest|]]..delayHarvest..[[|5|
add_text_input|farPlant|Far Plant|]]..farPlant..[[|5|
add_label|small| |left
add_checkbox|planting|Plants|0
add_checkbox|harvesting|Harvests|0
add_checkbox|looping|Loop|0
add_small_font_button|modfly|Turn Off ModFly|noflags|0|0|
end_dialog|ptht|Cancel|Ok
		]]
	end
	if packet:find("planting|1\nharvesting|1\nlooping|1") or packet:find("planting|1\nharvesting|1") then
		content = content:gsub("Plants|1","Plants|0")
		content = content:gsub("Harvests|1","Harvests|0")
		content = content:gsub("Loop|1","Loop|0")
		stopHarvest = true
		stopPlant = true
	elseif packet:find("looping|1") then
		content = content:gsub("Loop|0","Loop|1")
		stopHarvest = false
        stopPlant = false
		RunThread(function ()
			while true do
				place(plantId)
				Sleep(500)
				SendPacket(2,"action|dialog_return\ndialog_name|cheats\ncheck_gems|1\ncheck_autoplace|1")
				Sleep(500)
				ChangeValue("[C] Modfly", true)
				for y = startY, 0, -1 do
					for x = 0, endX,1 do
						if GetTile(x,y).fg == 0 and GetTile(x,y+1).fg ~= 0 and GetTile(x,y+1).fg ~= harvestId then
							FindPath(x,y,delayPlant)
							Sleep(delayPlant)
							place(plantId)
							Sleep(delayPlant)
							FindPath(x+farPlant,y,delayPlant)
							Sleep(delayPlant)
						end
						if stopPlant == true then
							isPlantRunning = false
							break
						end
					end
					if stopPlant == true then
						isPlantRunning = false
						break
					end
				end
				isPlantRunning = false
				Sleep(1000)
				SendPacket(2,"action|dialog_return\ndialog_name|ultraworldspray")
				Sleep(2000)
				SendPacket(2,"action|dialog_return\ndialog_name|cheats\ncheck_gems|1\ncheck_autoplace|0")
				ChangeValue("[C] Modfly", true)
				Sleep(1000)
				for y = startY, 0, -1 do
					for x = 0, endX,1 do
						if GetTile(x,y).fg == harvestId and IsReady(GetTile(x,y)) == true then
							FindPath(x,y,delayHarvest)
							Hold()
							Sleep(delayHarvest)
							place(18)
							Sleep(delayHarvest)
						end
						if stopHarvest == true then
							isHarvestRunning = false
							break
						end
					end
					if stopHarvest == true then
						isHarvestRunning = false
						break
					end
				end
				isHarvestRunning = false
			end
		end)
	elseif packet:find("planting|1") then
		content = content:gsub("Plants|0","Plants|1")
		stopHarvest = true
        stopPlant = false
		if isPlantRunning then
			insert()
		else
		RunThread(function ()
			place(plantId)
			Sleep(500)
			SendPacket(2,"action|dialog_return\ndialog_name|cheats\ncheck_gems|1\ncheck_autoplace|1")
			Sleep(500)
			notif("Starting Plant...")
			ChangeValue("[C] Modfly", true)
			for y = startY, 0, -1 do
				for x = 0, endX,1 do
					if GetTile(x,y).fg == 0 and GetTile(x,y+1).fg ~= 0 and GetTile(x,y+1).fg ~= harvestId then
						FindPath(x,y,delayPlant)
						Sleep(delayPlant)
						place(plantId)
						Sleep(delayPlant)
						FindPath(x+farPlant,y,delayPlant)
						Sleep(delayPlant)
					end
					if stopPlant == true then
						isPlantRunning = false
						break
					end
				end
				if stopPlant == true then
					isPlantRunning = false
					break
				end
			end
			isPlantRunning = false
        end)
		end
	elseif packet:find("harvesting|1") then
		content = content:gsub("Harvests|0","Harvests|1")
        stopHarvest = false
		stopPlant = true
		if isHarvestRunning then
			insert()
		else
		RunThread(function ()
			notif("Starting Harvest...")
			SendPacket(2,"action|dialog_return\ndialog_name|cheats\ncheck_gems|1\ncheck_autoplace|0")
			ChangeValue("[C] Modfly", true)
			Sleep(1000)
			for y = startY, 0, -1 do
				for x = 0, endX,1 do
					if GetTile(x,y).fg == harvestId and IsReady(GetTile(x,y)) == true then
						FindPath(x,y,delayHarvest)
						Hold()
						Sleep(delayHarvest)
						place(18)
						Sleep(delayHarvest)
					end
					if stopHarvest == true then
						isHarvestRunning = false
						break
					end
				end
				if stopHarvest == true then
					isHarvestRunning = false
					break
				end
			end
			isHarvestRunning = false
        end)
		end
	elseif packet:find("planting|0\nharvesting|0") then
		content = content:gsub("Plants|1","Plants|0") or content:gsub("Harvests|1","Harvests|0")
		stopHarvest = true
		stopPlant = true
		end
	if packet:find("buttonClicked|modfly") then
			ChangeValue("[C] Modfly", false)
	end
end
end
AddHook("onsendpacket","hook",dialog)
