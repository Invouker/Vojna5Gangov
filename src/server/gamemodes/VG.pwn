#include <a_samp>
#include <vg5>
#include <vg5callbacks>
#include <vg5languages>
#include <a_mysql>
#include <sscanf2>
#include <foreach>
#include <izcmd>
#include <easyDialog>
#include <dutils>

new MySQL: Database, Corrupt_Check[MAX_PLAYERS];

main()
{
	print("Hello World!");
	return 1;
}


public OnGameModeInit()
{
	new MySQLOpt: option_id = mysql_init_options();
	mysql_set_option(option_id, AUTO_RECONNECT, true);
	Database = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASS, MYSQL_DATABASE, option_id);
	if(Database == MYSQL_INVALID_HANDLE || mysql_errno(Database) != 0)
	{
		print("[Server] Nelze pripojit k DB!");

		SendRconCommand("exit");
		return 1;
	}
	print("[Server] Uspesne pripojeno k DB!");
	mysql_tquery(Database, "CREATE TABLE IF NOT EXISTS `PLAYERS` (`ID` int(11) NOT NULL AUTO_INCREMENT,`USERNAME` varchar(24) NOT NULL,`PASSWORD` char(65) NOT NULL,`SALT` char(11) NOT NULL,`SCORE` mediumint(7), `KILLS` mediumint(7), `CASH` mediumint(7) NOT NULL DEFAULT '0',`DEATHS` mediumint(7) NOT NULL DEFAULT '0', PRIMARY KEY (`ID`), UNIQUE KEY `USERNAME` (`USERNAME`))");
	return 1;
}

public OnGameModeExit()
{
	foreach(new i: Player)
    {
		if(IsPlayerConnected(i))
		{
			OnPlayerDisconnect(i, 1);
		}
	}
	mysql_close(Database);
	return 1;
}
public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
	return 1;
}

public OnPlayerConnect(playerid)
{
	new DB_Query[115];
	PlayerInfo[playerid][PasswordFails] = 0;
	GetPlayerName(playerid, PlayerInfo[playerid][PName], MAX_PLAYER_NAME);
	Corrupt_Check[playerid]++;
	mysql_format(Database, DB_Query, sizeof(DB_Query), "SELECT * FROM `PLAYERS` WHERE `USERNAME` = '%e' LIMIT 1", PlayerInfo[playerid][PName]);
	mysql_tquery(Database, DB_Query, "OnPlayerDataCheck", "ii", playerid, Corrupt_Check[playerid]);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	Corrupt_Check[playerid]++;
	new DB_Query[256];
	mysql_format(Database, DB_Query, sizeof(DB_Query), "UPDATE `PLAYERS` SET `SCORE` = %d, `CASH` = %d, `KILLS` = %d, `DEATHS` = %d WHERE `ID` = %d LIMIT 1",
	PlayerInfo[playerid][Score], PlayerInfo[playerid][Cash], PlayerInfo[playerid][Kills], PlayerInfo[playerid][Deaths], PlayerInfo[playerid][ID]);
	mysql_tquery(Database, DB_Query);
	if(cache_is_valid(PlayerInfo[playerid][Player_Cache]))
	{
		cache_delete(PlayerInfo[playerid][Player_Cache]);
		PlayerInfo[playerid][Player_Cache] = MYSQL_INVALID_CACHE;
	}
	PlayerInfo[playerid][LoggedIn] = false;
	return 1;
}

