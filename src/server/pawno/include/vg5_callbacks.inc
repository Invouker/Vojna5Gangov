forward LoadLanguages();
public LoadLanguages()
{
    printf("* Loading MultiLang Module ...");
	InstallLanguage("Slovak","VG/Languages/slovak.lng");
	InstallLanguage("Czech","VG/Languages/czech.lng");
	return 1;
}

