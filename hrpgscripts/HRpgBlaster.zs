// Blaster ------------------------------------------------------------------

class HRpgBlaster : HereticWeapon replaces Blaster
{
	Default
	{
		+BLOODSPLATTER
		Weapon.SelectionOrder 500;
		Weapon.AmmoUse 1;
		Weapon.AmmoGive 30;
		Weapon.YAdjust 15;
		Weapon.AmmoType "BlasterAmmo";
		Weapon.SisterWeapon "HRpgBlasterPowered";
		Inventory.PickupMessage "$TXT_WPNBLASTER";
		Tag "$TAG_BLASTER";
		Obituary "$OB_MPBLASTER";
	}

	States
	{
	Spawn:
		WBLS A -1;
		Stop;
	Ready:
		BLSR A 1 A_WeaponReady;
		Loop;
	Deselect:
		BLSR A 1 A_Lower;
		Loop;
	Select:
		BLSR A 1 A_Raise;
		Loop;
	Fire:
		BLSR BC 3;
	Hold:
		BLSR D 2 A_FireBlasterPL1;
		BLSR CB 2;
		BLSR A 0 A_ReFire;
		Goto Ready;
	AltFire:
		BLSR B 4 Offset(0, 20);
		BLSR C 8 Offset(0, 40) A_FireChain(0);
		BLSR C 24 Offset(0, 60);
		BLSR B 4 Offset(0, 40);
		BLSR A 2 Offset(0, 20);
		Goto Ready;
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_FireBlasterPL1
	//
	//----------------------------------------------------------------------------

	action void A_FireBlasterPL1()
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
		int damage = random[FireBlaster](1, 8) * 4;
		double ang = angle;
		if (player.refire)
		{
			ang += Random2[FireBlaster]() * (5.625 / 256);
		}
		
		//Scale up damage with level
		let hrpgPlayer = HRpgPlayer(player.mo);
		if (hrpgPlayer != null)
			damage = hrpgPlayer.GetDamageForWeapon(damage);
		
		LineAttack (ang, PLAYERMISSILERANGE, pitch, damage, 'Hitscan', "BlasterPuff");
		A_StartSound ("weapons/blastershoot", CHAN_WEAPON);
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_FireChain
	//
	//----------------------------------------------------------------------------
	action void A_FireChain(int powered)
	{
		if (player == null)
		{
			return;
		}
		
		let tracker = ClawChainTracker(FindInventory("ClawChainTracker"));
		if (tracker && tracker.ClawChain1)
			return;

		Actor clawChain;
		if (powered)
			clawChain = Actor(SpawnPlayerMissile ("RedClawChain", angle));
		else
			clawChain = Actor(SpawnPlayerMissile ("ClawChain", angle));
			
		//Scale up damage with level
		let hrpgPlayer = HRpgPlayer(player.mo);
		if (hrpgPlayer != null && clawChain != null)
		{
			let newDamage = hrpgPlayer.GetDamageForMelee(clawChain.Damage);
			
			if (powered)
				newDamage = hrpgPlayer.GetDamageForMagic(clawChain.Damage);
				
			clawChain.SetDamage (newDamage);
		}
		
		if (tracker == null)
			tracker = ClawChainTracker(GiveInventoryType("ClawChainTracker"));
		
		tracker.ClawChain1 = clawChain;
	}
}

class HRpgBlasterPowered : HRpgBlaster replaces BlasterPowered
{
	Default
	{
		+WEAPON.POWERED_UP
		Weapon.AmmoUse 5;
		Weapon.AmmoGive 0;
		Weapon.SisterWeapon "HRpgBlaster";
		Tag "$TAG_BLASTERP";
	}

	States
	{
	Fire:
		BLSR BC 0;
	Hold:
		BLSR D 3 A_FireProjectile("BlasterFX1");
		BLSR CB 4;
		BLSR A 0 A_ReFire;
		Goto Ready;
	AltFire:
		BLSR B 4 Offset(0, 20);
		BLSR C 8 Offset(0, 40) A_FireChain(1);
		BLSR C 24 Offset(0, 60);
		BLSR B 4 Offset(0, 40);
		BLSR A 2 Offset(0, 20);
		Goto Ready;
	}
}

class ClawChain : Actor
{
	Actor links[4];
	property Links : links;
	
	Default
	{
		Radius 10;
		Height 6;
		Speed 0;
		Damage 1;
		Health 19;
		Projectile;
		+RIPPER
		+ZDOOMTRANS
		DeathSound "weapons/blasterpowhit";
		Obituary "$OB_MPCLAWCHAIN";
		Scale 1.5;
		+BOUNCEONFLOORS;
		+BOUNCEONCEILINGS;
		+USEBOUNCESTATE;
		+BOUNCEONWALLS;
		+CANBOUNCEWATER;
	}

	States
	{
	Spawn:
		FX18 M 2 A_MoveClawChain;
		Loop;
	Bounce:
		FX18 M 1 A_MaceBallImpact;
		Goto Spawn;
	Death:
		FX18 M 1;
		Goto Spawn;
	}
	
