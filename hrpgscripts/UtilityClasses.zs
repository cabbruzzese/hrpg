class ActorUtils : Actor
{
	static bool HeathenPlayerExists()
    {
        for (int i = 0; i < MaxPlayers; i++)
        {
            if (players[i].mo && players[i].mo is 'HRpgHeathenPlayer')
            {
                return true;
            }
        }

        return false;
    }

    static bool NonHeathenPlayerExists()
    {
        for (int i = 0; i < MaxPlayers; i++)
        {
            if (players[i].mo && players[i].mo is 'HRpgHereticPlayer' || players[i].mo && players[i].mo is 'HRpgBlasphemerPlayer')
            {
                return true;
            }
        }

        return false;
    }
}