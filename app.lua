local fs = require("fs")

local manager = require("./manager")
local bot = require("./bot")
local logger = require("./logger")
local dictionary = require("./dictionary")

local configurationFile = "config.json"

if not pcall(function() assert(fs.readFileSync(configurationFile)) end) then
	logger.log("warning", "Configuration file ".. configurationFile .. " doesn't exist. Creating one for you...")
	local success, err = pcall(function()
		manager.make(configurationFile)
		logger.log("info", "Configuration file created! Please edit ".. configurationFile .." and then re-run Larkov.")
		return
	end)
	if not success then
		logger.log("error", "Failed to create a configuration file. Stopping execution...")
		return
	end
else
	logger.log("info", "Loading configuration from file ".. configurationFile .."...")
	manager.load(configurationFile)
	logger.log("info", "Starting Larkov 1.0.0...")
	dictionary.load()
	bot.run()
end