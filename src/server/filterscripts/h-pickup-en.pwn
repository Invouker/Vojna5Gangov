//===============================================================================
//|					This Script Originaly Made by Haikal Bintang				|
//===============================================================================

#include <a_samp>
#include <zcmd>
#include <mSelection>
#include <sscanf2>

#define DIALOG_PICKUP_TEXT 9999
#define DIALOG_PICKUP_ID 10001
#define DIALOG_PICKUP_TEXT_COLOR 10002

new pickuptext[256];
new pickupmodel;
new pickuplist = mS_INVALID_LISTID;
new bool:pickupidmode = false;
    
public OnFilterScriptInit()
{
	pickuplist = LoadModelSelectionMenu("pickup.txt");
	print("H-Pickup created by Haikal Bintang.");
	return 1;
}

public OnPlayerModelSelection(playerid, response, listid, modelid)
{
    if((listid == pickuplist) && response)
    {
        pickupmodel = modelid;
        ShowPlayerDialog(playerid, DIALOG_PICKUP_TEXT_COLOR, DIALOG_STYLE_LIST, "Pickup Text Color", "Red\nBlue\nGreen\nYellow\nPurple\nGrey\nOrange", "Create", "Cancel");
    }
    return 1;
}

public OnPlayerSpawn(playerid)
{
	SendClientMessage(playerid, -1, "{FFFFFF}Type /createpickup to make an pickup.");
	return 1;
}

