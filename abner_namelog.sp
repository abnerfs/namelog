#include <sourcemod>
#include <geoip>
#pragma newdecls required
#pragma semicolon 1
#define PLUGIN_VERSION "1.1"


Handle db = null;

public Plugin myinfo =
{
	name = "[ANY] AbNeR Name log",
	author = "AbNeR_CSS",
	description = "Registry every name a player uses in your server.",
	version = PLUGIN_VERSION,
	url = "www.tecnohardclan.com/forum"
}

public void OnPluginStart()
{
	CreateConVar("abner_namelog_version", PLUGIN_VERSION, "Plugin version", FCVAR_NOTIFY|FCVAR_REPLICATED);
	RegAdminCmd("sm_namelog", CmdNameLog, ADMFLAG_SLAY);
	RegAdminCmd("sm_steamlog", CmSteamLog, ADMFLAG_SLAY);
	RegAdminCmd("sm_iplog", CmdIPLog, ADMFLAG_SLAY);
	SQL_TConnect(LoadMySQLBase, "namelog");
	HookEvent("player_changename", OnNameChange, EventHookMode_Post);
}
public Action OnNameChange(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	CreateTimer(0.1, InsertTime, client);
}

public Action InsertTime(Handle time, any client)
{
	OnClientPutInServer(client);
}

public void OnClientPutInServer(int client)
{
	if(!IsFakeClient(client))
	{
		InsertClient(client);
	}
}

void InsertClient(int client)
{
	char SteamID[64];
	char AuthID[64];
	char ip[64];
	GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
	GetClientAuthId(client, AuthId_Steam3, AuthID, sizeof(AuthID));
	GetClientIP(client, ip, sizeof(ip), false);
	
	char Query[255];
	Format(Query, sizeof(Query), "SELECT * FROM namelog WHERE name = '%N' AND AuthID = '%s' AND SteamID = '%s'AND IP = '%s'", client, AuthID, SteamID, ip);
	DBResultSet SqlQuery = SQL_Query(db, Query);
	if(SqlQuery.RowCount == 0)
	{
		Format(Query, sizeof(Query), "INSERT INTO namelog (name, AuthID, SteamID, IP) VALUES('%N', '%s', '%s', '%s')", client, AuthID, SteamID, ip);
		SQL_TQuery(db, QueryErrorCallback, Query);
	}
}

public void LoadMySQLBase(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == null)
	{
		PrintToServer("NameLog Error: Falha %s", error);
		db = null;
		return;
	} 
	else 
	{
		PrintToServer("NameLog: Connected to database");
	}

	db = hndl;
	char query[1024];
	Format(query, sizeof(query), "PRAGMA table_info(namelog)");
	DBResultSet SqlQuery = SQL_Query(db, query);
	bool found = false;
	while(SqlQuery.FetchRow())
	{
		char TmpColName[64];
		SqlQuery.FetchString(1, TmpColName, 64);
		found = StrEqual("IP", TmpColName);
	}
	if(!found)
	{
		Format(query, sizeof(query), "ALTER TABLE 'namelog' ADD COLUMN IP Varchar(64)", MAX_NAME_LENGTH);
		SQL_TQuery(db, QueryErrorCallback, query);
	}
	
	Format(query, sizeof(query), "CREATE TABLE IF NOT EXISTS 'namelog' (name VARCHAR(%d) NOT NULL, SteamID VARCHAR(64) NOT NULL, AuthID VARCHAR(64) NOT NULL, IP Varchar(64))", MAX_NAME_LENGTH);
	SQL_TQuery(db, QueryErrorCallback, query);
}


public void QueryErrorCallback(Handle owner, Handle hndl, const char[] error, any data)
{
	if(!StrEqual("", error))
	{
		PrintToServer("NameLog: Error %s", error);
	}
}

