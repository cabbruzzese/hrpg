const TRIDENT_MELEE_RANGE = DEFMELEERANGE * 1.2;

class HRpgTrident : HeathenWeapon
{
	Default
	{
		Weapon.SelectionOrder 800;
		Weapon.AmmoUse2 5;
		Weapon.AmmoGive2 50;
		Weapon.AmmoType2 "SkullRodAmmo";
		Weapon.SisterWeapon "HRpgTridentPowered";
		Weapon.YAdjust 15;
		Inventory.PickupMessage "$TXT_WPNTRIDENT";
		Tag "$TAG_TRIDENT";
		Obituary "$OB_MPTRIDENT";
	}

	States
	{
	Spawn:
		WTRD A -1;
		Stop;
	Ready:
		TRDT A 4 A_WeaponReady;
		Loop;
	Deselect:
		TRDT A 1 A_Lower;
		Loop;
	Select:
		TRDT A 1 A_Raise;
		Loop;
	Fire:
		TRDT A 4 Offset(0, 80) A_ChargeForward(0, 0, 0, 10);
		TRDT B 4 Offset(0, 60) A_ChargeForward(0, 0, 0, 15);
		TRDT C 4 Offset(0, 40) A_ChargeForward(1, 100, random(1,25), 0, "WarhammerPuff");
		TRDT C 4 Offset(0, 0) A_ChargeForward(1, 100, random(1,30), 0, "WarhammerPuffSilent", 2.0);
		TRDT C 4 Offset(0, 0) A_ChargeForward(1, 500, random(1,25), 0, "WarhammerPuffSilent");
		TRDT BA 2;
		TRDT A 2 A_ReFire;
		Goto Ready;
	AltFire:
		TRDT DE 4;
		TRDT FG 4;
		TRDT H 4 A_FireTridentPL1(0);
		TRDT H 0 A_ReFire;
		TRDT IJ 4;
		TRDT A 4;
		Goto Ready;
	AltHold:
		TRDT H 2;
		TRDT G 6;
		TRDT FG 4;
		TRDT H 4 A_FireTridentPL1(0);
		TRDT H 0 A_ReFire;
		TRDT IJ 4;
		TRDT A 4;
		Goto Ready;
	}
	
	action void A_ChargeForward(int attack, int kickback, int damage, int thrust, class<Actor> puff = "", float rangeMod = 1.0)
	{
		Thrust(thrust, angle);
		
		if (attack)
			A_HeathenMeleeAttack(damage, kickback, puff, TRIDENT_MELEE_RANGE * rangeMod, 0, true);
	}
	
	action void FireTridentProjectile(double andleMod)
	{
		Actor mo = SpawnPlayerMissile ("TridentFX1", angle + andleMod);
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
	//----------------------------------------------------------------------------
	//
	// PROC A_FireTridentPL1
	//
	//----------------------------------------------------------------------------

	action void A_FireTridentPL1(int powered)
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
		
		FireTridentProjectile(0);
		if (powered)
		{
			FireTridentProjectile(3);
			FireTridentProjectile(-3);
		}
	}
}


class HRpgTridentPowered : HRpgTrident
{
	Default
	{
		+WEAPON.POWERED_UP
		Weapon.AmmoGive 0;
		Weapon.SisterWeapon "HRpgTrident";
		Tag "$TAG_TRIDENT";
		Obituary "$OB_MPPTRIDENT";
	}

	States
	{
	Spawn:
		WTRD A -1;
		Stop;
	Ready:
		TRDT A 4 A_WeaponReady;
		Loop;
	Deselect:
		TRDT A 1 A_Lower;
		Loop;
	Select:
		TRDT A 1 A_Raise;
		Loop;
	Fire:
		TRDT A 4 Offset(0, 80) A_ChargeForward(0, 0, 0, 10);
		TRDT B 4 Offset(0, 60) A_ChargeForward(0, 0, 0, 15);
		TRDT C 4 Offset(0, 40) A_ChargeForward(1, 100, random(10,40), 0, "HornRodPuff");
		TRDT C 4 Offset(0, 0) A_ChargeForward(1, 100, random(10,50), 0, "HornRodPuff", 2.0);
		TRDT C 4 Offset(0, 0) A_ChargeForward(1, 500, random(10,40), 0, "HornRodPuff");
		TRDT BA 2;
		TRDT A 2 A_ReFire;
		Goto Ready;
	AltFire:
		TRDT DE 4;
		TRDT FG 4;
		TRDT H 4 A_FireTridentPL1(1);
		TRDT H 0 A_ReFire;
		TRDT IJ 4;
		TRDT A 4 A_ReFire;
		Goto Ready;
	AltHold:
		TRDT H 2;
		TRDT G 6;
		TRDT FG 4;
		TRDT H 4 A_FireTridentPL1(1);
		TRDT H 0 A_ReFire;
		TRDT IJ 4;
		TRDT A 4;
		Goto Ready;
	}
}

class TridentPoweredPuff : Actor
{
	Default
	{
		RenderStyle "Translucent";
		Alpha 0.4;
		VSpeed 1;
		+NOBLOCKMAP
		+NOGRAVITY
		+PUFFONACTORS
		AttackSound "weapons/staffpowerhit";
	}

	States
	{
	Spawn:
		RAXE CDE 6 BRIGHT;
		Stop;
	}
}

class TridentFX1 : Actor
{
	Default
	{
		Radius 12;
		Height 8;
		Speed 28;
		Damage 10;
		Projectile;
		+WINDTHRUST
		+ZDOOMTRANS
		-NOBLOCKMAP
		RenderStyle "Add";
		SeeSound "weapons/hornrodshoot";
		DeathSound "weapons/hornrodhit";
		Obituary "$OB_MPTRIDENT";
	}

	States
	{
	Spawn:
		FX00 CDEF 3 BRIGHT;
		Loop;
	Death:
		FX00 HIJKLM 2 BRIGHT;
		Stop;
	}
}