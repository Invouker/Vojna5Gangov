#include <a_samp>

#include <zcmd>
#include <xFunction>

forward UnFreez(playerid);

#define COLOR_ADMIN 0xFF0000
/* SAMOTKA POZICIA  */
#define SAMOTKA_X 10
#define SAMOTKA_Y 10
#define SAMOTKA_Z 10
/* ---------------- */

#define Version "0.20"

enum pinfo {
	ALvl,
	pMoney,
	pHealth,
	pArmor,
	pCell
}

enum pSamotka {
	lX,
	lZ,
	lY,
	active
}

main() {}

new Samotka[MAX_PLAYERS][pSamotka];
new PlayerInfo[MAX_PLAYERS][pinfo];

stock HaveAdmin(playerid, AdminLevel){
	if(PlayerInfo[playerid][ALvl] >= AdminLevel) return SCM(playerid, COLOR_ADMIN, "[!] Nemáš dostatoèný admin level");
	return 1;
}

stock HaveMoney(playerid, Money){ // Použitie: HaveMoney(playerid, 1000);
	if(PlayerInfo[playerid][pMoney] >= Money) return SCM(playerid, COLOR_ADMIN, "[!] Nemáš dostatok penazí !");
	return 1;
}

public OnGameModeInit() {
	print("\n");
	print("-------------------------------");
	print("  Gamemode:      Life of Prison");
	printf("  Version:          %s", Version);
	print("  Autor:           XpresS");
	print("  SA-MP:           0.3.7");
	print("-------------------------------");
	return 1;
}

public OnGameModeExit() {
	return 1;
}
public OnPlayerConnect(playerid) {
	PlayerInfo[playerid][ALvl] = 0;
	PlayerInfo[playerid][pMoney] = 0;
	PlayerInfo[playerid][pHealth] = 0;
	PlayerInfo[playerid][pArmor] = 0;
	PlayerInfo[playerid][pCell] = 0;
    Samotka[playerid][active] = 0;
	return 1;
}


CMD:samotka(playerid, params[]){
	HaveAdmin(playerid, 1);
	new pid, time, Float:x, Float:z, Float:y;
	//if(sscanf(params, "ud",pid, time )) return SCM(playerid, COLOR_ADMIN, "[!] /samotka <ID> <ÈAS>");
    Samotka[playerid][active] = 1;
    GetPlayerPos(playerid, x,y,z);
    x = Samotka[playerid][lX];
    y = Samotka[playerid][lY];
    z = Samotka[playerid][lZ];
    SetTimerEx("UnFreez", time * 1000, false, "i", playerid);

    SetPlayerPos(playerid, SAMOTKA_X,SAMOTKA_Y,SAMOTKA_Z);
	return 1;
}

public UnFreez(playerid){
	SetPlayerPos(playerid, Samotka[playerid][lX],Samotka[playerid][lY],Samotka[playerid][lZ]);
	SCM(playerid, COLOR_ADMIN,"[!] Bol si prepustený zo samotky");
	return 1;
}
