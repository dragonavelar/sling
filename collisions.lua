local Collisions = {}
Collisions.debug = false

function Collisions.beginContact( a, b, coll )
	if Collisions.debug and a:getUserData() and b:getUserData() then
		print( 'Colliding a ' .. a:getUserData().id ..
			' with a ' .. b:getUserData().id )
	end
	if a:getUserData() then
		if a:getUserData().collide then
			a:getUserData():collide( b:getUserData(), true )
		end
	end
	if b:getUserData() then
		if b:getUserData().collide then
			b:getUserData():collide( a:getUserData(), true )
		end
	end
end

function Collisions.endContact( a, b, coll )
	if Collisions.debug and a:getUserData() or b:getUserData() then
		local audi, budi = "nil", "nil"
		if a:getUserData() then
			audi = a:getUserData().id
		end
		if b:getUserData() then
			budi = b:getUserData().id
		end
		print( 'Uncolliding a ' .. audi ..
			' with a ' .. budi )
	end
	if a:getUserData() then
		if a:getUserData().collide and b:getUserData() then
			a:getUserData():collide( b:getUserData(), false )
		end
	end
	if b:getUserData() then
		if b:getUserData().collide and a:getUserData() then
			b:getUserData():collide( a:getUserData(), false )
		end
	end
end

function Collisions.preSolve( a, b, coll ) -- TODO
	if a:getUserData() and b:getUserData() then
		if a:getUserData().id == Enemy.id
		and b:getUserData().id == Enemy.id then
			coll:setEnabled( false ) 
		end
		if ( a:getUserData().id == Bush.id
		and b:getUserData().id == Player.id )
		or ( b:getUserData().id == Bush.id
		and a:getUserData().id == Player.id ) then
			coll:setEnabled( false ) 
		end
	end
	return false
end

function Collisions.postSolve( a, b, coll, nimpulse, timpulse ) -- TODO
end

return Collisions
