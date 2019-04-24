#include <a_samp>
#include <i-zcmd>
#include <sscanf2>

CMD:kreatedom(playerid)
{
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, -1, "Si admin !");
	SendClientMessage(playerid, -1, "Si admin !");
	return 1;
}
