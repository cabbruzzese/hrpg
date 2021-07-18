// The mace itself ----------------------------------------------------------
const MACE_VVEL_MOD = 2.0;
class HRpgMace : HereticWeapon replaces Mace
{
	Default
	{
		Weapon.SelectionOrder 1400;
		Weapon.AmmoUse2 1;
		Weapon.AmmoGive2 50;
		Weapon.YAdjust 15;
		Weapon.AmmoType2 "MaceAmmo";
		Weapon.SisterWeapon "HRpgMacePowered";
		Inventory.PickupMessage "$TXT_WPNMACE";
		Tag "$TAG_MACE";
		Obituary "$OB_MPMACEHIT";
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
		MACE CDEF 3 A_FireMacePL1(0.0, 1, 1);
		MACE C 4 A_ReFire;
		MACE DEFB 4;
		Goto Ready;
	Fire2:
		HMAC G 6;
		HMAC H 3;
		HMAC I 3 A_MaceMeleeAttack(random(35, 75), "MacePuff1", 150);
		HMAC J 3;
		HMAC K 3;
		HMAC K 10;
		HMAC K 2 A_ReFire;
		Goto Ready;
	Fire3:
		HMAC B 6;
		HMAC C 3;
		HMAC D 3 A_MaceMeleeAttack(random(35, 75), "MacePuff1", 150);
		HMAC E 3;
		HMAC F 3;
		HMAC F 10;
		HMAC F 2 A_ReFire;
		Goto Ready;
	AltFire:
		HMAC G 6;
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

	//----------------------------------------------------------------------------
	//
	// PROC A_MaceAttackArc
	//
	//----------------------------------------------------------------------------
	action void A_MaceAttackArc(int powered)
	{
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
			if (!weapon.CheckAmmo(Weapon.AltFire, true))
				return;
		}

		A_FireMacePL1(0.1, 1, enlarged); //Fire two for the price of 1.
		A_FireMacePL1(0.2, 0, enlarged);
		A_FireMacePL1(0.3, costsExtraAmmo, enlarged); // Only charge extra if not powered
		A_FireMacePL1(0.4, 0, enlarged);
		A_FireMacePL1(0.5, costsExtraAmmo, enlarged);
		A_FireMacePL1(0.6, 0, enlarged);
		A_FireMacePL1(0.7, costsExtraAmmo, enlarged);
		A_FireMacePL1(0.8, 0, enlarged);
		A_FireMacePL1(0.9, costsExtraAmmo, enlarged);
		A_FireMacePL1(1.0, 0, enlarged);
	}

	//----------------------------------------------------------------------------
	//
	// PROC A_FireMacePL1
	//
	//----------------------------------------------------------------------------
	action void A_FireMacePL1(float apitch, int checkAmmo, int canEnlarge)
	{
		if (player == null)
		{
			return;
		}

		Weapon weapon = player.ReadyWeapon;
		if (weapon != null && checkAmmo)
		{
			if (!weapon.DepleteAmmo (true))
			{
				weapon.CheckAmmo(Weapon.AltFire, true);
				return;
			}
		}

		//Scale up damage with level
		let hrpgPlayer = HRpgPlayer(player.mo);

		if ((random[MaceAtk]() < 28 && canEnlarge != 0) || canEnlarge > 1)
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
				
				hrpgPlayer.SetProjectileDamageForWeapon(ball);

				ball.Vel.Z = ball.Vel.Z + (MACE_VVEL_MOD * apitch);
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
				
				hrpgPlayer.SetProjectileDamageForWeapon(ball);

				ball.Vel.Z = ball.Vel.Z + (MACE_VVEL_MOD * apitch);
			}
		}
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_MaceMeleeAttack
	//
	//----------------------------------------------------------------------------

	action void A_MaceMeleeAttack (int damage, class<Actor> puff, int kickback)
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
			damage *= 1.5;
		}

		Weapon weapon = player.ReadyWeapon;

		double ang = angle + Random2[StaffAtk]() * (5.625 / 256);
		double slope = AimLineAttack (ang, DEFMELEERANGE * 1.2);
		
		kickbackSave = weapon.Kickback;
		weapon.Kickback = kickback;
		LineAttack (ang, DEFMELEERANGE * 1.2, slope, damage, 'Melee', puff, true, t);
		weapon.Kickback = kickbackSave;
		
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
		Weapon.AmmoUse2 5;
		Weapon.AmmoGive2 0;
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
		HMAC G 6;
		HMAC H 3;
		HMAC I 3 A_MaceMeleeAttack(random(55, 95), "MacePuff2", 250);
		HMAC J 3;
		HMAC K 3;
		HMAC K 10;
		HMAC K 2 A_ReFire;
		Goto Ready;
	Fire3:
		HMAC B 6;
		HMAC C 3;
		HMAC D 3 A_MaceMeleeAttack(random(55, 95), "MacePuff2", 250);
		HMAC E 3;
		HMAC F 3;
		HMAC F 10;
		HMAC F 2 A_ReFire;
		Goto Ready;
	AltFire:
		HMAC G 6;
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
			if (!weapon.DepleteAmmo (true))
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
	}

	States
	{
	Spawn:
		FX14 DEFGH 4 BRIGHT;
		Stop;
	}
}