/**************************************************
PRÍKAZY PRI EVENTOCH
 ALVL 1: /ghost /ghostr /ghostoff /cevent <- RAZ ZA HODINU max.
                                    Pri založený eventu /ann /dann
 ALVL 2: /setport /setnkzona
 ALVL 3: /gpw /gpwr /disarm
 ALVL 4: /ebody

        PRÍKAZY PRE VIP
 VLVL BRONZ: BANKA;100K HVH @VIPCHAT /vflip /vrepair
 VLVL GOLD: BANKA;250K /vinviisible /vnitro,
 VLVL PLATINUM: BANKA;500K

 *BANKA;XXX == KAŽDY DEN XXX $ do banky *
 **HVH VLASTNI? VIP DOMY
slay, samotka, var, event, dotazy, ajail, freeze, respawn, akill, explode, ban,
====================[BUG & TO-DO LIST]=======================
- Jednoduché nastavení NEDOKONEENO
- Help co je vše na serveru NEDOKONEENO
- Spravi? dynamický systém jobov otvaranie dialogov a pod.
- Spravi? Inventory,  zobrazovanie itemov v dialogu - NEDOKONEENÉ
- Vymyslie? príbeh/úlohy - NEDOKONEENÉ
- Ukladanie Farby hráea do složky - NEDOKONEENÉ
- Opravit autoškolu
- House System
{
	|_ Vstup za pomocí klávesy Y (nebo F) - OPRAVIT PORT Z DOMU!!!
	|_ Upravi? ukladanie pod3a ID, a dorobi? ukladanie ! - NEDOKONEENÉ
	|_ Prerobi? kompletne House Systém
}
===================== ADMIN PRIKAZY =======================
Offline SetLevel
Offline && Online SetPassword
SetInterior & SetVirtualWorld & SetPos
SetName
Fake ID TEXT
Admin PM for Player
============================================================
Jednotlivé kolonky nemazat, ale poesunout DOKONEENÉ úplni dolu!
*************************************************/

#include <a_samp>
//#include <YSI\y_ini>
#include <i-zcmd>
#include <sscanf2>
#include "gl_common"
#include "streamer"
#include <foreach>
#include <playerzone>
#include <dof2>

//=======[NATIVE]============

native WP_Hash(buffer[], len, const str[]);

//=====[DEFINE DIALOGS]=======
enum
{
	DIALOG_LOGIN,
	DIALOG_REGISTER,
	DIALOG_BANK,
	DIALOG_VYBRAT,
	DIALOG_VLOZIT,
	DIALOG_STAV,
	DIALOG_RADIO,
	DIALOG_OWNRADIO,
	DIALOG_STATS,
	DIALOG_OPTIONS,
	DIALOG_HELP,
	DIALOG_SERVERINFO,
	DIALOG_ONLINE_ADMINS,
	DIALOG_CARSCHOOL,
	DIALOG_ROZPOCET_STAV,
	DIALOG_ROZPOCET_VLOZIT,
	DIALOG_EVERYTHING
}
//============================
//=====[ANTI DeAmx]==============
AntiDeAMX()
{
	 new a[][] =
	 {
			 "Unarmed (Fist)",
			 "Brass K"
	 };
	 #pragma unused a
}
//============================
//=====[DEFINES]==============
#define HOLDING(%0) \
((newkeys & (%0)) == (%0))

#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

#define PATH "/Users/%s.ini"
#define PLAYER_PUNISH "/Punish/Player/%s.ini"
#define ADMIN_PUNISH "/Punish/Admin/%s.ini"

#define MAX_STRING 256 +  1

#define COLOR_BRIGHTRED 0xDC143CAA
#define COLOR_LIGHTRED 0xFF6347AA
#define COLOR_YELLOW 0xFFFF00AA

#define COLOR_ADMIN 0xFF0000
#define COL_WHITE "{FFFFFF}"
#define COL_RED "{F81414}"
#define COL_GREEN "{00FF22}"
#define COL_LIGHTBLUE "{00CED1}"

#define VERSION "v0.025 alpha"

#define ClearChat(%0) for(new i=0; i<60; i++) SendClientMessage(%0, -1, " ")

#define SCM SendClientMessage
#define SCMTA SendClientMessageToAll

#undef MAX_PLAYERS
#define MAX_PLAYERS 100

#define AUTO_SAVE 5 // sekundy

#define MAX_JOB_NAME 24 + 1
#define MAX_JOBS 50
#define MAX_BANK 10
#define MAX_HOUSES 200
#define MAX_BANKOMAT 50

#define AUTOSKOLA_VEHICLE 549

#define MAX_TIMERS 10

#define DEFAULT_PLAYER_COLOR "4d14d"
//============================
//=====[ZAMESTNANIA DEF]======
#define JOB_NEZAMESTNANY 0
#define JOB_POLICIA 1
#define JOB_HASIC 2
#define JOB_ZACHRANAR 3
#define JOB_SERIF 4 // Neviem
#define JOB_HOTDOG 5  // DOMAPPOVAT
#define JOB_PREDAJCA 6 // V INTERIERY
#define JOB_PRAVNIK 7
#define JOB_EXEKUTOR 8
#define JOB_TRAMVAJ 9
#define JOB_AUTOBUSAR 10
#define JOB_TAXIKAR 11
#define JOB_PILOT 12
#define JOB_ROPNY_VRT 13 // DOMMAPOVAT
#define JOB_OPRAVAR_MOSTOV 14 // DOMAPOVAT DVERE /VYYTAH - GOLDEN GATE
#define JOB_RYBAR 15
#define JOB_UPRATOVAC 16
#define JOB_SMETIAR 17
#define JOB_UMYVAC_OKIEN 18 //
#define JOB_HORNIK 19
#define JOB_ROZVOZ_PIZZE 20 // v INTERIERY
#define JOB_NOVINAR 21
#define JOB_VOJAK 22
#define JOB_TERRORISTA 23

#define JOB_BALLAS 24 // <-- osobitne do GANGSYSTEMU zapracova?
#define JOB_AZTECAS 25
#define JOB_GROVE 26
#define JOB_VAGOS 27
#define JOB_MAFIAN 28
#define JOB_TRIADA 29
#define JOB_YAKUZA 30

#define JOB_PRIEKUPNIK_ZBRANI 31
#define JOB_KAMIONISTA 32
#define JOB_FARMAR 33
#define JOB_KOSIC_TRAVY 34 //
#define JOB_PRIEKUPNIK_DROG 35
#define JOB_OPRAVAR 36 // NWM COHO
#define JOB_MECHANIK 37
#define JOB_PREDAJCA_AUT 38
#define JOB_SKLADNIK 39
#define JOB_KUCHAR 40
#define JOB_MESTSTKA_POLICIA 41

#define JOB_GANG 50
//#define JOB_KONGRESMAN

//============================
//====[NEW]===================
new Hodina,Minuta,Sekunda;

new Text:Liberty_title;
new Text:of_title;
new Text:SF_title;
new Text:Day;
new Text:txtcas;
new Text:Time;
new Text:Date;

new Text:kmh[MAX_PLAYERS];
new Text:usebox2[MAX_PLAYERS];
new Text:usbox[MAX_PLAYERS];
new Text:speedometer[MAX_PLAYERS];
new Text:VehicleName[MAX_PLAYERS];
new Text:MapLocation[MAX_PLAYERS];

new Text:InfoBox0;
new Text:InfoBox1;
new Text:InfoBox2;

new Text:TdSpec0[MAX_PLAYERS];
new Text:TdSpec1[MAX_PLAYERS];
new Text:TdSpec2[MAX_PLAYERS];
new Text:TdSpec3[MAX_PLAYERS];
new Text:TdSpec4[MAX_PLAYERS];
new Text:TdSpec5[MAX_PLAYERS];
new Text:TdSpec6[MAX_PLAYERS];
new Text:TdSpec7[MAX_PLAYERS];
new Text:TdSpec8[MAX_PLAYERS];
new Text:TdSpec9[MAX_PLAYERS];
new Text:TdSpec10[MAX_PLAYERS];
new Text:TdSpec11[MAX_PLAYERS];
new Text:TdSpec12[MAX_PLAYERS];
new Text:TdSpec13[MAX_PLAYERS];
new Text:TdSpec14[MAX_PLAYERS];

new AFK[MAX_PLAYERS];
new logged[MAX_PLAYERS] = 0;
new total_vehicles_from_files=0;
new IsDead[MAX_PLAYERS];
new OldMoney[MAX_PLAYERS];
new NewMoney[MAX_PLAYERS];
new VstupAutoskola, VystupAutoskola, AutoskolaZkouska, AutoCar[MAX_PLAYERS];
new acp[MAX_PLAYERS];
//new RidicakTest;
new SpecInfo[MAX_PLAYERS];
new RandText[10];
new RandList[] =
{
	'A','B','C','D','E','F','G','H','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
	'a','b','c','d','e','f','g','h','i','j','k','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
	'1','2','3','4','5','6','7','8','9','0'
};

new BadPass[MAX_PLAYERS] = 0;
new WasSpawned[MAX_PLAYERS] = 0;

new Timers[MAX_PLAYERS][MAX_TIMERS];
//======[NEMOCNICE]======
new Float:RandomSpawns[][] =
{
	{1183.5685,-1323.8699,13.5767,269.1219},
	{2028.7759,-1419.7302,16.9922,136.3065},
	{1607.2153,1818.5798,10.8203,2.2467}
};
//=======================

new VehicleNames[][] =
{
    "Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel",
	"Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus",
	"Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam",
    "Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "Injection",
	"Hunter", "Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus",
	"Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie",
	"Stallion", "Rumpo", "Bandit", "Romero", "Packer", "Monster", "Admiral",
	"Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder",
	"Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair", "RC Van",
	"Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "Raider", "Glendale",
	"Oceanic","Sanchez", "Sparrow", "Patriot", "Quad", "Coastguard", "Dinghy",
	"Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX",
	"Burrito", "Camper", "Marquis", "Baggage", "Dozer", "Maverick", "NewsVan",
	"Rancher", "FBI Ran", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking",
	"Compact", "PD Mav", "Boxville", "Benson", "Mesa", "Goblin",
	"HRacer A", "HRacer B", "Bloodring Banger", "Rancher", "SuperGT",
	"Elegant", "Journey", "Bike", "MBike", "Beagle", "Cropduster", "Stunt",
 	"Tanker", "Roadtrain", "Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra",
 	"FCR-900", "NRG-500", "HPV1000", "Truck", "Tow Truck", "Fortune",
 	"Cadrona", "FBI Truck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer",
 	"Remington", "Slamvan", "Blade", "Freight", "Streak", "Vortex", "Vincent",
    "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder", "Primo",
	"Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada", "Yosemite",
	"Windsor", "Monster", "Monster", "Uranus", "Jester", "Sultan", "Stratium",
	"Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma", "Savanna", "Bandito",
    "Freight Flat", "Streak Carriage", "Kart", "Mower", "Dune", "Sweeper",
	"Broadway", "Tornado", "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400",
	"News Van", "Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club",
	"Freight Box", "Trailer", "Andromada", "Dodo", "RC Cam", "Launch", "PD Cruiser",
 	"PD Cruiser", "PD Cruiser", "PD Ranger", "Picador", "S.W.A.T", "Alpha",
 	"Phoenix", "Glendale", "Sadler", "Luggage", "Luggage", "Stairs", "Boxville",
 	"Tiller", "Trailer"
};

//============================
//=====[ENUM]=================
enum Info
{
    Pass,
    Admin,
    Kills,
    Deaths,
    Logins,
	Float: PosX,
	Float: PosY,
	Float: PosZ,
	Float: Angle,
	Money,
	Interior,
	VirtualWorld,
	Min,
	Hour,
	Sec,
	Skin,
	Bank,
	Exp,
	Level,
	Float:HP,
	Float:ARM,
 	Weapon1,
 	Ammo1,
 	Weapon2,
 	Ammo2,
 	Weapon3,
 	Ammo3,
 	Weapon4,
 	Ammo4,
 	Weapon5,
 	Ammo5,
 	Weapon6,
 	Ammo6,
 	Weapon7,
	Ammo7,
 	Weapon8,
 	Ammo8,
 	Weapon9,
 	Ammo9,
 	Weapon10,
 	Ammo10,
 	Weapon11,
 	Ammo11,
 	Weapon12,
 	Ammo12,
 	Skinn,
 	SpecCMD,
 	VIP,
    CasVIP,
    Color,
    RidicakB
}
new PlayerInfo[MAX_PLAYERS][Info];

enum jobInfo
{
	id,
	namejob,
	Float:jobX,
	Float:jobY,
	Float:jobZ,
	Text3D:Label,
	MapIcon,
	PickUp
}
new Jobs[MAX_JOBS][jobInfo];

enum PlayerPunishment
{
	eSok,
	aSlay,
	aSamotka,
	aVar,
	eEvent,
	dotazy,
	aJail,
	aFreeze,
	aKick,
	aRespawn,
	aKill,
	aExplode,
	aBan,
}
new PlayerPun[MAX_PLAYERS][PlayerPunishment];

enum AdminPunishment
{
	eSok,
	aSlay,
	aSamotka,
	aVar,
	eEvent,
	dotazy,
	aJail,
	aFreeze,
	aKick,
	aRespawn,
	aKill,
	aExplode,
	aBan,
}
new AdminPun[MAX_PLAYERS][AdminPunishment];

enum BankE
{
	Bid,
	Float:Bankx,
	Float:Banky,
	Float:Bankz,
	PickUp,
	MapIcon,
    Text3D:BLabel
}
new Banka[MAX_BANK][BankE];

enum BankomatInfo
{
	bankomatid,
	Float:Bankx,
	Float:Banky,
	Float:Bankz,
	MapIcon,
	Text3D:Label,
	PickUp
}
new Bankomat[MAX_BANKOMAT][BankomatInfo];

main()
{
	print(" ------------------------------------");
	print("       Liberty of Los Santos       	");
	print("Creators:       XpresS		");
	print("SA-MP Version:      0.3.7            ");
	print("GM Version:       "VERSION"			");
	print("Work Started:        8.4.2017       	");
	print(" ------------------------------------");
}
//============================
//=====[FORWARD]==============
forward Cas(playerid);
forward SetTime(playerid);
forward Camera(playerid);
forward SpeedUpdate();
forward FuelUpdate();
forward DataSave(playerid);
forward HideInfoBox(playerid);
forward KickExEx(playerid);
forward Restart(playerid);
forward SetSpecInfo(playerid, pid);
forward CreateJob(jobId, jobName[], Float:Jx, Float:Jy, Float:Jz, icon);
forward CreateBank(bankId, Float:Bx, Float:By, Float:Bz);
forward CreateBankomat(BankomatID, Float:Bax, Float:Bay, Float:Baz);
forward RandomText();
forward CheckVIP();
forward CheckMoney();
forward CheckPosition(playerid);
forward InGameTime(playerid);
forward CAFK(playerid);
//============================
//======[PUBLICS]=============
public CheckPosition(playerid)
{
	if(logged[playerid] == 1)
	{
        TextDrawSetString(MapLocation[playerid], GetPlayerZone(playerid));
        TextDrawShowForPlayer(playerid, MapLocation[playerid]);
	}
	return 1;
}
public CAFK(playerid)
{
  new Float:Pos[3];
  for(new i = 0; i < MAX_PLAYERS; i++)
  {
     GetPlayerPos(i,Pos[0],Pos[1],Pos[2]);
     if(IsPlayerInRangeOfPoint(i,2,Pos[0],Pos[1],Pos[2]))
     {
        new string[40];
        format(string, sizeof(string), "[AFK] %d sekund", AFK[i]);
     	new Text3D:afkk = Create3DTextLabel(string, -1, 30.0, 40.0, 50.0, 40.0, 0);
    	Attach3DTextLabelToPlayer(afkk, playerid, 0.0, 0.0, 0.7);
        AFK[i]++;
     }
     if(AFK[i] == 12000)
     {
        AFK[i] = 0;
        Kick(playerid);
      }
  }
  return 1;
}

public InGameTime()
{
	new string[30];
	Sekunda ++;
	if(Sekunda == 60)
	{
		Sekunda = 1;
		Minuta ++;
	}
	else if(Minuta == 60)
	{
		Minuta = 0;
		Hodina ++;
	}
	else if(Hodina == 24)
	{
		Hodina = 0;
	}
	for(new p = 0; p < MAX_PLAYERS; p++)
	{
		format(string, sizeof(string), "~g~%02d~r~:~g~%02d", Minuta, Sekunda);
		TextDrawSetString(txtcas, string);
		if(logged[p]==1)
		{
			TextDrawShowForPlayer(p, txtcas);
			SetPlayerTime(p,Hodina,Minuta);
		}
	}
	return 1;
}

//potom dát do gamemodeinit + zprávu v kicku

public CheckVIP()
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;
        if(!PlayerInfo[i][CasVIP]) continue;
        if(PlayerInfo[i][CasVIP] <= gettime())
        {
            PlayerInfo[i][VIP] = 0;
            PlayerInfo[i][CasVIP] = 0;
            Message(i, "Tvoje VIP práve vypršalo !");
        }
    }
    return 1;
}

