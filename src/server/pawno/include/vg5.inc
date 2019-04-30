#define MYSQL_HOST "casa1.fakaheda.eu"
#define MYSQL_USER "294332_mysql_db"
#define MYSQL_PASS "123456"
#define MYSQL_DATABASE "294332_mysql_db"

#undef MAX_PLAYERS
#define MAX_PLAYERS 	100


enum E_PLAYER_DATA
{
    ID,
    Name[25],
    Password[65],
    Salt[11],
    PasswordFails,
    Kills,
    Deaths,
    Score,
    Cash,
    Cache: Player_Cache,
    bool:LoggedIn
}
new PlayerInfo[MAX_PLAYERS][E_PLAYER_DATA];

stock PlayerName(playerid)
{
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid,name,sizeof(name));
	return name;
}

