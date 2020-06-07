local utility = {}

function utility.isDiscordMention(message)
	if message:match("<@%d+>") then
		return true
	end
	return false
end

function utility.escapePattern(message)
	return message:gsub("([^%w])", "")
end

-- boilerplate ye
function utility.splitWords(sentence)
	local words = {}
	for word in sentence:gmatch("%S+") do
		table.insert(words, word)
	end
	return words
end

function utility.splitSentences(line)
	local sentences = {}
	local line_ = line:gsub("\r", "") -- no carriage returns
	for sentence in line:gmatch("[^\n.]+") do -- AsrielBorg is supposed to split @ newlines + periods, but it only does it for newlines..?
		table.insert(sentences, sentence)
	end
	--[[ from Util.js, asrielborg
		// Split at line breaks and periods
        return new Set(str_.split(/\n+|\.\s+/));
		very odd... read last comment
	]]--
	return sentences
end

-- for getKnownWords (https://www.omnimaga.org/other-computer-languages-help/(lua)-check-if-array-contains-given-value/)
function utility.inTable(tbl, item)
    for key, value in pairs(tbl) do
        if value == item then return key end
    end
    return false
end

-- no parseint since tonumber returns `nil` if the int is NaN :D
return utility