public Action CmdNameLog(int client, int args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_namelog <name>");
		return Plugin_Handled;
	}
	char arg[128];
	GetCmdArgString(arg, sizeof(arg));
	
	char Query[1024];
	Format(Query, sizeof(Query), "SELECT name, AuthID, SteamID, IP FROM namelog WHERE name LIKE '%%%%%s%%%%'", arg);
	DBResultSet RsNames = SQL_Query(db, Query);
	if(RsNames.RowCount > 0)
	{
		Menu menu = new Menu(MenuHandlerSteam);
		menu.SetTitle("Results to name %s", arg);
		
		while(RsNames.FetchRow())
		{
			char TmpName[MAX_NAME_LENGTH];
			RsNames.FetchString(0, TmpName, MAX_NAME_LENGTH);
			char TmpAuthID[64];
			RsNames.FetchString(1, TmpAuthID, 64);
			char TmpSteamID[64];
			RsNames.FetchString(2, TmpSteamID, 64);
			char TmpIP[64];
			RsNames.FetchString(3, TmpIP, 64);
			char TmpInfo[1024];
			Format(TmpInfo,sizeof(TmpInfo), "Name: %s \nSteamID: %s \nAuthID: %s \nIP: %s", TmpName, TmpSteamID, TmpAuthID, TmpIP);
			menu.AddItem(TmpInfo, TmpName);
		}
		menu.Display(client, MENU_TIME_FOREVER);
	}
	else
	{
		PrintToChat(client, "[AbNeR Name Log] No results found to %s", arg);
	}
	return Plugin_Handled;
}

public Action CmSteamLog(int client, int args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_steamlog <steamid/authid>");
		return Plugin_Handled;
	}
	char arg[128];
	GetCmdArgString(arg, sizeof(arg));
	TrimString(arg);
	
	char Query[1024];
	Format(Query, sizeof(Query), "SELECT name, AuthID, SteamID, IP FROM namelog WHERE AuthID LIKE '%%%%%s%%%%' OR SteamID LIKE '%%%%%s%%%%'", arg, arg);
	DBResultSet RsNames = SQL_Query(db, Query);
	if(RsNames.RowCount > 0)
	{
		Menu menu = new Menu(MenuHandlerSteam);
		menu.SetTitle("Names used by %s", arg);
		
		while(RsNames.FetchRow())
		{
			char TmpName[MAX_NAME_LENGTH];
			RsNames.FetchString(0, TmpName, MAX_NAME_LENGTH);
			char TmpAuthID[64];
			RsNames.FetchString(1, TmpAuthID, 64);
			char TmpSteamID[64];
			RsNames.FetchString(2, TmpSteamID, 64);
			char TmpIP[64];
			RsNames.FetchString(3, TmpIP, 64);
			char TmpInfo[1024];
			Format(TmpInfo,sizeof(TmpInfo), "Name: %s \nSteamID: %s \nAuthID: %s \nIP: %s", TmpName, TmpSteamID, TmpAuthID, TmpIP);
			menu.AddItem(TmpInfo, TmpName);
		}
		menu.Display(client, MENU_TIME_FOREVER);
	}
	else
	{
		PrintToChat(client, "[AbNeR Name Log] No results found to '%s'", arg);
	}
	return Plugin_Handled;
}

public Action CmdIPLog(int client, int args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_iplog <ip>");
		return Plugin_Handled;
	}
	char arg[128];
	GetCmdArgString(arg, sizeof(arg));
	TrimString(arg);
	
	char Query[1024];
	Format(Query, sizeof(Query), "SELECT name, AuthID, SteamID, IP FROM namelog WHERE IP LIKE '%%%%%s%%%%'", arg);
	DBResultSet RsNames = SQL_Query(db, Query);
	if(RsNames.RowCount > 0)
	{
		Menu menu = new Menu(MenuHandlerSteam);
		menu.SetTitle("Names used by %s", arg);
		
		while(RsNames.FetchRow())
		{
			char TmpName[MAX_NAME_LENGTH];
			RsNames.FetchString(0, TmpName, MAX_NAME_LENGTH);
			char TmpAuthID[64];
			RsNames.FetchString(1, TmpAuthID, 64);
			char TmpSteamID[64];
			RsNames.FetchString(2, TmpSteamID, 64);
			char TmpIP[64];
			RsNames.FetchString(3, TmpIP, 64);
			char TmpInfo[1024];
			Format(TmpInfo,sizeof(TmpInfo), "Name: %s \nSteamID: %s \nAuthID: %s \nIP: %s", TmpName, TmpSteamID, TmpAuthID, TmpIP);
			menu.AddItem(TmpInfo, TmpName);
		}
		menu.Display(client, MENU_TIME_FOREVER);
	}
	else
	{
		PrintToChat(client, "[AbNeR Name Log] No results found to '%s'", arg);
	}
	return Plugin_Handled;
}

public int MenuHandlerSteam(Menu menu, MenuAction action, int client, int param2)
{
	if(action == MenuAction_Select)
	{
		char sInfo[1024];
		menu.GetItem(param2, sInfo, sizeof(sInfo));
		PrintToChat(client, "---------AbNeR Name Log---------");
		PrintToChat(client, sInfo);
		PrintToChat(client, "\n-------------------------------------");

	}
}


