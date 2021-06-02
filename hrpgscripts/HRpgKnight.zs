
// Knight -------------------------------------------------------------------

class HRpgKnight : ExpSquishbag replaces Knight
{
	Default
	{
		Health 200;
		Radius 24;
		Height 78;
		Mass 150;
		Speed 12;
		Painchance 100;
		Monster;
		+FLOORCLIP
		SeeSound "hknight/sight";
		AttackSound "hknight/attack";
		PainSound "hknight/pain";
		DeathSound "hknight/death";
		ActiveSound "hknight/active";
		Obituary "$OB_BONEKNIGHT";
		HitObituary "$OB_BONEKNIGHTHIT";
		Tag "$FN_BONEKNIGHT";
		DropItem "CrossbowAmmo", 84, 5;
		
		ExpSquishbag.IsRespawnable true;
	}
	
	States
	{
	Spawn:
		KNIG AB 10 A_Look;
		Loop;
	See:
		KNIG ABCD 4 A_Chase;
		Loop;
	Melee:
	Missile:
		KNIG E 10 A_FaceTarget;
		KNIG F 8 A_FaceTarget;
		KNIG G 8 A_KnightAttack;
		KNIG E 10 A_FaceTarget;
		KNIG F 8 A_FaceTarget;
		KNIG G 8 A_KnightAttack;
		Goto See;
	Pain:
		KNIG H 3;
		KNIG H 3 A_Pain;
		Goto See;
	Death:
		KNIG I 6;
		KNIG J 6 A_Scream;
		KNIG K 6;
		KNIG L 6 A_NoBlocking;
		KNIG MN 6;
		KNIG O -1;
		Stop;
	}

	//----------------------------------------------------------------------------
	//
	// PROC A_KnightAttack
	//
	//----------------------------------------------------------------------------

	void A_KnightAttack ()
	{
		let targ = target;
		if (!targ) return;
		if (CheckMeleeRange ())
		{
			int damage = random[KnightAttack](1, 8) * 3;
			int newdam = targ.DamageMobj (self, self, damage, 'Melee');
			targ.TraceBleed (newdam > 0 ? newdam : damage, self);
			A_StartSound ("hknight/melee", CHAN_BODY);
			return;
		}
		// Throw axe
		A_StartSound (AttackSound, CHAN_BODY);
		if (LeaderType & WML_POISON)
		{ // poison
			SpawnMissileZ (pos.Z + 36, targ, "PoisonBall");
		}
		else if (LeaderType & WML_ICE)
		{ // Ice
			SpawnMissileZ (pos.Z + 36, targ, "HeadFX1");
		}
		else if (LeaderType & WML_FIRE)
		{ // Fire
			A_FireVolcanoShot(targ);
		}
		else if (self.bShadow || random[KnightAttack]() < 40 || LeaderType & WML_STONE)
		{ // Red axe
			SpawnMissileZ (pos.Z + 36, targ, "RedAxe");
		}
		else
		{ // Green axe
			SpawnMissileZ (pos.Z + 36, targ, "KnightAxe");
		}
	}
}

// Knight ghost -------------------------------------------------------------

class HRpgKnightGhost : HRpgKnight replaces KnightGhost
{
	Default
	{
		+SHADOW
		+GHOST
		RenderStyle "Translucent";
		Alpha 0.4;

		ExpSquishbag.IsRespawnable true;
		ExpSquishbag.RespawnWaitBonus 1200;
		ExpSquishbag.IsSpectreable false;
	}
}