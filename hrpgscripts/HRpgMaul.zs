const MAUL_FLOOR_RADIUS = 80;
const MAUL_FLOOR_RADIUSDAMAGE = 50;
const MAUL_FLOOR_DAMAGE = 0;
const MAUL_MELEE_RANGE = DEFMELEERANGE * 2.0;

class HRpgMaul : HeathenWeapon
{
	Default
	{
		Weapon.SelectionOrder 800;
		Weapon.AmmoUse2 1;
		Weapon.AmmoGive2 2;
		Weapon.AmmoType2 "PhoenixRodAmmo";
		Weapon.SisterWeapon "HRpgMaulPowered";
		Weapon.YAdjust 15;
		Inventory.PickupMessage "$TXT_WPNMAUL";
		Tag "$TAG_MAUL";
		Obituary "$OB_MPMAUL";
	}

	States
	{
	Spawn:
		WMAL A -1;
		Stop;
	Ready:
		RMAL A 4 A_WeaponReady;
		Loop;
	Deselect:
		RMAL A 1 A_Lower;
		Loop;
	Select:
		RMAL A 1 A_Raise;
		Loop;
	Fire:
		RMAL B 18;
		RMAL C 2;
		RMAL D 2 A_HeathenMeleeAttack(random(50, 120), 125, "WarhammerPuff", MAUL_MELEE_RANGE);
		RMAL E 2;
		RMAL F 18;
		RMAL F 4 A_ReFire;
		Goto Ready;
	AltFire:
		RMAL B 0 Offset(1, WEAPONTOP);
		RMAL B 10 A_CheckAmmoOrMelee(AltFire);
		RMAL C 2 Offset(100, 0);
		RMAL D 2 Offset(120, 0);
		RMAL E 2 Offset(140, 0);
		RMAL F 26 Offset(160, 0) A_FireMaulFloorFire(0);
		RMAL F 4 A_ReFire;
		Goto Ready;
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_MaulSwingAttack
	//
	//----------------------------------------------------------------------------

	action void A_MaulSwingAttack (int damage, class<Actor> puff, int kickback, double swingangle)
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
			damage = hrpgPlayer.GetDamageForMelee(damage);

		//Scale up damage with berserk
		let berserk = Powerup(FindInventory("PowerStrength2"));
		if (berserk)
		{
			damage *= 2;
		}
			
		Weapon weapon = player.ReadyWeapon;
		if (weapon != null)
		{
			if (!weapon.DepleteAmmo (weapon.bAltFire))
				return;
		}
		
		double ang = angle + swingangle;
		double slope = AimLineAttack (ang, DEFMELEERANGE * 1.25);

		kickbackSave = weapon.Kickback;
		weapon.Kickback = kickback;
		LineAttack (ang, DEFMELEERANGE * 1.25, slope, damage, 'Melee', puff, true, t);
		weapon.Kickback = kickbackSave;
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_FireMaulFloorFire
	//
	//----------------------------------------------------------------------------
	action void A_FireMaulFloorFire(double angleMod)
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
		
		SpawnPlayerMissile ("MaulFloorFireFX2", angle + angleMod);
		
		A_StartSound("weapons/gauntletsuse", CHAN_WEAPON);
	}
}


class HRpgMaulPowered : HRpgMaul
{
	Default
	{
		+WEAPON.POWERED_UP
		Weapon.AmmoGive 0;
		Weapon.SisterWeapon "HRpgMaul";
		Tag "$TAG_MAUL";
		Obituary "$OB_MPPMAUL";
	}

	States
	{
	Spawn:
		WMAL A -1;
		Stop;
	Ready:
		RMAL A 4 A_WeaponReady;
		Loop;
	Deselect:
		RMAL A 1 A_Lower;
		Loop;
	Select:
		RMAL A 1 A_Raise;
		Loop;
	Fire:
		RMAL B 18;
		RMAL C 2;
		RMAL D 2 A_HeathenMeleeAttack(random(80, 180), 125, "MaulPoweredPuff", MAUL_MELEE_RANGE);
		RMAL E 2;
		RMAL F 18;
		RMAL F 4 A_ReFire;
		Goto Ready;
	AltFire:
		RMAL B 0 Offset(1, WEAPONTOP);
		RMAL B 10 A_CheckAmmoOrMelee(AltFire);
		RMAL C 2 Offset(100, 0);
		RMAL D 2 Offset(120, 0);
		RMAL E 2 Offset(140, 0);
		RMAL F 26 Offset(160, 0) A_FireMaulPoweredFloorFire();
		RMAL F 4 A_ReFire;
		Goto Ready;
	}
	
	action void A_FireMaulPoweredFloorFire()
	{
		A_FireMaulFloorFire(0);
		A_FireMaulFloorFire(9);
		A_FireMaulFloorFire(-9);
	}
}

class MaulPoweredPuff : Actor
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
		FX08 A 6 BRIGHT;// A_Explode;
		FX08 BC 5 BRIGHT;
		FX08 DEFGH 4 BRIGHT;
		Stop;
	}
}

class MaulFloorFireFX1 : Actor
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
		Obituary "$OB_MPMAULFLOORFIRE";
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

class MaulFloorFireFX2 : MaulFloorFireFX1
{
	Default
	{
		Radius 5;
		Height 12;
		Speed 24;
		FastSpeed 20;
		Damage MAUL_FLOOR_DAMAGE;
		+FLOORHUGGER
		RenderStyle "Add";
		
		+RIPPER
	}
	
	states
	{
	Spawn:
		FX13 AAAAAAAAA 4 Bright A_MaulFloorFire;
		Stop;
	Death:
		FX13 I 6 BRIGHT MaulFloorFireExplode;
		FX13 JKLM 6 BRIGHT;
		Stop;
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_MaulFloorFire
	//
	//----------------------------------------------------------------------------

	void A_MaulFloorFire()
	{
		SetZ(floorz);
		double x = Random2[MntrFloorFire]() / 64.;
		double y = Random2[MntrFloorFire]() / 64.;
		
		MaulFloorFireFX3 mo = MaulFloorFireFX3(Spawn("MaulFloorFireFX3", Vec2OffsetZ(x, y, floorz), ALLOW_REPLACE));
		if (mo != null)
		{
			mo.target = target;
			mo.Vel.X = MinVel; // Force block checking
			mo.CheckMissileSpawn (radius);
			mo.SetOrigin((mo.Pos.X, mo.Pos.Y, mo.Pos.Z + 2), false);
			
			mo.MaulFloorFireExplode();
		}
	}
	
	action void MaulFloorFireExplode()
	{
		A_Explode(MAUL_FLOOR_RADIUSDAMAGE, MAUL_FLOOR_RADIUS, 0);
	}
}

class MaulFloorFireFX3 : MaulFloorFireFX2
{
	Default
	{
		Radius 8;
		Height 16;
		Speed 0;
		Damage 0;
	}
	States
	{
	Spawn:
		FX13 IJKLM 6 BRIGHT;
		Stop;
	Death:
		FX13 M 1 BRIGHT;
		Stop;
	}
}