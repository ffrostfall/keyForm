local chalk = require("@lunePackages/chalk")
local process = require("@lune/process")
local task = require("@lune/task")

local PROCESS_SPAWN_OPTIONS = {
	stdio = "forward" :: "forward",
}

local function spawnProcess(name: string, parameters: { string })
	task.spawn(process.spawn, name, parameters, PROCESS_SPAWN_OPTIONS)
end

local function sourcemap(projectFile: string, sourcemapName: string)
	spawnProcess("rojo", { "sourcemap", projectFile, "--output", sourcemapName, "--watch" })
end

local function darklua()
	spawnProcess("darklua", { "process", "--config", ".darklua.json", "src/", "build/", "--watch" })
end

local function serve(projectFile: string)
	spawnProcess("rojo", { "serve", projectFile })
end

print(chalk.magentaBright("Starting dev server..."))
sourcemap("raw.project.json", "darklua_sourcemap.json")
sourcemap("dev.project.json", "sourcemap.json")
serve("dev.project.json")
darklua()