public CheckMoney()
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			if(GetPlayerMoney(i) > NewMoney[i])
			{
				ResetPlayerMoney(i);
				Kick(i);
			}
		}
	}
	return 1;
}
public RandomText()
{
    RandomString(RandText);
    new str[144];
    format(str,sizeof(str),""COL_RED"[!] "COL_WHITE"Kdo jako první napíše text "COL_RED"%s"COL_WHITE" získá náhodný poeet peniz.",RandText);
    SendClientMessageToAll(-1,str);
    return 1;
}
stock PunishmentsSave(playerid)
{
	if(GetALevel(playerid) == 0)
	if(DOF2_FileExists(PlayerPunPath(playerid)))
	{
		DOF2_SetInt(PlayerPunPath(playerid),"eSok",PlayerPun[playerid][eSok]);
	    DOF2_SetInt(PlayerPunPath(playerid),"Slay",PlayerPun[playerid][aSlay]);
	    DOF2_SetInt(PlayerPunPath(playerid),"Samotka",PlayerPun[playerid][aSamotka]);
	    DOF2_SetInt(PlayerPunPath(playerid),"Var",PlayerPun[playerid][aVar]);
	    DOF2_SetInt(PlayerPunPath(playerid),"eEvent",PlayerPun[playerid][eEvent]);
	    DOF2_SetInt(PlayerPunPath(playerid),"dotazy",PlayerPun[playerid][dotazy]);
	    DOF2_SetInt(PlayerPunPath(playerid),"Jail",PlayerPun[playerid][aJail]);
	    DOF2_SetInt(PlayerPunPath(playerid),"Freeze",PlayerPun[playerid][aFreeze]);
	    DOF2_SetInt(PlayerPunPath(playerid),"Kick",PlayerPun[playerid][aKick]);
	    DOF2_SetInt(PlayerPunPath(playerid),"Respawn",PlayerPun[playerid][aRespawn]);
	    DOF2_SetInt(PlayerPunPath(playerid),"Kill",PlayerPun[playerid][aKill]);
	    DOF2_SetInt(PlayerPunPath(playerid),"Explode",PlayerPun[playerid][aExplode]);
	    DOF2_SetInt(PlayerPunPath(playerid),"Ban",PlayerPun[playerid][aBan]);
	    DOF2_SaveFile();
	}else{
	   	DOF2_SetInt(AdminPunPath(playerid),"eSok",AdminPun[playerid][eSok]);
	    DOF2_SetInt(AdminPunPath(playerid),"Slay",AdminPun[playerid][aSlay]);
	    DOF2_SetInt(AdminPunPath(playerid),"Samotka",AdminPun[playerid][aSamotka]);
	    DOF2_SetInt(AdminPunPath(playerid),"Var",AdminPun[playerid][aVar]);
	    DOF2_SetInt(AdminPunPath(playerid),"eEvent",AdminPun[playerid][eEvent]);
	    DOF2_SetInt(AdminPunPath(playerid),"dotazy",AdminPun[playerid][dotazy]);
	    DOF2_SetInt(AdminPunPath(playerid),"Jail",AdminPun[playerid][aJail]);
	    DOF2_SetInt(AdminPunPath(playerid),"Freeze",AdminPun[playerid][aFreeze]);
	    DOF2_SetInt(AdminPunPath(playerid),"Kick",AdminPun[playerid][aKick]);
	    DOF2_SetInt(AdminPunPath(playerid),"Respawn",AdminPun[playerid][aRespawn]);
	    DOF2_SetInt(AdminPunPath(playerid),"Kill",AdminPun[playerid][aKill]);
	    DOF2_SetInt(AdminPunPath(playerid),"Explode",AdminPun[playerid][aExplode]);
	    DOF2_SetInt(AdminPunPath(playerid),"Ban",AdminPun[playerid][aBan]);
	}
	return 1;
}
stock LoadPunishments(playerid)
{
	if(DOF2_FileExists(PlayerPunPath(playerid)))
	{
		DOF2_GetInt("eSok",PlayerPun[playerid][eSok]);
	    DOF2_GetInt("Slay",PlayerPun[playerid][aSlay]);
	    DOF2_GetInt("Samotka",PlayerPun[playerid][aSamotka]);
	    DOF2_GetInt("Var",PlayerPun[playerid][aVar]);
	    DOF2_GetInt("eEvent",PlayerPun[playerid][eEvent]);
	    DOF2_GetInt("dotazy",PlayerPun[playerid][dotazy]);
	    DOF2_GetInt("Jail",PlayerPun[playerid][aJail]);
	    DOF2_GetInt("Freeze",PlayerPun[playerid][aFreeze]);
	    DOF2_GetInt("Kick",PlayerPun[playerid][aKick]);
	    DOF2_GetInt("Respawn",PlayerPun[playerid][aRespawn]);
	    DOF2_GetInt("Kill",PlayerPun[playerid][aKill]);
	    DOF2_GetInt("Explode",PlayerPun[playerid][aExplode]);
	    DOF2_GetInt("Ban",PlayerPun[playerid][aBan]);
    }else{
		DOF2_CreateFile(PlayerPunPath(playerid));
	}
	if(DOF2_FileExists(AdminPunPath(playerid)))
	{
		DOF2_GetInt("eSok",PlayerPun[playerid][eSok]);
	    DOF2_GetInt("Slay",PlayerPun[playerid][aSlay]);
	    DOF2_GetInt("Samotka",PlayerPun[playerid][aSamotka]);
	    DOF2_GetInt("Var",PlayerPun[playerid][aVar]);
	    DOF2_GetInt("eEvent",PlayerPun[playerid][eEvent]);
	    DOF2_GetInt("dotazy",PlayerPun[playerid][dotazy]);
	    DOF2_GetInt("Jail",PlayerPun[playerid][aJail]);
	    DOF2_GetInt("Freeze",PlayerPun[playerid][aFreeze]);
	    DOF2_GetInt("Kick",PlayerPun[playerid][aKick]);
	    DOF2_GetInt("Respawn",PlayerPun[playerid][aRespawn]);
	    DOF2_GetInt("Kill",PlayerPun[playerid][aKill]);
	    DOF2_GetInt("Explode",PlayerPun[playerid][aExplode]);
	    DOF2_GetInt("Ban",PlayerPun[playerid][aBan]);
    }else{
		//DOF2_CreateFile(PlayerPunPath(playerid));
	}
	return 1;
}

public Restart(playerid)
{
    SCM(playerid, COLOR_ADMIN, "Server sa reštartuje...");
	SendRconCommand("gmx");
	return 1;
}

public HideInfoBox(playerid)
{
    TextDrawHideForPlayer(playerid, InfoBox0);
    TextDrawHideForPlayer(playerid, InfoBox1);
    TextDrawHideForPlayer(playerid, InfoBox2);
	return 1;
}

public SetSpecInfo(playerid, pid)
{
	TextDrawHideForPlayer(playerid, TdSpec0[playerid]);
    TextDrawHideForPlayer(playerid, TdSpec1[playerid]);
    TextDrawHideForPlayer(playerid, TdSpec2[playerid]);
    TextDrawHideForPlayer(playerid, TdSpec3[playerid]);
    TextDrawHideForPlayer(playerid, TdSpec4[playerid]);
    TextDrawHideForPlayer(playerid, TdSpec5[playerid]);
    TextDrawHideForPlayer(playerid, TdSpec6[playerid]);
    TextDrawHideForPlayer(playerid, TdSpec7[playerid]);
    TextDrawHideForPlayer(playerid, TdSpec8[playerid]);
    TextDrawHideForPlayer(playerid, TdSpec9[playerid]);
    TextDrawHideForPlayer(playerid, TdSpec10[playerid]);
    TextDrawHideForPlayer(playerid, TdSpec11[playerid]);
    TextDrawHideForPlayer(playerid, TdSpec12[playerid]);
    TextDrawHideForPlayer(playerid, TdSpec13[playerid]);
    TextDrawHideForPlayer(playerid, TdSpec14[playerid]);
	new string[256],Float:health, Float:armour;
	GetPlayerHealth(pid, health);
	GetPlayerArmour(pid, armour);

	format(string, sizeof(string), "JMENO: %s", PlayerName(pid));
	TextDrawSetString(TdSpec1[playerid], string);
	format(string, sizeof(string), "ID: %d", pid);
	TextDrawSetString(TdSpec2[playerid], string);
    format(string, sizeof(string), "ADMIN LEVEL: {FFFFFF}%s", GetNameALevel(pid));
	TextDrawSetString(TdSpec3[playerid], string);
	format(string, sizeof(string), "KICK: %d", PlayerPun[pid][aKick]);
    TextDrawSetString(TdSpec4[playerid], string);
    format(string, sizeof(string), "{BAN: %d", PlayerPun[pid][aBan]);
    TextDrawSetString(TdSpec5[playerid], string);
    format(string, sizeof(string), "NAHRANY CAS: %dh/%dm/%ds", PlayerInfo[pid][Hour],PlayerInfo[pid][Min],PlayerInfo[pid][Sec]);
    TextDrawSetString(TdSpec6[playerid], string);
    format(string, sizeof(string), "INTERIER: %d", GetPlayerInterior(pid));
    TextDrawSetString(TdSpec7[playerid], string);
    format(string, sizeof(string), "VW: %d", GetPlayerVirtualWorld(pid));
    TextDrawSetString(TdSpec8[playerid], string);
    format(string, sizeof(string), "ZABIT: %d", PlayerInfo[pid][Kills]);
    TextDrawSetString(TdSpec9[playerid], string);
    format(string, sizeof(string), "ZEMREL: %d", PlayerInfo[pid][Deaths]);
    TextDrawSetString(TdSpec10[playerid], string);
    format(string, sizeof(string), "PENIZE: %d", GetPlayerMoney(pid));
    TextDrawSetString(TdSpec11[playerid], string);
    format(string, sizeof(string), "BANKA: %d", PlayerInfo[pid][Bank]);
    TextDrawSetString(TdSpec12[playerid], string);
    format(string, sizeof(string), "HP: %f", health);
    TextDrawSetString(TdSpec13[playerid], string);
	format(string, sizeof(string), "ARMOUR: %0.f", armour);
    TextDrawSetString(TdSpec14[playerid], string);

	TextDrawShowForPlayer(playerid, TdSpec0[playerid]);
    TextDrawShowForPlayer(playerid, TdSpec1[playerid]);
    TextDrawShowForPlayer(playerid, TdSpec2[playerid]);
    TextDrawShowForPlayer(playerid, TdSpec3[playerid]);
    TextDrawShowForPlayer(playerid, TdSpec4[playerid]);
    TextDrawShowForPlayer(playerid, TdSpec5[playerid]);
    TextDrawShowForPlayer(playerid, TdSpec6[playerid]);
    TextDrawShowForPlayer(playerid, TdSpec7[playerid]);
    TextDrawShowForPlayer(playerid, TdSpec8[playerid]);
    TextDrawShowForPlayer(playerid, TdSpec9[playerid]);
    TextDrawShowForPlayer(playerid, TdSpec10[playerid]);
    TextDrawShowForPlayer(playerid, TdSpec11[playerid]);
    TextDrawShowForPlayer(playerid, TdSpec12[playerid]);
    TextDrawShowForPlayer(playerid, TdSpec13[playerid]);
    TextDrawShowForPlayer(playerid, TdSpec14[playerid]);
	return 1;
}
public KickExEx(playerid)
{
	Kick(playerid);
	PlayerPun[playerid][aKick]++;
	return 1;
}
public SpeedUpdate()
{
	for(new i = 0;i<MAX_PLAYERS;i++)
	{
		if(IsPlayerConnected(i) && IsPlayerInAnyVehicle(i))
		{
			new Float:xx,Float:yy,Float:zz,Float:hp,string[24],vehicleid = GetPlayerVehicleID(i);
			TextDrawShowForPlayer(i,speedometer[i]);
			TextDrawShowForPlayer(i,kmh[i]);
			TextDrawShowForPlayer(i,VehicleName[i]);
			TextDrawShowForPlayer(i,usebox2[i]);
			TextDrawShowForPlayer(i,usbox[i]);
			GetVehicleVelocity(vehicleid,xx,yy,zz);
			GetVehicleHealth(vehicleid,hp);
			format(string,sizeof(string),"%dkm/h",floatround(floatsqroot(((xx*xx)+(yy*yy))+(zz*zz))*156.666667));
			TextDrawSetString(kmh[i],string);
        	format(string, sizeof(string), "%s", VehicleNames[GetVehicleModel(GetPlayerVehicleID(i))-400]);
        	TextDrawSetString(VehicleName[i], string);
		}
		if(!IsPlayerInAnyVehicle(i))
		{
			TextDrawHideForPlayer(i,speedometer[i]);
			TextDrawHideForPlayer(i,kmh[i]);
			TextDrawHideForPlayer(i,usebox2[i]);
			TextDrawHideForPlayer(i,usbox[i]);
            TextDrawHideForPlayer(i,VehicleName[i]);
		}
	}
}

public Camera(playerid)
{
	ClearChat(playerid);
	InterpolateCameraPos(playerid, -1150.871704, 852.612365, 200.904647, -2013.680419, -127.693359, 81.917411, 50000);
	InterpolateCameraLookAt(playerid, -1155.176635, 850.340270, 199.762481, -2015.832275, -131.740615, 79.920066, 50000);
}

public SetTime(playerid)
{
	new string[256],year,month,day,hours,minutes,seconds;
	getdate(year, month, day), gettime(hours, minutes, seconds);
	format(string, sizeof string, "%d/%s%d/%s%d", day, ((month < 10) ? ("0") : ("")), month, (year < 10) ? ("0") : (""), year);
	TextDrawSetString(Date, string);
	format(string, sizeof string, "~g~%s%d~r~:~g~%s%d~r~:~g~%s%d", (hours < 10) ? ("0") : (""), hours, (minutes < 10) ? ("0") : (""), minutes, (seconds < 10) ? ("0") : (""), seconds);
	TextDrawSetString(Time, string);
	new weekday;
	weekday = GetWeekdayNum(day, month, year);
	if(weekday == 7){TextDrawSetString(Day,"~r~po ~g~ut str st pi so ne");} // pondelok
	if(weekday == 1){TextDrawSetString(Day,"~g~po ~r~ut ~g~str st pi so ne");} // utorok
	if(weekday == 2){TextDrawSetString(Day,"~g~po ut ~r~str ~g~st pi so ne");} //streda
	if(weekday == 3){TextDrawSetString(Day,"~g~po ut str ~r~st~g~ pi so ne");} // stvrtok
	if(weekday == 4){TextDrawSetString(Day,"~g~po ut str st ~r~pi~g~ so ne");} // piatok
	if(weekday == 5){TextDrawSetString(Day,"~g~po ut str st pi ~r~so~g~ ne");} //sobota
	if(weekday == 6){TextDrawSetString(Day,"~g~po ut str st pi so ~r~ne");} // nedela
}

public Cas(playerid)
{
	PlayerInfo[playerid][Sec] ++;
	if(PlayerInfo[playerid][Sec]>=60)
	{
		PlayerInfo[playerid][Min]++;
		PlayerInfo[playerid][Sec]=0;
	}
	if(PlayerInfo[playerid][Min]>=60)
	{
		PlayerInfo[playerid][Min]=0;
		PlayerInfo[playerid][Hour]++;
		PlayerInfo[playerid][Exp]+=10;
	}
}

