// Staff --------------------------------------------------------------------

class HRpgHammer : HereticWeapon
{
	Default
	{
		Weapon.SelectionOrder 3800;
		+WEAPON.MELEEWEAPON
		Weapon.sisterweapon "HRpgHammerPowered";
		Obituary "$OB_MPSTAFF";
		Tag "$TAG_STAFF";
		Scale 1.4;
	}

	States
	{
	Ready:	
		WARH D 1 A_WeaponReady;
		Loop;
	Deselect:
		WARH D 1 A_Lower;
		Loop;
	Select:
		WARH D 1 A_Raise;
		Loop;
	Fire:
		WARH B 4 Offset(170, 1);
		WARH C 4 Offset(90, 0);
		WARH D 4 Offset(10, 0) A_HammerAttack(random(20, 35), "WarhammerPuff", 175, 0);
		WARH E 2 Offset(-30, 0);
		WARH F 2 Offset(-50, 0);
		WARH G 10 Offset(-60, 0);
		WARH G 2 Offset(-60, 0) A_ReFire;
		Goto Ready;
	AltFire:
		WARH A 2 Offset(200, 1);
		WARH B 2 Offset(150, 0);
		WARH C 2 Offset(100, 0) A_HammerAttack(random(5, 15), "WarhammerPuff", 125, -20);
		WARH C 2 Offset(50, 0);
		WARH C 2 Offset(1, 0) A_HammerAttack(random(5, 20), "WarhammerPuff", 125, 0);
		WARH C 2 Offset(-50, 0);
		WARH C 2 Offset(-100, 0) A_HammerAttack(random(5, 15), "WarhammerPuff", 125, 20);
		WARH D 2 Offset(-150, 0);
		WARH D 2 Offset(-200, 0);
		WARH E 14 Offset(-225, 0);
		WARH F 2 Offset(-225, 0) A_ReFire;
		Goto Ready;
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_HammerAttack
	//
	//----------------------------------------------------------------------------

	action void A_HammerAttack (int damage, class<Actor> puff, int kickback, double swingangle)
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
}

class HRpgHammerPowered : HRpgHammer
{
	Default
	{
		Weapon.sisterweapon "HRpgHammer";
		+WEAPON.POWERED_UP
		+WEAPON.READYSNDHALF
		+WEAPON.STAFF2_KICKBACK
		Obituary "$OB_MPPSTAFF";
		Tag "$TAG_STAFFP";
	}

	States
	{
	Ready:	
		WARH K 1 A_WeaponReady;
		Loop;
	Deselect:
		WARH K 1 A_Lower;
		Loop;
	Select:
		WARH K 1 A_Raise;
		Loop;
	Fire:
		WARH I 4 Offset(170, 1);
		WARH J 4 Offset(90, 0);
		WARH K 4 Offset(10, 0) A_HammerAttack(random(45, 70), "WarhammerPuff2", 175, 0);
		WARH L 2 Offset(-30, 0);
		WARH M 2 Offset(-50, 0);
		WARH N 10 Offset(-60, 0);
		WARH N 2 Offset(-60, 0) A_ReFire;
		Goto Ready;
	AltFire:
		WARH H 2 Offset(200, 1);
		WARH I 2 Offset(150, 0);
		WARH J 2 Offset(100, 0) A_HammerFire(-20);
		WARH J 2 Offset(50, 0);
		WARH J 2 Offset(1, 0) A_HammerFire(0);
		WARH J 2 Offset(-50, 0);
		WARH J 2 Offset(-100, 0) A_HammerFire(20);
		WARH K 2 Offset(-150, 0);
		WARH K 2 Offset(-200, 0);
		WARH L 14 Offset(-225, 0);
		WARH M 2 Offset(-225, 0) A_ReFire;
		Goto Ready;
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_HammerFire
	//
	//----------------------------------------------------------------------------

	action void A_HammerFire (double fireAngle)
	{
		if (player == null)
		{
			return;
		}
		
		let hrpgPlayer = HRpgPlayer(player.mo);
		
		let mo = SpawnPlayerMissile ("WarhammerFx1", angle + fireAngle);
		
		//Scale up damage with level
		if (hrpgPlayer != null)
		{
			hrpgPlayer.SetProjectileDamageForWeapon(mo);
		}
	}
}

class WarhammerFx1 : Actor 
{
	Default
	{
		Radius 11;
		Height 8;
		Speed 14;
		Damage 18;
		Projectile;
		DeathSound "weapons/staffpowerhit";
		Obituary "$OB_MPCROSSBOW";
	}

	States
	{
	Spawn:
		FX05 DEFG 6 BRIGHT;
		Stop;
	Death:
		FX16 GHIJKL 4 BRIGHT;
		Stop;
	}
}

class WarhammerPuff : Actor
{
	Default
	{
		RenderStyle "Translucent";
		Alpha 0.4;
		VSpeed 1;
		+NOBLOCKMAP
		+NOGRAVITY
		+PUFFONACTORS
		AttackSound "mummy/attack2";
	}

	States
	{
	Spawn:
		PUF3 A 4 BRIGHT;
		PUF3 BCD 4;
		Stop;
	}
}

class WarhammerPuff2 : Actor
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
		FX16 GHIJKL 4 BRIGHT;
		Stop;
	}
}