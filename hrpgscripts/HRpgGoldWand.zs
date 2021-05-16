// Gold wand ----------------------------------------------------------------

class HRpgGoldWand : HereticWeapon replaces GoldWand
{
	Default
	{
		+BLOODSPLATTER
		Weapon.SelectionOrder 2000;
		Weapon.AmmoGive 25;
		Weapon.AmmoUse 1;
		Weapon.AmmoType "GoldWandAmmo";
		Weapon.SisterWeapon "HRpgGoldWandPowered";
		Weapon.YAdjust 5;
		Inventory.PickupMessage "$TXT_WPNGOLDWAND";
		Obituary "$OB_MPGOLDWAND";
		Tag "$TAG_GOLDWAND";
	}

	States
	{
	Spawn:
		GWAN A -1;
		Stop;
	Ready:
		GWND A 1 A_WeaponReady;
		Loop;
	Deselect:
		GWND A 1 A_Lower;
		Loop;
	Select:
		GWND A 1 A_Raise;
		Loop;
	Fire:
		GWND B 3;
		GWND C 5 A_FireGoldWandPL1;
		GWND D 3;
		GWND D 0 A_ReFire;
		Goto Ready;
	AltFire:
		STFF B 6;
		STFF C 8 A_WandStaffAttack(random[StaffAttack](5, 20), "StaffPuff", 100);
		STFF B 8 A_ReFire;
		Goto Ready;
	}
	

	//----------------------------------------------------------------------------
	//
	// PROC A_FireGoldWandPL1
	//
	//----------------------------------------------------------------------------

	action void A_FireGoldWandPL1 ()
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
		double pitch = BulletSlope();
		int damage = random[FireGoldWand](7, 14);
		double ang = angle;
		if (player.refire)
		{
			ang += Random2[FireGoldWand]() * (5.625 / 256);
		}
		LineAttack(ang, PLAYERMISSILERANGE, pitch, damage, 'Hitscan', "GoldWandPuff1");
		A_StartSound("weapons/wandhit", CHAN_WEAPON);
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_WandStaffAttackPL1
	//
	//----------------------------------------------------------------------------

	action void A_WandStaffAttack (int damage, class<Actor> puff, int kickback)
	{
		FTranslatedLineTarget t;
		int kickbackSave;

		if (player == null)
		{
			return;
		}
		
		//Scale up damage with level
		let hrpgPlayer = HRpgPlayer(player.mo);
		if (hrpgPlayer != null)
			damage *= hrpgPlayer.GetLevelMod();

		Weapon weapon = player.ReadyWeapon;
		if (weapon != null)
		{
			if (!weapon.DepleteAmmo (weapon.bAltFire))
				return;
		}
		double ang = angle + Random2[StaffAtk]() * (5.625 / 256);
		double slope = AimLineAttack (ang, DEFMELEERANGE * 1.25);
		
		kickbackSave = weapon.Kickback;
		weapon.Kickback = kickback;
		LineAttack (ang, DEFMELEERANGE * 1.25, slope, damage, 'Melee', puff, true, t);
		weapon.Kickback = kickbackSave;
		
		if (t.linetarget)
		{
			//S_StartSound(player.mo, sfx_stfhit);
			// turn to face target
			angle = t.angleFromSource;
		}
	}
	
}

class HRpgGoldWandPowered : HRpgGoldWand replaces GoldWandPowered
{
	Default
	{
		+WEAPON.POWERED_UP
		Weapon.AmmoGive 0;
		Weapon.SisterWeapon "HRpgGoldWand";
		Obituary "$OB_MPPGOLDWAND";
		Tag "$TAG_GOLDWANDP";
	}

	States
	{
	Fire:
		GWND B 3;
		GWND C 4 A_FireGoldWandPL2;
		GWND D 3;
		GWND D 0 A_ReFire;
		Goto Ready;
	AltFire:
		STFF G 6;
		STFF H 8 A_WandStaffAttack(random[StaffAttack](18, 81), "StaffPuff2", 100);
		STFF G 8 A_ReFire;
		Goto Ready;
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_FireGoldWandPL2
	//
	//----------------------------------------------------------------------------

	action void A_FireGoldWandPL2 ()
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
		double pitch = BulletSlope();

		double vz = -GetDefaultByType("GoldWandFX2").Speed * clamp(tan(pitch), -5, 5);
		SpawnMissileAngle("GoldWandFX2", angle - (45. / 8), vz);
		SpawnMissileAngle("GoldWandFX2", angle + (45. / 8), vz);
		double ang = angle - (45. / 8);
		for(int i = 0; i < 5; i++)
		{
			int damage = random[FireGoldWand](1, 8);
			LineAttack (ang, PLAYERMISSILERANGE, pitch, damage, 'Hitscan', "GoldWandPuff2");
			ang += ((45. / 8) * 2) / 4;
		}
		A_StartSound("weapons/wandhit", CHAN_WEAPON);
	}

	
}