-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, math
    = minetest, nodecore, math
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()

local function luxlamp (desc, id, power, light)
local delum	= power-1
local flux	= power+1
local charge	= power*100
local vlux	= power*60
local time	= 1000/power

local particle = "nc_lux_base.png^[mask:nc_lux_dot_mask.png^[opacity:32"

minetest.register_node(modname .. ":luxlamp_" .. id, {
	description = desc.. " Luxlamp",
	tiles = {"nc_optics_glass_frost.png^(nc_lux_base.png^[opacity:" .. vlux .. ")^(nc_lode_tempered.png^[mask:" .. modname .. "_mask_lamp.png)"},
	drawtype = "nodebox",
	paramtype = "light",
	light_source = light,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.3125, -0.3125, -0.3125, 0.3125, 0.3125, 0.3125}, -- Core
			{-0.5, -0.125, -0.125, 0.5, 0.125, 0.125}, -- Pole_X
			{-0.125, -0.125, -0.5, 0.125, 0.125, 0.5}, -- Pole_Z
			{-0.125, -0.5, -0.125, 0.125, 0.5, 0.125}, -- Pole_Y
		}
	},
	sunlight_propagates = true,
	groups = {
		stack_as_node = 1,
		cracky = 1,
		luxlamp = 1
		},
		stack_max = 1,
		sounds = nodecore.sounds("nc_optics_glassy"),
})

---------------------------------------
-----------Luxlamp Crafting------------
nodecore.register_craft({
		label = "assemble luxlamp",
		nodes = {
			{match = "nc_optics:glass_opaque", replace = modname .. ":luxlamp_0"},
			{x = -1, z = -1, match = "nc_lode:rod_tempered", replace = "air"},
			{x = 1, z = -1, match = "nc_lode:rod_tempered", replace = "air"},
			{x = -1, z = 1, match = "nc_lode:rod_tempered", replace = "air"},
			{x = 1, z = 1, match = "nc_lode:rod_tempered", replace = "air"},
			{y = -1, match = {groups = {lux_cobble = true}}},
		}
	})
	
---------------------------------------
-----------Luxlamp Recycling-----------
nodecore.register_craft({
		label = "break luxlamp apart",
		action = "pummel",
		toolgroups = {choppy = 5},
		nodes = {
			{
				match = {groups = {luxlamp = true}},
				replace = "nc_optics:glass_crude"
			}
		},
		items = {
			{name = "nc_lode:rod_tempered", count = 4, scatter = flux},
			{name = "nc_lux:flux_flowing", count = flux, scatter = flux}
		},
		itemscatter = flux
	})

---------------------------------------
----------Luxlamp Diminishing----------
nodecore.register_abm({
		label = "Luxlamp Delumination",
		interval = charge,
		chance = 1,
		nodenames = {modname .. ":luxlamp_" .. id},
		action = function(pos)
			if minetest.find_node_near(pos,
				1, {"nc_lux:flux_flowing"}) then
				return false
			end
			if power > 0 then
				return minetest.set_node(pos, {name = modname .. ":luxlamp_" .. delum})
			end
		end
	})
---------------------------------------
nodecore.register_aism({
		label = "Held Delumination",
		interval = charge,
		chance = 1,
		itemnames = {modname .. ":luxlamp_" .. id},
		action = function(stack, data)
			if power > 0 then
				stack:set_name(modname .. ":luxlamp_" .. delum)
				return stack
			end
		end
	})

---------------------------------------
-----------Luxlamp Charging------------
nodecore.register_abm({
		label = "Luxlamp Effulgence",
		nodenames = {"group:luxlamp"},
		neighbors = {"nc_lux:flux_source", "nc_lux:flux_flowing"},
		interval = time,
		chance = 1,
		action = function(pos)
				nodecore.set_node(pos, {name = modname .. ":luxlamp_5"})
		end
	})
	
--nodecore.register_abm({
--		label = "Luxlamp Charging",
--		nodenames = {"group:luxlamp"},
--		neighbors = {"nc_lux:flux_source", "nc_lux:flux_flowing"},
--		interval = 2,	--temporary, as a mysterious bug causes serious issue with this value
--		chance = 1,
--		action = function(pos)
--			if power > 4 then
--				nodecore.set_node(pos, {name = modname .. ":luxlamp_" .. flux})
--				elseif 4 then return false
--			end
--		end
--	})
	
---------------------------------------

---------------------------------------
end
luxlamp("Dull",		"0",	0,	1)
luxlamp("Dim",			"1",	1,	4)
luxlamp("Lambent",		"2",	2,	8)
luxlamp("Radiant",		"3",	3,	12)
luxlamp("Brilliant",	"4",	4,	16)
luxlamp("Fulgent",		"5", 5,	20)
