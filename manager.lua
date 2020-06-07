local manager = {}
local fs = require("fs")
local json = require("json")
local logger = require("./logger")

local properties = {
	token = "foobar",
	blacklistedWords = {},
	ignoredUsers = {},
	replyRate = 100,
	replyNick = 100, -- does nothing atm
	speaking = true,
	pingUsers = false,
	autoSavePeriod = 200,
	admins = {}, -- does nothing atm
	aliases = {} -- untested
}

function manager.make(file)
	assert(fs.writeFileSync(file, json.encode(properties, {indent = true})))
end

function manager.load(file)
	local data = json.decode(fs.readFileSync(file))
	-- Int check
	if not tonumber(data.replyRate) or not tonumber(data.autoSavePeriod) or not tonumber(data.replyNick) then
		logger.log("error", "One of the values supplied (replyRate, autoSavePeriod, replyNick) in ".. file .." is not an integer! Stopping execution...")
		return
	elseif token == "foobar" then -- Token checks
		logger.log("error", "You need to change the token in ".. file .."! Stopping execution...")
		return
	elseif token == "" then
		logger.log("error", "I need a token to run! Set one in ".. file ..". Stopping execution...")
		return
	end -- TODO: more checks
	_G.larkov = data
end

return manager