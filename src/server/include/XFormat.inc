#define SCM SendClientMessage
#define SCMTA SendClientMessageToAll
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