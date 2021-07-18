// Crossbow -----------------------------------------------------------------

class HRpgCrossbow : NonHeathenWeapon replaces Crossbow
{
	Default
	{
		Weapon.SelectionOrder 800;
		Weapon.AmmoUse1 1;
		Weapon.AmmoGive 10;
		Weapon.AmmoType "CrossbowAmmo";
		Weapon.SisterWeapon "HRpgCrossbowPowered";
		Weapon.YAdjust 15;
		Inventory.PickupMessage "$TXT_WPNCROSSBOW";
		Tag "$TAG_CROSSBOW";
		
		HRpgWeapon.ExtraSpawnItem "HRpgWarAxe";
	}

	States
	{
	Spawn:
		WBOW A -1;
		Stop;
	Ready:
		CRBW AAAAAABBBBBBCCCCCC 1 A_WeaponReady;
		Loop;
	Deselect:
		CRBW A 1 A_Lower;
		Loop;
	Select:
		CRBW A 1 A_Raise;
		Loop;
	Fire:
		CRBW D 6 A_FireCrossbowPL1;
		CRBW EFGH 3;
		CRBW AB 4;
		CRBW C 5 A_ReFire;
		Goto Ready;
	AltFire:
		CRBW D 8 A_FireCrossbowRapid(1, 1);
		CRBW DD 4 A_FireCrossbowRapid(0, 0);
		CRBW EFGH 3;
		CRBW AB 4;
		CRBW C 5 A_ReFire;
		Goto Ready;
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_FireCrossbowPL1
	//
	//----------------------------------------------------------------------------

	action void A_FireCrossbowPL1 ()
	{
		if (player == null)
		{
			return;
		}

		Weapon weapon = player.ReadyWeapon;
		if (weapon != null)
		{
			if (!weapon.DepleteAmmo (weapon.bAltFire))
				return;
		}

		let mo1 = SpawnPlayerMissile ("CrossbowFX1");
		let mo2 = SpawnPlayerMissile ("CrossbowFX3", angle - 4.5);
		let mo3 = SpawnPlayerMissile ("CrossbowFX3", angle + 4.5);
		
		let hrpgPlayer = HRpgPlayer(player.mo);
		if (hrpgPlayer != null)
		{
			hrpgPlayer.SetProjectileDamageForWeapon(mo1);
			hrpgPlayer.SetProjectileDamageForWeapon(mo2);
			hrpgPlayer.SetProjectileDamageForWeapon(mo3);
		}
	}
	
	action void A_FireCrossbowRapid (int big, int useammo)
	{
		if (player == null)
		{
			return;
		}

		if (useammo)
		{
			Weapon weapon = player.ReadyWeapon;
			if (weapon != null)
			{
				if (!weapon.DepleteAmmo (false))
				{
					weapon.CheckAmmo(Weapon.PrimaryFire, true);
					return;
				}
			}
		}
			
		let hrpgPlayer = HRpgPlayer(player.mo);
		if (big)
		{
			let mo = SpawnPlayerMissile ("CrossbowFX1");
			hrpgPlayer.SetProjectileDamageForWeapon(mo);
		}
		else
		{
			let mo = SpawnPlayerMissile ("CrossbowFX3");
			hrpgPlayer.SetProjectileDamageForWeapon(mo);
		}
	}
}


class HRpgCrossbowPowered : HRpgCrossbow replaces CrossbowPowered
{
	Default
	{
		+WEAPON.POWERED_UP
		Weapon.AmmoGive 0;
		Weapon.SisterWeapon "HRpgCrossbow";
		Tag "$TAG_CROSSBOWP";
	}

	States
	{
	Fire:
		CRBW D 5 A_FireCrossbowPL2;
		CRBW E 3;
		CRBW F 2;
		CRBW G 3;
		CRBW H 2;
		CRBW A 3;
		CRBW B 3;
		CRBW C 4 A_ReFire;
		Goto Ready;
	AltFire:
		CRBW D 8 A_FireCrossbowRapid(1, 1);
		CRBW DDD 4 A_FireCrossbowRapid(1, 0);
		CRBW EFGH 3;
		CRBW AB 4;
		CRBW C 5 A_ReFire;
		Goto Ready;
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_FireCrossbowPL2
	//
	//----------------------------------------------------------------------------

	action void A_FireCrossbowPL2()
	{
		if (player == null)
		{
			return;
		}

		Weapon weapon = player.ReadyWeapon;
		if (weapon != null)
		{
			if (!weapon.DepleteAmmo (weapon.bAltFire))
				return;
		}
		
		let mo1 = SpawnPlayerMissile ("CrossbowFX2");
		let mo2 = SpawnPlayerMissile ("CrossbowFX2", angle - 4.5);
		let mo3 = SpawnPlayerMissile ("CrossbowFX2", angle + 4.5);
		let mo4 = SpawnPlayerMissile ("CrossbowFX3", angle - 9.);
		let mo5 = SpawnPlayerMissile ("CrossbowFX3", angle + 9.);
		
		let hrpgPlayer = HRpgPlayer(player.mo);
		if (hrpgPlayer != null && mo1)
		{
			hrpgPlayer.SetProjectileDamageForWeapon(mo1);
			hrpgPlayer.SetProjectileDamageForWeapon(mo2);
			hrpgPlayer.SetProjectileDamageForWeapon(mo3);
			hrpgPlayer.SetProjectileDamageForWeapon(mo4);
			hrpgPlayer.SetProjectileDamageForWeapon(mo5);
		}
	}
}