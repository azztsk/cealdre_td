-- called when a sell_tower_x ability is cast
function SellTower(keys)
    local building = keys.caster
	local sell_pct = keys.ability:GetSpecialValueFor("sell_pct")/100
	
   if building:GetHealth() == building:GetMaxHealth() then -- only allow selling if the building is fully built
		local hero = building:GetOwner()
		local playerID = hero:GetPlayerID()
        local gold_cost = building.gold_cost
		 
        local refundAmount = math.floor(gold_cost * sell_pct)
        if sell_pct > 0  then
			EmitSoundOnClient("DOTA_Item.Hand_Of_Midas", PlayerResource:GetPlayer(playerID))
--            PopupAlchemistGold(building, refundAmount, hero:GetPlayerOwner())
			PopupGoldGain(building, refundAmount,true)
			
            local coins = ParticleManager:CreateParticle("particles/econ/items/alchemist/alchemist_midas_knuckles/alch_knuckles_lasthit_coins.vpcf", PATTACH_CUSTOMORIGIN, building)
            ParticleManager:SetParticleControl(coins, 1, building:GetAbsOrigin())
            hero:ModifyGold(refundAmount, false, 0)
			building:ForceKill(true)
        end
    end
end