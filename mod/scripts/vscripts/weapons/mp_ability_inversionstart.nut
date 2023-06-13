global function OnWeaponPrimaryAttack_ability_inversionstart
global function OnWeaponPrimaryAttack_ability_inversionend
#if SERVER
global function giveEveryoneInversion
#endif
#if CLIENT
global function Server_ShootOnClients
#endif
global function ability_inversion_init
void function ability_inversion_init()
{
	PrecacheWeapon("mp_ability_inversionstart")
	PrecacheWeapon("mp_ability_inversionend")
	AddCallback_OnRegisteringCustomNetworkVars( ability_inversion_register_network_vars )
}


#if SERVER
void function giveEveryoneInversion()
{
	foreach(entity player in GetPlayerArray())
		player.TakeOffhandWeapon(1)
	foreach(entity player in GetPlayerArray())
		player.GiveOffhandWeapon( "mp_ability_inversionstart" , 1)

}
#endif
entity saveWeapon

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


/*
AttackParams
global struct WeaponPrimary
{
	vector pos
	vector dir
	bool firstTimePredicted
	int burstIndex
	int barrelIndex
}

*/

table<entity, inverseBulletPlayerData> inverseServerSaveStates = {

}



void function ability_inversion_register_network_vars()
{
	Remote_RegisterFunction( "Server_ShootOnClients" )
}


//THS HAS TO BE CALLED ON BOTH SERVER AND CLIENT
void function decideWeaponShootFunction( entity weapon, WeaponPrimaryAttackParams attackParams, float waitTime , int ammoCount, bool instantOverride = false)
{
	entity weaponOwner = weapon.GetParent()
	if ( IsValid( weaponOwner ) )
	{
		for( int i; i < ammoCount; i++ )
		{
#if SERVER
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
#endif
#if CLIENT
			if( weapon.GetWeaponClassName() == "mp_weapon_defender" )
				weapon.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, DF_GIB | DF_EXPLOSION )
			else if( weapon.GetWeaponClassName() == "mp_weapon_doubletake" )
				OnWeaponPrimaryAttack_weapon_doubletake( weapon, attackParams )
			else if( weapon.GetWeaponClassName() == "mp_weapon_epg" )
				OnWeaponPrimaryAttack_GenericBoltWithDrop_Player( weapon, attackParams )
			else if( weapon.GetWeaponClassName() == "mp_weapon_esaw" )
				OnWeaponPrimaryAttack_lmg( weapon, attackParams )
			else if( weapon.GetWeaponClassName() == "mp_weapon_lmg" )
				OnWeaponPrimaryAttack_lmg( weapon, attackParams )
			else if( weapon.GetWeaponClassName() == "mp_weapon_lstar" )
				OnWeaponPrimaryAttack_weapon_lstar( weapon, attackParams )
			else if( weapon.GetWeaponClassName() == "mp_weapon_mastiff" )
				OnWeaponPrimaryAttack_weapon_mastiff( weapon, attackParams )
			else if( weapon.GetWeaponClassName() == "mp_weapon_mgl" )
				OnWeaponPrimaryAttack_weapon_mgl( weapon, attackParams )
			else if( weapon.GetWeaponClassName() == "mp_weapon_pulse_lmg" )
				FireGenericBoltWithDrop( weapon, attackParams, false )
			else if( weapon.GetWeaponClassName() == "mp_weapon_rocket_launcher" )
				OnWeaponPrimaryAttack_weapon_rocket_launcher( weapon, attackParams )
			else if( weapon.GetWeaponClassName() == "mp_weapon_shotgun" )
				OnWeaponPrimaryAttack_weapon_shotgun( weapon, attackParams )
			else if( weapon.GetWeaponClassName() == "mp_weapon_shotgun_pistol" )
				OnWeaponPrimaryAttack_weapon_shotgun_pistol( weapon, attackParams )
			else if( weapon.GetWeaponClassName() == "mp_weapon_smr" )
				OnWeaponPrimaryAttack_weapon_smr( weapon, attackParams )
			else if( weapon.GetWeaponClassName() == "mp_weapon_sniper" )
				OnWeaponPrimaryAttack_weapon_sniper( weapon, attackParams )
			else if( weapon.GetWeaponClassName() == "mp_weapon_softball" )
				OnWeaponPrimaryAttack_weapon_softball( weapon, attackParams )
			else if( weapon.GetWeaponClassName() == "mp_weapon_wingman_n" )
				OnWeaponPrimaryAttack_weapon_sniper( weapon, attackParams )
			else if (weapon.GetWeaponClassName() == "mp_weapon_arc_launcher" )
				OnWeaponPrimaryAttack_weapon_arc_launcher( weapon, attackParams)
			else if (weapon.GetWeaponClassName() == "mp_alternator_smg" )
				OnWeaponPrimaryAttack_alternator_smg( weapon, attackParams)
			else
				weapon.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageTypes.bullet )
#endif
			if( !instantOverride )
			{
				wait( 1 / waitTime )
			}
		}
}
}




