class HRpgHeathenPlayer : HRpgPlayer
{
	Default
	{
		HRpgPlayer.ExpLevel 1;
		HRpgPlayer.Exp 0;
		HRpgPlayer.ExpNext XPMULTI;
		HRpgPlayer.Brt 10;
		HRpgPlayer.Trk 7;
		HRpgPlayer.Crp 5;
		
		Player.MaxHealth HEALTHBASE + 25;
		Health HEALTHBASE + 25;
		Radius 16;
		Height 56;
		Mass 100;
		Painchance 255;
		Speed 1;
		Player.DisplayName "Heathen";
		Player.SpawnClass "Heathen";
		Player.StartItem "HRpgHammer";
		Player.StartItem "HRpgGoldWand";
		Player.StartItem "GoldWandAmmo", 50;
		Player.WeaponSlot 1, "HRpgGauntlets", "HRpgHammer";
		Player.WeaponSlot 2, "HRpgGoldWand";
		Player.WeaponSlot 3, "HRpgWarAxe";
		Player.WeaponSlot 4, "HRpgFlail";
		Player.WeaponSlot 5, "HRpgTrident";
		Player.WeaponSlot 6, "HRpgMaul";
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
		RNDY A -1;
		Stop;
	See:
		RNDY ABCD 4;
		Loop;
	Melee:
	Missile:
		RNDY F 6 BRIGHT;
		RNDY E 12;
		Goto Spawn;
	Pain:
		RNDY G 4;
		RNDY G 4 A_Pain;
		Goto Spawn;
	Death:
		RNDY H 6 A_PlayerSkinCheck("AltSkinDeath");
		RNDY I 6 A_PlayerScream;
		RNDY JK 6;
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
		RNDY H 10;
		RNDY I 10 A_PlayerScream;
		RNDY J 10 A_NoBlocking;
		RNDY K 10;
		PLAY LM 10;
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
	
	override void BasicStatIncrease()
	{
		Brt += 1;
	}

	void RegenerateArmor(int regenMax)
	{
		int SaveAmount = SKULLITEM_ARMOR;
		let armor = FindInventory("BasicArmor");

		if (!armor || armor.Amount == 0)
		{
			class<Inventory> armorClass = "HeathenShield";
			armor = GiveInventoryType(armorClass);
		}

		if (armor.Amount >= regenMax)
			return;
		
		armor.Amount++;
	}

	const ARMOR_REGEN_MAX = 50;
	override void Regenerate ()
	{
		int strengthRegen = Brt / 2 + REGENERATE_MIN_VALUE;
		RegenerateHealth(strengthRegen);

		int armorRegenMax = Min(Brt / 2, ARMOR_REGEN_MAX);
		RegenerateArmor(armorRegenMax);
	}
}



// Silver Shield (Shield1) --------------------------------------------------
Class HeathenShield : BasicArmorPickup
{
	Default
	{
		+FLOATBOB
		Inventory.Pickupmessage "$TXT_ITEMSHIELDH";
		Inventory.Icon "SHLDC0";
		Armor.Savepercent 25;
		Armor.Saveamount 1;
	}
	States
	{
	Spawn:
		SHLD C -1;
		stop;
	}
}