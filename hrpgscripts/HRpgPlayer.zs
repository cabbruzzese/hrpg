const XPMULTI = 1000;
const HEALTHBASE = 100;
const STATNUM = 4;
const REGENERATE_TICKS_MAX_DEFAULT = 32;
const REGENERATE_MIN_VALUE = 15;


class HRpgPlayer : HereticPlayer
{
	int expLevel;
	int exp;
	int expNext;
	int brt;
	int trk;
	int crp;
	int regenerateTicks;
	int regenerateTicksMax;

	property ExpLevel : expLevel;
	property Exp : exp;
	property ExpNext : expNext;
	property Brt : brt;
	property Trk : trk;
	property Crp : crp;
	property RegenerateTicks : regenerateTicks;
	property RegenerateTicksMax : regenerateTicksMax;

	Default
	{
		HRpgPlayer.ExpLevel 1;
		HRpgPlayer.Exp 0;
		HRpgPlayer.ExpNext XPMULTI;
		HRpgPlayer.RegenerateTicks 0;
		HRpgPlayer.RegenerateTicksMax REGENERATE_TICKS_MAX_DEFAULT;
		Player.MaxHealth HEALTHBASE;
		Health HEALTHBASE;
		Radius 16;
		Height 56;
		Mass 100;
		Painchance 255;
		Speed 1;
		Player.DisplayName "Corvus";
		Player.StartItem "HRpgGoldWand";
		Player.StartItem "HRpgStaff";
		Player.StartItem "GoldWandAmmo", 50;
		Player.WeaponSlot 1, "HRpgStaff", "HRpgGauntlets";
		Player.WeaponSlot 2, "HRpgGoldWand";
		Player.WeaponSlot 3, "HRpgCrossbow";
		Player.WeaponSlot 4, "HRpgBlaster";
		Player.WeaponSlot 5, "HRpgSkullRod";
		Player.WeaponSlot 6, "HRpgPhoenixRod";
		Player.WeaponSlot 7, "HRpgMace";

		Player.ColorRange 225, 240;
		Player.Colorset 0, "$TXT_COLOR_GREEN",		225, 240,  238;
		Player.Colorset 1, "$TXT_COLOR_YELLOW",		114, 129,  127;
		Player.Colorset 2, "$TXT_COLOR_RED",		145, 160,  158;
		Player.Colorset 3, "$TXT_COLOR_BLUE",		190, 205,  203;
		// Doom Legacy additions
		Player.Colorset 4, "$TXT_COLOR_BROWN",		 67,  82,   80;
		Player.Colorset 5, "$TXT_COLOR_LIGHTGRAY",	  9,  24,   22;
		Player.Colorset 6, "$TXT_COLOR_LIGHTBROWN",	 74,  89,   87;
		Player.Colorset 7, "$TXT_COLOR_LIGHTRED",	150, 165,  163;
		Player.Colorset 8, "$TXT_COLOR_LIGHTBLUE",	192, 207,  205;
		Player.Colorset 9, "$TXT_COLOR_BEIGE",		 95, 110,  108;
	}

	States
	{
	Spawn:
		PLAY A -1;
		Stop;
	See:
		PLAY ABCD 4;
		Loop;
	Melee:
	Missile:
		PLAY F 6 BRIGHT;
		PLAY E 12;
		Goto Spawn;
	Pain:
		PLAY G 4;
		PLAY G 4 A_Pain;
		Goto Spawn;
	Death:
		PLAY H 6 A_PlayerSkinCheck("AltSkinDeath");
		PLAY I 6 A_PlayerScream;
		PLAY JK 6;
		PLAY L 6 A_NoBlocking;
		PLAY MNO 6;
		PLAY P -1;
		Stop;
	XDeath:
		PLAY Q 0 A_PlayerSkinCheck("AltSkinXDeath");
		PLAY Q 5 A_PlayerScream;
		PLAY R 0 A_NoBlocking;
		PLAY R 5 A_SkullPop;
		PLAY STUVWX 5;
		PLAY Y -1;
		Stop;
	Burn:
		FDTH A 5 BRIGHT A_StartSound("*burndeath");
		FDTH B 4 BRIGHT;
		FDTH C 5 BRIGHT;
		FDTH D 4 BRIGHT A_PlayerScream;
		FDTH E 5 BRIGHT;
		FDTH F 4 BRIGHT;
		FDTH G 5 BRIGHT A_StartSound("*burndeath");
		FDTH H 4 BRIGHT;
		FDTH I 5 BRIGHT;
		FDTH J 4 BRIGHT;
		FDTH K 5 BRIGHT;
		FDTH L 4 BRIGHT;
		FDTH M 5 BRIGHT;
		FDTH N 4 BRIGHT;
		FDTH O 5 BRIGHT A_NoBlocking;
		FDTH P 4 BRIGHT;
		FDTH Q 5 BRIGHT;
		FDTH R 4 BRIGHT;
		ACLO E 35 A_CheckPlayerDone;
		Wait;
	AltSkinDeath:	
		PLAY H 10;
		PLAY I 10 A_PlayerScream;
		PLAY J 10 A_NoBlocking;
		PLAY KLM 10;
		PLAY N -1;
		Stop;
	AltSkinXDeath:
		PLAY O 5;
		PLAY P 5 A_XScream;
		PLAY Q 5 A_NoBlocking;
		PLAY RSTUV 5;
		PLAY W -1;
		Stop;
	}
	
