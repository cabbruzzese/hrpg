const MAXXPHIT = 75;
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
	
	override void Die(Actor source, Actor inflictor, int dmgflags, Name MeansOfDeath)
	{
		A_DropItem("HRpgSkullItem", 1, 35);
		Super.Die(source, inflictor, dmflags, MeansOfDeath);
	}
}