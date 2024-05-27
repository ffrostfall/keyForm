local DARKLUA_PARAMS = { "process", "--config", ".darklua.json", "src/", "build/" }
local ROJO_BUILD_SOURCEMAP_PARAMS =
	{ "sourcemap", "raw.project.json", "-o", "buildsourcemap.json", "--include-non-scripts" }
local ROJO_DEV_SOURCEMAP_PARAMS = { "sourcemap", "dev.project.json", "-o", "sourcemap.json", "--include-non-scripts" }
local ROJO_DEVBUILD_SERVE_PARAMS = { "serve", "dev.project.json" }
local SPAWN_PROCESS_OPTIONS = {
	--luaufix
	stdio = "forward" :: "forward",
}

local chalk = require("@lunePackages/chalk")
local process = require("@lune/process")
local task = require("@lune/task")

local style = {
	rosePink = chalk.rgb(255, 120, 120),
	pastelBlue = chalk.rgb(180, 180, 255),

	bold = chalk.bold,
}

local function spawnProcess(name: string, parameters: { string }, watch: boolean)
	if watch then
		table.insert(parameters, "--watch")
	end

	process.spawn(name, parameters, SPAWN_PROCESS_OPTIONS)
end

task.spawn(function()
	print(style.pastelBlue("[lune] ") .. style.rosePink(style.bold("Starting keyForm dev")))
	print(style.pastelBlue("================================================================"))

	spawnProcess("rojo", ROJO_DEV_SOURCEMAP_PARAMS, false)
	spawnProcess("darklua", DARKLUA_PARAMS, false)

	task.spawn(spawnProcess, "darklua", DARKLUA_PARAMS, true)
	task.spawn(spawnProcess, "rojo", ROJO_BUILD_SOURCEMAP_PARAMS, true)
	task.spawn(spawnProcess, "rojo", ROJO_DEVBUILD_SERVE_PARAMS, false)
end)
