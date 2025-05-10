// Staff --------------------------------------------------------------------

class HRpgStaff : HereticWeapon replaces Staff
{
	Default
	{
		Weapon.SelectionOrder 3800;
		+THRUGHOST
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
		STFF C 8 A_StaffAttack(random[StaffAttack](5, 20), "StaffPuff", 100);
		STFF B 8 A_ReFire;
		Goto Ready;
	AltFire:
		STFF B 2 Offset(140, 60);
		STFF B 2 Offset(100, 40);
		STFF B 2 Offset(60, 20);
		STFF B 2 Offset(20, 0) A_StaffAttack(random[StaffAttack](10, 30), "StaffPuff", 200);
		STFF B 2 Offset(-20, 20);
		STFF B 2 Offset(-60, 40);
		STFF B 2 Offset(-100, 60);
		STFF B 12 Offset(-140, 60);
		STFF B 2 Offset(-140, 60) A_ReFire;
		Goto Ready;
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_StaffAttackPL1
	//
	//----------------------------------------------------------------------------

	action void A_StaffAttack (int damage, class<Actor> puff, int kickback)
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
			//S_StartSound(player.mo, sfx_stfhit);
			// turn to face target
			angle = t.angleFromSource;
		}
	}
}

class HRpgStaffPowered : HRpgStaff replaces StaffPowered
{
	Default
	{
		Weapon.sisterweapon "HRpgStaff";
		Weapon.ReadySound "weapons/staffcrackle";
		+WEAPON.POWERED_UP
		+WEAPON.READYSNDHALF
		+WEAPON.STAFF2_KICKBACK
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
		STFF G 2 Offset(140, 60);
		STFF G 2 Offset(100, 40);
		STFF G 2 Offset(60, 20);
		STFF G 2 Offset(20, 0) A_StaffAttack(random[StaffAttack](30, 90), "StaffPuff2", 200);
		STFF G 2 Offset(-20, 20);
		STFF G 2 Offset(-60, 40);
		STFF G 2 Offset(-100, 60);
		STFF G 12 Offset(-140, 60);
		STFF G 2 Offset(-140, 60) A_ReFire;
		Goto Ready;
	}
}