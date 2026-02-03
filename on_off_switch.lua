local sound = require('play_sound')

local switch_state = true -- true is ON, false is OFF
local switch_cooldown = 0 -- frames
local switch_entities = {}
local block_entities = {}
local allowed_triggers = {
	ENT_TYPE.ITEM_ROCK,
	ENT_TYPE.ITEM_POT,
	ENT_TYPE.ITEM_EGGPLANT
}

local function create_custom_texture(filename)
	local tex_def = TextureDefinition.new()
	tex_def.texture_path = f'Data/Textures/{filename}'
	tex_def.width = 128
	tex_def.height = 128
	tex_def.tile_width = 128
	tex_def.tile_height = 128
	return define_texture(tex_def)
end

local tex_switch_on = create_custom_texture("switch_ON.png")
local tex_switch_off = create_custom_texture("switch_OFF.png")
local tex_on_block = create_custom_texture("ON_block.png")
local tex_off_block = create_custom_texture("OFF_block.png")

set_callback(function()
	if switch_cooldown > 0 then
		switch_cooldown = switch_cooldown - 1
	end
	
	for _, uid in ipairs(switch_entities) do
		local ent = get_entity(uid)
		if ent ~= nil then
			ent.more_flags = set_flag(ent.more_flags, ENT_MORE_FLAG.DISABLE_INPUT)
		end
	end
	
	for _, uid in ipairs(block_entities) do
		local ent = get_entity(uid)
		if ent ~= nil then
			ent.more_flags = set_flag(ent.more_flags, ENT_MORE_FLAG.DISABLE_INPUT)
		end
	end
end, ON.FRAME)

local function toggle_switches()
	switch_state = not switch_state
	switch_cooldown = 30

	sound.play_sound(VANILLA_SOUND.TRAPS_SWITCH_FLICK)

	-- Update all switches in the level
	for i = #switch_entities, 1, -1 do -- Loop backwards in case a switch is destroyed
		local uid = switch_entities[i]
		local ent = get_entity(uid)

		if ent ~= nil then
			if switch_state then
				ent:set_texture(tex_switch_on)
			else
				ent:set_texture(tex_switch_off)
			end
		else
			table.remove(switch_entities, i)
		end
	end

	-- Update all on/off blocks in the level
	for i = #block_entities, 1, -1 do -- Loop backwards in case a block is destroyed
		local uid = block_entities[i]
		local ent = get_entity(uid)

		if ent ~= nil then
			local matches_state = (ent.user_data.is_on_block == switch_state)

			if matches_state then -- Solid
				ent.hitboxx = 0.5
				ent.hitboxy = 0.5
				ent.flags = set_flag(ent.flags, ENT_FLAG.SOLID)
				ent.flags = clr_flag(ent.flags, ENT_FLAG.PASSES_THROUGH_EVERYTHING)
				ent.flags = clr_flag(ent.flags, ENT_FLAG.PAUSE_AI_AND_PHYSICS)
				ent.flags = set_flag(ent.flags, ENT_FLAG.INTERACT_WITH_WATER)
				ent.color.a = 1.0
				add_entity_to_liquid_collision(uid, true)
			else -- Not Solid
				ent.hitboxx = 0.0
				ent.hitboxy = 0.0
				ent.flags = clr_flag(ent.flags, ENT_FLAG.SOLID)
				ent.flags = set_flag(ent.flags, ENT_FLAG.PASSES_THROUGH_EVERYTHING)
				ent.flags = set_flag(ent.flags, ENT_FLAG.PAUSE_AI_AND_PHYSICS)
				ent.flags = clr_flag(ent.flags, ENT_FLAG.INTERACT_WITH_WATER)
				ent.color.a = 0.35
				add_entity_to_liquid_collision(uid, false)
			end
		else
			table.remove(block_entities, i)
		end
	end
end

define_tile_code("on_off_switch")
set_pre_tile_code_callback(function(x, y, layer)
	local uid = spawn_entity(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, layer, 0, 0)
	local ent = get_entity(uid)

	ent.type.collision2_mask = set_flag(ent.type.collision2_mask, MASK.ITEM)
	ent.flags = set_flag(ent.flags, ENT_FLAG.NO_GRAVITY)
	ent.more_flags = set_flag(ent.more_flags, ENT_MORE_FLAG.DISABLE_INPUT)
	ent:set_texture(tex_switch_on) -- Set ON texture initially
	table.insert(switch_entities, uid)

	local trigger = get_entity(spawn_over(ENT_TYPE.LOGICAL_TENTACLE_TRIGGER, uid, 0, 0)) -- Detects player (and hired hand)
    trigger.x = 0
    trigger.y = -0.6
    trigger.hitboxx = 0.40
    trigger.hitboxy = 0.05
    trigger.offsetx = 0
    trigger.offsety = 0
	ent.user_data = { bonk_detector_uid = trigger.uid }
	set_pre_collision2(trigger.uid, function(ent, collider) -- For bonking the underside of the switch
		if switch_cooldown > 0 then
			return false
		end
        if collider.velocityy >= 0 then
			toggle_switches()
        end
		
		return true
	end)

	ent:set_pre_damage(function() -- Whipping triggers this
		if switch_cooldown > 0 then
			return false
		end
		toggle_switches()
	end)

	ent:set_pre_kill(function() -- Change switch states if switch is destroyed
		get_entity(ent.user_data.bonk_detector_uid):destroy()
		if switch_cooldown > 0 then
			return false
		end
		toggle_switches()
	end)

	return true
end, "on_off_switch")

define_tile_code("block_on")
set_pre_tile_code_callback(function(x, y, layer)
	local uid = spawn_entity(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, layer, 0, 0)
	local ent = get_entity(uid)
	
	-- Custom data to determine the type of ON/OFF block
	ent.user_data = { is_on_block = true }
	
	-- Initial appearance and properties
	ent:set_texture(tex_on_block)
	ent.flags = set_flag(ent.flags, ENT_FLAG.NO_GRAVITY)
	ent.flags = clr_flag(ent.flags, ENT_FLAG.PAUSE_AI_AND_PHYSICS)
	ent.more_flags = set_flag(ent.more_flags, ENT_MORE_FLAG.DISABLE_INPUT)
	
	table.insert(block_entities, uid)
	return true
end, "block_on")

define_tile_code("block_off")
set_pre_tile_code_callback(function(x, y, layer)
	local uid = spawn_entity(ENT_TYPE.ACTIVEFLOOR_PUSHBLOCK, x, y, layer, 0, 0)
	local ent = get_entity(uid)

	-- Custom data to determine the type of ON/OFF block
	ent.user_data = { is_on_block = false }
	
	-- Initial appearance and properties
	ent:set_texture(tex_off_block)
	ent.hitboxx = 0.0
	ent.hitboxy = 0.0
	ent.color.a = 0.35
	ent.flags = set_flag(ent.flags, ENT_FLAG.NO_GRAVITY)
	ent.flags = set_flag(ent.flags, ENT_FLAG.PAUSE_AI_AND_PHYSICS)
	ent.more_flags = set_flag(ent.more_flags, ENT_MORE_FLAG.DISABLE_INPUT)
	ent.flags = clr_flag(ent.flags, ENT_FLAG.SOLID)
	add_entity_to_liquid_collision(uid, false)

	table.insert(block_entities, uid)
	return true
end, "block_off")

-- Reset state and entity groups
set_callback(function()
	switch_entities = {}
	block_entities = {}
	switch_state = true
	switch_cooldown = 0
end, ON.POST_ROOM_GENERATION)