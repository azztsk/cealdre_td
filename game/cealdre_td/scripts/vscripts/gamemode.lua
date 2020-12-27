require('libraries/popups')

GameRules.round = 0
GameRules.units_ingame = 0

ROUND_TO_WIN = 50
DEBUG_SPEW = 0
player_colors = {}
player_colors[1] = { 61, 210, 150 }    --              Teal
player_colors[3] = { 243, 201, 9 }     --              Yellow
player_colors[5] = { 197, 77, 168 }    --              Pink
player_colors[4] = { 255, 108, 0 }     --              Orange
player_colors[0] = { 52, 85, 255 }     --              Blue
player_colors[8] = { 101, 212, 19 }    --              Green
player_colors[9] = { 129, 83, 54 }     --              Brown
player_colors[7] = { 27, 192, 216 }    --              Cyan
player_colors[6] = { 199, 228, 13 }    --              Olive
player_colors[2] = { 140, 42, 244 }    --              Purple

XP_PER_LEVEL_TABLE = {}
XP_PER_LEVEL_TABLE[0] =0
for i=1,8 do
  XP_PER_LEVEL_TABLE[i] = XP_PER_LEVEL_TABLE[i-1]+50--i * 25
end

function CTDGameMode:InitGameMode()
	self._nRoundNumber = 1
	self._currentRound = nil
	self._flLastThinkGameTime = nil

	GameRules:SetShowcaseTime( 0.0 ) 
	GameRules:SetSameHeroSelectionEnabled( true )
	GameRules:SetTimeOfDay( 0.75 )
	GameRules:SetHeroRespawnEnabled( false )
	GameRules:SetUseUniversalShopMode( false )
	GameRules:SetHeroSelectionTime( 30.0 )
	GameRules:SetStrategyTime(0.0)
	GameRules:SetPreGameTime( 25.0 )
	GameRules:SetPostGameTime( 30.0 )
	GameRules:SetTreeRegrowTime( 60.0 )
	GameRules:SetCreepMinimapIconScale( 0.7 )
	GameRules:SetRuneMinimapIconScale( 0.7 )
	GameRules:SetGoldPerTick( 0 )
	GameRules:SetStartingGold( 30 )
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS,10)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS,0)
	
	local mode = GameRules:GetGameModeEntity()
	mode:SetRemoveIllusionsOnDeath( true )
	mode:SetTopBarTeamValuesOverride( true )
	mode:SetTopBarTeamValuesVisible( false )
	mode:SetFogOfWarDisabled ( true )
	mode:SetUseCustomHeroLevels ( true )
	mode:SetCustomHeroMaxLevel ( 10 )
	mode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )

	mode:SetThink( "OnThink", self, "GlobalThink", 0.1 )
	mode:SetCameraDistanceOverride(1300)

	-- Register Listeners
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap(CTDGameMode, "OnNpcSpawned"), self)
	ListenToGameEvent( "dota_player_pick_hero", Dynamic_Wrap( CTDGameMode, "OnPlayerPicked" ), self )
	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( CTDGameMode, "OnGameRulesStateChange" ), self )
	ListenToGameEvent( "entity_killed", Dynamic_Wrap(CTDGameMode, "OnEntityKilled"), self)
	ListenToGameEvent( "player_reconnected", Dynamic_Wrap(CTDGameMode, "OnPlayerReconnect"), self)

end

-- assign invincibility to the heroes
function CTDGameMode:OnNpcSpawned( keys )

	local unit = EntIndexToHScript( keys.entindex )
	if unit:IsRealHero() then
		-- add the invulnerable modifier to the hero
		unit:AddNewModifier(unit, nil, "modifier_invulnerable", nil)
--[[	
		local player_id = unit:GetPlayerID()
		local point = Entities:FindByName( nil, "spawn_point_"..player_id )
		if point then 
			Timers:CreateTimer(0.01, function() unit:SetAbsOrigin(point:GetAbsOrigin()) end)			
			print("player_id = "..player_id)
			print(point)
		end
]]		
		for index=0,5 do
			if (unit:GetAbilityByIndex(index)==nil) then
				break
			else
				unit:GetAbilityByIndex(index):SetLevel(1)
--				unit:SetAbilityPoints(0)
			end
		end
	end
end

function CTDGameMode:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()

	if nNewState == DOTA_GAMERULES_STATE_STRATEGY_TIME then
		for i=0, DOTA_MAX_TEAM_PLAYERS do
			if PlayerResource:HasSelectedHero(i) == false then
	            local player = PlayerResource:GetPlayer(i)
	            if player then
	            	print("Randoming hero for player ", i)
	            	player:MakeRandomHeroSelection()
	            end
	        end
	    end
	elseif nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
--		CustomUI:DynamicHud_Create(0, "diffPan", "file://{resources}/layout/custom_game/choose_diff.xml", nil)
	end

	if nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		Timers:CreateTimer(0,function()
			CTDGameSpawner:_DoSpawn()
			return 30
		end)
	end

	--insert ui element for 
end

function CTDGameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		if GameRules.round > ROUND_TO_WIN then
			GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )
			return false
		end
		
		if GameRules.units_ingame >= 25 then
			GameRules:SetGameWinner( DOTA_TEAM_BADGUYS )
			return false			
		end

	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then		-- Safe guard catching any state that may exist beyond DOTA_GAMERULES_STATE_POST_GAME
		return nil
	end
	return 1
end

function CTDGameMode:OnEntityKilled( event )
	-- The Unit that was Killed
	local killedUnit = EntIndexToHScript(event.entindex_killed)
	-- The Killing entity
	local killerEntity
	if event.entindex_attacker then
		killerEntity = EntIndexToHScript(event.entindex_attacker)
	end

	-- Player owner of the unit
	local player = killedUnit:GetPlayerOwner()
	
	if killedUnit.ingame then
		GameRules.units_ingame = GameRules.units_ingame - 1
		local event_data = {units = GameRules.units_ingame}
		CustomGameEventManager:Send_ServerToAllClients( "update_units_count", event_data )
	end
	
	if IsCustomBuilding(killedUnit) then
		 -- Building Helper grid cleanup
		BuildingHelper:RemoveBuilding(killedUnit, true)

		-- Check units for downgrades
		local building_name = killedUnit:GetUnitName()
	end
end