stock LoadUserData(playerid)
{
	PlayerInfo[playerid][PosX] = DOF2_GetFloat(UserPath(playerid), "PositionX");
	PlayerInfo[playerid][PosY] = DOF2_GetFloat(UserPath(playerid), "PositionY");
	PlayerInfo[playerid][PosZ] = DOF2_GetFloat(UserPath(playerid), "PositionZ");
	PlayerInfo[playerid][Angle] = DOF2_GetFloat(UserPath(playerid), "Angle");
	PlayerInfo[playerid][SpecCMD] = DOF2_GetInt(UserPath(playerid),"SpecCMD");
	PlayerInfo[playerid][Interior] = DOF2_GetInt(UserPath(playerid), "Interior");
	PlayerInfo[playerid][VirtualWorld] = DOF2_GetInt(UserPath(playerid), "VirtualWorld");
	PlayerInfo[playerid][Pass] = DOF2_GetInt(UserPath(playerid),"Password",PlayerInfo[playerid][Pass]);
	PlayerInfo[playerid][Money] = DOF2_GetInt(UserPath(playerid),"Money");
	PlayerInfo[playerid][Admin] = DOF2_GetInt(UserPath(playerid),"Admin");
	PlayerInfo[playerid][Kills] = DOF2_GetInt(UserPath(playerid),"Kills");
	PlayerInfo[playerid][Skin] = DOF2_GetInt(UserPath(playerid),"Skin");
    PlayerInfo[playerid][Deaths] = DOF2_GetInt(UserPath(playerid),"Deaths");
    PlayerInfo[playerid][Logins] = DOF2_GetInt(UserPath(playerid),"Logins");
   	PlayerInfo[playerid][Min] = DOF2_GetInt(UserPath(playerid),"Min");
	PlayerInfo[playerid][Hour] = DOF2_GetInt(UserPath(playerid),"Hour");
	PlayerInfo[playerid][Sec] = DOF2_GetInt(UserPath(playerid),"Sec");
	PlayerInfo[playerid][Skinn] = DOF2_GetInt(UserPath(playerid),"Skin");
	PlayerInfo[playerid][Bank] = DOF2_GetInt(UserPath(playerid),"Bank");
	PlayerInfo[playerid][Exp] = DOF2_GetInt(UserPath(playerid),"Exp");
	PlayerInfo[playerid][Level] = DOF2_GetInt(UserPath(playerid),"Level");
    PlayerInfo[playerid][HP] = DOF2_GetFloat(UserPath(playerid),"HP");
    PlayerInfo[playerid][ARM] = DOF2_GetFloat(UserPath(playerid),"Armour");
    PlayerInfo[playerid][VIP] = DOF2_GetInt(UserPath(playerid),"VIP");
	PlayerInfo[playerid][CasVIP] = DOF2_GetInt(UserPath(playerid),"CasVIP");
	PlayerInfo[playerid][Color] = DOF2_GetInt(UserPath(playerid),"Color");
	PlayerInfo[playerid][RidicakB] = DOF2_GetInt(UserPath(playerid),"RidicakB");
	return 1;
}
stock SaveData(playerid)
{
	GetPlayerWeaponData(playerid, 1, PlayerInfo[playerid][Weapon1], PlayerInfo[playerid][Ammo1]);
    GetPlayerWeaponData(playerid, 2, PlayerInfo[playerid][Weapon2], PlayerInfo[playerid][Ammo2]);
    GetPlayerWeaponData(playerid, 3, PlayerInfo[playerid][Weapon3], PlayerInfo[playerid][Ammo3]);
    GetPlayerWeaponData(playerid, 4, PlayerInfo[playerid][Weapon4], PlayerInfo[playerid][Ammo4]);
    GetPlayerWeaponData(playerid, 5, PlayerInfo[playerid][Weapon5], PlayerInfo[playerid][Ammo5]);
    GetPlayerWeaponData(playerid, 6, PlayerInfo[playerid][Weapon6], PlayerInfo[playerid][Ammo6]);
    GetPlayerWeaponData(playerid, 7, PlayerInfo[playerid][Weapon7], PlayerInfo[playerid][Ammo7]);
    GetPlayerWeaponData(playerid, 8, PlayerInfo[playerid][Weapon8], PlayerInfo[playerid][Ammo8]);
    GetPlayerWeaponData(playerid, 9, PlayerInfo[playerid][Weapon9], PlayerInfo[playerid][Ammo9]);
    GetPlayerWeaponData(playerid, 10, PlayerInfo[playerid][Weapon10], PlayerInfo[playerid][Ammo10]);
    GetPlayerWeaponData(playerid, 11, PlayerInfo[playerid][Weapon11], PlayerInfo[playerid][Ammo11]);
    GetPlayerWeaponData(playerid, 12, PlayerInfo[playerid][Weapon12], PlayerInfo[playerid][Ammo12]);
	new Float:Zivoty, Float:Brnenie;
	GetPlayerHealth(playerid, Zivoty);
	GetPlayerArmour(playerid, Brnenie);
	PlayerInfo[playerid][HP] = Zivoty;
	PlayerInfo[playerid][ARM] = Brnenie;
	GetPlayerPos( playerid, PlayerInfo[playerid][PosX],PlayerInfo[playerid][PosY],PlayerInfo[playerid][PosZ]);
    GetPlayerFacingAngle( playerid, PlayerInfo[playerid][Angle] );

	DOF2_SetInt(UserPath(playerid),"Money",PlayerInfo[playerid][Money]);
	DOF2_SetInt(UserPath(playerid),"Admin",PlayerInfo[playerid][Admin]);
	DOF2_SetInt(UserPath(playerid),"Kills",PlayerInfo[playerid][Kills]);
	DOF2_SetInt(UserPath(playerid),"Deaths",PlayerInfo[playerid][Deaths]);
	DOF2_SetInt(UserPath(playerid),"Logins",PlayerInfo[playerid][Logins]);
	DOF2_SetInt(UserPath(playerid),"Min",PlayerInfo[playerid][Min]);
	DOF2_SetInt(UserPath(playerid),"Skin",GetPlayerSkin(playerid));
	DOF2_SetInt(UserPath(playerid),"Hour",PlayerInfo[playerid][Hour]);
	DOF2_SetInt(UserPath(playerid),"Sec",PlayerInfo[playerid][Sec]);
    DOF2_SetFloat(UserPath(playerid), "PositionX", PlayerInfo[playerid][PosX] );
    DOF2_SetFloat(UserPath(playerid), "PositionY", PlayerInfo[playerid][PosY] );
    DOF2_SetFloat(UserPath(playerid), "PositionZ", PlayerInfo[playerid][PosZ] );
    DOF2_SetFloat(UserPath(playerid), "SpecCMD", PlayerInfo[playerid][SpecCMD] );
    DOF2_SetFloat(UserPath(playerid), "Angle", PlayerInfo[playerid][Angle] );
	DOF2_SetInt(UserPath(playerid), "Interior", GetPlayerInterior( playerid ) );
	DOF2_SetInt(UserPath(playerid), "VirtualWorld", GetPlayerVirtualWorld( playerid ) );
	DOF2_SetInt(UserPath(playerid), "Skin", GetPlayerSkin( playerid ) );
	DOF2_SetInt(UserPath(playerid),"Bank",PlayerInfo[playerid][Bank]);
	DOF2_SetInt(UserPath(playerid), "Exp",PlayerInfo[playerid][Exp]);
	DOF2_SetInt(UserPath(playerid), "Level",PlayerInfo[playerid][Level]);
	DOF2_SetInt(UserPath(playerid), "Weapon1", PlayerInfo[playerid][Weapon1]);
 	DOF2_SetInt(UserPath(playerid), "Weapon2", PlayerInfo[playerid][Weapon2]);
 	DOF2_SetInt(UserPath(playerid), "Weapon3", PlayerInfo[playerid][Weapon3]);
 	DOF2_SetInt(UserPath(playerid), "Weapon4", PlayerInfo[playerid][Weapon4]);
 	DOF2_SetInt(UserPath(playerid), "Weapon5", PlayerInfo[playerid][Weapon5]);
 	DOF2_SetInt(UserPath(playerid), "Weapon6", PlayerInfo[playerid][Weapon6]);
 	DOF2_SetInt(UserPath(playerid), "Weapon7", PlayerInfo[playerid][Weapon7]);
 	DOF2_SetInt(UserPath(playerid), "Weapon8", PlayerInfo[playerid][Weapon8]);
 	DOF2_SetInt(UserPath(playerid), "Weapon9", PlayerInfo[playerid][Weapon9]);
 	DOF2_SetInt(UserPath(playerid), "Weapon10", PlayerInfo[playerid][Weapon10]);
 	DOF2_SetInt(UserPath(playerid), "Weapon11", PlayerInfo[playerid][Weapon11]);
 	DOF2_SetInt(UserPath(playerid), "Weapon12", PlayerInfo[playerid][Weapon12]);

	DOF2_SetInt(UserPath(playerid), "Ammo1", PlayerInfo[playerid][Ammo1]);
	DOF2_SetInt(UserPath(playerid), "Ammo2", PlayerInfo[playerid][Ammo2]);
	DOF2_SetInt(UserPath(playerid), "Ammo3", PlayerInfo[playerid][Ammo3]);
	DOF2_SetInt(UserPath(playerid), "Ammo4", PlayerInfo[playerid][Ammo4]);
	DOF2_SetInt(UserPath(playerid), "Ammo5", PlayerInfo[playerid][Ammo5]);
	DOF2_SetInt(UserPath(playerid), "Ammo6", PlayerInfo[playerid][Ammo6]);
	DOF2_SetInt(UserPath(playerid), "Ammo7", PlayerInfo[playerid][Ammo7]);
	DOF2_SetInt(UserPath(playerid), "Ammo8", PlayerInfo[playerid][Ammo8]);
	DOF2_SetInt(UserPath(playerid), "Ammo9", PlayerInfo[playerid][Ammo9]);
	DOF2_SetInt(UserPath(playerid), "Ammo10", PlayerInfo[playerid][Ammo10]);
	DOF2_SetInt(UserPath(playerid), "Ammo11", PlayerInfo[playerid][Ammo11]);
	DOF2_SetInt(UserPath(playerid), "Ammo12", PlayerInfo[playerid][Ammo12]);
	DOF2_SetFloat(UserPath(playerid),"HP",PlayerInfo[playerid][HP]);
	DOF2_SetFloat(UserPath(playerid),"Armour",PlayerInfo[playerid][ARM]);
	DOF2_SetInt(UserPath(playerid),"VIP",PlayerInfo[playerid][VIP]);
	DOF2_SetInt(UserPath(playerid),"CasVIP",PlayerInfo[playerid][CasVIP]);
	DOF2_SetInt(UserPath(playerid), "Color", PlayerInfo[playerid][Color]);
	DOF2_SetInt(UserPath(playerid),"RidicakB",PlayerInfo[playerid][RidicakB]);
}
//////////////////////
//////////////////////

