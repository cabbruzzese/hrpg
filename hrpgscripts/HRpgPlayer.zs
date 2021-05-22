const XPMULTI = 1000;
const HEALTHBASE = 80;
const STATNUM = 3;

class HRpgPlayer : HereticPlayer
{
	int expLevel;
	int exp;
	int expNext;
	int brt;
	int trk;
	int crp;
	property ExpLevel : expLevel;
	property Exp : exp;
	property ExpNext : expNext;
	property Brt : brt;
	property Trk : trk;
	property Crp : crp;
	
	Default
	{
		HRpgPlayer.ExpLevel 1;
		HRpgPlayer.Exp 0;
		HRpgPlayer.ExpNext XPMULTI;
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
	
	int GetModDamage(int damage, int stat)
	{
		double mod = stat / 10.0;
		let damageMod = damage * mod;
		
		if (damageMod < 1)
			return 1;

		return damageMod;
	}
	
	int GetDamageForMelee(int damage)
	{
		return GetModDamage(damage, Brt);
	}
	
	int GetDamageForWeapon(int damage)
	{
		return GetModDamage(damage, Trk);
	}
	
	int GetDamageForMagic(int damage)
	{
		return GetModDamage(damage, Crp);
	}

	void SetProjectileDamage(Actor proj, int stat)
	{
		if (!proj)
			return;
		
		let newDamage = GetModDamage(proj.Damage, stat);
		
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
	
	//Gain a level
	void GainLevel()
	{
		if (Exp < ExpNext)
			return;

		ExpLevel++;
		Exp = Exp - ExpNext;
		ExpNext = CalcXpNeeded();
		
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
		
		//All stats increase by 1
		Brt += 1;
		Trk += 1;
		Crp += 1;

		//health increases by Brutality
		int newHealth = MaxHealth + Brt;
		MaxHealth = newHealth;
		if (Health < MaxHealth)
			A_SetHealth(MaxHealth);
	}
}
