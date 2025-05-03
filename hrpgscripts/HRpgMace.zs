// The mace itself ----------------------------------------------------------
const MACE_VVEL_MOD = 2.0;
const MACE_MELEE_RANGE = int(DEFMELEERANGE * 1.2);
const MACE_ALT_AMMO_USE = 5;

class HRpgMace : HRpgWeapon replaces Mace
{
	Default
	{
		Weapon.SelectionOrder 1400;
		Weapon.AmmoUse 1;
		Weapon.AmmoGive 50;
		Weapon.AmmoType "MaceAmmo";
		Weapon.YAdjust 15;
		Weapon.SisterWeapon "HRpgMacePowered";
		Inventory.PickupMessage "$TXT_WPNMACE";
		Tag "$TAG_MACE";
		Obituary "$OB_MPMACEHIT";
		
		+WEAPON.MELEEWEAPON
	}

	States
	{
	Spawn:
		WMCE A -1;
		Stop;
	Ready:
		HMAC A 1 A_WeaponReady;
		Loop;
	Deselect:
		HMAC A 1 A_Lower;
		Loop;
	Select:
		HMAC A 1 A_Raise;
		Loop;
	Fire:
		HMAC A 1 A_MaceAttackRandomize;
	Hold:
		MACE B 1 A_MaceAttackRandomize;
		MACE CDEF 3 A_FireMacePL1(false, 0.0, 1, 1);
		MACE C 4 A_ReFire;
		MACE DEFB 4;
		Goto Ready;
	Fire2:
		HMAC G 5;
		HMAC H 2;
		HMAC I 2 A_HeathenMeleeAttack(random(30, 60), 150, "MacePuff1", MACE_MELEE_RANGE);
		HMAC J 2;
		HMAC K 2;
		HMAC K 8;
		HMAC K 2 A_ReFire;
		Goto Ready;
	Fire3:
		HMAC B 5;
		HMAC C 2;
		HMAC D 2 A_HeathenMeleeAttack(random(30, 60), 150, "MacePuff1", MACE_MELEE_RANGE);
		HMAC E 2;
		HMAC F 2;
		HMAC F 8;
		HMAC F 2 A_ReFire;
		Goto Ready;
	AltFire:
		HMAC G 6 A_CheckAmmoOrMeleeIfHeathen(AltFire, PrimaryFire);
		HMAC H 3;
		HMAC I 3 A_MaceAttackArc(0);
		HMAC J 3;
		HMAC K 3;
		HMAC K 10;
		HMAC K 2 A_ReFire;
		Goto Ready;
	}

	//----------------------------------------------------------------------------
	//
	// PROC A_MaceAttackRandomize
	//
	//----------------------------------------------------------------------------
	action void A_MaceAttackRandomize()
	{
		if (player == null)
		{
			return;
		}
		
		let heathenPlayer = HRpgHeathenPlayer(player.mo);
		if (heathenPlayer)
		{
			int attacktype = random(0, 2);

			if (attacktype == 1)
			{
				player.SetPsprite(PSP_WEAPON, player.ReadyWeapon.FindState("Fire3"));
			}
			else
			{
				player.SetPsprite(PSP_WEAPON, player.ReadyWeapon.FindState("Fire2"));
			}
		}
	}

	action void A_MaceAttackArc(int powered)
	{
		A_StartSound("minotaur/attack2");
		
		int enlarged = 0;
		int costsExtraAmmo = 1;
		if (powered)
		{
			enlarged = 2;
			costsExtraAmmo = 0;
		}

		Weapon weapon = player.ReadyWeapon;
		if (weapon != null)
		{
			if (!weapon.CheckAmmo(Weapon.PrimaryFire, true))
				return;
		}

		A_FireMacePL1(true, 0.1, 1, enlarged, AltFire); //Fire two for the price of 1.
		A_FireMacePL1(true, 0.2, 0, enlarged);
		A_FireMacePL1(true, 0.3, costsExtraAmmo, enlarged); // Only charge extra if not powered
		A_FireMacePL1(true, 0.4, 0, enlarged);
		A_FireMacePL1(true, 0.5, costsExtraAmmo, enlarged);
		A_FireMacePL1(true, 0.6, 0, enlarged);
		A_FireMacePL1(true, 0.7, costsExtraAmmo, enlarged);
		A_FireMacePL1(true, 0.8, 0, enlarged);
		A_FireMacePL1(true, 0.9, costsExtraAmmo, enlarged);
		A_FireMacePL1(true, 1.0, 0, enlarged);
	}