public CreateBank(bankId, Float:Bx, Float:By, Float:Bz)
{
	Banka[bankId][Bankx] = Bx;
	Banka[bankId][Banky] = By;
	Banka[bankId][Bankz] = Bz;
	Banka[bankId][Bid] = bankId;

	Banka[bankId][MapIcon] = CreateDynamicMapIcon(Bx, By, Bz, 52, 0);
	Banka[bankId][BLabel] = CreateDynamic3DTextLabel("[Banka]", 0xFF0000FF, Bx, By, Bz, 50.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
	for(new b=0; b<MAX_PLAYERS; b++) Banka[bankId][PickUp] = CreateDynamicPickup(1274,1, Bx, By,Bz, b, 0);
	return 1;
}
public CreateBankomat(BankomatID, Float:Bax, Float:Bay, Float:Baz)
{
	Bankomat[BankomatID][Bankx] = Bax;
	Bankomat[BankomatID][Banky] = Bay;
	Bankomat[BankomatID][Bankz] = Baz;
	Bankomat[BankomatID][bankomatid] = BankomatID;

	Bankomat[BankomatID][MapIcon] = CreateDynamicMapIcon(Bax, Bay, Baz, 52, 0);
	Bankomat[BankomatID][Label] = CreateDynamic3DTextLabel("[Bankomat]", 0xFF0000FF, Bax, Bay, Baz, 50.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
	for(new b=0; b<MAX_PLAYERS; b++) Bankomat[BankomatID][PickUp] = CreateDynamicPickup(1274,1, Bax, Bay, Baz, b, 0);
	return 1;
}

public CreateJob(jobId, jobName[] ,Float:Jx, Float:Jy, Float:Jz, icon)
{
	//Jobs[jobId][namejob] = jobName;
	Jobs[jobId][jobX] = Jx;
	Jobs[jobId][jobY] = Jy;
	Jobs[jobId][jobZ] = Jz;
	Jobs[jobId][id] = jobId;

	new str[75];
	format(str, sizeof(str), "[Zamestnanie]\n%s", jobName);

	Jobs[jobId][MapIcon] = CreateDynamicMapIcon(Jx, Jy, Jz, icon, 20);
	Jobs[jobId][Label] = CreateDynamic3DTextLabel(str, 0xFF0000FF, Jx, Jy, Jz, 50.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);

	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
    for(new ids0=0; ids0 < MAX_BANKOMAT; ids0++)
	{
	    if(IsPlayerInSphere(playerid,Bankomat[ids0][Bankx],Bankomat[ids0][Banky],Bankomat[ids0][Bankz],3)==1)
		{
			ShowPlayerDialog(playerid, DIALOG_BANK, DIALOG_STYLE_LIST, "Bankomat", "Stav\nVybrat\nVložit\nVybra? všetko\nVloži? všetko", "Vybra?", "Storno");
		}
	}
	for(new ids0=0; ids0<MAX_BANK; ids0++)
	{
	    if(IsPlayerInSphere(playerid,Banka[ids0][Bankx],Banka[ids0][Banky],Banka[ids0][Bankz],3)==1)
		{
			InfoBox(playerid, "PRE VSTUP STLAC F!", 6);
		}
	}
	for(new ids1=0; ids1<MAX_JOBS; ids1++)
	{
		if(IsPlayerInSphere(playerid,Jobs[ids1][jobX],Jobs[ids1][jobY],Jobs[ids1][jobZ],3)==1)
		{
			InfoBox(playerid, "PRE OTEVRENI MENU STISKNI F!", 6);
		}
	}
    if(pickupid == VstupAutoskola)
    {
		InfoBox(playerid, "PRO VSTUP DO AUTOSKOLY STISKNI F", 3);
    }
    if(pickupid == VystupAutoskola)
    {
		InfoBox(playerid, "PRO VYSTUP DO AUTOSKOLY STISKNI F", 3);
    }
    if(pickupid == AutoskolaZkouska)
    {
		InfoBox(playerid, "PRO OTEVRENI MENU STISKNI F", 3);
    }
	return 1;
}
public OnPlayerEnterDynamicCP(playerid,checkpointid)
{
    for(new ids0=0; ids0 < MAX_BANKOMAT; ids0++)
	{
	    if(IsPlayerInSphere(playerid,Bankomat[ids0][Bankx],Bankomat[ids0][Banky],Bankomat[ids0][Bankz],3)==1)
		{
			ShowPlayerDialog(playerid, DIALOG_BANK, DIALOG_STYLE_LIST, "Bankomat", "Stav\nVybrat\nVložit\nVybra? všetko\nVloži? všetko", "Vybra?", "Storno");
		}
	}
    if(IsPlayerInSphere(playerid,2315.7192,-7.2789,26.7422,3)==1)
	{
		ShowPlayerDialog(playerid, DIALOG_BANK, DIALOG_STYLE_LIST, "Banka", "Stav\nVybrat\nVložit\nVybra? všetko\nVloži? všetko", "Vybra?", "Storno");
	}
	return 1;
}
////////////////////////
//============================
public OnGameModeInit()
{
    CreateDynamic3DTextLabel("[Banka]\nVÝCHOD", 0xFF0000FF, 2305.8718,-16.1436,26.7496, 50.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 1, 0); // EXIT BANKA
    for(new bankPID=0; bankPID<MAX_PLAYERS; bankPID++)
	{
		CreateDynamicPickup(1274,1, 2305.8718,-16.1436,26.7496, bankPID, 0); // PICKUP EXIT
		CreateDynamicCP(2315.7192,-7.2789,26.7422, 1.5, 1, 0, bankPID); // Výber
	}

	/* SAN FIERRO BANKY*/
	CreateBank(0, -2374.1492,942.6392,45.4393);
	CreateBank(1, -1988.2341,1039.0054,55.7266);
	CreateBank(2, -1946.2325,555.0698,35.1719);
	CreateBank(3, -1610.1035,779.5831,7.1875);
	CreateBank(4, -1950.9917,1345.2639,7.1875);
	CreateBank(5, -2242.3000,191.4594,35.3203);
	CreateBank(6, -2648.8906,376.1100,6.1593);
	CreateBank(7, -2016.8364,-27.3699,35.2152);
	/* PALOMINO CREEK BANKY*/
	CreateBank(8, 2302.3367, -16.0762, 26.4844);
	/* SAN FIERRO BANKOMATY */
	CreateBankomat(0, -2227.8323,287.7067,35.3203);
	CreateBankomat(1,-1678.8401,437.5883,7.1797);
    CreateBankomat(2,-1940.7927,275.9156,41.0471);


    CreateJob(JOB_POLICIA, "Policia", -1605.6229,711.8320,13.8672, 6);
    CreateJob(JOB_HASIC, "Hasie", 2026.4365,67.0827,28.6916, 6);
    CreateJob(JOB_ZACHRANAR, "Zachranár", -2655.3120,638.9794,14.4531, 6);
    CreateJob(JOB_SERIF, "Šerif", 217.7919,979.0998,19.5037, 6);
    CreateJob(JOB_PILOT,"Pilot", -1541.1945,-441.0560,6.1000,5); //DOROBIT U PILOTA VSTUP/VYSTUP
    //CreateJob(JOB_ROPNY_VRT,"Pracovník ropného vrtu", X,9);
    //CreateJob(JOB_OPRAVAR_MOSTOV,"Opravár mostov", X,9);
    CreateJob(JOB_RYBAR,"Rybár", -1552.1914,1276.2831,7.1853,9);
    CreateJob(JOB_UPRATOVAC,"Upratovae", -2109.5649,0.6681,35.3203,16);
    CreateJob(JOB_SMETIAR,"Smetiar", -1832.2394,-69.1689,15.1094,40);
    CreateJob(JOB_UMYVAC_OKIEN,"Umývae okien", -2054.1487,379.4349,35.1719,40);
    CreateJob(JOB_HORNIK,"Horník",-2816.2969,-1527.1433,140.8438,57);

    //DOROBIT CreateJob(JOB_ROZVOZ_PIZZE,"Rozvoz Pizze", X,29);

    CreateJob(JOB_NOVINAR,"Novinár", -2054.9534,453.9141,35.1719,4);
    CreateJob(JOB_VOJAK,"Vojak", -1526.7625,486.0031,7.1797,18);
    CreateJob(JOB_TERRORISTA,"Terrorista", -1327.0835,2522.6399,87.0866,19);
    /*CreateJob(JOB_BALLAS,"Ballas", X,59);
    CreateJob(JOB_AZTECAS,"Aztecas", X,58);
    CreateJob(JOB_VAGOS,"Vagos", X,60);
    CreateJob(JOB_MAFINA,"Ruská Mafia", X,61);
    CreateJob(JOB_TRIADA,"Triada", X,43);
    */
    CreateJob(JOB_YAKUZA,"Yakuza", -2177.1345,-263.3357,36.5156,44);

    CreateJob(JOB_PRIEKUPNIK_ZBRANI,"Priekupnik zbraní", -2491.4497,2363.0718,10.2726,18);
    CreateJob(JOB_KAMIONISTA,"Kamionista", 125.1815,-285.4176,1.5781,51);
    CreateJob(JOB_FARMAR,"Farmár", -103.9826,9.4240,3.1172,23);
    CreateJob(JOB_KOSIC_TRAVY,"Kosie Trávy", -2317.2280,245.7105,35.3203,8);
    CreateJob(JOB_PRIEKUPNIK_DROG,"Priekupnik Drog", -1111.1167,-1637.4613,76.3672,23);
    //CreateJob(JOB_OPRAVAR,"XX", X,6);
    CreateJob(JOB_MECHANIK,"Mechanik", -1873.3951,-218.3538,18.3750,48);
    CreateJob(JOB_PREDAJCA_AUT,"Predajca Aut", -1799.9275,1200.3373,25.1194,55);
    CreateJob(JOB_SKLADNIK,"Skladník", -1933.8248,619.4207,35.1719,51);
    CreateJob(JOB_KUCHAR,"Kuchár", -2430.3091,-183.0481,35.3203,40);
    CreateJob(JOB_MESTSTKA_POLICIA,"Mestská Polícia", -1607.6158,713.2224,13.5962,6);
    /*CreateJob(JOB_HOTDOG,"Hodogar", X,6);
    CreateJob(JOB_PREDAJCA,"Predavae", X,6);
    CreateJob(JOB_PRAVNIK,"Právnik", X,6);
    CreateJob(JOB_EXEKUTOR,"Exekútor", X,6);
    CreateJob(JOB_TRAMVAJ,"Tramvajar", X,6);
*/

	SetTimer("SpeedUpdate",100,1);
	SetTimer("SetTime",1000,true);
	SetTimer("CheckVIP", 10000, true);
    SetTimer("InGameTime", 1000, true);

	ManualVehicleEngineAndLights();
	DisableInteriorEnterExits();
	EnableStuntBonusForAll(0);

	TextDraw();

	total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/trains.txt");
 	total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/pilots.txt");
	total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/lv_law.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/lv_airport.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/lv_gen.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/sf_law.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/sf_airport.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/sf_gen.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/ls_law.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/ls_airport.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/ls_gen_inner.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/ls_gen_outer.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/whetstone.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/bone.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/flint.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/tierra.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/red_county.txt");
	///////////////////
	//================

	VstupAutoskola = CreatePickup(1318, 1, -2026.5702,-101.7656,35.1641, 0);
	VystupAutoskola = CreatePickup(1318, 1, -2026.9592,-104.0146,1035.1719, 0);
	AutoskolaZkouska = CreatePickup(1239, 1, -2026.7332,-114.9335,1035.1719, 0);

	SetGameModeText("LoSF "VERSION"");
	//////////////////
	return 1;
}
public OnGameModeExit()
{
    SetTimer("RandomText",1800000,true);
	for(new i=0;i<MAX_PLAYERS;i++) if(logged[i]){ SaveData(i); }
	DOF2_Exit();
    return 1;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	if(IsPlayerAdmin(playerid) || PlayerInfo[playerid][Admin] >= 5)
	{
	    if(!IsPlayerInAnyVehicle(playerid))
	    {
	        SetPlayerPosFindZ(playerid, fX, fY, fZ);
	    }
	    else if(IsPlayerInAnyVehicle(playerid))
	    {
	        new Babatz = GetPlayerVehicleID(playerid);
	        new Batz = GetPlayerVehicleSeat(playerid);
	        SetVehiclePos(Babatz,fX,fY,fZ);
	        PutPlayerInVehicle(playerid,Babatz,Batz);
	    }
	}
    return 1;
}

public OnPlayerConnect(playerid)
{
    logged[playerid] = 0;
    IsDead[playerid] = 0;

    CheckRegister(playerid);

    PlayerTextDraw(playerid);

    SetTimerEx("Camera", 100, false, "i", playerid);

	LoadPunishments(playerid);

	SCMFTA(-1, "{B3B3B3}** Hráe %s(%d) sa pripojil do hry.", PlayerName(playerid), playerid);

	TogglePlayerSpectating(playerid, true);

	WasSpawned[playerid] = 0;

	LoadPunishments(playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{

	TextDrawDestroy(kmh[playerid]);
	TextDrawDestroy(speedometer[playerid]);
	TextDrawDestroy(usebox2[playerid]);
	TextDrawDestroy(usbox[playerid]);
	TextDrawDestroy(VehicleName[playerid]);

	PunishmentsSave(playerid);
	if(logged[playerid] == 1)
	{
    	SaveData(playerid);
	}
	switch(reason)
	{
 		case 0: SCMFTA(-1, "{B3B3B3}** Hráe %s(%d) opustil hru. Duvod: Timeout",PlayerName(playerid), playerid);
 		case 1: SCMFTA(-1, "{B3B3B3}** Hráe %s(%d) opustil hru. Duvod: Odešel", PlayerName(playerid),playerid);
	    case 2: SCMFTA(-1, "{B3B3B3}** Hráe %s(%d) opustil hru. Duvod: Kick / Ban", PlayerName(playerid),playerid);
	}
	for(new t=0;t<MAX_TIMERS; t++) KillTimer(Timers[playerid][t]);
	return 1;
}

public OnPlayerText(playerid, text[])
{
	if(GetALevel(playerid) >= 1)
	{
	    if(text[0] == '$')
	 	{
			SendAdminMessage(text);
		}
	}
    ChatLog(playerid, text);
    SetPlayerChatBubble(playerid, text, 0xFF0000FF, 100.0, 5000);
	if(logged[playerid] == 0) return 0;

	if(RandText[0] && strcmp(text,RandText,true) == 0)
	{
		new string[144],penize = random(50000);
		format(string,sizeof(string),""COL_RED"[!]"COL_WHITE" První napsal text "COL_RED"%s"COL_WHITE" hráe "COL_GREEN"%s"COL_WHITE" a získal "COL_LIGHTBLUE"%d{FFFFFF} peniz.",RandText,PlayerName(playerid),penize);
		SendClientMessageToAll(-1,string);
		GivePlayerMoneyEx(playerid, penize);
		PlayerInfo[playerid][Exp]+=50;
		RandText[0] = 0;
		return 0;
	}

	if(PlayerInfo[playerid][VIP] == 0)
	{
	    new str[144];
	    format(str, sizeof (str), "{FF0000}%s {3399FF}(%d): {%s}%s",PlayerInfo[playerid][Color], PlayerName(playerid), playerid, text);
	    SendClientMessageToAll(-1, str);
        return 0;
 	}
	if(PlayerInfo[playerid][VIP] == 1)
	{
	    new textstr[128];
        format(textstr, sizeof(textstr), "{CCCCFF}Silver VIP {%s}%s (%d): %s",PlayerInfo[playerid][Color], PlayerName(playerid),playerid, text);
        SendClientMessageToAll(-1, textstr);
        return 0;
 	}
	if(PlayerInfo[playerid][VIP] == 2)
	{
	    new textstr[128];
        format(textstr, sizeof(textstr), "{FFCC00}Gold VIP {%s}%s (%d): %s",PlayerInfo[playerid][Color], PlayerName(playerid),playerid, text);
        SendClientMessageToAll(-1, textstr);
        return 0;
 	}
	return 1;
}

public OnPlayerRequestClass(playerid,classid)
{
	if(IsDead[playerid] == 1)
	{
		InterpolateCameraPos(playerid, -1942.520263, 1001.259765, 260.332244, -1979.224975, 766.297180, 260.332244, 5000);
		InterpolateCameraLookAt(playerid, -1939.344726, 998.284057, 257.870269, -1975.395019, 768.667114, 258.160949, 5000);
	}
	return 1;
}
public OnPlayerSpawn(playerid)
{
	if(WasSpawned[playerid] == 1)
	{
		if(IsDead[playerid] == 1)
		{
		    IsDead[playerid] = 0;
		    new Random = random(sizeof(RandomSpawns));
			SetSpawnInfo(playerid, 0, PlayerInfo[playerid][Skinn], RandomSpawns[Random][0], RandomSpawns[Random][1], RandomSpawns[Random][2], RandomSpawns[Random][3], 0, 0, 0, 0,0,0);
			SpawnPlayer(playerid);
			SetPlayerHealth(playerid, 100);
			Message(playerid, "Za poskytnutí našich služeb jsme vám z vašeho úetu strhnuli 1 000$!");
			if(PlayerInfo[playerid][Bank] >= 1000)
			{
				PlayerInfo[playerid][Bank]-=1000;
			}else{
				if(GetPlayerMoney(playerid) >= 1000)
	   			{
	   			    GivePlayerMoneyEx(playerid, -1000);
	   			}
			}
		}else{
			///////////////////
			AntiDeAMX();
			//////////////////
	 	}
	}else{
	    new Float:health;
 		GetPlayerHealth(playerid,health);
		if(health < 1)
 		{
	        PlayerInfo[playerid][HP]+=100;
		}


		TextDrawShowForPlayer(playerid, Day),
		TextDrawShowForPlayer(playerid, Date),
		TextDrawShowForPlayer(playerid, Time),
		TextDrawShowForPlayer(playerid, Liberty_title),
	    TextDrawShowForPlayer(playerid, of_title),
	    TextDrawShowForPlayer(playerid, SF_title),
		TextDrawShowForPlayer(playerid, txtcas);

		WasSpawned[playerid] = 1;

		logged[playerid] = 1;
		TogglePlayerSpectating(playerid, false);
		SetPlayerHealth(playerid, PlayerInfo[playerid][HP]);
		SetPlayerArmour(playerid, PlayerInfo[playerid][ARM]);

 		GivePlayerWeapon(playerid,PlayerInfo[playerid][Weapon1],PlayerInfo[playerid][Ammo1]/2);
		GivePlayerWeapon(playerid,PlayerInfo[playerid][Weapon2],PlayerInfo[playerid][Ammo2]/2);
		GivePlayerWeapon(playerid,PlayerInfo[playerid][Weapon3],PlayerInfo[playerid][Ammo3]/2);
	 	GivePlayerWeapon(playerid,PlayerInfo[playerid][Weapon4],PlayerInfo[playerid][Ammo4]/2);
	 	GivePlayerWeapon(playerid,PlayerInfo[playerid][Weapon5],PlayerInfo[playerid][Ammo5]/2);
	 	GivePlayerWeapon(playerid,PlayerInfo[playerid][Weapon6],PlayerInfo[playerid][Ammo6]/2);
	 	GivePlayerWeapon(playerid,PlayerInfo[playerid][Weapon7],PlayerInfo[playerid][Ammo7]/2);
	 	GivePlayerWeapon(playerid,PlayerInfo[playerid][Weapon8],PlayerInfo[playerid][Ammo8]/2);
	 	GivePlayerWeapon(playerid,PlayerInfo[playerid][Weapon9],PlayerInfo[playerid][Ammo9]/2);
	 	GivePlayerWeapon(playerid,PlayerInfo[playerid][Weapon10],PlayerInfo[playerid][Ammo10]/2);
	 	GivePlayerWeapon(playerid,PlayerInfo[playerid][Weapon11],PlayerInfo[playerid][Ammo11]/2);
	 	GivePlayerWeapon(playerid,PlayerInfo[playerid][Weapon12],PlayerInfo[playerid][Ammo12]/2);

		Timers[playerid][0] = SetTimerEx("SaveData", AUTO_SAVE * 1000, true, "i", playerid);
		Timers[playerid][1] = SetTimerEx("CAFK",1000,true, "i", playerid);
		Timers[playerid][2] = SetTimerEx("CheckPosition", 1000, true, "i", playerid);
		Timers[playerid][3] = SetTimerEx("LevelUp", 1000, true, "i", playerid);

		SetPlayerColor(playerid, PlayerInfo[playerid][Color]);
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    IsDead[playerid] = 1;
	PlayerInfo[killerid][Kills]++;
	PlayerInfo[playerid][Deaths]++;
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	for(new BID=0; BID<MAX_BANK; BID++)
	{
	    if(IsPlayerInSphere(playerid,Banka[BID][Bankx],Banka[BID][Banky],Banka[BID][Bankz],3)==1) // VSTUP PRE BANKU DYNAMICKY
		{
			if(PRESSED(KEY_SECONDARY_ATTACK))
			{
			    if(GetPlayerVirtualWorld(playerid) > 0)
	   			{}else{
					SetPVarInt(playerid, "BankVW", GetPlayerVirtualWorld(playerid));
					new Float:pos[3];
					GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
					SetPVarInt(playerid, "BankEPos", BID);
					SetPlayerVirtualWorld(playerid, 1);
					SetPlayerPos(playerid, 2305.8718,-16.1436,26.7496);
				}
			}
		}
	}
	if(IsPlayerInSphere(playerid,2305.8718,-16.1436,26.7496,3)==1) //VYSTUP V INTERIERY
	{
	    if(GetPlayerVirtualWorld(playerid) == 1)
	    {
		    InfoBox(playerid, "PRE VYCHOD STLAC F", 5);
			if(PRESSED(KEY_SECONDARY_ATTACK))
			{
			        SetPlayerVirtualWorld(playerid, GetPVarInt(playerid, "BankVW"));
					//SetPlayerPos(playerid, 2299.9780,-15.8797,26.4844);
					//SetPlayerPos(playerid, GetPVarFloat(playerid, "BankEPosX"),GetPVarFloat(playerid, "BankEPosY"),GetPVarFloat(playerid, "BankEPosZ"));
                    SetPlayerPos(playerid, Banka[GetPVarInt(playerid, "BankEPos")][Bankx],Banka[GetPVarInt(playerid, "BankEPos")][Banky],Banka[GetPVarInt(playerid, "BankEPos")][Bankz]);
			}
		}
	}
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		new vehicleid = GetPlayerVehicleID(playerid);
		if(PRESSED(KEY_NO))
		{
			new engine,lights,alarm,doors,bonnet,boot,objective;
			GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
			if(engine == 1)
			{
				SetVehicleParamsEx(vehicleid,0,lights,alarm,doors,bonnet,boot,objective);
			}else{
		 		SetVehicleParamsEx(vehicleid,1,lights,alarm,doors,bonnet,boot,objective);
			}
		}
		if(PRESSED(KEY_SUBMISSION))
		{
			new engine,lights,alarm,doors,bonnet,boot,objective;
			GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
			if(lights == 1) SetVehicleParamsEx(vehicleid,engine,0,alarm,doors,bonnet,boot,objective);
			else SetVehicleParamsEx(vehicleid,engine,1,alarm,doors,bonnet,boot,objective);
		}
		if(PRESSED(KEY_SECONDARY_ATTACK))
		{
			new engine,lights,alarm,doors,bonnet,boot,objective;
			GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
			if(doors == 1) SetVehicleParamsEx(vehicleid,engine,lights,alarm,0,bonnet,boot,objective);
			else SetVehicleParamsEx(vehicleid, engine,lights,alarm,1,bonnet,boot,objective);
		}
	}
	if(IsPlayerInSphere(playerid,-2026.5702,-101.7656,35.1641,3)==1)
	{
			if(PRESSED(KEY_SECONDARY_ATTACK))
			{
				SetPlayerPos(playerid, -2026.9592,-104.0146,1035.1719);
				SetPlayerInterior(playerid,3);
			}
	}
	if(IsPlayerInSphere(playerid,-2026.9592,-104.0146,1035.1719,3)==1)
	{
			if(PRESSED(KEY_SECONDARY_ATTACK))
			{
				SetPlayerPos(playerid, -2026.5702,-101.7656,35.1641);
				SetPlayerInterior(playerid,0);
			}
	}
	if(IsPlayerInSphere(playerid,-2026.7332,-114.9335,1035.1719,3)==1)
	{
			if(PRESSED(KEY_SECONDARY_ATTACK))
			{
				ShowPlayerDialog(playerid, DIALOG_CARSCHOOL, DIALOG_STYLE_LIST, "Autoškola", "Zkoušky (10 000$)", "Zvolit", "Zrušit");
			}
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    	if(dialogid == DIALOG_BANK)
	    {
	        if(response)
	        {
	            switch(listitem)
	            {
	                case 0:
					{
					    new string[70];
					    format(string, sizeof(string), "Váš zustatek na úetu je %d$", PlayerInfo[playerid][Bank]);
						ShowPlayerDialog(playerid, DIALOG_STAV, DIALOG_STYLE_MSGBOX, "Stav úetu", string, "Zavoít", "");
					}
	                case 1:
					{
						ShowPlayerDialog(playerid, DIALOG_VYBRAT, DIALOG_STYLE_INPUT, "Banka", "Zadaj eástku pre výber", "Confirm", "Storno");
	 				}
				    case 2:
					{
						ShowPlayerDialog(playerid, DIALOG_VLOZIT, DIALOG_STYLE_INPUT, "Banka", "Zadaj eiastku pre vloženie", "Confirm", "Storno");
					}
					case 3:
					{
					    GivePlayerMoneyEx(playerid, PlayerInfo[playerid][Bank]);
					    PlayerInfo[playerid][Bank] = 0;
					    new string[80];
						format(string, sizeof(string), "Nový zustatok na úete: %d", PlayerInfo[playerid][Bank]);
						Message(playerid, string);
					}
	                case 4:
	                {
						PlayerInfo[playerid][Bank] = PlayerInfo[playerid][Money];
						PlayerInfo[playerid][Money] = 0;
						ResetMoney(playerid);
						new string[80];
						format(string, sizeof(string), "Nový zustatok na úete: %d", PlayerInfo[playerid][Bank]);
						Message(playerid, string);
					}
	            }
	        }
	        return 1;
	    }
	    if(dialogid == DIALOG_STAV)
	    {
	        if(!response) ShowPlayerDialog(playerid, DIALOG_BANK, DIALOG_STYLE_LIST, "BANK", "Stav\nVybrat\nVložit\nVybra? všetko\nVloži? všetko", "Vybrat", "Storno");
		}
     	if(dialogid == DIALOG_VYBRAT)
	    {
	        if(response)
	        {
	            new text = strval(inputtext);
	        	if(text < 0 || text > 999999999999)
	         	{
		             if (! strlen (inputtext)) return ShowPlayerDialog (playerid, DIALOG_VYBRAT, DIALOG_STYLE_INPUT, "BANKA - Výbir eástky", "Zadej eástku, kterou chceš z banky vybrat!\n{FF0000}ZADAL SI NEPLATNOU EÁSTKU!" , "zadat" , "zrušit" ) ;
		             if (GetPlayerMoney (playerid) < strval(inputtext)) return ShowPlayerDialog(playerid, DIALOG_VYBRAT, DIALOG_STYLE_INPUT, "Vybrat", "tolik penízku nemáš v bance :(" , "zadat" , "zrušit" ) ;
		             GivePlayerMoneyEx(playerid, strval(inputtext));
		             PlayerInfo[playerid][Bank] += strval(inputtext);
		             SCMF(playerid, -1, "Nový zostatok na úete: %d", PlayerInfo[playerid][Bank]);
				}else{
					ShowPlayerDialog (playerid, DIALOG_VLOZIT, DIALOG_STYLE_INPUT, "BANKA - Výbir eástky", "Zadej eástku, kterou chceš z banky vybrat!\n{FF0000}ZADAL SI NEPLATNOU EÁSTKU!" , "zadat" , "zrušit" ) ;
				}
			}else{
                ShowPlayerDialog(playerid, DIALOG_BANK, DIALOG_STYLE_LIST, "BANK", "Stav\nVybrat\nVložit\nVybra? všetko\nVloži? všetko", "Vybrat", "Storno");
			}
	        return 1;
	    }
     	if(dialogid == DIALOG_VLOZIT)
	    {
	        if(response)
	        {
	            new text = strval(inputtext);
	        	if(text < 0 || text > 999999999999)
	         	{
	             	if (! strlen (inputtext)) return ShowPlayerDialog (playerid, DIALOG_VLOZIT, DIALOG_STYLE_INPUT, "Eástka", "neplatna eástka! " , "zadat" , "zrušit" ) ;
	             	if (GetPlayerMoney (playerid) < strval (inputtext)) return ShowPlayerDialog(playerid, DIALOG_VLOZIT, DIALOG_STYLE_INPUT, "vložit", "tolik penízku nemáš :(" , "zadat" , "zrušit" ) ;
	             	GivePlayerMoneyEx(playerid,-strval (inputtext));
	             	PlayerInfo [playerid] [Bank] += strval (inputtext);
	             	SCMF(playerid, -1, "Nový zostatok na úete: %d", PlayerInfo[playerid][Bank]);
				}else{
					ShowPlayerDialog (playerid, DIALOG_VLOZIT, DIALOG_STYLE_INPUT, "Eástka", "Lze použít jenom eísla!" , "zadat" , "zrušit" ) ;
				}
			}else{
                ShowPlayerDialog(playerid, DIALOG_BANK, DIALOG_STYLE_LIST, "BANK", "Stav\nVybrat\nVložit\nVybra? všetko\nVloži? všetko", "Vybrat", "Storno");
			}
	        return 1;
	    }
		if(dialogid == DIALOG_RADIO)
		{
		    if(response)
		    {
				switch(listitem)
				{
					case 0: {}
	   				case 1: PlayAudioStreamForPlayer(playerid, "http://www.play.cz/radio/evropa2-128.mp3.m3u");
				   	case 2: PlayAudioStreamForPlayer(playerid, "http://www.play.cz/radio/spin64.mp3.m3u");
				   	case 3: PlayAudioStreamForPlayer(playerid, "http://www.hiphopstage.cz/radio128.pls");
				   	case 4: PlayAudioStreamForPlayer(playerid, "http://www.play.cz/radio/frekvence1-128.mp3.m3u");
				   	case 5: PlayAudioStreamForPlayer(playerid, "http://www.play.cz/radio/impuls128.mp3.m3u");
				   	case 6: PlayAudioStreamForPlayer(playerid, "http://ice.abradio.cz:8000/fajn128.mp3");
				   	case 7: PlayAudioStreamForPlayer(playerid, "http://ice.abradio.cz:8000/helax128.mp3.m3u");
					case 8: ShowPlayerDialog(playerid, DIALOG_OWNRADIO, DIALOG_STYLE_INPUT, "Vlastní rádio", "Zde napiš odkaz", "Select", "Cancel");
				}
			}
		}
		if(dialogid == DIALOG_OWNRADIO)
		{
		    if(response)
		    {
		        PlayAudioStreamForPlayer(playerid, inputtext);
			}
		}
	    if(dialogid == DIALOG_CARSCHOOL)
	    {
	        if(response)
	        {
	            switch(listitem)
	            {
	                case 0:
	                {
						if(PlayerInfo[playerid][RidicakB] == 0)
						{
      						if(GetPlayerMoney(playerid) >= 10000)
            				{
								GivePlayerMoneyEx(playerid, -10000);
								SetPlayerInterior(playerid, 0);
								SetPlayerVirtualWorld(playerid, playerid);
								AutoCar[playerid] = CreateVehicle(AUTOSKOLA_VEHICLE,-2044.5496,-84.8166,34.8612,0.6667, -1,-1,-1);
								SetVehicleVirtualWorld(AutoCar[playerid], playerid);
								SetPlayerPos(playerid, -2044.5496,-84.8166,34.8612);
								PutPlayerInVehicle(playerid, AutoCar[playerid], 0);
								acp[playerid] = 1;
							 	SetPlayerRaceCheckpoint(playerid,0,-2049.3713,-68.1456,34.8693,-2152.8745,-67.7842,34.8691,5.0);
							}else{
								SendClientMessage(playerid, -1, "Nemáš bohužel dostatek peniz.");
							}
						}else{
							SendClientMessage(playerid, -1, "Již máš oidieák!");
						}
					}
	            }
	        }
	    }
     	if(dialogid == DIALOG_REGISTER)
	    {
            if (!response) return Kick(playerid);
            if(response)
            {
                if(!strlen(inputtext))
                {
					ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "REGISTER","Vítej ve hoe, nováeku!\nZadej prosím své nové heslo!", "Zvolit", "Zrušit");
				}
				if(36 > strlen(inputtext) > 4)
				{
                    ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "REGISTER","Vítej ve hoe, nováeku!\nZadej prosím své nové heslo!", "Zvolit", "Zrušit");
				}
				//new hashpass[250];
				//WP_Hash(hashpass,sizeof(hashpass),inputtext);
				PlayerInfo[playerid][Pass] = udb_hash(inputtext);
				DOF2_SetString(UserPath(playerid), "Password", PlayerInfo[playerid][Pass]);
                DOF2_SetInt(UserPath(playerid),"Bank",0);
                DOF2_SetInt(UserPath(playerid),"Exp",0);
                DOF2_SetInt(UserPath(playerid),"Level",0);
                DOF2_SetInt(UserPath(playerid),"RidicakB",0);
                DOF2_SetString(UserPath(playerid),"Color",DEFAULT_PLAYER_COLOR);
				DOF2_SaveFile();
                SaveData(playerid);
                SetSpawnInfo(playerid, 0, 0, -1975.9182,137.7640,27.6875,89.2057, 0, 0, 0, 0, 0, 0);
                SpawnPlayer(playerid);
                SetTimerEx("Cas", 1000, true, "i", playerid);
                //PlayerInfo[playerid][Logins]++;
				new string[120];
				format(string, sizeof(string), "Vítej ve hoe, {FF3300}%s{FFFFFF}! Pokud bys potoeboval s nieím pomoct, zadej /help", PlayerName(playerid));
				SendClientMessage(playerid, -1, string);

			}
        }
     	if(dialogid == DIALOG_LOGIN)
	    {
            if( response )
            {
                //new hashpass[300];
				//WP_Hash(hashpass,sizeof(hashpass),inputtext);
				//if( !strcmp( hashpass, PlayerInfo[ playerid ][ Pass ], false ) )
				if(udb_hash(inputtext) == DOF2_GetInt(UserPath(playerid), "Password"))
				{
                    LoadUserData(playerid);
                    GivePlayerMoneyEx(playerid, PlayerInfo[playerid][Money]);
                    SetSpawnInfo(playerid, PlayerInfo[playerid][Skinn],0, PlayerInfo[playerid][PosX],PlayerInfo[playerid][PosY],PlayerInfo[playerid][PosZ],PlayerInfo[playerid][Angle],0,0,0,0,0,0);
                    SpawnPlayer(playerid);
					SetPlayerInterior( playerid, PlayerInfo[playerid][Interior] );
					SetPlayerVirtualWorld( playerid, PlayerInfo[playerid][VirtualWorld] );
					PlayerInfo[playerid][Logins]++;
					PlayerInfo[playerid][Exp]++;
					SetTimerEx("Cas", 1000, true, "i", playerid);
					SendClientMessage(playerid, -1, "Úspišni si se {FF0000}POIHLÁSIL{FFFFFF}!");
                }else{
                    BadPass[playerid]++;
					if(BadPass[playerid] < 3)
					{
					    new string[120];
					    format(string, sizeof(string), "Zadal si nesprávne heslo %d/3 !", BadPass[playerid]);
						Message(playerid, string);
					}
					if(BadPass[playerid] >= 3)
					{
					    BadPass[playerid] = 0;
					    new string[120];
					    format(string, sizeof(string), "Hráe %s zadal 3x zlé heslo a ból vyhodený !", PlayerName(playerid));
					    MessageTA(string);
						KickEx(playerid);
					}
					ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT, "LOGIN","Vítej zpátky ve hoe!\n\nZadej prosím své heslo pro potvrzení.", "Zvolit", "Zrušit");
                }
            }else{
                Kick(playerid);
			}
			return 1;
        }
    	return 0;
}
public OnPlayerEnterRaceCheckpoint(playerid)
{
	switch(acp[playerid])
	{
		case 1:
		{
		    DisablePlayerRaceCheckpoint(playerid);
		    SetPlayerRaceCheckpoint(playerid,0,-2152.8745,-67.7842,34.8691,-2152.8745,-67.7842,34.8691,5.0);
		    acp[playerid] = 2;
		}
		case 2:
		{
		    DisablePlayerRaceCheckpoint(playerid);
		    SetPlayerRaceCheckpoint(playerid,0,-2152.8745,-67.7842,34.8691,-2249.5930,-68.4627,34.8688,5.0);
		    acp[playerid] = 3;
		}
		case 3:
		{
		    DisablePlayerRaceCheckpoint(playerid);
		    SetPlayerRaceCheckpoint(playerid,0,-2249.5930,-68.4627,34.8688,-2249.7830,46.4425,34.8703,5.0);
		    acp[playerid] = 4;
		}
		case 4:
		{
		    DisablePlayerRaceCheckpoint(playerid);
		    SetPlayerRaceCheckpoint(playerid,0,-2249.7830,46.4425,34.8703,-2373.4697,-61.4780,34.8968,5.0);
		    acp[playerid] = 5;
		}
 		case 5:
		{
		    DisablePlayerRaceCheckpoint(playerid);
		    SetPlayerRaceCheckpoint(playerid,0,-2373.4697,-61.4780,34.8968,-2424.8264,-68.1810,34.9773,5.0);
		    acp[playerid] = 6;
		}
 		case 6:
		{
		    DisablePlayerRaceCheckpoint(playerid);
		    SetPlayerRaceCheckpoint(playerid,0,-2424.8264,-68.1810,34.9773,-2508.6108,-68.0486,25.2240,5.0);
		    acp[playerid] = 7;
		}
 		case 7:
		{
		    DisablePlayerRaceCheckpoint(playerid);
		    SetPlayerRaceCheckpoint(playerid,0,-2508.6108,-68.0486,25.2240,-2601.9478,-66.9061,3.9937,5.0);
		    acp[playerid] = 8;
		}
 		case 8:
		{
		    DisablePlayerRaceCheckpoint(playerid);
		    SetPlayerRaceCheckpoint(playerid,0,-2601.9478,-66.9061,3.9937,-2602.1951,27.7066,3.8764,5.0);
		    acp[playerid] = 9;
		}
 		case 9:
		{
		    DisablePlayerRaceCheckpoint(playerid);
		    SetPlayerRaceCheckpoint(playerid,0,-2602.1951,27.7066,3.8764,-2605.3250,159.4388,3.8764,5.0);
		    acp[playerid] = 10;
		}
 		case 10:
		{
		    DisablePlayerRaceCheckpoint(playerid);
		    SetPlayerRaceCheckpoint(playerid,0,-2605.3250,159.4388,3.8764,-2703.8196,163.1200,3.9746,5.0);
		    acp[playerid] = 11;
		}
 		case 11:
		{
		    DisablePlayerRaceCheckpoint(playerid);
		    SetPlayerRaceCheckpoint(playerid,0,-2703.8196,163.1200,3.9746,-2704.2810,281.4559,3.9531,5.0);
		    acp[playerid] = 12;
		}
 		case 12:
		{
		    DisablePlayerRaceCheckpoint(playerid);
		    SetPlayerRaceCheckpoint(playerid,0,-2704.2810,281.4559,3.9531,-2700.4023,333.2613,3.8804,5.0);
		    acp[playerid] = 13;
		}
 		case 13:
		{
		    DisablePlayerRaceCheckpoint(playerid);
		    SetPlayerRaceCheckpoint(playerid,0,-2700.4023,333.2613,3.8804,-2604.6960,325.0151,3.8769,5.0);
		    acp[playerid] = 14;
		}
 		case 14:
		{
		    DisablePlayerRaceCheckpoint(playerid);
		    SetPlayerRaceCheckpoint(playerid,0,-2604.6960,325.0151,3.8769,-2604.1208,465.3903,14.1682,5.0);
		    acp[playerid] = 15;
		}
 		case 15:
		{
		    DisablePlayerRaceCheckpoint(playerid);
		    SetPlayerRaceCheckpoint(playerid,0,-2604.1208,465.3903,14.1682,-2522.9712,561.3566,14.1629,5.0);
		    acp[playerid] = 16;
		}
 		case 16:
		{
		    DisablePlayerRaceCheckpoint(playerid);
		    SetPlayerRaceCheckpoint(playerid,0,-2522.9712,561.3566,14.1629,-2315.4651,563.2466,31.6173,5.0);
		    acp[playerid] = 17;
		}
 		case 17:
		{
		    DisablePlayerRaceCheckpoint(playerid);
		    SetPlayerRaceCheckpoint(playerid,0,-2315.4651,563.2466,31.6173,-2228.8074,558.6979,34.7129,5.0);
		    acp[playerid] = 18;
		}
 		case 18:
		{
		    DisablePlayerRaceCheckpoint(playerid);
		    SetPlayerRaceCheckpoint(playerid,0,-2228.8074,558.6979,34.7129,-2229.4500,502.5050,34.7163,5.0);
		    acp[playerid] = 19;
		}
 		case 19:
		{
		    DisablePlayerRaceCheckpoint(playerid);
		    SetPlayerRaceCheckpoint(playerid,0,-2229.4500,502.5050,34.7163,-2280.7329,388.0360,34.3543,5.0);
		    acp[playerid] = 20;
		}
 		case 20:
		{
		    DisablePlayerRaceCheckpoint(playerid);
		    SetPlayerRaceCheckpoint(playerid,0,-2280.7329,388.0360,34.3543,-2255.2559,313.9443,34.8697,5.0);
		    acp[playerid] = 21;
		}
 		case 21:
		{
		    DisablePlayerRaceCheckpoint(playerid);
		    SetPlayerRaceCheckpoint(playerid,0,-2255.2559,313.9443,34.8697,-2259.7390,-57.0095,34.8688,5.0);
		    acp[playerid] = 22;
		}
 		case 22:
		{
		    DisablePlayerRaceCheckpoint(playerid);
		    SetPlayerRaceCheckpoint(playerid,0,-2259.7390,-57.0095,34.8688,-2249.1624,-73.0541,34.8691,5.0);
		    acp[playerid] = 23;
		}
 		case 23:
		{
		    DisablePlayerRaceCheckpoint(playerid);
		    SetPlayerRaceCheckpoint(playerid,0,-2249.1624,-73.0541,34.8691,-2134.2405,-72.8314,34.8754,5.0);
		    acp[playerid] = 24;
		}
 		case 24:
		{
		    DisablePlayerRaceCheckpoint(playerid);
		    SetPlayerRaceCheckpoint(playerid,0,-2134.2405,-72.8314,34.8754,-2052.2747,-74.8391,34.8617,5.0);
		    acp[playerid] = 25;
		}
 		case 25:
		{
		    DisablePlayerRaceCheckpoint(playerid);
		    SetPlayerRaceCheckpoint(playerid,1,-2052.2747,-74.8391,34.8617,-2072.5085,-85.1227,34.8613,5.0);
		    acp[playerid] = 26;
		}
		case 26:
		{
		    DisablePlayerRaceCheckpoint(playerid);
		    acp[playerid] = 0;
		    DestroyVehicle(AutoCar[playerid]);
			SetPlayerPos(playerid, -2026.7332,-114.9335,1035.1719);
			SetPlayerInterior(playerid,3);
			SetPlayerVirtualWorld(playerid, 0);
			ShowPlayerDialog(playerid, DIALOG_EVERYTHING, DIALOG_STYLE_MSGBOX, "Autoškola", "Naše práce je zde již hotova. Úspišni si složil test.", "Zavoít", "");
            PlayerInfo[playerid][RidicakB]++;
		}
	}
	return 1;
}


public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
	if(success)
 	{
		if(IsPlayerConnected(playerid))
		{
			if(GetALevel(playerid) >= 1)
     		{
     		    if(PlayerInfo[playerid][SpecCMD] == 1)
     		    {
					for(new i=1; i < 4; i++) SCMF(i ,COLOR_ADMIN, "[CMD ]%s[%d]: %s", PlayerName(playerid),playerid, cmdtext);
				}
			}
  		}
	}else{
        Message(playerid, "Tento príkaz neexistuje, použi prosím /help alebo /cmds");
	}
	return 1;
}

CMD:motor(playerid)
{
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		new vehicleid = GetPlayerVehicleID(playerid);
		new engine,lights,alarm,doors,bonnet,boot,objective;
		GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
		if(engine == 1) SetVehicleParamsEx(vehicleid,0,lights,alarm,doors,bonnet,boot,objective);
		else
		{
			SetVehicleParamsEx(vehicleid,1,lights,alarm,doors,bonnet,boot,objective);
		}
	}
	return 1;
}

