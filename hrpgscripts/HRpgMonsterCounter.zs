class HRpgMonsterCounter : StaticEventHandler
{
    static void UpdateSpawnCounts()
    {
        int count = 0;

        // Create a ThinkerIterator for all actors
        let iterator = ThinkerIterator.Create("Actor");
        Actor currentActor;

        // Iterate through all actors
        while (currentActor = Actor(iterator.Next()))
        {
            // Filter for living monsters
            let spawnableActor = ExpSquishbag(currentActor);
            if (spawnableActor)
            {
                if (!spawnableActor.isDoneRespawning)
                    count++;
            }
        }

        EventHandler.SendInterfaceEvent(consoleplayer , "TotalSpawnableMonstersUpdate", count);
    }

    override void WorldLoaded (WorldEvent e)
    {
        UpdateSpawnCounts();
    }

    override void InterfaceProcess(ConsoleEvent e)
	{
		if (!e.isManual && e.name ~== "TotalSpawnableMonstersUpdate")
		{
			let sb = HRpgStatusBar(statusBar);
			if (sb)
			{
				sb.TotalSpawnableMonsters = e.Args[0];

                if (sb.TotalSpawnableMonstersMax < sb.TotalSpawnableMonsters)
                    sb.TotalSpawnableMonstersMax = sb.TotalSpawnableMonsters;
			}
		}
	}
}