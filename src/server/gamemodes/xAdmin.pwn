#include <a_samp>
#include <zcmd>
#include <xFunction>
//#include <sscanf>
#include <DOF2>
#include <xColor>
#include <YSI\y_ini>

#define ELECTRIC_SHOCK 7 // Doba ElektrickÈho öoku v sekund·ch

native WP_Hash(buffer[], len, const str[]);
/*
#define USER_FILE_LENGTH 50
#define PP_WP
#define MODE_NAME "xAdmin"
//#include <YSI\y_users>

#include <YSI>

//#include <YSI\y_ini>
*/


//*************************************************//
/****************************************************
		PRÕKAZY PRE ADMIN SYSTEM by XpresS
 ALVL 0: /dotaz /report

 ALVL 1: /goto /spec /specoff /slay /samotka /var /ahelp /say /cevent //ADMINCHAT @VIPCHAT /dotazy /dotazr
 ALVL 2: /ajail /freeze /unfreeze /var /get /heal /healr /cc /eject /setdrunk
 ALVL 3: /kick /respawn /aflip /akill /carcolor /explode /setwtime /alock /aunlock
 ALVL 4: /aban /ipban /ip /unban /car /setskin /crash /saveall /setvhealth /gwl /swl
 ALVL 5: /pban /log /connections /avar /savar /setlvl /gcar /rcar /gmx /respawncar
 ALVL 6: /god /setinterior /setpos /loadpos /setvw /jetpack /hydra

        PRÕKAZY PRI EVENTOCH
 ALVL 1: /ghost /ghostr /ghostoff /cevent <- RAZ ZA HODINU max.
                                    Pri zaloûen˝ eventu /ann /dann
 ALVL 2: /setport /setnkzona
 ALVL 3: /gpw /gpwr /disarm
 ALVL 4: /ebody

        PRÕKAZY PRE VIP
 VLVL BRONZ: BANKA;100K HVH @VIPCHAT /vflip /vrepair
 VLVL GOLD: BANKA;250K /vinviisible /vnitro,
 VLVL PLATINUM: BANKA;500K

 **BANKA;XXX == KAéDY DEN XXX $ do banky **
 **HVH VLASTNIç VIP DOMY

****************************************************/
//*************************************************//


#undef MAX_PLAYERS
#define MAX_PLAYERS 200

forward SaveData(playerid);
forward LoadData(playerid);


enum AdminInfo {
	AdminLvl,
	AdminIp,
	AdminPsw,
	AdminWarns,
	AdminSlaps,
	AdminShocks,
	Vip,
}

enum PlayerInfo{
	Money,
	Warns,
	Kicks,
	Slaps,
	Shocks,
	Events,
	Quest,
	AJail,
	Freeze,
	Eject,
	Banned,
	Exploded,
	Quit,
	Crashes,
	Kills,
	Deaths,
	Flip,
	Repair,
 	Quits,
 	FirstJoinned,
 	Joins
}

enum {
	DIALOG_REGISTER,
	DIALOG_LOGIN,
}
new AInfo[MAX_PLAYERS][AdminInfo];
new PInfo[MAX_PLAYERS][PlayerInfo];

stock SendAdminMessage(col, string[])
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(AInfo[i][AdminLvl] > 0)
			SendClientMessage(i, col, string);
	}

	return 1;
}

stock GivePlayerHealth(playerid,Float:Health)
{
	new Float:health; GetPlayerHealth(playerid,health);
	SetPlayerHealth(playerid,health+Health);
}
stock GivePlayerArmour(playerid,Float:Armour)
{
	new Float:armour; GetPlayerHealth(playerid,armour);
	SetPlayerArmour(playerid,armour+Armour);
}
stock GivePlayerScore(playerid,Score)
{
	SetPlayerScore(playerid,GetPlayerScore(playerid)+Score);
}
stock Message(playerid, Messages[],col[] = "r",Sub[] = "!"){
	if(strcmp(col, "g",false)) return SCMF(playerid, COLOR_ADMIN, "{FF0000}[ %s{FF0000} ]{FFFFFF} %s",Sub, Messages);
	if(strcmp(col, "r",false)) return SCMF(playerid, COLOR_ADMIN, "[ %s ]{FFFFFF} %s",Sub, Messages);
	return 1;
}

