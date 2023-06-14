global function OnWeaponPrimaryAttack_ability_inversionstart
global function OnWeaponPrimaryAttack_ability_inversionend
#if SERVER
global function giveEveryoneInversion
#endif
global function ability_inversion_init

void function ability_inversion_init()
{
	PrecacheWeapon("mp_ability_inversionstart")
	PrecacheWeapon("mp_ability_inversionend")
}

#if SERVER
bool InverseDebugDraw = true

void function giveEveryoneInversion()
{
	foreach(entity player in GetPlayerArray())
		player.TakeOffhandWeapon(1)
	foreach(entity player in GetPlayerArray())
		player.GiveOffhandWeapon( "mp_ability_inversionstart" , 1)

}
#endif


struct inverseBulletPlayerData {

entity savedWeapon
int invertedAmmoCount
string weaponHasProjectile
vector savedBulletsOrigin
vector savedBulletOriginImpactAngle
vector savedBulletImpactDelta
vector savedBulletsImpactSurface
vector savedBulletsImpact

}


table<entity, inverseBulletPlayerData> inverseServerSaveStates = {

}


#if SERVER

void function decideWeaponShootFunction( entity playerWeapon, WeaponPrimaryAttackParams attackParams, float waitTime , int ammoCount, bool instantOverride = false)
{
	entity ownerPlayer = playerWeapon.GetWeaponOwner()
	entity testEntity = CreateSoldier( ownerPlayer.GetTeam(), attackParams.pos, attackParams.dir )
	DispatchSpawn( testEntity )
	if ( InverseDebugDraw )
	{
		testEntity.MakeInvisible()
	}
	testEntity.SetNameVisibleToEnemy( false )
	testEntity.SetNameVisibleToFriendly( false )
	testEntity.SetNoTarget( true )
	testEntity.SetNoTargetSmartAmmo( true )
	testEntity.Freeze()
	testEntity.StopPhysics()
	testEntity.MakeInvisible()
	testEntity.SetInvulnerable()
	testEntity.GiveWeapon( playerWeapon.GetWeaponClassName())
	testEntity.SetActiveWeaponByName( playerWeapon.GetWeaponClassName())
	entity weapon = testEntity.GetActiveWeapon()

	if ( IsValid( testEntity ) )
	{
		for( int i; i < ammoCount; i++ )
		{

			if( weapon.GetWeaponClassName() == "mp_weapon_defender" )
				OnWeaponNpcPrimaryAttack_weapon_defender( weapon, attackParams )
			else if( weapon.GetWeaponClassName() == "mp_weapon_doubletake" )
				OnWeaponNpcPrimaryAttack_weapon_doubletake( weapon, attackParams )
			else if( weapon.GetWeaponClassName() == "mp_weapon_epg" )
				OnWeaponPrimaryAttack_GenericBoltWithDrop_NPC( weapon, attackParams )
			else if( weapon.GetWeaponClassName() == "mp_weapon_esaw" )
				OnWeaponPrimaryAttack_lmg( weapon, attackParams )
			else if( weapon.GetWeaponClassName() == "mp_weapon_lmg" )
				OnWeaponPrimaryAttack_lmg( weapon, attackParams )
			else if( weapon.GetWeaponClassName() == "mp_weapon_lstar" )
				OnWeaponNpcPrimaryAttack_weapon_lstar( weapon, attackParams )
			else if( weapon.GetWeaponClassName() == "mp_weapon_mastiff" )
				OnWeaponNpcPrimaryAttack_weapon_mastiff( weapon, attackParams )
			else if( weapon.GetWeaponClassName() == "mp_weapon_mgl" )
				OnWeaponNpcPrimaryAttack_weapon_mgl( weapon, attackParams )
			else if( weapon.GetWeaponClassName() == "mp_weapon_pulse_lmg" )
				FireGenericBoltWithDrop( weapon, attackParams, false )
			else if( weapon.GetWeaponClassName() == "mp_weapon_rocket_launcher" )
				OnWeaponNpcPrimaryAttack_weapon_rocket_launcher( weapon, attackParams )
			else if( weapon.GetWeaponClassName() == "mp_weapon_shotgun" )
				OnWeaponNpcPrimaryAttack_weapon_shotgun( weapon, attackParams )
			else if( weapon.GetWeaponClassName() == "mp_weapon_shotgun_pistol" )
				OnWeaponNpcPrimaryAttack_weapon_shotgun_pistol( weapon, attackParams )
			else if( weapon.GetWeaponClassName() == "mp_weapon_smr" )
				OnWeaponNpcPrimaryAttack_weapon_smr( weapon, attackParams )
			else if( weapon.GetWeaponClassName() == "mp_weapon_sniper" )
				OnWeaponNpcPrimaryAttack_weapon_sniper( weapon, attackParams )
			else if( weapon.GetWeaponClassName() == "mp_weapon_softball" )
				OnWeaponNpcPrimaryAttack_weapon_softball( weapon, attackParams )
			else if( weapon.GetWeaponClassName() == "mp_weapon_wingman_n" )
				OnWeaponNpcPrimaryAttack_weapon_sniper( weapon, attackParams )
			else if (weapon.GetWeaponClassName() == "mp_weapon_arc_launcher" )
				FireArcBall( weapon, attackParams.pos, attackParams.dir, false, 350 )
			else if (weapon.GetWeaponClassName() == "mp_alternator_smg" )
				OnWeaponNpcPrimaryAttack_alternator_smg( weapon, attackParams)

			else
				weapon.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageTypes.bullet )

			if( !instantOverride )
			{
				wait( 1 / waitTime )
			}
		}
		testEntity.Destroy()
	}
}
#endif


