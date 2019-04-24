#include <a_samp>
#include <i-zcmd>
#include <DOF2>
#include <sscanf>
#include <streamer>

#define SHOP_PATH "/Shops/Shop%d.ini"

#define SCM(%0, %1) SendClientMessage(%0, -1, %1)
#define SCMTA(%0) SendClientMessageToAll(-1, %0)
#define Message(%0,%1) SendClientMessage(%0, -1, %1)
#define MessageTA(%0) SendClientMessageToAll(-1, %0)

#define MAX_SHOP_NAME 25+1

#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

#define MAX_SHOPS 20
#define MAX_SHOP_TYPE 8

new ShopCount;
new ShopEntered[MAX_PLAYERS];

new static ShopTypes[MAX_SHOP_TYPE][] =
{
	{10,	float:6.091179,   float:-29.271898,  float:1003.549438},
	{18, 	float:161.391006, float:-93.159156,  float:1001.804687},
	{5,		float:226.293991, float:-7.431529,   float:1002.210937},
	{1,		float:203.777999, float:-48.492397,  float:1001.804687},
	{3,		float:207.054992, float:-138.804992, float:1003.507812},
	{14,	float:204.332992, float:-166.694992, float:1000.523437},
	{15,	float:207.737991, float:-109.019996, float:1005.132812},
 	{1,		float:1.808619,	  float:32.384357,	 float:1199.593750}
};

new static ShopNames[] =
{
	"24/7",
	"Zip",
	"Suburban",
	"Prolaps",
	"Dieder Sachs",
	"Binco"
};

enum iShop
{
	Float:sX,
	Float:sY,
	Float:sZ,
	sType,
	sPickUp,
	Text3D:sText
};

new Shops[MAX_SHOPS][iShop];

stock RandomMin(min, max) return random(max-min)+min;
new shopLabel[150];

