class HRpgClink : ExpSquishbag replaces Clink
{
	Default
	{
		Health 150;
		Radius 20;
		Height 64;
		Mass 75;
		Speed 14;
		Painchance 32;
		Monster;
		+NOBLOOD
		+FLOORCLIP
		SeeSound "clink/sight";
		AttackSound "clink/attack";
		PainSound "clink/pain";
		DeathSound "clink/death";
		ActiveSound "clink/active";
		Obituary "$OB_CLINK";
		Tag "$FN_CLINK";
		DropItem "SkullRodAmmo", 84, 20;
		
		ExpSquishbag.IsRespawnable true;
		ExpSquishbag.isSpawnLess true;
	}
	States
	{
	Spawn:
		CLNK AB 10 A_Look;
		Loop;
	See:
		CLNK ABCD 3 A_Chase;
		Loop;
	Melee:
		CLNK E 5 A_FaceTarget;
		CLNK F 4 A_FaceTarget;
		CLNK G 7 A_CustomMeleeAttack(random[ClinkAttack](3,9), "clink/attack", "clink/attack");
		Goto See;
	Pain:
		CLNK H 3;
		CLNK H 3 A_Pain;
		Goto See;
	Death:
		CLNK IJ 6;
		CLNK K 5 A_Scream;
		CLNK L 5 A_NoBlocking;
		CLNK MN 5;
		CLNK O -1;
		Stop;
	}
}

