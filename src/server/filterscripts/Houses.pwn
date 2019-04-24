#include <a_samp>
#include <i-zcmd>
#include <dof2>
#include <streamer>
#include <a_zone>
#include <sscanf2>

#define FILTERSCRIPT

#undef MAX_PLAYERS
#define MAX_PLAYERS 200

#define COLOR_RED 0xAA3333AA
#define COLOR_WHITE 0xFFFFFFAA


#define HOUSE_PATH "/Houses/House.%d.ini"

#define MAX_HOUSES  2000+200
#define MAX_HOUSE_INTERIORS 9
#define MIN_HOUSE_PRICE 10000

#define HOUSE_DEFAULT_OWNER "Mesto"
#define PREHLIADKA_DOMU_TIME 60 // V sekund·ch


enum
{
	DIALOG_HOUSE = 200,
	DIALOG_HOUSE_BUY,
	DIALOG_HOUSE_INT_CHANGE,
	DIALOG_HOUSE_SETTING,
	DIALOG_HOUSE_SETTING2,
	DIALOG_HOUSE_INTERIOR,
	DIALOG_HOUSE_MONEY,
	DIALOG_HOUSE_SAVE,
	DIALOG_HOUSE_SAVE2,
	DIALOG_HOUSE_WITHDRAW,
	DIALOG_HOUSE_ADMIN,
	DIALOG_HOUSE_ADMIN_INT,
	DIALOG_HOUSE_ADMIN_PRICE,
	DIALOG_HOUSE_ADMIN_OWN,
	DIALOG_HOUSE_ADMIN_MONEY,
	DIALOG_HOUSE_ADMIN_TLEVEL,
	DIALOG_HOUSE_ADMIN_VIP,
	DIALOG_INFO,
	DIALOG_HOUSE_ACCEPT
}

#define PRESSED(%0) (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
#define isnull(%1) \
	((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))

/*
Zmazaù:
====================
*/
enum pInfo
{
	Money
}

new PlayerInfo[MAX_PLAYERS][pInfo];
//=================

//===============[ TO-DO ]=====================
/*
- Spraviù typy interierov, // nemennÈ iba pri zakladanÌ a  pre administr·tora mennÈ
- V˝chody u kaûd˝ch interierov

- Do kaûdÈho interieru daù checkpoint s nastaveniami domu ato:
 |_ Zamknuù / Odomknuù // COMPLETE
 |_ Ukladanie zbranÌ
 |_ Ukladanie PenazÌ // SpravenÈ
 |_ Ukladanie Invent·ru
		  |_ Dorobiù Inventory SystÈm a doÚ impltementovaù
 |_ Prehliadka domu // Hotovo // PRE» - Interiery budu stanovenÈ a bez zmeny
          |_ K˙pa interieru za $$ // - PRE»
  |_ PlnÈ nastavenie domu pre administr·torov
*/
//=============================================
enum houseInfo
{
	hid,
	isVIP,
	bool:isOwned,
	bool:isLocked,
	Float:hX,
	Float:hY,
	Float:hZ,
	hPrice,
	interiorID,
	pickUp,
	Text3D:TLabel,
	owner[25],
	Money,
	MoneyLevel,
 	CP
}

new Float:HouseIntPOS[][] =
{
	{2496.049804,-1695.238159,1014.742187}, // CJ's HOUSE
	{2468.8423,-1698.3083,1013.5078},
	{266.4989,304.9362,999.1484}, // OPRAVIT ------
	{2807.7087,-1174.7528,1025.5703}, // TAKTIEé
	{1260.6512,-785.4138,1091.9063},//5 TIEé
	{2323.7432,-1149.5474,1050.7101},
	{24.0209,1340.1595,1084.3750},
	{260.9727,1284.2955,1080.2578},  // -------------
	{226.2987,1114.1613,1080.9929},  // POHODE
	{447.1034,1397.0695,1084.3047},//10
	{294.9624,1472.2561,1080.2578},
	{223.1237,1287.0776,1082.1406}, // POHODE
	{226.7866,1239.9832,1082.1406},
	{235.1502,1186.6797,1080.2578},
	{2263.2151,-1132.6669,1050.6328},//15
	{2317.8052,-1026.7654,1050.2178},
	{2233.6895,-1115.2571,1050.8828},
	{422.5727,2536.5051,10.0000},
	{260.8049,1237.2336,1084.2578} //19
};

new Float:HouseIntPickUp[][] =
{
	{2496.1025,-1711.1698,1014.7422}
};

new Float:HouseIntPosExit[][] =
{
	{2495.9302,-1693.0852,1014.7422} //EXIT CJ
};

new HouseIntID[][1] =
{
	{3}, // OK
	{2}, // OK
	{3},
	{3},
	{2},//5
	{3},
	{3},
	{3},
	{3},
	{2}, // OK
	{3},//10
	{3},
	{3},
	{3},
	{2}, // OK
	{3},
	{3},//15
	{3},
	{3},
	{3},
	{3},
	{3}//19
};

new HouseInfo[MAX_HOUSES][houseInfo];
new houseLabel[100],housezone[MAX_ZONE_NAME];
new HouseCount;
new HouseEntered[MAX_PLAYERS];
new bool:HouseVisit[MAX_PLAYERS];

