--require("td_game_round")
function OnTouchVector(keys)
	local unit = keys.activator
	local trigger_name = thisEntity:GetName()
	print("gg")
	print(trigger_name)
	
    if (unit:IsOwnedByAnyPlayer() ) and unit  then
        -- Is player owned - Ignore
		print("111")
		
    else
		print("222")
		local point_name = ""
		
		if trigger_name == "vector_trigger_1" 	then point_name = "vector_trigger_2"
		elseif trigger_name == "vector_trigger_2" then point_name = "vector_trigger_3"
		elseif trigger_name == "vector_trigger_3" then point_name = "vector_trigger_4"
		elseif trigger_name == "vector_trigger_4" then point_name = "vector_trigger_1"
		end
		
		local point = Entities:FindByName( nil, point_name) 				
		if point then	
--			unit:MoveToPosition(point:GetAbsOrigin())
		else
			print(point_name.." dont exist !")
		end		
    end
end
