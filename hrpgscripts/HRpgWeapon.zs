const EXTRA_SPAWN_DIST = 20.0;

class HRpgWeapon : HereticWeapon
{
	class<Actor> extraSpawnItem;
	property ExtraSpawnItem : extraSpawnItem;
	
	override void PostBeginPlay()
	{
		//If spawning additional items and not an owned item (not in inventory)
		if (ExtraSpawnItem && ExtraSpawnItem != "" && !Owner)
		{
			let randomX = random(EXTRA_SPAWN_DIST * -1.0, EXTRA_SPAWN_DIST);
			let randomY = random(EXTRA_SPAWN_DIST * -1.0, EXTRA_SPAWN_DIST);
			let newItem = Spawn(ExtraSpawnItem, (Pos.X + randomX, Pos.Y + randomY, Pos.Z));

			ExtraSpawnItem = "";
		}
		
		Super.PostBeginPlay();
	}
	
	override bool TryPickupRestricted (in out Actor toucher)
	{
		return false;
	}
	
	override Inventory CreateCopy (Actor other)
	{
		HRpgWeapon copy;
		Amount = MIN(Amount, MaxAmount);
		if (GoAway ())
		{
			copy = HRpgWeapon(Spawn (GetClass()));
			copy.Amount = Amount;
			copy.MaxAmount = MaxAmount;
			copy.ExtraSpawnItem = "";
		}
		else
		{
			copy = self;
		}
		return copy;
	}

	action void A_HeathenMeleeAttack(int baseDamage, int kickBack, Class<Actor> puffType, int meleeDist = DEFMELEERANGE, int angleMod = 0, bool adjustAngle = false, bool scaleDamageBrutality = true, bool scaleDamageBerserk = true)
	{
		FTranslatedLineTarget t;
		int kickbackSave;

		if (!player)
			return;

		int damage = baseDamage;
		if (scaleDamageBrutality)
		{
			//Scale up damage with level
			let hrpgPlayer = HRpgPlayer(player.mo);
			if (hrpgPlayer)
				damage = hrpgPlayer.GetDamageForMelee(damage);
		}

		//Scale up damage with berserk
		if (scaleDamageBerserk)
		{
			let berserk = Powerup(FindInventory("PowerStrength2"));
			if (berserk)
				damage *= 2;
		}

		//Adjust force of kickback
		// Note: The "bounciness" of monsters in Heretic is a feature, and gives it that arcade feel.
		//   Hexen uses thrust to give melee pushback, but it feels more scripted and doesn't fit heretic.
		//   i.e. Compare the pushback from the pheonix staff to a gargoyle bounced around from a crossbow bolt.
		//   One feels smooth and overriding, and the other feels elastic. We use this kickback hack to reproduce
		//   that same bounciness with melee attacks.
		Weapon w = player.ReadyWeapon;
		if (w)
		{
			kickbackSave = w.Kickback;
			w.Kickback = kickback;
		}
	
		for (int i = 0; i < 16; i++)
		{
			for (int j = 1; j >= -1; j -= 2)
			{
				double ang = angle + angleMod + j*i*(45. / 16);
				double slope = AimLineAttack(ang, meleeDist, t, 0., ALF_CHECK3D);
				if (t.linetarget)
				{
					let puffObj = LineAttack(ang, meleeDist, slope, damage, 'Melee', puffType, true, t);
					
					//restore original kickback value
					if (w)
						w.Kickback = kickbackSave;

					if (t.linetarget)
					{
						if (adjustAngle)
							AdjustPlayerAngle(t);
						
						return;
					}
				}
			}
		}
		// didn't find any creatures, so try to strike any walls
		weaponspecial = 0;

		double slope = AimLineAttack (angle + angleMod, meleeDist, null, 0., ALF_CHECK3D);
        LineAttack (angle + angleMod, meleeDist, slope, damage, 'Melee', puffType, true);
	}
}

class NonHeathenWeapon : HRpgWeapon
{
	Default
	{
		Inventory.ForbiddenTo "HRpgHeathenPlayer";
	}
}

class HeathenWeapon : HRpgWeapon
{
	Default
	{
		Inventory.ForbiddenTo "HRpgHereticPlayer", "HRpgBlasphemerPlayer";
		+WEAPON.MELEEWEAPON
	}
}

class BlasphemerWeapon : HRpgWeapon
{
	Default
	{
		Inventory.ForbiddenTo "HRpgHereticPlayer", "HRpgHeathenPlayer";
	}
}