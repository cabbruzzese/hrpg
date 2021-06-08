const MANA_SCALE_MOD = 5;

const SPELL_LEVEL_FIREBALL = 1;
const SPELL_LEVEL_ICE = 4;
const SPELL_LEVEL_VAMPIRE = 8;
const SPELL_LEVEL_VOLCANO = 12;
const SPELL_LEVEL_LIGHTNING = 16;

class HRpgBlasphemerPlayer : HRpgPlayer
{
	int maxMana;
	int mana;
	int manaTicks;
	int spellLock;
	property MaxMana : maxMana;
	property Mana : mana;
	property SpellLock : spellLock;
	
	Default
	{
		HRpgPlayer.ExpLevel 1;
		HRpgPlayer.Exp 0;
		HRpgPlayer.ExpNext XPMULTI;
		HRpgPlayer.Brt 5;
		HRpgPlayer.Trk 7;
		HRpgPlayer.Crp 10;
		
		HRpgBlasphemerPlayer.MaxMana 100 * MANA_SCALE_MOD;
		HRpgBlasphemerPlayer.Mana 100 * MANA_SCALE_MOD;
		HRpgBlasphemerPlayer.SpellLock 0;
		
		Player.MaxHealth HEALTHBASE - 25;
		Health HEALTHBASE - 25;
		Radius 16;
		Height 56;
		Mass 100;
		Painchance 255;
		Speed 0.9;
		Player.DisplayName "Blasphemer";
		Player.SpawnClass "Blasphemer";
		Player.StartItem "HRpgSpellBook";
		Player.StartItem "HRpgGoldWand";
		Player.StartItem "FireballSpell";
		Player.StartItem "GoldWandAmmo", 50;
		Player.WeaponSlot 1, "HRpgGauntlets", "HRpgSpellBook";
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
		PLAB A -1;
		Stop;
	See:
		PLAB ABCD 4;
		Loop;
	Melee:
	Missile:
		PLAB F 6 BRIGHT;
		PLAB E 12;
		Goto Spawn;
	Pain:
		PLAB G 4;
		PLAB G 4 A_Pain;
		Goto Spawn;
	Death:
		PLAB H 6 A_PlayerSkinCheck("AltSkinDeath");
		PLAB I 6 A_PlayerScream;
		PLAB JK 6;
		PLAB L 6 A_NoBlocking;
		PLAB MNO 6;
		PLAB P -1;
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
		PLAB H 10;
		PLAB I 10 A_PlayerScream;
		PLAB J 10 A_NoBlocking;
		PLAB KLM 10;
		PLAB N -1;
		Stop;
	AltSkinXDeath:
		PLAB O 5;
		PLAB P 5 A_XScream;
		PLAY Q 5 A_NoBlocking;
		PLAY RSTUV 5;
		PLAY W -1;
		Stop;
	}
	
	void GiveSpell(class<Inventory> itemtype)
	{
		let spell = GiveInventoryType(itemtype);

		if (spell)
			A_Print(spell.PickupMessage());
	}
	
	void GiveSpellsByLevel()
	{
		if (ExpLevel >= SPELL_LEVEL_FIREBALL)
			GiveSpell("FireballSpell");
		if (ExpLevel >= SPELL_LEVEL_ICE)
			GiveSpell("IceSpell");
		if (ExpLevel >= SPELL_LEVEL_VAMPIRE)
			GiveSpell("VampireSpell");
		if (ExpLevel >= SPELL_LEVEL_VOLCANO)
			GiveSpell("VolcanoSpell");
		if (ExpLevel >= SPELL_LEVEL_LIGHTNING)
			GiveSpell("LightningSpell");
	}
	
	override void BasicStatIncrease()
	{
		Crp += 1;
		
		int manaBonus = random(1, Crp);
		if (manaBonus < 5)
			manaBonus = 5;

		manaBonus *= MANA_SCALE_MOD;
		MaxMana += manaBonus;
		if (Mana < MaxMana)
			Mana = MaxMana;

		GiveSpellsByLevel();
	}
	
	override void Tick()
	{
		if (Mana < MaxMana)
		{
			int manaHeal = Crp / 10;
			if (manaHeal < 1)
				manaHeal = 1;
				
			Mana += manaHeal;
		}
		
		if (SpellLock > 0)
		{
			SpellLock--;
		}
		
		Super.Tick();
	}
	
	override void BeginPlay()
	{
		GiveSpellsByLevel();
		Super.BeginPlay();
	}
}
