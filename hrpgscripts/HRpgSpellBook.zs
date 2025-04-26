const FIREBALLSPREAD_X = 4;
const FIREBALLSPREAD_Y = 0.3;

class HRpgSpellBook : BlasphemerWeapon
{
	Default
	{
		+BLOODSPLATTER
		Weapon.SelectionOrder 2100;
		Weapon.SisterWeapon "HRpgSpellBookPowered";
		Weapon.YAdjust 5;
		Inventory.PickupMessage "$TXT_WPNGOLDWAND";
		Tag "$TAG_SPELLBOOK";
	}

	States
	{
	Spawn:
		SPBO A -1;
		Stop;
	Ready:
		SPBO A 1 A_WeaponReady;
		Loop;
	Deselect:
		SPBO A 1 A_Lower;
		Loop;
	Select:
		SPBO A 1 A_Raise;
		Loop;
	Fire:
		SPBO B 4;
		SPBO C 4;
		SPBO D 5;
		SPBO E 3 A_FireSpellbookPL2(0);
		SPBO D 3;
		SPBO C 3;
		SPBO B 2 A_ReFire;
		SPBO B 6;
		Goto Ready;
	Hold:
		SPBO DDD 4 A_Jump(64, "JumpFire");
	JumpFire:
		SPBO E 3 A_FireSpellbookPL2(0);
		SPBO D 3;
		SPBO C 3;
		SPBO B 2 A_ReFire;
		SPBO B 6;
		Goto Ready;
	AltFire:
		SPBO F 4;
		SPBO G 4;
		SPBO H 4;
		SPBO I 6 A_FireSpellbookPL1(0);
		SPBO H 4;
		SPBO G 4;
		SPBO F 2;
		SPBO F 2 A_ReFire;
		Goto Ready;
	}
	

	action void A_SpellbookIceBall (double spread, double velZ)
	{
		if (player == null)
		{
			return;
		}
		
		let mo = SpawnPlayerMissile ("SpellbookFx1", angle + spread);
		
		if (mo != null)
		{
			mo.Vel.Z += velZ;
		}

		let hrpgPlayer = HRpgPlayer(player.mo);
		if (hrpgPlayer != null)
		{
			hrpgPlayer.SetProjectileDamageForMagic(mo);
		}
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_FireSpellbookPL1
	//
	//----------------------------------------------------------------------------
	
	action void A_FireSpellbookPL1 (int powered)
	{
		if (player == null)
		{
			return;
		}
		
		A_SpellbookIceBall(FIREBALLSPREAD_X * 3, 0);
		A_SpellbookIceBall(FIREBALLSPREAD_X, FIREBALLSPREAD_Y * 2);
		A_SpellbookIceBall(FIREBALLSPREAD_X, FIREBALLSPREAD_Y * -2);
		A_SpellbookIceBall(FIREBALLSPREAD_X * -1, FIREBALLSPREAD_Y * 2);
		A_SpellbookIceBall(FIREBALLSPREAD_X * -1, FIREBALLSPREAD_Y * -2);
		A_SpellbookIceBall(FIREBALLSPREAD_X * -3, 0);
		
		if (powered)
		{
			A_SpellbookIceBall(FIREBALLSPREAD_X * 5, 0);
			A_SpellbookIceBall(FIREBALLSPREAD_X * 3, FIREBALLSPREAD_Y * 3);
			A_SpellbookIceBall(FIREBALLSPREAD_X * 3, FIREBALLSPREAD_Y * -3);
			A_SpellbookIceBall(0, FIREBALLSPREAD_Y * 4);
			A_SpellbookIceBall(0, FIREBALLSPREAD_Y * -4);
			A_SpellbookIceBall(FIREBALLSPREAD_X * -3, FIREBALLSPREAD_Y * 3);
			A_SpellbookIceBall(FIREBALLSPREAD_X * -3, FIREBALLSPREAD_Y * -3);
			A_SpellbookIceBall(FIREBALLSPREAD_X * -5, 0);
		}
	}
	
	action void A_SpellbookFireBlast ()
	{
		if (player == null)
		{
			return;
		}
		
		let randx = random(0, 20) - 10;
		let randy = random(0, 20) - 10;
		let mo = SpawnPlayerMissile ("SpellbookFx2", 1e37, randx, randy);
		
		let hrpgPlayer = HRpgPlayer(player.mo);
		if (hrpgPlayer != null)
		{
			hrpgPlayer.SetProjectileDamageForMagic(mo);
		}
	}
	action void A_FireSpellbookPL2 (int powered)
	{
		if (player == null)
		{
			return;
		}
		
		A_SpellbookFireBlast();
		if (powered)
		{
			A_SpellbookFireBlast();
			A_SpellbookFireBlast();
		}
	}
}

class HRpgSpellBookPowered : HRpgSpellBook
{
	Default
	{
		+WEAPON.POWERED_UP
		Weapon.SisterWeapon "HRpgSpellBook";
		Tag "$TAG_SPELLBOOK";
	}

