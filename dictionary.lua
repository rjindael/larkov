local dictionary = {}
local fs = require("fs")

local utility = require("./utility")
local logger = require("./logger")

local markovStrings = "markov.txt"

-- PS: `lines` in asrielborg are treated as `sentences`
-- Proceed with caution. I mean it.

function dictionary.load()
	logger.log("info", "Loading dictionary...")
	-- Create arrays
	_G.larkov.dictionary = {}
	_G.larkov.dictionary.words = {}
	_G.larkov.dictionary.sentences = {}
	_G.larkov.dictionary.toLearn = {}
	
	if pcall(function() assert(fs.readFileSync("lines.txt")) end) then
		logger.log("info", "It looks like you have a lines.txt! This will be renamed to `markov.txt`. Larkov execution will continue as normal.")
		fs.rename("lines.txt", "markov.txt")
	elseif not pcall(function() assert(fs.readFileSync(markovStrings)) end) then
		logger.log("warning", "No markov.txt was found. If this is a fresh install, ignore this message. A markov.txt will be made for you.")
		assert(fs.writeFileSync(markovStrings, "\n"))
	end
	-- Load markov string
	local strings = fs.readFileSync(markovStrings)
	
	-- Load words
	_G.larkov.dictionary.sentences = utility.splitSentences(strings)
	_G.larkov.dictionary.words = utility.splitWords(strings)
	logger.log("info", "Done loading dictionary! I know ".. #_G.larkov.dictionary.sentences .." sentences and ".. #_G.larkov.dictionary.words .." unique words.")
end

function dictionary.save()
	local data
	
	logger.log("info", "Saving dictionary...")
	for i, line in ipairs(_G.larkov.dictionary.sentences) do
		for sentence in string.gmatch(line, "\n") do
			data = data .. sentence .. "\n"
		end
	end
	assert(fs.writeFileSync(markovStrings, data))
	
	logger.log("info", "Saved dictionary!")
end

function dictionary.getKnownWords(words)
	local known = {}
	
	for i, word in ipairs(words) do
		if utility.inTable(_G.larkov.dictionary.words, word) then
			table.insert(known, word)
		end
	end
	
	return known
end

function dictionary.getAllSentencesContaining(word)
	local linesContainingWord = {}
	local word_ = utility.escapePattern(word)
	local pattern = "%f[%w_]".. word_ .. "%f[^%w_]"
	
	for i, sentence in ipairs(_G.larkov.dictionary.sentences) do
		if sentence:find(pattern) then
			table.insert(linesContainingWord, sentence)
		end
	end
	
	return linesContainingWord
end

function dictionary.getRandomSentenceContaining(word)
	local word_ = utility.escapePattern(word)
	local sentences = dictionary.getAllSentencesContaining(word_)
	
	if #sentences == 0 then
		return ""
	end
	
	return sentences[math.random(1, #sentences - 1)]
end

function dictionary.learn(strings)
	local sentences = utility.splitSentences(strings)
	local words = utility.splitSentences(strings)
	-- blacklist check
	for i, word in ipairs(words) do
		if #_G.larkov.blacklistedWords >= 1 then
			for blacklist in _G.larkov.blacklistedWords do
				if blacklist == word then
					return
				end
			end
		end
	end
	-- learn
	for i, sentence in ipairs(sentences) do
		table.insert(_G.larkov.dictionary.sentences, sentence)
	end
	for i, word in ipairs(words) do
		table.insert(_G.larkov.dictionary.words, word)
	end
end

function dictionary.forget(word)
	local pattern = "%f[%w_]".. utility.escapePattern(word) .. "%f[^%w_]"
	local forgottenAmount = 0
	
	for i, line in ipairs(_G.larkov.dictionary.sentences) do
		if line:match(pattern) then
			table.remove(_G.larkov.dictionary.sentences, i)
			forgottenAmount = forgottenAmount + 1
		end
	end
	
	return forgottenAmount
end

function dictionary.buildAround(word)
	local word_ = utility.escapePattern(word)
	
	local leftSentence = dictionary.getRandomSentenceContaining(word_)
	local rightSentence = dictionary.getRandomSentenceContaining(word_)
	local leftSide = {}
	local rightSide = {}
	local pattern = "%f[%w_]".. word_ .. "%f[^%w_]"
	
	-- l
	for split in leftSentence:gmatch("%S+") do
		table.insert(leftSide, split)
	end
	
	-- r
	for split in rightSentence:gmatch("%S+") do
		table.insert(rightSide, split)
	end
	table.remove(rightSide, #rightSide)
	
	local rightSentence = table.concat(rightSide, " ")
	local leftSentence = table.concat(leftSide, " ")
	return rightSentence .. " ".. word_.. " ".. leftSentence
end

return dictionary