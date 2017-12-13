
if not swf then swf = { } end

script.on_event("synced-wagon-filters-open-gui", function(event)
	local player = game.players[event.player_index]
	local entity = player.selected
  
	if entity and entity.type == "cargo-wagon" and player.can_reach_entity(entity) then
		open_gui(entity, player)
	end
end)

script.on_event(defines.events.on_gui_click, function(event)
	local player = game.players[event.player_index]
	if event.element.name == "synced_wagon_close_button" then
		save_current_gui_group_name(player)
		close_gui(player)
	elseif event.element.name == "synced_wagon_broadcast_button" then
		save_current_gui_group_name(player)
		broadcast(player)
	end
end)

script.on_init(function()
	global.records = { } 
end)

function context(player)
	
	if not swf[player.index] then 
		swf[player.index] = { }
	end
	
	return swf[player.index]
end

function open_gui(entity, player)

	ctx = context(player)
	
	if ctx.gui then 
		close_gui(player, false)
	else 
	
		local gui = player.gui.center.add({ type = "frame",
											name = "synced_wagon_filters_gui",
											direction = "vertical" })
											
		gui.add({ type = "label", 
				  name = "title",
				  caption = "Wagon filters synchronization",
				  style = "description_title_label_style" })
				  
		local frame = gui.add({ type = "flow", name = "frame", direction = "horizontal" })
				  
		frame.add({ type = "label", 
				    name = "group_header",
				    caption = "Group name:" })
				  
		frame.add({ type = "textfield", 
				    name = "group_name_box",
				    text = get_group(entity) })
				  
		frame.add({ type = "button",
		            name = "synced_wagon_broadcast_button",
				    caption = "Broadcast" })
				  
		gui.add({ type = "button",
                  name = "synced_wagon_close_button",
				  caption = "Close" })
		
		ctx.gui = gui
		ctx.entity = entity
	end 
end

function save_current_gui_group_name(player)
	ctx = context(player)
	if ctx.gui then 
		set_group(player, ctx.entity, ctx.gui.frame.group_name_box.text)
	end
end

function close_gui(player)
	ctx = context(player)
	if ctx.gui then 
		ctx.gui.destroy()
		ctx.gui = nil
		ctx.entity = nil
	end
	player.gui.center.clear()
end

function get_record(entity)	
	for i, g in ipairs(global.records) do
		if g.entity == entity then
			return g
		end
	end 
	global.records[#global.records + 1] = { entity = entity, group = "" }
	return global.records[#global.records]
end

function get_group(entity)
	return get_record(entity).group
end

function set_group(player, entity, group)
	local record = get_record(entity)
	record.group = group
end

function get_wagons_by_group(group)
	local wagons = { }
	for i = #global.records,1,-1 do
		local rec = global.records[i]
		if rec.entity.valid then
			if rec.group == group then 
				wagons[#wagons + 1] = rec.entity
			end
		else
			table.remove(global.records, i)
		end
	end
	return wagons
end

function broadcast(player)
	ctx = context(player)
	if ctx.gui then
		local entity = ctx.entity
		local group = get_group(entity)
		if group ~= "" then
			player.print("Broadcast on group " .. group)
			local wagons = get_wagons_by_group(group)
			for i, wagon in ipairs(wagons) do
				player.print("copy_settings")
				if wagon ~= entity then
					wagon.copy_settings(entity)
				end
			end
		end
	end
end