CMD:svetla(playerid)
{
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		new vehicleid = GetPlayerVehicleID(playerid);
		new engine,lights,alarm,doors,bonnet,boot,objective;
		GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
		if(lights == 1) SetVehicleParamsEx(vehicleid,engine,0,alarm,doors,bonnet,boot,objective);
		else
		{
			SetVehicleParamsEx(vehicleid,engine,1,alarm,doors,bonnet,boot,objective);
		}
	}
	return 1;
}

CMD:kufr(playerid)
{
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		new vehicleid = GetPlayerVehicleID(playerid);
		new engine,lights,alarm,doors,bonnet,boot,objective;
		GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
		if(boot == 1) SetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,0,objective);
		else
		{
			SetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,1,objective);
		}
	}
	return 1;
}

CMD:kapota(playerid)
{
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		new vehicleid = GetPlayerVehicleID(playerid);
		new engine,lights,alarm,doors,bonnet,boot,objective;
		GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
		if(bonnet == 1) SetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,0,boot,objective);
		else
		{
			SetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,1,boot,objective);
		}
	}
	return 1;
}

CMD:alarm(playerid)
{
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		new vehicleid = GetPlayerVehicleID(playerid);
		new engine,lights,alarm,doors,bonnet,boot,objective;
		GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
		if(alarm == 1) SetVehicleParamsEx(vehicleid,engine,lights,0,doors,bonnet,boot,objective);
		else
		{
			SetVehicleParamsEx(vehicleid,engine,lights,1,doors,bonnet,boot,objective);
		}
	}
	return 1;
}
CMD:auto(playerid)
{
//nabídka všech vicí, motor, svitla, alarm, dveoe, kapota, kufr
}

CMD:givecash(playerid, params[])
{
    new pid,money;
	if(sscanf(params, "ii",pid, money)) return SCM(playerid, -1, "ERROR: /givecash <ID> <EIASTKA>");
	if(PlayerInfo[playerid][Money] > 0) return SCM(playerid, -1, "Nemáš dostatok penazí !");
	GivePlayerMoneyEx(pid, money);
    GivePlayerMoneyEx(playerid, -money);
    SCMF(playerid, -1, "Poslal si hráeovy %s[%d] penažnu eiastku v hodnote %d", PlayerName(pid), pid, money);
    //PlayerInfo[playerid][Money] =- money;
	return 1;
}
CMD:pm(playerid, params[])
{
	new pid, message[256+1];
	if(sscanf(params, "ii",pid, message)) return SCM(playerid, -1, "ERROR: /pm <ID> <SPRÁVA>");
	SCMF(pid, -1, "{FF0000}[PM]od: %s[%d]: %s",PlayerName(playerid),playerid, message);
	SCMF(playerid, -1, "{FF0000}[PM]komu: %s[%d]: %s",PlayerName(pid),pid, message);
	return 1;
}
///////////////////////
CMD:kill(playerid)
{
	SetPlayerHealth(playerid, 0);
	return 1;
}
///////////////////////////////
//=====[VIP PRÍKAZY]==========
CMD:vheal(playerid,params[])
{
    if (PlayerInfo[playerid][VIP] >= 1) //POTOM UPRAVIT, ABY TO FUNGOVALO AJ PRO ADMINY
    {
	    SetPlayerHealth(playerid, 100);
        SendClientMessage(playerid, -1, "[{FF0000}!{FFFFFF}] Byl si vyléeen!");
	}
    return 1;
}

