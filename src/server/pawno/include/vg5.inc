#include <dutils>
#include <easyDialog>
#include <streamer>
#include <sscanf2>
#include <izcmd>

#include <vg5_callbacks>
#include <vg5_colors>
#include <vg5_gui>


#define MYSQL_HOST "casa1.fakaheda.eu"
#define MYSQL_USER "294332_mysql_db"
#define MYSQL_PASS "123456"
#define MYSQL_DATABASE "294332_mysql_db"

#define STREAM_DISTANCE_3DTEXT 300
#define STREAM_DISTANCE_PICKUP 300

#undef MAX_PLAYERS
#define MAX_PLAYERS 	100

#define MAX_BANKS 10

#define strcpy(%0,%1,%2) strcat((%0[0] = '\0', %0), %1, %2)

#define IsPlayerInSphere(%0,%1,%2,%3,%4) IsPlayerInRangeOfPoint(%0,%4,%1,%2,%3)

#define isnull(%1) \
    ((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))

#define SCM SendClientMessage
#define SCMTA SendClientMessageToAll

#define SERVER_SALT "ugRb3x74c]c"

#pragma unused ret_memcpy

enum E_PLAYER_DATA
{
    ID,
    PName[25],
    Password[65],
    PasswordFails, // neukladat
    Kills,
    Deaths,
    Score,
    Cash,
    Bank, // UKLADAT
    Cache: Player_Cache, // neukladat
    bool:LoggedIn, // neukladat
    adminLevel, // TREBA NASTAVIT UKLADANIE 
    vip,  // -||-
    vipTimeto, // -||-
    bool:isInvisible // neukldat
}
new PlayerInfo[MAX_PLAYERS][E_PLAYER_DATA];

enum E_PLAYER_DATA_ADMIN // neukladať, dočasné premenné !
{
	varns, // neukladat - počet varnov od admina 1/3 - 2/3 - 3/3
    bool:aVisible, // pre admina visible - neukladat
    bool:isMuted, // ak je umlčany
    bool:isFreezed // ak je hráč zmrazený 
}
new AdminInfo[MAX_PLAYERS][E_PLAYER_DATA_ADMIN];

enum E_BANK_INFO {	
	Float:bankX,
	Float:bankY,
	Float:bankZ,

	MapIcon,
	CP,
	Text3D:label,
	Pickup
};

new BankInfo[MAX_BANKS][E_BANK_INFO];

stock PlayerName(playerid)
{
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid,name,sizeof(name));
	return name;
}

stock KickEx(playerid)
{
	SetTimerEx("KickTimed", 500, false, "i", playerid);
}

forward KickTimed(playerid);
public KickTimed(playerid)
{
	Kick(playerid);
	return 1;	
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

stock LoadStaticVehiclesFromFile(const filename[])
{
	new File:file_ptr;
	new line[256];
	new var_from_line[64];
	new vehicletype;
	new Float:SpawnX;
	new Float:SpawnY;
	new Float:SpawnZ;
	new Float:SpawnRot;
    new Color1, Color2;
	new index;
	new vehicles_loaded;

	file_ptr = fopen(filename,filemode:io_read);
	if(!file_ptr) return 0;

	vehicles_loaded = 0;

	while(fread(file_ptr,line,256) > 0)
	{
	    index = 0;

	    // Read type
  		index = token_by_delim(line,var_from_line,',',index);
  		if(index == (-1)) continue;
  		vehicletype = strval(var_from_line);
   		if(vehicletype < 400 || vehicletype > 611) continue;

  		// Read X, Y, Z, Rotation
  		index = token_by_delim(line,var_from_line,',',index+1);
  		if(index == (-1)) continue;
  		SpawnX = floatstr(var_from_line);

  		index = token_by_delim(line,var_from_line,',',index+1);
  		if(index == (-1)) continue;
  		SpawnY = floatstr(var_from_line);

  		index = token_by_delim(line,var_from_line,',',index+1);
  		if(index == (-1)) continue;
  		SpawnZ = floatstr(var_from_line);

  		index = token_by_delim(line,var_from_line,',',index+1);
  		if(index == (-1)) continue;
  		SpawnRot = floatstr(var_from_line);

  		// Read Color1, Color2
  		index = token_by_delim(line,var_from_line,',',index+1);
  		if(index == (-1)) continue;
  		Color1 = strval(var_from_line);

  		index = token_by_delim(line,var_from_line,';',index+1);
  		Color2 = strval(var_from_line);

  		//printf("%d,%.2f,%.2f,%.2f,%.4f,%d,%d",vehicletype,SpawnX,SpawnY,SpawnZ,SpawnRot,Color1,Color2);

  		AddStaticVehicleEx(vehicletype,SpawnX,SpawnY,SpawnZ,SpawnRot,Color1,Color2,(30*60)); // respawn 30 minutes

		/*new numplate_test[32+1];
		format(numplate_test,32,"GRLC{44AA33}%d",vid);
		SetVehicleNumberPlate(vid, numplate_test);*/

		vehicles_loaded++;
	}

	fclose(file_ptr);
	printf("Loaded %d vehicles from: %s",vehicles_loaded,filename);
	return vehicles_loaded;
}

stock token_by_delim(const string[], return_str[], delim, start_index)
{
	new x=0;
	while(string[start_index] != EOS && string[start_index] != delim) {
	    return_str[x] = string[start_index];
	    x++;
	    start_index++;
	}
	return_str[x] = EOS;
	if(string[start_index] == EOS) start_index = (-1);
	return start_index;
}

stock AddCommasToInt(number)
{
    new
        tStr[16]; // Up to 9,999,999,999,999

    new number2 = number;
    if(number < 0) number = number * -1;

    format(tStr, sizeof(tStr), "%d", number);

    if(strlen(tStr) < 4)
 	return tStr;

    new
        iPos = strlen(tStr),
        iCount = 1;

    while(iPos > 0)
    {
	if(iCount == 4)
	{
	    iCount = 0;
	    strins(tStr, ",", iPos, 1);
		iPos++;
    }
    iCount++;
    iPos--;
    }
    if(number2 < 0) format(tStr, sizeof(tStr), "-%s", tStr);
    return tStr;
}
