
#include <a_samp>
#include <sscanf2>
#include <izcmd>
#include <a_mysql>
#include <a_zones>
#include <streamer>
#include <vg5>
#include <easyDialog>
#include <dutils>
#include <vg5callbacks>
#include <vg5languages>

#define SCM SendClientMessage
#define SCMF(%0) SendClientMessage(playerid, -1, %0)

#define MAX_HOUSES 10
#define DEFAULT_HOUSE_OWNER "Mesto"
#define INVALID_HOUSE_OWNER '\0'
#define INVALID_HOUSE -1


// STREAM_DISTANCE_3DTEXT
// STREAM_DISTANCE_PICKUP
new MySQL: Database;

enum E_HOUSE_INFO {
	owner[24+1],
	bool:isOwned,
	bool:isLocked,
	price,
	interier,

	Float:x,
	Float:y,
	Float:z,

	isVip,

	Cache: cache,
	
	pickup,
	iPickup,
	Text3D:labelText,
	cp
}

new Float:HouseIntPOS[][] =
{
	{2496.049804,-1695.238159,1014.742187} // CJ's HOUSE
};

new Float:HouseIntPickUp[][] =
{
	{2496.1025,-1711.1698,1014.7422} // v interiery pickup
};

new Float:HouseIntPosExit[][] =
{
	{2495.9302,-1693.0852,1014.7422} //EXIT CJ
};

new HouseIntID[][1] =
{
	{3} // OK
};

new HouseInfo[MAX_HOUSES][E_HOUSE_INFO];
new HouseEnter[MAX_PLAYERS] = -1;
new TotalLoaded;

forward LoadHouse(houseid);
public LoadHouse(houseid)
{
	if(cache_num_rows() > 0) // ak neobsahuje niË, nenaËÌta sa niË...
	{
		printf("LOADING HOUSE ID: %d", houseid);
	 	HouseInfo[houseid][cache] = cache_save();

	 	cache_set_active(HouseInfo[houseid][cache]);
	 	
		cache_get_value(0, 1, HouseInfo[houseid][owner], 24+1);
		
	 	if(strcmp(HouseInfo[houseid][owner], DEFAULT_HOUSE_OWNER, true) == 0) HouseInfo[houseid][isOwned] = false;
		else HouseInfo[houseid][isOwned] = true;
		 
		cache_get_value_int(0, "price", HouseInfo[houseid][price]);
		cache_get_value_int(0, "isVip", HouseInfo[houseid][isVip]);
		cache_get_value_int(0, "isLocked", HouseInfo[houseid][isLocked]);
		cache_get_value_int(0, "interier", HouseInfo[houseid][interier]);
		
		cache_get_value_float(0, "x", HouseInfo[houseid][x]);
		cache_get_value_float(0, "y", HouseInfo[houseid][y]);
		cache_get_value_float(0, "z", HouseInfo[houseid][z]);

		RenderHouse(houseid); // vygeneruje pickup, 3dtext a podobnÈ veci k domu
		TotalLoaded++;
		
		cache_unset_active();
	}
}

