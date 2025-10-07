local level_var = {
    identifier = "l46",
    title = "Floor 46",
    theme = THEME.TIDE_POOL,
    world = 1,
	level = 46,
	width = 4,
    height = 2,
    file_name = "l46.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

level_var.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true
	
	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.SYSTEMIC, 0, ENT_TYPE.ITEM_PICKUP_SKELETON_KEY)
	
	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_SKELETON)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.ANY, 0, ENT_TYPE.ITEM_SKULL)
	
	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.ANY, 0, ENT_TYPE.ITEM_BONES)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_GENERIC)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOORSTYLED_PAGODA)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_THORN_VINE)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_CONVEYORBELT_LEFT)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_CONVEYORBELT_RIGHT)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:give_powerup(ENT_TYPE.ITEM_POWERUP_SPIKE_SHOES)
		entity:set_cursed(true, false)
		entity.flags = clr_flag(entity.flags, ENT_FLAG.FACING_LEFT)
	end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_OCTOPUS)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
        -- Remove Hermitcrabs
        local x, y, layer = get_position(entity.uid)
        local floor = get_entities_at(0, MASK.ANY, x, y, layer, 1)
        if #floor > 0 then
            entity.flags = set_flag(entity.flags, ENT_FLAG.INVISIBLE)
            entity:destroy()
        end
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_HERMITCRAB)

	--Sliding Wall Switch
	local wall_switch
	define_tile_code("wall_switch")
	set_pre_tile_code_callback(function(x, y, layer)
		local block_id = spawn(ENT_TYPE.ITEM_SLIDINGWALL_SWITCH, x, y, layer, 0, 0)
		wall_switch = get_entity(block_id)
	end, "wall_switch")
	
	local frames = 0
	local wall_switch_off = true
	local slidingwall = {}
	local arrows = {}
	level_state.callbacks[#level_state.callbacks+1] = set_callback(function ()
		if frames == 0 then
			state.kali_favor = 16
			local uids = get_entities_by(ENT_TYPE.FLOOR_SLIDINGWALL_CEILING, MASK.ANY, 0)
			for i = 1,#uids do
				slidingwall[#slidingwall + 1] = get_entity(uids[i])
			end
			uids = get_entities_by(ENT_TYPE.ITEM_METAL_ARROW, MASK.ANY, 0)
			for i = 1,#uids do
				arrows[#arrows + 1] = get_entity(uids[i])
			end
			for i = 1,#arrows do
				arrows[i]:destroy()
			end
		end
		
		if wall_switch.timer == 90 and wall_switch_off == true then
			for i = 1,#slidingwall do
				slidingwall[i].state = 1
			end
			wall_switch_off = false
		elseif wall_switch.timer == 90 and wall_switch_off == false then
			for i = 1,#slidingwall do
				slidingwall[i].state = 0
			end
			wall_switch_off = true
		end
		
		frames = frames + 1		
    end, ON.FRAME)

	toast(level_var.title)
	
end

level_var.unload_level = function()
    if not level_state.loaded then return end

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _, callback in pairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return level_var
