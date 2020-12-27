unit_abilities = {
	"creature_armor_bonus","creature_health_bonus",
	"creature_movespeed_bonus","creature_regeneration_bonus",
	"creature_evasion_bonus","creature_gold_bonus",
}
ground_unit ={
	
--	"models/courier/greevil/gold_greevil.vmdl",
--	{name = "", model = ""},
	{unit_name = "mega_greevil", model ="models/courier/gold_mega_greevil/gold_mega_greevil.vmdl"},
	{unit_name = "pudge_dog", model ="models/items/courier/butch_pudge_dog/butch_pudge_dog.vmdl"},
	{unit_name = "amphibian_kid", model ="models/items/courier/amphibian_kid/amphibian_kid.vmdl"},
	{unit_name = "bajie_pig", model ="models/items/courier/bajie_pig/bajie_pig.vmdl"},
	{unit_name = "bearzky", model ="models/items/courier/bearzky/bearzky.vmdl"},
	{unit_name = "blilly_bounceback", model ="models/items/courier/billy_bounceback/billy_bounceback.vmdl"},
	{unit_name = "blotto", model ="models/items/courier/blotto_and_stick/blotto.vmdl"},
	{unit_name = "broofus", model ="models/items/courier/boooofus_courier/boooofus_courier.vmdl"},
	{unit_name = "dokkaebi", model ="models/items/courier/dokkaebi_nexon_courier/dokkaebi_nexon_courier.vmdl"},
	{unit_name = "dc_demon", model ="models/items/courier/dc_demon/dc_demon.vmdl"},
	{unit_name = "faceless_rex", model ="models/items/courier/faceless_rex/faceless_rex.vmdl"},
	
}
fly_unit_model ={
	
--	"models/courier/greevil/gold_greevil_flying.vmdl",
	"models/courier/gold_mega_greevil/gold_mega_greevil_flying.vmdl",
	"models/items/courier/butch_pudge_dog/butch_pudge_dog_flying.vmdl",
	"models/items/courier/amphibian_kid/amphibian_kid_flying.vmdl",
	"models/items/courier/bajie_pig/bajie_pig_flying.vmdl",
	"models/items/courier/bearzky/bearzky_flying.vmdl",
	"models/items/courier/billy_bounceback/billy_bounceback_flying.vmdl",
	"models/items/courier/blotto_and_stick/blotto_flying.vmdl",
	"models/items/courier/boooofus_courier/boooofus_courier_flying.vmdl",
	"models/items/courier/dokkaebi_nexon_courier/dokkaebi_nexon_courier_flying.vmdl",
	"models/items/courier/dc_demon/dc_demon_flying.vmdl",
	"models/items/courier/faceless_rex/faceless_rex_flying.vmdl"
	
}
--[[
	CTDGameSpawner - A single unit spawner for Holdout.
]]
if CTDGameSpawner == nil then
	CTDGameSpawner = class({})
end

function CTDGameSpawner:_DoSpawn()	

	local unit = ground_unit[RandomInt(1,#ground_unit)]
	local model = unit.model
	local unit_name = unit.unit_name
	GameRules.round  = GameRules.round + 1
	local round = GameRules.round
	
	for iUnit = 1,10 do
		Timers:CreateTimer(iUnit,function()			
			local vSpawnLocation = Entities:FindByName( nil, "unit_spawner"):GetAbsOrigin() 

			local entUnit = CreateUnitByName( "npc_dota_ground_unit", vSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS )
	--        table.insert(self._vAliveSpawnedUnits, entUnit)
	--		entUnit:SetMaxHealth(entUnit:GetMaxHealth() * self._gameRound._gameMode._diff["hp"])

			local gold = round--math.floor(round/1)+1
			entUnit:SetOriginalModel(model)
			entUnit:SetModel(model)
			entUnit:SetMaximumGoldBounty(gold)				
			entUnit:SetMinimumGoldBounty(gold)
--			entUnit:SetUnitName(unit_name)
			
			local base_value = GAME_START_GOLD
			local value_sum = 0
			local income_sum = 0
			local dmg_kf = 7/10
			if round > 1 then
				local k = round - 1
				value_sum = 15*k*(k + 5)
				income_sum = 5*k*(k + 4)
			end
	--		print(value_sum)
	--		print(income_sum)
			local health =  (10*round)*(1.17^(round-1))--(base_value + value_sum + income_sum)*dmg_kf*1.12^(round-1)/3
			entUnit:SetMaxHealth(health)
			entUnit:SetBaseMaxHealth(health)
			entUnit:SetHealth(health)
	--		entUnit:SetMaxHealth(entUnit:GetMaxHealth() * self._gameRound._gameMode._diff["hp"])
			
	--		local ability = self._roundSpecial
	--		print(ability)
	--		ability = entUnit:AddAbility(ability)
	--		ability:SetLevel(1)
	--		print(model)
	--		print(unit_name)
	--		print(round)
			
			if entUnit then
				
				local point = Entities:FindByName( nil, "corner_point_1") 				
				if point then	
					entUnit:SetInitialGoalEntity(point)
--					entUnit:MoveToPosition(point:GetAbsOrigin())
					entUnit:AddNewModifier(entUnit, nil, "modifier_phased", nil)
					GameRules.units_ingame = GameRules.units_ingame + 1
					entUnit.ingame = true
					local event_data = {units = GameRules.units_ingame}
					CustomGameEventManager:Send_ServerToAllClients( "update_units_count", event_data )
					
				else
					print(point_name.." dont exist !")
				end	
			end
		end)
	end
end

