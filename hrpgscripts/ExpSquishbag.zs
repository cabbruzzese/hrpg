class ExpSquishbag : Actor
{
	override int TakeSpecialDamage(Actor inflictor, Actor source, int damage, Name damagetype)
	{
		let hrpgPlayer = HRpgPlayer(source);
		if (hrpgPlayer)
		{
			hrpgPlayer.GiveXP(damage);
		}
		
		return Super.TakeSpecialDamage(inflictor, source, damage, damagetype);
	}
}