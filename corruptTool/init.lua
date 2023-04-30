local exports = {
	name = "corruptTool",
	version = "0.1",
	description = "Breaking systems for fun",
	license = "BSD-3-Clause",
	author = {name = "ligarius20fps"}}

local corruptTool = exports

function corruptTool.startplugin()
	emu.register_start(function()
		--memory_spaces = {}
		print("(:device):space")
		for device, v1 in pairs(manager.machine.devices)
		do
			cpu = manager.machine.devices[device]
			for space, v2 in pairs(cpu.spaces)
			do
				mem=cpu.spaces[space]
				size = mem.address_mask
				emu.print_verbose(string.format("%s – size:%s", v2, size))
				--table.insert(memory_spaces, space)
			end
		end
		emu.print_verbose("It works!")
	end)
end

return exports
