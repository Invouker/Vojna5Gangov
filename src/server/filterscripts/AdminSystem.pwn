#include <a_samp>

#include <vg5>
#include <vg5_languages>
#include <vg5_callbacks>

#include <foreach>

new MuteTime[MAX_PLAYERS];

CMD:admins(playerid)
{
	new string[512], x;
	foreach(new p : Player)
	{
		if(GetAdminLevel(p) > 0 && !AdminInfo[playerid][aVisible])
		{
		    new tStr[70];
		    format(tStr, sizeof(tStr), "%s(%i) - Level(%d)", PlayerName(p),p,GetAdminLevel(p));
			strcat(string, tStr);
           	if(IsPlayerAdmin(p)) // ak m· RCON prid·me +RCON k Admin levelu
			{
		    	format(tStr, sizeof(tStr), "+[RCON]", PlayerName(p),p);
				strcat(string, tStr);
			}
			strcat(string, ", ");
		}

		if(x >= 2) // ak su dvaja vedæa seba vloûÌme \n aby uû dalöÌ iöli  do Ôalöieho riadku
		{
			x = 0;
			strcat(string, "\n");
		}
		x++;
	}
	if(isnull(string)) strcat(string, "Moment·lne nieje online ûiadny administr·tor");
	Dialog_Show(playerid, AdminList, DIALOG_STYLE_MSGBOX, "Online Administratori", string, "Cancel", ""); // vypÌöe online adminov do DIALOGU a zobrazÌ ich

	return 1;
}

CMD:say(playerid, params[])
{
    if(GetAdminLevel(playerid) >= 1 || IsPlayerAdmin(playerid))
    {
        new text[256];
		if(sscanf(params, "s[256]", text)) return SendClientMessage(playerid, -1, "/say <text>");

		format(text, sizeof(text), "**Admin %s(%d): %s", PlayerName(playerid), playerid, text);
		SendClientMessageToAll(COLOR_LIGHTBLUE, text);
	}
	return 1;
}

CMD:warn(playerid, params[])
{
    if(GetAdminLevel(playerid) >= 1 || IsPlayerAdmin(playerid))
    {
        new pid,text[128];
		if(sscanf(params, "is[128]",pid, text)) return SendClientMessage(playerid, COLOR_RED, "Usage: /warn <playerid> <reason>");
		if(IsPlayerConnected(pid)) return SendClientMessage(playerid, COLOR_RED, "Hr·Ë moment·lne nieje online!");
		AdminInfo[pid][varns]++;

		format(text, sizeof(text), "[%i/3] Hr·Ë %s(%i) dostal varovanie od administr·tora %s(%d) za %s.",AdminInfo[pid][varns], PlayerName(pid), pid,PlayerName(playerid), playerid, text);

		if(AdminInfo[pid][varns] >= 3)
		{
			KickEx(playerid, text);
	 	}


		SendClientMessageToAll(COLOR_LIGHTBLUE, text);
	}
	return 1;
}

CMD:mute(playerid, params[])
{
    if(GetAdminLevel(playerid) >= 1 || IsPlayerAdmin(playerid))
    {
        new pid,time, reason[128];
		if(sscanf(params, "iis[128]",pid,time, reason)) return SendClientMessage(playerid, -1, "/mute <playerid> <min˙ty> <reason>");
		if(IsPlayerConnected(pid)) return SendClientMessage(playerid, COLOR_RED, "Hr·Ë moment·lne nieje online!");

		AdminInfo[pid][isMuted] = true;
        MuteTime[pid] = (gettime() + (60*time));

		format(reason, sizeof(reason), "Administr·tor %s(%d) umlËal hr·Ëa %s(%i) na %i min˙t, za %s.",PlayerName(playerid), playerid,PlayerName(pid), pid, time,reason);
		SendClientMessageToAll(COLOR_LIGHTBLUE, reason);
	}
	return 1;
}

