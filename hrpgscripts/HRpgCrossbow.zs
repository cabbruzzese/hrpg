// Crossbow -----------------------------------------------------------------

class HRpgCrossbow : HereticWeapon replaces Crossbow
{
	Default
	{
		Weapon.SelectionOrder 800;
		Weapon.AmmoUse 1;
		Weapon.AmmoGive 10;
		Weapon.AmmoType "CrossbowAmmo";
		Weapon.SisterWeapon "HRpgCrossbowPowered";
		Weapon.YAdjust 15;
		Inventory.PickupMessage "$TXT_WPNCROSSBOW";
		Tag "$TAG_CROSSBOW";
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
		CRBW C 4 Offset(-40, 40);
		CRBW C 4 Offset(-60, 50);
		CRBW C 4 Offset(-80, 60);
		CRBW C 12 Offset(-80, 60) A_FireBowAxe(false);
		CRBW C 4 Offset(-60, 50);
		CRBW C 4 Offset(-40, 40);
		CRBW C 4 Offset(-20, 40) A_ReFire;
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
	
	//----------------------------------------------------------------------------
	//
	// PROC A_FireBowAxe
	//
	//----------------------------------------------------------------------------

	action void A_FireBowAxe (bool powered)
	{
		if (player == null)
		{
			return;
		}
		
		if (powered)
		{
			Weapon weapon = player.ReadyWeapon;
			if (weapon != null)
			{
				if (!weapon.DepleteAmmo (false))
					return;
			}
		}

		let hrpgPlayer = HRpgPlayer(player.mo);
		if (powered)
		{
			let mo = SpawnPlayerMissile ("BowRedAxe");
			
			//Scale up damage with level
			if (hrpgPlayer != null)
			{
				hrpgPlayer.SetProjectileDamageForMagic(mo);
			}
		}
		else
		{
			let mo = SpawnPlayerMissile ("BowAxe");
			
			//Scale up damage with level
			if (hrpgPlayer != null && mo)
			{
				hrpgPlayer.SetProjectileDamageForWeapon(mo);
			}
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
		CRBW C 4 Offset(-40, 40);
		CRBW C 4 Offset(-60, 50);
		CRBW C 4 Offset(-80, 60);
		CRBW C 12 Offset(-80, 60) A_FireBowAxe(true);
		CRBW C 4 Offset(-60, 50);
		CRBW C 4 Offset(-40, 40);
		CRBW C 4 Offset(-20, 40) A_ReFire;
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

class BowAxe : Actor 
{
	Default
	{
		Radius 11;
		Height 8;
		Speed 9;
		Damage 4;
		Projectile;
		DeathSound "hknight/hit";
		Obituary "$OB_MPBOWAXE";
	}

	States
	{
	Spawn:
		SPAX A 3 BRIGHT A_StartSound("hknight/axewhoosh");
		SPAX BC 3 BRIGHT;
		SPAX A 3 BRIGHT A_StartSound("hknight/axewhoosh");
		SPAX BC 3 BRIGHT;
		SPAX A 3 BRIGHT A_StartSound("hknight/axewhoosh");
		SPAX BC 3 BRIGHT;
		Goto Death;
	Death:
		SPAX D 4 A_ChangeVelocity(0,0,0, CVF_REPLACE);
		SPAX EF 4 BRIGHT;
		Stop;
	}
}

class BowRedAxe : BowAxe 
{
	Default
	{
		Damage 20;
		Speed 9;
		Health 0;
		Obituary "$OB_MPPBOWAXE";
	}

	States
	{
	Spawn:
		RAXE AB 5 BRIGHT;
		RAXE AB 5 BRIGHT;
		RAXE A 5 BRIGHT A_DripBlood;
		RAXE B 5 BRIGHT;
		RAXE A 5 BRIGHT A_SplitAxe;
	Death:
		RAXE CDE 6 BRIGHT;
		Stop;
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_DripBlood
	//
	//----------------------------------------------------------------------------
	
	void A_DripBlood ()
	{
		double xo = random2[DripBlood]() / 32.0;
		double yo = random2[DripBlood]() / 32.0;
		Actor mo = Spawn ("Blood", Vec3Offset(xo, yo, 0.), ALLOW_REPLACE);
		if (mo != null)
		{
			mo.Vel.X = random2[DripBlood]() / 64.0;
			mo.Vel.Y = random2[DripBlood]() / 64.0;
			mo.Gravity = 1./8;
		}
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_SplitAxe
	//
	//----------------------------------------------------------------------------

	action void A_SplitAxe ()
	{
		if (target == null)
		{
			return;
		}
		
		//Maximum of 5 splits
		if (Health > 4)
			return;

		A_SplitAxeFire(angle + 7);
		A_SplitAxeFire(angle - 7);
	}
	
	action void A_SplitAxeFire(double angle)
	{
		if (target == null)
		{
			return;
		}
		
		let mo = target.SpawnPlayerMissile ("BowRedAxe", angle);
		if (mo != null)
		{
			mo.SetOrigin(Pos, false);
			mo.target = target;
			mo.A_SetPitch(pitch);
			mo.Vel.Z = Vel.Z;
			mo.A_SetHealth(Health + 1);
			mo.SetDamage(Damage);
		}
	}
}