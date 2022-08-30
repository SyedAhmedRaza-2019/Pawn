#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <cstrike>

#pragma semicolon 1
#pragma tabsize 4

#define PLUGIN 				"Gun Menu"
#define VERSION 			"1.0"
#define AUTHOR 				"begin"
#define PREFIX_CHAT			"^4[AMXX]"
#define TASK_DESTROY_MENU 	2981724

enum E_CVARS
{
CVAR_GIVE_HE,
CVAR_GIVE_FB,
CVAR_GIVE_SG,
CVAR_MENU_ACTIVE,
CVAR_MENU_M4A1,
CVAR_MENU_AK47,
CVAR_MENU_AWP,
CVAR_MENU_VIP,
CVAR_VIP_ROUND,
}

enum E_WEAPONS
{
WPN_M4A1,
WPN_AK47,
WPN_AWP,
WPN_DEAGLE,
}

enum E_WEAPON_DETAIL
{
DETAIL_NAME[32],
DETAIL_ITEM[32],
DETAIL_CLASS,
DETAIL_AMMO,
}

new g_CVarString	[E_CVARS][][] =
{
{"gmenu_vip_he_cancel",			"1",	"num"},	
{"gmenu_vip_flash_cancel",		"1",	"num"},	
{"gmenu_vip_smoke_cancel",		"0",	"num"},	
{"gmenu_active", 			"1",	"num"},	
{"gmenu_cancel_m4a1",			"0",	"num"},	
{"gmenu_cancel_ak47",			"1",	"num"},
{"gmenu_cancel_awp",			"1",	"num"},
{"gmenu_cancel_vip",			"15",	"num"},
{"gmenu_vip_available_round",		"3",	"num"},
};
new g_cvarPointer	[E_CVARS];
new g_cvars			[E_CVARS];
new g_menu_callback;
new g_round;
new g_c4			[MAX_PLAYERS + 1];
new g_menuid		[MAX_PLAYERS + 1];

new const WEAPON_LIST[E_WEAPONS][E_WEAPON_DETAIL] = 
{
{"M4A1",	"weapon_m4a1", 		CSW_M4A1,	90},
{"AK47",	"weapon_ak47", 		CSW_AK47,	90},
{"AWP", 	"weapon_awp", 		CSW_AWP,	30},
{"DEAGLE",	"weapon_deagle", 	CSW_DEAGLE,	35},
};

public plugin_init() 
{
register_plugin(PLUGIN, VERSION, AUTHOR);

// Register Cvar pointers.
register_cvars();

register_logevent("logevent_round_start", 2, "1=Round_Start");
register_event("TextMsg", "Event_Round_Restart", "a", "2=#Game_Commencing", "2=#Game_will_restart_in");

g_menu_callback = menu_makecallback("MenuCancel");
}

// ====================================================
//  Register Cvars.
// ====================================================
register_cvars()
{
for(new E_CVARS:i = CVAR_GIVE_HE; i < E_CVARS; i++)
{
g_cvarPointer[i] = create_cvar(g_CVarString[i][0], g_CVarString[i][1]);
if (equali(g_CVarString[i][2], "num"))
bind_pcvar_num(g_cvarPointer[i], g_cvars[i]);
else if(equali(g_CVarString[i][2], "float"))
bind_pcvar_float(g_cvarPointer[i], Float:g_cvars[i]);

hook_cvar_change(g_cvarPointer[i], "cvar_change_callback");
}
}

// ====================================================
//  Callback cvar change.
// ====================================================
public cvar_change_callback(pcvar, const old_value[], const new_value[])
{
for(new E_CVARS:i = CVAR_GIVE_HE; i < E_CVARS; i++)
{
if (g_cvarPointer[i] == pcvar)
{
if (equali(g_CVarString[i][2], "num"))
g_cvars[i] = str_to_num(new_value);
else if (equali(g_CVarString[i][2], "float"))
	g_cvars[i] = _:str_to_float(new_value);
}
}
}

public Event_Round_Restart()
{
g_round = 0;
}

public logevent_round_start()
{
g_round++;

new players[32], pnum;
get_players(players, pnum, "ac");

for(new i = 0, iplayer; i < pnum; i++)
{
iplayer = players[i];

if (!is_user_alive(iplayer)) 
	continue;
	
	give_defaultset(iplayer);
	
	if (g_cvars[CVAR_MENU_ACTIVE])
	{
		if (g_round	<= g_cvars[CVAR_VIP_ROUND])
			client_print_color(iplayer, print_team_default, "%s^3 Menu will be available in^4 %i^3 Round",PREFIX_CHAT,(g_cvars[CVAR_VIP_ROUND] + 1)-g_round);
			else
				OpenMenu(iplayer);
			} else {
			client_print_color(iplayer, print_team_default, "%s^3 Menu Not Actived^1 [^4Contact Admins^1]",PREFIX_CHAT);
		}
	}
	return PLUGIN_HANDLED;
} 

