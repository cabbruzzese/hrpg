// Skull (Horn) Rod ---------------------------------------------------------
const SKULLROD_ALT_AMMO_COST = 3;
const SKULLROD_POWER_AMMO_COST = 5;

class HRpgSkullRod : NonHeathenWeapon replaces SkullRod
{
	Default
	{
		Weapon.SelectionOrder 200;
		Weapon.AmmoUse 1;
		Weapon.AmmoGive 50;
		Weapon.YAdjust 15;
		Weapon.AmmoType "SkullRodAmmo";
		Weapon.SisterWeapon "HRpgSkullRodPowered";
		Inventory.PickupMessage "$TXT_WPNSKULLROD";
		Tag "$TAG_SKULLROD";
		Obituary "$OB_MPSKULLBASH";
		
		HRpgWeapon.ExtraSpawnItem "HRpgTrident";
	}

	States
	{
	Spawn:
		WSKL A -1;
		Stop;
	Ready:
		HROD A 1 A_WeaponReady;
		Loop;
	Deselect:
		HROD A 1 A_Lower;
		Loop;
	Select:
		HROD A 1 A_Raise;
		Loop;
	Fire:
		HROD AB 4 A_FireSkullRodPL1;
		HROD B 0 A_ReFire;
		Goto Ready;
	AltFire:
		TNT1 A 0 A_CheckAltAmmoOrFire(SKULLROD_ALT_AMMO_COST);
		HROD CDEF 4;
		HROD G 4 A_FireSkullRodPL3(0);
		HROD FED 4;
		HROD C 2 A_ReFire;
		Goto Ready;
	}
	
	action void A_FireSkullRodPL1()
	{
		if (player == null)
		{
			return;
		}

		Weapon weapon = player.ReadyWeapon;
		if (weapon != null)
		{
			if (!weapon.CheckAmmo(PrimaryFire, true))
				return;
			
			weapon.DepleteAmmo (false, true);
		}
		Actor mo = SpawnPlayerMissile ("HornRodFX1");
		// Randomize the first frame
		if (mo && random[FireSkullRod]() > 128)
		{
			mo.SetState (mo.CurState.NextState);
		}
		
		//Scale up damage with level
		let hrpgPlayer = HRpgPlayer(player.mo);
		if (hrpgPlayer != null)
		{
			hrpgPlayer.SetProjectileDamageForMagic(mo);
		}
	}
	
	action void FirePurpleBall(double angleMod)
	{
		let mo = SpawnPlayerMissile ("HornBallFX1", angle + angleMod);
		
		//Scale up damage with level
		let hrpgPlayer = HRpgPlayer(player.mo);
		if (hrpgPlayer != null)
		{
			hrpgPlayer.SetProjectileDamageForMagic(mo);
		}
	}
	
	action void A_FireSkullRodPL3(int powered)
	{
		if (player == null)
		{
			return;
		}

		Weapon weapon = player.ReadyWeapon;
		if (weapon != null)
		{
			int ammoUse = SKULLROD_ALT_AMMO_COST;
			if (powered)
				ammoUse = SKULLROD_POWER_AMMO_COST;
			if (!weapon.DepleteAmmo(false, true, ammoUse, true))
			{
				return;
			}
		}
		
		FirePurpleBall(0);
		if (powered)
		{
			FirePurpleBall(9);
			FirePurpleBall(-9);
		}
		
		A_StartSound ("weapons/hornrodpowshoot", CHAN_WEAPON);
	}
}

class HRpgSkullRodPowered : HRpgSkullRod replaces SkullRodPowered
{
	Default
	{
		+WEAPON.POWERED_UP
		Weapon.AmmoUse 5;
		Weapon.AmmoGive 0;
		Weapon.SisterWeapon "HRpgSkullRod";
		Tag "$TAG_SKULLRODP";
	}

	States
	{
	Fire:
		TNT1 A 0 A_ForceCheckAmmo;
		HROD C 2;
		HROD D 3;
		HROD E 2;
		HROD F 3;
		HROD G 4 A_FireSkullRodPL2;
		HROD F 2;
		HROD E 3;
		HROD D 2;
		HROD C 2 A_ReFire;
		Goto Ready;
	AltFire:
		TNT1 A 0 A_CheckAltAmmoOrFire(SKULLROD_POWER_AMMO_COST);
		HROD C 2 ;
		HROD D 2;
		HROD E 2;
		HROD F 2;
		HROD G 2 A_FireSkullRodPL3(1);
		HROD F 2;
		HROD E 2;
		HROD D 2;
		HROD C 2 A_ReFire;
		Goto Ready;
	}

	action void A_ForceCheckAmmo()
	{
		Weapon weapon = player.ReadyWeapon;
		if (weapon != null)
		{
			weapon.CheckAmmo(false, true);
		}
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_FireSkullRodPL2
	//
	// The special2 field holds the player number that shot the rain missile.
	// The special1 field holds the id of the rain sound.
	//
	//----------------------------------------------------------------------------

	action void A_FireSkullRodPL2()
	{
		FTranslatedLineTarget t;
		
		if (player == null)
		{
			return;
		}

		Weapon weapon = player.ReadyWeapon;
		if (weapon != null)
		{
			if (!weapon.DepleteAmmo (PrimaryFire, true))
				return;
		}
		// Use MissileActor instead of the first return value from P_SpawnPlayerMissile 
		// because we need to give info to it, even if it exploded immediately.
		Actor mo, MissileActor;
		[mo, MissileActor] = SpawnPlayerMissile ("HornRodFX2", angle, pLineTarget: t);
		if (MissileActor != null)
		{
			if (t.linetarget && !t.unlinked)
			{
				MissileActor.tracer = t.linetarget;
			}
			MissileActor.A_StartSound ("weapons/hornrodpowshoot", CHAN_WEAPON);
		}
	}
}

class HornBallFX1 : Actor
{
	Default
	{
		Radius 10;
		Height 6;
		Speed 18;
		FastSpeed 24;
		Damage 10;
		Projectile;
		-ACTIVATEIMPACT
		-ACTIVATEPCROSS
		+ZDOOMTRANS
		RenderStyle "Add";
		Obituary "$OB_MPPHORNBALL";
	}

	States
	{
	Spawn:
		FX11 AB 6 BRIGHT;
		Loop;
	Death:
		FX11 CDEFG 5 BRIGHT;
		Stop;
	}
}