#if SERVER
void function savePlayerStructToTable(entity player_to_save)
{
	inverseBulletPlayerData toSaveNameTemp
	toSaveNameTemp.savedWeapon = player_to_save.GetActiveWeapon()
	if ( toSaveNameTemp.savedWeapon.GetWeaponClassName() == "mp_weapon_defender" )
	{
		toSaveNameTemp.invertedAmmoCount = 1

	}
	else
	{
		toSaveNameTemp.invertedAmmoCount = player_to_save.GetWeaponAmmoLoaded( toSaveNameTemp.savedWeapon )
		toSaveNameTemp.savedWeapon.SetWeaponPrimaryClipCount(0)
	}

 	toSaveNameTemp.savedBulletsOrigin = player_to_save.GetOrigin() + < 0, 0, 50>

 	toSaveNameTemp.savedBulletOriginImpactAngle = Normalize( player_to_save.GetViewVector() )

	toSaveNameTemp.savedBulletsImpactSurface = GetViewTrace( player_to_save ).endPos

 	toSaveNameTemp.savedBulletImpactDelta = Normalize( toSaveNameTemp.savedBulletsImpactSurface - toSaveNameTemp.savedBulletsOrigin )

	toSaveNameTemp.savedBulletsImpact = toSaveNameTemp.savedBulletsImpactSurface - toSaveNameTemp.savedBulletImpactDelta * 36

	if ( InverseDebugDraw )
	{
		DrawArrow( toSaveNameTemp.savedBulletsImpact, -toSaveNameTemp.savedBulletsOrigin, 60, 10, <255, 220, 200>)
		DebugDrawSphere( toSaveNameTemp.savedBulletsImpact, 25.0, 255, 0, 0, true, 60.0 )
		DebugDrawSphere( toSaveNameTemp.savedBulletsOrigin, 25.0, 111, 210, 63, true, 60.0 )
	}

	inverseServerSaveStates[player_to_save] <- toSaveNameTemp

	player_to_save.TakeOffhandWeapon(1)
	player_to_save.GiveOffhandWeapon( "mp_ability_inversionend" , 1)


	WeaponPrimaryAttackParams attackParams_Server
	attackParams_Server.pos = toSaveNameTemp.savedBulletsOrigin
	attackParams_Server.dir = toSaveNameTemp.savedBulletOriginImpactAngle
	thread decideWeaponShootFunction( toSaveNameTemp.savedWeapon, attackParams_Server, toSaveNameTemp.savedWeapon.GetWeaponSettingFloat( eWeaponVar.fire_rate ), toSaveNameTemp.invertedAmmoCount, true)
	printt( toSaveNameTemp.savedWeapon.GetWeaponClassName() )

}

