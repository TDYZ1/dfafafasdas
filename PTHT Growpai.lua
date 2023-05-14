--↶default settings↷
--can be change in game
plantId = 5640
harvestId = 13593
startY = 193
endX = 199
delayPlant = 150
delayHarvest = 150
farPlant = 8
command = "/config"

local stopPlant = false
local stopHarvest = false
local isPlantRunning = false
local isHarvestRunning = false

function place(id)
	pkt = {}
	pkt.type = 3
	pkt.int_data = id
	pkt.pos_x = GetLocal().pos_x
	pkt.pos_y = GetLocal().pos_y
	pkt.int_x = math.floor(GetLocal().pos_x // 32)
	pkt.int_y = math.floor(GetLocal().pos_y // 32)
	SendPacketRaw(pkt)
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
		var.netid = -1
		SendVarlist(var)
end

function cek(plant)
	for y = startY, 0 do
		for x = 0, endX do
			if plant then
				if GetTile(x,y).fg == 0 then
					FindPath(x,y,100)
					Sleep(delayPlant)
					place(plantId)
					Sleep(delayPlant)
					FindPath(x + farPlant,y)
					Sleep(delayPlant)
				end
			else
				if GetTile(x,y).fg == harvestId then
					FindPath(x,y,100)
					Hold()
					Sleep(delayHarvest)
					place(18)
				end
			end

		end
	end

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
add_small_font_button|modfly|Turn Off ModFly|noflags|0|0|
end_dialog|ptht|Cancel|Ok
		]]

notif("Script Terminated [PTHT]\n    `2Credit : `1Rtnt-#7940")

function dialog(types, packet)
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
	    var.netid = -1
	    SendVarlist(var)
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
add_small_font_button|modfly|Turn Off ModFly|noflags|0|0|
end_dialog|ptht|Cancel|Ok
		]]
	end
	if packet:find("planting|1\nharvesting|1") then
	content = content:gsub("Plants|1","Plants|0")
	content = content:gsub("Harvests|1","Harvests|0")
	stopHarvest = true
	stopPlant = true
	notif("Choose One Masbro")
	elseif packet:find("planting|1") then
		content = content:gsub("Plants|0","Plants|1")
		stopHarvest = true
        stopPlant = false
		if isPlantRunning then
			insert()
		else
		RunThread(function ()
			notif("Starting Plant...")
			EditToggle("ModFly", true)
				isPlantRunning = true
                for y = startY, 0, -1 do
                    for x = 0, endX,1 do
						if stopPlant then
							break
						else
							if GetTile(x,y).fg == 0 and GetTile(x,y + 1).fg ~= 0 then
								FindPath(x,y,100)
								Sleep(delayPlant)
								place(plantId)
								Sleep(delayPlant)
								FindPath(x + farPlant,y)
								Sleep(delayPlant)
							end
							if math.floor(GetLocal().pos_x // 32) == 0 and math.floor(GetLocal().pos_y // 32) == endX then
								cek(true)
							end
						end
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
			EditToggle("ModFly", true)
			isHarvestRunning = true
                for y = startY, 0, -1 do
                    for x = 0, endX,1 do
						if stopHarvest then
							break
						else
							if GetTile(x,y).fg == harvestId and GetTile(x,y).ready then
								FindPath(x,y,100)
								Hold()
								Sleep(200)
								place(18)
								Sleep(delayHarvest)
							end
							if math.floor(GetLocal().pos_x // 32) == 0 and math.floor(GetLocal().pos_y // 32) == endX then
								cek(false)
							end
						end
                    end
                end
			isHarvestRunning = false	
        end)
		end
	elseif packet:find("planting|0\nharvesting|0") then
		stopHarvest = true
		stopPlant = true
		content = content:gsub("Plants|1","Plants|0") or content:gsub("Harvests|1","Harvests|0")
	end
	if packet:find("buttonClicked|modfly") then
		EditToggle("ModFly", false)
	end
end
end
AddCallback("Hook","OnPacket",dialog)