// The mace itself ----------------------------------------------------------

class HRpgMace : HereticWeapon replaces Mace
{
	Default
	{
		Weapon.SelectionOrder 1400;
		Weapon.AmmoUse 1;
		Weapon.AmmoGive1 50;
		Weapon.YAdjust 15;
		Weapon.AmmoType "MaceAmmo";
		Weapon.SisterWeapon "HRpgMacePowered";
		Inventory.PickupMessage "$TXT_WPNMACE";
		Tag "$TAG_MACE";
	}

	States
	{
	Spawn:
		WMCE A -1;
		Stop;
	Ready:
		MACE A 1 A_WeaponReady;
		Loop;
	Deselect:
		MACE A 1 A_Lower;
		Loop;
	Select:
		MACE A 1 A_Raise;
		Loop;
	Fire:
		MACE B 4;
	Hold:
		MACE CDEF 3 A_FireMacePL1;
		MACE C 4 A_ReFire;
		MACE DEFB 4;
		Goto Ready;
	AltFire:
		MMAC A 4 Offset(120, 40);
		MMAC B 4 Offset(100, 40) A_MaceMeleeAttack(random[StaffAttack](20, 50), "StaffPuff");
		MMAC C 4 Offset(80, 40);
		MMAC D 12 Offset(60, 40);
		MMAC D 2 A_ReFire;
		Goto Ready;
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_FireMacePL1
	//
	//----------------------------------------------------------------------------

	action void A_FireMacePL1()
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

		if (random[MaceAtk]() < 28)
		{
			Actor ball = Spawn("MaceFX2", Pos + (0, 0, 28 - Floorclip), ALLOW_REPLACE);
			if (ball != null)
			{
				ball.Vel.Z = 2 - clamp(tan(pitch), -5, 5);
				ball.target = self;
				ball.angle = self.angle;
				ball.AddZ(ball.Vel.Z);
				ball.VelFromAngle();
				ball.Vel += Vel.xy / 2;
				ball.A_StartSound ("weapons/maceshoot", CHAN_BODY);
				ball.CheckMissileSpawn (radius);
			}
		}
		else
		{
			let psp = player.GetPSprite(PSP_WEAPON);
			if (psp)
			{
				psp.x = random[MaceAtk](-2, 1);
				psp.y = WEAPONTOP + random[MaceAtk](0, 3);
			}
			Actor ball = SpawnPlayerMissile("MaceFX1", angle + (random[MaceAtk](-4, 3) * (360. / 256)));
			if (ball)
			{
				ball.special1 = 16; // tics till dropoff
			}
		}
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_MaceMeleeAttack
	//
	//----------------------------------------------------------------------------

	action void A_MaceMeleeAttack (int damage, class<Actor> puff)
	{
		FTranslatedLineTarget t;

		if (player == null)
		{
			return;
		}
		
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
		double slope = AimLineAttack (ang, DEFMELEERANGE);
		LineAttack (ang, DEFMELEERANGE, slope, damage, 'Melee', puff, true, t);
		if (t.linetarget)
		{
			//S_StartSound(player.mo, sfx_stfhit);
			// turn to face target
			angle = t.angleFromSource;
		}
	}
}

class HRpgMacePowered : HRpgMace replaces MacePowered
{
	Default
	{
		+WEAPON.POWERED_UP
		Weapon.AmmoUse 5;
		Weapon.AmmoGive 0;
		Weapon.SisterWeapon "HRpgMace";
		Tag "$TAG_MACEP";
	}

	States
	{
	Fire:
	Hold:	
		MACE B 4;
		MACE D 4 A_FireMacePL2;
		MACE B 4;
		MACE A 8 A_ReFire;
		Goto Ready;
	AltFire:
		MMAC A 4 Offset(120, 40);
		MMAC B 4 Offset(100, 40) A_MaceMeleeAttack(random[StaffAttack](40, 81), "StaffPuff2");
		MMAC C 4 Offset(80, 40);
		MMAC D 12 Offset(60, 40);
		MMAC D 2 A_ReFire;
		Goto Ready;
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_FireMacePL2
	//
	//----------------------------------------------------------------------------

	action void A_FireMacePL2()
	{
		FTranslatedLineTarget t;

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
		Actor mo = SpawnPlayerMissile ("MaceFX4", angle, pLineTarget:t);
		if (mo)
		{
			mo.Vel.xy += Vel.xy;
			mo.Vel.Z = 2 - clamp(tan(pitch), -5, 5);
			if (t.linetarget && !t.unlinked)
			{
				mo.tracer = t.linetarget;
			}
		}
		A_StartSound ("weapons/maceshoot", CHAN_WEAPON);
	}
}