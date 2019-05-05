#include <a_samp>

#include <vg5>
#include <vg5_languages>
#include <vg5_callbacks>

#include <foreach>

#pragma unused AdminInfo

#define BANK_ENTER_X 2141.9255
#define BANK_ENTER_Y 1629.3380
#define BANK_ENTER_Z 993.5761

#define BANK_EXIT_X 2141.9255
#define BANK_EXIT_Y 1629.3380
#define BANK_EXIT_Z 993.5761

#define BANK_PICKUP_X 2141.9255
#define BANK_PICKUP_Y 1629.3380
#define BANK_PICKUP_Z 993.5761

stock CreateBank(id, Float:bX, Float:bY, Float:bZ)
{
	BankInfo[id][bankX] = bX;
	BankInfo[id][bankY] = bY;
	BankInfo[id][bankZ] = bZ;
	
		
	BankInfo[id][label] =  CreateDynamic3DTextLabel("{FF0000}[ BANKA ]\nVstup", -1, bX, bY, bZ+0.6, 50.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
	BankInfo[id][CP] = CreateDynamicCP(BANK_EXIT_X,BANK_EXIT_Y,BANK_EXIT_Z, 1.5, id, 0);
	BankInfo[id][MapIcon] = CreateDynamicMapIcon(bX, bY, bZ, 52, 0, 0, 0, -1, 100.0);
	BankInfo[id][Pickup] = CreateDynamicPickup(1274, 1, bX, bY, bZ, 0, 0);
}

public OnPlayerPickUpDynamicPickup(playerid, pickupid)
{
	for(new bankID; bankID < MAX_BANKS; bankID++)
	{
		if(pickupid == BankInfo[bankID][Pickup])
		{
		    // natrafili sme na id danej banky do ktorej vstupil
		    SetPlayerVirtualWorld(playerid, bankID);
			SetPlayerPos(playerid, BANK_ENTER_X, BANK_ENTER_Y, BANK_ENTER_Z); // Vstup do banky POZICIA
			break;
		}
	}
	return 1;
}

public OnPlayerEnterDynamicCP(playerid, checkpointid)
{
	for(new bankID; bankID < MAX_BANKS; bankID++)
	{
		if(checkpointid == BankInfo[bankID][CP])
		{
		  	Dialog_Show(playerid, Banka, DIALOG_STYLE_LIST, "Banka", "Výber\nVklad\nVybra všetko\nVloži všetko\nPrevod penazí", "Select", "Cancel");
			break;
		}
	}
	return 1;
}

Dialog:Banka(playerid, response, listitem, inputtext[])
{
	if(!response) return Dialog_Close(playerid);
	else {
		switch(listitem)
		{
			case 0: { // výber
					Dialog_Show(playerid, BankaVyber, DIALOG_STYLE_INPUT, "Banka - Výber", "Zadajte množstvo, ko¾ko chcete vybra penez z banky.", "Vybra", "Cancel");
			}
			case 1: { // vklad
					Dialog_Show(playerid, BankaVklad, DIALOG_STYLE_INPUT, "Banka - Vklad", "Zadajte množstvo, ko¾ko chcete vloži penez z banky.", "Vloži", "Cancel");
			}
			case 2: { // výber všetko
					Dialog_Show(playerid, BankaVyberVsetko, DIALOG_STYLE_MSGBOX, "Banka - Výbra všetko", "Fakt chcete vybra všetký peniaze ?", "Ano", "Nie");
			}
			case 3: { // vloži všetko
					Dialog_Show(playerid, BankaVlozVsetko, DIALOG_STYLE_MSGBOX, "Banka - Vloži všetko", "Fakt chcete vloži všetký peniaze do banky?", "Ano", "Nie");
			}
			case 4: { // Prevod penazí
					Dialog_Show(playerid, BankaPrevodPenazi, DIALOG_STYLE_INPUT, "Banka - Výber", "Zadajte id/meno (aj offline) hráèa komu chcete previes peniaze.", "Enter", "Cancel");
			}
		}
	}
	return 1;
}

Dialog:BankaVyber(playerid, response, listitem, inputtext[])
{
	if(!response) return Dialog_Close(playerid);
	else {
		if(strval(inputtext) <= PlayerInfo[playerid][Bank])
		{
			GivePlayerMoney(playerid, strval(inputtext));
			PlayerInfo[playerid][Bank] = GetPlayerMoney(playerid);
		}
	}
	return 1;
}

Dialog:BankaVklad(playerid, response, listitem, inputtext[])
{
	if(!response) return Dialog_Close(playerid);
	else {

	}
	return 1;
}

Dialog:BankaVyberVsetko(playerid, response, listitem, inputtext[])
{
	if(!response) return Dialog_Close(playerid);
	else {

	}
	return 1;
}

Dialog:BankaVlozVsetko(playerid, response, listitem, inputtext[])
{
	if(!response) return Dialog_Close(playerid);
	else {

	}
	return 1;
}

Dialog:BankaPrevodPenazi(playerid, response, listitem, inputtext[])
{
	if(!response) return Dialog_Close(playerid);
	else {

	}
	return 1;
}

public OnFilterScriptInit()
{
	CreateBank(0, -2374.6970, 942.3097, 45.4453);
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}