stock RenderHouse(houseid)
{
	//Render Textdraw, pickup pre domy
	// Get2DZone(Float:x, Float:y, Float:z, zone[], len);
	new houseText[328],
		sZone[50];
 	Get2DZone(HouseInfo[houseid][x], HouseInfo[houseid][y], sZone, sizeof(sZone)); // osadÌ zÛnu do stringu sZone
	
	if(HouseInfo[houseid][isVip] == 0) format(houseText, sizeof(houseText), "{FF0000}[ House ]\n%s %d\n%s", sZone, houseid, HouseInfo[houseid][owner]); // kontrolujem, Ëi je VIP dom
	else format(houseText, sizeof(houseText), "{FF0000}[ V.I.P House ]\n%s %d\n%s",sZone, houseid, HouseInfo[houseid][owner]); // ak je VIP premmenn· nastavÌ VIP HOUSE

	if(!HouseInfo[houseid][isOwned]) // ak nikto neb˝va, prid·m dalöÌ riadok a k tmu cenu
	{
		new priceText[50];
		format(priceText, sizeof(priceText), "\n%d $", HouseInfo[houseid][price]);
		strcat(houseText, priceText);
	}
	if(!IsValidDynamic3DTextLabel(HouseInfo[houseid][labelText])){ // kontrolujem, Ëi uû existuje, ak nie vytvorÌ sa
		HouseInfo[houseid][labelText] =  CreateDynamic3DTextLabel("", -1, HouseInfo[houseid][x], HouseInfo[houseid][y], HouseInfo[houseid][z],
		50.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
	}
	if(!IsValidDynamicPickup(HouseInfo[houseid][pickup])){ // kontrolujem, Ëi existuje, ak nie vyvorÌ sa
		HouseInfo[houseid][pickup] = CreateDynamicPickup(1273, 1, HouseInfo[houseid][x], HouseInfo[houseid][y], HouseInfo[houseid][z], -1,-1);
	}
	
	if(!IsValidDynamicCP(HouseInfo[houseid][cp])){
	HouseInfo[houseid][cp] = CreateDynamicCP(
		HouseIntPosExit[ HouseInfo[houseid][interier] ][0], // zÌska, ak˝ interier m· osadiù, n·sledne vytiahne v˝chod X s˙radnicu
		HouseIntPosExit[ HouseInfo[houseid][interier] ][1],// zÌska, ak˝ interier m· osadiù, n·sledne vytiahne v˝chod Y s˙radnicu
		HouseIntPosExit[ HouseInfo[houseid][interier] ][2],// zÌska, ak˝ interier m· osadiù, n·sledne vytiahne v˝chod Z s˙radnicu
		1.5, houseid, HouseIntID[ HouseInfo[houseid][interier] ][0]);
	}
	
	if(!IsValidDynamicPickup(HouseInfo[houseid][iPickup])){ // kontrolujem, Ëi existuje, ak nie vyvorÌ sa
		HouseInfo[houseid][iPickup] = CreateDynamicPickup(1277, 1,
 		HouseIntPickUp[ HouseInfo[houseid][interier] ][0],
		HouseIntPickUp[ HouseInfo[houseid][interier] ][1],
 		HouseIntPickUp[ HouseInfo[houseid][interier] ][2],
		 houseid, HouseIntID[ HouseInfo[houseid][interier] ][0]);
	}
 //1277 SAVE ICON
	
	printf("X:%f, Y:%f, Z:%f ", HouseIntPosExit[ HouseInfo[houseid][interier] ][0], HouseIntPosExit[ HouseInfo[houseid][interier] ][1], HouseIntPosExit[ HouseInfo[houseid][interier] ][2]);
	printf("\nHouseID: %d, InteriorID: %d", houseid, HouseIntID[ HouseInfo[houseid][interier] ][0]);
	UpdateDynamic3DTextLabelText(HouseInfo[houseid][labelText], -1, houseText); // updatujem 3D text
}

stock PlayerOwnAnyHouse(playerid)
{
	for(new i; i < MAX_HOUSES; i++){
        if(strcmp(HouseInfo[i][owner], PlayerName(playerid), true) == 0)
		{
		    return true;
		}
	}
	return false;
}

CMD:pos(playerid, params[])
{
	#pragma unused params
	SCM(playerid, COLOR_RED, "Bol si teleportovan˝!");
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerPos(playerid, 2136.9878,-1457.1827,23.9723);
	return 1;
}

CMD:hspos(playerid, params[])
{
	new hid;
	if(sscanf(params, "i", hid)) return SCM(playerid, -1, "/hspos <houseid>");
	SCM(playerid, COLOR_RED, "Bol si teleportovan˝!");
	SetPlayerPos(playerid, HouseInfo[hid][x],HouseInfo[hid][y],HouseInfo[hid][z]);
	return 1;
}

CMD:isvalid(playerid, params[])
{
	#pragma unused params
	for(new i; i < MAX_HOUSES; i++){
        if(!IsValidDynamic3DTextLabel(HouseInfo[i][labelText]))
		{
		SCMF("Nieje valid!");
		}
	}
	return 1;
}

CMD:vw(playerid)
{
	new str[128];
	format(str, sizeof(str), "Tvoj interier: %d a VW: %d kde sa nach·dzaö: ", GetPlayerInterior(playerid), GetPlayerVirtualWorld(playerid));
	SCMF(str);
	return 1;
}

CMD:createhouse(playerid, params[])
{
	new hPrice, interiorID, hIsVip;
	if(sscanf(params, "ddd", hPrice, interiorID, hIsVip)) return SCMF("/createhouse <cena> <interior ID> <isVip 0/1>");

	if(hPrice > 0)
	{
	    SCMF("PRICE > 0");
		if(interiorID >= 0 && interiorID < sizeof(HouseIntPOS[][]))
		{
			SCMF(" >= 0 &&  < sizeof");
  			new hID = TotalLoaded + 1;
		    if(hID < MAX_HOUSES)
			{
				format(HouseInfo[hID][owner], MAX_PLAYER_NAME + 1, "%s", DEFAULT_HOUSE_OWNER);
				HouseInfo[hID][price] = hPrice;
				HouseInfo[hID][interier] = interiorID;
				HouseInfo[hID][isOwned] = false;
				HouseInfo[hID][isLocked] = false;

				new Float:pos[3];
				GetPlayerPos(playerid, pos[0], pos[1], pos[2]);

				HouseInfo[hID][x] = pos[0];
				HouseInfo[hID][y] = pos[1];
				HouseInfo[hID][z] = pos[2];
				
				if(hIsVip) HouseInfo[hID][isVip] = true;
				else HouseInfo[hID][isVip] = false;
				
				RenderHouse(hID);
				new string[256];
	 			mysql_format(Database, string, sizeof(string), "INSERT INTO `houses` (`price`, `isVip`, `x`, `y`, `z`) VALUES ('%d','%d','%f','%f','%f')",
				 hPrice, hIsVip, pos[0], pos[1], pos[2]);
				mysql_tquery(Database, string);
                
                TotalLoaded++;
				
			}else SCMF("Bol prekroËen˝ limit domov na servery!");
		}
	}
	return 1;
}



stock SaveHouse(houseid)
{
	if(isnull(HouseInfo[houseid][owner])) return 0;

	new query[384];
    mysql_format(Database, query, sizeof(query), "UPDATE `houses` SET `owner`='%e', `price`='%d', `isVip`='%d', `x`='%f', `y`='%f', `z`='%f' WHERE `id`='%i' LIMIT 1",
	HouseInfo[houseid][owner], HouseInfo[houseid][price], 1, HouseInfo[houseid][x], HouseInfo[houseid][y], HouseInfo[houseid][z], houseid);
	if(isnull(query)) return 0;
	else mysql_tquery(Database, query);
	return 1;
}

new timerTesting;

public OnFilterScriptInit()
{
	print("\n--------------------------------------");
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

	
	print(" House system loading...");
	print("--------------------------------------\n");
	timerTesting = SetTimer("saveHouses", 1000*20, true);
	return 1;
}


forward saveHouses();
public saveHouses()
{
	for(new id = 0; id < MAX_HOUSES; id++) {
		SaveHouse(id);
	}
	print("SAVING!!!");


}

public OnFilterScriptExit()
{
	for(new id = 0; id < MAX_HOUSES; id++){
 		SaveHouse(id);
 		
		DestroyDynamicPickup(HouseInfo[id][pickup]);
		DestroyDynamic3DTextLabel(HouseInfo[id][labelText]);
        DestroyDynamicCP(HouseInfo[id][cp]);
        
		HouseInfo[id][owner] = INVALID_HOUSE_OWNER;
		HouseInfo[id][isOwned] = false;
		
		HouseInfo[id][x] = 0;
		HouseInfo[id][y] = 0;
		HouseInfo[id][z] = 0;
		
		HouseInfo[id][isVip] = false;
		
	//	HouseInfo[id][labelText] = INVALID_3DTEXT_ID;
		HouseInfo[id][pickup] = -1;
		
		if(cache_is_valid(HouseInfo[id][cache])) //Checking if the player's cache ID is valid.
		{
			cache_delete(HouseInfo[id][cache]); // Deleting the cache.
			HouseInfo[id][cache] = MYSQL_INVALID_CACHE; // Setting the stored player Cache as invalid.
		}
 	}

	KillTimer(timerTesting);
 	mysql_close(Database);
	return 1;
}


public OnPlayerEnterDynamicCP(playerid, checkpointid)
{
	for(new houseID; houseID < MAX_HOUSES; houseID++)
	{
		if(checkpointid == HouseInfo[houseID][cp])
		{
		    SetPlayerPos(playerid, HouseInfo[houseID][x], HouseInfo[houseID][y], HouseInfo[houseID][z]);
		    SetPlayerVirtualWorld(playerid, 0);
			SetPlayerInterior(playerid, 0);
			break;
		}
	}
	return 1;
}

public OnPlayerPickUpDynamicPickup(playerid, pickupid)
{
	for(new houseID; houseID < MAX_HOUSES; houseID++)
	{
		if(pickupid == HouseInfo[houseID][pickup])
		{
	        if(Dialog_Opened(playerid))
			{
				HouseEnter[playerid] = houseID; // nastavÌm global variable pre kaûdÈho hr·Ëa
				if(HouseInfo[houseID][isOwned])
				{
					// ak dom niekto vlasn˝, zobrazÌ sa mu dialog na vstup a pod...
					new dialogText[128];
				 	format(dialogText, sizeof(dialogText), "Vst˙più\n");

					if(HouseInfo[houseID][isLocked]) strcat(dialogText, "Odomkn˙ù");
					else strcat(dialogText, "Zamkn˙ù");

					Dialog_Show(playerid, HouseMenu, DIALOG_STYLE_LIST, "Dom", dialogText, "Select", "Cancel"); // aj je niekto majitel,
				} else Dialog_Show(playerid, BuyHouse, DIALOG_STYLE_LIST, "K˙più Dom", "K˙più dom\n???\nPridat Peniaze", "Select", "Cancel"); // ak nieje nikto majitel
				break;
			}
		}
	}
	return 1;
}

Dialog:HouseMenu(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		switch(listitem){
			case 0: { // vstupiù do domu
                if(HouseEnter[playerid] != INVALID_HOUSE)
				{
    				if(HouseInfo[HouseEnter[playerid]][isLocked])
					{
		   				//dom je zamknut˝
	    	    		SCMF("Dom je zamknut˝, nemÙûeö do neho vst˙più!");
	    	    		Dialog_Close(playerid);
					}else{
					
						//HouseIntPos[ HouseInfo[hID][interier] ] [0], HouseIntPos[ HouseInfo[hID][interier] ] [1], HouseIntPos[ HouseInfo[hID][interier] ] [2]

						//HouseIntPOS[ ID INTERIERU ] [ POS 0,1,2 ];

						SetPlayerPos(playerid,
						HouseIntPOS[ HouseInfo[HouseEnter[playerid]][interier] ][0],
						HouseIntPOS[ HouseInfo[HouseEnter[playerid]][interier] ][1],
						HouseIntPOS[ HouseInfo[HouseEnter[playerid]][interier] ][2]);
						
						SetPlayerVirtualWorld(playerid, HouseEnter[playerid]);
						SetPlayerInterior(playerid, HouseIntID[ HouseInfo[HouseEnter[playerid]][interier] ][0]);
						
					    Dialog_Close(playerid);
						//dom je odomknut˝, samotn˝ vstup do interiera!
					}
				}else Dialog_Close(playerid); // neplatn˝ vstup, ID domu
			}
			case 1: { // zamkn˙ù / odomkn˙ù
                if (strcmp(HouseInfo[HouseEnter[playerid]][owner], PlayerName(playerid), true) == 0) // ak je hr·Ë majitelom domu
				{
				    if(HouseInfo[HouseEnter[playerid]][isLocked])
					{
					    SCMF("odomkol si dom!");
						HouseInfo[HouseEnter[playerid]][isLocked] = false;
					} else {
						SCMF("zamkol si dom!");
						HouseInfo[HouseEnter[playerid]][isLocked] = true;
					}
					Dialog_Close(playerid);
                }
			}
		}
	}else Dialog_Close(playerid);
	return 1;
}

