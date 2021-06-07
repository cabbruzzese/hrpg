// Blaster ------------------------------------------------------------------

class HRpgBlaster : NonHeathenWeapon replaces Blaster
{
	Default
	{
		+BLOODSPLATTER
		Weapon.SelectionOrder 500;
		Weapon.AmmoUse 1;
		Weapon.AmmoGive 30;
		Weapon.YAdjust 15;
		Weapon.AmmoType "BlasterAmmo";
		Weapon.SisterWeapon "HRpgBlasterPowered";
		Inventory.PickupMessage "$TXT_WPNBLASTER";
		Tag "$TAG_BLASTER";
		Obituary "$OB_MPBLASTER";
		
		HRpgWeapon.ExtraSpawnItem "HRpgFlail";
	}

	States
	{
	Spawn:
		WBLS A -1;
		Stop;
	Ready:
		BLSR A 1 A_WeaponReady;
		Loop;
	Deselect:
		BLSR A 1 A_Lower;
		Loop;
	Select:
		BLSR A 1 A_Raise;
		Loop;
	Fire:
		BLSR BC 3;
	Hold:
		BLSR D 2 A_FireBlasterPL1;
		BLSR CB 2;
		BLSR A 0 A_ReFire;
		Goto Ready;
	AltFire:
		BLSR BC 4 Offset(0, 20);
		BLSR D 8 Offset(0, 40) A_FireBlasterShotgun(0);
		BLSR C 20 Offset(0, 60);
		BLSR B 4 Offset(0, 40);
		BLSR A 2 Offset(0, 20);
		Goto Ready;
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_FireBlasterPL1
	//
	//----------------------------------------------------------------------------

	action void A_FireBlasterPL1(double angleSpread = 0.0, double pitchSpread = 0.0, bool useAmmo = true)
	{
		if (player == null)
		{
			return;
		}

		Weapon weapon = player.ReadyWeapon;
		if (weapon != null && useAmmo)
		{
			if (!weapon.DepleteAmmo (false))
			{
				weapon.CheckAmmo(Weapon.PrimaryFire, true);
				return;
			}
		}

		double pitch = BulletSlope();
		int damage = random[FireBlaster](1, 8) * 4;
		double ang = angle + angleSpread;
		double pitchRand = random(pitchSpread * -1.0, pitchSpread);
		if (player.refire)
		{
			ang += Random2[FireBlaster]() * (5.625 / 256);
		}
		
		//Scale up damage with level
		let hrpgPlayer = HRpgPlayer(player.mo);
		if (hrpgPlayer != null)
			damage = hrpgPlayer.GetDamageForWeapon(damage);
		
		LineAttack (ang, PLAYERMISSILERANGE, pitch + pitchRand, damage, 'Hitscan', "BlasterPuff");
		A_StartSound ("weapons/blastershoot", CHAN_WEAPON);
	}
	
	action void A_FireBlasterShotgun(int powered)
	{
		if (player == null)
		{
			return;
		}

		A_FireBlasterPL1(6, 1.0);
		A_FireBlasterPL1(3, 2.0);
		A_FireBlasterPL1(0, 3.0);
		A_FireBlasterPL1(-3, 2.0);
		A_FireBlasterPL1(-6, 1.0);
		
		if (powered)
		{
			Weapon weapon = player.ReadyWeapon;
			if (!weapon.CheckAmmo(Weapon.PrimaryFire, true))
				return;

			A_FireBlasterPL1(12, 1.0, false);
			A_FireBlasterPL1(8, 3.0, false);
			A_FireBlasterPL1(4, 5.0, false);
			A_FireBlasterPL1(0, 7.0, false);
			A_FireBlasterPL1(-4, 5.0, false);
			A_FireBlasterPL1(-8, 3.0, false);
			A_FireBlasterPL1(-12, 1.0, false);
		}
	}
}

class HRpgBlasterPowered : HRpgBlaster replaces BlasterPowered
{
	Default
	{
		+WEAPON.POWERED_UP
		Weapon.AmmoUse 5;
		Weapon.AmmoGive 0;
		Weapon.SisterWeapon "HRpgBlaster";
		Tag "$TAG_BLASTERP";
	}

	States
	{
	Fire:
		BLSR BC 0;
	Hold:
		BLSR D 3 A_FireProjectile("BlasterFX1");
		BLSR CB 4;
		BLSR A 0 A_ReFire;
		Goto Ready;
	AltFire:
		BLSR B 4 Offset(0, 20);
		BLSR C 8 Offset(0, 40) A_FireBlasterShotgun(1);
		BLSR C 24 Offset(0, 60);
		BLSR B 4 Offset(0, 40);
		BLSR A 2 Offset(0, 20);
		Goto Ready;
	}
}