const MAXXPHIT = 75;

const RESPAWN_TICS_MIN = 1200; //1 minute
const RESPAWN_TICS_MAX = 24000; //20 minutes

const BOSSTYPE_CHANCE_BRUTE = 10;
const BOSSTYPE_CHANCE_SPECTRE = 4;
const BOSSTYPE_CHANCE_LEADER = 2;
const BOSSTYPE_CHANCE_RUNT = 6;
const BOSSTYPE_SUBCHANCE_POISON = 25;

enum EWanderingMonsterFlags
{
	WMF_BRUTE = 1,
	WMF_SPECTRE = 2,
	WMF_LEADER = 4,
	WMF_RUNT = 8,
	WMF_POISON = 16
};

class ExpSquishbag : Actor
{
	int respawnWaitTics;
	int respawnWaitBonus;
	int respawnLevel;
	bool isRespawnable;
	bool IsSpectreable;
	int baseSpeed;
	int bossType;
	property RespawnWaitTics : respawnWaitTics;
	property RespawnWaitBonus : respawnWaitBonus;
	property RespawnLevel : respawnLevel;
	property IsRespawnable : isRespawnable;
	property IsSpectreable : isSpectreable;
	property BaseSpeed : baseSpeed;
	property BossType : bossType;
	
	
	Default
	{
		ExpSquishbag.RespawnWaitTics 0;
		ExpSquishbag.RespawnWaitBonus 0;
		ExpSquishbag.respawnLevel 1;
		ExpSquishbag.IsRespawnable false;
		ExpSquishbag.IsSpectreable true;
		ExpSquishbag.BaseSpeed -1;
		ExpSquishbag.BossType 0;
	}
	
	void A_CustomComboAttack2(class<Actor> missiletype, double spawnheight, int damage, sound meleesound = "", name damagetype = "none", bool bleed = true)
	{
		if (BossType & WMF_POISON)
			missileType = "PoisonBall";
			
		A_CustomComboAttack(missiletype, spawnheight, damage, meleesound, damagetype, bleed);
	}
	
	override int TakeSpecialDamage(Actor inflictor, Actor source, int damage, Name damagetype)
	{
		int xp = damage;
		if (xp > MAXXPHIT)
			xp = MAXXPHIT;

		let hrpgPlayer = HRpgPlayer(source);
		if (hrpgPlayer)
		{
			hrpgPlayer.GiveXP(xp);
		}
		
		return Super.TakeSpecialDamage(inflictor, source, damage, damagetype);
	}
	
	override void Die(Actor source, Actor inflictor, int dmgflags, Name MeansOfDeath)
	{
		A_DropItem("HRpgSkullItem", 1, 35);
		Super.Die(source, inflictor, dmflags, MeansOfDeath);

		if (IsRespawnable)
		{
			let hrpgPlayer = HRpgPlayer(source);
			if (hrpgPlayer)
			{
				RespawnLevel = hrpgPlayer.ExpLevel;
			}
			RespawnWaitTics = random(RESPAWN_TICS_MIN, RESPAWN_TICS_MAX) + RespawnWaitBonus;
		}
	}
	
	override void Tick()
	{
		if (RespawnWaitTics > 0)
		{
			RespawnWaitTics--;
			
			if (RespawnWaitTics == 1)
			{
				WanderingMonsterRespawn();
			}
		}
		
		Super.Tick();
	}
	
	void SetNormal()
	{
		A_SetScale(1);
		DamageMultiply = 1;
		Translation = 0;
		bALWAYSFAST = false;
		BossType = 0;
		
		if (isSpectreable)
			A_SetRenderStyle(1.0, STYLE_Normal);
		
		if (BaseSpeed != -1)
			A_SetSpeed(BaseSpeed);//Restore saved speed
	}
	
	void SetBrute()
	{
		let bruteSize = random(10.0, 30.0) / 10.0;
		float bruteScale = 0.6 + bruteSize / 3.0;
		
		A_SetScale(float(bruteScale));
		Health = Health * bruteSize;
	}
	