#endif


/*

 ▄▄▄▄▄▄▄▄▄▄▄  ▄▄        ▄  ▄               ▄       ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄               ▄  ▄▄▄▄▄▄▄▄▄▄▄
▐░░░░░░░░░░░▌▐░░▌      ▐░▌▐░▌             ▐░▌     ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌             ▐░▌▐░░░░░░░░░░░▌
 ▀▀▀▀█░█▀▀▀▀ ▐░▌░▌     ▐░▌ ▐░▌           ▐░▌      ▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌ ▐░▌           ▐░▌ ▐░█▀▀▀▀▀▀▀▀▀
     ▐░▌     ▐░▌▐░▌    ▐░▌  ▐░▌         ▐░▌       ▐░▌          ▐░▌       ▐░▌  ▐░▌         ▐░▌  ▐░▌
     ▐░▌     ▐░▌ ▐░▌   ▐░▌   ▐░▌       ▐░▌        ▐░█▄▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄█░▌   ▐░▌       ▐░▌   ▐░█▄▄▄▄▄▄▄▄▄
     ▐░▌     ▐░▌  ▐░▌  ▐░▌    ▐░▌     ▐░▌         ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌    ▐░▌     ▐░▌    ▐░░░░░░░░░░░▌
     ▐░▌     ▐░▌   ▐░▌ ▐░▌     ▐░▌   ▐░▌           ▀▀▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀█░▌     ▐░▌   ▐░▌     ▐░█▀▀▀▀▀▀▀▀▀
     ▐░▌     ▐░▌    ▐░▌▐░▌      ▐░▌ ▐░▌                     ▐░▌▐░▌       ▐░▌      ▐░▌ ▐░▌      ▐░▌
 ▄▄▄▄█░█▄▄▄▄ ▐░▌     ▐░▐░▌       ▐░▐░▌             ▄▄▄▄▄▄▄▄▄█░▌▐░▌       ▐░▌       ▐░▐░▌       ▐░█▄▄▄▄▄▄▄▄▄
▐░░░░░░░░░░░▌▐░▌      ▐░░▌        ▐░▌             ▐░░░░░░░░░░░▌▐░▌       ▐░▌        ▐░▌        ▐░░░░░░░░░░░▌
 ▀▀▀▀▀▀▀▀▀▀▀  ▀        ▀▀          ▀               ▀▀▀▀▀▀▀▀▀▀▀  ▀         ▀          ▀          ▀▀▀▀▀▀▀▀▀▀▀


*/

var function OnWeaponPrimaryAttack_ability_inversionstart( entity weapon, WeaponPrimaryAttackParams attackParams )
{

	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( IsValid( ownerPlayer) && ownerPlayer.IsPlayer() )
	if ( IsValid( ownerPlayer ) && ownerPlayer.IsPlayer() )
	{
		if ( ownerPlayer.GetCinematicEventFlags() & CE_FLAG_CLASSIC_MP_SPAWNING )
			return false

		if ( ownerPlayer.GetCinematicEventFlags() & CE_FLAG_INTRO )
			return false
	}


	float duration = weapon.GetWeaponSettingFloat( eWeaponVar.fire_duration )

#if SERVER
	savePlayerStructToTable(ownerPlayer)
#if BATTLECHATTER_ENABLED
	TryPlayWeaponBattleChatterLine( ownerPlayer, weapon )
#endif //
#else //
	Rumble_Play( "rumble_stim_activate", {} )
#endif //
	PlayerUsedOffhand( ownerPlayer, weapon )

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_min_to_fire )
}