stock HaveAdmin(playerid, Adminlevel){
	if(AInfo[playerid][AdminLvl] >= Adminlevel){

	}else{
		Message(playerid, "Nem·ö dostatoËnÈ opravnenie.");
		return 0;
	 }
	return 1;
}

stock SpecCMD(playerid, cmd[], params[]){
	for(new SCMD = 0, CMDX = GetPlayerPoolSize(); SCMD <= CMDX; SCMD++)
	{
		if(IsPlayerConnected(playerid)) return 0;
		if(AInfo[playerid][AdminLvl] >= 1) return 0;
		SCMF(playerid, COLOR_SPEC, "[CMD](%s): %s", cmd, params);
 	}
	return 1;
}
stock UserPath(playerid){
    new cesta[50];
	format(cesta,sizeof(cesta),"Accounts/%s.sav",PlayerName(playerid));
	return cesta;
}
/*stock SaveData(playerid) {
		DOF2_SetInt(UserPath(playerid), "AdminLevel", AInfo[playerid][AdminLvl]);
}*/

public SaveData(playerid){
	new Float:pos[3];
	GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
    new INI:File = INI_Open(UserPath(playerid));
 	INI_WriteFloat(File, "PosX", pos[0]);
 	INI_WriteFloat(File, "PosY", pos[1]);
 	INI_WriteFloat(File, "PosZ", pos[2]);
 	INI_WriteInt(File, "Money", PInfo[playerid][Money]);
 	INI_WriteInt(File, "AdminLevel", AInfo[playerid][AdminLvl]);
	return 1;
}

public LoadData(playerid){
	return 1;
}



