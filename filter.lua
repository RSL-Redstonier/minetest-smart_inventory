local filter = {}
filter.registered_filter = {}

--- API
function filter.get(name)
	return filter.registered_filter[name]
end

function filter.register_filter(def)
	assert(def.name, "filter needs a name")
	assert(def.shortdesc, "filter needs a shortdesc that is used as for users readable name")
	assert(def.filter_func, "filter function required")
	assert(not filter.registered_filter[def.name], "filter already exists")

	local self = def
	function self:check_item_by_name(itemname)
		return self.filter_func(minetest.registered_items[itemname], itemname)
	end
	function self:check_item_by_def(def)
		if not def then
			return false
		else
			return self.filter_func(def, def.name)
		end
	end
	filter.registered_filter[self.name] = self
end

filter.register_filter({
		name = "transluc", 
		shortdesc = "Translucent blocks",
		filter_func = function(def, name)
			if def.sunlight_propagates == true then
				return true
			else
				return false
			end
		end
	})

filter.register_filter({
		name = "vessel", 
		shortdesc = "Vessel",
		filter_func = function(def, name)
			if def.allow_metadata_inventory_move or
					def.allow_metadata_inventory_take or
					def.on_metadata_inventory_put then
				return true
			else
				return false
			end
		end
	})

---TODO: irgend wo einbauen!
function filter.is_revealed_item(itemname, playername)
	local cache = smart_inventory.cache
	if smart_inventory.doc_items_mod then
		local category_id
		if not cache.items[itemname] then
			-- not in creative or something like
			return false
		else
			for _, group in pairs(cache.items[itemname].groups) do
				if group.name == "type_node" then
					category_id = "nodes"
				elseif group.name == "type_tool" then
					category_id = "tools"
				elseif group.name == "type_craft" then
					category_id = "craftitems"
				end
			end
			if category_id then
				return doc.entry_revealed(playername, category_id, itemname)
			end
			return true --should not be happen. But take it visible if the item is not a node or tool or item
		end
	end
	return true
end
	----------------
return filter
