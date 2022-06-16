/*============================================================================================
							[L4D & L4D2] Survivor utilities: Notifications
----------------------------------------------------------------------------------------------
*	Author	:	Eärendil
*	Descrp	:	Adds chat notifications to players when they have a change in their condition
*	Version :	1.0.3
*	Link	:	https://forums.alliedmods.net/showthread.php?t=335683
----------------------------------------------------------------------------------------------
==============================================================================================*/

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <survivorutilities>

#define PLUGIN_VERSION "1.0.3"

#define CHAT_TAG	"\x04[\x05SU\x04] \x01"

ConVar g_hAllow, g_hEnd;

enum
{
	GF_FREEZE,
	GF_TOXIC,
	GF_BLEED,
	GF_EXHAUST
};

public Plugin myinfo =
{
	name = "[L4D & L4D2] Surivor utilities: Notifications",	// Title pending of changes, I haven't found an appropiate name for this
	author = "Eärendil",
	description = "Adds chat notifications to players when they have a change in their condition",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=335683",
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (GetEngineVersion() != Engine_Left4Dead2 && GetEngineVersion() != Engine_Left4Dead)
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2");
		return APLRes_SilentFailure;
	}
	return APLRes_Success;
}

public void OnPluginStart()
{
	// Not adding a convar for version, this is a basic extension of the main plugin
	g_hAllow =		CreateConVar("sm_su_notifications_enable",		"1",		"0 = Plugin Off. 1 = Plugin On.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hEnd =		CreateConVar("sm_su_notification_end",			"1",		"Notify when condition ends. 1 = On, 0 = Off.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	AutoExecConfig(true, "l4d_su_notifications");
}

public Action SU_OnFreeze(int client, float &time)
{
	if( !g_hAllow.BoolValue ) return Plugin_Continue;
	if( !SU_IsFrozen(client) ) // This status will be applied AFTER the native ends, so it checks if the survivor is already frozen
	{
		char sBuffer[] = "You have been frozen.";
		DataPack hPack = new DataPack();
		RequestFrame(GlobalForward_Frame, hPack); // Check one frame after, if the native has been blocked by another plugin, dont print any message
		hPack.WriteCell(GetClientSerial(client)); // Use client serial to prevent errors, thanks to Silvers for pointing that
		hPack.WriteCell(GF_FREEZE);
		hPack.WriteString(sBuffer);
	}
	
	return Plugin_Continue;
}

public Action SU_OnToxic(int client, int &amount)
{
	if( !g_hAllow.BoolValue ) return Plugin_Continue;
	if( !SU_IsToxic(client) )
	{
		char sBuffer[] = "You have been intoxicated. Use pain pills or adrenaline to cure the intoxication.";
		DataPack hPack = new DataPack();
		RequestFrame(GlobalForward_Frame, hPack);
		hPack.WriteCell(GetClientSerial(client));
		hPack.WriteCell(GF_TOXIC);
		hPack.WriteString(sBuffer);
	}
		
	return Plugin_Continue;
}

public Action SU_OnBleed(int client, int &amount)
{
	if( !g_hAllow.BoolValue ) return Plugin_Continue;
	if( !SU_IsBleeding(client) )
	{
		char sBuffer[] = "You are bleeding. Use a medkit to stop the bleed.";
		DataPack hPack = new DataPack();
		RequestFrame(GlobalForward_Frame, hPack);
		hPack.WriteCell(GetClientSerial(client));
		hPack.WriteCell(GF_BLEED);
		hPack.WriteString(sBuffer);
	}	
	
	return Plugin_Continue;
}

public Action SU_OnExhaust(int client)
{
	if( !g_hAllow.BoolValue ) return Plugin_Continue;
	if( !SU_IsExhausted(client) )
	{
		char sBuffer[] = "You are exhausted. Use adrenaline to recover inmediately.";
		DataPack hPack = new DataPack();
		RequestFrame(GlobalForward_Frame, hPack);
		hPack.WriteCell(client);
		hPack.WriteCell(GF_EXHAUST);
		hPack.WriteString(sBuffer);
	}		
	return Plugin_Continue;
}

public void SU_OnFreezeEnd(int client)
{
	if( !g_hAllow.BoolValue || !g_hEnd.BoolValue ) return;
	
	PrintToChat(client, "%s Freeze effect ended.", CHAT_TAG);
}

public void SU_OnToxicEnd(int client)
{
	if( !g_hAllow.BoolValue || !g_hEnd.BoolValue ) return;
	
	PrintToChat(client, "%s Intoxication ended.", CHAT_TAG);
}

public void SU_OnBleedEnd(int client)
{
	if( !g_hAllow.BoolValue || !g_hEnd.BoolValue ) return;
	
	PrintToChat(client, "%s Bleeding ended.", CHAT_TAG);
}

public void SU_OnExhaustEnd(int client)
{
	if( !g_hAllow.BoolValue || !g_hEnd.BoolValue ) return;
	
	PrintToChat(client, "%s Exhaustion ended.", CHAT_TAG);
}

void GlobalForward_Frame(DataPack hPack)
{
	hPack.Reset();
	int client = GetClientFromSerial(hPack.ReadCell());
	int gf_caller = hPack.ReadCell();
	char sOut[128];
	hPack.ReadString(sOut, sizeof(sOut));
	delete hPack;
	// Invalid client, don't print the message
	if( !client ) return;
	switch( gf_caller )
	{
		case GF_FREEZE: 	if( SU_IsFrozen(client) )		PrintToChat(client, "%s %s", CHAT_TAG, sOut);
		case GF_BLEED:		if( SU_IsBleeding(client) )		PrintToChat(client, "%s %s", CHAT_TAG, sOut);
		case GF_TOXIC:		if( SU_IsToxic(client) )		PrintToChat(client, "%s %s", CHAT_TAG, sOut);
		case GF_EXHAUST:	if( SU_IsExhausted(client) )	PrintToChat(client, "%s %s", CHAT_TAG, sOut);
	}
}

/*============================================================================================
									Changelog
----------------------------------------------------------------------------------------------
* 1.0.3 (16-Jun-2022)
		- Datapacks now send ClientSerial instead of raw client number.
		- Strings now have the text assigned when declared instead of using StrCat.
* 1.0.2 (30-Dec-2021)
		- Fixed exhaustion notification not being showed properly.
* 1.0.1	(25-Dec-2021)
		- Fixed missing config file.
* 1.0	(25-Dec-2021)
		- Initial release.
*/
