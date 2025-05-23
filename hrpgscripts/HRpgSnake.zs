
class HRpgSnake : ExpSquishbag replaces Snake
{
	Default
	{
		Health 280;
		Radius 22;
		Height 70;
		Speed 10;
		Painchance 48;
		Monster;
		+FLOORCLIP
		AttackSound "snake/attack";
		SeeSound "snake/sight";
		PainSound "snake/pain";
		DeathSound "snake/death";
		ActiveSound "snake/active";
		Obituary "$OB_SNAKE";
		Tag "$FN_SNAKE";
		DropItem "PhoenixRodAmmo", 84, 5;
		
		ExpSquishbag.IsRespawnable true;
		ExpSquishbag.isSpawnLess true;
	}
	States
	{
	Spawn:
		SNKE AB 10 A_Look;
		Loop;
	See:
		SNKE ABCD 4 A_Chase;
		Loop;
	Missile:
		SNKE FF 5 A_FaceTarget;
		SNKE FFF 4 A_SpawnProjectile("SnakeProjA", 32, 0, 0, CMF_CHECKTARGETDEAD);
		SNKE FFF 5 A_FaceTarget;
		SNKE F 4 A_SnakeAttackBig;
		Goto See;
	Pain:
		SNKE E 3;
		SNKE E 3 A_Pain;
		Goto See;
	Death:
		SNKE G 5;
		SNKE H 5 A_Scream;
		SNKE IJKL 5;
		SNKE M 5 A_NoBlocking;
		SNKE NO 5;
		SNKE P -1;
		Stop;
	}
	
	void A_SnakeAttackBig()
	{
		if (LeaderType & WML_POISON)
		{
			A_SpawnProjectile("PoisonBall", 32, 0, 0, CMF_CHECKTARGETDEAD);
		}
		else if (LeaderType & WML_ICE)
		{
			A_SpawnProjectile("HeadFX1", 32, 0, 0, CMF_CHECKTARGETDEAD);
		}
		else if (LeaderType & WML_FIRE)
		{
			A_FireVolcanoShot(target);
		}
		else if (LeaderType & WML_DEATH)
		{
			A_FireDeathShot(target);
		}
		else if (LeaderType & WML_LIGHTNING)
		{
			A_SpawnProjectile("LightningMonsterBlast", 32, 0, 0, CMF_CHECKTARGETDEAD);
		}
		else
		{
			A_SpawnProjectile("SnakeProjB", 32, 0, 0, CMF_CHECKTARGETDEAD);
		}
	}
}