class HRpgSpellItem : PowerupGiver
{
	int cooldownTicksMax;
	int cooldownTicks;
	int manaCost;
	sound castSound;
	property CooldownTicksMax : cooldownTicksMax;
	property CooldownTicks : cooldownTicks;
	property ManaCost : manaCost;
	property CastSound : castSound;
	
	Default
	{
		+COUNTITEM
		+FLOATBOB
		Inventory.PickupFlash "PickupFlash";
		Inventory.InterHubAmount 1;
		Inventory.MaxAmount 1;
		
		HRpgSpellItem.CooldownTicksMax 80;
		HRpgSpellItem.CooldownTicks 0;
		HRpgSpellItem.ManaCost 100;
		HRpgSpellItem.CastSound "beast/attack";
	}
	
	
	virtual void CastSpell(HRpgBlasphemerPlayer bPlayer)
	{
	}
	
	override bool Use (bool pickup)
	{
		if (Owner == null) return true;

		if (CooldownTicks > 0)
		{
			return false;
		}
		
		CooldownTicks = CooldownTicksMax;
		
		let bPlayer = HRpgBlasphemerPlayer(Owner);
		if (bPlayer && bPlayer.Mana > ManaCost)
		{
			if (bPlayer.SpellLock > 0)
				return false;
			
			bPlayer.SpellLock = 10;
			
			bPlayer.Mana -= ManaCost;
			bPlayer.A_StartSound (CastSound, CHAN_BODY);
			CastSpell(bPlayer);
		}

		return false;
	}
	
	override void Tick()
	{
		// Spells cannot exist outside an inventory
		if (Owner == NULL)
		{
			Destroy ();
		}
		
		if (CooldownTicks > 0)
			CooldownTicks--;
	}
	
	Actor FireSpellProjectile(HRpgBlasphemerPlayer bPlayer, double angleMod, class<Actor> proj, bool scaleDamage, double velZ = 0)
	{
		let mo = bPlayer.SpawnPlayerMissile (proj, bPlayer.angle + angleMod);
		
		if (mo)
		{
			if (scaleDamage)
				bPlayer.SetProjectileDamageForMagic(mo);
		
			if (velZ != 0)
				mo.Vel.Z += velZ;
		}
		
		return mo;
	}
}


//Fireball Blast
class SpellFireballFX1 : PhoenixFireballFX1
{
	Default
	{
		Obituary "$OB_FIREBALLSPELL";
	}
}

//IceBall Blast
class SpellIceFX1 : Actor
{
	Default
	{
		Radius 12;
		Height 6;
		FastSpeed 20;
		Damage 1;
		Projectile;
		-ACTIVATEIMPACT
		-ACTIVATEPCROSS
		+THRUGHOST
		+ZDOOMTRANS
		RenderStyle "Add";
		Speed 16;
		-THRUGHOST;
		Obituary "$OB_ICESPELL";
	}


	States
	{
	Spawn:
		FX05 ABC 6 BRIGHT;
		Loop;
	Death:
		FX05 D 5 BRIGHT A_IceSpellImpact;
		FX05 EFG 5 BRIGHT;
		Stop;
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_IceSpellImpact
	//
	//----------------------------------------------------------------------------

	void A_IceSpellImpact()
	{
		for (int i = 0; i < 8; i++)
		{
			Actor shard = Spawn("SpellIceFX2", Pos, ALLOW_REPLACE);
			if (shard != null)
			{
				shard.target = target;
				shard.angle = i*45.;
				shard.VelFromAngle();
				shard.Vel.Z = -.6;
				shard.CheckMissileSpawn (radius);
			}
		}
	}
}

class SpellIceFX2 : Actor
{
	Default
	{
		Radius 12;
		Height 6;
		Speed 8;
		Damage 3;
		Projectile;
		-ACTIVATEIMPACT
		-ACTIVATEPCROSS
		+ZDOOMTRANS
		RenderStyle "Add";
		Obituary "$OB_ICESPELL";
	}

