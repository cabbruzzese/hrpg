// Phoenix Rod --------------------------------------------------------------

class HRpgPhoenixRod : Weapon replaces PhoenixRod
{
	Default
	{
		+WEAPON.NOAUTOFIRE
		Weapon.SelectionOrder 2600;
		Weapon.Kickback 150;
		Weapon.YAdjust 15;
		Weapon.AmmoUse 1;
		Weapon.AmmoGive 2;
		Weapon.AmmoType "PhoenixRodAmmo";
		Weapon.Sisterweapon "HRpgPhoenixRodPowered";
		Inventory.PickupMessage "$TXT_WPNPHOENIXROD";
		Tag "$TAG_PHOENIXROD";
	}

	States
	{
	Spawn:
		WPHX A -1;
		Stop;
	Ready:
		PHNX A 1 A_WeaponReady;
		Loop;
	Deselect:
		PHNX A 1 A_Lower;
		Loop;
	Select:
		PHNX A 1 A_Raise;
		Loop;
	Fire:
		PHNX B 5;
		PHNX C 7 A_FirePhoenixPL1;
		PHNX DB 4;
		PHNX B 0 A_ReFire;
		Goto Ready;
	AltFire:
		PHNX B 7;
		PHNX C 10 A_FirePhoenixFloorFire;
		PHNX DB 6;
		PHNX B 0 A_ReFire;
		Goto Ready;
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_FirePhoenixPL1
	//
	//----------------------------------------------------------------------------

	action void A_FirePhoenixPL1()
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
		
		let mo = SpawnPlayerMissile ("PhoenixFX1");
		
		//Scale up damage with level
		let hrpgPlayer = HRpgPlayer(player.mo);
		if (hrpgPlayer != null)
		{
			hrpgPlayer.SetProjectileDamageForMagic(mo);
		}
		
		Thrust(4, angle + 180);
	}

	//----------------------------------------------------------------------------
	//
	// PROC A_FirePhoenixFloorFire
	//
	//----------------------------------------------------------------------------

	action void A_FirePhoenixFloorFire()
	{
		if (player == null)
		{
			return;
		}

		A_StartSound ("weapons/phoenixpowshoot", CHAN_VOICE);

		SpawnPlayerMissile ("PhoenixFloorFireFX2", angle + 3.5);
		SpawnPlayerMissile ("PhoenixFloorFireFX2");
		SpawnPlayerMissile ("PhoenixFloorFireFX2", angle - 3.5);
	}
}

class HRpgPhoenixRodPowered : HRpgPhoenixRod replaces PhoenixRodPowered
{
	const FLAME_THROWER_TICS = (10*TICRATE);
	
	private int FlameCount;		// for flamethrower duration
	
	Default
	{
		+WEAPON.POWERED_UP
		Weapon.SisterWeapon "HRpgPhoenixRod";
		Weapon.AmmoGive 0;
		Tag "$TAG_PHOENIXRODP";
	}

	States
	{
	Fire:
		PHNX B 3 A_InitPhoenixPL2;
	Hold:
		PHNX C 1 A_FirePhoenixPL2;
		PHNX B 4 A_ReFire;
	Powerdown:
		PHNX B 4 A_ShutdownPhoenixPL2;
		Goto Ready;
	AltFire:
		PHNX B 7;
		PHNX C 2 A_FirePhoenixFireball(13.5, 1);
		PHNX C 2 A_FirePhoenixFireball(9, 0);
		PHNX C 2 A_FirePhoenixFireball(4.5, 0);
		PHNX C 2 A_FirePhoenixFireball(0, 0);
		PHNX C 2 A_FirePhoenixFireball(-4.5, 0);
		PHNX C 2 A_FirePhoenixFireball(-9, 0);
		PHNX C 2 A_FirePhoenixFireball(-13.5, 0);
		PHNX DB 4;
		PHNX B 0 A_ReFire;
		Goto Ready;
	}
	

	override void EndPowerup ()
	{
		DepleteAmmo (bAltFire);
		Owner.player.refire = 0;
		Owner.A_StopSound (CHAN_WEAPON);
		Owner.player.ReadyWeapon = SisterWeapon;
		Owner.player.SetPsprite(PSP_WEAPON, SisterWeapon.GetReadyState());
	}

	//----------------------------------------------------------------------------
	//
	// PROC A_InitPhoenixPL2
	//
	//----------------------------------------------------------------------------

	action void A_InitPhoenixPL2()
	{
		if (player != null)
		{
			HRpgPhoenixRodPowered flamethrower = HRpgPhoenixRodPowered(player.ReadyWeapon);
			if (flamethrower != null)
			{
				flamethrower.FlameCount = FLAME_THROWER_TICS;
			}
		}
	}

	//----------------------------------------------------------------------------
	//
	// PROC A_FirePhoenixPL2
	//
	// Flame thrower effect.
	//
	//----------------------------------------------------------------------------

