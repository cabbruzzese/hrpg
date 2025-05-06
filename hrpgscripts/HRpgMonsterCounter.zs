class SpawnTotalCount
{
    int Remaining;
    int Total;
    bool IsWin;
    bool HasWon;

    void Set(int numRemaining, int numTotal, bool win, bool won)
    {
        Remaining = numRemaining;
        Total = numTotal;
        IsWin = win;
        HasWon = won;
    }
}

class HRpgMonsterCounter : StaticEventHandler
{
    static SpawnTotalCount UpdateSpawnCounts()
    {
        int count = 0;
        int squishTotal = 0;
        bool win = false;
        bool won = false;

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
                squishTotal++;

                if (!spawnableActor.isDoneRespawning)
                    count++;
            }

            let winActor = WinTrophy(currentActor);
            if (winActor)
            {
                won = true;
            }
        }

        EventHandler.SendInterfaceEvent(consoleplayer , "TotalSpawnableMonstersUpdate", count, squishTotal);

        SpawnTotalCount response = new("SpawnTotalCount");
        response.Set(count, squishTotal, count == 0, won);

        return response;
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
                sb.TotalSpawnableMonstersMax = e.Args[1];
			}
		}
	}
}