	//Bounce
	void A_MaceBallImpact()
	{
		A_StartSound ("weapons/macebounce", CHAN_BODY);
	}
	
	override void Die(Actor source, Actor inflictor, int dmgflags, Name MeansOfDeath)
	{
		A_MaceBallImpact();
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_MoveClawChain
	//
	//----------------------------------------------------------------------------
	action void A_MoveClawChain()
	{
		if (target == null || target.health <= 0)
		{ // Shooter is dead or nonexistent
			A_RemoveClawChain();
			return;
		}
		
		Health--;
		if (Health <= 0)
		{
			A_RemoveClawChain();
			return;
		}
		
		let particleStepX = (Pos.X - target.Pos.X) * 0.2;
		let particleStepY = (Pos.Y - target.Pos.Y) * 0.2;
		let particleStepZ = (Pos.Z - target.Pos.Z) * 0.2;
		
		for (int i = 1; i < 5; i++)
		{
			let mox = target.Pos.X + particleStepX *  i;
			let moy = target.Pos.Y + particleStepY *  i;
			let moz = target.Pos.Z + particleStepZ *  i;
			
			let clawChain = ClawChain(self);
			if (clawChain.Links[i-1] == null)
			{
				if (Damage == 3)
					clawChain.Links[i-1] = Spawn ("ClawChainLink2", (mox, moy, moz), ALLOW_REPLACE);
				else
					clawChain.Links[i-1] = Spawn ("ClawChainLink", (mox, moy, moz), ALLOW_REPLACE);
			}
			else
			{
				/*clawChain.Links[i-1].Pos.X = mox;
				clawChain.Links[i-1].Pos.Y = moy;
				clawChain.Links[i-1].Pos.Z = moz;*/
				clawChain.Links[i-1].SetOrigin((mox, moy, moz), true);
			}
		}
		
		double maxDist = 150;
		if (Health <= 5)
		{
			let vecOffset = (target.Pos.X - Pos.X, target.Pos.Y - Pos.Y);
			let ang = Vectorangle(vecOffset.x, vecOffset.y);
			A_SetAngle(ang);
			
			let dist = Distance2D(target);
			let vel = dist * 0.25;
			let aPitch = Vectorangle(dist, Pos.Z - target.Pos.Z);
			
			Vel3DFromAngle(vel, angle, aPitch);
		}
		else
		{
			let forwardOffset = AngleToVector(target.angle, maxDist);
			let newPos = (target.Pos.X + forwardOffset.x, target.Pos.Y + forwardOffset.y);
			let vecOffset = (Pos.X - newPos.x, Pos.Y - newPos.y);
			let ang = Vectorangle(vecOffset.x, vecOffset.y);
			A_SetAngle(ang);
			
			let dist = Sqrt(vecOffset.X * vecOffset.X + vecOffset.Y * vecOffset.Y);
			if (dist < 2)
			{
				A_ChangeVelocity(0,0,0, CVF_REPLACE);
			}
			else
			{
				let vel = dist * 0.5;
				if (vel > 13)
					vel = 13;
				Vel3DFromAngle(vel, angle + 180, target.pitch);
			}
		}
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_RemoveClawChain
	//
	//----------------------------------------------------------------------------
	action void A_RemoveClawChain()
	{
		ClawChainTracker tracker;
		
		if (target != null && target.health > 0)
			tracker = ClawChainTracker(target.FindInventory("ClawChainTracker"));
			
		let clawChain = ClawChain(self);
		for (int i = 0; i < 4; i++)
		{
			if (clawChain.Links[i] != null)
			{
				clawChain.Links[i].Destroy();
				clawChain.Links[i] = null;
			}
		}
		
		Destroy();
		
		if (tracker)
			tracker.ClawChain1 = null;
	}
}

class RedClawChain : ClawChain
{
	Default
	{
		Height 6;
		Speed 0;
		Damage 3;
		Health 21;
		Projectile;
		+RIPPER
		+ZDOOMTRANS
		DeathSound "weapons/blasterpowhit";
		Obituary "$OB_MPPCLAWCHAIN";
		Scale 1.5;
	}

	States
	{
	Spawn:
		FX15 E 2 A_MoveClawChain();
		Loop;
	Death:
		FX15 EFG 2;
		Goto Spawn;
	}
}

class ClawChainTracker : Inventory
{
	Actor ClawChain1;
	
	Default
	{
		+INVENTORY.UNDROPPABLE
	}
}

class ClawChainLink : Actor
{
	Default
	{
		+NOBLOCKMAP
		+NOGRAVITY
		+NOTELEPORT
		+CANNOTPUSH
		Scale 0.33;
	}

	States
	{
	Spawn:
		FX18 M 24;
		Stop;
	}
}

class ClawChainLink2 : ClawChainLink
{
	Default
	{
		+NOBLOCKMAP
		+NOGRAVITY
		+NOTELEPORT
		+CANNOTPUSH
		+ZDOOMTRANS
		RenderStyle "Translucent";
		Scale 0.5;
	}

	States
	{
	Spawn:
		FX15 D 40;
		Stop;
	}
}