	States
	{
	Spawn:
		SPBO J -1;
		Stop;
	Ready:
		SPBO J 1 A_WeaponReady;
		Loop;
	Deselect:
		SPBO J 1 A_Lower;
		Loop;
	Select:
		SPBO J 1 A_Raise;
		Loop;
	Fire:
		SPBO B 4;
		SPBO C 4;
		SPBO D 5;
		SPBO E 3 A_FireSpellbookPL2(1);
		SPBO D 3;
		SPBO C 3;
		SPBO B 2 A_ReFire;
		SPBO B 6;
		Goto Ready;
	Hold:
		SPBO DDD 4 A_Jump(64, "JumpFire");
	JumpFire:
		SPBO E 3 A_FireSpellbookPL2(1);
		SPBO D 3;
		SPBO C 3;
		SPBO B 2 A_ReFire;
		SPBO B 6;
		Goto Ready;
	AltFire:
		SPBO F 4;
		SPBO G 4;
		SPBO H 4;
		SPBO I 6 A_FireSpellbookPL1(1);
		SPBO H 4;
		SPBO G 4;
		SPBO F 2;
		SPBO F 2 A_ReFire;
		Goto Ready;
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_FireGoldWandPL2
	//
	//----------------------------------------------------------------------------

	action void A_FireGoldWandPL2 ()
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
		double pitch = BulletSlope();

		double vz = -GetDefaultByType("GoldWandFX2").Speed * clamp(tan(pitch), -5, 5);
		
		let mo1 = SpawnMissileAngle("GoldWandFX2", angle - (45. / 8), vz);
		let mo2 = SpawnMissileAngle("GoldWandFX2", angle + (45. / 8), vz);
		
		//Scale up damage with level
		let hrpgPlayer = HRpgPlayer(player.mo);
		if (hrpgPlayer != null)
		{
			hrpgPlayer.SetProjectileDamageForMagic(mo1);
		}
		
		double ang = angle - (45. / 8);
		for(int i = 0; i < 5; i++)
		{
			int damage = random[FireGoldWand](1, 8);
			
			if (hrpgPlayer != null)
				damage = hrpgPlayer.GetDamageForMagic(damage);
			
			LineAttack (ang, PLAYERMISSILERANGE, pitch, damage, 'Hitscan', "GoldWandPuff2");
			ang += ((45. / 8) * 2) / 4;
		}
		A_StartSound("weapons/wandhit", CHAN_WEAPON);
	}
}

//Ice Blast
class SpellbookFx1 : Actor
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 8;
		Damage 2;
		Projectile;
		SeeSound "himp/leaderattack";
		+SPAWNSOUNDSOURCE
		-ACTIVATEPCROSS
		-ACTIVATEIMPACT
		RenderStyle "Add";
		Obituary "$OB_MPSPELLBOOKICE";
	}
	States
	{
	Spawn:
		FX05 ABC 4 Bright;
	Death:
		FX23 HI 2 Bright;
		Stop;
	}
}

//Fire Blast
const FIREBLAST_SPEED = 20;
const FIREBLAST_ZSPEED = 1;
class SpellbookFx2 : Actor
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 1;
		Damage 2;
		Projectile;
		Gravity -0.1;
		SeeSound "himp/leaderattack";
		+SPAWNSOUNDSOURCE
		-ACTIVATEPCROSS
		-ACTIVATEIMPACT
		-NOGRAVITY
		Obituary "$OB_MPSPELLBOOKFIRE";
	}
	States
	{
	Spawn:
		FX10 ABC 4 Bright;
		FX10 ABC 4 Bright A_Jump(128, "Launch");
	Launch:
		FX10 A 6 Bright A_LaunchFireBall;
		Goto Launched;
	Launched:
		FX10 ABC 6 Bright;
		Goto Launched;
	Death:
		FX10 DEFG 5 Bright;
		Stop;
	}

	action void A_LaunchFireBall()
	{
		A_SetGravity(0.2);
		A_ChangeVelocity(Vel.X * FIREBLAST_SPEED, Vel.Y * FIREBLAST_SPEED, FIREBLAST_ZSPEED);
	}
}