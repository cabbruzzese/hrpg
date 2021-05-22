// Skull (Horn) Rod ---------------------------------------------------------

class HRpgSkullRod : HereticWeapon replaces SkullRod
{
	Default
	{
		Weapon.SelectionOrder 200;
		Weapon.AmmoUse1 1;
		Weapon.AmmoGive1 50;
		Weapon.YAdjust 15;
		Weapon.AmmoType1 "SkullRodAmmo";
		Weapon.SisterWeapon "HRpgSkullRodPowered";
		Inventory.PickupMessage "$TXT_WPNSKULLROD";
		Tag "$TAG_SKULLROD";
		Obituary "$OB_MPSKULLBASH";
	}

	States
	{
	Spawn:
		WSKL A -1;
		Stop;
	Ready:
		HROD A 1 A_WeaponReady;
		Loop;
	Deselect:
		HROD A 1 A_Lower;
		Loop;
	Select:
		HROD A 1 A_Raise;
		Loop;
	Fire:
		HROD AB 4 A_FireSkullRodPL1;
		HROD B 0 A_ReFire;
		Goto Ready;
	AltFire:
		HROD C 4 Offset(0, 80) A_ChargeForward(0, 0, 0, 5);
		HROD D 4 Offset(0, 60) A_ChargeForward(0, 0, 0, 15);
		HROD E 4 Offset(0, 40) A_ChargeForward(1, 500, random(8,13), 10);
		HROD F 4 Offset(0, 0) A_ChargeForward(1, 500, random(13,18), 5);
		HROD G 4 Offset(0, 0) A_ChargeForward(1, 500, random(18,23), 5);
		HROD FED 2;
		HROD C 2 A_ReFire;
		Goto Ready;
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_FireSkullRodPL1
	//
	//----------------------------------------------------------------------------

	action void A_FireSkullRodPL1()
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
		Actor mo = SpawnPlayerMissile ("HornRodFX1");
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
	
	action void A_ChargeForward(int attack, int kickback, int damage, int thrust)
	{
		Thrust(thrust, angle);
		
		if (attack)
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

			double slope = AimLineAttack (angle, DEFMELEERANGE * 1.1);
			
			kickbackSave = weapon.Kickback;
			weapon.Kickback = kickback;
			LineAttack (angle, DEFMELEERANGE * 1.1, slope, damage, 'Melee', "HornRodPuff", true, t);
			weapon.Kickback = kickbackSave;
			
			if (t.linetarget)
			{
				//S_StartSound(player.mo, sfx_stfhit);
				// turn to face target
				angle = t.angleFromSource;
			}
		}
	}
}

class HRpgSkullRodPowered : HRpgSkullRod replaces SkullRodPowered
{
	Default
	{
		+WEAPON.POWERED_UP
		Weapon.AmmoUse1 5;
		Weapon.AmmoGive1 0;
		Weapon.SisterWeapon "HRpgSkullRod";
		Tag "$TAG_SKULLRODP";
	}

	States
	{
	Fire:
		HROD C 2;
		HROD D 3;
		HROD E 2;
		HROD F 3;
		HROD G 4 A_FireSkullRodPL2;
		HROD F 2;
		HROD E 3;
		HROD D 2;
		HROD C 2 A_ReFire;
		Goto Ready;
	AltFire:
		HROD C 2;
		HROD D 2;
		HROD E 2;
		HROD F 2;
		HROD G 2 A_FireSkullRodPL3;
		HROD F 2;
		HROD E 2;
		HROD D 2;
		HROD C 2 A_ReFire;
		Goto Ready;
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_FireSkullRodPL2
	//
	// The special2 field holds the player number that shot the rain missile.
	// The special1 field holds the id of the rain sound.
	//
	//----------------------------------------------------------------------------

	action void A_FireSkullRodPL2()
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
		// Use MissileActor instead of the first return value from P_SpawnPlayerMissile 
		// because we need to give info to it, even if it exploded immediately.
		Actor mo, MissileActor;
		[mo, MissileActor] = SpawnPlayerMissile ("HornRodFX2", angle, pLineTarget: t);
		if (MissileActor != null)
		{
			if (t.linetarget && !t.unlinked)
			{
				MissileActor.tracer = t.linetarget;
			}
			MissileActor.A_StartSound ("weapons/hornrodpowshoot", CHAN_WEAPON);
		}
	}
	
	action void A_FireSkullRodPL3()
	{
		if (player == null)
		{
			return;
		}

		Weapon weapon = player.ReadyWeapon;
		if (weapon != null)
		{
			if (!weapon.DepleteAmmo (false))
				return;
		}
		SpawnPlayerMissile ("HornBallFX1", angle + 9);
		SpawnPlayerMissile ("HornBallFX1");
		SpawnPlayerMissile ("HornBallFX1", angle - 9);
	}
}

class HornRodPuff : Actor
{
	Default
	{
		RenderStyle "Translucent";
		Alpha 0.4;
		VSpeed 1;
		Scale 0.33;
		+NOBLOCKMAP
		+NOGRAVITY
		+PUFFONACTORS
		AttackSound "weapons/staffhit";
	}

	States
	{
	Spawn:
		FX00 HI 5 BRIGHT;
		FX00 JK 4 BRIGHT;
		FX00 LM 3 BRIGHT;
		Stop;
	}
}

class HornBallFX1 : Actor
{
	Default
	{
		Radius 10;
		Height 6;
		Speed 18;
		FastSpeed 24;
		Damage 10;
		Projectile;
		-ACTIVATEIMPACT
		-ACTIVATEPCROSS
		+ZDOOMTRANS
		RenderStyle "Add";
		Obituary "$OB_MPPHORNBALL";
	}

	States
	{
	Spawn:
		FX11 AB 6 BRIGHT;
		Loop;
	Death:
		FX11 CDEFG 5 BRIGHT;
		Stop;
	}
}