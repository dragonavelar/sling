local Auxiliary = {}

function Auxiliary.wrap_values(value,lower_limit,upper_limit)
	while value < lower_limit or value >= upper_limit do
		if value < lower_limit then
			value = upper_limit - lower_limit + value
		elseif value >= upper_limit then
			value = lower_limit + value - upper_limit
		end
	end
	return value
end

return Auxiliary
