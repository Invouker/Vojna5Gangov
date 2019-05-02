/*
	GUI Script
	11.12.2008
	
	bzuco
	
	Obsahuje:
	Univerzalnu tabulku pre hraca
	
	Instalacia:
	1.Do OnGameModeInit() nakopirovat GUI_Initialize();
	2.Do hlavneho sekundoveho timeru pre hracov pridat: GUI_SecondTimer(playerid);
	
	native ShowTableMessage(playerid,time,text[],bool:important)
	native ShowPlayerWideScreen(playerid);
	native HidePlayerWideScreen(playerid);
*/
#if defined _vg_gui_included
	#endinput
#endif
#define _vg_gui_included
#pragma library vg_gui
#include <a_samp>

#define UTABLE_BUFFER 5    //kolko sprav sa ulozi do zasobnika pre univerzalnu tabulku

//skriptovacie funkcie:
forward ShowTableMessage(playerid,time,text[],bool:important);
forward ShowPlayerWideScreen(playerid);
forward HidePlayerWideScreen(playerid);
//Euro logo
forward Euro_Initialize();
forward ShowEuroForPlayer(playerid);
forward HideEuroForPlayer(playerid);
//ostatne funkcie
forward GUI_SecondTimer(playerid);
forward GUI_Initialize();

enum pTable
{
	Text:uTable,
	uTableShowTime,
	buffer,
	bool:uTableSee,
}
new GUI_uTable[MAX_PLAYERS][pTable];

new uTableBuffer[MAX_PLAYERS][UTABLE_BUFFER][128];
new uTableBufferTime[MAX_PLAYERS][10];

new Text:GUI_InfoBox;

new Text:txt_ciernypas1;
new Text:txt_ciernypas2;
new Text:evro_c;
new Text:evro_cmparator;

//Posledny parameter important urcuje ci sa sprava moze ukladat do bufferu. Pouzivat true ak ide o dolezitu spravu
public ShowTableMessage(playerid,time,text[],bool:important)
{
	if(GUI_uTable[playerid][uTableSee]==false)
	{
		TextDrawSetString(GUI_uTable[playerid][uTable],text);
		TextDrawShowForPlayer(playerid,GUI_uTable[playerid][uTable]);
		TextDrawShowForPlayer(playerid,GUI_InfoBox);
		GUI_uTable[playerid][uTableSee]=true;
		GUI_uTable[playerid][uTableShowTime]=time;
	}else{
	    if(important==true)
	    {
		    if(GUI_uTable[playerid][buffer]<UTABLE_BUFFER)
		    {
			    uTableBufferTime[playerid][GUI_uTable[playerid][buffer]]=time;
			    format(uTableBuffer[playerid][GUI_uTable[playerid][buffer]],128,"%s",text);
			    //memcpy(uTableBuffer[playerid][GUI_uTable[playerid][buffer]], text,0,512);
			    GUI_uTable[playerid][buffer]++;
		    }
	    }
	}
	return true;
}



public ShowPlayerWideScreen(playerid)
{
    TextDrawShowForPlayer(playerid,txt_ciernypas1);
    TextDrawShowForPlayer(playerid,txt_ciernypas2);
}

public HidePlayerWideScreen(playerid)
{
    TextDrawHideForPlayer(playerid,txt_ciernypas1);
    TextDrawHideForPlayer(playerid,txt_ciernypas2);
}

public GUI_SecondTimer(playerid)
{
	if(GUI_uTable[playerid][uTableSee])
	{
	    if(GUI_uTable[playerid][uTableShowTime]>0)
	    {
	        GUI_uTable[playerid][uTableShowTime]--;
	    }else{
	        TextDrawHideForPlayer(playerid,GUI_uTable[playerid][uTable]);
    		TextDrawHideForPlayer(playerid,GUI_InfoBox);
			GUI_uTable[playerid][uTableSee]=false;
	        if(GUI_uTable[playerid][buffer]!=0)
	        {
			    //zobrazenie dalsej spravy:
			    GUI_uTable[playerid][buffer]--;
			    TextDrawSetString(GUI_uTable[playerid][uTable],uTableBuffer[playerid][GUI_uTable[playerid][buffer]]);
			    uTableBuffer[playerid][GUI_uTable[playerid][buffer]]="";
				TextDrawShowForPlayer(playerid,GUI_uTable[playerid][uTable]);
				TextDrawShowForPlayer(playerid,GUI_InfoBox);
				GUI_uTable[playerid][uTableSee]=true;
				GUI_uTable[playerid][uTableShowTime]=uTableBufferTime[playerid][GUI_uTable[playerid][buffer]];
			}
	    }
	}
	return true;
}