	void SetSpectre()
	{
		if (!IsSpectreable)
			return;

		A_SetRenderStyle(HR_SHADOW, STYLE_Translucent);
		DamageMultiply = 1.5;
	}
	
	void SetLeader()
	{
		if (BossType & WMF_POISON)
		{
			A_SetTranslation("GreenSkin");
			Health *= 2;
		}
		else
		{
			A_SetTranslation("StoneSkin");
			Health *= 3.5;
		}

		DamageMultiply += 1;
	}
	
	void SetRunt()
	{
		BaseSpeed = Speed;
		A_SetSpeed(Speed * 2);

		A_SetScale(0.5);
		DamageMultiply = 0.5;
		Health *= 0.5;
		bALWAYSFAST = true;
		
		BossType = 0; // Clear special damage
	}
	
	void ApplyRespawnBoss(int bossFlag)
	{
		SetNormal();
		
		BossType = bossFlag;

		//Runt cannot combine
		if (bossFlag & WMF_RUNT)
		{
			SetRunt();
		}
		else
		{
			if (bossFlag & WMF_BRUTE)
				SetBrute();
			if (bossFlag & WMF_SPECTRE)
				SetSpectre();
			if (bossFlag & WMF_LEADER)
				SetLeader();
		}

		//string msg = string.Format("Health %f, Damage Buff %f, Translation %d, Speed %d", Health, DamageMultiply, Translation, Speed);
		//Console.MidPrint (null, msg, true);
	}
	
	void WanderingMonsterRespawn()
	{
		int bossFlag = 0;
		if ((random(1,100) - RespawnLevel) < BOSSTYPE_CHANCE_BRUTE)
			bossFlag |= WMF_BRUTE;
		if ((random(1,100) - RespawnLevel) < BOSSTYPE_CHANCE_SPECTRE)
			bossFlag |= WMF_SPECTRE;
		if ((random(1,100) - (RespawnLevel / 2)) < BOSSTYPE_CHANCE_LEADER)
		{
			bossFlag |= WMF_LEADER;
			
			if (random(1,100) < BOSSTYPE_SUBCHANCE_POISON)
				bossFlag |= WMF_POISON;
		}
			
		if ((random(1,100)) < BOSSTYPE_CHANCE_RUNT) //since runts override all, do not scale their spawn chance with leveling
			bossFlag |= WMF_RUNT;
		
		RespawnWaitTics = 0;
		RespawnLevel = 1;

		A_Respawn(false);
		
		ApplyRespawnBoss(bossFlag);
	}
}

class PoisonBall : Actor
{
	Default
	{
		Radius 9;
		Height 8;
		Speed 12;
		FastSpeed 20;
		Damage 4;
		PoisonDamage 20;
		Projectile;
		-ACTIVATEIMPACT
		-ACTIVATEPCROSS
		-NOBLOCKMAP
		+WINDTHRUST
		+SPAWNSOUNDSOURCE
		+ZDOOMTRANS
		RenderStyle "Add";
		SeeSound "beast/attack";
		Translation "PoisonBall";
	}
	States
	{
	Spawn:
		FRB1 AABBCC 2 A_SpawnItemEx("PoisonPuffy", random2[BeastPuff]()*0.015625, random2[BeastPuff]()*0.015625, random2[BeastPuff]()*0.015625, 
									0,0,0,0,SXF_ABSOLUTEPOSITION, 64);
		Loop;
	Death:
		FRB1 DEFGH 4;
		Stop;
	}
}

class PoisonPuffy : Actor
{
	Default
	{
		Radius 6;
		Height 8;
		Speed 10;
		+NOBLOCKMAP
		+NOGRAVITY
		+MISSILE
		+NOTELEPORT
		+DONTSPLASH
		+ZDOOMTRANS
		RenderStyle "Add";
		Translation "PoisonBall";
	}
	States
	{
	Spawn:
		FRB1 DEFGH 4;
		Stop;
	}
}