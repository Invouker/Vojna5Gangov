#include <a_samp>
#include <i-zcmd>
#include <sscanf2>
#include <DOF2>

native IsValidVehicle(vehicleid);

#define Message(%0, %1) SendClientMessage(%0, -1, %2);
#define CAR_PATH "/Cars/%d.ini"

#undef MAX_VEHICLES
#define MAX_VEHICLES 500

new VehCount;
new Vehicle[MAX_VEHICLES];

enum {
	DIALOG_VEH_INFO = 300
};


public OnFilterScriptInit()
{
	for(new id=0; id < MAX_VEHICLES; id++) LoadVeh(id);
	return 1;
}

public OnFilterScriptExit()
{
	DellAllVeh();
	DOF2_Exit();
	return 1;
}
stock DellAllVeh()
{
	for(new i=0; i<MAX_VEHICLES; i++)
	{
		DestroyVehicle(Vehicle[i]);
	}
	return 1;
}
CMD:dveh(playerid, params[])
{
	new id;
	if(sscanf(params, "i", id)) return SendClientMessage(playerid, -1, "SYNTAX: /dveh <ID>");
	if(DOF2_FileExists(CarPath(id)))
	{
		DestroyVehicle(Vehicle[id]);
		DOF2_RemoveFile(CarPath(id));
		SendClientMessage(playerid, -1, "Vozidlo bolo vymazanÈ !");
	}else{
        SendClientMessage(playerid, -1, "Vozidlo s ID neexistuje !");
	}
	return 1;
}
CMD:eveh(playerid)
{
	new string[150];
	for(new i=0; i<MAX_VEHICLES; i++)
	{
		if(DOF2_FileExists(CarPath(i)))
		{
		    format(string, sizeof(string), "Existuj˙ce ID  vozidiel: %d", i);
			SendClientMessage(playerid, -1, string);
		}else{
			break;
		}
	}
	return 1;
}
CMD:cveh(playerid)
{
	if(IsPlayerInAnyVehicle(playerid))
	{
		new Float:pos[4];
		new vehmdl = GetVehicleModel( GetPlayerVehicleID(playerid) );
		new vehid = GetPlayerVehicleID(playerid);
		
		GetVehiclePos(vehid, pos[0], pos[1], pos[2]);
		GetVehicleZAngle(vehid, pos[3]);
		CreateVeh(vehmdl, pos[0], pos[1], pos[2], pos[3]);
		new string[256];
  		format(string, sizeof(string), "X:%f, Y:%f, Z:%f, rZ:%f, mID:%d", pos[0], pos[1], pos[2], pos[3], vehmdl);
  		SendClientMessage(playerid, -1, "");
  		SendClientMessage(playerid, 0x00CCFF00, "===VOZIDLO BOLO VYTVORENE S PARAMETRAMI===");
  		SendClientMessage(playerid, -1, string);
	}else{
		SendClientMessage(playerid, -1, "MusÌö byù v nejakom vozidle !");
	}
	return 1;
}

CMD:auto(playerid, params[])
{
	new id;
	if(sscanf(params, "i", id)) return SendClientMessage(playerid, -1, "/auto ID");
	new Float:pos[3];
	GetPlayerPos(playerid, pos[0],pos[1], pos[2]);
	CreateVehicle(id, pos[0],pos[1], pos[2]+2, 0,random(250), random(250), -1, 0);
	SendClientMessage(playerid, -1, "Auto bolo vytvorenÈ !");
	return 1;
}

