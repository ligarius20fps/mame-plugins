local exports = {
	name = "quantumGameplay",
	version = "1.5",
	description = "Disrupting your gameplay with intermittent state saving/loading",
	licence = "BSD-3-Clause",
	author = {name = "ligarius20fps"}}

local quantumGameplay = exports

function quantumGameplay.startplugin()
	--feel free to edit varables below ↓
	local number_of_timelines = 5
	local seconds = 10 -- how long should we stay on a timeline before loading another one
	local load_delay = emu.attotime.from_msec(100) -- delay to prevent cancelling pending save state, read: https://docs.mamedev.org/techspecs/luareference.html#id6
	--feel free to edit varables above ↑
	local load_from_origin = true
	local curr_timeline = 1
	local running = false
	local save_moment = emu.attotime(seconds,0)
	local load_moment = save_moment + load_delay
	local about_to_load = false
	local next_state = 0
	
	local function save(name)
		manager.machine:save("q" .. name)
		emu.print_verbose("Saved q".. name)
	end
	local function load(name)
		manager.machine:load("q" .. name)
		emu.print_verbose("Loaded q".. name)
		-- manager.machine:popmessage()
		-- manager.machine:popmessage("Loaded timeline #" .. name)
	end
	local function init()
		load_from_origin = true
		curr_timeline = 1
		running = true
		save_moment = manager.machine.time + emu.attotime(seconds,0)
		load_moment = save_moment + load_delay
		about_to_load = false
		next_state = 0
		save(next_state)
	end
	-- setting up menu ↓
	local function populate()
		return {{ "Press select here to set a new timeline origin" }}
	end
	local function callback(i, e)
		if i == 1 and e == "select" then
			emu.print_verbose("less goo")
			init()
		end
	end
	emu.register_menu(callback, populate, "Quantum Gameplay – set a new origin")
	-- setting up menu ↑
	emu.register_periodic(function()
		if running then
			now = manager.machine.time
			if about_to_load and now > load_moment then
				load(next_state)
				about_to_load = false
				load_moment = save_moment + load_delay
				return
			end
			if not about_to_load and now > save_moment then
				save(curr_timeline)
				curr_timeline = curr_timeline + 1
				if curr_timeline > number_of_timelines then
					emu.print_verbose("back to the first timeline")
					load_from_origin = false
					load_moment = save_moment + load_delay
					save_moment = now + emu.attotime(seconds,0)
					curr_timeline = 1
				end
				next_state = curr_timeline
				if load_from_origin then
					emu.print_verbose("loading from origin")
					next_state = 0
				end
				about_to_load = true
			end
		end
	end)
end

return exports
