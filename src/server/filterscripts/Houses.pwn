
#include <a_samp>
#include <sscanf2>
#include <izcmd>
#include <a_mysql>
#include <vg5>

#undef MAX_PLAYERS
#define MAX_PLAYERS 100

#define MAX_HOUSES 5

new MySQL: Database;

enum pInfo { //  enum, èo všetko sa bude uklada
	Money
}

new PlayerInfo[MAX_PLAYERS][pInfo]; // premenná, kde sa budú uklada hráèove dáta


enum hInfo {
	owner,
	price,
	
	Float:x,
	Float:y,
	Float:z,
	
	Cache: cache
}

new HouseInfo[MAX_HOUSES][hInfo];

forward LoadHouse(houseid);
public LoadHouse(houseid){
//new String[150];
	
	if(cache_num_rows() > 0) // ak neobsahuje niè, nenaèíta sa niè...
	{
		printf("LOADING HOUSE ID: %d", houseid);
	 	HouseInfo[houseid][cache] = cache_save();
		new string[MAX_PLAYER_NAME+1];
		
	 	cache_set_active(HouseInfo[houseid][cache]);
		cache_get_value(0, "owner", HouseInfo[houseid][owner], MAX_PLAYER_NAME+1);
		cache_get_value_int(0, "price", HouseInfo[houseid][price]);
		cache_get_value_float(0, "x", HouseInfo[houseid][x]);
		cache_get_value_float(0, "y", HouseInfo[houseid][y]);
		cache_get_value_float(0, "z", HouseInfo[houseid][z]);
		cache_get_value_index(0, 1, string, MAX_PLAYER_NAME+1);
		printf("HOUSE ID 1, OWNER:  %s, CENA: %d,   STRING TEST: ",HouseInfo[0][owner],HouseInfo[0][price], string);
		
		cache_unset_active();
	}
	

}

stock SaveHouse(houseid){


}

public OnFilterScriptInit()
{
    new MySQLOpt: option_id = mysql_init_options();
    mysql_set_option(option_id, AUTO_RECONNECT, true);
    Database = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASS, MYSQL_DATABASE, option_id);

    if(Database == MYSQL_INVALID_HANDLE || mysql_errno(Database) != 0)
	{
		print("I couldn't connect to the MySQL server, closing.");
		SendRconCommand("exit");
		return 1;
	}
	
	for(new id = 0; id < MAX_HOUSES; id++){
		new string[128];
	 	mysql_format(Database, string, sizeof(string), "SELECT * FROM `houses` WHERE `id` = '%i' LIMIT 1", id);
	    mysql_tquery(Database, string, "LoadHouse", "i", id);
    }

	print("\n--------------------------------------");
	print(" House system loading...");
	print("--------------------------------------\n");
	
	
	

	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}


public OnPlayerConnect(playerid) {
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	return 1;
}

public OnPlayerSpawn(playerid)
{
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}


