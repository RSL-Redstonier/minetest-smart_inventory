local filter = {}
filter.registered_filter = {}

function filter.get(name)
	return filter.registered_filter[name]
end

function filter.register_filter(def)
	assert(def.name, "filter needs a name")
	assert(def.filter_func, "filter function required")
	assert(not filter.registered_filter[def.name], "filter already exists")

	local self = def

	function self:check_item_by_name(itemname)
		if minetest.registered_items[itemname] then
			return self.filter_func(minetest.registered_items[itemname])
		end
	end
	function self:check_item_by_def(def)
		return self.filter_func(def)
	end
	function self:get_group_description(group)
		local rela_group = group:sub(string.len(self.name)+2)
		local descr
		if self.shortdesc_func then
			descr = self.shortdesc_func(rela_group)
		end
		if descr then
			return descr
		elseif self.shortdesc then
			return self.shortdesc
		else
			return group
		end
	end

	filter.registered_filter[self.name] = self
end

--[[	level = { shortdesc = "Uses level information" },
	dig_immediate = { shortdesc = "Fast removable" },
	disable_jump = { shortdesc = "Not jumpable" },
	less_damage  = { shortdesc = "Less damage" },
	more_damage  = { shortdesc = "More damage" },
	bouncy = { shortdesc = "Bouncy" },
	falling_node = { shortdesc = "Falling" },
	attached_node = { shortdesc = "Attachable" },
	connect_to_raillike = { shortdesc = "Rail-like" },
	-- TODO: http://dev.minetest.net/Groups/Custom_groups

	armor_use = { shortdesc = "Armor" },
	armor_heal = { shortdesc = "Armor" },
	cracky = { shortdesc = "Cracky" },
	flammable = { shortdesc = "Flammable" },
	snappy = { shortdesc = "Snappy" },
	choppy = { shortdesc = "Choppy" },
	oddly_breakable_by_hand = { shortdesc = "Oddly breakable" },

	tool = { shortdesc = "Tools" },
	type_node = { shortdesc = "Nodes" },
	type_craft = { shortdesc = "Craft Items" },
]]

filter.register_filter({
		name = "group",
		filter_func = function(def)
			return def.groups
		end,
		shortdesc_func = function(group)
			-- hide the top group because of meaningless
			if group == "" then
				return ""
			end
		end
	})

filter.register_filter({
		name = "type",
		filter_func = function(def)
			return def.type
		end,
		shortdesc_func = function(group)
			-- hide the top group because of meaningless
			if group == "" then
				return ""
			end
		end
	})

filter.register_filter({
		name = "mod",
		filter_func = function(def)
			return def.mod_origin
		end,
		shortdesc_func = function(group)
			-- hide the top group because of meaningless
			if group == "" then
				return ""
			end
		end
	})

filter.register_filter({
		name = "transluc",
		shortdesc = "Translucent blocks",
		filter_func = function(def)
			return def.sunlight_propagates
		end
	})

filter.register_filter({
		name = "vessel",
		shortdesc = "Vessel",
		filter_func = function(def)
			if def.allow_metadata_inventory_move or
					def.allow_metadata_inventory_take or
					def.on_metadata_inventory_put then
				return true
			end
		end
	})

filter.register_filter({
		name = "drawtype",
		filter_func = function(def)
			if not def.drawtype then
				return "normal"
			else
				return def.drawtype
			end
		end,
		shortdesc_func = function(group)
			-- hide the top group because of meaningless
			if group == "group" then
				return ""
			end
		end
	})

filter.register_filter({
		name = "material",
		filter_func = function(def)
			return def.base_material
		end
	})

filter.register_filter({
		name = "shape",
		filter_func = function(def)
			return def.shape_type
		end
	})

filter.register_filter({
		name = "eatable",
		filter_func = function(def)
			if def.on_use then
				local name,change=debug.getupvalue(def.on_use, 1)
				if name~=nil and name=="hp_change" and change > 0 then
					return tostring(change)
				end
			end
		end
	})

filter.register_filter({
		name = "toxic",
		filter_func = function(def)
			if def.on_use then
				local name,change=debug.getupvalue(def.on_use, 1)
				if name~=nil and name=="hp_change" and change < 0 then
					return tostring(change)
				end
			end
		end
	})

filter.register_filter({
		name = "tool",
		filter_func = function(def)
			if not def.tool_capabilities then
				return
			end
			local rettab = {}
			for k, v in pairs(def.tool_capabilities) do
				if type(v) ~= "table" then
					rettab[k] = v
				end
			end
			if def.tool_capabilities.damage_groups then
				for k, v in pairs(def.tool_capabilities.damage_groups) do
					rettab["damage:"..k] = v
				end
			end
			if def.tool_capabilities.groupcaps then
				for groupcap, gdef in pairs(def.tool_capabilities.groupcaps) do
					for k, v in pairs(gdef) do
						if type(v) ~= "table" then
							rettab["capability:"..groupcap..":"..k] = v
						end
					end
				end
			end
			return rettab
		end
	})

----------------
return filter

