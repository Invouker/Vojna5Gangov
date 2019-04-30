
#include <a_samp>
#include <sscanf2>
#include <izcmd>
#include <a_mysql>
#include <streamer>
#include <vg5>

#include <dutils>
#include <vg5callbacks>
#include <vg5languages>

#define MAX_HOUSES 5

#pragma unused PlayerInfo

new MySQL: Database;

enum hInfo {
	owner[24+1],
	price,

	Float:x,
	Float:y,
	Float:z,

	bool:isVip,

	Cache: cache,
	
	pickup,
	labelText
}

new HouseInfo[MAX_HOUSES][hInfo];

forward LoadHouse(houseid);
public LoadHouse(houseid){
//new String[150];

	if(cache_num_rows() > 0) // ak neobsahuje niè, nenaèíta sa niè...
	{
		printf("LOADING HOUSE ID: %d", houseid);
	 	HouseInfo[houseid][cache] = cache_save();

	 	cache_set_active(HouseInfo[houseid][cache]);

		cache_get_value(0, 1, HouseInfo[houseid][owner], 24+1);
		cache_get_value_int(0, "price", HouseInfo[houseid][price]);
		cache_get_value_int(0, "isVip", HouseInfo[houseid][isVip]);
		cache_get_value_float(0, 3, HouseInfo[houseid][x]);
		cache_get_value_float(0, 4, HouseInfo[houseid][y]);
		cache_get_value_float(0, 5, HouseInfo[houseid][z]);

		//Vytvorenie domu
		new houseType[30];

		
	    CreateDynamic3DTextLabel( (), color, Float:x, Float:y, Float:z, Float:drawdistance, attachedplayer = INVALID_PLAYER_ID, attachedvehicle = INVALID_VEHICLE_ID, testlos = 0, worldid = -1, interiorid = -1, playerid = -1, Float:streamdistance = STREAMER_3D_TEXT_LABEL_SD, areaid = -1, priority = 0 )

		printf("HOUSE ID 0, OWNER:  %s, CENA: %d",HouseInfo[houseid][owner],HouseInfo[houseid][price]);

		cache_unset_active();
	}
}

stock SaveHouse(houseid)
{
	if(isnull(HouseInfo[houseid][owner])) return 0;

	new query[384];
    mysql_format(Database, query, sizeof(query), "UPDATE `houses` SET `owner`='%e', `price`='%d', `isVip`='%d', `x`='%f', `y`='%f', `z`='%f' WHERE `id`='%i' LIMIT 1",
	HouseInfo[houseid][owner], HouseInfo[houseid][price], 1, HouseInfo[houseid][x], HouseInfo[houseid][y], HouseInfo[houseid][z], houseid);
	if(isnull(query)) return 0;

	mysql_tquery(Database, query);

	if(cache_is_valid(HouseInfo[houseid][cache])) //Checking if the player's cache ID is valid.
	{
		cache_delete(HouseInfo[houseid][cache]); // Deleting the cache.
		HouseInfo[houseid][cache] = MYSQL_INVALID_CACHE; // Setting the stored player Cache as invalid.
	}
	return 1;
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
	for(new id = 0; id < MAX_HOUSES; id++){
	    printf("BEFORE PRICE: %d", HouseInfo[id][price]);
	    HouseInfo[id][price] += 10;
	    printf(" PRICE: %d", HouseInfo[id][price]);
 		SaveHouse(id);
 	}

 	mysql_close(Database);
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

