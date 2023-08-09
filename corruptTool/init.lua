local exports = {
	name = "corruptTool",
	version = "0.3",
	description = "Breaking systems for fun",
	license = "BSD-3-Clause",
	author = {name = "ligarius20fps"}}

local corruptTool = exports

local memory_spaces = {}
local poke_period = emu.attotime.from_msec(661)
local poke_moment = poke_period
local number_of_pokes = 17

local function my_init()
	if loaded then return end
	for device, v1 in pairs(manager.machine.devices)
	do
		local cpu = manager.machine.devices[device]
		for space, v2 in pairs(cpu.spaces)
		do
			--mem = manager.machine.devices[":maincpu"].spaces["program"]
			local mem=cpu.spaces[space]
			local size = mem.address_mask
			memory_spaces[#memory_spaces + 1] = mem
			
			loaded = true
		end
	end
	if loaded
	then
		print("found memory spaces:")
		for k, v in pairs(memory_spaces)
		do
			print("tab["..tostring(k).."] = "..tostring(v))
		end
	end
end

local function continuous()
	num_of_mem_regions = #memory_spaces
	if num_of_mem_regions > 0
	then
		local now = manager.machine.time
		if poke_moment and now > poke_moment
		then
		--poke
			for i=1, number_of_pokes
			do
				local index = math.random(1,num_of_mem_regions)
				local mem = memory_spaces[index]
				local size = mem.address_mask
				local position = math.random(0,size)
				local value = math.random(0,255)
				mem:write_u8(position, value)
				emu.print_verbose("Poked "..value.."@"..position.." in "..tostring(mem))
			end
			poke_moment = now + poke_period
		end
	end
end

function corruptTool.startplugin()
	local memory_spaces = {}
	-- setting up menu ↓

	local function populate()
		menu = {}
		menu[#menu + 1] = {"test1",{"test2","test4","test5"},"on"}
		return menu
	end
	local function callback(i, e)
		emu.print_verbose("(dummy) index: " .. i .. " event: " .. e)
		return false
	end
	emu.register_menu(callback, populate, "Corrupt Tool")
	
	-- setting up menu ↑
	emu.add_machine_frame_notifier(my_init)
	emu.register_periodic(continuous)
end

return exports