CMD:vips(playerid)
{
    new count = 0,string[800];
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if (IsPlayerConnected(i))
        {
            if (PlayerInfo[playerid][VIP] >= 1)
            {
                format(string, sizeof(string), "%s [ID:%i] | VIP Level: %d\n", PlayerName(i),playerid ,PlayerInfo[playerid][VIP]);
                count++;
            }
        }
	}
    if (count == 0) ShowPlayerDialog(playerid, 1000, DIALOG_STYLE_MSGBOX, "VIP Online", "Žádný VIP momentálni nejsou online!", "Zavoít", "");
    else ShowPlayerDialog(playerid, 800, DIALOG_STYLE_MSGBOX, "VIP Online", string, "Zavoít", "");
    return 1;
}
///////////////////////////////
//=====[HRAESKE PRÍKAZY]======
CMD:admins(playerid)
{
    new count = 0, string[600];
	foreach(Player, i)
	{
 		if (PlayerInfo[playerid][Admin] >= 1)
   		{
     		format(string, sizeof(string), "Nick\tID\tAdminLevel\tPozícia\n\%s\t%d\t%d\t%s\n",PlayerName(i), i,GetALevel(i), GetNameALevel(i));
			count++;
   		}
	}
	if (count == 0) InfoBox(playerid, "Zadny admin neni online!", 3);
    else ShowPlayerDialog(playerid, DIALOG_ONLINE_ADMINS, DIALOG_STYLE_TABLIST_HEADERS, "Admins Online", string, "Close", "");
    return 1;
}


CMD:options(playerid) return cmd_nastaveni(playerid);
CMD:settings(playerid) return cmd_nastaveni(playerid);
CMD:nastavenie(playerid) return cmd_nastaveni(playerid);
CMD:nastaveni(playerid)
{
	ShowPlayerDialog(playerid, DIALOG_OPTIONS, DIALOG_STYLE_LIST, "Settings", "Vypnutí TD\nPoložka 2\nPoložka 3", "Select", "Cancel");
	return 1;
}

CMD:pomoc(playerid) return cmd_help(playerid);
CMD:help(playerid)
{
	ShowPlayerDialog(playerid, DIALOG_HELP, DIALOG_STYLE_LIST, "HELP", "Zaeínám\nPráce\nBanka", "Select", "Cancel");
	return 1;
}

CMD:serverinfo(playerid)
{
	ShowPlayerDialog(playerid, DIALOG_SERVERINFO, DIALOG_STYLE_MSGBOX, "SERVER INFO","Autooi módu: Daniels & XpresS\nZaeátek vývoje: 8.4.2017\nVerze: "VERSION"", "Cancel","");
	return 1;
}

CMD:stats(playerid)
{
	SendClientMessage(playerid, -1, "{CC6600}-- STATS --");
	new string[200], str[200];
	format(string, sizeof(string), "{00CCFF}| Jméno: {FFFFFF}%s{00CCFF} || Nahraný eas: {FFFFFF}%dh:%dm:%ds{00CCFF} || Vražd: {FFFFFF}%d{00CCFF} || Úmrtí: {FFFFFF}%d{00CCFF} |", PlayerName(playerid), PlayerInfo[playerid][Hour], PlayerInfo[playerid][Min], PlayerInfo[playerid][Sec], PlayerInfo[playerid][Kills], PlayerInfo[playerid][Deaths]);
	SendClientMessage(playerid, -1, string);
	format(str, sizeof(str), "{00CCFF}| Poeet poihlášení: {FFFFFF}%d{00CCFF} || AdminLevel: {FFFFFF}%d{00CCFF} || Level: {FFFFFF}%d{00CCFF} || Exp: {FFFFFF}%d{00CCFF} |", PlayerInfo[playerid][Logins], PlayerInfo[playerid][Admin],PlayerInfo[playerid][Level],PlayerInfo[playerid][Exp]);
	SendClientMessage(playerid, -1, str);
	return 1;
}
CMD:trestani(playerid)
{
	new string[400];
    strcat(string,"===============[ HRAESKE TRESTY ]===============");
	strcat(string,"\n|{00CCFF}| Elek. šokov: {FFFFFF}%d{00CCFF} || Faciek: {FFFFFF}%d{00CCFF} || Samotka: {FFFFFF}%d{00CCFF} || Varovaní: {FFFFFF}%d{00CCFF} |");
	strcat(string,"\n| Vstupov na Event: {FFFFFF}%d{00CCFF} || Dotazov: {FFFFFF}%d{00CCFF} || Admin Väzenie: {FFFFFF}%d{00CCFF} || Zamrazení: {FFFFFF}%d{00CCFF} |");
	strcat(string,"\n| Vykopnutí: {FFFFFF}%d{00CCFF} || Admin Respawnov: {FFFFFF}%d{00CCFF} || Admin-Zabití: {FFFFFF}%d{00CCFF} || Explozií: {FFFFFF}%d{00CCFF}");
	strcat(string,"\n| Bany: {FFFFFF}%d{00CCFF} |");
	format(string, sizeof(string), string, PlayerPun[playerid][eSok], PlayerPun[playerid][aSlay],
											PlayerPun[playerid][aVar], PlayerPun[playerid][eEvent], PlayerPun[playerid][dotazy],
											PlayerPun[playerid][aJail], PlayerPun[playerid][aFreeze], PlayerPun[playerid][aKick],
											PlayerPun[playerid][aRespawn], PlayerPun[playerid][aKill], PlayerPun[playerid][aExplode],
											PlayerPun[playerid][aBan]);
	ShowPlayerDialog(playerid, DIALOG_STATS,DIALOG_STYLE_MSGBOX,"STATS", string, "Close","");
	//SCM(playerid, -1, string);
	return 1;
}
CMD:atrestani(playerid)
{
	new string[400];
    strcat(string,"===============[ ADMINSKE TRESTY ]===============");
	strcat(string,"\n|{00CCFF}| Elek. šokov: {FFFFFF}%d{00CCFF} || Faciek: {FFFFFF}%d{00CCFF} || Samotka: {FFFFFF}%d{00CCFF} || Varovaní: {FFFFFF}%d{00CCFF} |");
	strcat(string,"\n| Vstupov na Event: {FFFFFF}%d{00CCFF} || Zodpovedané dotazy: {FFFFFF}%d{00CCFF} || Admin Väzenie: {FFFFFF}%d{00CCFF} || Zamrazení: {FFFFFF}%d{00CCFF} |");
	strcat(string,"\n| Vykopnutí: {FFFFFF}%d{00CCFF} || Admin Respawnov: {FFFFFF}%d{00CCFF} || Admin-Zabití: {FFFFFF}%d{00CCFF} || Explozií: {FFFFFF}%d{00CCFF}");
	strcat(string,"\n| Bany: {FFFFFF}%d{00CCFF} |");
	format(string, sizeof(string), string, AdminPun[playerid][eSok], AdminPun[playerid][aSlay],
											AdminPun[playerid][aVar], AdminPun[playerid][eEvent], AdminPun[playerid][dotazy],
											AdminPun[playerid][aJail], AdminPun[playerid][aFreeze], AdminPun[playerid][aKick],
											AdminPun[playerid][aRespawn], AdminPun[playerid][aKill], AdminPun[playerid][aExplode],
											AdminPun[playerid][aBan]);
	ShowPlayerDialog(playerid, DIALOG_STATS,DIALOG_STYLE_MSGBOX,"STATS", string, "Close","");
	//SCM(playerid, -1, string);
	return 1;
}

CMD:ulozitdata(playerid) return cmd_savedata(playerid);
CMD:savedata(playerid)
{
	if(logged[playerid] == 1)
	{
		SaveData(playerid);
	}
	return 1;
}

CMD:radio(playerid)
{
	ShowPlayerDialog(playerid, DIALOG_RADIO,DIALOG_STYLE_LIST,"RADIO", "{FF0000}VYPNOUT\nEvropa 2 CZ\nSpin\nHip Hop Stage\nFrekvence 1\nImpuls\nFajn North Music\nHelax\nVlastní odkaz", "Select", "Cancel");
	return 1;
}

CMD:infobox(playerid, params[])
{
	new text[34],time;
	if(sscanf(params, "is", time, text)) return SCM(playerid, -1, "/infobox <cas v sek.> <text>");
	InfoBox(playerid, text, time);
	SCMF(playerid, -1, "Text: %s, Eas: %d", text, time);
	return 1;
}


//==============================================
//=============[STOCKS]=========================
stock ConvertToSeconds(years = 0, months = 0, days = 0, hours = 0, minutes = 0, seconds = 0)
{
    new time = 0;
    time += (years * 31536000);
    time += (months * 2592000);
    time += (days * 86400);
    time += (hours * 3600);
    time += (minutes * 60);
    time += seconds;
    return time;
}

stock SendVIPMessage(text[])
{
	for(new vipmsg=0; vipmsg < MAX_PLAYERS; vipmsg++)
 	{
  		if(IsPlayerConnected(adminprm))
  		{
   			if(PlayerInfo[playerid][VIP] > 0)
   			{
       			SCMF(vipmsg, -1, "{FFFF00}[VIP MESSAGE]: {FFFFFF}%s", text);
   			}
  		}
 	}
}
stock SendAdminMessage(text[])
{
	for(new adminprm=0; adminprm < MAX_PLAYERS; adminprm++)
	{
		if(IsPlayerConnected(adminprm))
		{
			if(GetALevel(adminprm) > 0)
			{
			    SCMF(adminprm, -1, "(*)%s", text);
			}
		}
	}
}
stock KickEx(playerid)
{
	SetTimerEx("KickExEx", 800, false, "i", playerid);
	return 1;
}
stock GivePlayerHealth(playerid,Float:Health)
{
	new Float:health; GetPlayerHealth(playerid,health);
	SetPlayerHealth(playerid,health+Health);
	return 1;
}

stock GivePlayerArmour(playerid,Float:Armour)
{
	new Float:armour; GetPlayerHealth(playerid,armour);
	SetPlayerArmour(playerid,armour+Armour);
	return 1;
}

stock GivePlayerScore(playerid,Score)
{
	SetPlayerScore(playerid,GetPlayerScore(playerid)+Score);
}
stock GivePlayerMoneyEx(playerid, money)
{
	OldMoney[playerid] = GetPlayerMoney(playerid);
	NewMoney[playerid] = money;
	GivePlayerScore(playerid, money);
	GivePlayerMoney(playerid, money);
	PlayerInfo[playerid][Money] = money;
}
stock Message(playerid, text[], customup[] = "!")
{
	SCMF(playerid,-1, "{FF0000}[ {FFFFFF}%s{FF0000} ]{FFFFFF} %s",customup, text);
	return 1;
}
stock MessageTA(text[], customup[] = "!")
{
	SCMFTA(-1, "{FF0000}[ {FFFFFF}%s{FF0000} ]{FFFFFF} %s",customup, text);
	return 1;
}
stock GetALevel(playerid)
{
	return  PlayerInfo[playerid][Admin];
}

stock HaveAdmin(playerid)
{
	SendClientMessage(playerid, COLOR_ADMIN, "ERROR: Nemáš dostateený práva na tento poíkaz!");
	return 1;
}
stock IsOnline(playerid)
{
    SendClientMessage(playerid, COLOR_ADMIN, "ERROR: Tento hráe není momentálni online!");
	return 1;
}
stock GetNameALevel(playerid)
{
	new ranka[24+1];
	switch(GetALevel(playerid))
	{
		case 0: ranka = "Hráe";
		case 1: ranka = "Pomocník";
		case 2: ranka = "Moderátor";
		case 3: ranka = "Administrátor";
		case 4: ranka = "Hlavní Administrator";
		case 5: ranka = "Vedení";
		case 6: ranka = "Vedení + RCON";
	}
	return ranka;
}

stock RandomString(data[],size = sizeof(data))
{
    for(new i;i<size;i++) data[i] = RandList[random(sizeof(RandList))];
    data[size] = 0;
    return 1;
}

stock UserPath(playerid)
{
	new string[128];
	format(string,sizeof(string),PATH,PlayerName(playerid));
	return string;
}

stock AdminPunPath(playerid)
{
	new string[128];
  	format(string, sizeof(string), ADMIN_PUNISH, PlayerName(playerid));
	return string;
}
stock PlayerPunPath(playerid)
{
    new string[128];
	format(string, sizeof(string), PLAYER_PUNISH, PlayerName(playerid));
	return string;
}
/*Credits to Dracoblue*/
stock udb_hash(buf[]) {
	new length=strlen(buf);
    new s1 = 1;
    new s2 = 0;
    for (new n=0; n<length; n++)
    {
       s1 = (s1 + buf[n]) % 65521;
       s2 = (s2 + s1)     % 65521;
    }
    return (s2 << 16) + s1;
}

//============================
stock SCMF(playerid,color,string[],{ Float, _ }: ...){
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
SendClientMessage(playerid,color,globalstr);
return true;
}

stock SCMFTA(color,string[],{ Float, _ }: ...){
new len = strlen(string)+1;
new globalstr[256];
new found = 1;
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
SendClientMessageToAll(color,globalstr);
return true;
}

//vracia hodnotu meno cez ID
stock PlayerName(playerid)
{
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid,name,MAX_PLAYER_NAME);
	return name;
}

//Vymazáva character
stock DelChar(tstring[])
{
new ln = strlen(tstring);
if(tstring[ln-2] == '\r')tstring[ln-2] = '\0';
if(tstring[ln-1] == '\n')tstring[ln-1] = '\0';
}


//ei je "text" eíselný
stock IsNumeric(const string[])
{
   new length=strlen(string);
   if (length==0) return false;
   for (new i = 0; i < length; i++)
   {
      if ((string[i] > '9' || string[i] < '0' && string[i]!='-' && string[i]!='+')|| (string[i]=='-' && i!=0)|| (string[i]=='+' && i!=0)) return false;
   }
   if (length==1 && (string[0]=='-' || string[0]=='+')) return false;
   return true;
}

stock CheckRegister(playerid)
{
	if(logged[playerid] == 0)
	{
		if(fexist(UserPath(playerid)))
		{
			LoadUserData(playerid);
			ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT, "LOGIN","Vítej zpátky ve hoe!\n\nZadej prosím své heslo pro potvrzení.", "Zvolit", "Zrušit");
		}
		else
		{
			ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "REGISTER","Vítej ve hoe, nováeku!\n\nZadej prosím své nové heslo!", "Zvolit", "Zrušit");
		}
	}
	return 1;
}
///////////////////////////////by d.wine////////////////

stock WARP(playerid, Float:X, Float:Y, Float:Z, INT=0, VW=0)
{
	new vehicle;
 	vehicle = GetPlayerVehicleID(playerid);
 	if(IsPlayerInAnyVehicle(playerid))
 	{
        SetVehiclePos(vehicle, Float:X, Float:Y, Float:Z);
        SetPlayerPos(playerid, Float:X, Float:Y, Float:Z);
     	SetPlayerInterior(playerid, INT);
     	SetPlayerVirtualWorld(playerid, VW);
        LinkVehicleToInterior(vehicle, INT);
        SetVehicleVirtualWorld(vehicle, VW);
        PutPlayerInVehicle(playerid, vehicle, 0);
 	}
 	else
 	{
     	SetPlayerPos(playerid, Float:X, Float:Y, Float:Z);
     	SetPlayerInterior(playerid, INT);
     	SetPlayerVirtualWorld(playerid, VW);
 	}
 	return 1;
}

stock GetWeekdayNum(day,month,year) //by d.wine
{
        month-=2;
        if(month<=0)
                {
                year--;
                month+=12;
                }
        new cen = year/100;
        year=getrem(year,100);
        new w = day + ((13*month-1)/5) + year + (year/4) + (cen/4) - 2*cen;
        w=getrem(w,7);
        if (w==0) w=7;
        return w-1;
}

getrem(a,b) //get remnant of division
{
        new div = a/b;
        new left = a-b*div;
        return left;
}
///////////////////////////////by d.wine////////////////