forward GUI_CreateTable(i);
public GUI_CreateTable(i)
{
    GUI_uTable[i][uTable] = TextDrawCreate(20.000000,168.000000," ");
	TextDrawUseBox(GUI_uTable[i][uTable],1);
	TextDrawBoxColor(GUI_uTable[i][uTable],0x00000066);
	TextDrawTextSize(GUI_uTable[i][uTable],150.000000,168.000000);
	TextDrawAlignment(GUI_uTable[i][uTable],0);
	TextDrawBackgroundColor(GUI_uTable[i][uTable],0x000000ff);
	TextDrawFont(GUI_uTable[i][uTable],1);
	TextDrawLetterSize(GUI_uTable[i][uTable],0.299999,1.500000);
	TextDrawColor(GUI_uTable[i][uTable],0xffffffff);
	TextDrawSetOutline(GUI_uTable[i][uTable],1);
	TextDrawSetProportional(GUI_uTable[i][uTable],1);
	TextDrawSetShadow(GUI_uTable[i][uTable],1);
}

forward GUI_DestroyTable(i);
public GUI_DestroyTable(i)
{
	TextDrawDestroy(GUI_uTable[i][uTable]);
}

public GUI_Initialize()
{
    GUI_InfoBox = TextDrawCreate(20.000000,154.000000,"       ~g~VG~r~6 ~g~InfoBox");
	TextDrawUseBox(GUI_InfoBox,1);
	TextDrawBoxColor(GUI_InfoBox,0x00000099);
	TextDrawTextSize(GUI_InfoBox,150.000000,154.000000);
	TextDrawAlignment(GUI_InfoBox,1);
	TextDrawBackgroundColor(GUI_InfoBox,0x000000ff);
	TextDrawFont(GUI_InfoBox,1);
	TextDrawLetterSize(GUI_InfoBox,0.299999,1.000000);
	TextDrawColor(GUI_InfoBox,0xffffffff);
	TextDrawSetOutline(GUI_InfoBox,1);
	TextDrawSetProportional(GUI_InfoBox,1);
	TextDrawSetShadow(GUI_InfoBox,1);

	
	txt_ciernypas1 = TextDrawCreate(1.000000,1.000000,"_");
	txt_ciernypas2 = TextDrawCreate(1.000000,356.000000,"_");
	TextDrawUseBox(txt_ciernypas1,1);
	TextDrawBoxColor(txt_ciernypas1,0x00000099);
	TextDrawTextSize(txt_ciernypas1,640.000000,-23.000000);
	TextDrawUseBox(txt_ciernypas2,1);
	TextDrawBoxColor(txt_ciernypas2,0x00000099);
	TextDrawTextSize(txt_ciernypas2,640.000000,10.000000);
	TextDrawAlignment(txt_ciernypas1,0);
	TextDrawAlignment(txt_ciernypas2,0);
	TextDrawBackgroundColor(txt_ciernypas1,0x000000ff);
	TextDrawBackgroundColor(txt_ciernypas2,0x000000ff);
	TextDrawFont(txt_ciernypas1,3);
	TextDrawLetterSize(txt_ciernypas1,1.100000,9.899999);
	TextDrawFont(txt_ciernypas2,3);
	TextDrawLetterSize(txt_ciernypas2,1.000000,9.899991);
	TextDrawColor(txt_ciernypas1,0xffffffff);
	TextDrawColor(txt_ciernypas2,0xffffffff);
	TextDrawSetOutline(txt_ciernypas1,1);
	TextDrawSetOutline(txt_ciernypas2,1);
	TextDrawSetProportional(txt_ciernypas1,1);
	TextDrawSetProportional(txt_ciernypas2,1);
	TextDrawSetShadow(txt_ciernypas1,1);
	TextDrawSetShadow(txt_ciernypas2,1);
}

public Euro_Initialize()
{
    evro_c = TextDrawCreate(491.000000,76.000000,"~g~C");
	evro_cmparator = TextDrawCreate(485.000000,83.000000,"~g~=");
	TextDrawAlignment(evro_c,0);
	TextDrawAlignment(evro_cmparator,0);
	TextDrawBackgroundColor(evro_c,0x000000ff);
	TextDrawBackgroundColor(evro_cmparator,0x000000ff);
	TextDrawFont(evro_c,1);
	TextDrawLetterSize(evro_c,1.000000,2.399999);
	TextDrawFont(evro_cmparator,3);
	TextDrawLetterSize(evro_cmparator,1.000000,1.000000);
	TextDrawColor(evro_c,0xffffffff);
	TextDrawColor(evro_cmparator,0xffffffff);
	TextDrawSetOutline(evro_c,1);
	TextDrawSetOutline(evro_cmparator,1);
	TextDrawSetProportional(evro_c,1);
	TextDrawSetProportional(evro_cmparator,1);
	TextDrawSetShadow(evro_c,1);
	TextDrawSetShadow(evro_cmparator,1);
	return 1;
}

public ShowEuroForPlayer(playerid)
{
	TextDrawShowForPlayer(playerid,evro_c);
	TextDrawShowForPlayer(playerid,evro_cmparator);
	return 1;
}

public HideEuroForPlayer(playerid)
{
	TextDrawHideForPlayer(playerid,evro_c);
	TextDrawHideForPlayer(playerid,evro_cmparator);
	return 1;
}
