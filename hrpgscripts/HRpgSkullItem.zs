const SKULLITEM_HEALTH = 30;
const SKULLITEM_ARMOR = 50;
const SKULLITEM_ARMORSAVE = 50;
const SKULLITEM_AMMO = 10;

const SKULLITEM_TICKS_BESERK = 500;
const SKULLITEM_TICKS_INVIS = 700;
const SKULLITEM_TICKS_TORCH = 1200;
const SKULLITEM_TICKS_TOME = 300;
const SKULLITEM_TICKS_FLY = 300;

const SKULLITEM_LEVEL_INVIS = 1;
const SKULLITEM_LEVEL_TORCH = 5;
const SKULLITEM_LEVEL_TOME = 10;
const SKULLITEM_LEVEL_FLY = 15;

class HRpgSkullItem : Inventory
{
	transient int PrevHealth;
	meta int LowHealth;
	meta String LowHealthMessage;
	
	property LowMessage: LowHealth, LowHealthMessage;
	
	Default
	{
		Health 30;
		+INVENTORY.ISHEALTH
		+FLOATBOB
		+INVENTORY.FANCYPICKUPSOUND
		Inventory.PickupFlash "PickupFlash";
		Inventory.Amount 1;
		Inventory.MaxAmount 0;
		Inventory.PickupSound "misc/p_pkup";
		RenderStyle "Translucent";
		Inventory.PickupMessage "$TXT_ARTSKULLITEM";
	}
	States
	{
	Spawn:
		SKIT A 3;
		Loop;
	}
	
	//===========================================================================
	//
	// AHealth :: PickupMessage
	//
	//===========================================================================
	override String PickupMessage ()
	{
		return Super.PickupMessage();
	}

	//===========================================================================
	//
	// TryPickup
	//
	//===========================================================================

	override bool TryPickup (in out Actor other)
	{
		ApplySkullItem(other);
		GoAwayAndDie ();
		return true;
	}
	
	//Only give armor to heathens
	bool TryGiveArmor(Actor other)
	{
		let heathenPlayer = HRpgHeathenPlayer(other.player.mo);
		if (heathenPlayer)
		{
			int SaveAmount = SKULLITEM_ARMOR;
			let armor = BasicArmor(other.FindInventory("BasicArmor"));

			// This should really never happen but let's be prepared for a broken inventory.
			if (armor == null)
			{
				armor = BasicArmor(Spawn("BasicArmor"));
				armor.BecomeItem ();

				armor.Icon = GetDefaultByType("SilverShield").Icon;
		
				other.AddInventory (armor);
			}
			else
			{
				// If you already have more armor than this item gives you, you can't
				// use it.
				if (armor.Amount >= SaveAmount + armor.BonusCount)
				{
					return false;
				}
				// Don't use it if you're picking it up and already have some.
				if (armor.Amount > 0 && MaxAmount > 0)
				{
					return false;
				}
			}
			
			armor.SavePercent = clamp(SKULLITEM_ARMORSAVE, 0, 100) / 100;
			armor.Amount = SaveAmount + armor.BonusCount;
			armor.MaxAmount = SaveAmount;
			armor.Icon = Icon;
			armor.MaxAbsorb = SKULLITEM_ARMORSAVE;
			armor.MaxFullAbsorb = SKULLITEM_ARMORSAVE;
			armor.ArmorType = GetClassName();
			armor.ActualSaveAmount = SaveAmount;
			return true;
		}
		return false;
	}
	
	//give health to everyone
	bool TryGiveHealth(Actor other)
	{
		if (other.GiveBody(SKULLITEM_HEALTH, MaxAmount))
		{
			return true;
		}
		return false;
	}
	
	bool TryUsePowerup (Actor other, Class<Actor> powerupType, double effectTics)
	{
		if (powerupType == NULL) return true;	// item is useless
		if (other == null) return true;

		let power = Powerup(Spawn (powerupType));

		if (effectTics != 0)
		{
			power.EffectTics = effectTics;
		}
		
		/*if (BlendColor != 0)
		{
			if (BlendColor != Powerup.SPECIALCOLORMAP_MASK | 65535) power.BlendColor = BlendColor;
			else power.BlendColor = 0;
		}*/
		
/*		if (mode != 'None')
		{
			power.Mode = mode;
		}
		if (strength != 0)
		{
			power.Strength = strength;
		}*/

		power.bAlwaysPickup |= bAlwaysPickup;
		power.bAdditiveTime |= bAdditiveTime;
		power.bNoTeleportFreeze |= bNoTeleportFreeze;
		
		let strengthPowerup = PowerStrength2(power);
		if (strengthPowerup)
		{
			strengthPowerup.MaxTics = effectTics * 2;
		}
		
		if (power.CallTryPickup (other))
		{
			return true;
		}
		power.GoAwayAndDie ();
		return false;
	}
	
