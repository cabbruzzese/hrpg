const MAXXPHIT = 75;

const RESPAWN_TICS_MIN = 1200; //1 minute
const RESPAWN_TICS_MAX = 18000; //15 minutes

const BOSSTYPE_CHANCE_BRUTE = 10;
const BOSSTYPE_CHANCE_SPECTRE = 4;
const BOSSTYPE_CHANCE_LEADER = 2;
const BOSSTYPE_CHANCE_RUNT = 6;
const BOSSTYPE_SUBCHANCE_POISON = 25;
const BOSSTYPE_SUBCHANCE_ICE = 25;
const BOSSTYPE_SUBCHANCE_FIRE = 25;

const SNEAK_ATTACK_BONUS = 3.0;
const SNEAK_DELAY_TIME = 20;

enum EWanderingMonsterFlags
{
	WMF_BRUTE = 1,
	WMF_SPECTRE = 2,
	WMF_LEADER = 4,
	WMF_RUNT = 8
};

enum ELeaderTypeFlags
{
	WML_STONE = 1,
	WML_POISON = 2,
	WML_ICE = 4,
	WML_FIRE = 8
};

class ExpSquishbag : Actor
{
	int respawnWaitTics;
	int respawnWaitBonus;
	int respawnLevel;
	bool isRespawnable;
	bool isSpectreable;
	bool isBossOnly;
	int baseSpeed;
	int leaderType;
	int sneakDelay;
	property RespawnWaitTics : respawnWaitTics;
	property RespawnWaitBonus : respawnWaitBonus;
	property RespawnLevel : respawnLevel;
	property IsRespawnable : isRespawnable;
	property IsSpectreable : isSpectreable;
	property BaseSpeed : baseSpeed;
	property LeaderType : leaderType;
	property IsBossOnly : isBossOnly;
	property SneakDelay : sneakDelay;
	
	Default
	{
		ExpSquishbag.RespawnWaitTics 0;
		ExpSquishbag.RespawnWaitBonus 0;
		ExpSquishbag.respawnLevel 1;
		ExpSquishbag.IsRespawnable false;
		ExpSquishbag.IsSpectreable true;
		ExpSquishbag.BaseSpeed -1;
		ExpSquishbag.LeaderType 0;
		ExpSquishbag.IsBossOnly false;
		ExpSquishbag.SneakDelay 0;
	}
	
	void A_CustomComboAttack2(class<Actor> missiletype, double spawnheight, int damage, sound meleesound = "", name damagetype = "none", bool bleed = true)
	{
		if (LeaderType & WML_POISON)
			missileType = "PoisonBall";
		else if (LeaderType & WML_ICE)
			missileType = "HeadFX1";
		else if (LeaderType & WML_FIRE)
		{			
			A_FireVolcanoShot(target);
			return;
		}
			
		A_CustomComboAttack(missiletype, spawnheight, damage, meleesound, damagetype, bleed);
	}
	
	void A_FireVolcanoShot(Actor targ)
	{
		SpawnMissileAngleZSpeed(pos.Z + 36, "VolcanoMonsterBlast", angle + 0, 1, 12, self);
		SpawnMissileAngleZSpeed(pos.Z + 36, "VolcanoMonsterBlast", angle + 6, 1, 10, self);
		SpawnMissileAngleZSpeed(pos.Z + 36, "VolcanoMonsterBlast", angle - 6, 1, 10, self);
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
			
			let hereticPlayer = HRpgHereticPlayer(hrpgPlayer);
			if (hereticPlayer)
			{
				//Sneak attack
				if (target != hereticPlayer || sneakDelay > 0)
				{
					damage *= SNEAK_ATTACK_BONUS;
					hereticPlayer.A_Print("Surprise Attack!");
					
					sneakDelay = 0;
				}
			}
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
		
		if (!target)
		{
			SneakDelay = SNEAK_DELAY_TIME;
		}
		if (sneakDelay > 0)
			sneakDelay--;
		
		Super.Tick();
	}
	
	void SetNormal()
	{
		A_SetScale(1);
		DamageMultiply = 1;
		Translation = 0;
		bALWAYSFAST = false;
		LeaderType = 0;
		
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
		if (LeaderType & WML_ICE)
		{
			A_SetTranslation("Ice");
			Health *= 2;
		}
		else if (LeaderType & WML_POISON)
		{
			A_SetTranslation("GreenSkin");
			Health *= 2;
		}
		else if (LeaderType & WML_FIRE)
		{
			A_SetTranslation("RedSkin");
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
		
		LeaderType = 0; // Clear special damage
	}
	
	void ApplyRespawnBoss(int bossFlag, int leaderFlag)
	{
		SetNormal();
		
		LeaderType = leaderFlag;

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
	}
	
	void WanderingMonsterRespawn()
	{
		int bossFlag = 0;
		int leaderFlag = 0;
		if ((random(1,100) - RespawnLevel) < BOSSTYPE_CHANCE_BRUTE)
			bossFlag |= WMF_BRUTE;
		if ((random(1,100) - RespawnLevel) < BOSSTYPE_CHANCE_SPECTRE)
			bossFlag |= WMF_SPECTRE;
		if ((random(1,100) - RespawnLevel) < BOSSTYPE_CHANCE_LEADER)
		{
			bossFlag |= WMF_LEADER;
			
			let bossRoll = random(1,100);
			if (bossRoll < BOSSTYPE_SUBCHANCE_POISON)
				leaderFlag = WML_POISON;
			else if (bossRoll < BOSSTYPE_SUBCHANCE_POISON + BOSSTYPE_SUBCHANCE_ICE)
				leaderFlag = WML_ICE;
			else if (bossRoll < BOSSTYPE_SUBCHANCE_POISON + BOSSTYPE_SUBCHANCE_ICE + BOSSTYPE_SUBCHANCE_FIRE)
				leaderFlag = WML_FIRE;
			else
				leaderFlag = WML_STONE;
		}
			
		if ((random(1,100)) < BOSSTYPE_CHANCE_RUNT) //since runts override all, do not scale their spawn chance with leveling
			bossFlag = WMF_RUNT;

		//If only respawns bosses, reset timer and try again later
		if (IsBossOnly && leaderFlag == 0)
		{
			RespawnWaitTics = random(RESPAWN_TICS_MIN, RESPAWN_TICS_MAX);//no bonus for this respawnLevel
			return;
		}
		
		RespawnWaitTics = 0;
		RespawnLevel = 1;

		A_Respawn(false);
		
		ApplyRespawnBoss(bossFlag, leaderFlag);
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

class VolcanoMonsterBlast : Actor
{
	Default
	{
		Radius 8;
		Height 8;
		Speed 10;
		Damage 4;
		DamageType "Fire";
		Gravity 0.125;
		+NOBLOCKMAP +MISSILE +DROPOFF
		+NOTELEPORT
		DeathSound "world/volcano/blast";
	}

	States
	{
	Spawn:
		VFBL AB 4 BRIGHT A_SpawnItemEx("Puffy", random2[BeastPuff]()*0.015625, random2[BeastPuff]()*0.015625, random2[BeastPuff]()*0.015625, 
									0,0,0,0,SXF_ABSOLUTEPOSITION, 64);
		Loop;

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
}