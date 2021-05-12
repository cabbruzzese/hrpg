
// Ironlich -----------------------------------------------------------------

class HrpgIronlich : ExpSquishbag replaces Ironlich
{
	Default
	{
		Health 700;
		Radius 40;
		Height 72;
		Mass 325;
		Speed 6;
		Painchance 32;
		Monster;
		+NOBLOOD
		+DONTMORPH
		+DONTSQUASH
		+BOSSDEATH
		SeeSound "ironlich/sight";
		AttackSound "ironlich/attack";
		PainSound "ironlich/pain";
		DeathSound "ironlich/death";
		ActiveSound "ironlich/active";
		Obituary "$OB_IRONLICH";
		HitObituary "$OB_IRONLICHHIT";
		Tag "$FN_IRONLICH";
		DropItem "BlasterAmmo", 84, 10;
		DropItem "ArtiEgg", 51, 0;
	}

	
	States
	{
	Spawn:
		LICH A 10 A_Look;
		Loop;
	See:
		LICH A 4 A_Chase;
		Loop;
	Missile:
		LICH A 5 A_FaceTarget;
		LICH B 20 A_LichAttack;
		Goto See;
	Pain:
		LICH A 4;
		LICH A 4 A_Pain;
		Goto See;
	Death:
		LICH C 7;
		LICH D 7 A_Scream;
		LICH EF 7;
		LICH G 7 A_NoBlocking;
		LICH H 7;
		LICH I -1 A_BossDeath;
		Stop;
	}
	
	//----------------------------------------------------------------------------
	//
	// PROC A_LichAttack
	//
	//----------------------------------------------------------------------------

	void A_LichAttack ()
	{
		static const int atkResolve1[] = { 50, 150 };
		static const int atkResolve2[] = { 150, 200 };

		// Ice ball		(close 20% : far 60%)
		// Fire column	(close 40% : far 20%)
		// Whirlwind	(close 40% : far 20%)
		// Distance threshold = 8 cells

		let targ = target;
		if (targ == null)
		{
			return;
		}
		A_FaceTarget ();
		if (CheckMeleeRange ())
		{
			int damage = random[LichAttack](1, 8) * 6;
			int newdam = targ.DamageMobj (self, self, damage, 'Melee');
			targ.TraceBleed (newdam > 0 ? newdam : damage, self);
			return;
		}
		int dist = Distance2D(targ) > 8 * 64;
		int randAttack = random[LichAttack]();
		if (randAttack < atkResolve1[dist])
		{ // Ice ball
			SpawnMissile (targ, "HeadFX1");
			A_StartSound ("ironlich/attack2", CHAN_BODY);
		}
		else if (randAttack < atkResolve2[dist])
		{ // Fire column
			Actor baseFire = SpawnMissile (targ, "HeadFX3");
			if (baseFire != null)
			{
				baseFire.SetStateLabel("NoGrow");
				for (int i = 0; i < 5; i++)
				{
					Actor fire = Spawn("HeadFX3", baseFire.Pos, ALLOW_REPLACE);
					if (i == 0)
					{
						A_StartSound ("ironlich/attack1", CHAN_BODY);
					}
					if (fire != null)
					{
						fire.target = baseFire.target;
						fire.angle = baseFire.angle;
						fire.Vel = baseFire.Vel;
						fire.SetDamage(0);
						fire.health = (i+1) * 2;
						fire.CheckMissileSpawn (radius);
					}
				}
			}
		}
		else
		{ // Whirlwind
			Actor mo = SpawnMissile (targ, "Whirlwind");
			if (mo != null)
			{
				mo.AddZ(-32);
				mo.tracer = targ;
				mo.health = 20*TICRATE; // Duration
				A_StartSound ("ironlich/attack3", CHAN_BODY);
			}
		}
	}
	
}