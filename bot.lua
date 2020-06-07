local bot = {}
bot.discordia = require("discordia")
local client = bot.discordia.Client()
local logger = require("./logger")
local dictionary = require("./dictionary")
local utility = require("./utility")

client:on("ready", function()
	client:setGame("v1.0.0 | by carrot#1664")
end)

client:on("messageCreate", function(message)
	if message.author.id == client.user.id then
		return
	end
	logger.log("markov", message.content, message.author.fullname)
	if message.author.id == client.id then
		return
	end
	for i, blacklist in ipairs(_G.larkov.ignoredUsers) do
		if blacklist == message.author.fullname or blacklist == message.author.id then
			return
		end
	end

	if not _G.larkov.speaking then
		return
	end
	
	if _G.larkov.learning then
		dictionary.learn(message.content)
	end
	
	if #_G.larkov.aliases >= 1 then
		local done = false
		for i, alias in ipairs(_G.larkov.aliases) do
			if done == false then
				if message.content:find(alias) then
					done = true
				end
				if i >= #_G.larkov.aliases then
					return
				end
			end
		end
	end
	
	local willReply = bot.getWillReply(message.content)
	if willReply then
		bot.reply(message)
	end
	
end)

function bot.getWillReply(message)
	local chance = math.floor(math.random() * 100) + 1
	local willReply = chance <= _G.larkov.replyRate
	
	return willReply
end

function bot.reply(message)
	math.randomseed(os.time())
	
	local message_ = message.content:lower()
	local words = utility.splitWords(message_)
	local knownWords = dictionary.getKnownWords(words)
	local buildAroundWord = knownWords[math.random(#knownWords)]
	
	if not _G.larkov.pingUsers then
		for i, word in ipairs(words) do
			if utility.isDiscordMention(word) then
				table.remove(words, i)
			end
		end
	end
	
	if #knownWords == 0 then
		return
	end

	local finalSentence = dictionary.buildAround(buildAroundWord)

	if finalSentence == "  " then
		return
	end 
	message.channel:send(finalSentence)
end
	
function bot.run()
	client:run("Bot ".. _G.larkov.token)
end

return bot