	States
	{
	Spawn:
		FX05 HIJ 6 BRIGHT;
		Loop;
	Death:
		FX05 DEFG 5 BRIGHT;
		Stop;
	}
}

//Vampire Blast
class SpellVampireFX1 : Actor
{
	Default
	{
		Radius 12;
		Height 8;
		Speed 22;
		Damage 1;
		Projectile;
		SeeSound "himp/leaderattack";
		+SPAWNSOUNDSOURCE
		-ACTIVATEPCROSS
		-ACTIVATEIMPACT
		+RIPPER
		+ZDOOMTRANS
		RenderStyle "Add";
		Obituary "$OB_VAMPIRESPELL";
	}
	States
	{
	Spawn:
		FX00 HIJKL 2 Bright;
		Stop;
	Death:
		FX00 M 2 Bright;
		Stop;
	}
	
	override int DoSpecialDamage(Actor targetMonster, int damage, name damagetype)
	{
		let bPlayer = HRpgBlasphemerPlayer(target);
		if (bPlayer && bPlayer.Health > 0)
		{
			if (bPlayer.Health < bPlayer.MaxHealth)
			{
				bPlayer.A_SetHealth(bPlayer.Health + 1);
			}
		}
		
		return Super.DoSpecialDamage(targetMonster, damage, damagetype);
	}
}

//Fire shpere spell
class VolcanoFX1 : Actor
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 15;
		Damage 2;
		DamageType "Fire";
		Gravity 0.125;
		+NOBLOCKMAP +MISSILE +DROPOFF
		+NOTELEPORT
		+BOUNCEONFLOORS
		+BOUNCEONCEILINGS
		+BOUNCEONWALLS
		+USEBOUNCESTATE
		DeathSound "world/volcano/blast";
		Health 4;
		Obituary "$OB_VOLCANOSPELL";
	}

	States
	{
	Spawn:
		VFBL AB 8 BRIGHT A_SpawnItemEx("Puffy", random2[BeastPuff]()*0.015625, random2[BeastPuff]()*0.015625, random2[BeastPuff]()*0.015625, 
									0,0,0,0,SXF_ABSOLUTEPOSITION, 64);
		Loop;
	Bounce:
		FX18 M 1 A_VolcanoImpact;
		Goto Spawn;
	Death:
		XPL1 A 4 BRIGHT A_VolcBallImpact;
		XPL1 BCDEF 4 BRIGHT;
		Stop;
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_VolcBallImpact
	//
	//----------------------------------------------------------------------------

	void A_VolcBallImpact ()
	{
		if (pos.Z <= floorz)
		{
			bNoGravity = true;
			Gravity = 1;
			AddZ(28);
		}
		A_Explode(25, 25, XF_NOSPLASH|XF_HURTSOURCE, false, 0, 0, 0, "BulletPuff", 'Fire');
		for (int i = 0; i < 4; i++)
		{
			Actor tiny = Spawn("VolcanoTBlast", Pos, ALLOW_REPLACE);
			if (tiny)
			{
				tiny.target = self;
				tiny.Angle = 90.*i;
				tiny.VelFromAngle(0.7);
				tiny.Vel.Z = 1. + random[VolcBallImpact]() / 128.;
				tiny.CheckMissileSpawn (radius);
			}
		}
	}
	
	//Bounce
	void A_VolcanoImpact()
	{
		Health--;
		if (Health < 1)
		{
			SetStateLabel("Death");
			return;
		}

		A_StartSound ("world/volcano/blast", CHAN_BODY);
		
	}
}

class LightningFX1 : Actor
{
	Default
	{
		Radius 10;
		Height 6;
		Speed 18;
		FastSpeed 28;
		Damage 1;
		Projectile;
		-ACTIVATEIMPACT
		-ACTIVATEPCROSS
		+ZDOOMTRANS
		+STEPMISSILE
		RenderStyle "Add";
		Obituary "$OB_LIGHTNINGSPELL";

		+SEEKERMISSILE
		+EXPLOCOUNT

		Health 5;
	}

	States
	{
	Spawn:
		FX16 ABC 3 BRIGHT A_ChainLightningSeek;
		Loop;
	Death:
		FX16 GH 4 BRIGHT;
		FX16 IJ 4 BRIGHT;
		FX16 IJ 4 BRIGHT;
		FX16 IJ 4 BRIGHT;
		FX16 KL 4 BRIGHT;
		Stop;
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_BlueSpark
	//
	//----------------------------------------------------------------------------

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
	
	void A_ChainLightningSeek()
	{
		A_BlueSpark();
		
		Health--;
		if (Health < 1)
		{
			Vel = (0,0,0);
			SetStateLabel("Death");
			bMissile = false;
			return;
		}
		
		A_SeekerMissile(20, 60, SMF_LOOK | SMF_PRECISE);
	}
}

class FireballSpell : HRpgSpellItem
{
	Default
	{
		Inventory.Icon "FX09G0";
		Inventory.PickupMessage "$TXT_FIREBALLSPELL";
		Tag "$TAG_FIREBALLSPELL";
		
		HRpgSpellItem.CooldownTicksMax 25;
		HRpgSpellItem.ManaCost 20 * MANA_SCALE_MOD;
		HRpgSpellItem.CastSound "beast/attack";
	}
	
