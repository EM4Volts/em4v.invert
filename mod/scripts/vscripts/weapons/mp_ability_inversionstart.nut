global function OnWeaponPrimaryAttack_ability_inversionstart
global function OnWeaponPrimaryAttack_ability_inversionend

global function ability_inversion_init
void function ability_inversion_init()
{
	PrecacheWeapon("mp_ability_inversionstart")
	PrecacheWeapon("mp_ability_inversionend")
#if CLIENT
	inversionBulletServer()
#endif
}

entity saveWeapon

struct inverseBulletPlayerData {

bool invertedBulletsSet = false
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


#if CLIENT
void function inversionBulletServer()
{
	AddServerToClientStringCommandCallback("saveInversionOnPlayer", inverseBulletSave)
	AddServerToClientStringCommandCallback("fireInversionOnPlayer", inverseBulletFire)

}
#endif

#if SERVER
void function savePlayerStructToTable(entity player_to_save)
{
	inverseBulletPlayerData toSaveNameTemp
	toSaveNameTemp.invertedBulletsSet = true
	toSaveNameTemp.savedWeapon = player_to_save.GetActiveWeapon()
	printt( player_to_save.IsPlayer() )
	toSaveNameTemp.invertedAmmoCount = player_to_save.GetWeaponAmmoLoaded( toSaveNameTemp.savedWeapon )
 	toSaveNameTemp.savedBulletsOrigin = player_to_save.GetOrigin() + < 0, 0, 50>
 	toSaveNameTemp.savedBulletOriginImpactAngle = player_to_save.GetViewVector()
	toSaveNameTemp.savedBulletsImpactSurface = GetViewTrace( player_to_save ).endPos
 	toSaveNameTemp.savedBulletImpactDelta = Normalize( toSaveNameTemp.savedBulletsImpactSurface - toSaveNameTemp.savedBulletsOrigin )
	toSaveNameTemp.savedBulletsImpact = toSaveNameTemp.savedBulletsImpactSurface - toSaveNameTemp.savedBulletImpactDelta * 36

	inverseServerSaveStates[player_to_save] <- toSaveNameTemp


	player_to_save.TakeOffhandWeapon(1)
	player_to_save.GiveOffhandWeapon( "mp_ability_inversionend" , 1)
	ServerToClientStringCommand(player_to_save, "saveInversionOnPlayer " + player_to_save.GetEncodedEHandle())
	toSaveNameTemp.savedWeapon.SetWeaponPrimaryClipCount(0)
}

#endif

#if CLIENT
void function inverseBulletSave(array <string> args)
{
		entity player_to_fire = GetEntityFromEncodedEHandle( int(args[0]) )
		//savedWeapon.FireWeaponBullet( savedBulletsOrigin, savedBulletOriginImpactAngle, invertedAmmoCount, damageTypes.bullet )
		saveWeapon = player_to_fire.GetActiveWeapon()
		inverseServerSaveStates[player_to_fire].savedWeapon = saveWeapon
		saveWeapon.FireWeaponBullet( inverseServerSaveStates[player_to_fire].savedBulletsOrigin, inverseServerSaveStates[player_to_fire].savedBulletOriginImpactAngle, inverseServerSaveStates[player_to_fire].invertedAmmoCount, damageTypes.bullet )
		//DEBUG
		printt(inverseServerSaveStates[player_to_fire].savedBulletsImpact)
		DebugDrawSphere( inverseServerSaveStates[player_to_fire].savedBulletsImpact, 32.0, 255, 128, 0, true, 10.0 )
		DebugDrawSphere( inverseServerSaveStates[player_to_fire].savedBulletsOrigin, 32.0, 0, 128, 155, true, 10.0 )


}

void function inverseBulletFire(array <string> args)
{

		entity ownerPlayer = GetEntityFromEncodedEHandle( int(args[0]) )
		printt("TEST")
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
	ServerToClientStringCommand(ownerPlayer, "saveInversionOnPlayer" + ownerPlayer.GetEncodedEHandle())
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
	ServerToClientStringCommand(ownerPlayer, "fireInversionOnPlayer" + ownerPlayer.GetEncodedEHandle())
	ownerPlayer.TakeOffhandWeapon(1)
	ownerPlayer.GiveOffhandWeapon( "mp_ability_inversionstart" , 1)
	DebugDrawLine( inverseServerSaveStates[ownerPlayer].savedBulletsImpact,  inverseServerSaveStates[ownerPlayer].savedBulletsOrigin, 255, 0, 0, true, 10.0 )
	DebugDrawSphere( inverseServerSaveStates[ownerPlayer].savedBulletsImpact, 32.0, 255, 128, 0, true, 10.0 )
	DebugDrawSphere( inverseServerSaveStates[ownerPlayer].savedBulletsOrigin, 32.0, 0, 128, 155, true, 10.0 )
	inverseServerSaveStates[ownerPlayer].savedWeapon.FireWeaponBullet(inverseServerSaveStates[ownerPlayer].savedBulletsImpact,-inverseServerSaveStates[ownerPlayer].savedBulletOriginImpactAngle, inverseServerSaveStates[ownerPlayer].invertedAmmoCount, damageTypes.bullet  )

#if BATTLECHATTER_ENABLED
	TryPlayWeaponBattleChatterLine( ownerPlayer, weapon )
#endif //
#else //
	Rumble_Play( "rumble_stim_activate", {} )
#endif //

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_min_to_fire )
}