CMD:testfloat(playerid, params[])
{
	new id;
	if(sscanf(params, "i", id)) return Message(playerid, "CMD ERROR: /testfloat <ID>");
	
	new string[150];
	format(string, sizeof(string), "INT: %d, NAZOV: %s, X:%f, Y:%f, Z:%f", ShopTypes[id][1],ShopNames[id],ShopTypes[id][2], ShopTypes[id][3], ShopTypes[id][4]);
	SCMTA(string);
	return 1;
}
stock LoadShop(shopID)
{
	if(DOF2_FileExists(ShopPath(shopID)))
 	{
 	    Shops[shopID][sX] = DOF2_GetFloat(ShopPath(shopID), "X");
 	    Shops[shopID][sY] = DOF2_GetFloat(ShopPath(shopID), "Y");
 	    Shops[shopID][sZ] = DOF2_GetFloat(ShopPath(shopID), "Z");
 	    Shops[shopID][sType] = DOF2_GetInt(ShopPath(shopID), "Type");
 	    
		if(Shops[shopID][sType] >= MAX_SHOP_TYPE) return printf("Súbor %s má zlý typ !", ShopPath(shopID));


		format(shopLabel, sizeof(shopLabel), "{00CCFF}[ Obchod ]\n{FFFFFF}%s\nPre vstup stlaè ENTER", ShopTypes[Shops[shopID][sType]][1]);
  		Shops[shopID][sText] = CreateDynamic3DTextLabel(shopLabel, 0xFF0000FF, Shops[shopID][sX], Shops[shopID][sY], Shops[shopID][sZ]+0.7, 50.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
		Shops[shopID][sPickUp] = CreateDynamicPickup(19134, 1, Shops[shopID][sX], Shops[shopID][sY], Shops[shopID][sZ]);
 	}

	return 1;
}

public OnPlayerPickUpDynamicPickup(playerid, pickupid)
{
	for(new i=0; i<MAX_SHOPS; i++)
	{
    	if(IsPlayerInSphere(playerid,Shops[i][sX],Shops[i][sY],Shops[i][sZ],2))
    	{
			Message(playerid, "Pre vstup stlaè Y !");
			ShopEntered[playerid]=i;
   			break;
		}
	}
    return 1;
}

CMD:debugpos(playerid)
{
    Message(playerid, "{00CCFF}=== DEBUG POSITION ===");
	SetPlayerPos(playerid, 0.0,0.0,0.0);
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
	return 1;
}

CMD:debugshop(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return Message(playerid, "Nemáš admin práva !");
	{
	    new id;
		if(sscanf(params, "i", id)) return Message(playerid, "ERROR: /debugshop <ID>");
		new string[300];
		MessageTA("");
  		MessageTA("{00CCFF}=== DEBUG SHOP ===");
		format(string, sizeof(string), "X: %f, Y: %f, Z: %f", Shops[id][sX], Shops[id][sY], Shops[id][sZ]);
		printf("X: %f, Y: %f, Z: %f", Shops[id][sX], Shops[id][sY], Shops[id][sZ]);
		MessageTA(string);
		format(string, sizeof(string), "NAZOV: %s, ID: %d, INT: %d", ShopNames[Shops[id][sType]][], id, ShopTypes[Shops[id][sType]][0]);
		printf("NAZOV: %s, ID: %d, INT: %d", ShopTypes[Shops[id][sType]][1], id, ShopTypes[Shops[id][sType]][1]);
		MessageTA(string);
		format(string, sizeof(string), "IX: %f, IY: %f, IZ: %f", ShopTypes[Shops[id][sType]][2], ShopTypes[Shops[id][sType]][3], ShopTypes[Shops[id][sType]][4]);
		printf("IX: %f, IY: %f, IZ: %f", ShopTypes[Shops[id][sType]][2], ShopTypes[Shops[id][sType]][3], ShopTypes[Shops[id][sType]][4]);
		MessageTA(string);
	}
	return 1;
}

public OnRconCommand(cmd[])
{
    if(!strcmp(cmd, "xpress", true))
    {
		for(new id=0; id<MAX_SHOPS; id++)
		{
		    print("============================================================================");
            printf("X: %f, Y: %f, Z: %f", Shops[id][sX], Shops[id][sY], Shops[id][sZ]);
            printf("NAZOV: %s, ID: %d, INT: %d", ShopTypes[Shops[id][sType]][1], id, ShopTypes[Shops[id][sType]][0]);
            printf("IX: %f, IY: %f, IZ: %f", ShopTypes[Shops[id][sType]][2], ShopTypes[Shops[id][sType]][3], ShopTypes[Shops[id][sType]][4]);
		}
        print("================= TEST ============");

        printf("NAZOV: %s, ID: %d, INT: %d", ShopTypes[2][1], ShopTypes[2][0]);
        return 1;
    }

    if(!strcmp(cmd, "xpress2", true))
    {
        print("================= TEST ============");

		new id = 5;
		for(id=0;id<MAX_SHOPS; id++) printf("ID: %d, NAZOV: %s, INT: %d",id,  ShopTypes[Shops[id][sType]][1], ShopTypes[id][0]);
        return 1;
    }
    return 0;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	for(new i=0; i<MAX_SHOPS; i++)
	{
    	if(IsPlayerInSphere(playerid,Shops[i][sX],Shops[i][sY],Shops[i][sZ],2))
    	{
			SCMTA(ShopTypes[Shops[i][sType]][2]);
			SCMTA(ShopTypes[Shops[i][sType]][3]);
			SCMTA(ShopTypes[Shops[i][sType]][4]);
    	    if(PRESSED(KEY_YES))
    	    {
    	        SetPlayerInterior(playerid, ShopTypes[Shops[i][sType]][0]);

				SetPlayerPos(playerid, 	ShopTypes[Shops[i][sType]][2], ShopTypes[Shops[i][sType]][3], ShopTypes[Shops[i][sType]][4]);
			}
   			break;
		}
	}
	return 1;
}

stock CreateShop(shopID, Float:x, Float:y, Float:z, type)
{
	if(!DOF2_FileExists(ShopPath(shopID)))
	{
 		DOF2_CreateFile(ShopPath(shopID));
		DOF2_SetFloat(ShopPath(shopID), "X", x);
		DOF2_SetFloat(ShopPath(shopID), "Y", y);
		DOF2_SetFloat(ShopPath(shopID), "Z", z);
		DOF2_SetInt(ShopPath(shopID), "Type", type);
		DOF2_SaveFile();

	    Shops[shopID][sX] = x;
	    Shops[shopID][sY] = y;
	    Shops[shopID][sZ] = z;
	    Shops[shopID][sType] = type;

		format(shopLabel, sizeof(shopLabel), "{00CCFF}[ Obchod ]\n{FFFFFF}%s", ShopTypes[type][1]);
        Shops[shopID][sText] = CreateDynamic3DTextLabel(shopLabel, 0xFF0000FF, x, y, z+0.7, 50.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
		Shops[shopID][sPickUp] = CreateDynamicPickup(19134, 1, x, y, z);
	}
	return 1;
}

CMD:createshop(playerid,params[])
{
	if(!IsPlayerAdmin(playerid)) return Message(playerid, "Nemáš admin práva !");
 	{
	  	new type;
 	    if(sscanf(params, "i", type)) return Message(playerid, "SYNTAX ERROR: /createshop <TYPE>");
 	    new Float:pos[3];
 	    GetPlayerPos(playerid, pos[0],pos[1],pos[2]);
 	    CreateShop(LastShopCreate(), pos[0],pos[1],pos[2], type);
 	}
	return 1;
}

public OnFilterScriptInit()
{

	for(new i=0; i<MAX_SHOPS; i++) LoadShop(i);

	return 1;
}
forward Load();

public OnFilterScriptExit()
{
	DOF2_Exit();
	return 1;
}

stock ShopPath(shopID)
{
	new string[50];
	format(string, sizeof(string), SHOP_PATH, shopID);
	return string;
}
stock LastShopCreate()
{
	for(ShopCount=0; ShopCount<MAX_SHOPS; ShopCount++)
	{
		if(!DOF2_FileExists(ShopPath(ShopCount)))
		{
			break;
		}
	}
	return ShopCount;
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
