#define MYSQL_HOST "casa1.fakaheda.eu"
#define MYSQL_USER "294332_mysql_db"
#define MYSQL_PASS "123456"
#define MYSQL_DATABASE "294332_mysql_db"

stock PlayerName(playerid)
{
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid,name,sizeof(name));
	return name;
}