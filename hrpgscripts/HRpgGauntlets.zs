// Gauntlets ----------------------------------------------------------------
const MAXMAGICMISSILES = 9;

class HRpgGauntlets : Weapon replaces Gauntlets
{
	Default
	{
		+BLOODSPLATTER
		Weapon.SelectionOrder 2300;
		+WEAPON.WIMPY_WEAPON
		+WEAPON.MELEEWEAPON
		Weapon.Kickback 0;
		Weapon.YAdjust 15;
		Weapon.UpSound "weapons/gauntletsactivate";
		Weapon.SisterWeapon "HRpgGauntletsPowered";
		Inventory.PickupMessage "$TXT_WPNGAUNTLETS";
		Tag "$TAG_GAUNTLETS";
		Obituary "$OB_MPGAUNTLETS";
	}

	States
	{
	Spawn:
		WGNT A -1;
		Stop;
	Ready:
		GAUN A 1 A_WeaponReady;
		Loop;
	Deselect:
		GAUN A 1 A_Lower;
		Loop;
	Select:
		GAUN A 1 A_Raise;
		Loop;
	Fire:
		GAUN B 4 A_StartSound("weapons/gauntletsuse", CHAN_WEAPON);
		GAUN C 4;
	Hold:
		GAUN DEF 4 BRIGHT A_GauntletAttack(0, 0);
		GAUN C 4 A_ReFire;
		GAUN B 4 A_Light0;
		Goto Ready;
	AltFire:
		GAUN L 4 BRIGHT;
		GAUN M 4 BRIGHT A_GauntletAttack2(400);
		GAUN N 4 BRIGHT;
		GAUN K 6;
		GAUN J 6 A_Light0;
		GAUN A 12 A_ReFire;
		Goto Ready;
	}
	
	//---------------------------------------------------------------------------
	//
	// PROC A_GauntletAttack
	//
	//---------------------------------------------------------------------------

	action void A_GauntletAttack (int power, int kickback)
	{
		int damage;
		double dist;
		Class<Actor> pufftype;
		FTranslatedLineTarget t;
		int actualdamage = 0;
		Actor puff;
		int kickbackSave;

		if (player == null)
		{
			return;
		}
		
		Weapon weapon = player.ReadyWeapon;
		if (weapon != null)
		{
			if (!weapon.DepleteAmmo (weapon.bAltFire))
				return;
			
			let psp = player.GetPSprite(PSP_WEAPON);
			if (psp)
			{
				psp.x = ((random[GauntletAtk](0, 3)) - 2);
				psp.y = WEAPONTOP + (random[GauntletAtk](0, 3));
			}
		}
		
		double ang = angle;
		if (power)
		{
			damage = random[GauntletAtk](1, 8) * 2;
			dist = 4*DEFMELEERANGE;
			ang += random2[GauntletAtk]() * (2.8125 / 256);
			pufftype = "GauntletPuff2";
		}
		else
		{
			damage = random[GauntletAtk](1, 8) * 2;
			dist = SAWRANGE;
			ang += random2[GauntletAtk]() * (5.625 / 256);
			pufftype = "GauntletPuff1";
		}
		
		//Scale up damage with level
		let hrpgPlayer = HRpgPlayer(player.mo);
		if (hrpgPlayer != null)
			damage = hrpgPlayer.GetDamageForMagic(damage);

		double slope = AimLineAttack (ang, dist);
		
		kickbackSave = weapon.Kickback;
		weapon.Kickback = kickback;
		[puff, actualdamage] = LineAttack (ang, dist, slope, damage, 'Melee', pufftype, false, t);
		weapon.Kickback = kickbackSave;
		if (!t.linetarget)
		{
			if (random[GauntletAtk]() > 64)
			{
				player.extralight = !player.extralight;
			}
			A_StartSound ("weapons/gauntletson", CHAN_AUTO);
			return;
		}
		int randVal = random[GauntletAtk]();
		if (randVal < 64)
		{
			player.extralight = 0;
		}
		else if (randVal < 160)
		{
			player.extralight = 1;
		}
		else
		{
			player.extralight = 2;
		}
		if (power)
		{
			if (!t.linetarget.bDontDrain) GiveBody (actualdamage >> 1);
			A_StartSound ("weapons/gauntletspowhit", CHAN_AUTO);
		}
		else
		{
			A_StartSound ("weapons/gauntletshit", CHAN_AUTO);
		}
		
		// turn to face target
		ang = t.angleFromSource;
		double anglediff = deltaangle(angle, ang);

		if (anglediff < 0.0)
		{
			if (anglediff < -4.5)
				angle = ang + 90.0 / 21;
			else
				angle -= 4.5;
		}
		else
		{
			if (anglediff > 4.5)
				angle = ang - 90.0 / 21;
			else
				angle += 4.5;
		}
		bJustAttacked = true;
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_GauntletAttack2
	//
	//----------------------------------------------------------------------------

	action void A_GauntletAttack2 (int kickback)
	{
		int kickbackSave;
		FTranslatedLineTarget t;
		int damage;

		if (player == null)
		{
			return;
		}
		
		class<Actor> puff = "GauntletPuff3";
		damage = random[StaffAtk](10, 30);
		
		//Scale up damage with level
		let hrpgPlayer = HRpgPlayer(player.mo);
		if (hrpgPlayer != null)
			damage = hrpgPlayer.GetDamageForMagic(damage);

		Weapon weapon = player.ReadyWeapon;
		if (weapon != null)
		{
			if (!weapon.DepleteAmmo (weapon.bAltFire))
				return;
		}
		double ang = angle + Random2[StaffAtk]() * (5.625 / 256);
		double slope = AimLineAttack (ang, DEFMELEERANGE);

		kickbackSave = weapon.Kickback;
		weapon.Kickback = kickback;
		LineAttack (ang, DEFMELEERANGE, slope, damage, 'Melee', puff, true, t);
		weapon.Kickback = kickbackSave;


		if (t.linetarget)
		{
			//S_StartSound(player.mo, sfx_stfhit);
			// turn to face target
			angle = t.angleFromSource;
		}
	}
}


class HRpgGauntletsPowered : HRpgGauntlets replaces GauntletsPowered
{
	Default
	{
		+WEAPON.POWERED_UP
		Tag "$TAG_GAUNTLETSP";
		Obituary "$OB_MPPGAUNTLETS";
		Weapon.SisterWeapon "HRpgGauntlets";
	}

