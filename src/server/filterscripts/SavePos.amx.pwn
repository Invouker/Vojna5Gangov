#include <a_samp>
#include <zcmd>
#include <sscanf2>
#include <xFunction>
#include <streamer>

#define STREAMER_TYPE_MAP_ICON (4)


#define MAX_ICON 100
#define STREAM_DISTANCE 300

new MapIcon[MAX_ICON];

CMD:seticon(playerid, params[]){
	if(!IsPlayerAdmin(playerid)) return SCM(playerid, -1, "Niesi Admin");
	new Float:x, Float:y, Float:z, i = 0;
	GetPlayerPos(playerid, x,y,z);
	SCMF(playerid, -1, "Tvoje súradnice sú X:%d, Y: %d, Z: %d", x,y,z);
	//MapIcon[i] = SetPlayerMapIcon(playerid, i, x, y, z, 32, 0, MAPICON_LOCAL);
	//MapIcon[i] = CreateStreamedMapIcon(playerid, 52, x, y, z, 52, 0, STREAM_DISTANCE);
	//MapIcon[i] = CreateMapIcon(32, 0, x,y,z);
	CreateDynamicMapIcon(x,y,z, 32, 0, 0,0, playerid);
	CreateDynamicMapIcon(x, y, z, 32, 0, 0, 0, playerid,200, MAPICON_LOCAL, 0,0);
	SCMF(playerid, -1, "MapIcon ID:(%d) bola úspešne vytvorená", i);
	//
	i++;
	return 1;
}
CMD:delicon(playerid, params[]){
    if(!IsPlayerAdmin(playerid)) return SCM(playerid, -1, "Niesi Admin");
	new id;
	if(sscanf(params, "d", id)) return SCM(playerid, -1, "/delicon <IDICON>");
    //RemovePlayerMapIcon(playerid, MapIcon[id]);
    DestroyDynamicMapIcon(MapIcon[id]);
	SCMF(playerid, -1, "Ikonka %d bola vymazaná", id);
	return 1;
}
CMD:delallicon(playerid, params[]){
    if(!IsPlayerAdmin(playerid)) return SCM(playerid, -1, "Niesi Admin");
	for(new id; id < MAX_ICON; id++)
	{
		DestroyDynamicMapIcon(MapIcon[id]);
	}
	SCMF(playerid, -1, "Všetký ikonky boli vymazané (MAX:%d)", MAX_ICON);
	return 1;
}



