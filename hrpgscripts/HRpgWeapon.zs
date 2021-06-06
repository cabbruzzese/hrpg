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
	}
}

class BlasphemerWeapon : HRpgWeapon
{
	Default
	{
		Inventory.ForbiddenTo "HRpgHereticPlayer", "HRpgHeathenPlayer";
	}
}