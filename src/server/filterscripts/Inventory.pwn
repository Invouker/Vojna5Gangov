#include <a_samp>
#include <sscanf2>
#include <i-zcmd>
#define INV_DIALOG_ID 13337
#define MAX_ITEMS 7
#define MAX_ITEM_STACK 10
#define MAX_ITEM_NAME 24

#define INVENTORY_PATH "Inventory/%s.inv"

forward OnPlayerUseItem(playerid,ItemName[]);

new gItemList[(MAX_ITEMS+1)*(MAX_ITEM_NAME+3)];

CMD:additem(playerid, params[])
{
	new name[MAX_ITEM_NAME], count;
	if(sscanf(params,"si",name,count)) return SendClientMessage(playerid, -1, "/additem <NAZOV> <POÈET>");
	GiveItem(playerid, name, count);
	return 1;
}
CMD:inv(playerid)
{
	ShowInventory(playerid);
	return 1;
}
CMD:inventar(playerid)
{
	return cmd_inv(playerid);
}

stock GetItemNamePVar(playerid,item)
{
	new tmp[32];
	new tmp2[MAX_ITEM_NAME];
	format(tmp,32,"NAZOV%d",item);
	GetPVarString(playerid,tmp,tmp2,MAX_ITEM_NAME);
	return tmp2;
}
stock SetItemNamePVar(playerid,item,ItemName[])
{
	new tmp[MAX_ITEM_NAME];
	format(tmp,MAX_ITEM_NAME,"NAZOV%d",item);
	SetPVarString(playerid,tmp,ItemName);
}
stock GetItemAmountPVar(playerid,item)
{
	new tmp[16];
	format(tmp,16,"POCET%d",item);
	return GetPVarInt(playerid,tmp);
}
stock SetItemAmountPVar(playerid,item,Amount)
{
	new tmp[16];
	format(tmp,16,"POCET%d",item);
	SetPVarInt(playerid,tmp,Amount);
}
stock GiveItem(playerid,ItemName[],Amount)
{
	new slot=-1;
	for(new item;item<MAX_ITEMS;item++)
	{
		if(!GetItemAmountPVar(playerid,item))
		{
			if(slot==-1)slot=item;
			continue;
		}
		if(!strcmp(GetItemNamePVar(playerid,item),ItemName,true))
		{
			SetItemAmountPVar(playerid,item,GetItemAmountPVar(playerid,item)+Amount);
			if(GetItemAmountPVar(playerid,item)<=0)SetItemAmountPVar(playerid,item,0);
			if(GetItemAmountPVar(playerid,item)>MAX_ITEM_STACK)
			{
				SetItemAmountPVar(playerid,item,MAX_ITEM_STACK);
				return 2;
			}
			return 1;
		}
	}
	if(slot>-1)
	{
		SetItemNamePVar(playerid,slot,ItemName);
		SetItemAmountPVar(playerid,slot,Amount);
		if(GetItemAmountPVar(playerid,slot)>MAX_ITEM_STACK)
		{
			SetItemAmountPVar(playerid,slot,MAX_ITEM_STACK);
			return 2;
		}
		return 1;
	}
	return 0;
}
stock RemoveItem(playerid,ItemName[],Amount)
{
	for(new item;item<MAX_ITEMS;item++)
	{
		if(!GetItemAmountPVar(playerid,item))continue;
		if(!strcmp(GetItemNamePVar(playerid,item),ItemName,true))
		{
			SetItemAmountPVar(playerid,item,GetItemAmountPVar(playerid,item)-Amount);
			if(GetItemAmountPVar(playerid,item)<=0)SetItemAmountPVar(playerid,item,0);
			if(GetItemAmountPVar(playerid,item)>MAX_ITEM_STACK)
			{
				SetItemAmountPVar(playerid,item,MAX_ITEM_STACK);
				return 2;
			}
			return 1;
		}
	}
	return 0;
}
stock PlayerHasItem(playerid,ItemName[])
{
	for(new item;item<MAX_ITEMS;item++)
	{
		if(!GetItemAmountPVar(playerid,item))continue;
		if(!strcmp(GetItemNamePVar(playerid,item),ItemName,false))return GetItemAmountPVar(playerid,item);
	}
	return 0;
}
stock GetPlayerItemInfo(playerid,&idx,ItemName[],len=sizeof(ItemName),&Amount)
{
	if(idx>=MAX_ITEMS)return 0;
	format(ItemName,len,GetItemNamePVar(playerid,idx));
	Amount=GetItemAmountPVar(playerid,idx);
	idx++;
	return 1;
}
stock ResetPlayerInventory(playerid)
{
	for(new item;item<MAX_ITEMS;item++)SetItemAmountPVar(playerid,item,0);
}
stock ShowInventory(playerid)
{
	gItemList="";
	for(new item;item<MAX_ITEMS;item++)
	{
		if(!strlen(GetItemNamePVar(playerid,item))||!GetItemAmountPVar(playerid,item))continue;
		format(gItemList,sizeof(gItemList),"%s\n%d\t\t%s",gItemList,GetItemAmountPVar(playerid,item),GetItemNamePVar(playerid,item));
	}
	format(gItemList,sizeof(gItemList),"Poèet\t\tNázov%s",gItemList);
	ShowPlayerDialog(playerid,INV_DIALOG_ID,DIALOG_STYLE_LIST,"Inventory",gItemList,"Použi","Zatvori");
	SetPVarInt(playerid,"PUSINGDIALOG",1);
}
stock SaveInventory(playerid)
{
	gItemList=" ";
	new File:file=fopen(InvPath(playerid),io_write);
	for(new item;item<MAX_ITEMS;item++)
	{
		if(!strlen(GetItemNamePVar(playerid,item))||!GetItemAmountPVar(playerid,item))continue;
		format(gItemList,sizeof(gItemList),"%s%s\n%d\n",gItemList,GetItemNamePVar(playerid,item),GetItemAmountPVar(playerid,item));
	}
	fwrite(file,gItemList);
	fclose(file);
}
stock LoadInventory(playerid)
{
	new tstring[48];
	new tstring2[12];
	if(!fexist(InvPath(playerid)))return 0;
	new File:file=fopen(InvPath(playerid),io_read);
	fread(file,InvPath(playerid));
	while(tstring[0])
	{
		format(tstring,strlen(tstring),"%s",tstring);
		fread(file,tstring2);
		GiveItem(playerid,tstring,strval(tstring2));
		fread(file,tstring);
	}
	fclose(file);
	return 1;
}
InventoryOnDialogResponse(playerid, dialogid, response, inputtext[])
{
	if(dialogid!=INV_DIALOG_ID)return 1;
	if(!GetPVarInt(playerid,"PUSINGDIALOG"))return 1;
	if(!response)return 1;
	if(!strcmp(inputtext,"Amount",true,6))
	{
		ShowInventory(playerid);
		return 1;
	}
	format(gItemList,MAX_ITEM_NAME,inputtext[strfind(inputtext,"\t")+2]);
	if(CallLocalFunction("OnPlayerUseItem","is",playerid,gItemList))ShowInventory(playerid);
	else SetPVarInt(playerid,"PUSINGDIALOG",0);
	return 1;
}

public OnPlayerConnect(playerid)
{
	ResetPlayerInventory(playerid);
	LoadInventory(playerid);
	return 1;
}
public OnPlayerDisconnect(playerid, reason)
{
	SaveInventory(playerid);
	return 1;
}

stock PlayerName(playerid)
{
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, sizeof(name));
	return name;
}

stock InvPath(playerid)
{
	new string[50];
	format(string, sizeof(string), INVENTORY_PATH,playerid);
	return string;
}
