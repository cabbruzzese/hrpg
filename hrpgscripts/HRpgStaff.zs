// Staff --------------------------------------------------------------------

class HRpgStaff : HereticWeapon replaces Staff
{
	Default
	{
		Weapon.SelectionOrder 3800;
		-THRUGHOST
		-WEAPON.WIMPY_WEAPON
		+WEAPON.MELEEWEAPON
		Weapon.sisterweapon "HRpgStaffPowered";
		Obituary "$OB_MPSTAFF";
		Tag "$TAG_STAFF";
	}
	//VFBLA - VFBLB
	//FX10A - FX10G

	States
	{
	Ready:	
		STFF A 1 A_WeaponReady;
		Loop;
	Deselect:
		STFF A 1 A_Lower;
		Loop;
	Select:
		STFF A 1 A_Raise;
		Loop;
	Fire:
		STFF B 6;
		STFF C 8 A_StaffAttack(random[StaffAttack](5, 20), "StaffAttackPuff", 100);
		STFF B 8 A_ReFire;
		Goto Ready;
	AltFire:
		STFF B 6 Offset(140, 80);
		STFF B 3 Offset(100, 50);
		STFF C 2 Offset(60, 40);
		STFF C 1 Offset(20, 30);
		STFF C 1 Offset(-20, 20) A_StaffAttack(random[StaffAttack](25, 60), "StaffAttackPuff", 200);
		STFF C 1 Offset(-60, 10);
		STFF C 2 Offset(-100, 20);
		STFF C 2 Offset(-140, 30);
		STFF B 3 Offset(-140, 40);
		STFF B 14 Offset(-140, 50);
		STFF B 2 Offset(-140, 60) A_ReFire;
		Goto Ready;
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_StaffAttackPL1
	//
	//----------------------------------------------------------------------------

	action void A_StaffAttack (int damage, class<Actor> puff, int kickback, bool fireLightning = false)
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
			damage = hrpgPlayer.GetDamageForWeapon(damage);
			
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
			if (fireLightning)
				A_VerticalStaffFire(t.linetarget.Pos, t.linetarget);

			angle = t.angleFromSource;
		}
	}

	action void A_VerticalStaffFire(Vector3 newPos, actor strikeTarget)
	{
		let mo = StaffLightningMissile(SpawnPlayerMissile("StaffLightningMissile"));
		mo.strikeTarget = strikeTarget;
		double newz = mo.CurSector.HighestCeilingAt(mo.Pos.XY);
        mo.SetOrigin((newPos.X, newPos.Y, newz), false);
		mo.Vel.X = MinVel; // Force collision detection
        mo.Vel.Y = MinVel; // Force collision detection
		mo.Vel.Z = -15;

		mo.CheckMissileSpawn (radius);
	}
}

class HRpgStaffPowered : HRpgStaff replaces StaffPowered
{
	Default
	{
		Weapon.sisterweapon "HRpgStaff";
		Weapon.ReadySound "weapons/staffcrackle";
		-THRUGHOST
		+WEAPON.POWERED_UP
		+WEAPON.READYSNDHALF
		+WEAPON.STAFF2_KICKBACK
		-WEAPON.WIMPY_WEAPON
		Obituary "$OB_MPPSTAFF";
		Tag "$TAG_STAFFP";
	}

	States
	{
	Ready:	
		STFF DEF 4 A_WeaponReady;
		Loop;
	Deselect:
		STFF D 1 A_Lower;
		Loop;
	Select:
		STFF D 1 A_Raise;
		Loop;
	Fire:
		STFF G 6;
		STFF H 8 A_StaffAttack(random[StaffAttack](18, 81), "StaffPuff2", 150);
		STFF G 8 A_ReFire;
		Goto Ready;
	AltFire:
		STFF G 6 Offset(140, 80);
		STFF G 3 Offset(100, 50);
		STFF H 2 Offset(60, 40);
		STFF H 1 Offset(20, 30);
		STFF H 1 Offset(-20, 20) A_StaffLightningAttack();
		STFF H 1 Offset(-60, 10);
		STFF H 2 Offset(-100, 20);
		STFF H 2 Offset(-140, 30);
		STFF G 3 Offset(-140, 40);
		STFF G 14 Offset(-140, 50);
		STFF G 2 Offset(-140, 60) A_ReFire;
		Goto Ready;
	}

	action void A_StaffLightningAttack()
	{
		A_StaffAttack(random[StaffAttack](35, 81), "StaffAttackPuff2Small", 200, true);
	}
}

class StaffAttackPuff : StaffPuff
{
	Default
	{
		ActiveSound "mummy/attack1";
	}
}

class StaffAttackPuffSilent : StaffAttackPuff
{
	Default
	{
		ActiveSound "";
	}
}

class StaffAttackPuff2 : StaffPuff2
{
	Default
	{
		ActiveSound "mummy/attack1";
	}
}

class StaffAttackPuff2Silent : StaffAttackPuff2
{
	Default
	{
		ActiveSound "";
	}
}

class StaffAttackPuff2Small : StaffAttackPuff2
{
	Default
	{
		Scale 0.4;
	}
}

class StaffLightningMissile : Actor
{
	Actor strikeTarget;
	Default
	{
		Radius 10;
		Height 6;
		Speed 2;
		Damage 6;
		Projectile;
		-ACTIVATEIMPACT
		-ACTIVATEPCROSS
		+ZDOOMTRANS
		+RIPPER
		RenderStyle "Add";
		Obituary "$OB_MPPSTAFF";
		Scale 1;
	}

	States
	{
	Spawn:
		FX16 DDEEFF 1 Bright A_BlueSpark;
		Loop;
	Death:
		FX16 GH 2 BRIGHT;
		FX16 IJ 2 BRIGHT;
		FX16 IJ 2 BRIGHT;
		FX16 IJ 2 BRIGHT;
		FX16 KL 2 BRIGHT;
		Stop;
	}

	void A_BlueSpark ()
	{
		for (int i = 0; i < 2; i++)
		{
			Actor mo = Spawn("Sorcerer2FXSpark", pos, ALLOW_REPLACE);
			if (mo != null)
			{
				mo.Vel.X = Random2[BlueSpark]() / 128.;
				mo.Vel.Y = Random2[BlueSpark]() / 128.;
				mo.Vel.Z = 1. + Random[BlueSpark]() / 256.;
			}
		}
	}

	override void Tick()
	{
		if (strikeTarget)
			SetOrigin((strikeTarget.Pos.X, strikeTarget.Pos.Y, Pos.Z), true);

		Super.Tick();
	}
}