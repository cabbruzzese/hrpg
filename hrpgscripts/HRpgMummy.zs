
// Mummy --------------------------------------------------------------------

class HRpgMummy : ExpSquishbag replaces Mummy
{
	Default
	{
		Health 80;
		Radius 22;
		Height 62;
		Mass 75;
		Speed 12;
		Painchance 128;
		Monster;
		+FLOORCLIP
		SeeSound "mummy/sight";
		AttackSound "mummy/attack1";
		PainSound "mummy/pain";
		DeathSound "mummy/death";
		ActiveSound "mummy/active";
		HitObituary "$OB_MUMMY";
		Tag "$FN_MUMMY";
		DropItem "GoldWandAmmo", 84, 3;
	}
	States
	{
	Spawn:
		MUMM AB 10 A_Look;
		Loop;
	See:
		MUMM ABCD 4 A_Chase;
		Loop;
	Melee:
		MUMM E 6 A_FaceTarget;
		MUMM F 6 A_CustomMeleeAttack(random[MummyAttack](1,8)*2, "mummy/attack2", "mummy/attack");
		MUMM G 6;
		Goto See;
	Pain:
		MUMM H 4;
		MUMM H 4 A_Pain;
		Goto See;
	Death:
		MUMM I 5;
		MUMM J 5 A_Scream;
		MUMM K 5 A_SpawnItemEx("MummySoul", 0,0,10, 0,0,1);
		MUMM L 5;
		MUMM M 5 A_NoBlocking;
		MUMM NO 5;
		MUMM P -1;
		Stop;
	}
}

// Mummy leader -------------------------------------------------------------

class HRpgMummyLeader : HRpgMummy replaces MummyLeader
{
	Default
	{
		Species "MummyLeader";
		Health 100;
		Painchance 64;
		Obituary "$OB_MUMMYLEADER";
		Tag "$FN_MUMMYLEADER";
	}
	States
	{
	Missile:
		MUMM X 5 A_FaceTarget;
		MUMM Y 5 Bright A_FaceTarget;
		MUMM X 5 A_FaceTarget;
		MUMM Y 5 Bright A_FaceTarget;
		MUMM X 5 A_FaceTarget;
		MUMM Y 5 Bright A_CustomComboAttack("MummyFX1", 32, random[MummyAttack2](1,8)*2, "mummy/attack2");
		Goto See;
	}
}