	States
	{
	Ready:
		GAUN GHI 4 A_WeaponReady;
		Loop;
	Deselect:
		GAUN G 1 A_Lower;
		Loop;
	Select:
		GAUN G 1 A_Raise;
		Loop;
	Fire:
		GAUN J 4 A_StartSound("weapons/gauntletsuse", CHAN_WEAPON);
		GAUN K 4;
	Hold:
		GAUN LMN 4 BRIGHT A_GauntletAttack(1, 0);
		GAUN K 4 A_ReFire;
		GAUN J 4 A_Light0;
		Goto Ready;
	AltFire:
		GAUN D 4;
		GAUN E 4 BRIGHT A_GauntletFireBolts();
		GAUN F 4;
		GAUN C 6;
		GAUN B 6 A_Light0;
		GAUN A 12 A_ReFire;
		Goto Ready;
	}
	
	action void A_GauntletFireBolt (int spread)
	{
		if (player == null)
		{
			return;
		}
		
		let rangle = random[GauntletAtk](spread * -1, spread);
		let mo = SpawnPlayerMissile ("GauntletFX3", angle + rangle);
		
		let hrpgPlayer = HRpgPlayer(player.mo);
		if (hrpgPlayer != null)
		{
			hrpgPlayer.SetProjectileDamageForMagic(mo);
		}
	}
	
	action void A_GauntletFireBolts ()
	{
		int magicMissileCount = 3;
		
		if (player == null)
		{
			return;
		}
		
		//Scale up damage with level
		let hrpgPlayer = HRpgPlayer(player.mo);
		if (hrpgPlayer != null)
		{
			int spellLevel = hrpgPlayer.Crp / 5;
			if (spellLevel > magicMissileCount)
				magicMissileCount = spellLevel;
			
			if (magicMissileCount > MAXMAGICMISSILES)
				magicMissileCount = MAXMAGICMISSILES;
		}
		
		for (int i = 0; i < magicMissileCount; i++)
		{
			A_GauntletFireBolt(3 + magicMissileCount);
		}
	}
}

class GauntletPuff3 : Actor
{
	Default
	{
		+NOBLOCKMAP
		+NOGRAVITY
		+PUFFONACTORS
		RenderStyle "Translucent";
		Alpha 0.4;
		VSpeed 0.8;
	}

	States
	{
	Spawn:
		FX00 HIJKLM 4 BRIGHT;
		Stop;
	}
}

// Crossbow FX3 -------------------------------------------------------------

class GauntletFX3 : CrossbowFX1
{
	Default
	{
		Speed 20;
		Damage 2;
		SeeSound "";
		-NOBLOCKMAP
		+WINDTHRUST
		+THRUGHOST
		Obituary "$OB_MPPMAGICMISSILE";
	}

	States
	{
	Spawn:
		FX03 A 1 BRIGHT;
		Loop;
	Death:
		FX03 CDE 8 BRIGHT;
		Stop;
	}
}