forward CreateHouse(houseID, Float:hoX, Float:hoY, Float:hoZ, price, isVip, int);
public CreateHouse(houseID, Float:hoX, Float:hoY, Float:hoZ, price, isVip, int)
{
	//HouseInfo[houseID][hid] = houseID;
	HouseInfo[houseID][hX] = hoX;
	HouseInfo[houseID][hY] = hoY;
	HouseInfo[houseID][hZ] = hoZ;
    HouseInfo[houseID][hPrice] = price;
    HouseInfo[houseID][isOwned] = false;
    HouseInfo[houseID][isLocked] = false;
    HouseInfo[houseID][interiorID] = int;
    HouseInfo[houseID][isVIP] = isVip;
    format(HouseInfo[houseID][owner], 25, "%s", HOUSE_DEFAULT_OWNER);
	if(!DOF2_FileExists(HousePath(houseID)))
	{
		DOF2_CreateFile(HousePath(houseID));
		DOF2_SetFloat(HousePath(houseID),"posX", hoX);
		DOF2_SetFloat(HousePath(houseID),"posY", hoY);
		DOF2_SetFloat(HousePath(houseID),"posZ", hoZ);
		DOF2_SetInt(HousePath(houseID),"price", price);
		DOF2_SetBool(HousePath(houseID),"isOwned", HouseInfo[houseID][isOwned]);
		DOF2_SetBool(HousePath(houseID),"isLocked", HouseInfo[houseID][isLocked]);
		DOF2_SetInt(HousePath(houseID),"interiorID", HouseInfo[houseID][interiorID]);
		DOF2_SetString(HousePath(houseID),"owner", HouseInfo[houseID][owner]);
		DOF2_SetInt(HousePath(houseID),"Money", 0);
		DOF2_SetInt(HousePath(houseID),"MoneyLevel", 1);
		DOF2_SaveFile();
	}
	HouseInfo[houseID][pickUp] = CreateDynamicPickup(1273, 1, hoX, hoY, hoZ);
	Get2DZone(hoX,hoY, housezone, 37);
	if(HouseInfo[houseID][isVIP] == 0)
 	{
		format(houseLabel, sizeof(houseLabel),"[ House ]\n%s %d\n%s\n%d$",housezone, houseID,HouseInfo[houseID][owner], price);
	}else{
        format(houseLabel, sizeof(houseLabel),"[ V.I.P House ]\n%s %d\n%s\n%d$",housezone, houseID, HouseInfo[houseID][owner],price);
	}
	HouseInfo[houseID][TLabel] = CreateDynamic3DTextLabel(houseLabel, 0xFF0000FF, hoX, hoY, hoZ+0.7, 50.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);

	return 1;
}
/*
public OnPlayerPickUpPickup(playerid, pickupid)
{
	for(new ID; ID<MAX_HOUSES;ID++)
	{
        if(IsPlayerInSphere(playerid,HouseInfo[ID][hX],HouseInfo[ID][hY],HouseInfo[ID][hZ],3)==1)
		{
		   Message(playerid, "Pre otvorenie MENU stlaË Y");

		}
	}
	return 1;
}
*/
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    for(new ID=2000; ID<MAX_HOUSES;ID++)
	{
		if(PRESSED(KEY_YES))
		{
	        if(IsPlayerInSphere(playerid,HouseInfo[ID][hX],HouseInfo[ID][hY],HouseInfo[ID][hZ],3)==1)
			{
			    SCMF(playerid, "ID Domu: %d", ID);
			    HouseEntered[playerid] = ID;
			    if(HouseInfo[ID][isOwned] == true)
				{
				    if(IsPlayerAdmin(playerid))
				    {
						ShowPlayerDialog(playerid, DIALOG_HOUSE, DIALOG_STYLE_LIST, "House", "Vstupiù dnu\nZamknuù dom\nOdomknuù dom\nInformacie o Dome\t{00CCFF}PRE ADMINOV", "Select", "Cancel");
	  				}else{
                        ShowPlayerDialog(playerid, DIALOG_HOUSE, DIALOG_STYLE_LIST, "House", "Vstupiù dnu\nZamknuù dom\nOdomknuù dom", "Select", "Cancel");
					}
				}else{
					new string2[300];
					if(IsPlayerAdmin(playerid))
					{
				    	format(string2, sizeof(string2), "K˙più\t{00CCFF}%d\nPrehliadka domu\nInformacie o Dome\t{00CCFF}PRE ADMINOV", HouseInfo[HouseEntered[playerid]][hPrice]);
					}else{
                        format(string2, sizeof(string2), "K˙più\t{00CCFF}%d\nPrehliadka domu", HouseInfo[HouseEntered[playerid]][hPrice]);
					}
					ShowPlayerDialog(playerid, DIALOG_HOUSE_BUY, DIALOG_STYLE_LIST, "House", string2, "Select", "Cancel");
				}
			}
		}
	}
	for(new ID=2000; ID<MAX_HOUSES;ID++)
	{
        		if(IsPlayerInSphere(playerid,HouseInfo[ID][hX],HouseInfo[ID][hY],HouseInfo[ID][hZ],3)==1)
		{
			Message(playerid, "Pre otvorenie MENU stlaË Y");
		}
	}

	if(IsPlayerInSphere(playerid,GetHouseIntPosExit(HouseEntered[playerid], 0),GetHouseIntPosExit(HouseEntered[playerid], 1),GetHouseIntPosExit(HouseEntered[playerid], 2),3)==1)
	{
		Message(playerid, "Pre otvorenie MENU stlaË Y");
		if(PRESSED(KEY_YES))
		{
		    if(HouseVisit[playerid] == false)
		    {
			    SetPlayerPos(playerid, HouseInfo[HouseEntered[playerid]][hX],HouseInfo[HouseEntered[playerid]][hY],HouseInfo[HouseEntered[playerid]][hZ]);
				SetPlayerInterior(playerid, 0);
				SetPlayerVirtualWorld(playerid, 0);
			}else{
				Message(playerid, "Pr·ve si prezer·ö nov˝ interier ! NemÙûeö vysù z domu !");
			}
		}
	}
	if(IsPlayerInSphere(playerid,HouseIntPickUp[ GetHouseInterior( HouseEntered[ playerid ] ) ][0],HouseIntPickUp[ GetHouseInterior( HouseEntered[ playerid ] ) ][1],HouseIntPickUp[ GetHouseInterior( HouseEntered[ playerid ] ) ][2],3)==1)
	{
		if(PRESSED(KEY_YES))
		{
		    if(IsPlayerInInterior(playerid))
			{
				ShowPlayerDialog(playerid, DIALOG_HOUSE_SETTING, DIALOG_STYLE_LIST, "House Menu", "Nastavenia domu\nInvent·r\nZbrane\nPeniaze", "Select", "Cancel");
			}
		}
	}
	return 1;
}
CMD:nastaveniadomu(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_HOUSE_SETTING, DIALOG_STYLE_LIST, "House Menu", "Nastavenia domu\nInvent·r\nZbrane\nPeniaze", "Select", "Cancel");
	return 1;
}
stock MaxMoneyLevel(playerid, level)
{
	if(level <= 9)
	{
		switch(level)
		{
			case 1: return 750000;
			case 2: return 1650000;
			case 3: return 2820000;
			case 4: return 4100000;
			case 5: return 5200000;
			case 6: return 7400000;
			case 7: return 8600000;
			case 8: return 9800000;
			case 9: return 10000000;
		}
 	} else return Message(playerid, "SERVER ERROR: Please Report it to administrator, Error Name: MaxMoneyLevel(405)");
 	return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == DIALOG_HOUSE_SETTING)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					if(HouseInfo[HouseEntered[playerid]][isLocked] == true)
				 	{
						ShowPlayerDialog(playerid, DIALOG_HOUSE_SETTING2, DIALOG_STYLE_LIST, "House Menu", "Odomknuù dom", "Select", "Cancel");
					}else{
						ShowPlayerDialog(playerid, DIALOG_HOUSE_SETTING2, DIALOG_STYLE_LIST, "House Menu", "Zamknuù dom", "Select", "Cancel");
					}
				}
				case 1:
				{
					ShowPlayerDialog(playerid, DIALOG_HOUSE_SETTING, DIALOG_STYLE_LIST, "House Menu", "Prazdny slot\nPrazdny slot\nPrazdny slot\nPrazdny slot", "Select", "Cancel");
				}
				case 2:
				{
					ShowPlayerDialog(playerid, DIALOG_HOUSE_SETTING, DIALOG_STYLE_LIST, "House Menu", "Prazdny slot\nPrazdny slot\nPrazdny slot\nPrazdny slot", "Select", "Cancel");
				}
				case 3:
				{
				    new string[250];
				    format(string, sizeof(string), "Stav PenazÌ: {00CCFF}%d\nVybraù peniaze\nVloûiù peniaze",HouseInfo[HouseEntered[playerid]][Money]);
					ShowPlayerDialog(playerid, DIALOG_HOUSE_MONEY, DIALOG_STYLE_LIST, "House Money", string, "Select", "Close");
				}
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_HOUSE_MONEY)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					new string[250];
				    format(string, sizeof(string), "Aktualn˝ stav penazÌ v dome: %d",HouseInfo[HouseEntered[playerid]][Money]);
					Message(playerid, string);

				}
				case 1:
				{
                    ShowPlayerDialog(playerid, DIALOG_HOUSE_WITHDRAW, DIALOG_STYLE_INPUT, "House Money", "Vybranie penazÌ !", "Select", "Cancel");
				}
				case 2:
				{
                    ShowPlayerDialog(playerid, DIALOG_HOUSE_SAVE, DIALOG_STYLE_INPUT, "House Money", "Vloûenie penazÌ !", "Select", "Cancel");
				}
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_HOUSE_SAVE)
	{
		if(response)
		{
			if(MaxMoneyLevel(playerid, HouseInfo[HouseEntered[playerid]][MoneyLevel]) > HouseInfo[HouseEntered[playerid]][Money] && strval(inputtext) < MaxMoneyLevel(playerid, HouseInfo[HouseEntered[playerid]][MoneyLevel]) && strval(inputtext) < HouseInfo[HouseEntered[playerid]][Money])
 			{
				if(IsNumeric(inputtext))
				{
					if(GetPlayerMoney(playerid) >= strval(inputtext))
					{
						HouseInfo[HouseEntered[playerid]][Money] += strval(inputtext);
      					GivePlayerMoney(playerid, -strval(inputtext));
					}else{
						Message(playerid, "Nem·ö dostatok penazÌ pre vloûenie !");
					}
				}else{
					Message(playerid, "Vloûiù mÙûeö iba ËÌsla");
				}
			}else{
			    new string[200];
			    format(string, sizeof(string), "Do tvojho domu ide uloûiù maxim·lne: {00FF00}%d${A9C4E4}, aktu·lne m·ö uloûenÈ: {00FF00}%d$\n\
												{A9C4E4}Chcete uloûiù maxim·lny poËet penazÌ do domu ?",MaxMoneyLevel(playerid, HouseInfo[HouseEntered[playerid]][MoneyLevel]),
																										HouseInfo[HouseEntered[playerid]][Money]);
			    ShowPlayerDialog(playerid, DIALOG_HOUSE_SAVE2, DIALOG_STYLE_MSGBOX, "House Money", string, "Vloûit", "Cancel");
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_HOUSE_SAVE2)
 	{
 	    if(response)
 	    {
				new vypocet[MAX_PLAYERS];
				vypocet[playerid] = MaxMoneyLevel(playerid, HouseInfo[HouseEntered[playerid]][MoneyLevel]) - HouseInfo[HouseEntered[playerid]][Money];
				GivePlayerMoney(playerid, -vypocet[playerid]);
				HouseInfo[HouseEntered[playerid]][Money] += vypocet[playerid];
	 	}
	 	return 1;
 	}
	if(dialogid == DIALOG_HOUSE_WITHDRAW)
	{
		if(response)
		{
  			if(IsNumeric(inputtext))
			{
				if(HouseInfo[HouseEntered[playerid]][Money] >= strval(inputtext))
				{
					HouseInfo[HouseEntered[playerid]][Money] -= strval(inputtext);
  					GivePlayerMoney(playerid, strval(inputtext));
				}else{
						Message(playerid, "Nem·ö dostatok penazÌ pre vybratie z domu !");
				}
			}else{
				Message(playerid, "Vybraù mÙûeö iba ËÌsla !");
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_HOUSE_SETTING2)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
				    if(HouseInfo[HouseEntered[playerid]][isLocked] == true)
					{
					    Message(playerid, "Odomkol si dom !");
						HouseInfo[HouseEntered[playerid]][isLocked] = false;
				    }else{
				    	Message(playerid, "Zamkol si dom !");
						HouseInfo[HouseEntered[playerid]][isLocked] = true;
					}
				}
			}
		}else{
            			ShowPlayerDialog(playerid, DIALOG_HOUSE_SETTING, DIALOG_STYLE_LIST, "House Menu", "Nastavenia domu\nInvent·r\nZbrane\nPeniaze", "Select", "Cancel");
		}
		return 1;
	}
	if(dialogid == DIALOG_HOUSE)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					if(HouseInfo[HouseEntered[playerid]][isLocked] == false)
					{
						if(strcmp(HouseInfo[HouseEntered[playerid]][owner],PlayerName(playerid), false))
						{
							Message(playerid, "Vstupil si do domu");
							//SetPlayerInterior(playerid, GetHouseInterior( HouseEntered[ playerid ] ) );
							SetPlayerPos(playerid,GetHouseIntPos( HouseEntered[playerid], 0),GetHouseIntPos( HouseEntered[playerid], 1),GetHouseIntPos( HouseEntered[playerid], 2));
							SetPlayerInterior(playerid, GetHouseInterior( HouseEntered[ playerid ] ) );


							HouseInfo[HouseEntered[ playerid ]][CP] = CreateDynamicCP(2495.9302,-1693.0852,1014.7422, 1.5, playerid, GetHouseInterior(HouseEntered[ playerid ]));

							SetPlayerVirtualWorld(playerid, HouseEntered[playerid]);
							/*if(playerid == 0)
							{
								SetPlayerVirtualWorld(playerid, MAX_PLAYERS+1);
							}else{
								SetPlayerVirtualWorld(playerid, playerid);
							}*/
						}else{
									//AK NENI MAJITEL
									SetPlayerPos(playerid,GetHouseIntPos( HouseEntered[playerid], 0),GetHouseIntPos( HouseEntered[playerid], 1),GetHouseIntPos( HouseEntered[playerid], 2));
									SetPlayerInterior(playerid, GetHouseInterior(HouseEntered[playerid]) );
									SetPlayerVirtualWorld(playerid, HouseEntered[playerid]);
						}
					}else{
						Message(playerid, "Dom je zamknut˝ !");
					}
				}
				case 2:
				{
					Message(playerid, "Odomkol si dom");
					HouseInfo[HouseEntered[playerid]][isLocked] = false;
				}
				case 3:
				{
					new string[150];
					format(string, sizeof(string), "X: %d || Y: %d || Z: %d",	HouseInfo[HouseEntered[playerid]][hX],
												HouseInfo[HouseEntered[playerid]][hY],
												HouseInfo[HouseEntered[playerid]][hZ]);
					Message(playerid, string);

					format(string, sizeof(string), "CENA: %d || Interior: %d || PickUp: %d", 	HouseInfo[HouseEntered[playerid]][hPrice],
															HouseInfo[HouseEntered[playerid]][interiorID],
															HouseInfo[HouseEntered[playerid]][pickUp]);
					Message(playerid, string);

					format(string, sizeof(string), "Majitel: %s ", HouseInfo[HouseEntered[playerid]][owner]);
					Message(playerid, string);

					format(string, sizeof(string), "HouseEntered: %d || IntX: %f || IntY: %f || IntZ:%f || IntID: %d",		HouseEntered[playerid],
																		GetHouseIntPos( HouseEntered[playerid], 0),
																		GetHouseIntPos( HouseEntered[playerid], 1),
																		GetHouseIntPos( HouseEntered[playerid], 2),
																		GetHouseInterior(HouseEntered[playerid]));
					Message(playerid, string);
				}
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_HOUSE_BUY)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					if(HouseInfo[HouseEntered[playerid]][isOwned] == false)
					{
						if(GetPlayerMoney(playerid) >= HouseInfo[HouseEntered[playerid]][hPrice])
	  					{
							GivePlayerMoney(playerid, -HouseInfo[HouseEntered[playerid]][hPrice]);
							format(HouseInfo[HouseEntered[playerid]][owner], 25, "%s", PlayerName(playerid));
							new housezoneDIA[37];
							HouseInfo[HouseEntered[playerid]][isOwned] = true;
							Get2DZone(HouseInfo[HouseEntered[playerid]][hX],HouseInfo[HouseEntered[playerid]][hY], housezoneDIA, 37);

							if(HouseInfo[ HouseEntered[playerid] ][isVIP] == 0)
							{
								format(houseLabel, sizeof(houseLabel),"[ House ]\n%s %d\n%s",housezoneDIA,HouseEntered[playerid] , HouseInfo[HouseEntered[playerid]][owner]);
							}else{
                               	format(houseLabel, sizeof(houseLabel),"[ V.I.P House ]\n%s %d\n%s",housezoneDIA,HouseEntered[playerid] , HouseInfo[HouseEntered[playerid]][owner]);
							}
							UpdateDynamic3DTextLabelText(HouseInfo[HouseEntered[playerid]][TLabel], 0xFF0000FF, houseLabel);

							format(HouseInfo[HouseEntered[playerid]][owner], 25, "%s", PlayerName(playerid));
						}else{
							Message(playerid, "Nem·ö dostatok penazÌ !");
						}
					}else{
						Message(playerid, "Tento dom uû niekto vlastnÌ");
					}
				}
				case 1:
				{
					Message(playerid, "Prehliadka domu bola zapoËat· !");
				}
				case 2:
				{
					new string[256+1];
					format(string, sizeof(string), "X: %d || Y: %d || Z: %d",	HouseInfo[HouseEntered[playerid]][hX],
												HouseInfo[HouseEntered[playerid]][hY],
												HouseInfo[HouseEntered[playerid]][hZ]);
					Message(playerid, string);

					format(string, sizeof(string), "CENA: %d || Interior: %d || PickUp: %d", 	HouseInfo[HouseEntered[playerid]][hPrice],
														HouseInfo[HouseEntered[playerid]][interiorID],
														HouseInfo[HouseEntered[playerid]][pickUp]);
					Message(playerid, string);

					format(string, sizeof(string), "Majitel: %s ", HouseInfo[HouseEntered[playerid]][owner]);
					Message(playerid, string);

					format(string, sizeof(string), "HouseEntered: %d || IntX: %f || IntY: %f || IntZ:%f || IntID: %d",	HouseEntered[playerid],
																GetHouseIntPos( HouseEntered[playerid], 0),
																GetHouseIntPos( HouseEntered[playerid], 1),
																GetHouseIntPos( HouseEntered[playerid], 2),
                                                                                              									GetHouseInterior(HouseEntered[playerid]));
					Message(playerid, string);
				}
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_HOUSE_ADMIN)
 	{
 	    if(response)
 	    {
 	        switch(listitem)
 	        {
				case 0:
				{
				    ShowPlayerDialog(playerid, DIALOG_HOUSE_ADMIN_INT, DIALOG_STYLE_INPUT, "Administration House Setting", "Zadaj ID Interieru od 0-5\nAk je pr·zdne polÌËko default interier je 0 !", "Confirm", "Cancel");
				}
				case 1:
				{
				    ShowPlayerDialog(playerid, DIALOG_HOUSE_ADMIN_PRICE, DIALOG_STYLE_INPUT, "Administration House Setting", "Zadaj Cenu Domu.", "Confirm", "Cancel");
				}
				case 2:
				{
				    ShowPlayerDialog(playerid, DIALOG_HOUSE_ADMIN_OWN, DIALOG_STYLE_INPUT, "Administration House Setting", "Zadaj Majitela Domu\nPr·zdne sa rovn· odpredaj domu !", "Confirm", "Cancel");
				}
				case 3:
				{
				    ShowPlayerDialog(playerid, DIALOG_HOUSE_ADMIN_MONEY, DIALOG_STYLE_INPUT, "Administration House Setting", "Zadaj poËet penazÌ, koæko bude v dome !", "Confirm", "Cancel");
				}
				case 4:
				{
				    ShowPlayerDialog(playerid, DIALOG_HOUSE_ADMIN_TLEVEL, DIALOG_STYLE_INPUT, "Administration House Setting", "Zadaj Trezor Level 0-5 pre norm. hr·Ëov\n6-9 pre VIP !", "Confirm", "Cancel");
				}
				case 5:
				{
				    ShowPlayerDialog(playerid, DIALOG_HOUSE_ADMIN_VIP, DIALOG_STYLE_INPUT, "Administration House Setting", "Zadaj Ëi m· byù  dom VIP alebo nie\n 0/false = Norm·lny dom\n1/true = V.I.P dom", "Confirm", "Cancel");
				}
				case 6:
				{
                    ShowPlayerDialog(playerid, DIALOG_HOUSE_ACCEPT, DIALOG_STYLE_INPUT, "Administration House Setting", "V·ûne chcete smazaù tento dom ?", "Confirm", "Cancel");
				}
			}
	 	}
		return 1;
	}
	if(dialogid == DIALOG_HOUSE_ADMIN_INT)
	{
 		if(response)
   		{
  			if(GetPVarInt(playerid, "housecfg") >= 2000)
			{
				new string[150];
 				if(isnull(inputtext))
	   			{
   					HouseInfo[GetPVarInt(playerid, "housecfg")][interiorID] = 0;
			   	}else{
					if(strval(inputtext) <= MAX_HOUSE_INTERIORS)
	 				{
				  		HouseInfo[GetPVarInt(playerid, "housecfg")][interiorID] = strval(inputtext);
					}else{
					    new string1[50];
					    format(string1, sizeof(string1), "Rozmedzie interieru je 0-%d", MAX_HOUSE_INTERIORS);
						Message(playerid, string1);
						return 0;
					}
				}
                format(string, sizeof(string), "Administr·tor %s(%d) zmenil Interior Domu %d na %d", PlayerName(playerid), playerid, GetPVarInt(playerid, "housecfg"), HouseInfo[GetPVarInt(playerid, "housecfg")][interiorID]);
  				MessageTA(string);
			}else{
				Message(playerid, "ProsÌm eöte raz zadaj prÌkaz s ID Domu !");
			}
	 	}
    	return 1;
	}
	if(dialogid == DIALOG_HOUSE_ADMIN_PRICE)
	{
	    if(response)
	    {
   			if(!isnull(inputtext))
			{
				if(strval(inputtext) > MIN_HOUSE_PRICE)
		 		{
	    			new string[200];
		 	    	if(HouseInfo[GetPVarInt(playerid, "housecfg")][isOwned] == true)
			 	    {
						HouseInfo[GetPVarInt(playerid, "housecfg")][hPrice] = strval(inputtext);
					}else{
					    HouseInfo[GetPVarInt(playerid, "housecfg")][hPrice] = strval(inputtext);
						new housezoneDIA[37];
						Get2DZone(HouseInfo[GetPVarInt(playerid, "housecfg")][hX],HouseInfo[GetPVarInt(playerid, "housecfg")][hY], housezoneDIA, 37);
						if(HouseInfo[GetPVarInt(playerid, "housecfg")][isVIP] == 0)
				 		{
							format(houseLabel, sizeof(houseLabel),"[ House ]\n%s %d\n%s\n%d$",housezone, GetPVarInt(playerid, "housecfg"),HouseInfo[GetPVarInt(playerid, "housecfg")][owner], strval(inputtext));
						}else{
	     					format(houseLabel, sizeof(houseLabel),"[ V.I.P House ]\n%s %d\n%s\n%d$",housezone, GetPVarInt(playerid, "housecfg"), HouseInfo[GetPVarInt(playerid, "housecfg")][owner],strval(inputtext));
						}
						UpdateDynamic3DTextLabelText(HouseInfo[GetPVarInt(playerid, "housecfg")][TLabel], 0xFF0000FF, houseLabel);
					}
					format(string, sizeof(string), "Administr·tor %s(%d) zmenil Cenu Domu %d na {2C9F35}%d$", PlayerName(playerid), playerid, GetPVarInt(playerid, "housecfg"), HouseInfo[GetPVarInt(playerid, "housecfg")][hPrice]);
					MessageTA(string);
				}else{
					new string1[50];
					format(string1, sizeof(string1), "Minim·lna cena domu musÌ byù {2C9F35}%d$", MIN_HOUSE_PRICE);
					Message(playerid, string1);
				}
	 		}else{
				Message(playerid, "NemÙûe byù pr·zdne polÌËko !");
			}
	 	}
	 	return 1;
 	}
 	if(dialogid == DIALOG_HOUSE_ADMIN_OWN)
 	{
		if(response)
		{
		    if(!isnull(inputtext))
		    {
		        if(strcmp(inputtext, HOUSE_DEFAULT_OWNER, false)==0)
		        {
			        format(HouseInfo[GetPVarInt(playerid, "housecfg")][owner],25, "%s", HOUSE_DEFAULT_OWNER);
					HouseInfo[GetPVarInt(playerid, "housecfg")][isOwned] = false;
  				}else{
  					format(HouseInfo[GetPVarInt(playerid, "housecfg")][owner],25, "%s", inputtext);
					HouseInfo[GetPVarInt(playerid, "housecfg")][isOwned] = true;
				}
			}else{
				format(HouseInfo[GetPVarInt(playerid, "housecfg")][owner],25, "%s", HOUSE_DEFAULT_OWNER);
				HouseInfo[GetPVarInt(playerid, "housecfg")][isOwned] = false;
			}
			new housezoneDIA[37];
			Get2DZone(HouseInfo[GetPVarInt(playerid, "housecfg")][hX],HouseInfo[GetPVarInt(playerid, "housecfg")][hY], housezoneDIA, 37);
			if(HouseInfo[GetPVarInt(playerid, "housecfg")][isOwned] == false)
			{
				if(HouseInfo[GetPVarInt(playerid, "housecfg")][isVIP] == 0)
				{
					format(houseLabel, sizeof(houseLabel),"[ House ]\n%s %d\n%s\n%d$",housezone, GetPVarInt(playerid, "housecfg"),HouseInfo[GetPVarInt(playerid, "housecfg")][owner], HouseInfo[GetPVarInt(playerid, "housecfg")][hPrice]);
				}else{
					format(houseLabel, sizeof(houseLabel),"[ V.I.P House ]\n%s %d\n%s\n%d$",housezone, GetPVarInt(playerid, "housecfg"), HouseInfo[GetPVarInt(playerid, "housecfg")][owner], HouseInfo[GetPVarInt(playerid, "housecfg")][hPrice]);
				}
   			}else{
                if(HouseInfo[GetPVarInt(playerid, "housecfg")][isVIP] == 0)
				{
					format(houseLabel, sizeof(houseLabel),"[ House ]\n%s %d\n%s",housezone, GetPVarInt(playerid, "housecfg"),HouseInfo[GetPVarInt(playerid, "housecfg")][owner]);
				}else{
					format(houseLabel, sizeof(houseLabel),"[ V.I.P House ]\n%s %d\n%s",housezone, GetPVarInt(playerid, "housecfg"), HouseInfo[GetPVarInt(playerid, "housecfg")][owner]);
				}
			}
			UpdateDynamic3DTextLabelText(HouseInfo[GetPVarInt(playerid, "housecfg")][TLabel], 0xFF0000FF, houseLabel);
		}
		return 1;
	}
	if(dialogid == DIALOG_HOUSE_ADMIN_MONEY)
	{
		if(response)
		{
			if(!isnull(inputtext))
			{
				HouseInfo[GetPVarInt(playerid, "housecfg")][Money] = strval(inputtext);
				new string[250];
				format(string, sizeof(string), "Administr·tor %s nastavil peniaze na {2C9F35}%d${FFFFFF}, do domu %d.", PlayerName(playerid), strval(inputtext), GetPVarInt(playerid, "housecfg"));
				Message(playerid, string);
			}else{
				Message(playerid, "PolÌËko nemÙûe byù pr·zdne !");
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_HOUSE_ADMIN_TLEVEL)
	{
		if(response)
		{
			if(!isnull(inputtext))
			{
				HouseInfo[GetPVarInt(playerid, "housecfg")][MoneyLevel] = strval(inputtext);
				new string[250];
				format(string, sizeof(string), "Administr·tor %s nastavil Trezor Level na %d, do domu %d.", PlayerName(playerid), strval(inputtext), GetPVarInt(playerid, "housecfg"));
				Message(playerid, string);
			}else{
				Message(playerid, "PolÌËko nemÙûe byù pr·zdne !");
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_HOUSE_ACCEPT)
 	{
		if(response)
		{
			if(DOF2_FileExists(HousePath(GetPVarInt(playerid, "housecfg"))))
			{
				DOF2_RemoveFile(HousePath(GetPVarInt(playerid, "housecfg")));
				DestroyDynamic3DTextLabel(HouseInfo[ GetPVarInt(playerid, "housecfg")][TLabel]);
				DestroyDynamicPickup(HouseInfo[GetPVarInt(playerid, "housecfg")][pickUp]);

				HouseInfo[GetPVarInt(playerid, "housecfg")][hX] = 0;
				HouseInfo[GetPVarInt(playerid, "housecfg")][hY] = 0;
				HouseInfo[GetPVarInt(playerid, "housecfg")][hZ] = 0;
				HouseInfo[GetPVarInt(playerid, "housecfg")][isVIP] = 0;
				HouseInfo[GetPVarInt(playerid, "housecfg")][hPrice] = 0;
			 	HouseInfo[GetPVarInt(playerid, "housecfg")][isOwned] = false;
			 	HouseInfo[GetPVarInt(playerid, "housecfg")][isLocked] = false;
				HouseInfo[GetPVarInt(playerid, "housecfg")][interiorID] = 0;
			}
		}
	}
	if(dialogid == DIALOG_HOUSE_ADMIN_VIP)
	{
		if(response)
		{
		    if(!isnull(inputtext))
		    {
				new int = strval(inputtext);
		        if(int == 1 || strcmp(inputtext,"true",false)==0)
		        {
		            HouseInfo[GetPVarInt(playerid, "housecfg")][isVIP] = 1;
		            new string[250];
					format(string, sizeof(string), "Administr·tor %s nastavil domu %d status na V.I.P House", PlayerName(playerid), GetPVarInt(playerid, "housecfg"));
					Message(playerid, string);
				}else{
					if(int == 0 || strcmp(inputtext,"false",false)==0)
					{
					    HouseInfo[GetPVarInt(playerid, "housecfg")][isVIP] = 0;
					    new string[250];
						format(string, sizeof(string), "Administr·tor %s nastavil domu %d status na House", PlayerName(playerid), GetPVarInt(playerid, "housecfg"));
						Message(playerid, string);
					}
				}
				new housezoneDIA[37];
				Get2DZone(HouseInfo[GetPVarInt(playerid, "housecfg")][hX],HouseInfo[GetPVarInt(playerid, "housecfg")][hY], housezoneDIA, 37);
				if(HouseInfo[GetPVarInt(playerid, "housecfg")][isVIP] == 0)
	 			{
					format(houseLabel, sizeof(houseLabel),"[ House ]\n%s %d\n%s\n%d$",housezone, GetPVarInt(playerid, "housecfg"),HouseInfo[GetPVarInt(playerid, "housecfg")][owner], HouseInfo[GetPVarInt(playerid, "housecfg")][hPrice]);
				}else{
	     			format(houseLabel, sizeof(houseLabel),"[ V.I.P House ]\n%s %d\n%s\n%d$",housezone, GetPVarInt(playerid, "housecfg"), HouseInfo[GetPVarInt(playerid, "housecfg")][owner],HouseInfo[GetPVarInt(playerid, "housecfg")][hPrice]);
				}
				UpdateDynamic3DTextLabelText(HouseInfo[GetPVarInt(playerid, "housecfg")][TLabel], 0xFF0000FF, houseLabel);
			}else{
				Message(playerid, "PolÌËko nemÙûe byù pr·zdne !");
			}
		}
		return 1;
	}
	return 0;
}
CMD:housecfg(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return Message(playerid, "MusÌö byù administr·tor pre ovl·danie domu !");
	new id;
	if(sscanf(params, "i", id)) return Message(playerid, "/housecfg <HOUSE_ID>", "SYNTAX");
	new string[500];
	new vip[10];
	if(HouseInfo[id][isVIP] == 1) vip = "ANO";
	else vip = "NIE";
	format(string, sizeof(string), "Nastavenia Interieru\t{00CCFF}%d\n\
									Nastavenia Ceny\t{00CCFF}%d$\n\
									Nastavenia Majitela\t{00CCFF}%s\n\
								    Nastavenia PenazÌ\t{00CCFF}%d$\n\
								    Nastavenia Trezor Level\t{00CCFF}%d\n\
								    Nastavenia V.I.P\t{00CCFF}%s\n\
								    {FF0000}Zmazanie Domu\t{00CCFF}%d\n\
									",HouseInfo[id][interiorID],
									HouseInfo[id][hPrice],
									HouseInfo[id][owner],
									HouseInfo[id][Money],
									HouseInfo[id][MoneyLevel],
									vip,
									id);

	new stringh[30];
	format(stringh, sizeof(stringh), "Admin nastavenia, DOM ID:%d",id);
	SetPVarInt(playerid, "housecfg", id);
	ShowPlayerDialog(playerid, DIALOG_HOUSE_ADMIN, DIALOG_STYLE_TABLIST,stringh, string, "Nastaviù", "Cancel");
	return 1;
}
CMD:househelp(playerid, params[])
{
	ShowPlayerDialog(playerid, DIALOG_INFO, DIALOG_STYLE_MSGBOX, "House System Help", "{2C9F35}Vytv·ranie domov:\n{A9C4E4}/createhouse <CENA> <0/1 - NOVIP/VIP> <INTERIOR>\n\
																						\n\
																						{2C9F35}Nastavenia domu:\n{A9C4E4}/housecfg <ID DOMU>\n\
																						\n\
																						{2C9F35}Zmazanie domu:\n{A9C4E4}/delhouse <ID DOMU>", "Okay", "");
	return 1;
}
new TCount[MAX_PLAYERS];
new TimerOdpocet[MAX_PLAYERS];
new bool:TimerOdpoc[MAX_PLAYERS];
CMD:odpocet(playerid, params[])
{
	new count;
	if(sscanf(params, "i", count)) return Message(playerid, "/odpocet <SEK>", "SYNTAX");
	if(count < 3) return Message(playerid, "NemÙûe to byù menöie ako 3 !");
	if(TimerOdpoc[playerid] == true) return Message(playerid, "OdpoËet uû bezÌ pre  hr·Ëa !");
	TimerOdpoc[playerid] = true;
	Timer(playerid, count);
	return 1;
}
stock Timer(playerid, count)
{
    TimerOdpocet[playerid] = SetTimerEx("Odpocet", 1000, true, "i", playerid);
    TCount[playerid] = count;
	return 1;
}
forward Odpocet(playerid);
public Odpocet(playerid)
{
	if(TCount[playerid] == 0)
	{
	    GameTextForPlayer(playerid, "0", 1000, 6);
		KillTimer(TimerOdpocet[playerid]);
		TimerOdpoc[playerid] = false;
	}else{
	    new string[4];
	    if(TCount[playerid] == 3)
	 	{
	 	    format(string, sizeof(string), "G%d", TCount[playerid]);
	 	    GameTextForPlayer(playerid, string, 1000, 6);
 		}else{
 		    if(TCount[playerid] == 2)
 		    {
		 	    format(string, sizeof(string), "O%d", TCount[playerid]);
		 	    GameTextForPlayer(playerid, string, 1000, 6);
			}else{
                if(TCount[playerid] == 1)
                {
					format(string, sizeof(string), "R%d", TCount[playerid]);
		 			GameTextForPlayer(playerid, string, 1000, 6);
				}else{
			 	    format(string, sizeof(string), "%d", TCount[playerid]);
			 	    GameTextForPlayer(playerid, string, 1000, 6);
				}
			}
		}
		TCount[playerid]--;
	}
	return 1;
}

CMD:createhouse(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return Message(playerid, "MusÌö byù prÌhl·seny za RCON !");
	{
		new price,vip, interior;
	 	if(sscanf(params, "iiI(0)", price,vip,interior)) return Message(playerid, "/createhouse <CENA> <VIP=1|NORMAL=0> <INTERIOR>");
	 	if(MAX_HOUSES == LastHouseCreate())
	 	{
			Message(playerid, "Vytvoren˝ max. poËet domov ! [1/200]");
	        return 0;
		}else{
			new Float:pos[3];
			GetPlayerPos(playerid, pos[0],pos[1],pos[2]);

			new string[256];
			format(string, sizeof(string), "Hr·Ë %s(%d) vytvoril dom ID:%d, Cena:%d", PlayerName(playerid),playerid, LastHouseCreate(), price);

			MessageTA(string);

			CreateHouse(LastHouseCreate(), pos[0],pos[1],pos[2], price, vip, interior);
		}
	}
	return 1;
}

CMD:delhouse(playerid, params[])
{
	new id;
	if(sscanf(params,"i",id)) return Message(playerid, "/delhouse <ID>");

	if(DOF2_FileExists(HousePath(id)))
	{
		DOF2_RemoveFile(HousePath(id));
		DestroyDynamic3DTextLabel(HouseInfo[id][TLabel]);
		DestroyDynamicPickup(HouseInfo[id][pickUp]);

		HouseInfo[id][hX] = 0;
		HouseInfo[id][hY] = 0;
		HouseInfo[id][hZ] = 0;
		HouseInfo[id][isVIP] = 0;
		HouseInfo[id][hPrice] = 0;
	 	HouseInfo[id][isOwned] = false;
	 	HouseInfo[id][isLocked] = false;
		HouseInfo[id][interiorID] = 0;
	}
	return 1;
}
CMD:int(playerid)
{
	SetPlayerPos(playerid, 131.8434,-77.6558,1.4297);
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
	Message(playerid, "Portol si sa na DEBUG position");
	return 1;
}
CMD:vwint(playerid)
{
	new int = GetPlayerInterior(playerid);
	new vw = GetPlayerVirtualWorld(playerid);
	new Float:pos[3];
	GetPlayerPos(playerid, pos[0],pos[1],pos[2]);
	SCMF(playerid, "INT: %d, VW: %d", int , vw);
	SCMF(playerid, "X:%f, Y:%f, Z:%f", pos[0],pos[1],pos[2]);
	return 1;
}


CMD:money(playerid)
{
	PlayerInfo[playerid][Money] = 1000000;
	PlayerMoney(playerid, 1000000);
	GivePlayerMoney(playerid, 1000000);
	return 1;
}

CMD:savedomy(playerid)
{
	for(new o=1000;o<MAX_HOUSES;o++) SaveHouse(o);
	Message(playerid, "Vöetk˝ domy boli uspeöne uloûenÈ !");
	return 1;
}

stock SaveHouse(houseID)
{
	if(DOF2_FileExists(HousePath(houseID)))
	{
		DOF2_SetFloat(HousePath(houseID),"posX", HouseInfo[houseID][hX]);
		DOF2_SetFloat(HousePath(houseID),"posY", HouseInfo[houseID][hY]);
		DOF2_SetFloat(HousePath(houseID),"posZ", HouseInfo[houseID][hZ]);
		DOF2_SetInt(HousePath(houseID), "isVIP", HouseInfo[houseID][isVIP]);
		DOF2_SetInt(HousePath(houseID),"price", HouseInfo[houseID][hPrice]);
		DOF2_SetBool(HousePath(houseID),"isOwned", HouseInfo[houseID][isOwned]);
	 	DOF2_SetBool(HousePath(houseID),"isLocked", HouseInfo[houseID][isLocked]);
		DOF2_SetInt(HousePath(houseID),"interiorID",HouseInfo[houseID][interiorID]);
		DOF2_SetInt(HousePath(houseID),"Money",HouseInfo[houseID][Money]);
		DOF2_SetInt(HousePath(houseID),"MoneyLevel",HouseInfo[houseID][MoneyLevel]);
		DOF2_SetString(HousePath(houseID),"owner", HouseInfo[houseID][owner]);
		DOF2_SaveFile();
	}
	return 1;
}

forward Float:GetHouseIntPos(houseid, pos);
public Float:GetHouseIntPos(houseid, pos)
{
	return HouseIntPOS[ HouseInfo[ houseid ][ interiorID ] ][pos];
}

forward Float:GetHouseIntPosExit(houseid, pos);
public Float:GetHouseIntPosExit(houseid, pos)
{
	return HouseIntPosExit[ HouseInfo[ houseid ][ interiorID ] ][pos];
}

stock GetHouseInterior(houseID)
{
	return HouseIntID[HouseInfo[ houseID ][ interiorID ]][0];
}

stock SetHouseInterior(houseID, int)
{
	HouseInfo[ houseID ][ interiorID ] = int;
	return 1;
}

stock LastHouseCreate()
{
	for(HouseCount=2000; HouseCount<MAX_HOUSES; HouseCount++)
	{
		if(!DOF2_FileExists(HousePath(HouseCount)))
		{
			break;
		}
	}
	return HouseCount;
}
stock LoadHouse(houseID)
{
	if(DOF2_FileExists(HousePath(houseID)))
	{
		HouseInfo[houseID][hX] = DOF2_GetFloat(HousePath(houseID),"posX");
		HouseInfo[houseID][hY] = DOF2_GetFloat(HousePath(houseID),"posY");
		HouseInfo[houseID][hZ] = DOF2_GetFloat(HousePath(houseID),"posZ");
		HouseInfo[houseID][hPrice] = DOF2_GetInt(HousePath(houseID),"price");
		HouseInfo[houseID][isVIP] = DOF2_GetInt(HousePath(houseID),"isVIP");
		HouseInfo[houseID][isOwned] = DOF2_GetBool(HousePath(houseID),"isOwned");
	 	HouseInfo[houseID][isLocked] = DOF2_GetBool(HousePath(houseID),"isLocked");
		HouseInfo[houseID][interiorID] = DOF2_GetInt(HousePath(houseID),"interiorID");
        HouseInfo[houseID][Money] = DOF2_GetInt(HousePath(houseID),"Money");
    	HouseInfo[houseID][MoneyLevel] = DOF2_GetInt(HousePath(houseID),"MoneyLevel");

		format(HouseInfo[houseID][owner], 24, DOF2_GetString(HousePath(houseID),"owner"));

		new houseLab[150];
		Get2DZone(HouseInfo[houseID][hX],HouseInfo[houseID][hY], housezone, 37);
    	if(HouseInfo[houseID][isVIP] == 1)
		{
			if(HouseInfo[houseID][isOwned] == true)
			{
			    format(houseLab, sizeof(houseLab),"[ V.I.P House ]\n%s %d\n%s",housezone, houseID, HouseInfo[houseID][owner]);
			}else{
			    format(houseLab, sizeof(houseLab),"[ V.I.P House ]\n%s %d\nMesto\n%d$",housezone, houseID, HouseInfo[houseID][hPrice]);
			}
		}else{
			if(HouseInfo[houseID][isOwned] == true)
			{
			    format(houseLab, sizeof(houseLab),"[ House ]\n%s %d\n%s",housezone, houseID, HouseInfo[houseID][owner]);
			}else{
			    format(houseLab, sizeof(houseLab),"[ House ]\n%s %d\nMesto\n%d$",housezone, houseID, HouseInfo[houseID][hPrice]);
			}
		}
    	HouseInfo[houseID][TLabel] = CreateDynamic3DTextLabel(houseLab, 0xFF0000FF, HouseInfo[houseID][hX], HouseInfo[houseID][hY], HouseInfo[houseID][hZ]+0.7, 50.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);


		//
        for(new pid=0; pid<MAX_PLAYERS; pid++)
		{
			HouseInfo[houseID][pickUp] = CreateDynamicPickup(1273, 1, HouseInfo[houseID][hX], HouseInfo[houseID][hY], HouseInfo[houseID][hZ]);
  		}
	}
}
stock SetPosAllVW(vw, Float:x,Float:y,Float:z)
{
	for(new i=0;i < MAX_PLAYERS; i++)
	{
	    if(IsPlayerConnected(i))
	 	{
			if(GetPlayerVirtualWorld(i) == vw)
	  		{
				SetPlayerPos(i, x, y, z);
			}
		}
	}
	return 1;
}

stock UpdateHouseLabel(houseID)
{
   //UPDATE
}

stock PlayerName(playerid)
{
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, sizeof(name));
	return name;
}
public OnPlayerConnect(playerid)
{
	for(new b=2000;b<MAX_HOUSES;b++)
 	{
		HouseInfo[b][CP] = CreateDynamicCP(
							GetHouseIntPosExit(b, 0),
							GetHouseIntPosExit(b, 1),
							GetHouseIntPosExit(b, 2), 1.5, playerid);
	}
	return 1;
}
stock IsPlayerInVW(playerid, vw)
{
	if(GetPlayerVirtualWorld(playerid) > 0)
	{
		return true;
	}
	return false;
}

public OnFilterScriptInit()
{
	new housesLoaded, housesNoLoaded;
	print("NaËÌtanie FilterScriptu - ,,Houses");
	for(new i=2000; i<MAX_HOUSES;i++)
	{
	    if(DOF2_FileExists(HousePath(i)))
	    {
			housesLoaded++;
			LoadHouse(i);
			#if defined DEBUG
			printf("Dom: %d naËÌtan˝ ...", i);
			#endif
		}else{
			housesNoLoaded++;
		}
	}
	printf("[Houses] Loaded/MaxHouses - %d/%d", housesLoaded, housesNoLoaded);
	if(housesLoaded >= MAX_HOUSES)
	{
		SendRconCommand("exit");
	}
	SetTimer("SaveHouses", 5000, true);
	return 1;
}
public OnFilterScriptExit()
{
	print("VypÌnanie FilterScriptu - ,,Houses");
	SaveHouses();
	DOF2_Exit();
	return 1;
}

stock SaveHouses()
{
    for(new o=2000;o<MAX_HOUSES;o++) SaveHouse(o);
}

stock HousePath(houseID)
{
	new string[50];
	format(string, sizeof(string), HOUSE_PATH,houseID);
	return string;
}

stock IsPlayerInInterior(playerid)
{
    if(GetPlayerInterior(playerid) > 0)
    {
        return 1;
    }
    return 0;
}

stock IsPlayerInSphere(playerid,Float:x,Float:y,Float:z,radius)
{
	if(GetPlayerDistanceToPointEx(playerid,x,y,z) < radius)
	{
		return true;
	}
	return false;
}

stock GetPlayerDistanceToPointEx(playerid,Float:x,Float:y,Float:z)
{
	new Float:x1,Float:y1,Float:z1;
	new Float:tmpdis;
	GetPlayerPos(playerid,x1,y1,z1);
	tmpdis = floatsqroot(floatpower(floatabs(floatsub(x,x1)),2)+floatpower(floatabs(floatsub(y,y1)),2)+floatpower(floatabs(floatsub(z,z1)),2));
	return floatround(tmpdis);
}

stock GetHouseMoney(houseid) return HouseInfo[houseid][Money];


stock PlayerMoney(playerid, money)
{
	if(GetPlayerMoney(playerid) == PlayerInfo[playerid][Money])
	{
		if(GetPlayerMoney(playerid) >= money)
		{
			GivePlayerMoney(playerid, -money);
			PlayerInfo[playerid][Money] -= money;
		}else{
			Message(playerid, "Nem·ö dostatok PenazÌ !");
		}
	}else{
	}
}
stock Message(playerid, text[], customup[] = "!")
{
	new string[300];
	format(string, sizeof(string), "{FF0000}[ {FFFFFF}%s{FF0000} ]{FFFFFF} %s",customup, text);
	SendClientMessage(playerid, -1, string);
	return 1;
}
stock MessageTA(text[], customup[] = "!")
{
	new string[300];
	format(string, sizeof(string), "{FF0000}[ {FFFFFF}%s{FF0000} ]{FFFFFF} %s",customup, text);
	SendClientMessageToAll(-1, string);
	return 1;
}
stock SCMF(playerid,string[],{ Float, _ }: ...){
new len = strlen(string)+1;
new globalstr[256];
new found = 2;
new count;

new bool:founded = false;
for(new i; i < len;i++){
if(string[i] == '%'){
new str[128];
found++;
switch(string[i+1]){
case 'd','D':{
format(str,sizeof(str),"%d", getarg(found));
strins(globalstr, str, count,strlen(str));
count += strlen(str);
founded = true;
}
case 'f','F':{
format(str,sizeof(str),"%0.3f",getarg(found));
strins(globalstr, str, count,strlen(str));
count += strlen(str);
founded = true;
}
case 's','S':{
for(new b; getarg(found, b) != 0;b++) str[b] = getarg(found,b);
strins(globalstr, str, count,strlen(str));
count += strlen(str);
founded = true;
}
default:{
globalstr[count] = string[i];
count++;
founded = false;
found--;
}
}
}else{
if(!founded){
globalstr[count] = string[i];
count++;
}else founded = false;
}
}
Message(playerid,globalstr);
return true;
}
IsNumeric(const string[])
{
	for (new i = 0, j = strlen(string); i < j; i++)
	{
		if (string[i] > '9' || string[i] < '0') return 0;
	}
    return 1;
}