Dialog:BuyHouse(playerid, response, listitem, inputtext[])
{
    if(HouseEnter[playerid] == INVALID_HOUSE) return Dialog_Close(playerid);
	if(response)
	{
		switch(listitem){
			case 0: {
			    if(PlayerOwnAnyHouse(playerid)){
			        SCMF("Uû m·ö k˙pen˝ jeden dom!");
					return 1;
				}
			    // Eöte kontorla, Ëi je dan˝ hr·Ë VIP !!! na kupu VIP Domu!!!!
				// Eöte kontorla, Ëi je dan˝ hr·Ë VIP !!! na kupu VIP Domu!!!!
				// Eöte kontorla, Ëi je dan˝ hr·Ë VIP !!! na kupu VIP Domu!!!!
				// Eöte kontorla, Ëi je dan˝ hr·Ë VIP !!! na kupu VIP Domu!!!!
			
  				if(PlayerInfo[playerid][Cash] >= HouseInfo[HouseEnter[playerid]][price]) // Kontrolujem, Ëi dan˝ hr·Ë m· dostatok penazÌ na k˙pu
		  		{
					format(HouseInfo[HouseEnter[playerid]][owner], MAX_PLAYER_NAME + 1, "%s", PlayerName(playerid)); // NastavÌm majitela do premennej
					GivePlayerMoneyEx(playerid, -HouseInfo[HouseEnter[playerid]][price]); // odobere peniaze
                    HouseInfo[HouseEnter[playerid]][isOwned] = true;  // nastavÌ, ûe je niekto majitel,
                    
                    RenderHouse(HouseEnter[playerid]); // vyrenderujem znova 3dtext ( updatujem ho )

				}
				Dialog_Close(playerid); // idk, aj tak to nefunguje...
			}
			case 1: {
				GivePlayerMoney(playerid, HouseInfo[HouseEnter[playerid]][price]);
				Dialog_Close(playerid);
			}
   			case 2:{
     			PlayerInfo[playerid][Cash] += 10000;
     			Dialog_Close(playerid);
			}
		}
	}else Dialog_Close(playerid);
	return 1;
}

stock GivePlayerMoneyEx(playerid, money)
{
	PlayerInfo[playerid][Cash] += money;
	GivePlayerMoney(playerid, money);
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