	action void A_FireMacePL1(bool isSilent, float apitch, int checkAmmo, int canEnlarge, int fireMode = PrimaryFire)
	{
		if (player == null)
		{
			return;
		}

		Weapon weapon = player.ReadyWeapon;
		if (weapon != null && checkAmmo)
		{			
			if (!weapon.DepleteAmmo (false))
			{
				weapon.CheckAmmo(fireMode, true);
				return;
			}
		}

		//Scale up damage with level
		let hrpgPlayer = HRpgPlayer(player.mo);

		if ((random[MaceAtk]() < 28 && canEnlarge != 0) || canEnlarge > 1)
		{
			let spawnType = "MaceFX2Loud";
			if (isSilent)
				spawnType = "MaceFX2Silent";

			Actor ball = SpawnPlayerMissile(spawnType, angle + (random[MaceAtk](-4, 3) * (360. / 256)));
			if (ball != null)
			{
				if (!isSilent)
					ball.A_StartSound ("weapons/maceshoot", CHAN_BODY);
				
				ball.CheckMissileSpawn (radius);
				
				hrpgPlayer.SetProjectileDamageForWeapon(ball);

				ball.Vel.Z = ball.Vel.Z + (MACE_VVEL_MOD * apitch);
			}
		}
		else //normal shot
		{
			let psp = player.GetPSprite(PSP_WEAPON);
			if (psp)
			{
				psp.x = random[MaceAtk](-2, 1);
				psp.y = WEAPONTOP + random[MaceAtk](0, 3);
			}

			let fxClass = "MaceFX1";
			if (isSilent)
				"MaceFX1Silent";

			if (canEnlarge == 0)
			{
				fxClass = "MaceFX5";
				if (isSilent)
					fxClass = "MaceFX5Silent";
			}
			
			Actor ball = SpawnPlayerMissile(fxClass, angle + (random[MaceAtk](-4, 3) * (360. / 256)));
			if (ball)
			{
				ball.special1 = 16; // tics till dropoff
				
				hrpgPlayer.SetProjectileDamageForWeapon(ball);

				ball.Vel.Z = ball.Vel.Z + (MACE_VVEL_MOD * apitch);
			}
		}
	}

	override bool CheckAmmo(int fireMode, bool autoSwitch, bool requireAmmo, int ammocount)
	{
		let htPlayer = HRpgHeathenPlayer(Owner);
		if (htPlayer && htPlayer.player.ReadyWeapon)
		{
			htPlayer.player.ReadyWeapon.bAMMO_OPTIONAL = true;
			htPlayer.player.ReadyWeapon.bALT_AMMO_OPTIONAL = true;
		}

		return super.CheckAmmo(firemode, autoSwitch, requireAmmo, ammocount);
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
		Obituary "$OB_MPPMACEHIT";
	}