public OpenMenu(id)
{
	g_menuid[id] = menu_create("Free VIP Guns", "OpenMenu_Handler");
	
	menu_additem(g_menuid[id], "Get M4A1 + Deagle",	"0",_,g_menu_callback);
	menu_additem(g_menuid[id], "Get AK47 + Deagle",	"1",_,g_menu_callback);
	menu_additem(g_menuid[id], "Get AWP  + Deagle",	"2",_,g_menu_callback);
	menu_setprop(g_menuid[id], MPROP_EXIT, MEXIT_ALL);
	
	menu_display(id, g_menuid[id], 0, g_cvars[CVAR_MENU_VIP]);
	
	client_print_color(id, print_team_default, "%s^3 Please Choose Your^4 VIP Gun^3, Menu Will Closed in^4 %i^3 Seconds",PREFIX_CHAT, g_cvars[CVAR_MENU_VIP]);
	
	client_print (id,print_chat,"Test: M4A1=%i, AK47=%i, AWP=%i",g_cvars[CVAR_MENU_M4A1], g_cvars[CVAR_MENU_AK47], g_cvars[CVAR_MENU_AWP]);
	
	set_task(float(g_cvars[CVAR_MENU_VIP]),"Destroy_Menu",id+TASK_DESTROY_MENU);
}

public Destroy_Menu(taskid)
{
	new id = taskid - TASK_DESTROY_MENU;
	show_menu(id,0,"^n",1);
}

public MenuCancel(id, menu, item)
{
	new szData[6], szName[64], access, callback;
	menu_item_getinfo(menu, item, access, szData, charsmax(szData), szName, charsmax(szName), callback);
	switch(item)
	{
		case 0:
			return g_cvars[CVAR_MENU_M4A1] ? ITEM_ENABLED : ITEM_DISABLED;
		case 1:
			return g_cvars[CVAR_MENU_AK47] ? ITEM_ENABLED : ITEM_DISABLED;
		case 2:
			return g_cvars[CVAR_MENU_AWP] ? ITEM_ENABLED : ITEM_DISABLED;
	}
	return ITEM_ENABLED;
}

public OpenMenu_Handler(id, menu, item)
{
	if(item == MENU_EXIT || !is_user_alive(id) || item == MENU_TIMEOUT)
	{
		return PLUGIN_HANDLED;
	}
	select_weapon(id,E_WEAPONS:item);
	menu_destroy(menu);	
	return PLUGIN_HANDLED;
}

public select_weapon(id, E_WEAPONS:class)
{
	if (WPN_M4A1 <= class <= WPN_DEAGLE)
	{
		if (user_has_weapon(id, CSW_C4))
			g_c4[id] = true;
		else
			g_c4[id] = false;
		
		strip_user_weapons(id);
		give_defaultset(id);
		
		give_weaponset(id, class);
		give_weaponset(id, WPN_DEAGLE);
		
		give_c4_or_defusekit(id);
		
		client_print_color(id,print_team_default,"%s^3 You Got Free^4 %s^3 and^4 Deagle",PREFIX_CHAT,  WEAPON_LIST[class][DETAIL_NAME]);
	}
}

//
// Give Default Set.
//
give_defaultset(id)
{
give_item(id, "weapon_knife");
give_item(id, "item_assaultsuit");

if (g_cvars[CVAR_GIVE_HE])
	give_item(id, "weapon_hegrenade");    
	
	if (g_cvars[CVAR_GIVE_FB])
	{
		for(new i = 0; i < 2; i++)
			give_item(id, "weapon_flashbang");
	}
	if (g_cvars[CVAR_GIVE_SG])
		give_item(id, "weapon_smokegrenade");
}

//
// Give Weapons.
//
give_weaponset(id, E_WEAPONS:weapon)
{
give_item(id, WEAPON_LIST[weapon][DETAIL_ITEM]);
cs_set_user_bpammo(id, WEAPON_LIST[weapon][DETAIL_CLASS], WEAPON_LIST[weapon][DETAIL_AMMO]);
}

//
// Give C4 or Defuse Kit.
//
give_c4_or_defusekit(id)
{
new CsTeams:team = cs_get_user_team(id);
if (team == CS_TEAM_CT)
cs_set_user_defuse(id, 1);
else if(team == CS_TEAM_T)
	if (g_c4[id])
		give_item(id, "weapon_c4");
}
