const MAXXPHIT = 75;

const RESPAWN_TICS_MIN = 1200; //1 minute
const RESPAWN_TICS_MAX = 24000; //20 minutes

const BOSSTYPE_CHANCE_BRUTE = 10;
const BOSSTYPE_CHANCE_SPECTRE = 4;
const BOSSTYPE_CHANCE_LEADER = 2;
const BOSSTYPE_CHANCE_RUNT = 6;

enum EWanderingMonsterFlags
{
	WMF_BRUTE = 1,
	WMF_SPECTRE = 2,
	WMF_LEADER = 4,
	WMF_RUNT = 8
};

class ExpSquishbag : Actor
{
	int respawnWaitTics;
	int respawnWaitBonus;
	int respawnLevel;
	bool isRespawnable;
	bool IsSpectreable;
	int baseSpeed;
	property RespawnWaitTics : respawnWaitTics;
	property RespawnWaitBonus : respawnWaitBonus;
	property RespawnLevel : respawnLevel;
	property IsRespawnable : isRespawnable;
	property IsSpectreable : isSpectreable;
	property BaseSpeed : baseSpeed;
	
	Default
	{
		ExpSquishbag.RespawnWaitTics 0;
		ExpSquishbag.RespawnWaitBonus 0;
		ExpSquishbag.respawnLevel 1;
		ExpSquishbag.IsRespawnable false;
		ExpSquishbag.IsSpectreable true;
		ExpSquishbag.BaseSpeed -1;
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
		A_SetRenderStyle(1.0, STYLE_Normal);
		Translation = 0;
		bALWAYSFAST = false;
		
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
		A_SetTranslation("Ice");

		DamageMultiply += 1;
		Health *= 2;
	}
	
	void SetRunt()
	{
		BaseSpeed = Speed;
		A_SetSpeed(Speed * 2);

		A_SetScale(0.5);
		DamageMultiply = 0.5;
		Health *= 0.5;
		bALWAYSFAST = true;
	}
	
	void ApplyRespawnBoss(int bosstype)
	{
		SetNormal();

		//Runt cannot combine
		if (bosstype & WMF_RUNT)
		{
			SetRunt();
		}
		else
		{
			if (bosstype & WMF_BRUTE)
				SetBrute();
			if (bosstype & WMF_SPECTRE)
				SetSpectre();
			if (bosstype & WMF_LEADER)
				SetLeader();
		}

		//string msg = string.Format("Health %f, Damage Buff %f, Translation %d, Speed %d", Health, DamageMultiply, Translation, Speed);
		//Console.MidPrint (null, msg, true);
	}
	
	void WanderingMonsterRespawn()
	{
		int bossType = 0;
		if ((random(1,100) - RespawnLevel) < BOSSTYPE_CHANCE_BRUTE)
			bossType |= WMF_BRUTE;
		if ((random(1,100) - RespawnLevel) < BOSSTYPE_CHANCE_SPECTRE)
			bossType |= WMF_SPECTRE;
		if ((random(1,100) - (RespawnLevel / 2)) < BOSSTYPE_CHANCE_LEADER)
			bossType |= WMF_LEADER;
			
		if ((random(1,100)) < BOSSTYPE_CHANCE_RUNT) //since runts override all, do not scale their spawn chance with leveling
			bossType |= WMF_RUNT;
		
		RespawnWaitTics = 0;
		RespawnLevel = 1;

		A_Respawn(false);
		
		ApplyRespawnBoss(bossType);
	}
}