/*============================================================================================
							[L4D & L4D2] Survivor utilities: Test plugin
----------------------------------------------------------------------------------------------
*	Author	:	Eärendil
*	Descrp	:	Test applying survivor conditions, forwards and natives
*	Link	:	None
----------------------------------------------------------------------------------------------
==============================================================================================*/

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <survivorutilities>

#define PLUGIN_VERSION "1.0"
#define DEBUG 1


public Plugin myinfo =
{
	name = "[L4D & L4D2] Surivor utilities: Test plugin",	// Title pending of changes, I haven't found an appropiate name for this
	author = "Eärendil",
	description = "Test applying survivor conditions, forwards and natives",
	version = PLUGIN_VERSION,
	url = "",
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
	RegAdminCmd("sm_intox",		ADM_Intoxicate, 0);
	RegAdminCmd("sm_bleed",		ADM_Bleed, 0);
	RegAdminCmd("sm_freeze2",	ADM_Freeze, 0);	// Because sm_freeze is a command of sourcemod
	RegAdminCmd("sm_speed",		ADM_Speed, 0);
	RegAdminCmd("sm_exhaust",	ADM_Exhaust, 0);
	RegAdminCmd("sm_survivorstatus", ADM_Info, 0);
}

public Action ADM_Freeze(int client, int args)
{
	if (args < 2)
	{
		ReplyToCommand(client, "[SM] Usage: sm_freeze2 <#userid|name> <time>");
		return Plugin_Handled;
	}

	char arg[65], arg2[16];
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg2));
	float fTime = StringToFloat(arg2);
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
	if( (target_count = ProcessTargetString(arg, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0 )
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for (int i = 0; i < target_count; i++)
	{
		if( GetClientTeam(target_list[i]) != 2 ) return Plugin_Handled;
		SU_AddFreeze(target_list[i], fTime);
	}
	
	if (tn_is_ml)
	{
		ShowActivity2(client, "[SM] Frozen player %s", target_name);
	}
	else
	{
		ShowActivity2(client, "[SM] Frozen player %s", target_name);
	}

	return Plugin_Handled;
}

public Action ADM_Bleed(int client, int args)
{
	if (args < 2)
	{
		ReplyToCommand(client, "[SM] Usage: sm_bleed <#userid|name> <count>");
		return Plugin_Handled;
	}

	char arg[65], arg2[16];
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg));
	int iCount = StringToInt(arg2);
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
	if( (target_count = ProcessTargetString(arg, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0 )
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for (int i = 0; i < target_count; i++)
	{
		if( GetClientTeam(target_list[i]) != 2 ) return Plugin_Handled;
		SU_AddBleed(target_list[i], iCount);
	}

	if (tn_is_ml)
	{
		ShowActivity2(client, "[SM] Bleed player %s", target_name);
	}
	else
	{
		ShowActivity2(client, "[SM] Bleed player %s", "_s", target_name);
	}

	return Plugin_Handled;
}

public Action ADM_Intoxicate(int client, int args)
{
	if( args < 2 )
	{
		ReplyToCommand(client, "[SM] Usage: sm_intoxicate <#userid|name> <count>");
		return Plugin_Handled;
	}

	char arg[65], arg2[16];
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg));
	int iAmount = StringToInt(arg2);

	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
	if( (target_count = ProcessTargetString(arg, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0 )
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for( int i = 0; i < target_count; i++ )
	{
		if( GetClientTeam(target_list[i]) != 2 ) return Plugin_Handled;
		SU_AddToxic(target_list[i], iAmount);
	}
	
	if( tn_is_ml )
	{
		ShowActivity2(client, "[SM] Intoxicated player %s", target_name);
	}
	else
	{
		ShowActivity2(client, "[SM] Intoxicated player %s", "_s", target_name);
	}

	return Plugin_Handled;
}

public Action ADM_Speed(int client, int args)
{
	if( args < 3 )
	{
		ReplyToCommand(client, "[SM] Usage: sm_speed <#userid|name> <speedtype> <amount>");
		return Plugin_Handled;
	}

	char arg[65], arg2[16], arg3[16];
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg));
	GetCmdArg(3, arg3, sizeof(arg3));
	int iSpeedType;
	float fAmount = StringToFloat(arg3);
	
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
	if( (target_count = ProcessTargetString(arg, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0 )
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	if( StrEqual(arg2, "run", false) ) iSpeedType = SPEED_RUN;
	if( StrEqual(arg2, "walk", false) ) iSpeedType = SPEED_WALK;
	if( StrEqual(arg2, "crouch", false) ) iSpeedType = SPEED_CROUCH;
	if( StrEqual(arg2, "limp", false) ) iSpeedType = SPEED_LIMP;
	if( StrEqual(arg2, "critical", false) || StrEqual(arg2, "crit", false) ) iSpeedType = SPEED_CRITICAL;
	if( StrEqual(arg2, "water", false) ) iSpeedType = SPEED_WATER;
	if( StrEqual(arg2, "exhaust", false) ) iSpeedType = SPEED_EXHAUST;
	for( int i = 0; i < target_count; i++ )
	{
		if( GetClientTeam(target_list[i]) != 2 ) return Plugin_Handled;
		SU_SetSpeed(target_list[i], iSpeedType, fAmount);
	}
	
	if( tn_is_ml )
	{
		ReplyToCommand(client, "[SM] Player %s speed changed", target_name);
	}
	else
	{
		ReplyToCommand(client, "[SM] Player %s speed changed", target_name);
	}

	return Plugin_Handled;
}

public Action ADM_Exhaust(int client, int args)
{
	if( args < 2 )
	{
		ReplyToCommand(client, "[SM] Usage: sm_exhaust <#userid|name>");
		return Plugin_Handled;
	}

	char arg[65], arg2[32];
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg2));
	int tokens = StringToInt(arg2);
	ReplyToCommand(client, "Tokens to add: %i", tokens);

	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
	if( (target_count = ProcessTargetString(arg, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0 )
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for( int i = 0; i < target_count; i++ )
	{
		if( GetClientTeam(target_list[i]) != 2 ) return Plugin_Handled;
		SU_AddExhaust(target_list[i], tokens); 
	}
	
	if( tn_is_ml )
	{
		ReplyToCommand(client, "[SM] Player %s exhausted", target_name);
	}
	else
	{
		ReplyToCommand(client, "[SM] Player %s exhausted", target_name);
	}

	return Plugin_Handled;
}

public Action ADM_Info(int client, int args)
{
	if( args < 1 ) ReplyToCommand(client, "Pick a survivor");
	char arg[65];
	GetCmdArg(1, arg, sizeof(arg));

	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
	if( (target_count = ProcessTargetString(arg, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0 )
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	for (int i = 0; i < target_count; i++)
	{
		PrintToConsole(client, "*******************************************************************");
		PrintToConsole(client, "******* Current player info: %N *******", target_list[i]);
		if( SU_IsFrozen(target_list[i]) ) PrintToConsole(client, "******* Survivor is frozen *******");
		else PrintToConsole(client, "******* Survivor isn't frozen *******");
		if( SU_IsBleeding(target_list[i]) ) PrintToConsole(client, "******* Survivor is bleeding *******");
		else PrintToConsole(client, "******* Survivor is not bleeding *******");
		if( SU_IsToxic(target_list[i]) ) PrintToConsole(client, "******* Survivor is intoxicated *******");
		else PrintToConsole(client, "******* Survivor is not intoxicated *******");
		if( SU_IsExhausted(target_list[i]) ) PrintToConsole(client, "******* Survivor is exhausted *******");
		else PrintToConsole(client, "******* Survivor is not exhausted *******");
		PrintToConsole(client, "******* Survivor speeds *******");
		PrintToConsole(client, "*******************************");
		PrintToConsole(client, "** Run speed :%f", SU_GetSpeed(target_list[i], SPEED_RUN));
		PrintToConsole(client, "** Walk speed :%f", SU_GetSpeed(target_list[i], SPEED_WALK));
		PrintToConsole(client, "** Crouch speed :%f", SU_GetSpeed(target_list[i], SPEED_CROUCH));
		PrintToConsole(client, "** Limp speed: %f", SU_GetSpeed(target_list[i], SPEED_LIMP));
		PrintToConsole(client, "** Critical speed :%f", SU_GetSpeed(target_list[i], SPEED_CRITICAL));
		PrintToConsole(client, "** Water speed :%f", SU_GetSpeed(target_list[i], SPEED_WATER));
		PrintToConsole(client, "** Exhaust speed :%f", SU_GetSpeed(target_list[i], SPEED_EXHAUST));
		PrintToConsole(client, "*******************************************************************");
	}
	return Plugin_Handled;
	
}

public Action SU_OnFreeze(int client, float &time)
{
	#if DEBUG
	PrintToServer("******* Survivor frozen *******");
	PrintToServer("** Client %N **  Time %f **", client, time);
	#endif
	return Plugin_Continue;
}

public Action SU_OnBleed(int client, int &amount)
{
	#if DEBUG
	PrintToServer("******* Survivor bleeding *******");
	PrintToServer("** Client %N ** Bleed hits %i **", client, amount);
	#endif
	return Plugin_Continue;
}

public Action SU_OnToxic(int client, int &amount)
{
	#if DEBUG
	PrintToServer("******* Survivor intoxicated *******");
	PrintToServer("** Client %N ** Toxic hits %i **", client, amount);
	#endif
	return Plugin_Continue;
}

public Action SU_OnExhaust(int client)
{
	#if DEBUG
	PrintToServer("******* Survivor exhausted *******");
	PrintToServer("** Client %N **", client);
	#endif
	return Plugin_Continue;
}

public void SU_OnFreezeEnd(int client)
{
	#if DEBUG
	PrintToServer("**** Survivor %N Freeze ended ****", client);
	#endif
}

public void SU_OnBleedEnd(int client)
{
	#if DEBUG
	PrintToServer("**** Survivor %N Bleed ended ****", client);
	#endif
}

public void SU_OnToxicEnt(int client)
{
	#if DEBUG
	PrintToServer("**** Survivor %N Intoxication ended ****", client);
	#endif
}

public void SU_OnExhaustEnd(int client)
{
	#if DEBUG
	PrintToServer("**** Survivor %N Exhaust ended ****", client);
	#endif
}