CMD:goto(playerid, params[])
{
    if(GetAdminLevel(playerid) >= 1 || IsPlayerAdmin(playerid))
    {
        new pid;
		if(sscanf(params, "i",pid)) return SendClientMessage(playerid, -1, "/goto <playerid>");
		if(!IsPlayerConnected(pid)) return SendClientMessage(playerid, COLOR_RED, "Hr·Ë moment·lne nieje online!");
		if(pid == playerid) return SendClientMessage(playerid, COLOR_RED, "NemÙûeö sa portnuù s·m na seba!");

		new str[128];
		format(str, sizeof(str), "Administr·tor %s(%d) sa na teba portol.",PlayerName(playerid), playerid);
		SendClientMessage(pid, COLOR_LIGHTBLUE, str);
		new Float:pos[3];
		GetPlayerPos(pid, pos[0],pos[1],pos[2]);

  		if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT || PLAYER_STATE_DRIVER)  {
       		new getv = GetPlayerVehicleID(playerid);
       		SetVehiclePos(getv,pos[0],pos[1],pos[2]);
       		PutPlayerInVehicle(playerid,getv,0);
       		SetVehicleVirtualWorld(getv, GetPlayerVirtualWorld(pid));
       	}

       	SetPlayerVirtualWorld(playerid,  GetPlayerVirtualWorld(pid));
       	SetPlayerPos(playerid, pos[0],pos[1],pos[2]);
	}
	return 1;
}

CMD:ahide(playerid)
{
    if(GetAdminLevel(playerid) >= 5 || IsPlayerAdmin(playerid))
	{
		if(AdminInfo[playerid][aVisible])
		{ // ak je schovan˝
		    AdminInfo[playerid][aVisible] = false;
		}else{
		    //ak nieje schovan˝, schov· ho
            AdminInfo[playerid][aVisible] = true;
		}
		CallRemoteFunction("cmd_vinvisible", "i", playerid);
	}else return false;
	return 1;
}

CMD:setlevel(playerid, params[])
{
	if(GetAdminLevel(playerid) >= 5 || IsPlayerAdmin(playerid))
	{
	    new pid, level;
		if(sscanf(params, "ui", pid, level)) return SendClientMessage(playerid, COLOR_LIGHTRED, "/setlevel <playerid/name> <level>");
		if(!IsPlayerConnected(pid)) return SendClientMessage(playerid, COLOR_LIGHTRED, "Hr·Ë moment·lne nieje na servery.");
		if(level < 0 || level > 5) return SendClientMessage(playerid, COLOR_LIGHTRED, "Rozmedzie Admin Levela, ktorÈ mÙûeö nastaviù je 1-5.");

		new string[128];
		if(level == 0) 	format(string, sizeof(string), "Administr·tor %s(%d) odobral hr·Ëovy %s(%d) admin level.", PlayerName(playerid), playerid, PlayerName(pid),pid);
		else format(string, sizeof(string), "Administr·tor %s(%d) nastavil hr·Ëovy %s(%d) admin level %d.", PlayerName(playerid), playerid, PlayerName(pid),pid, level);
		SendClientMessageToAll(COLOR_LIMEGREEN, string);
		SetAdminLevel(pid, level);
	}else return false;
	return 1;
}

public OnFilterScriptInit()
{
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}


public OnPlayerConnect(playerid)
{
	return 1;
}

public OnPlayerText(playerid)
{
	if(AdminInfo[playerid][isMuted])
	{
        if(gettime() < (MuteTime[playerid]))
		{
		    new string[128];
		    format(string, sizeof(string), "NemÙûeö pÌsaù, si umlËan˝ eöte po dobu %02d min˙t a %02d sekund.", ((MuteTime[playerid]-gettime())/60), ((MuteTime[playerid]-gettime()) % 60));
			SendClientMessage(playerid, COLOR_BLUE, string);
			return 0;
		}
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    AdminInfo[playerid][varns] = 0;
    SetAdminLevel(playerid, 0);
	return 1;
}

stock IsPlayerALevel(playerid, level)
{
	if(GetAdminLevel(playerid) >= level) return true;
	else return false
}

stock GetAdminLevel(playerid)
{
	return PlayerInfo[playerid][adminLevel];
}

stock SetAdminLevel(playerid, level)
{
	PlayerInfo[playerid][adminLevel] = level;
}