public OnPlayerConnect(playerid){
	AInfo[playerid][AdminLvl] = 0;
	AInfo[playerid][AdminIp] = 0;
	AInfo[playerid][AdminPsw] = 0;
	AInfo[playerid][AdminWarns] = 0;
	AInfo[playerid][AdminSlaps] = 0;
	AInfo[playerid][AdminShocks] = 0;

    SCMFTA(COLOR_ADMIN, "{FF0000}[ ! ]{FFFFFF} Hr·Ë %s sa pripojil do hry.", PlayerName(playerid));
    
   	if(fexist(UserPath(playerid)))
	{
		INI_ParseFile(UserPath(playerid), "LoadData", .bExtra = true, .extra = playerid);
  		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT,"Prihlasovanie","ProsÌm Zadaj svoje heslo:","Potvrdit","OdejÌt");
	}
	else
	{
  		ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT,"Registrovanie","ProsÌm zaregistruj sa, tvoje meno nebolo registrovanÈ.","Potvrdit","OdejÌt");
	}
    SpawnPlayer(playerid);
	return 1;
}
public OnPlayerDisconnect(playerid, reason){
	switch(reason)
	{
	    case 0: SCMFTA(COLOR_ADMIN, "{FF0000}[ ! ]{FFFFFF} Hr·Ë %s sa odpojil z hry. DÙvod: Timeout / Crash", PlayerName(playerid));
        case 1: SCMFTA(COLOR_ADMIN, "{FF0000}[ ! ]{FFFFFF} Hr·Ë %s sa odpojil z hry. DÙvod: Quit", PlayerName(playerid));
        case 2: SCMFTA(COLOR_ADMIN, "{FF0000}[ ! ]{FFFFFF} Hr·Ë %s sa odpojil z hry. DÙvod: Kick / Ban", PlayerName(playerid));
	}
	PInfo[playerid][Quits]++;
	SaveData(playerid);
	DOF2_Exit();
	return 1;
}
main () { return 1; }
public OnGameModeInit(){
	SetGameModeText("High Life");
	return 1;
}
public OnGameModeExit(){
    for(new i = 0; i < MAX_PLAYERS; i++) SaveData(i);
	return 1;
}
CMD:a(playerid, params[]){

	HaveAdmin(playerid, 1);
	SendAdminMessage(COLOR_ADMIN, params);
	return 1;
}
CMD:car(playerid, params[]){
	new Float:pos[3];
	GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	CreateVehicle(522, pos[0], pos[1], pos[2], 82.2873, -1, -1, 60);
	Message(playerid, "Auto vytvorenÈ...");
	return 1;
}
CMD:goto(playerid, params[]){
	new pid, Float:pos[3 + 1];
	HaveAdmin(playerid, 1);
	if(sscanf(params, "u", pid)) return Message(playerid, "/goto <ID>");
	if(pid == playerid || pid == INVALID_PLAYER_ID) return Message(playerid, "ERROR: ID je offline, alebo si to ty !");
	GetPlayerPos(pid, pos[0], pos[1], pos[2]);
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			new veh = GetPlayerVehicleID(playerid);
			SetVehiclePos(veh, pos[0], pos[1], pos[2]);
			SetVehicleVirtualWorld(veh, 0);
			LinkVehicleToInterior(veh, 0);
			SetPlayerInterior(playerid, 0);
			SetPlayerVirtualWorld(playerid, 0);
			PutPlayerInVehicle(playerid, veh, 0);
		}
		else
		{
			SetPlayerPos(playerid, pos[0], pos[1], pos[2]);
			SetPlayerInterior(playerid, 0);
			SetPlayerVirtualWorld(playerid, 0);
		}
	SetPlayerPos(playerid, pos[0],pos[1],pos[2]);
	SCMF(playerid,COLOR_ADMIN, "[ ! ] {FFFFFF}Administr·tor {FF0000}%s(%d){FFFFFF} sa portÛl na hr·Ëa %s(%d)", PlayerName(playerid),playerid, PlayerName(pid),pid);
	SpecCMD(playerid, "goto", params);
	return 1;
}
CMD:spec(playerid, params[]){
	new pid;
    HaveAdmin(playerid, 1);
    if(sscanf(params, "u", pid)) return Message(playerid, "/spec <ID>");
    if(pid == playerid || pid == INVALID_PLAYER_ID) return Message(playerid, "ERROR: ID je offline, alebo si to ty !");
    SCMF(playerid,COLOR_ADMIN, "[ ! ] {FFFFFF}Administr·tor %s(%d) zaËal pozorovaù hr·Ëa %s(%d)",PlayerName(playerid),playerid,PlayerName(pid),pid);
    SpecCMD(playerid, "spec", params);
    TogglePlayerSpectating(playerid, 1);
    PlayerSpectatePlayer(playerid, pid);
	return 1;
}
CMD:specoff(playerid, params[]){
	new pid;
    HaveAdmin(playerid, 1);
    if(pid == playerid || pid == INVALID_PLAYER_ID) return Message(playerid, "ERROR: ID je offline, alebo si to ty !");
    SpecCMD(playerid, "spec", params);
    TogglePlayerSpectating(playerid, 0);
    PlayerSpectatePlayer(playerid, pid);
	return 1;
}
CMD:ahelp(playerid, params[]){

	if(AInfo[playerid][AdminLvl] == 1) return Message(playerid,"Nem·ö dostatoËnÈ opravnenie !");
	if(AInfo[playerid][AdminLvl] >= 1) { SCMFTA(COLOR_ADMIN, "{FF0000}[ ! ] {FFFFFF}Tvoj aktu·lny Admin-Level je %d", AInfo[playerid][AdminLvl]); }
	if(AInfo[playerid][AdminLvl] >= 1) { Message(playerid,"/goto /spec /specoff /slay /esok /samotka /var /ahelp /say /cevent //ADMINCHAT @VIPCHAT /dotazy /dotazr", "g", "LVL: 1"); }
	if(AInfo[playerid][AdminLvl] >= 2) { Message(playerid,"/ajail /freeze /unfreeze /var /get /heal /healr /cc /eject /setdrunk /astats", "g", "LVL: 2"); }
	if(AInfo[playerid][AdminLvl] >= 3) { Message(playerid,"/kick /respawn /aflip /akill /carcolor /explode /setwtime /alock /aunlock", "g", "LVL: 3"); }
	if(AInfo[playerid][AdminLvl] >= 4) { Message(playerid,"/aban /ipban /ip /unban /car /setskin /crash /saveall /setvhealth /gwl /swl", "g", "LVL: 4"); }
	if(AInfo[playerid][AdminLvl] >= 5) { Message(playerid,"/pban /log /connections /avar /savar /setlvl /gcar /rcar /gmx /respawncar", "g", "LVL: 5"); }
	if(AInfo[playerid][AdminLvl] >= 6) { Message(playerid,"/xdebug /god /setinterior /setpos /loadpos /setvw /jetpack /hydra", "g", "LVL: 6"); }
	return 1;
}
CMD:setlvl(playerid, params[]){
	if(!IsPlayerAdmin(playerid)) return Message(playerid, "Niesi prihl·seny za RCON !");
	new pid, alvl;
	if(sscanf(params, "id", pid, alvl)) return Message(playerid, "ERROR: /setlvl <id> <lvl>");
	if(pid == INVALID_PLAYER_ID) return Message(playerid, "Nespr·vne ID !", "r");
	if(!IsPlayerConnected(pid)) return Message(playerid, "Hr·Ë neni online !", "r");
	if(alvl > 6 || alvl <= 0) return Message(playerid, "Rozmedzie Levelu je od 0 po 5");
	DOF2_SetInt(UserPath(playerid),"AdminLevel",alvl);
	DOF2_SaveFile();
	AInfo[playerid][AdminLvl] = alvl;
	SCMFTA(COLOR_ADMIN, "{FF0000}[ ! ] {FFFFFF}Administr·tor %s(%d) nastavil hr·Ëovy %s(%d) Admin-Level na %d",PlayerName(playerid), playerid, PlayerName(pid),pid, AInfo[playerid][AdminLvl]);
	return 1;
}

