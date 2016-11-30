-- Author: Davis Zeng  <daviszeng@outlook.com>

local tool = {}

function tool:required_check(data, need)
	if type(data) ~= "table" or type(need) ~= "table" then
		return false
	end
	for key, value in pairs(need) do
		if data[value] == nil then
			return false
		end
	end
	return true
end

return tool
