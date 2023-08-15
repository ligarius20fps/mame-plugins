local exports = {
	name = "corruptTool",
	version = "0.4",
	description = "Breaking systems for fun",
	license = "BSD-3-Clause",
	author = {name = "ligarius20fps"}}

local corruptTool = exports

local memory_spaces = {}
local poke_period = emu.attotime.from_msec(100)
local poke_moment = poke_period
local number_of_pokes = 2
local running = true

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
	if running then
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
end

function corruptTool.startplugin()
	local memory_spaces = {}
	-- setting up menu ↓

	local function populate()
		return {{"Start"}, {"Stop"}}
	end
	local function callback(i, e)
		if i == 1 and e == "select"
		then
			my_init()
			running = true
			manager.machine:popmessage("Started")
		elseif i == 2 and e == "select"
		then
			running = false
			manager.machine:popmessage("Stopped")
		end
	end
	emu.register_menu(callback, populate, "Corrupt Tool")
	
	-- setting up menu ↑
	emu.add_machine_frame_notifier(my_init)
	emu.register_periodic(continuous)
end

return exports