	double GetScaledMod(int stat)
	{
		//First 10 scales to 1 by 10% increments
		if (stat <= 10)
			return stat * 0.1;
		
		//Remaining scales at 5% increments. 30 = double damage
		return 1 + ((stat - 10) * 0.05);
	}
	
	int GetModDamage(int damage, int stat, int scaled)
	{
		double mod = stat / 10.0;
		if (scaled)
			mod = GetScaledMod(stat);

		let modDamage = damage * mod;
		
		if (modDamage < 1)
			return 1;

		return modDamage;
	}
	
	int GetDamageForMelee(int damage)
	{
		return GetModDamage(damage, Brt, 1);
	}
	
	int GetDamageForWeapon(int damage)
	{
		return GetModDamage(damage, Trk, 1);
	}
	
	int GetDamageForMagic(int damage)
	{
		return GetModDamage(damage, Crp, 1);
	}

	void SetProjectileDamage(Actor proj, int stat)
	{
		if (!proj)
			return;
		
		let newDamage = GetModDamage(proj.Damage, stat, 1);
		
		proj.SetDamage(newDamage);
	}
	
	void SetProjectileDamageForMelee(Actor proj)
	{
		SetProjectileDamage(proj, Brt);
	}

	void SetProjectileDamageForWeapon(Actor proj)
	{
		SetProjectileDamage(proj, Trk);
	}

	void SetProjectileDamageForMagic(Actor proj)
	{
		SetProjectileDamage(proj, Crp);
	}
	
	int CalcXPNeeded()
	{
		return ExpLevel * XPMULTI;
	}
	
	void GiveXP (int expEarned)
	{
		Exp += expEarned;
		
		while (Exp >= ExpNext)
		{
			GainLevel();
		}
	}
	
	virtual void BasicStatIncrease()
	{
	}
	
	void DoLevelGainBlend()
	{
		let blendColor = Color(122,	122, 122, 122);
		A_SetBlend(blendColor, 0.8, 40);
		
		string lvlMsg = String.Format("You are now level %d", ExpLevel);
		A_Print(lvlMsg);
	}
	
	//Gain a level
	void GainLevel()
	{
		if (Exp < ExpNext)
			return;

		ExpLevel++;
		Exp = Exp - ExpNext;
		ExpNext = CalcXpNeeded();		
					
		DoLevelGainBlend();

		//Distribute points randomly, giving weight to highest stats
		int statPoints = STATNUM;
		while (statPoints > 0)
		{
			int statStack = Brt + Trk + Crp;
			
			double rand = random(1, statStack);
			if (rand <= Brt)
			{
				Brt += 1;
			}
			else if (rand <= Brt + Trk)
			{
				Trk += 1;
			}
			else
			{
				Crp += 1;
			}
			statPoints--;
		}
		
		//BasicStatIncrease to call overrides in classes
		BasicStatIncrease();

		//health increases by random up to Brutality, min 5 (weighted for low end of flat scale)
		int healthBonus = random(1, Brt);
		if (healthBonus < 5)
			healthbonus = 5;

		int newHealth = MaxHealth + healthBonus;
		MaxHealth = newHealth;
		if (Health < MaxHealth)
			A_SetHealth(MaxHealth);
	}

	void RegenerateHealth(int regenMax)
	{
		regenMax = Max(regenMax, REGENERATE_MIN_VALUE);
		if (Health < regenMax)
			GiveBody(1);
	}

	virtual void Regenerate() { }

	bool TryUsePowerupGiver (Class<Actor> powerupType)
	{
		if (powerupType == NULL) return true;	// item is useless

		let power = PowerupGiver(Spawn (powerupType));

		if (power.CallTryPickup (self))
		{
			return true;
		}
		power.Destroy();
		return false;
	}

	override void Tick()
	{
		RegenerateTicks++;
		if (RegenerateTicks > RegenerateTicksMax)
		{
			RegenerateTicks = 0;

			if (Health > 0)
			{
				Regenerate();
			}
		}

		Super.Tick();
	}

	override void CheatGive (String name, int amount)
	{
		let player = self.player;

		if (player.mo == NULL || player.health <= 0)
		{
			return;
		}

		if (name ~== "blackmoor" || name ~== "tonisborg")
		{			
			GiveXP(1000);
			return;
		}

		if (name ~== "thac0")
		{			
			GiveXP(5000);
			return;
		}

		if (name ~== "arneson" || name ~== "gygax")
		{			
			GiveXP(50000);
			return;
		}

		Super.CheatGive(name, amount);
	}
}