#if CLIENT

void function Server_ShootOnClients( bool isProjectileWeapon, int entityWeaponEncodedEHandle, float OriginVector1, float OriginVector2, float OriginVector3, float ImpactVector1, float ImpactVector2, float ImpactVector3, int ammoCount, bool instantOverride)
{
	entity entityWeapon = GetEntityFromEncodedEHandle( entityWeaponEncodedEHandle )
	vector OriginVector = < OriginVector1, OriginVector2, OriginVector3 >
	vector ImpactVector = < ImpactVector1, ImpactVector2, ImpactVector3 >
	//entityWeapon.FireWeaponBullet( OriginVector, ImpactVector, 1, DF_GIB | DF_EXPLOSION )
	WeaponPrimaryAttackParams attackParams
	attackParams.pos = OriginVector
	attackParams.dir = ImpactVector
	attackParams.firstTimePredicted = true
	thread decideWeaponShootFunction( entityWeapon, attackParams, entityWeapon.GetWeaponSettingFloat( eWeaponVar.fire_rate ), ammoCount, instantOverride)



}

#endif


#if SERVER
void function savePlayerStructToTable(entity player_to_save)
{
	inverseBulletPlayerData toSaveNameTemp
	toSaveNameTemp.savedWeapon = player_to_save.GetActiveWeapon()
	printt( player_to_save.IsPlayer() )
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

	DrawArrow( toSaveNameTemp.savedBulletsImpact, -toSaveNameTemp.savedBulletsOrigin, 60, 10, <255, 220, 200>)

	DebugDrawSphere( toSaveNameTemp.savedBulletsImpact, 25.0, 255, 0, 0, true, 60.0 )

	DebugDrawSphere( toSaveNameTemp.savedBulletsOrigin, 25.0, 111, 210, 63, true, 60.0 )

	print( toSaveNameTemp.savedWeapon.GetWeaponDamageFlags())
	inverseServerSaveStates[player_to_save] <- toSaveNameTemp

	player_to_save.TakeOffhandWeapon(1)
	player_to_save.GiveOffhandWeapon( "mp_ability_inversionend" , 1)


	WeaponPrimaryAttackParams attackParams_Server
	attackParams_Server.pos = toSaveNameTemp.savedBulletsOrigin
	attackParams_Server.dir = toSaveNameTemp.savedBulletOriginImpactAngle
	thread decideWeaponShootFunction( toSaveNameTemp.savedWeapon, attackParams_Server, toSaveNameTemp.savedWeapon.GetWeaponSettingFloat( eWeaponVar.fire_rate ), toSaveNameTemp.invertedAmmoCount, true)
	printt( toSaveNameTemp.savedWeapon.GetWeaponClassName() )

	foreach(entity player in GetPlayerArray())
		Remote_CallFunction_Replay( player, "Server_ShootOnClients", true, toSaveNameTemp.savedWeapon.GetEncodedEHandle(), toSaveNameTemp.savedBulletsOrigin.x, toSaveNameTemp.savedBulletsOrigin.y, toSaveNameTemp.savedBulletsOrigin.z, toSaveNameTemp.savedBulletOriginImpactAngle.x, toSaveNameTemp.savedBulletOriginImpactAngle.y, toSaveNameTemp.savedBulletOriginImpactAngle.z, toSaveNameTemp.invertedAmmoCount, true)
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
	StimPlayer( ownerPlayer, duration )





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
	attackParams_Server.pos = inverseBulletImpact
	attackParams_Server.dir = inverseBulletOriginAngle
	thread decideWeaponShootFunction( inverseServerSaveStates[ownerPlayer].savedWeapon, attackParams_Server, inverseServerSaveStates[ownerPlayer].savedWeapon.GetWeaponSettingFloat( eWeaponVar.fire_rate ), inverseServerSaveStates[ownerPlayer].invertedAmmoCount, false)

	//inverseServerSaveStates[ownerPlayer].savedWeapon.FireWeaponBullet( inverseBulletImpact, inverseBulletOriginAngle, inverseServerSaveStates[ownerPlayer].invertedAmmoCount, damageTypes.bullet )
	foreach(entity player in GetPlayerArray())
		Remote_CallFunction_Replay( player, "Server_ShootOnClients", true, inverseServerSaveStates[ownerPlayer].savedWeapon.GetEncodedEHandle(), inverseBulletImpact.x, inverseBulletImpact.y, inverseBulletImpact.z, inverseBulletOriginAngle.x, inverseBulletOriginAngle.y, inverseBulletOriginAngle.z, inverseServerSaveStates[ownerPlayer].invertedAmmoCount, false)
#if BATTLECHATTER_ENABLED
	TryPlayWeaponBattleChatterLine( ownerPlayer, weapon )
#endif //
#else //
	Rumble_Play( "rumble_stim_activate", {} )
#endif //

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_min_to_fire )
}