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



void function ability_inversion_register_network_vars()
{
	Remote_RegisterFunction( "Server_ShootOnClients" )
}


#if CLIENT

void function Server_ShootOnClients( bool isProjectileWeapon, int entityWeaponEncodedEHandle, float OriginVector1, float OriginVector2, float OriginVector3, float ImpactVector1, float ImpactVector2, float ImpactVector3, int ammoCount )
{
	entity entityWeapon = GetEntityFromEncodedEHandle( entityWeaponEncodedEHandle )
	vector OriginVector = < OriginVector1, OriginVector2, OriginVector3 >
	vector ImpactVector = < ImpactVector1, ImpactVector2, ImpactVector3 >
	entityWeapon.FireWeaponBullet( OriginVector, ImpactVector, ammoCount, damageTypes.bullet )
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
	toSaveNameTemp.savedWeapon.FireWeaponBullet( toSaveNameTemp.savedBulletsOrigin, toSaveNameTemp.savedBulletOriginImpactAngle, toSaveNameTemp.invertedAmmoCount, damageTypes.bullet )
	foreach(entity player in GetPlayerArray())
		Remote_CallFunction_Replay( player, "Server_ShootOnClients", true, toSaveNameTemp.savedWeapon.GetEncodedEHandle(), toSaveNameTemp.savedBulletsOrigin.x, toSaveNameTemp.savedBulletsOrigin.y, toSaveNameTemp.savedBulletsOrigin.z, toSaveNameTemp.savedBulletOriginImpactAngle.x, toSaveNameTemp.savedBulletOriginImpactAngle.y, toSaveNameTemp.savedBulletOriginImpactAngle.z, toSaveNameTemp.invertedAmmoCount)
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
	vector inverseBulletOriginAngle = -inverseServerSaveStates[ownerPlayer].savedBulletOriginImpactAngle
	vector inverseBulletImpact = inverseServerSaveStates[ownerPlayer].savedBulletsImpact
	inverseServerSaveStates[ownerPlayer].invertedBulletsSet = false
	inverseServerSaveStates[ownerPlayer].savedWeapon.SetWeaponPrimaryClipCount(inverseServerSaveStates[ownerPlayer].invertedAmmoCount)
	inverseServerSaveStates[ownerPlayer].savedWeapon.FireWeaponBullet( inverseBulletImpact, inverseBulletOriginAngle, inverseServerSaveStates[ownerPlayer].invertedAmmoCount, damageTypes.bullet )
	foreach(entity player in GetPlayerArray())
		Remote_CallFunction_Replay( player, "Server_ShootOnClients", true, inverseServerSaveStates[ownerPlayer].savedWeapon.GetEncodedEHandle(), inverseBulletImpact.x, inverseBulletImpact.y, inverseBulletImpact.z, inverseBulletOriginAngle.x, inverseBulletOriginAngle.y, inverseBulletOriginAngle.z, inverseServerSaveStates[ownerPlayer].invertedAmmoCount)
#if BATTLECHATTER_ENABLED
	TryPlayWeaponBattleChatterLine( ownerPlayer, weapon )
#endif //
#else //
	Rumble_Play( "rumble_stim_activate", {} )
#endif //

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_min_to_fire )
}