CMD:stat(playerid, params[]){
	new pid;
	HaveAdmin(playerid, 1);
	if(sscanf(params,"d", pid)) return Message(playerid, "/xstat <id>");
	if(!IsPlayerConnected(pid)) return Message(playerid, "Hr·Ë neni online !", "r");
	SCMF(playerid, COLOR_ADMIN, "Nick: %s | ID: %d | Admin Level: %d",PlayerName(pid), pid, AInfo[pid][AdminLvl]);
	SCMF(playerid, COLOR_ADMIN, "Doplnit...");
	return 1;
}
CMD:debug(playerid, params[]){
	SCMF(playerid, COLOR_ADMIN, "Nick: %s | ID: %d | Admin Level: %d",PlayerName(playerid), playerid, AInfo[playerid][AdminLvl]);
	return 1;
}
CMD:slay(playerid, params[]){
	HaveAdmin(playerid, 1);
	new pid,reason[256],Float:pos[3];
	if(sscanf(params, "is", pid, reason)) return Message(playerid, "ERROR: /slay <id> <reason>");
	if(pid == INVALID_PLAYER_ID) return Message(playerid, "Nespr·vne ID !", "r");
	if(!IsPlayerConnected(pid)) return Message(playerid, "Hr·Ë neni online !", "r");
	AInfo[playerid][AdminSlaps]++;
    PInfo[pid][Slaps]++;
	GivePlayerHealth(playerid, -10);
	GetPlayerPos(playerid, pos[0],pos[1],pos[2]);
	SetPlayerPos(playerid, pos[0],pos[1]+10,pos[2]);
	SCMFTA(COLOR_ADMIN, "{FF0000}[ ! ] {FFFFFF}Administr·tor %s(%d) dal facku hr·Ëovy %s(%d) za %s",PlayerName(playerid), playerid, PlayerName(pid),pid, reason);
	return 1;
}
CMD:esok(playerid, params[]){
	HaveAdmin(playerid, 1);
	new pid,reason[256];
	if(sscanf(params, "is", pid, reason)) return Message(playerid, "ERROR: /esok <id> <reason>");
	if(pid == INVALID_PLAYER_ID) return Message(playerid, "Nespr·vne ID !", "r");
	if(!IsPlayerConnected(pid)) return Message(playerid, "Hr·Ë neni online !", "r");
	AInfo[playerid][AdminShocks]++;
    PInfo[pid][Shocks]++;
	GivePlayerHealth(playerid, -10);
	ApplyAnimation(playerid,"CRACK","crckdeth2",4.1,1,1,1,7,1);
 	//TogglePlayerControllable(playerid, 0);
	SetTimerEx("UnFreeze", ELECTRIC_SHOCK * 1000, false, "i", playerid);
	SCMFTA(COLOR_ADMIN, "{FF0000}[ ! ] {FFFFFF}Administr·tor %s(%d) dal facku hr·Ëovy %s(%d) za %s",PlayerName(playerid), playerid, PlayerName(pid),pid, reason);
	return 1;
}
forward UnFreeze(playerid);
public UnFreeze(playerid){
	TogglePlayerControllable(playerid, 1);
	return 1;
}
//*************************************************//
/****************************************************
		PRÕKAZY PRE ADMIN SYSTEM by XpresS
 ALVL 0: /dotaz /report

 ALVL 1: /goto /spec /specoff /slay /esok /samotka /var /ahelp /say /cevent //ADMINCHAT @VIPCHAT /dotazy /dotazr
 ALVL 2: /ajail /freeze /unfreeze /var /get /heal /healr /cc /eject /setdrunk /astats
 ALVL 3: /kick /respawn /aflip /akill /carcolor /explode /setwtime /alock /aunlock
 ALVL 4: /aban /ipban /ip /unban /car /setskin /crash /saveall /setvhealth /gwl /swl
 ALVL 5: /pban /log /connections /avar /savar /setlvl /gcar /rcar /gmx /respawncar
 ALVL 6: /god /setinterior /setpos /loadpos /setvw /jetpack /hydra /xdebug

        PRÕKAZY PRI EVENTOCH
 ALVL 1: /ghost /ghostr /ghostoff /cevent <- RAZ ZA HODINU max.
                                    Pri zaloûen˝ eventu /ann /dann
 ALVL 2: /setport /setnkzona
 ALVL 3: /gpw /gpwr /disarm
 ALVL 4: /ebody

        PRÕKAZY PRE VIP
 VLVL BRONZ: BANKA;100K HVH @VIPCHAT /vflip /vrepair
 VLVL GOLD: BANKA;250K /vinviisible /vnitro,
 VLVL PLATINUM: BANKA;500K

 **BANKA;XXX == KAéDY DEN XXX $ do banky **
 **HVH VLASTNIç VIP DOMY

****************************************************/
//*************************************************//
stock sscanf(string[], format[], {Float,_}:...)
{
	#if defined isnull
		if (isnull(string))
	#else
		if (string[0] == 0 || (string[0] == 1 && string[1] == 0))
	#endif
		{
			return format[0];
		}
	#pragma tabsize 4
	new
		formatPos = 0,
		stringPos = 0,
		paramPos = 2,
		paramCount = numargs(),
		delim = ' ';
	while (string[stringPos] && string[stringPos] <= ' ')
	{
		stringPos++;
	}
	while (paramPos < paramCount && string[stringPos])
	{
		switch (format[formatPos++])
		{
			case '\0':
			{
				return 0;
			}
			case 'i', 'd':
			{
				new
					neg = 1,
					num = 0,
					ch = string[stringPos];
				if (ch == '-')
				{
					neg = -1;
					ch = string[++stringPos];
				}
				do
				{
					stringPos++;
					if ('0' <= ch <= '9')
					{
						num = (num * 10) + (ch - '0');
					}
					else
					{
						return -1;
					}
				}
				while ((ch = string[stringPos]) > ' ' && ch != delim);
				setarg(paramPos, 0, num * neg);
			}
			case 'h', 'x':
			{
				new
					num = 0,
					ch = string[stringPos];
				do
				{
					stringPos++;
					switch (ch)
					{
						case 'x', 'X':
						{
							num = 0;
							continue;
						}
						case '0' .. '9':
						{
							num = (num << 4) | (ch - '0');
						}
						case 'a' .. 'f':
						{
							num = (num << 4) | (ch - ('a' - 10));
						}
						case 'A' .. 'F':
						{
							num = (num << 4) | (ch - ('A' - 10));
						}
						default:
						{
							return -1;
						}
					}
				}
				while ((ch = string[stringPos]) > ' ' && ch != delim);
				setarg(paramPos, 0, num);
			}
			case 'c':
			{
				setarg(paramPos, 0, string[stringPos++]);
			}
			case 'f':
			{

				new changestr[16], changepos = 0, strpos = stringPos;
				while(changepos < 16 && string[strpos] && string[strpos] != delim)
				{
					changestr[changepos++] = string[strpos++];
    				}
				changestr[changepos] = '\0';
				setarg(paramPos,0,_:floatstr(changestr));
			}
			case 'p':
			{
				delim = format[formatPos++];
				continue;
			}
			case '\'':
			{
				new
					end = formatPos - 1,
					ch;
				while ((ch = format[++end]) && ch != '\'') {}
				if (!ch)
				{
					return -1;
				}
				format[end] = '\0';
				if ((ch = strfind(string, format[formatPos], false, stringPos)) == -1)
				{
					if (format[end + 1])
					{
						return -1;
					}
					return 0;
				}
				format[end] = '\'';
				stringPos = ch + (end - formatPos);
				formatPos = end + 1;
			}
			case 'u':
			{
				new
					end = stringPos - 1,
					id = 0,
					bool:num = true,
					ch;
				while ((ch = string[++end]) && ch != delim)
				{
					if (num)
					{
						if ('0' <= ch <= '9')
						{
							id = (id * 10) + (ch - '0');
						}
						else
						{
							num = false;
						}
					}
				}
				if (num && IsPlayerConnected(id))
				{
					setarg(paramPos, 0, id);
				}
				else
				{
					#if !defined foreach
						#define foreach(%1,%2) for (new %2 = 0; %2 < MAX_PLAYERS; %2++) if (IsPlayerConnected(%2))
						#define __SSCANF_FOREACH__
					#endif
					string[end] = '\0';
					num = false;
					new
						name[MAX_PLAYER_NAME];
					id = end - stringPos;
					foreach (Player, playerid)
					{
						GetPlayerName(playerid, name, sizeof (name));
						if (!strcmp(name, string[stringPos], true, id))
						{
							setarg(paramPos, 0, playerid);
							num = true;
							break;
						}
					}
					if (!num)
					{
						setarg(paramPos, 0, INVALID_PLAYER_ID);
					}
					string[end] = ch;
					#if defined __SSCANF_FOREACH__
						#undef foreach
						#undef __SSCANF_FOREACH__
					#endif
				}
				stringPos = end;
			}
			case 's', 'z':
			{
				new
					i = 0,
					ch;
				if (format[formatPos])
				{
					while ((ch = string[stringPos++]) && ch != delim)
					{
						setarg(paramPos, i++, ch);
					}
					if (!i)
					{
						return -1;
					}
				}
				else
				{
					while ((ch = string[stringPos++]))
					{
						setarg(paramPos, i++, ch);
					}
				}
				stringPos--;
				setarg(paramPos, i, '\0');
			}
			default:
			{
				continue;
			}
		}
		while (string[stringPos] && string[stringPos] != delim && string[stringPos] > ' ')
		{
			stringPos++;
		}
		while (string[stringPos] && (string[stringPos] == delim || string[stringPos] <= ' '))
		{
			stringPos++;
		}
		paramPos++;
	}
	do
	{
		if ((delim = format[formatPos++]) > ' ')
		{
			if (delim == '\'')
			{
				while ((delim = format[formatPos++]) && delim != '\'') {}
			}
			else if (delim != 'z')
			{
				return delim;
			}
		}
	}
	while (delim > ' ');
	return 0;
}