CMD:createpickup(playerid, params[])
{
	ShowPlayerDialog(playerid, DIALOG_PICKUP_TEXT, DIALOG_STYLE_INPUT, "Pickup Text", "Enter the pickup text below :\nFor example In-Game [Press [ENTER] untuk get in]", "Create", "Cancel");
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    
    if(dialogid == DIALOG_PICKUP_TEXT)
    {
        if(response)
        {
            if(pickupidmode == false)
            {
                format(pickuptext, sizeof(pickuptext), "%s", inputtext);
                ShowModelSelectionMenu(playerid, pickuplist, "Select the Pickup Models");
            }
            else
            {
                format(pickuptext, sizeof(pickuptext), "%s", inputtext);
                ShowPlayerDialog(playerid, DIALOG_PICKUP_ID, DIALOG_STYLE_INPUT, "Pickup ID", "Enter the pickup id below :", "Create", "Cancel");
            }
        }
        else
        {
            pickupidmode = false;
        }
    }
    if(dialogid == DIALOG_PICKUP_ID)
    {
        if(response)
        {
            if(IsNumeric(inputtext))
            {
                pickupmodel = strval(inputtext);
                ShowPlayerDialog(playerid, DIALOG_PICKUP_TEXT_COLOR, DIALOG_STYLE_LIST, "Pickup Text Color", "Red\nBlue\nGreen\nYellow\nPurple\nGrey\nOrange", "Create", "Cancel");
            }
            else
            {
                ShowPlayerDialog(playerid, DIALOG_PICKUP_ID, DIALOG_STYLE_INPUT, "Pickup ID", "Enter the pickup id below :", "Create", "Cancel");
                SendClientMessage(playerid, -1, "Invalid pickup ID.");
            }
        }
        else
        {
            pickupidmode = false;
        }
    }
    if(dialogid == DIALOG_PICKUP_TEXT_COLOR)
    {
        new string[256], Float:X, Float:Y, Float:Z;
        if(response)
        {
            if(listitem == 0)
            {
                GetPlayerPos(playerid, X, Y, Z);
 
                new File:pos=fopen("createdpickup.txt", io_append);
                format(string, 256, "CreatePickup(%i, 23, %f, %f, %f, %i);\r\n",  pickupmodel, X, Y, Z, GetPlayerVirtualWorld(playerid));
                fwrite(pos, string);
                format(string, 256, "Create3DTextLabel(%s, 0xAA3333AA, %f, %f, %f, 5.0, %i);\r\n", pickuptext, X, Y, Z+0.50, GetPlayerVirtualWorld(playerid));
                fwrite(pos, string);
                fclose(pos);
                CreatePickup(pickupmodel, 23, X, Y, Z, GetPlayerVirtualWorld(playerid));
                Create3DTextLabel(pickuptext, 0xAA3333AA, X, Y, Z+0.50, 5.0, GetPlayerVirtualWorld(playerid));
                SendClientMessage(playerid, -1, "{FFFFFF}Pickup created, all the pickup will be saved in scriptfiles -> createdpickup.txt.");
                SendClientMessage(playerid, -1, "{FFFFFF}Type /createpickup to make an pickup.");
            }
            if(listitem == 1)
            {
                GetPlayerPos(playerid, X, Y, Z);
 
                new File:pos=fopen("createdpickup.txt", io_append);
                format(string, 256, "CreatePickup(%i, 23, %f, %f, %f, %i);\r\n",  pickupmodel, X, Y, Z, GetPlayerVirtualWorld(playerid));
                fwrite(pos, string);
                format(string, 256, "Create3DTextLabel(%s, 0x007BD0FF, %f, %f, %f, 5.0, %i);\r\n", pickuptext, X, Y, Z+0.50, GetPlayerVirtualWorld(playerid));
                fwrite(pos, string);
                fclose(pos);
                CreatePickup(pickupmodel, 23, X, Y, Z, GetPlayerVirtualWorld(playerid));
                Create3DTextLabel(pickuptext, 0x007BD0FF, X, Y, Z+0.50, 5.0, GetPlayerVirtualWorld(playerid));
                SendClientMessage(playerid, -1, "{FFFFFF}Pickup created, all the pickup will be saved in scriptfiles -> createdpickup.txt.");
                SendClientMessage(playerid, -1, "{FFFFFF}Type /createpickup to make an pickup.");
            }
            if(listitem == 2)
            {
                GetPlayerPos(playerid, X, Y, Z);
 
                new File:pos=fopen("createdpickup.txt", io_append);
                format(string, 256, "CreatePickup(%i, 23, %f, %f, %f, %i);\r\n",  pickupmodel, X, Y, Z, GetPlayerVirtualWorld(playerid));
                fwrite(pos, string);
                format(string, 256, "Create3DTextLabel(%s, 0x33AA33AA, %f, %f, %f, 5.0, %i);\r\n", pickuptext, X, Y, Z+0.50, GetPlayerVirtualWorld(playerid));
                fwrite(pos, string);
                fclose(pos);
                CreatePickup(pickupmodel, 23, X, Y, Z, GetPlayerVirtualWorld(playerid));
                Create3DTextLabel(pickuptext, 0x33AA33AA, X, Y, Z+0.50, 5.0, GetPlayerVirtualWorld(playerid));
                SendClientMessage(playerid, -1, "{FFFFFF}Pickup created, all the pickup will be saved in scriptfiles -> createdpickup.txt.");
                SendClientMessage(playerid, -1, "{FFFFFF}Type /createpickup to make an pickup.");
            }
            if(listitem == 3)
            {
                GetPlayerPos(playerid, X, Y, Z);
 
                new File:pos=fopen("createdpickup.txt", io_append);
                format(string, 256, "CreatePickup(%i, 23, %f, %f, %f, %i);\r\n",  pickupmodel, X, Y, Z, GetPlayerVirtualWorld(playerid));
                fwrite(pos, string);
                format(string, 256, "Create3DTextLabel(%s, 0xFFFF00AA, %f, %f, %f, 5.0, %i);\r\n", pickuptext, X, Y, Z+0.50, GetPlayerVirtualWorld(playerid));
                fwrite(pos, string);
                fclose(pos);
                CreatePickup(pickupmodel, 23, X, Y, Z, GetPlayerVirtualWorld(playerid));
                Create3DTextLabel(pickuptext, 0xFFFF00AA, X, Y, Z+0.50, 5.0, GetPlayerVirtualWorld(playerid));
                SendClientMessage(playerid, -1, "{FFFFFF}Pickup created, all the pickup will be saved in scriptfiles -> createdpickup.txt.");
                SendClientMessage(playerid, -1, "{FFFFFF}Type /createpickup to make an pickup.");
            }
            if(listitem == 4)
            {
                GetPlayerPos(playerid, X, Y, Z);
 
                new File:pos=fopen("createdpickup.txt", io_append);
                format(string, 256, "CreatePickup(%i, 23, %f, %f, %f, %i);\r\n",  pickupmodel, X, Y, Z, GetPlayerVirtualWorld(playerid));
                fwrite(pos, string);
                format(string, 256, "Create3DTextLabel(%s, 0xC2A2DAAA, %f, %f, %f, 5.0, %i);\r\n", pickuptext, X, Y, Z+0.50, GetPlayerVirtualWorld(playerid));
                fwrite(pos, string);
                fclose(pos);
                CreatePickup(pickupmodel, 23, X, Y, Z, GetPlayerVirtualWorld(playerid));
                Create3DTextLabel(pickuptext, 0xC2A2DAAA, X, Y, Z+0.50, 5.0, GetPlayerVirtualWorld(playerid));
                SendClientMessage(playerid, -1, "{FFFFFF}Pickup created, all the pickup will be saved in scriptfiles -> createdpickup.txt.");
                SendClientMessage(playerid, -1, "{FFFFFF}Type /createpickup to make an pickup.");
            }
            if(listitem == 5)
            {
                GetPlayerPos(playerid, X, Y, Z);
 
                new File:pos=fopen("createdpickup.txt", io_append);
                format(string, 256, "CreatePickup(%i, 23, %f, %f, %f, %i);\r\n",  pickupmodel, X, Y, Z, GetPlayerVirtualWorld(playerid));
                fwrite(pos, string);
                format(string, 256, "Create3DTextLabel(%s, 0xAFAFAFAA, %f, %f, %f, 5.0, %i);\r\n", pickuptext, X, Y, Z+0.50, GetPlayerVirtualWorld(playerid));
                fwrite(pos, string);
                fclose(pos);
                CreatePickup(pickupmodel, 23, X, Y, Z, GetPlayerVirtualWorld(playerid));
                Create3DTextLabel(pickuptext, 0xAFAFAFAA, X, Y, Z+0.50, 5.0, GetPlayerVirtualWorld(playerid));
                SendClientMessage(playerid, -1, "{FFFFFF}Pickup created, all the pickup will be saved in scriptfiles -> createdpickup.txt.");
                SendClientMessage(playerid, -1, "{FFFFFF}Type /createpickup to make an pickup.");
            }
            if(listitem == 6)
            {
                GetPlayerPos(playerid, X, Y, Z);
 
                new File:pos=fopen("createdpickup.txt", io_append);
                format(string, 256, "CreatePickup(%i, 23, %f, %f, %f, %i);\r\n",  pickupmodel, X, Y, Z, GetPlayerVirtualWorld(playerid));
                fwrite(pos, string);
                format(string, 256, "Create3DTextLabel(%s, 0xFF8000FF, %f, %f, %f, 5.0, %i);\r\n", pickuptext, X, Y, Z+0.50, GetPlayerVirtualWorld(playerid));
                fwrite(pos, string);
                fclose(pos);
                CreatePickup(pickupmodel, 23, X, Y, Z, GetPlayerVirtualWorld(playerid));
                Create3DTextLabel(pickuptext, 0xFF8000FF, X, Y, Z+0.50, 5.0, GetPlayerVirtualWorld(playerid));
                SendClientMessage(playerid, -1, "{FFFFFF}Pickup created, all the pickup will be saved in scriptfiles -> createdpickup.txt.");
                SendClientMessage(playerid, -1, "{FFFFFF}Type /createpickup to make an pickup.");
            }
        }
    }
    return 0;
}

stock IsNumeric(const string[])
{
    for (new i = 0, j = strlen(string); i < j; i++)
    {
        if (string[i] > '9' || string[i] < '0') return 0;
    }
    return 1;
}
