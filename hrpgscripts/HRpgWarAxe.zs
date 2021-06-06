class HRpgWarAxe : HeathenWeapon
{
	Default
	{
		Weapon.SelectionOrder 800;
		Weapon.AmmoUse2 1;
		Weapon.AmmoGive2 10;
		Weapon.AmmoType2 "CrossbowAmmo";
		Weapon.SisterWeapon "HRpgWarAxePowered";
		Weapon.YAdjust 15;
		Inventory.PickupMessage "$TXT_WPNWARAXE";
		Tag "$TAG_WARAXE";
		Obituary "$OB_MPWARAXE";
	}

	States
	{
	Spawn:
		WAXE A -1;
		Stop;
	Ready:
		TAXE A 4 A_WeaponReady;
		Loop;
	Deselect:
		TAXE A 1 A_Lower;
		Loop;
	Select:
		TAXE A 1 A_Raise;
		Loop;
	Fire:
		TAXE B 8;
		TAXE C 4 A_AxeSwingAttack(random(12, 17), "WarhammerPuff", 125, -20);
		TAXE D 4 A_AxeSwingAttack(random(12, 25), "WarhammerPuff", 125, 0);
		TAXE E 4 A_AxeSwingAttack(random(12, 17), "WarhammerPuff", 125, 20);
		TAXE E 8;
		TAXE E 4 A_ReFire;
		Goto Ready;
	AltFire:
		TAXE B 8 OFFSET(0, 24);
		TAXE C 4 A_FireBowAxe(0);
		TAXE EEEEE 4 OFFSET(0, 100);
		TAXE E 4 A_ReFire;
		Goto Ready;
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_AxeSwingAttack
	//
	//----------------------------------------------------------------------------

	action void A_AxeSwingAttack (int damage, class<Actor> puff, int kickback, double swingangle)
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
	// PROC A_FireBowAxe
	//
	//----------------------------------------------------------------------------

	action void A_FireBowAxe (bool powered)
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


class HRpgWarAxePowered : HRpgWarAxe
{
	Default
	{
		+WEAPON.POWERED_UP
		Weapon.AmmoGive 0;
		Weapon.SisterWeapon "HRpgWarAxe";
		Tag "$TAG_WARAXE";
	}

	States
	{
	Spawn:
		WAXE A -1;
		Stop;
	Ready:
		TAXE A 4 A_WeaponReady;
		Loop;
	Deselect:
		TAXE A 1 A_Lower;
		Loop;
	Select:
		TAXE A 1 A_Raise;
		Loop;
	Fire:
		TAXE B 8;
		TAXE C 4 A_AxeSwingAttack(random(20, 30), "WarAxePoweredPuff", 175, -20);
		TAXE D 4 A_AxeSwingAttack(random(20, 40), "WarAxePoweredPuff", 175, 0);
		TAXE E 4 A_AxeSwingAttack(random(20, 30), "WarAxePoweredPuff", 175, 20);
		TAXE E 8;
		TAXE E 4 A_ReFire;
		Goto Ready;
	AltFire:
		TAXE B 8 OFFSET(0, 24);
		TAXE C 4 A_FireBowAxe(1);
		TAXE EEEEE 4 OFFSET(0, 100);
		TAXE E 4 A_ReFire;
		Goto Ready;
	}
}

class BowAxe : Actor 
{
	Default
	{
		Radius 11;
		Height 8;
		Speed 15;
		Damage 7;
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

class WarAxePoweredPuff : Actor
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