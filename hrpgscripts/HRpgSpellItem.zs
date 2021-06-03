class HRpgSpellItem : PowerupGiver
{
	int cooldownTicks;
	int manaCost;
	property CooldownTicks : cooldownTicks;
	property ManaCost : manaCost;
	
	Default
	{
		+COUNTITEM
		+FLOATBOB
		Inventory.PickupFlash "PickupFlash";
		Inventory.InterHubAmount 0;
		Inventory.Icon "ARTISOAR";
		Inventory.PickupMessage "$TXT_ARTIFLY";
		Tag "$TAG_ARTIFLY";
		Powerup.Type "PowerFlight";
		
		HRpgSpellItem.CooldownTicks 80;
		HRpgSpellItem.ManaCost 10;
	}
	
	
	virtual void CastSpell(HRpgBlasphemerPlayer player)
	{
	}
	
	override bool Use (bool pickup)
	{
		if (Owner == null) return true;

		if (EffectTics > 0)
		{
			return false;
		}
		
		EffectTics = CooldownTicks;
		
		let blasphemerPlayer = HRpgBlasphemerPlayer(Owner);
		if (blasphemerPlayer && blasphemerPlayer.Mana > ManaCost)
		{
			blasphemerPlayer.Mana -= ManaCost;
			CastSpell(blasphemerPlayer);
		}

		return false;
	}
	
	override void Tick()
	{
		// Spells cannot exist outside an inventory
		if (Owner == NULL)
		{
			Destroy ();
		}
		
		if (EffectTics > 0)
			EffectTics--;
	}
}

class FireBallSpell : HRpgSpellItem
{
	Default
	{
		+COUNTITEM
		+FLOATBOB
		Inventory.PickupFlash "PickupFlash";
		Inventory.InterHubAmount 0;
		Inventory.Icon "FX09G0";
		Inventory.PickupMessage "Hey fireball, lookin' kinda hot, if you know what I mean.";//"$TXT_ARTIFLY";
		Tag "Fireball WUZ HERE";//"$TAG_ARTIFLY";
		
		HRpgSpellItem.CooldownTicks 30;
		HRpgSpellItem.ManaCost 20 * MANA_SCALE_MOD;
	}
	
	override void CastSpell(HRpgBlasphemerPlayer player)
	{
		if (player == null)
		{
			return;
		}
		
		
		let mo = player.SpawnPlayerMissile ("PhoenixFireballFX1");
		
		//Scale up damage with level
		player.SetProjectileDamageForMagic(mo);
	}
}