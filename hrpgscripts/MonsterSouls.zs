class DeadMonsterCounter : Actor
{
}

class MonsterSoul:MummySoul
{
	Default
	{
		Scale 1.5;
		DeathSound "mummy/death";
	}
  
	States
	{
	Spawn:
		TNT1 A 6;
		TNT1 A 0 A_Scream;
		MUMM QRS 5;
		MUMM TUVW 9;
		FDT2 O 5 A_StartSound("beast/attack");
		FDT2 PQR 5;
		Stop;
	}
}

class PositionTester: Barrel
{
	States
	{
	Spawn:
		TNT1 A 1;
		Loop;
	}
}

class WinTrophy:Actor
{
	Default
	{
		-SOLID;
		+NOBLOCKMAP;
		//+NOINTERACTION;
		-NOGRAVITY;
		DeathSound "world/amb6";
		Scale 0.75;
		Translation "LightningSkin";
	}

	States
	{
	Spawn:
		TNT1 A 12;
		TNT1 A 0 Bright A_Scream;
		TROP A 5 Bright;
		Goto Stay;
	Stay:
		TROP A 5 Bright;
		Loop;
	}
}
class WinTrophyBase:Actor
{
	Default
	{
		-SOLID;
		+NOBLOCKMAP;
		+NOINTERACTION;
		Translation "LightningSkin";
	}

	States
	{
	Spawn:
		SMPL A 2 Bright;
		Loop;
	}
}

class SoulGlitter:TeleGlitter1 // Let your soul GLOW!!!!
{
	Default
	{
		-SOLID;
		+NOBLOCKMAP;
		+NOINTERACTION;
		Translation "DeathSkin";
		RenderStyle "Translucent";
		Alpha 0.4;
	}

	States
	{
	Spawn:
		TGLT A 5 Bright;
		TGLT B 5 Bright A_AccTeleGlitter;
		TGLT C 5 Bright;
		TGLT D 5 Bright A_AccTeleGlitter;
		TGLT E 5 Bright;
		TGLT A 5 Bright;
		TGLT B 5 Bright A_AccTeleGlitter;
		TGLT C 5 Bright;
		TGLT D 5 Bright A_AccTeleGlitter;
		TGLT E 5 Bright;
		TGLT A 5 Bright;
		TGLT B 5 Bright A_AccTeleGlitter;
		TGLT C 5 Bright;
		TGLT D 5 Bright A_AccTeleGlitter;
		TGLT E 5 Bright;
		TGLT A 5 Bright;
		TGLT B 5 Bright A_AccTeleGlitter;
		TGLT C 5 Bright;
		TGLT D 5 Bright A_AccTeleGlitter;
		TGLT E 5 Bright;
		Stop;
	}
}

class MonsterStarsMarker : MapMarker
{
	Default
	{
		Translation "DeathSkin";
		RenderStyle "Translucent";
		Alpha 0.4;
		Scale 0.7;
	}

	States
	{
	Spawn:
		TGLT ABCDE 4;
		Loop;
	}
}

class MonsterMapTracker : MonsterStarsMarker
{
	Actor monsterTracker;
	Default
	{
		Translation "DeathSkin";
		Alpha 0.4;
		Scale 0.3;
		AutomapOffsets (0,-700);
	}

	States
	{
	Spawn:
//		IMPX ABC 3;
		MUMS A 4;
		Loop;
	Death:
//		IMPX STUVWXYZ 3;
		MUMS ABCD 9;
		Stop;
	}

	void EndTracker()
	{
		monsterTracker = null;
		SetStateLabel ("Death");
	}

	override void Tick()
	{
		if (monsterTracker)
			SetOrigin(monsterTracker.Pos, true);
		
		Super.Tick();
	}
}

class MonsterBurstMarker : MapMarker
{
	Default
	{
		Translation "DeathSkin";
		RenderStyle "Translucent";
		Alpha 0.4;
		Scale 0.5;
	}

	States
	{
	Spawn:
		FX15 CBA 8;
        FX15 DEFG 4;
		Stop;
	}
}

class MonsterStars : Powerup
{
	Actor mapMark;
	int starTics;
	Default
	{
		+INVENTORY.UNDROPPABLE
        +INVENTORY.UNTOSSABLE
        +INVENTORY.AUTOACTIVATE
        +INVENTORY.PERSISTENTPOWER
        +INVENTORY.UNCLEARABLE

        Powerup.Duration 0x7FFFFFFF;
	}

	void DestroyMapMarker()
	{
		if (mapMark)
		{
			mapMark.Destroy();
			mapMark = null;
		}
	}

	void AddMapBurst(Actor other)
	{
        if (other)
		    other.A_SpawnItemEx("MonsterBurstMarker");
	}

	void AddMapMarker(Actor other)
	{
		bool success = false;
		[success, mapMark] = other.A_SpawnItemEx("MonsterStarsMarker");
	}

	override void AttachToOwner(Actor other)
	{
		if (mapMark)
			DestroyMapMarker();
		
		AddMapMarker(other);

		Super.AttachToOwner(other);
	}

	override void DetachFromOwner()
	{
        //Add to same position as map marker
        AddMapBurst(mapMark);

		DestroyMapMarker();

		Super.DetachFromOwner();
	}

	override void Tick()
	{
		starTics--;
		if (starTics <= 0)
		{
			starTics = random[SoulGlitter](5,35);
			if (Owner)
				Owner.A_SpawnItemEx("SoulGlitter", random[SoulGlitter](0,31)-16, random[SoulGlitter](0,31)-16, 1, 0, 0, 0.18);
		}
		Super.Tick();
	}
}