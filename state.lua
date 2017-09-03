local State = {}
State.__index = State

function State.new() -- ::State
	local self = setmetatable({},State)
	return self
end

function State:load()
end

function State:transition(new_state)
	-- TODO: Clean up and transition
	return new_state.new()
end

function State:free()
end

function State:update( dt, screenmanager ) -- ::void!
	return nil
end

function State:draw( screenmanager ) -- ::void!
end

function State:input(act,val) -- ::void!
end

return State