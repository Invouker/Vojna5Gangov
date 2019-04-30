/* MultiLanguage functions
native 
native _VG_MULTILANG_MODULE_();
native 
native IsValidLanguage(languageid);
native GetLanguageName(languageid);
native GetLanguageFile(languageid);
native GetLanguageId(const Name[]);
native SetPlayerLanguage(playerid,languageid);
native InstallLanguage(LangName[],LangFile[]);
native GetStringFromLangKey(languageid,const key[]);
native GetPlayerLangKey(playerid,const key[]);
native SendClientLangKeyMessageToAll(color,const key[],{Float,_}:...);
*/

#define MAX_LANGUAGES 5//maximalny pocet nacitatelnych jazykovych suborov
#define MAX_LANGKEYS 256//maximalny pocet nacitanych jazykovych klucov zo suboru(kluc=data...)
//#define LANG_SLOVAK 1//id jazyka, jazykoveho identifikatoru
#define GetStringArg(%1,%2) for(new x = 0; getarg(%1,x) != '\0'; x++) %2[x] = getarg(%1,x)


enum langProp {
	langName[24],
	langFile[128]
}
enum langArr {
	keyname[24],
	keydata[128]
}

new langInit[MAX_LANGUAGES][langProp];
new langData[MAX_LANGUAGES][MAX_LANGKEYS][langArr];
new langCount=0;
new playerLang[200];

//Language Module
//native IsValidLanguage(languageid);
stock IsValidLanguage(languageid)
{
	if(strlen(langInit[languageid][langName]) > 0 && strlen(langInit[languageid][langName]) >0 && languageid <= MAX_LANGUAGES) return true;
	return false;
}

//native GetLanguageName(languageid);
stock GetLanguageName(languageid)
	return langInit[languageid][langName];
	
stock GetLanguageFile(languageid)
	return langInit[languageid][langFile];

stock GetLanguageId(const Name[])
{
	new ret = -1;
    for(new l=0;l<MAX_LANGUAGES;l++) {
		    if(strlen(langInit[l][langName]) < 1) break;//koniec nacitanych langs
		    if(!strcmp(langInit[l][langName],Name,false)) ret = l;
	}
	return ret;
}

stock SetPlayerLanguage(playerid,languageid)
{
	if(IsValidLanguage(languageid)) {
    	playerLang[playerid] = languageid;
    	return 1;
	}
	return 0;
}

stock InstallLanguage(LangName[],LangFile[])
{
	new langkeyid = 0,languageid;
	new File: file = fopen(LangFile, io_read);
	if (file)
	{
	    strcpy(langInit[langCount][langName],LangName,24);
	    strcpy(langInit[langCount][langFile],LangFile,128);
	    languageid = langCount;
	    printf("  + Nahravam Lang %s(id:%d) ...",GetLanguageName(languageid),languageid);
		new Line[256],tmpdata[2][128];
		while (fread(file, Line, sizeof(Line) ))
		{
			//new idx;
			StripNewLine(Line);
			if (strlen(Line)!=0)
			{
			    if(langkeyid > MAX_LANGKEYS) {
			        printf("    !>! Jazykovy kluc id %d sa nepodarilo nacitat! Maximum %d klucov je dosiahnute.",langkeyid,MAX_LANGKEYS);
			        printf("    !>! Nacitanie jazyka %s bolo prerusene !",GetLanguageName(languageid));
			        break;
			    } else {
				 	split(Line, tmpdata, '=');//new langData[MAX_LANGUAGES][512][langArr];
				 	strmid(langData[languageid][langkeyid][keyname], tmpdata[0], 0, strlen(tmpdata[0]), 24);
				 	strmid(langData[languageid][langkeyid][keydata], tmpdata[1], 0, strlen(tmpdata[1]), 128);
				 	//printf("    + Lang Key %d = %s s obsahom %s nacitany !",langkeyid,langData[languageid][langkeyid][keyname],langData[languageid][langkeyid][keydata]);
				 	langkeyid++;
				}
			}
		}
		fclose(file);
		printf("   > Pocet platnych jazykovych klucov: %d .",langkeyid-1);
		printf("   > Kluce jazyka %s(id:%d) uspesne nahrane ...",GetLanguageName(languageid),languageid);
		langCount++;
	} else {
        printf(" !>! Jazykovy subor '%s' sa nepodarilo nahrat !",LangFile);
		return false;
	}
	return langCount-1;
}

stock GetStringFromLangKey(languageid,const key[])
{
	new output[128],frmt[128];
	strcpy(output,"LANG_ERROR: UNKNOWN",128);
	if(IsValidLanguage(languageid)) {
		for(new l=0;l<MAX_LANGKEYS;l++) {
		    if(strlen(langData[languageid][l][keyname]) < 1) break;//koniec nacitanych keys
		    if(!strcmp(langData[languageid][l][keyname],key,false)) {//zhoda ?!
		        strcpy(output, langData[languageid][l][keydata], 128);
				break;
			} else {
                format(frmt,sizeof(frmt),"LANG_ERROR: LANG KEY %s NOT FOUND IN LANG %s.",key, GetLanguageName(languageid));
				strcpy(output, frmt, 128);
			}
		}
	} else {
		format(frmt,sizeof(frmt),"LANG_ERROR: LANG ID %d NOT FOUND.",languageid);
		strcpy(output, frmt, 128);
	}
    return output;
}


stock GetPlayerLangKey(playerid,const key[])
{
	new languageid = playerLang[playerid];
	new output[128];
    strcpy(output, GetStringFromLangKey(languageid,key), 128);
    return output;
}

stock SendClientLangKeyMessageToAll(color,const key[],{Float,_}:...)
{
	new arg1[64],arg2[64],arg3[64],arg4[64],arg5[64];
	GetStringArg(2,arg1); GetStringArg(3,arg2); GetStringArg(4,arg3);
	GetStringArg(5,arg4);
	for(new i=0;i<MAX_SLOT;i++)
	    if(IsPlayerConnected(i)) {
	    	new inone[128];
			format(inone,sizeof(inone),GetPlayerLangKey(i,key),arg1,arg2,arg3,arg4,arg5);
			SendClientMessage(i,color,inone);
		}
	return 1;
}