stock TextDraw()
{
	//globální textdrawy
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

stock InfoBox(playerid, text[], const time)
{
    TextDrawSetString(InfoBox1, text);
    TextDrawShowForPlayer(playerid, InfoBox0);
    TextDrawShowForPlayer(playerid, InfoBox1);
    TextDrawShowForPlayer(playerid, InfoBox2);
    SetTimerEx("HideInfoBox",time * 1000, false, "i", playerid);

	return 1;
}

stock ChatLog(playerid, text[])
{
	new
	 File:lFile = fopen("logs/Chat.txt", io_append),
	 logData[178],
		year, month, day,
		hour, minute, second;

 	getdate(year, month, day);
	gettime(hour, minute, second);

	format(logData, sizeof(logData),"[%02d/%02d/%04d %02d:%02d:%02d] %s: %s \r\n", day, month, year, hour, minute, second, PlayerName(playerid), text);
	fwrite(lFile, logData);

	fclose(lFile);
	return 1;
}
stock ResetMoney(playerid)
{
	GivePlayerMoney(playerid, -GetPlayerMoney(playerid));
	return 1;
}

stock PlayerTextDraw(playerid)
{
	txtcas = TextDrawCreate(547.0,30.0,"~g~--~r~:~g~--");
    TextDrawLetterSize(Text:txtcas,0.5,1.5);
	TextDrawFont(Text:txtcas,3);
    TextDrawSetShadow(Text:txtcas,0);
	TextDrawSetOutline(Text:txtcas,1);

	Time = TextDrawCreate(615.000000, 30.000000, "11:54:40");
	TextDrawAlignment(Time, 2);
	TextDrawBackgroundColor(Time, 255);
	TextDrawFont(Time, 3);
	TextDrawLetterSize(Time, 0.300000, 1.000000);
    TextDrawColor(Time,COLOR_BRIGHTRED);
	TextDrawSetOutline(Time,0);
	TextDrawSetProportional(Time, 1);
	TextDrawSetShadow(Time, 0);
	TextDrawSetSelectable(Time, 0);

	Date = TextDrawCreate(581.000000, 422.000000, "~w~15/04/2017");
	TextDrawAlignment(Date, 2);
	TextDrawBackgroundColor(Date, 255);
	TextDrawFont(Date, 2);
	TextDrawLetterSize(Date, 0.310000, 1.200000);
	TextDrawColor(Date, -1);
	TextDrawSetOutline(Date, 0);
	TextDrawSetProportional(Date, 1);
	TextDrawSetShadow(Date, 1);
	TextDrawSetSelectable(Date, 0);

    Day = TextDrawCreate(547.0,20.0,"po ut str st pi so ne");
	TextDrawLetterSize(Text:Day,0.2,1.1);
    TextDrawSetShadow(Text:Day,0);
	TextDrawFont(Text:Day,1);
	TextDrawSetOutline(Text:Day,1);

	Liberty_title = TextDrawCreate(478.000000, 4.000000, "~g~LIBERTY");
	TextDrawBackgroundColor(Liberty_title, 255);
	TextDrawFont(Liberty_title, 1);
	TextDrawLetterSize(Liberty_title, 0.420000, 1.400000);
	TextDrawColor(Liberty_title, -1);
	TextDrawSetOutline(Liberty_title, 1);
	TextDrawSetProportional(Liberty_title, 1);
	TextDrawSetSelectable(Liberty_title, 0);

	of_title = TextDrawCreate(533.000000, 6.000000, "~r~of");
	TextDrawBackgroundColor(of_title, 255);
	TextDrawFont(of_title, 1);
	TextDrawLetterSize(of_title, 0.500000, 1.100000);
	TextDrawColor(of_title, -1);
	TextDrawSetOutline(of_title, 1);
	TextDrawSetProportional(of_title, 0);
	TextDrawSetSelectable(of_title, 0);

	SF_title = TextDrawCreate(553.000000, 5.000000, "~g~SAN FIERRO");
	TextDrawBackgroundColor(SF_title, 255);
	TextDrawFont(SF_title, 1);
	TextDrawLetterSize(SF_title, 0.420000, 1.400000);
	TextDrawColor(SF_title, -1);
	TextDrawSetOutline(SF_title, 1);
	TextDrawSetProportional(SF_title, 1);
	TextDrawSetSelectable(SF_title, 0);

	MapLocation[playerid] = TextDrawCreate(88.000000, 419.000000, "BaySide");
	TextDrawAlignment(MapLocation[playerid], 2);
	TextDrawBackgroundColor(MapLocation[playerid], 255);
	TextDrawFont(MapLocation[playerid], 2);
	TextDrawLetterSize(MapLocation[playerid], 0.300000, 1.000000);
	TextDrawColor(MapLocation[playerid], -1);
	TextDrawSetOutline(MapLocation[playerid], 0);
	TextDrawSetProportional(MapLocation[playerid], 1);
	TextDrawSetShadow(MapLocation[playerid], 1);
	TextDrawSetSelectable(MapLocation[playerid], 0);

   	InfoBox0 = TextDrawCreate(20.272369, 177.666595, "usebox");
	TextDrawLetterSize(InfoBox0, 0.000000, -5.177776);
	TextDrawTextSize(InfoBox0, 236.008728, 0.000000);
	TextDrawAlignment(InfoBox0, 1);
	TextDrawColor(InfoBox0, 0);
	TextDrawUseBox(InfoBox0, true);
	TextDrawBoxColor(InfoBox0, 102);
	TextDrawSetShadow(InfoBox0, 0);
	TextDrawSetOutline(InfoBox0, 0);
	TextDrawFont(InfoBox0, 0);

	InfoBox1 = TextDrawCreate(20.615005, 142.916717, "PRO OTEVRENI MENU STISKNI Y!");
	TextDrawLetterSize(InfoBox1, 0.206367, 1.804167);
	TextDrawAlignment(InfoBox1, 1);
	TextDrawColor(InfoBox1, -1);
	TextDrawSetShadow(InfoBox1, 0);
	TextDrawSetOutline(InfoBox1, 1);
	TextDrawBackgroundColor(InfoBox1, 51);
	TextDrawFont(InfoBox1, 2);
	TextDrawSetProportional(InfoBox1, 1);

	InfoBox2 = TextDrawCreate(230.043914, 128.916732, "LD_CHAT:badchat");
	TextDrawLetterSize(InfoBox2, 0.000000, 0.000000);
	TextDrawTextSize(InfoBox2, 18.272354, 20.416667);
	TextDrawAlignment(InfoBox2, 1);
	TextDrawColor(InfoBox2, -1);
	TextDrawSetShadow(InfoBox2, 0);
	TextDrawSetOutline(InfoBox2, 0);
	TextDrawFont(InfoBox2, 4);


	TdSpec0[playerid] = TextDrawCreate(683.230041, 408.666442, "usebox");
	TextDrawLetterSize(TdSpec0[playerid], 0.000000, 7.101691);
	TextDrawTextSize(TdSpec0[playerid], -9.496963, 0.000000);
	TextDrawAlignment(TdSpec0[playerid], 1);
	TextDrawColor(TdSpec0[playerid], 0);
	TextDrawUseBox(TdSpec0[playerid], true);
	TextDrawBoxColor(TdSpec0[playerid], -1378294017);
	TextDrawSetShadow(TdSpec0[playerid], 0);
	TextDrawSetOutline(TdSpec0[playerid], 44);
	TextDrawBackgroundColor(TdSpec0[playerid], -2139062017);
	TextDrawFont(TdSpec0[playerid], 0);
	TextDrawSetProportional(TdSpec0[playerid], 1);

	TdSpec1[playerid] = TextDrawCreate(6.090833, 405.999908, "JMENO: MAX_PLAYER_NAME");
	TextDrawLetterSize(TdSpec1[playerid], 0.260248, 1.424999);
	TextDrawAlignment(TdSpec1[playerid], 1);
	TextDrawColor(TdSpec1[playerid], -65281);
	TextDrawSetShadow(TdSpec1[playerid], 0);
	TextDrawSetOutline(TdSpec1[playerid], 1);
	TextDrawBackgroundColor(TdSpec1[playerid], 51);
	TextDrawFont(TdSpec1[playerid], 2);
	TextDrawSetProportional(TdSpec1[playerid], 1);

	TdSpec2[playerid] = TextDrawCreate(7.496378, 425.249786, "ID: 0");
	TextDrawLetterSize(TdSpec2[playerid], 0.268682, 1.675834);
	TextDrawAlignment(TdSpec2[playerid], 1);
	TextDrawColor(TdSpec2[playerid], -65281);
	TextDrawSetShadow(TdSpec2[playerid], 0);
	TextDrawSetOutline(TdSpec2[playerid], 1);
	TextDrawBackgroundColor(TdSpec2[playerid], 51);
	TextDrawFont(TdSpec2[playerid], 2);
	TextDrawSetProportional(TdSpec2[playerid], 1);

	TdSpec3[playerid] = TextDrawCreate(59.033599, 426.416595, "ADMIN LEVEL: 0");
	TextDrawLetterSize(TdSpec3[playerid], 0.316471, 1.419167);
	TextDrawAlignment(TdSpec3[playerid], 1);
	TextDrawColor(TdSpec3[playerid], -65281);
	TextDrawSetShadow(TdSpec3[playerid], 0);
	TextDrawSetOutline(TdSpec3[playerid], 1);
	TextDrawBackgroundColor(TdSpec3[playerid], 51);
	TextDrawFont(TdSpec3[playerid], 2);
	TextDrawSetProportional(TdSpec3[playerid], 1);

	TdSpec4[playerid] = TextDrawCreate(189.751159, 405.416687, "KICK: 0");
	TextDrawLetterSize(TdSpec4[playerid], 0.306163, 1.331666);
	TextDrawAlignment(TdSpec4[playerid], 1);
	TextDrawColor(TdSpec4[playerid], -65281);
	TextDrawSetShadow(TdSpec4[playerid], 0);
	TextDrawSetOutline(TdSpec4[playerid], 1);
	TextDrawBackgroundColor(TdSpec4[playerid], 51);
	TextDrawFont(TdSpec4[playerid], 2);
	TextDrawSetProportional(TdSpec4[playerid], 1);

	TdSpec5[playerid] = TextDrawCreate(190.219528, 428.166534, "BAN: 0");
	TextDrawLetterSize(TdSpec5[playerid], 0.377847, 1.343334);
	TextDrawAlignment(TdSpec5[playerid], 1);
	TextDrawColor(TdSpec5[playerid], -65281);
	TextDrawSetShadow(TdSpec5[playerid], 0);
	TextDrawSetOutline(TdSpec5[playerid], 1);
	TextDrawBackgroundColor(TdSpec5[playerid], 51);
	TextDrawFont(TdSpec5[playerid], 2);
	TextDrawSetProportional(TdSpec5[playerid], 1);

	TdSpec6[playerid] = TextDrawCreate(266.588714, 405.416625, "NAHRANY CAS: 00h/00m/00s");
	TextDrawLetterSize(TdSpec6[playerid], 0.208711, 1.425000);
	TextDrawAlignment(TdSpec6[playerid], 1);
	TextDrawColor(TdSpec6[playerid], -65281);
	TextDrawSetShadow(TdSpec6[playerid], 0);
	TextDrawSetOutline(TdSpec6[playerid], 1);
	TextDrawBackgroundColor(TdSpec6[playerid], 51);
	TextDrawFont(TdSpec6[playerid], 2);
	TextDrawSetProportional(TdSpec6[playerid], 1);

	TdSpec7[playerid] = TextDrawCreate(263.308746, 427.582916, "Interier: 0");
	TextDrawLetterSize(TdSpec7[playerid], 0.363792, 1.325833);
	TextDrawAlignment(TdSpec7[playerid], 1);
	TextDrawColor(TdSpec7[playerid], -65281);
	TextDrawSetShadow(TdSpec7[playerid], 0);
	TextDrawSetOutline(TdSpec7[playerid], 1);
	TextDrawBackgroundColor(TdSpec7[playerid], 51);
	TextDrawFont(TdSpec7[playerid], 2);
	TextDrawSetProportional(TdSpec7[playerid], 1);

	TdSpec8[playerid] = TextDrawCreate(363.103973, 428.166748, "VirtualWorld: 0");
	TextDrawLetterSize(TdSpec8[playerid], 0.339428, 1.249999);
	TextDrawAlignment(TdSpec8[playerid], 1);
	TextDrawColor(TdSpec8[playerid], -65281);
	TextDrawSetShadow(TdSpec8[playerid], 0);
	TextDrawSetOutline(TdSpec8[playerid], 1);
	TextDrawBackgroundColor(TdSpec8[playerid], 51);
	TextDrawFont(TdSpec8[playerid], 2);
	TextDrawSetProportional(TdSpec8[playerid], 1);

	TdSpec9[playerid] = TextDrawCreate(411.830291, 404.833404, "ZABITI: 0");
	TextDrawLetterSize(TdSpec9[playerid], 0.336149, 1.296666);
	TextDrawAlignment(TdSpec9[playerid], 1);
	TextDrawColor(TdSpec9[playerid], -65281);
	TextDrawSetShadow(TdSpec9[playerid], 0);
	TextDrawSetOutline(TdSpec9[playerid], 1);
	TextDrawBackgroundColor(TdSpec9[playerid], 51);
	TextDrawFont(TdSpec9[playerid], 2);
	TextDrawSetProportional(TdSpec9[playerid], 1);

	TdSpec10[playerid] = TextDrawCreate(514.905151, 404.249816, "UMREL: 0");
	TextDrawLetterSize(TdSpec10[playerid], 0.328184, 1.360833);
	TextDrawAlignment(TdSpec10[playerid], 1);
	TextDrawColor(TdSpec10[playerid], -65281);
	TextDrawSetShadow(TdSpec10[playerid], 0);
	TextDrawSetOutline(TdSpec10[playerid], 1);
	TextDrawBackgroundColor(TdSpec10[playerid], 51);
	TextDrawFont(TdSpec10[playerid], 2);
	TextDrawSetProportional(TdSpec10[playerid], 1);

	TdSpec11[playerid] = TextDrawCreate(500.381347, 434.583557, "PENIZE: 0 000 000$");
	TextDrawLetterSize(TdSpec11[playerid], 0.262122, 1.121666);
	TextDrawAlignment(TdSpec11[playerid], 1);
	TextDrawColor(TdSpec11[playerid], -65281);
	TextDrawSetShadow(TdSpec11[playerid], 0);
	TextDrawSetOutline(TdSpec11[playerid], 1);
	TextDrawBackgroundColor(TdSpec11[playerid], 51);
	TextDrawFont(TdSpec11[playerid], 2);
	TextDrawSetProportional(TdSpec11[playerid], 1);

	TdSpec12[playerid] = TextDrawCreate(500.849060, 422.333404, "BANKA: 000 000 000$");
	TextDrawLetterSize(TdSpec12[playerid], 0.196998, 1.267499);
	TextDrawAlignment(TdSpec12[playerid], 1);
	TextDrawColor(TdSpec12[playerid], -65281);
	TextDrawSetShadow(TdSpec12[playerid], 0);
	TextDrawSetOutline(TdSpec12[playerid], 1);
	TextDrawBackgroundColor(TdSpec12[playerid], 51);
	TextDrawFont(TdSpec12[playerid], 2);
	TextDrawSetProportional(TdSpec12[playerid], 1);

	TdSpec13[playerid] = TextDrawCreate(591.742492, 404.250305, "HP: 100");
	TextDrawLetterSize(TdSpec13[playerid], 0.295388, 1.133333);
	TextDrawAlignment(TdSpec13[playerid], 1);
	TextDrawColor(TdSpec13[playerid], -65281);
	TextDrawSetShadow(TdSpec13[playerid], 0);
	TextDrawSetOutline(TdSpec13[playerid], 1);
	TextDrawBackgroundColor(TdSpec13[playerid], 51);
	TextDrawFont(TdSpec13[playerid], 2);
	TextDrawSetProportional(TdSpec13[playerid], 1);

	TdSpec14[playerid] = TextDrawCreate(590.805480, 412.416748, "ARMOUR: 100");
	TextDrawLetterSize(TdSpec14[playerid], 0.171229, 1.395834);
	TextDrawAlignment(TdSpec14[playerid], 1);
	TextDrawColor(TdSpec14[playerid], -65281);
	TextDrawSetShadow(TdSpec14[playerid], 0);
	TextDrawSetOutline(TdSpec14[playerid], 1);
	TextDrawBackgroundColor(TdSpec14[playerid], 51);
	TextDrawFont(TdSpec14[playerid], 2);
	TextDrawSetProportional(TdSpec14[playerid], 1);

	speedometer[playerid] = TextDrawCreate(250.658584, 361.083312, "speedometer");
	TextDrawLetterSize(speedometer[playerid], 0.449999, 1.600000);
	TextDrawAlignment(speedometer[playerid], 1);
	TextDrawColor(speedometer[playerid], -1);
	TextDrawSetShadow(speedometer[playerid], 0);
	TextDrawSetOutline(speedometer[playerid], 1);
	TextDrawBackgroundColor(speedometer[playerid], 51);
	TextDrawFont(speedometer[playerid], 2);
	TextDrawSetProportional(speedometer[playerid], 1);

	usbox[playerid] = TextDrawCreate(254.532943, 387.666687, "usebox");
	TextDrawLetterSize(usbox[playerid], 0.000000, -1.418520);
	TextDrawTextSize(usbox[playerid], 384.061462, 0.000000);
	TextDrawAlignment(usbox[playerid], 1);
	TextDrawColor(usbox[playerid], 0);
	TextDrawUseBox(usbox[playerid], true);
	TextDrawBoxColor(usbox[playerid], -16776961);
	TextDrawSetShadow(usbox[playerid], 0);
	TextDrawSetOutline(usbox[playerid], 0);
	TextDrawFont(usbox[playerid], 0);

	VehicleName[playerid] = TextDrawCreate(249.721817, 397.249877, "VEH_NAME");
	TextDrawLetterSize(VehicleName[playerid], 0.449999, 1.600000);
	TextDrawAlignment(VehicleName[playerid], 1);
	TextDrawColor(VehicleName[playerid], -65281);
	TextDrawSetShadow(VehicleName[playerid], 0);
	TextDrawSetOutline(VehicleName[playerid], 1);
	TextDrawBackgroundColor(VehicleName[playerid], 51);
	TextDrawFont(VehicleName[playerid], 1);
	TextDrawSetProportional(VehicleName[playerid], 1);

	kmh[playerid] = TextDrawCreate(324.216644, 379.749908, "000 KM/H");
	TextDrawLetterSize(kmh[playerid], 0.384406, 3.641666);
	TextDrawAlignment(kmh[playerid], 1);
	TextDrawColor(kmh[playerid], -1523963137);
	TextDrawSetShadow(kmh[playerid], 0);
	TextDrawSetOutline(kmh[playerid], 1);
	TextDrawBackgroundColor(kmh[playerid], 51);
	TextDrawFont(kmh[playerid], 1);
	TextDrawSetProportional(kmh[playerid], 1);

	usebox2[playerid] = TextDrawCreate(252.658859, 420.916687, "usebox");
	TextDrawLetterSize(usebox2[playerid], 0.000000, -1.094444);
	TextDrawTextSize(usebox2[playerid], 382.655914, 0.000000);
	TextDrawAlignment(usebox2[playerid], 1);
	TextDrawColor(usebox2[playerid], 0);
	TextDrawUseBox(usebox2[playerid], true);
	TextDrawBoxColor(usebox2[playerid], -16776961);
	TextDrawSetShadow(usebox2[playerid], 0);
	TextDrawSetOutline(usebox2[playerid], 0);
	TextDrawFont(usebox2[playerid], 0);
}


stock LevelUp(playerid)
{
	if(PlayerInfo[playerid][EXP] > 1000)
	{
	    PlayerInfo[playerid][Level] ++;
	    PlayerInfo[playerid][Exp] = 0;
	    GivePlayerMoney(playerid, 50000);
	    SCMF(playerid, -1, "[ "COL_RED" ! "COL_WHITE" ] Úspišni si dosáhnul levelu "COL_RED"%d"COL_WHTE"!",PlayerInfo[playerid][level);
	}
}



stock CashBoxPATH(playerid)
{
	new string[128];
	format(string,sizeof(string),CPATH,PlayerName(playerid));
	return string;
}

stock GetAlevel(playerid)
{
	return PlayerInfo[playerid][Admin];
}


/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
//=====[ADMIN PRÍKAZY]======

CMD:goto(playerid, params[])
{
	if(GetALevel(playerid) >= 1 || IsPlayerAdmin(playerid))
	{
		new string[256],pid, Float:pos[3];
		if(sscanf(params, "u",pid)) return InfoBox(playerid, "SYNTAX: /goto <ID>", 7);
		if(IsPlayerConnected(pid)) return IsOnline(playerid);
		GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
		WARP(playerid, pos[0], pos[1], pos[2], GetPlayerInterior(pid), GetPlayerVirtualWorld(pid));

		format(string, sizeof(string), "Administrátor %s[%d] sa portól na hráea %s[%d]",PlayerName(playerid),playerid, PlayerName(pid), pid);
		MessageTA(string);
	}else{
        HaveAdmin(playerid);
	}
	return 1;
}
new Float:Sx,Float:Sy,Float:Sz;
CMD:spec(playerid, params[])
{
	if(GetALevel(playerid) >= 1 || IsPlayerAdmin(playerid))
	{
		new pid, string[256];
	    if(sscanf(params, "u", pid)) return InfoBox(playerid, "SYNTAX: /spec <ID>", 7);
	    if(pid == playerid || pid == INVALID_PLAYER_ID) return IsOnline(playerid);

		format(string, sizeof(string), "Administrátor %s(%d) zaeal pozorova? hráea %s(%d)",PlayerName(playerid),playerid,PlayerName(pid),pid);
		SendAdminMessage(string);
		GetPlayerPos(playerid, Sx,Sy,Sz);

		TogglePlayerSpectating(playerid, 1);
	    PlayerSpectatePlayer(playerid, pid);
	    SetPVarInt(playerid, "specID", pid);

		TextDrawShowForPlayer(playerid, TdSpec0[playerid]);
	    TextDrawShowForPlayer(playerid, TdSpec1[playerid]);
	    TextDrawShowForPlayer(playerid, TdSpec2[playerid]);
	    TextDrawShowForPlayer(playerid, TdSpec3[playerid]);
	    TextDrawShowForPlayer(playerid, TdSpec4[playerid]);
	    TextDrawShowForPlayer(playerid, TdSpec5[playerid]);
	    TextDrawShowForPlayer(playerid, TdSpec6[playerid]);
	    TextDrawShowForPlayer(playerid, TdSpec7[playerid]);
	    TextDrawShowForPlayer(playerid, TdSpec8[playerid]);
	    TextDrawShowForPlayer(playerid, TdSpec9[playerid]);
	    TextDrawShowForPlayer(playerid, TdSpec10[playerid]);
	    TextDrawShowForPlayer(playerid, TdSpec11[playerid]);
	    TextDrawShowForPlayer(playerid, TdSpec12[playerid]);
	    TextDrawShowForPlayer(playerid, TdSpec13[playerid]);
	    TextDrawShowForPlayer(playerid, TdSpec14[playerid]);
	    //HIDE

	    TextDrawHideForPlayer(playerid,Day),
	    TextDrawHideForPlayer(playerid,Liberty_title),
	    TextDrawHideForPlayer(playerid,of_title),
	    TextDrawHideForPlayer(playerid,SF_title),
	    TextDrawHideForPlayer(playerid,Time),
	    TextDrawHideForPlayer(playerid,txtcas),
	 	TextDrawHideForPlayer(playerid,Date);

		SpecInfo[pid] = SetTimerEx("SetSpecInfo",500, true, "ii", playerid, pid);
	}else{
	HaveAdmin(playerid);
	}
	return 1;
}

CMD:specoff(playerid, params[])
{
    if(GetALevel(playerid) >= 1 || IsPlayerAdmin(playerid))
	{
	    TogglePlayerSpectating(playerid, 0);

	    TextDrawHideForPlayer(playerid, TdSpec0[playerid]);
	    TextDrawHideForPlayer(playerid, TdSpec1[playerid]);
	    TextDrawHideForPlayer(playerid, TdSpec2[playerid]);
	    TextDrawHideForPlayer(playerid, TdSpec3[playerid]);
	    TextDrawHideForPlayer(playerid, TdSpec4[playerid]);
	    TextDrawHideForPlayer(playerid, TdSpec5[playerid]);
	    TextDrawHideForPlayer(playerid, TdSpec6[playerid]);
	    TextDrawHideForPlayer(playerid, TdSpec7[playerid]);
	    TextDrawHideForPlayer(playerid, TdSpec8[playerid]);
	    TextDrawHideForPlayer(playerid, TdSpec9[playerid]);
	    TextDrawHideForPlayer(playerid, TdSpec10[playerid]);
	    TextDrawHideForPlayer(playerid, TdSpec11[playerid]);
	    TextDrawHideForPlayer(playerid, TdSpec12[playerid]);
	    TextDrawHideForPlayer(playerid, TdSpec13[playerid]);
	    TextDrawHideForPlayer(playerid, TdSpec14[playerid]);
		//SHOW
		TextDrawShowForPlayer(playerid, Liberty_title),
		TextDrawShowForPlayer(playerid, of_title),
		TextDrawShowForPlayer(playerid, SF_title),
	    TextDrawShowForPlayer(playerid,Day),
	    TextDrawShowForPlayer(playerid,Time),
	    TextDrawShowForPlayer(playerid,txtcas),
	 	TextDrawShowForPlayer(playerid,Date);

	 	KillTimer(SpecInfo[GetPVarInt(playerid, "specID")]);
	 	SetPlayerPos(playerid, Sx,Sy,Sz);
	}else{
		HaveAdmin(playerid);
	}
	return 1;
}

CMD:facka(playerid, params[])
{
    if(GetALevel(playerid) >= 1 || IsPlayerAdmin(playerid))
    {
		new pid,reason[256],Float:pos[3],string[256];
		if(sscanf(params, "is", pid, reason)) return InfoBox(playerid, "SYNTAX: /facka <ID> <DOVOD>", 7);
		if(pid == INVALID_PLAYER_ID) return IsOnline(playerid);
		if(!IsPlayerConnected(pid))  return IsOnline(playerid);

		AdminPun[playerid][aSlay]++;
		PlayerPun[id][aSlay]++;

		GivePlayerHealth(playerid, -10);
		GetPlayerPos(playerid, pos[0],pos[1],pos[2]);
		SetPlayerPos(playerid, pos[0],pos[1]+10,pos[2]);
		format(string, sizeof(string), "Administrátor %s(%d) dal facku hráeovy %s(%d) za %s",PlayerName(playerid), playerid, PlayerName(pid),pid, reason);
		//SCMFTA(COLOR_ADMIN, "{FF0000}[ ! ] {FFFFFF}Administrátor %s(%d) dal facku hráeovy %s(%d) za %s",PlayerName(playerid), playerid, PlayerName(pid),pid, reason);
		MessageTA(string);
	}else{
        HaveAdmin(playerid);
	}
	return 1;
}

CMD:samotka(playerid, params[])
{
    if(GetALevel(playerid) >=1 || IsPlayerAdmin(playerid))
	{
		new pid, reason[256];
		if(sscanf(params, "is", pid, reason)) return InfoBox(playerid, "SYNTAX: /samotka <id> <reason>", 7);
		if(pid == INVALID_PLAYER_ID) return IsOnline(playerid);
		if(!IsPlayerConnected(pid)) return IsOnline(playerid);

		AdminPun[playerid][aSamotka]++;
		PlayerPun[pid][aSamotka]++;

		new string[256];
		format(string, sizeof(string), "Administrator %s[%d] dal facku %s[%d] za %s", PlayerName(playerid),playerid,PlayerName(pid), pid, reason);
		MessageTA(string);
	}else{
        HaveAdmin(playerid);
	}
	return 1;
}

CMD:var(playerid, params[])
{
    if(GetALevel(playerid) >=1 || IsPlayerAdmin(playerid))
	{
		new pid, reason[256];
		if(sscanf(params, "is", pid, reason)) return InfoBox(playerid, "SYNTAX: /var <id> <reason>", 7);
		if(pid == INVALID_PLAYER_ID) return IsOnline(playerid);
		if(!IsPlayerConnected(pid)) return IsOnline(playerid);

		AdminPun[playerid][aVar]++;
		PlayerPun[pid][aVar]++;

		new string[256];
		format(string, sizeof(string), "Administrator %s[%d] varoval hráea %s[%d], %d/3 za %s", PlayerName(playerid),playerid,PlayerName(pid), pid, PlayerPun[pid][aVar], reason);
		MessageTA(string);

		if(PlayerPun[id][aVar] == 3)
		{
			SCMF(playerid, -1, "Server vyhodil hráea %s[%d] za 3/3 varaovania !",PlayerName(pid), pid);
			KickEx(playerid);
		}
	}else{
        HaveAdmin(playerid);
	}
	return 1;
}
CMD:ahelp(playerid)
{
	if(GetALevel(playerid == 0)) { HaveAdmin(playerid); }
	if(GetALevel(playerid >= 1)) { Message(playerid, "/goto /spec /specoff /facka /samotka /var /ahelp /say /cevent /esok //ADMINCHAT @VIPCHAT /dotazy /dotazr", "LVL 1"); }
	if(GetALevel(playerid >= 2)) { Message(playerid, "/ajail /freeze /unfreeze /var /get /heal /healr /cc /eject /setdrunk", "LVL 2"); }
	if(GetALevel(playerid >= 3)) { Message(playerid, "/kick /respawn /aflip /akill /carcolor /explode /setwtime /alock /aunlock", "LVL 3"); }
	if(GetALevel(playerid >= 4)) { Message(playerid, "/aban /ipban /ip /unban /car /setskin /crash /saveall /setvhealth /gwl /swl", "LVL 4"); }
	if(GetALevel(playerid >= 5)) { Message(playerid, "/pban /log /connections /avar /savar /setlvl /gcar /rcar /gmx /respawncar", "LVL 5"); }
	if(GetALevel(playerid >= 6)) { Message(playerid, "/god /setinterior /setpos /loadpos /setvw /jetpack /hydra", "LVL 6"); }
	return 1;
}
CMD:say(playerid, params[])
{
    if(GetALevel(playerid) >=1 || IsPlayerAdmin(playerid))
	{
	    new string[256], check;
		if(sscanf(params, "si", string,check)) return InfoBox(playerid, "/say <TEXT> <ZOBRAZENIE MENA 0/1>", 7);
		if(check == 1)
		{
		    SCMFTA(-1, "{FF0000}* Admin: {FF0000}%s", string);
		}else{
            SCMFTA(-1, "{FF0000}* Admin %s(%d): {FF0000}%s",PlayerName(playerid),playerid, string);
		}
	}else{
        HaveAdmin(playerid);
	}
	return 1;
}
CMD:cevent(playerid)
{
	Message(playerid, "DOROBI?"); //DOROBIT
	return 1;
}

CMD:esok(playerid, params[])
{
	if(GetALevel(playerid) >=1 || IsPlayerAdmin(playerid))
	{
		new pid,reason[256];
		if(sscanf(params, "is", pid, reason)) return InfoBox(playerid, "SYNTAX: /esok <ID> <DOVOD>", 7);
		if(pid == INVALID_PLAYER_ID) return IsOnline(playerid);
		if(!IsPlayerConnected(pid)) return IsOnline(playerid);

		AdminPun[playerid][eSok]++;
		PlayerPun[id][eSok]++;

		GivePlayerHealth(playerid, -10);
		ApplyAnimation(playerid,"CRACK","crckdeth2",4.1,1,1,1,7,1);

		new string[256];
		format(string, sizeof(string), "Administrátor %s(%d) dal facku hráeovy %s(%d) za %s",PlayerName(playerid), playerid, PlayerName(pid),pid, reason);
		MessageTA(string);
	}else{
        HaveAdmin(playerid);
	}
	return 1;
}

//ADMINCHAT / VIPCHAT Dotazy a dotazr dorobi?
CMD:ajail(playerid, params[])
{
    if(GetALevel(playerid) >= 2 || IsPlayerAdmin(playerid))
	{
	    new pid, reason[50], time;
		if(sscanf(params, "uis",pid, time, reason)) return InfoBox(playerid, "/ajail <ID> <TIME v sek> <DOVOD>",7);
		MessageTA("test");
	}else{
		HaveAdmin(playerid);
	}
	return 1;
}

CMD:setvip(playerid,params[])
{
    if(GetALevel(playerid) >= 1 || IsPlayerAdmin(playerid))
    {
        new pid, level, str[128], days;
        if (sscanf(params, "uii", pid, level, days)) return InfoBox(playerid, "SYNTAX: /setvip <id> <0-2> <dny>",7);
        if (!IsPlayerConnected(pid)) return IsOnline(playerid);
        if(!(0 <= level <= 2)) return InfoBox(playerid, "SYNTAX: /setvip <id> <0-2> <dny>",7);

		new viptime = (gettime() + ConvertToSeconds(.days = days));

        PlayerInfo[pid][VIP] = level;
        PlayerInfo[pid][CasVIP] = viptime;

        format(str, 128, "{FF0000}[ {FF0000}!{FFFFFF}] Nastavil jsi %s  {FFFF00}VIP {FFFFFF} level na {FF0000}%d{FFFFFF}!", PlayerName(id), level);
        Message(playerid, str);
        format(str, 128, "{FF0000}[ {FF0000}!{FFFFFF}] Administrátor %s ti nastavil {FFFF00}VIP {FFFFFF} na level {FF0000}%d{FFFFFF}!", PlayerName(playerid), level);
        Message(pid, str);
        SaveData(pid);
        return 1;
    }else{
		HaveAdmin(playerid);
	}
	return 1;
}

CMD:setlevel(playerid, params[])
{
	if(PlayerInfo[playerid][Admin] >= 6 || IsPlayerAdmin(playerid))
 	{
		new pID, slvl;
		if(sscanf(params, "ud", pID,slvl)) return SendClientMessage(playerid, -1, "SYNTAX: /setlevel [id] [0-6]");
		//if(!IsPlayerConnected(pID)) return SendClientMessage(playerid, -1, "ERROR: Tento hráe není pripojený na servery!");
		//if(pID != INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "ERROR: Tento hráe není pripojený na servery!");
		if(!(0 <= slvl <= 6)) return SendClientMessage(playerid, -1, "ERROR: Rozmedzie levelu musí by? 0-6!");
		PlayerInfo[pID][Admin] = slvl;
		SCMFTA(COLOR_ADMIN, "Administrátor %s(%d), nastavil hráeovy %s(%d) Admin-Level: %d", PlayerName(playerid),playerid, PlayerName(pID), pID,slvl);
 	}else{
        SCM(playerid, -1, "{FF0000}Nemáš dostatoené opravnene !");
 	}
	return 1;
}
///////////////////////////////
/*
  PRÍKAZY PRE ADMIN SYSTEM by XpresS
 ALVL 0: /dotaz /report

 ALVL 1: /goto /spec /specoff /slay /samotka /var /ahelp /say /cevent /esok //ADMINCHAT @VIPCHAT /dotazy /dotazr
 ALVL 2: /ajail /freeze /unfreeze /var /get /heal /healr /cc /eject /setdrunk
 ALVL 3: /kick /respawn /aflip /akill /carcolor /explode /setwtime /alock /aunlock
 ALVL 4: /aban /ipban /ip /unban /car /setskin /crash /saveall /setvhealth /gwl /swl
 ALVL 5: /pban /log /connections /avar /savar /setlvl /gcar /rcar /gmx /respawncar
 ALVL 6: /god /setinterior /setpos /loadpos /setvw /jetpack /hydra

        PRÍKAZY PRI EVENTOCH
 ALVL 1: /ghost /ghostr /ghostoff /cevent <- RAZ ZA HODINU max.
                                    Pri založený eventu /ann /dann
 ALVL 2: /setport /setnkzona
 ALVL 3: /gpw /gpwr /disarm
 ALVL 4: /ebody

        PRÍKAZY PRE VIP
 VLVL BRONZ: BANKA;100K HVH @VIPCHAT /vflip /vrepair
 VLVL GOLD: BANKA;250K /vinviisible /vnitro,
 VLVL PLATINUM: BANKA;500K

 *BANKA;XXX == KAŽDY DEN XXX $ do banky *
 **HVH VLASTNI? VIP DOMY
*/


/*

DOKONEENÉ VICI

- Opravit spawn aut u total_vehicles_from_files DOKONEENO - DNLS
- První register = výbir jazyku, po loginu už automaticky jazyk ten který máš. DOKONEENÉ - XpresS
- Poidat místa, kde budou banky, následni tam funkení poíkaz /banka DOKONEENÉ
- Spravi? dynamický systém bánk - DOKONEENÉ XpresS
- Poidat bankomaty, stejné jako banky, akorát ne v interiéru. DOKONEENÉ
- Escape v /banka u stavu, nebo výbiru ei vkladu = zpit do hlavního menu DOKONEENO - XpresS, úprava DNLS
- Základní Admin System rozdilen na skupiny Helper, Moderátor, Administrátor, Hlavní Administrátor, Spolumajitel, Majitel DOKONEENÉ - XpresS
- Exp systém , +10 expu každou odehranou hodinu, za poihlášení 1 exp a za xxx expu další level - DOKONEENO, DNLS
- Level systém napo. 1000 expu = 2 level, 10 000 exp = 3 level atp.. - DOKONEENO, DNLS
- Poidat textdraw easu tvar: (18:52:58), dnu tvar:( PO ÚT ST ET PÁ {BARVA}SO) a data (8.4.2017) - DOKOEENO, DNLS - PREROBI? POZICIU
- Po napsání eehokoliv do chatu se napíše za jméno ID - DOKONEENO, DNLS - DOROBI? Farby hráeov
- Infobox DOKONEENO - TD DNLS, pawno XpresS
- Zaeáteení kamera v connectu DOKONEENO, DNLS
- RÁDIO - DOKONEENO, DNLS
- Zaea? na House systéme (basic) - DOKONEENÉ, DNLS
- Spravi? tachometer - DOKONEENÉ, DNLS
- Dorobi? ukladanie na životy / brnenie, zbraní a skinu - DOKONEENÉ, DNLS - životy a brnenie - OPRAVENE XpresS
- Ve scriptfiles složku logs, kam ukládat CHAT - DOKONEENO, DNLS
- Odpoeet /timer - DOKONEENÝ XpresS
- House System poedilat na pickup (arrow pickup 1318 nebo 1317) - DOKONEENÉ, DANIELS
- VIP System na levely -> Premium , VIP - DOKONEENO, DNLS
- možnost zamknout vozidlo, otevoít kufr a kapotu - DOKOEENÉ, DNLS

Jednotlivé kolonky nemazat, ale zminit NEDOKONEENO na DOKONEENO !!!
*/


