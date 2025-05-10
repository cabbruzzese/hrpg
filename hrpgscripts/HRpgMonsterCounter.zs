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

        // Cycle through all squishy xp bags
        let iterator = ThinkerIterator.Create("ExpSquishbag");
        ExpSquishbag currentMonster;
        while (currentMonster = ExpSquishbag(iterator.Next()))
        {
            // Count as total
            squishTotal++;

            // See if soul is freed
            if (!currentMonster.isDoneRespawning)
                count++;
        }

        // Cycle through any (and all) trophies
        iterator = ThinkerIterator.Create("WinTrophy");
        WinTrophy currentTrophy;
        while (currentTrophy = WinTrophy(iterator.Next()))
        {
            // If at least one exists, we won
            won = true;
        }

        // Cycle through all dead monster placeholders (morph, etc)
        iterator = ThinkerIterator.Create("DeadMonsterCounter");
        DeadMonsterCounter currentDeadCounter;
        while (currentDeadCounter = DeadMonsterCounter(iterator.Next()))
        {
            squishTotal++;
        }

        EventHandler.SendInterfaceEvent(consoleplayer , "TotalSpawnableMonstersUpdate", count, squishTotal);

        SpawnTotalCount response = new("SpawnTotalCount");
        response.Set(count, squishTotal, count == 0, won);

        // Update monsters with latest info
        double remainingPercent = double(response.Remaining) / double(response.Total);
        UpdateMonsterTics(remainingPercent);

        return response;
    }

    static void UpdateMonsterTics(double percent)
    {
        // Cycle through all squishy xp bags
        let iterator = ThinkerIterator.Create("ExpSquishbag");
        ExpSquishbag currentMonster;
        while (currentMonster = ExpSquishbag(iterator.Next()))
        {
            if (currentMonster)
                currentMonster.DoLastCallUpdate(percent);
        }
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