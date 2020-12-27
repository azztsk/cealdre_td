



function SetColor(data)

	local moob = data.caster
	local name = moob:GetUnitName()
	
	local a = 255
	local b = 255
	local c = 255

	if name == "npc_dota_direr3_1" then
		a = 255
		b = 15
		c = 0
	elseif name == "npc_dota_tower_support_red" then
		a = 255
		b = 0
		c = 0
	elseif name == "npc_dota_tower_support_yellow" then
		a = 255
		b = 255
		c = 0
	elseif name == "npc_dota_tower_support_green" then
		a = 173
		b = 255
		c = 47
	elseif name == "npc_dota_tower_support_blue" then
		a = 70
		b = 130
		c = 100
	elseif name == "npc_dota_tower_support_orange" then
		a = 255
		b = 130
		c = 0
	end	


--	GameRules:GetGameModeEntity():SetContextThink(string.format("RespawnThink_%d",moob:GetEntityIndex()), 
--		function()
		moob:SetRenderColor(a, b, c)
--		end,
--		data.Time)		

end