	//Only give invisible to heretic
	bool TryGiveArtifacts (Actor other)
	{
		let hereticPlayer = HRpgHereticPlayer(other.player.mo);
		if (hereticPlayer)
		{
			bool result = false;
			if (hereticPlayer.ExpLevel >= SKULLITEM_LEVEL_INVIS)
			{
				result |= TryUsePowerup(other, "PowerGhost", SKULLITEM_TICKS_INVIS);
			}
			
			if (hereticPlayer.ExpLevel >= SKULLITEM_LEVEL_TORCH)
			{
				result |= TryUsePowerup(other, "PowerTorch", SKULLITEM_TICKS_TORCH);
			}

			if (hereticPlayer.ExpLevel >= SKULLITEM_LEVEL_TOME)
			{
				result |= TryUsePowerup(other, "PowerWeaponlevel2", SKULLITEM_TICKS_TOME);
			}
			
			if (hereticPlayer.ExpLevel >= SKULLITEM_LEVEL_FLY)
			{
				result |= TryUsePowerup(other, "PowerFlight", SKULLITEM_TICKS_FLY);
			}
			
			return result;
		}
		return false;
	}

	//Only for heathen
	bool TryGiveBerserk (Actor other)
	{
		let heathenPlayer = HRpgHeathenPlayer(other.player.mo);
		if (heathenPlayer)
		{
			return TryUsePowerup(other, "PowerStrength2", SKULLITEM_TICKS_BESERK);
		}
		return false;		
	}
	
	//Only for Blasphemer
	bool TryGiveAmmo (Actor other)
	{
		let blasphemerPlayer = HRpgBlasphemerPlayer(other.player.mo);
		if (blasphemerPlayer)
		{
			for (let probe = other.Inv; probe != NULL; probe = probe.Inv)
			{
				let ammoitem = Ammo(probe);

				if (ammoitem && ammoitem.GetParentAmmo() == ammoitem.GetClass())
				{
					if (ammoitem.Amount < ammoitem.MaxAmount || sv_unlimited_pickup)
					{
						int amount = SKULLITEM_AMMO;
						// extra ammo in baby mode and nightmare mode
						if (!bIgnoreSkill)
						{
							amount = int(amount * G_SkillPropertyFloat(SKILLP_AmmoFactor));
						}
						ammoitem.Amount += amount;
						if (ammoitem.Amount > ammoitem.MaxAmount && !sv_unlimited_pickup)
						{
							ammoitem.Amount = ammoitem.MaxAmount;
						}
					}
				}
			}
			return true;
		}
		return false;		
	}
	
	void ApplySkullItem (Actor other)
	{
		TryGiveArmor(other);
		TryGiveHealth(other);
		TryGiveArtifacts(other);
		TryGiveBerserk(other);
		TryGiveAmmo(other);
	}
}

//===========================================================================
//
// Strength2
//
//===========================================================================

class PowerStrength2 : Powerup
{
	int maxTics;
	property MaxTics : maxTics;
	Default
	{
		Powerup.Duration 1;
		Powerup.Color "ff 00 00", 0.5;
		+INVENTORY.HUBPOWER
		
		PowerStrength2.MaxTics 556;
	}
	
	override bool HandlePickup (Inventory item)
	{
		if (item.GetClass() == GetClass())
		{ // Setting EffectTics to 0 will force Powerup's HandlePickup()
		  // method to reset the tic count so you get the red flash again.
			EffectTics = 0;
		}
		return Super.HandlePickup (item);
	}

	//===========================================================================
	//
	// APowerStrength :: DoEffect
	//
	//===========================================================================

	override void Tick ()
	{
		// Strength counts up to diminish the fade.
		EffectTics += 2;

		Super.Tick();

		if (EffectTics >= MaxTics)
			Destroy();
	}

	//===========================================================================
	//
	// APowerStrength :: GetBlend
	//
	//===========================================================================

	override color GetBlend ()
	{
		// slowly fade the berserk out
		int cnt = 128 - (EffectTics>>3);

		if (cnt > 0)
		{
			return Color(BlendColor.a*cnt/256,
				BlendColor.r, BlendColor.g, BlendColor.b);
		}
		return 0;
	}
	
}