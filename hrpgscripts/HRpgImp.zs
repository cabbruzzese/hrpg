
// Heretic imp (as opposed to the Doom variety) -----------------------------

class HRpgImp : ExpSquishbag replaces HereticImp
{
	bool extremecrash;

	Default
	{
		Health 40;
		Radius 16;
		Height 36;
		Mass 50;
		Speed 10;
		Painchance 200;
		Monster;
		+FLOAT
		+NOGRAVITY
		+SPAWNFLOAT
		+DONTOVERLAP
		+MISSILEMORE
		SeeSound "himp/sight";
		AttackSound "himp/attack";
		PainSound "himp/pain";
		DeathSound "himp/death";
		ActiveSound "himp/active";
		Obituary "$OB_HERETICIMP";
		HitObituary "$OB_HERETICIMPHIT";
		Tag "$FN_HERETICIMP";
		
		ExpSquishbag.IsRespawnable true;
		ExpSquishbag.isSpawnLess true;
	}
	
	States
	{
	Spawn:
		IMPX ABCB 10 A_Look;
		Loop;
	See:
		IMPX AABBCCBB 3 A_Chase;
		Loop;
	Melee:
		IMPX DE 6 A_FaceTarget;
		IMPX F 6 A_CustomMeleeAttack(random[ImpMeAttack](5,12), "himp/attack", "himp/attack");
		Goto See;
	Missile:
		IMPX A 10 A_FaceTarget;
		IMPX B 6 A_ImpMsAttack;
		IMPX CBAB 6;
		Goto Missile+2;
	Pain:
		IMPX G 3;
		IMPX G 3 A_Pain;
		Goto See;
	Death:
		IMPX G 4 A_ImpDeath;
		IMPX H 5;
		Wait;
	XDeath:
		IMPX S 5 A_ImpXDeath1;
		IMPX TU 5;
		IMPX V 5 A_Gravity;
		IMPX W 5;
		Wait;
	Crash:
		IMPX I 7 A_ImpExplode;
		IMPX J 7 A_Scream;
		IMPX K 7;
		IMPX L -1;
		Stop;
	XCrash:
		IMPX X 7;
		IMPX Y 7;
		IMPX Z -1;
		Stop;
	}
	
	
	//----------------------------------------------------------------------------
	//
	// PROC A_ImpMsAttack
	//
	//----------------------------------------------------------------------------

	void A_ImpMsAttack()
	{
		if (!target || random[ImpMSAtk]() > 64)
		{
			SetState (SeeState);
			return;
		}
		A_SkullAttack(12);
}

	//----------------------------------------------------------------------------
	//
	// PROC A_ImpExplode
	//
	//----------------------------------------------------------------------------

	void A_ImpExplode()
	{
		Actor chunk;

		bNoGravity = false;

		chunk = Spawn("HereticImpChunk1", pos, ALLOW_REPLACE);
		if (chunk != null)
		{
			chunk.vel.x = random2[ImpExplode]() / 64.;
			chunk.vel.y = random2[ImpExplode]() / 64.;
			chunk.vel.z = 9;
		}

		chunk = Spawn("HereticImpChunk2", pos, ALLOW_REPLACE);
		if (chunk != null)
		{
			chunk.vel.x = random2[ImpExplode]() / 64.;
			chunk.vel.y = random2[ImpExplode]() / 64.;
			chunk.vel.z = 9;
		}
		
		if (extremecrash)
		{
			SetStateLabel ("XCrash");
		}
	}

	//----------------------------------------------------------------------------
	//
	// PROC A_ImpDeath
	//
	//----------------------------------------------------------------------------

	void A_ImpDeath()
	{
		bSolid = false;
		bFloorClip = true;
	}

	//----------------------------------------------------------------------------
	//
	// PROC A_ImpXDeath1
	//
	//----------------------------------------------------------------------------

	void A_ImpXDeath1()
	{
		bSolid = false;
		bFloorClip = true;
		bNoGravity = true;
		extremecrash = true;
	}
}		

// Heretic imp leader -------------------------------------------------------

class HRpgImpLeader : HRpgImp replaces HereticImpLeader
{
	Default
	{
		Species "HereticImpLeader";
		Health 80;
		-MISSILEMORE
		AttackSound "himp/leaderattack";
		
		ExpSquishbag.IsRespawnable true;
		ExpSquishbag.isSpawnLess true;
	}
	States
	{
	Melee:
		Stop;
	Missile:
		IMPX DE 6 A_FaceTarget;
		IMPX F 6 A_CustomComboAttack2("HereticImpBall", 32, random[ImpMsAttack2](5,12), "himp/leaderattack");
		Goto See;
	}
}

