
function GiveGoldPerAttack( event )
	local caster = event.caster
	local ability = event.ability	
	local gold_per_tick = ability:GetSpecialValueFor("gold_per_attack")

	PlayerResource:ModifyGold( caster:GetPlayerOwnerID(), gold_per_tick, false, 0 )

	local coins = ParticleManager:CreateParticle("particles/econ/items/alchemist/alchemist_midas_knuckles/alch_knuckles_lasthit_coins.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(coins, 1, caster:GetAbsOrigin())
	
	PopupGoldGainAlt(caster, gold_per_tick, true)
	
end


