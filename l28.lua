local level_var = {
    identifier = "l28",
    title = "Floor 28",
    theme = THEME.SUNKEN_CITY,
    world = 1,
	level = 28,
	width = 3,
    height = 3,
    file_name = "l28.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

level_var.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true
	
	replace_drop(DROP.EGGSAC_GRUB_1, ENT_TYPE.ITEM_BLOOD)
	replace_drop(DROP.EGGSAC_GRUB_2, ENT_TYPE.ITEM_BLOOD)
	replace_drop(DROP.EGGSAC_GRUB_3, ENT_TYPE.ITEM_BLOOD)
	
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
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOORSTYLED_SUNKEN)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_THORN_VINE)
	
	local frames = 0
	level_state.callbacks[#level_state.callbacks+1] = set_callback(function ()
        if frames == 0 then
			pick_up(players[1].uid, spawn(ENT_TYPE.ITEM_JETPACK, 0, 0, LAYER.PLAYER, 0, 0))
		end
		frames = frames + 1
    end, ON.FRAME)
	
	toast(level_var.title)
	
end

level_var.unload_level = function()
    if not level_state.loaded then return end

	replace_drop(DROP.EGGSAC_GRUB_1, ENT_TYPE.MONS_GRUB)
	replace_drop(DROP.EGGSAC_GRUB_2, ENT_TYPE.MONS_GRUB)
	replace_drop(DROP.EGGSAC_GRUB_3, ENT_TYPE.MONS_GRUB)
	
    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _, callback in pairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return level_var