public OnPlayerSpawn(playerid)
{
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	if(killerid != INVALID_PLAYER_ID)
	{
	    PlayerInfo[killerid][Kills]++;
	    PlayerInfo[playerid][Deaths]++;
	}
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
	if(PlayerInfo[playerid][LoggedIn] == false) return 0;
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

forward public OnPlayerDataCheck(playerid, corrupt_check);
public OnPlayerDataCheck(playerid, corrupt_check)
{
	if (corrupt_check != Corrupt_Check[playerid]) return Kick(playerid);
	new String[150];

	if(cache_num_rows() > 0)
	{
		cache_get_value(0, "PASSWORD", PlayerInfo[playerid][Password], 129);

		PlayerInfo[playerid][Player_Cache] = cache_save();

		format(String, sizeof(String), "{FFFFFF}Welcome back, %s.\n\n{0099FF}This account is already registered.\n\
		{0099FF}Please, input your password below to proceed to the game.\n\n", PlayerInfo[playerid][PName]);
		Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login System", String, "Login", "Leave");
	}
	else
	{
		format(String, sizeof(String), "{FFFFFF}Welcome %s.\n\n{0099FF}This account is not registered.\n\
		{0099FF}Please, input your password below to proceed to the game.\n\n", PlayerInfo[playerid][PName]);
		Dialog_Show(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Registration System", String, "Register", "Leave");
	}
	return 1;
}

Dialog:DIALOG_LOGIN(playerid, response, listitem, inputtext[])
{
	if(!response) return Kick(playerid);
	new Salted_Key[65];
	SHA256_PassHash(inputtext, PlayerInfo[playerid][Salt], Salted_Key, 65);
	if(strcmp(Salted_Key, PlayerInfo[playerid][Password]) == 0)
	{
		cache_set_active(PlayerInfo[playerid][Player_Cache]);
		cache_get_value_int(0, "ID", PlayerInfo[playerid][ID]);

		cache_get_value_int(0, "KILLS", PlayerInfo[playerid][Kills]);
		cache_get_value_int(0, "DEATHS", PlayerInfo[playerid][Deaths]);

		SetPlayerScore(playerid, PlayerInfo[playerid][Score]);

		ResetPlayerMoney(playerid);
		GivePlayerMoney(playerid, PlayerInfo[playerid][Cash]);

		cache_delete(PlayerInfo[playerid][Player_Cache]);
		PlayerInfo[playerid][Player_Cache] = MYSQL_INVALID_CACHE;
		PlayerInfo[playerid][LoggedIn] = true;
		SCM(playerid, 0x00FF00FF, "Prihlasen!");
	}else{
		new String[150];
		PlayerInfo[playerid][PasswordFails] += 1;
		printf("%s has been failed to login. (%d)", PlayerInfo[playerid][PName], PlayerInfo[playerid][PasswordFails]);
		if (PlayerInfo[playerid][PasswordFails] >= 3)
		{
			format(String, sizeof(String), "%s has been kicked Reason: {FF0000}(%d/3) Login fails.", PlayerInfo[playerid][PName], PlayerInfo[playerid][PasswordFails]);
			SCMTA(0x969696FF, String);
			Kick(playerid);
		}else{
			format(String, sizeof(String), "Wrong password, you have %d out of 3 tries.", PlayerInfo[playerid][PasswordFails]);
			SCM(playerid, 0xFF0000FF, String);
			format(String, sizeof(String), "{FFFFFF}Welcome back, %s.\n\n{0099FF}This account is already registered.\n\
			{0099FF}Please, input your password below to proceed to the game.\n\n", PlayerInfo[playerid][PName]);
			Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login System", String, "Login", "Leave");
		}
	}
	return 1;
}

Dialog:DIALOG_REGISTER(playerid, response, listitem, inputtext[])
{
	if(!response) return Kick(playerid);
	if(strlen(inputtext) <= 5 || strlen(inputtext) > 60)
	{
		SCM(playerid, 0x969696FF, "Invalid password length, should be 5 - 60.");
		new String[150];
    	format(String, sizeof(String), "{FFFFFF}Welcome %s.\n\n{0099FF}This account is not registered.\n\
     	{0099FF}Please, input your password below to proceed.\n\n", PlayerInfo[playerid][PName]);
       	Dialog_Show(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Registration System", String, "Register", "Leave");
	}else{
	    for (new i = 0; i < 10; i++)
     	{
        	PlayerInfo[playerid][Salt][i] = random(79) + 47;
   		}
   		PlayerInfo[playerid][Salt][10] = 0;
    	SHA256_PassHash(inputtext, PlayerInfo[playerid][Salt], PlayerInfo[playerid][Password], 65);
    	new DB_Query[225];
    	mysql_format(Database, DB_Query, sizeof(DB_Query), "INSERT INTO `PLAYERS` (`USERNAME`, `PASSWORD`, `SALT`, `SCORE`, `KILLS`, `CASH`, `DEATHS`)\
    	VALUES ('%e', '%s', '%e', '20', '0', '0', '0')", PlayerInfo[playerid][PName], PlayerInfo[playerid][Password], PlayerInfo[playerid][Salt]);
     	mysql_tquery(Database, DB_Query, "OnPlayerRegister", "d", playerid);
	}
	return 1;
}

forward public OnPlayerRegister(playerid);
public OnPlayerRegister(playerid)
{
	SCM(playerid, 0x00FF00FF, "You are now registered and has been logged in.");
    PlayerInfo[playerid][LoggedIn] = true;
    return 1;
}
