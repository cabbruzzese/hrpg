const MAXXPHIT = 200;
class ExpSquishbag : Actor
{
	override int TakeSpecialDamage(Actor inflictor, Actor source, int damage, Name damagetype)
	{
		int xp = damage;
		if (xp > MAXXPHIT)
			xp = MAXXPHIT;

		let hrpgPlayer = HRpgPlayer(source);
		if (hrpgPlayer)
		{
			hrpgPlayer.GiveXP(xp);
		}
		
		return Super.TakeSpecialDamage(inflictor, source, damage, damagetype);
	}
}