stock LoadVeh(id)
{
	new modelid, Float:pos[4], color[2];
	if(DOF2_FileExists(CarPath(id)))
	{
	    modelid = DOF2_GetInt(CarPath(id), "modelID");
	    pos[0] = DOF2_GetFloat(CarPath(id), "posX");
	    pos[1] = DOF2_GetFloat(CarPath(id), "posY");
	    pos[2] = DOF2_GetFloat(CarPath(id), "posZ");
	    pos[3] = DOF2_GetFloat(CarPath(id), "rotZ");
		color[0] = DOF2_GetInt(CarPath(id), "color1");
		color[1] = DOF2_GetInt(CarPath(id), "color2");
            
		Vehicle[id] = CreateVehicle(modelid ,pos[0], pos[1], pos[2], pos[3], color[0], color[1], -1, 0);
		printf("MDL: %d, X:%f, Y:%f, Z:%f, rZ:%f, c1:%d, c2:%f", modelid ,pos[0], pos[1], pos[2], pos[3], color[0], color[1]);
		SendClientMessageToAll(-1, "VOZIDLO BOLO VYTVORENE ");
			
		if(!IsValidVehicle(Vehicle[id]))
		{
		    printf("Vozidlo %d sa nepodarilo naËÌtaù, vozidlo neexistuje", id);
		}
			//CreateVehicle(522,  pos[0], pos[1], pos[2], pos[3], 150, 150, -1, 0);
	}
	return 1;
}
CMD:vehinfo(playerid, params[])
{
	new id, string1[120], string2[256];
	if(sscanf(params, "i", id)) return SendClientMessage(playerid,-1, "SYNTAX ERROR: /vehinfo <ID>");

	new Float:vehx, Float:vehy, Float:vehz;
    GetVehiclePos(id, vehx, vehy, vehz);
            
	format(string1, sizeof(string1), "Vehicle info ID: %d", id);
	
	format(string2, sizeof(string2), "	{00FF00}PozÌcia vozidla:\n\
  									  		{00CCBB}X: {FFFFFF}%f\n\
 									  		{00CCBB}Y: {FFFFFF}%f\n\
 									  		{00CCBB}Z: {FFFFFF}%f\n\
										{00FF00}Vzdialenosù od vozidla:\n\
											{00CCBB}Metrov: {FFFFFF}%f"
											,vehx, vehy, vehz, GetPlayerDistanceFromPoint(playerid, vehx, vehy, vehz) );
	SetPVarInt(playerid, "VEH_ID", id);
 									  
    ShowPlayerDialog(playerid, DIALOG_VEH_INFO, DIALOG_STYLE_MSGBOX, string1, string2, "Opravit", "Cancel");
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == DIALOG_VEH_INFO)
 	{
        if(response) return RepairVehicle(GetPVarInt(playerid, "VEH_ID"));
        return 1; 
    }

    return 0; 
}

CMD:nearveh(playerid)
{
	new string[50];
	format(string, sizeof(string), "Near Veahicle is ID:%d, ", IsPlayerNearVehicle(playerid, 3));
	SendClientMessage(playerid, -1, string );
	return 1;
}
CMD:pos(playerid, params[])
{
	new Float:pos[3];
	if(sscanf(params, "fff",pos[0], pos[1], pos[2])) return SendClientMessage(playerid, -1, "CMD ERRO: /pos <X> <Y> <Z>");
	SetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	SendClientMessage(playerid, -1, "{FF0000}[ ! ]{00CCBB}Portnut˝ !!!");
	return 1;
}

 
stock CreateVeh(model, Float:X, Float:Y, Float:Z, Float:rot)
{
	new Last = LastVehCreate();
	if(!DOF2_FileExists(CarPath(LastVehCreate())))
	{
	    if(!(Last > MAX_VEHICLES))
	    {
		    DOF2_CreateFile(CarPath(Last));
		   	DOF2_SetInt(CarPath(Last),"modelID", model);
			DOF2_SetFloat(CarPath(Last),"posX", X);
			DOF2_SetFloat(CarPath(Last),"posY", Y);
			DOF2_SetFloat(CarPath(Last),"posZ", Z);
			DOF2_SetFloat(CarPath(Last), "rotZ", rot);
			DOF2_SetInt(CarPath(Last),"color1", minrandom(128, 255));
	   		DOF2_SetInt(CarPath(Last),"color2", minrandom(128, 255));
			SendClientMessageToAll(-1, "Do 5 sekund bude vozidlo spawnutÈ !");
			SetTimerEx("LVeh", 1000 * 5, false, "i", Last);
		}else{
			printf("PrekroËen˝ limit vozidiel na servery ! [%d/%d]", Last, MAX_VEHICLES);
			return 0;
		}
	}
	return 1;
}

CMD:testvote(playerid)
{
    new m = cellmin, array[] = {100,2220,30,4,80,90};
	for (new i = 0; i != sizeof (array); ++i)
	{
	    m = max(m, array[i]);
	}
	
	printf("%d", m);
	return 0;
}


forward LVeh(id);
public LVeh(id)
{
	LoadVeh(id);
	return 1;
}


stock IsPlayerNearVehicle(playerid, Float: RANGE = 10.0)
{
	static Float: fX, Float: fY, Float: fZ;

	for(new i = 0 ; i < MAX_VEHICLES; i++)
	{
		if(IsValidVehicle(i))
		{
			GetVehiclePos(i, fX, fY, fZ);
			if(IsPlayerInRangeOfPoint(playerid, RANGE, fX, fY, fZ) || IsPlayerInVehicle(playerid, i))
				return i;
			else continue;
		}
	}

	return INVALID_VEHICLE_ID;
}

stock LastVehCreate()
{
	for(VehCount = 1; VehCount < MAX_VEHICLES; VehCount++)
	{
	    if(!DOF2_FileExists(CarPath(VehCount)))
	    {
			break;
		}
	}
	return VehCount;
}
stock CarPath(carid)
{
	new string[150];
	format(string, sizeof(string), CAR_PATH, carid);
	return string;
}
stock minrandom(min, max) return random(max - min) + min;