	States
	{
	Fire:
		HMAC A 1 A_MaceAttackRandomize;
	Hold:	
		MACE B 1 A_MaceAttackRandomize;
		MACE B 3;
		MACE D 4 A_FireMacePL2;
		MACE B 4;
		MACE A 8 A_ReFire;
		Goto Ready;
	Fire2:
		HMAC G 5;
		HMAC H 2;
		HMAC I 2 A_HeathenMeleeAttack(random(50, 80), 250, "MacePuff2", MACE_MELEE_RANGE);
		HMAC J 2;
		HMAC K 2;
		HMAC K 8;
		HMAC K 2 A_ReFire;
		Goto Ready;
	Fire3:
		HMAC B 5;
		HMAC C 2;
		HMAC D 2 A_HeathenMeleeAttack(random(50, 80), 250, "MacePuff2", MACE_MELEE_RANGE);
		HMAC E 2;
		HMAC F 2;
		HMAC F 8;
		HMAC F 2 A_ReFire;
		Goto Ready;
	AltFire:
		HMAC G 6 A_CheckAmmoOrMeleeIfHeathen(AltFire, PrimaryFire);
		HMAC H 3;
		HMAC I 3 A_MaceAttackArc(1);
		HMAC J 3;
		HMAC K 3;
		HMAC K 10;
		HMAC K 2 A_ReFire;
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
			if (!weapon.DepleteAmmo (false))
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

class MacePuff1 : Actor
{
	Default
	{
		RenderStyle "Add";
		+NOBLOCKMAP
		+NOGRAVITY
		+PUFFONACTORS
		+ZDOOMTRANS
		+FORCEXYBILLBOARD
		AttackSound "weapons/phoenixhit";
		ActiveSound "mummy/attack1";
		Scale 0.5;
	}

	States
	{
	Spawn:
		FX06 DEFG 4 BRIGHT;
		Stop;
	}
}

class MacePuff2 : Actor
{
	Default
	{
		RenderStyle "Add";
		+NOBLOCKMAP
		+NOGRAVITY
		+PUFFONACTORS
		+ZDOOMTRANS
		+FORCEXYBILLBOARD
		AttackSound "weapons/staffpowerhit";
		ActiveSound "mummy/attack1";
	}

	States
	{
	Spawn:
		FX14 DEFGH 4 BRIGHT;
		Stop;
	}
}

class MaceFX5 : Actor
{
	const MAGIC_JUNK = 1234;
	
	Default
	{
		Radius 8;
		Height 6;
		Speed 20;
		Damage 2;
		Projectile;
		+THRUGHOST
		BounceType "HereticCompat";
		Obituary "$OB_MPMACE";
	}

	States
	{
	Spawn:
		FX02 AB 4 A_MacePL1Check;
		Loop;
	Death:
		FX02 F 4 BRIGHT A_MaceBallImpact;
		FX02 GHIJ 4 BRIGHT;
		Stop;
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_MacePL1Check
	//
	//----------------------------------------------------------------------------

	void A_MacePL1Check()
	{
		if (special1 == 0) return;
		special1 -= 4;
		if (special1 > 0) return;
		special1 = 0;
		bNoGravity = false;
		Gravity = 1. / 8;
		// [RH] Avoid some precision loss by scaling the velocity directly
		double velscale = 7 / Vel.XY.Length();
		Vel.XY *= velscale;
		Vel.Z *= 0.5;
	}

	//----------------------------------------------------------------------------
	//
	// PROC A_MaceBallImpact
	//
	//----------------------------------------------------------------------------

	void A_MaceBallImpact()
	{
		if ((health != MAGIC_JUNK) && bInFloat)
		{ // Bounce
			health = MAGIC_JUNK;
			Vel.Z *= 0.75;
			bBounceOnFloors = bBounceOnCeilings = false;
			SetState (SpawnState);
			A_StartSound ("weapons/macebounce", CHAN_BODY);
		}
		else
		{ // Explode
			Vel = (0,0,0);
			bNoGravity = true;
			Gravity = 1;
			A_StartSound ("weapons/macehit", CHAN_BODY);
		}
	}
}

class MaceFX1Silent : MaceFX1
{
	Default
	{
		SeeSound "";
	}
}

class MaceFX2Silent : MaceFX2Loud
{
	Default
	{
		SeeSound "";
	}
}

class MaceFX5Silent : MaceFX5
{
	Default
	{
		SeeSound "";
	}
}

class MaceFX2Loud : MaceFX1
{
	Default
	{
		Speed 10;
		Damage 6;
		Gravity 0.125;
		-NOGRAVITY
		SeeSound "";
	}

	States
	{
	Spawn:
		FX02 CD 4;
		Loop;
	Death:
		FX02 F 4 A_MaceBallImpact2;
		goto Super::Death+1;
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_MaceBallImpact2
	//
	//----------------------------------------------------------------------------

	void A_MaceBallImpact2()
	{
		if ((pos.Z <= floorz) && HitFloor ())
		{ // Landed in some sort of liquid
			Destroy ();
			return;
		}
		if (bInFloat)
		{
			if (Vel.Z >= 2)
			{
				// Bounce
				Vel.Z *= 0.75;
				SetState (SpawnState);

				Actor tiny = Spawn("MaceFX3", Pos, ALLOW_REPLACE);
				if (tiny != null)
				{
					tiny.target = target;
					tiny.angle = angle + 90.;
					tiny.VelFromAngle(Vel.Z - 1.);
					tiny.Vel += (Vel.XY * .5, Vel.Z);
					tiny.CheckMissileSpawn (radius);
				}

				tiny = Spawn("MaceFX3", Pos, ALLOW_REPLACE);
				if (tiny != null)
				{
					tiny.target = target;
					tiny.angle = angle - 90.;
					tiny.VelFromAngle(Vel.Z - 1.);
					tiny.Vel += (Vel.XY * .5, Vel.Z);
					tiny.CheckMissileSpawn (radius);
				}

				A_StartSound ("weapons/macebounce", CHAN_BODY);
				return;
			}
		}
		Vel = (0,0,0);
		bNoGravity = true;
		bBounceOnFloors = bBounceOnCeilings = false;
		Gravity = 1;
	}
}