	override void CastSpell(HRpgBlasphemerPlayer bPlayer)
	{
		if (bPlayer == null)
		{
			return;
		}
		
		FireSpellProjectile(bPlayer, 0, "SpellFireballFX1", true);
	}
}

class IceSpell : HRpgSpellItem
{
	Default
	{
		Inventory.Icon "FX05A0";
		Inventory.PickupMessage "$TXT_ICESPELL";
		Tag "$TAG_ICESPELL";
		
		HRpgSpellItem.CooldownTicksMax 35;
		HRpgSpellItem.ManaCost 30 * MANA_SCALE_MOD;
		HRpgSpellItem.CastSound "weapons/hornrodshoot";
	}
	
	override void CastSpell(HRpgBlasphemerPlayer bPlayer)
	{
		if (bPlayer == null)
		{
			return;
		}
		
		FireSpellProjectile(bPlayer, 0, "SpellIceFX1", true);
	}
}

class VampireSpell : HRpgSpellItem
{
	Default
	{
		Inventory.Icon "FX00H0";
		Inventory.PickupMessage "$TXT_VAMPIRESPELL";
		Tag "$TAG_VAMPIRESPELL";
		
		HRpgSpellItem.CooldownTicksMax 30;
		HRpgSpellItem.ManaCost 80 * MANA_SCALE_MOD;
		HRpgSpellItem.CastSound "snake/attack";
	}
	
	override void CastSpell(HRpgBlasphemerPlayer bPlayer)
	{
		if (bPlayer == null)
		{
			return;
		}

		//Do not scale up damage. This is a healing spell and we want our victims to last longer
		FireSpellProjectile(bPlayer, 0, "SpellVampireFX1", false);
		FireSpellProjectile(bPlayer, 5, "SpellVampireFX1", false);
		FireSpellProjectile(bPlayer, -5, "SpellVampireFX1", false);
	}
}

class VolcanoSpell : HRpgSpellItem
{
	Default
	{
		Inventory.Icon "VFBLA0";
		Inventory.PickupMessage "$TXT_VOLCANOSPELL";
		Tag "$TAG_VOLCANOSPELL";
		
		HRpgSpellItem.CooldownTicksMax 30;
		HRpgSpellItem.ManaCost 60 * MANA_SCALE_MOD;
		HRpgSpellItem.CastSound "beast/attack";
	}
	
	override void CastSpell(HRpgBlasphemerPlayer bPlayer)
	{
		if (bPlayer == null)
		{
			return;
		}

		FireSpellProjectile(bPlayer, -6, "VolcanoFX1", true, random(0.0, 1.0) - 0.5);
		FireSpellProjectile(bPlayer, -2, "VolcanoFX1", true, random(0.0, 1.0) - 0.5);
		FireSpellProjectile(bPlayer, 2, "VolcanoFX1", true, random(0.0, 1.0) - 0.5);
		FireSpellProjectile(bPlayer, 6, "VolcanoFX1", true, random(0.0, 1.0) - 0.5);
	}
}

class LightningSpell : HRpgSpellItem
{
	Default
	{
		Inventory.Icon "FX16B3B7";
		Inventory.PickupMessage "$TXT_LIGHTNINGSPELL";
		Tag "$TAG_LIGHTNINGSPELL";
		
		HRpgSpellItem.CooldownTicksMax 40;
		HRpgSpellItem.ManaCost 250 * MANA_SCALE_MOD;
		HRpgSpellItem.CastSound "dsparil/attack";
	}
	
	override void CastSpell(HRpgBlasphemerPlayer bPlayer)
	{
		if (bPlayer == null)
		{
			return;
		}

		let mo = FireSpellProjectile(bPlayer, -6, "LightningFX1", false);
		
		//Set Timelimit by Corruption value
		if (mo)
		{
			int healthBonus = bPlayer.Crp / 2;
			mo.A_SetHealth(mo.Health + healthBonus);
		}
	}
}