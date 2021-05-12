
// Beast --------------------------------------------------------------------

class HRpgBeast : ExpSquishbag replaces Beast
{
	Default
	{
		Health 220;
		Radius 32;
		Height 74;
		Mass 200;
		Speed 14;
		Painchance 100;
		Monster;
		+FLOORCLIP
		SeeSound "beast/sight";
		AttackSound "beast/attack";
		PainSound "beast/pain";
		DeathSound "beast/death";
		ActiveSound "beast/active";
		Obituary "$OB_BEAST";
		Tag "$FN_BEAST";
		DropItem "CrossbowAmmo", 84, 10;
	}
	States
	{
	Spawn:
		BEAS AB 10 A_Look;
		Loop;
	See:
		BEAS ABCDEF 3 A_Chase;
		Loop;
	Missile:
		BEAS H 10 A_FaceTarget;
		BEAS I 10 A_CustomComboAttack("BeastBall", 32, random[BeastAttack](1,8)*3, "beast/attack");
		Goto See;
	Pain:
		BEAS G 3;
		BEAS G 3 A_Pain;
		Goto See;
	Death:
		BEAS R 6;
		BEAS S 6 A_Scream;
		BEAS TUV 6;
		BEAS W 6 A_NoBlocking;
		BEAS XY 6;
		BEAS Z -1;
		Stop;
	XDeath:
		BEAS J 5;
		BEAS K 6 A_Scream;
		BEAS L 5;
		BEAS M 6;
		BEAS N 5;
		BEAS O 6 A_NoBlocking;
		BEAS P 5;
		BEAS Q -1;
		Stop;
	}
}