	action void A_FirePhoenixPL2()
	{
		if (player == null)
		{
			return;
		}

		HRpgPhoenixRodPowered flamethrower = HRpgPhoenixRodPowered(player.ReadyWeapon);
		
		if (flamethrower == null || --flamethrower.FlameCount == 0)
		{ // Out of flame
			player.SetPsprite(PSP_WEAPON, flamethrower.FindState("Powerdown"));
			player.refire = 0;
			A_StopSound (CHAN_WEAPON);
			return;
		}

		double slope = -clamp(tan(pitch), -5, 5);
		double xo = Random2[FirePhoenixPL2]() / 128.;
		double yo = Random2[FirePhoenixPL2]() / 128.;
		Vector3 spawnpos = Vec3Offset(xo, yo, 26 + slope - Floorclip);

		slope += 0.1;
		Actor mo = Spawn("PhoenixFX2", spawnpos, ALLOW_REPLACE);
		if (mo != null)
		{
			mo.target = self;
			mo.Angle = Angle;
			mo.VelFromAngle();
			mo.Vel.XY += Vel.XY;
			mo.Vel.Z = mo.Speed * slope;
			mo.CheckMissileSpawn (radius);
			
			//Scale damage for level
			let hrpgPlayer = HRpgPlayer(player.mo);
			if (hrpgPlayer != null)
			{
				hrpgPlayer.SetProjectileDamageForMagic(mo);
			}
		}
		if (!player.refire)
		{
			A_StartSound("weapons/phoenixpowshoot", CHAN_WEAPON, CHANF_LOOPING);
		}	
	}

	//----------------------------------------------------------------------------
	//
	// PROC A_ShutdownPhoenixPL2
	//
	//----------------------------------------------------------------------------

	action void A_ShutdownPhoenixPL2()
	{
		if (player == null)
		{
			return;
		}
		A_StopSound (CHAN_WEAPON);
		Weapon weapon = player.ReadyWeapon;
		if (weapon != null)
		{
			weapon.DepleteAmmo (weapon.bAltFire);
		}
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_FirePhoenixFireballs
	//
	//----------------------------------------------------------------------------

	action void A_FirePhoenixFireball(double angleMod, int depletes)
	{
		if (player == null)
		{
			return;
		}

		Weapon weapon = player.ReadyWeapon;
		if (weapon != null && depletes)
		{
			if (!weapon.DepleteAmmo (false))
				return;
		}
		let mo = SpawnPlayerMissile ("PhoenixFireballFX1", angle + angleMod);
		
		//Scale up damage with level
		let hrpgPlayer = HRpgPlayer(player.mo);
		if (hrpgPlayer != null)
		{
			hrpgPlayer.SetProjectileDamageForMagic(mo);
		}
	}
}

class PhoenixFireballFX1 : Actor
{
	Default
	{
		Radius 10;
		Height 6;
		Speed 20;
		FastSpeed 26;
		Damage 5;
		DamageType "Fire";
		Projectile;
		-ACTIVATEIMPACT
		-ACTIVATEPCROSS
		+ZDOOMTRANS
		RenderStyle "Add";
		ExplosionDamage 30;
		DeathSound "minotaur/fx2hit";
	}
	States
	{
	Spawn:
		FX12 AB 6 Bright;
		Loop;
	Death:
		FX13 I 4 Bright A_Explode;
		FX13 JKLM 4 Bright;
		Stop;
	}
}

class PhoenixFloorFireFX1 : Actor
{
	Default
	{
		Radius 10;
		Height 6;
		Speed 20;
		FastSpeed 26;
		Damage 3;
		DamageType "Fire";
		Projectile;
		-ACTIVATEIMPACT
		-ACTIVATEPCROSS
		+ZDOOMTRANS
		RenderStyle "Add";
	}
	States
	{
	Spawn:
		FX12 AB 6 Bright;
		Loop;
	Death:
		FX12 CDEFGH 5 Bright;
		Stop;
	}
}

class PhoenixFloorFireFX2 : PhoenixFloorFireFX1
{
	Default
	{
		Radius 5;
		Height 12;
		Speed 14;
		FastSpeed 20;
		Damage 1;
		+FLOORHUGGER
		RenderStyle "Add";
	}
	
	states
	{
	Spawn:
		FX13 AAAAAAA 2 Bright A_PhoenixFloorFire;
		Stop;
	Death:
		FX13 BCDE 5 Bright;
		FX13 FGH 4 Bright;
		Stop;
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_PhoenixFloorFire
	//
	//----------------------------------------------------------------------------

	void A_PhoenixFloorFire()
	{
		SetZ(floorz);
		double x = Random2[MntrFloorFire]() / 64.;
		double y = Random2[MntrFloorFire]() / 64.;
		
		Actor mo = Spawn("PhoenixFloorFireFX3", Vec2OffsetZ(x, y, floorz), ALLOW_REPLACE);
		if (mo != null)
		{
			mo.target = target;
			mo.Vel.X = MinVel; // Force block checking
			mo.CheckMissileSpawn (radius);
			
			//Scale up damage with level
			let hrpgPlayer = HRpgPlayer(target);
			if (hrpgPlayer != null)
			{
				hrpgPlayer.SetProjectileDamageForMagic(mo);
			}
		}
	}
}

class PhoenixFloorFireFX3 : PhoenixFloorFireFX2
{
	Default
	{
		Radius 8;
		Height 16;
		Speed 0;
	}
	States
	{
	Spawn:
		FX13 BCDE 5 Bright;
		FX13 FGH 4 Bright;
		Stop;
	}
}