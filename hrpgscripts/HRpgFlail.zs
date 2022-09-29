const CHAIN_TARGETZ_OFFSET = 15;
const CHAIN_LINK_SKIP = 1;
const CHAIN_MAX_DIST = 350;
const CHAIN_VEL_PERCENT = 0.25;
const CHAIN_VEL_FAST_PERCENT = 0.7;
const CHAIN_VEL_MIN = 2;
const CHAIN_VEL_MAX = 13;
const CHAIN_HEALTH_RETURN = 5;
const CHAIN_HEALTH_MAX = 30;
const FLAIL_MELEE_RANGE = DEFMELEERANGE * 1.75;

class HRpgFlail : HeathenWeapon
{
	Default
	{
		Weapon.SelectionOrder 800;
		Weapon.AmmoUse2 5;
		Weapon.AmmoGive2 30;
		Weapon.AmmoType2 "BlasterAmmo";
		Weapon.SisterWeapon "HRpgFlailPowered";
		Weapon.YAdjust 15;
		Inventory.PickupMessage "$TXT_WPNFLAIL";
		Tag "$TAG_FLAIL";
		Obituary "$OB_MPFLAIL";
	}

	States
	{
	Spawn:
		WMST A -1;
		Stop;
	Ready:
		MSTR A 4 A_WeaponReady;
		Loop;
	Deselect:
		MSTR A 1 A_Lower;
		Loop;
	Select:
		MSTR A 1 A_Raise;
		Loop;
	Fire:
		MSTR B 8;
		MSTR C 4;
		MSTR D 4 A_HeathenMeleeAttack(random(15, 45), 175, "WarhammerPuff", FLAIL_MELEE_RANGE);
		MSTR E 4;
		MSTR F 8;
		MSTR F 2 A_ReFire;
		Goto Ready;
	AltFire:
		MSTR B 8 Offset(0, 65);
		MSTR C 4;
		MSTR G 38 A_FireChain(0);
		MSTR G 4;
		MSTR G 8;
		MSTR G 2 A_ReFire;
		Goto Ready;
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
		
		Weapon weapon = player.ReadyWeapon;
		if (weapon != null)
		{
			if (!weapon.DepleteAmmo (weapon.bAltFire))
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
				
			//Scale up damage with berserk
			let berserk = Powerup(FindInventory("PowerStrength2"));
			if (berserk)
			{
				newDamage *= 2;
			}
				
			clawChain.SetDamage (newDamage);
		}
		
		if (tracker == null)
			tracker = ClawChainTracker(GiveInventoryType("ClawChainTracker"));
		
		tracker.ClawChain1 = clawChain;
	}
}


class HRpgFlailPowered : HRpgFlail
{
	Default
	{
		+WEAPON.POWERED_UP
		Weapon.AmmoGive 0;
		Weapon.SisterWeapon "HRpgFlail";
		Tag "$TAG_FLAIL";
		Obituary "$OB_MPPFLAIL";
	}

	States
	{
	Spawn:
		WMST A -1;
		Stop;
	Ready:
		MSTR A 4 A_WeaponReady;
		Loop;
	Deselect:
		MSTR A 1 A_Lower;
		Loop;
	Select:
		MSTR A 1 A_Raise;
		Loop;
	Fire:
		MSTR B 8;
		MSTR C 4;
		MSTR D 4 A_HeathenMeleeAttack(random(35, 90), 175, "BlasterPuff", FLAIL_MELEE_RANGE);
		MSTR E 4;
		MSTR F 8;
		MSTR F 2 A_ReFire;
		Goto Ready;
	AltFire:
		MSTR B 8 Offset(0, 35);
		MSTR C 4;
		MSTR G 32 A_FireChain(1);
		MSTR E 4;
		MSTR F 8;
		MSTR F 2 A_ReFire;
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
		Health CHAIN_HEALTH_MAX;
		Projectile;
		+RIPPER
		+ZDOOMTRANS
		DeathSound "weapons/macebounce";
		Obituary "$OB_MPCLAWCHAIN";
		Scale 1.5;
		+BOUNCEONFLOORS
		+BOUNCEONCEILINGS
		+USEBOUNCESTATE
		+BOUNCEONWALLS
		+CANBOUNCEWATER
		+FORCEXYBILLBOARD
	}

	States
	{
	Spawn:
		FX18 M 2 A_MoveClawChain(0);
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
	action void A_MoveClawChain(int powered)
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
		
		let targetZ = target.Pos.Z + CHAIN_TARGETZ_OFFSET;
		let particleStepX = (Pos.X - target.Pos.X) * 0.2;
		let particleStepY = (Pos.Y - target.Pos.Y) * 0.2;
		let particleStepZ = (Pos.Z - targetZ) * 0.2;
		
		for (int i = 1; i < 5; i++)
		{
			int num = i + CHAIN_LINK_SKIP;
			let mox = target.Pos.X + particleStepX * num;
			let moy = target.Pos.Y + particleStepY * num;
			let moz = targetZ + particleStepZ * num;
			
			let clawChain = ClawChain(self);
			if (clawChain.Links[i-1] == null)
			{
				if (powered)
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
		
		if (Health <= CHAIN_HEALTH_RETURN)
		{
			let vecOffset = (target.Pos.X - Pos.X, target.Pos.Y - Pos.Y);
			let ang = Vectorangle(vecOffset.x, vecOffset.y);
			A_SetAngle(ang);
			
			let dist = Distance2D(target);
			let vel = dist * CHAIN_VEL_PERCENT;
			let aPitch = Vectorangle(dist, Pos.Z - targetZ);
			
			Vel3DFromAngle(vel, angle, aPitch);
		}
		else
		{
			let forwardOffset = AngleToVector(target.angle, CHAIN_MAX_DIST);
			let newPos = (target.Pos.X + forwardOffset.x, target.Pos.Y + forwardOffset.y);
			let vecOffset = (Pos.X - newPos.x, Pos.Y - newPos.y);
			let ang = Vectorangle(vecOffset.x, vecOffset.y);
			A_SetAngle(ang);
			
			let dist = Sqrt(vecOffset.X * vecOffset.X + vecOffset.Y * vecOffset.Y);
			if (dist < CHAIN_VEL_MIN)
			{
				A_ChangeVelocity(0,0,0, CVF_REPLACE);
			}
			else
			{
				let vel = dist * CHAIN_VEL_FAST_PERCENT;
				if (vel > CHAIN_VEL_MAX)
					vel = CHAIN_VEL_MAX;
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
		Projectile;
		+RIPPER
		+ZDOOMTRANS
		DeathSound "weapons/macebounce";
		Obituary "$OB_MPPCLAWCHAIN";
		Scale 1.5;
	}

	States
	{
	Spawn:
		FX15 E 2 A_MoveClawChain(1);
		Loop;
	Bounce:
		FX15 E 1 A_MaceBallImpact;
		Goto Spawn;
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
		+FORCEXYBILLBOARD
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