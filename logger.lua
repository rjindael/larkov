local logger = {}

function logger.log(type, message, ...)
	local pMessage = os.date("%Y-%m-%d %H:%M:%S").. " | "
	if type == "info" then
		pMessage = pMessage .. "\27[0m\27[1;32m[INFO]\27[0m    | "
	elseif type == "warning" then
		pMessage = pMessage .. "\27[0m\27[1;33m[WARNING]\27[0m | "
	elseif type == "error" then
		pMessage = pMessage .. "\27[0m\27[1;31m[ERROR]\27[0m   | "
	elseif type == "markov" then
		pMessage = pMessage .. "\27[0m\27[1;35m[MARKOV]\27[0m  | User ".. ... .." sends message "
	elseif type == "debug" then
		pMessage = pMessage .. "\27[0m\27[1;36m[DEBUG]\27[0m   | "
	end
	print(pMessage.. message)
end

return logger