/*


 ▄▄▄▄▄▄▄▄▄▄▄  ▄▄        ▄  ▄               ▄       ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄
▐░░░░░░░░░░░▌▐░░▌      ▐░▌▐░▌             ▐░▌     ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌
 ▀▀▀▀█░█▀▀▀▀ ▐░▌░▌     ▐░▌ ▐░▌           ▐░▌      ▐░█▀▀▀▀▀▀▀▀▀  ▀▀▀▀█░█▀▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀▀▀
     ▐░▌     ▐░▌▐░▌    ▐░▌  ▐░▌         ▐░▌       ▐░▌               ▐░▌     ▐░▌       ▐░▌▐░▌
     ▐░▌     ▐░▌ ▐░▌   ▐░▌   ▐░▌       ▐░▌        ▐░█▄▄▄▄▄▄▄▄▄      ▐░▌     ▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄▄▄
     ▐░▌     ▐░▌  ▐░▌  ▐░▌    ▐░▌     ▐░▌         ▐░░░░░░░░░░░▌     ▐░▌     ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌
     ▐░▌     ▐░▌   ▐░▌ ▐░▌     ▐░▌   ▐░▌          ▐░█▀▀▀▀▀▀▀▀▀      ▐░▌     ▐░█▀▀▀▀█░█▀▀ ▐░█▀▀▀▀▀▀▀▀▀
     ▐░▌     ▐░▌    ▐░▌▐░▌      ▐░▌ ▐░▌           ▐░▌               ▐░▌     ▐░▌     ▐░▌  ▐░▌
 ▄▄▄▄█░█▄▄▄▄ ▐░▌     ▐░▐░▌       ▐░▐░▌            ▐░▌           ▄▄▄▄█░█▄▄▄▄ ▐░▌      ▐░▌ ▐░█▄▄▄▄▄▄▄▄▄
▐░░░░░░░░░░░▌▐░▌      ▐░░▌        ▐░▌             ▐░▌          ▐░░░░░░░░░░░▌▐░▌       ▐░▌▐░░░░░░░░░░░▌
 ▀▀▀▀▀▀▀▀▀▀▀  ▀        ▀▀          ▀               ▀            ▀▀▀▀▀▀▀▀▀▀▀  ▀         ▀  ▀▀▀▀▀▀▀▀▀▀▀


*/




var function OnWeaponPrimaryAttack_ability_inversionend( entity weapon, WeaponPrimaryAttackParams attackParams )
{

	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( IsValid( ownerPlayer) && ownerPlayer.IsPlayer() )
	if ( IsValid( ownerPlayer ) && ownerPlayer.IsPlayer() )
	{
		if ( ownerPlayer.GetCinematicEventFlags() & CE_FLAG_CLASSIC_MP_SPAWNING )
			return false

		if ( ownerPlayer.GetCinematicEventFlags() & CE_FLAG_INTRO )
			return false
	}


	float duration = weapon.GetWeaponSettingFloat( eWeaponVar.fire_duration )
	//StimPlayer( ownerPlayer, duration )

	PlayerUsedOffhand( ownerPlayer, weapon )

#if SERVER
	ownerPlayer.TakeOffhandWeapon(1)
	ownerPlayer.GiveOffhandWeapon( "mp_ability_inversionstart" , 1)
	vector inverseBulletOriginAngle = -inverseServerSaveStates[ownerPlayer].savedBulletOriginImpactAngle
	vector inverseBulletImpact = inverseServerSaveStates[ownerPlayer].savedBulletsImpact
	if ( inverseServerSaveStates[ownerPlayer].savedWeapon.GetWeaponClassName() == "mp_weapon_defender" )
	{
		bool fuckthisshitidontknowifthereisapassfunctioninsquirrelandimtoolazytolookintothedocs = true
	}
	else
	{
		inverseServerSaveStates[ownerPlayer].savedWeapon.SetWeaponPrimaryClipCount(inverseServerSaveStates[ownerPlayer].invertedAmmoCount)
	}
	WeaponPrimaryAttackParams attackParams_Server
	attackParams_Server.pos = inverseBulletImpact - < 0, 0, 47>
	attackParams_Server.dir = Normalize( inverseBulletOriginAngle )
	thread decideWeaponShootFunction( inverseServerSaveStates[ownerPlayer].savedWeapon, attackParams_Server, inverseServerSaveStates[ownerPlayer].savedWeapon.GetWeaponSettingFloat( eWeaponVar.fire_rate ), inverseServerSaveStates[ownerPlayer].invertedAmmoCount, false)

#if BATTLECHATTER_ENABLED
	TryPlayWeaponBattleChatterLine( ownerPlayer, weapon )
#endif //
#else //
	Rumble_Play( "rumble_stim_activate", {} )
#endif //

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_min_to_fire )
}