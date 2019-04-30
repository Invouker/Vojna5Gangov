#define MYSQL_HOST "casa1.fakaheda.eu"
#define MYSQL_USER "294332_mysql_db"
#define MYSQL_PASS "123456"
#define MYSQL_DATABASE "294332_mysql_db"

#undef MAX_PLAYERS
#define MAX_PLAYERS 	100

#define strcpy(%0,%1,%2) strcat((%0[0] = '\0', %0), %1, %2)

#define isnull(%1) \
    ((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))

#define SCM SendClientMessage
#define SCMTA SendClientMessageToAll

#pragma unused ret_memcpy


enum E_PLAYER_DATA
{
    ID,
    PName[25],
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

stock split(const strsrc[], strdest[][], delimiter)
{
	new i, li;
	new aNum;
	new len;
	while(i <= strlen(strsrc)){
	    if(strsrc[i]==delimiter || i==strlen(strsrc)){
	        len = strmid(strdest[aNum], strsrc, li, i, 128);
	        strdest[aNum][len] = 0;
	        li = i+1;
	        aNum++;
		}
		i++;
	}
	return 1;
}

