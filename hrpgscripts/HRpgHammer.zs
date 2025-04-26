const HAMMER_MELEE_RANGE = DEFMELEERANGE * 1.25;

class HRpgHammer : HeathenWeapon
{
	Default
	{
		Weapon.SelectionOrder 2100;
		Weapon.sisterweapon "HRpgHammerPowered";
		Obituary "$OB_MPHAMMER";
		Tag "$TAG_HAMMER";
		Scale 1.4;
	}

	States
	{
	Ready:	
		WARH A 1 A_WeaponReady;
		Loop;
	Deselect:
		WARH A 1 A_Lower;
		Loop;
	Select:
		WARH A 1 A_Raise;
		Loop;
	Fire:
		WARH A 3;
		WARH B 3;
		WARH C 3;
		WARH D 3 A_HeathenMeleeAttack(random(15, 35), 125, "WarhammerPuff", HAMMER_MELEE_RANGE);
		WARH E 2;
		WARH F 2;
		TNT1 A 10;
		WARH A 2 A_ReFire;
		Goto Ready;
	AltFire:
		WARH A 3 A_Mirror;
		WARH B 3;
		WARH C 3;
		WARH D 3 A_HeathenMeleeAttack(random(15, 35), 125, "WarhammerPuff", HAMMER_MELEE_RANGE);
		WARH E 2;
		WARH F 2;
		TNT1 A 10 A_RestoreMirror;
		WARH A 2 A_ReFire;
		Goto Ready;
	}
}

class HRpgHammerPowered : HRpgHammer
{
	Default
	{
		Weapon.sisterweapon "HRpgHammer";
		+WEAPON.POWERED_UP
		+WEAPON.READYSNDHALF
		+WEAPON.STAFF2_KICKBACK
		Obituary "$OB_MPPHAMMER";
		Tag "$TAG_HAMMER";
	}

	States
	{
	Ready:	
		WARH G 1 A_WeaponReady;
		Loop;
	Deselect:
		WARH G 1 A_Lower;
		Loop;
	Select:
		WARH G 1 A_Raise;
		Loop;
	Fire:
		WARH G 3;
		WARH H 3;
		WARH I 3;
		WARH J 3;
		WARH K 3 A_HeathenMeleeAttack(random(45, 70), 175, "WarhammerPuff2", HAMMER_MELEE_RANGE);
		WARH L 2;
		TNT1 A 10;
		WARH G 2 A_ReFire;
		Goto Ready;
	AltFire:
		WARH G 3;
		WARH H 3;
		WARH I 3 A_HammerFire(-10);
		WARH J 3 A_StartSound("mummy/attack1");
		WARH K 3 A_HammerFire(10);
		WARH L 2;
		TNT1 A 10;
		WARH G 2 A_ReFire;
		Goto Ready;
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_HammerFire
	//
	//----------------------------------------------------------------------------

	action void A_HammerFire (double fireAngle)
	{
		if (player == null)
		{
			return;
		}
		
		let hrpgPlayer = HRpgPlayer(player.mo);
		
		let mo = SpawnPlayerMissile ("WarhammerFx1", angle + fireAngle);
		
		//Scale up damage with level
		if (hrpgPlayer != null)
		{
			hrpgPlayer.SetProjectileDamageForWeapon(mo);
		}
	}
}

class WarhammerFx1 : Actor 
{
	Default
	{
		Radius 11;
		Height 8;
		Speed 14;
		Damage 12;
		Projectile;
		DeathSound "dsparil/explode";
		Obituary "$OB_MPPHAMMERMAGIC";
	}

	States
	{
	Spawn:
		FX05 DEFG 6 BRIGHT;
		Stop;
	Death:
		FX16 GHIJKL 4 BRIGHT;
		Stop;
	}
}

class WarhammerPuff : Actor
{
	Default
	{
		RenderStyle "Translucent";
		Alpha 0.4;
		VSpeed 1;
		+NOBLOCKMAP
		+NOGRAVITY
		+PUFFONACTORS
		AttackSound "mummy/attack2";
		ActiveSound "mummy/attack1";
	}

	States
	{
	Spawn:
		PUF3 A 4 BRIGHT;
		PUF3 BCD 4;
		Stop;
	}
}

class WarhammerPuff2 : Actor
{
	Default
	{
		RenderStyle "Translucent";
		Alpha 0.4;
		VSpeed 1;
		+NOBLOCKMAP
		+NOGRAVITY
		+PUFFONACTORS
		AttackSound "weapons/staffpowerhit";
		ActiveSound "mummy/attack1";
	}

	States
	{
	Spawn:
		FX16 GHIJKL 4 BRIGHT;
		Stop;
	}
}

class WarhammerPuffSilent : WarhammerPuff
{
	Default
	{
		ActiveSound "";
	}
}