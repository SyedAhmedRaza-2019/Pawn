/* Plugin generated by AMXX-Studio */
#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <cstrike>
#define PLUGIN "Gun Menu"
#define VERSION "1.0"
#define AUTHOR "begin"
new g_round,g_c4
new g_pMenuCancel,g_menu_active,g_menuAvailableRound;
new g_CvarHe,g_CvarFlash
#define PREFIX_CHAT "^4[AMXX]"
public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
	g_menu_active = register_cvar("menu_active", "1")
	g_CvarHe       = register_cvar( "spv_he", "1" );
	g_CvarFlash   = register_cvar( "spv_flash", "1" );
	g_menuAvailableRound = register_cvar("amx_vip_available_round", "3")
	g_pMenuCancel = register_cvar("amx_vip_menu_cancel", "15");
	register_logevent("logevent_round_start", 2, "1=Round_Start");
	register_event("TextMsg", "Event_Round_Restart", "a", "2=#Game_Commencing", "2=#Game_will_restart_in");
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
	new availableRound = get_pcvar_num(g_menuAvailableRound)
	for(new i = 0, iplayer; i < pnum; i++)
	{
		iplayer = players[i]
		if (!is_user_alive(iplayer)) continue;
		
		if (get_pcvar_num(g_CvarHe))
		{
			give_item(iplayer, "weapon_hegrenade");	
		}
		if (get_pcvar_num(g_CvarFlash))
		{
			give_item(iplayer, "weapon_flashbang");
			give_item(iplayer, "weapon_flashbang");
		}
		
		give_item(iplayer, "item_assaultsuit");
		give_item(iplayer, "item_thighpack");
		
		if (g_round<=availableRound)
		{
			client_print_color(iplayer, print_team_default, "%s^3 Menu will be available in^4 %i^3 Round",PREFIX_CHAT,(availableRound+1)-g_round);
		}
		else 
		{
			if (get_pcvar_num(g_menu_active)&&g_round>=availableRound)
			{
				OpenMenu(iplayer)
			}
		}	
	}
	
	return PLUGIN_HANDLED;
} 
public OpenMenu(id)
{
	new iMenu = menu_create("Free VIP Guns", "OpenMenu_sub");
	
	menu_additem(iMenu, "Get M4A1+Deagle","0",0);
	menu_additem(iMenu, "Get AK47+Deagle","1",0);
	menu_additem(iMenu, "Get AWP+Deagle","2",0);
	menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL);
	new iSec = get_pcvar_num(g_pMenuCancel)
	menu_display(id, iMenu, 0,iSec);
	client_print_color(id, print_team_default, "%s^3 Please Choose Your^4 VIP Gun^3, Menu Will Closed in^4 %i^3 Seconds",PREFIX_CHAT, iSec);
	set_task(float(iSec), "Destroy_Menu", id)
}
public Destroy_Menu ()
{
	for(new Num; Num < 32; Num++)
	{
		if(!is_user_connected(Num))
			continue;
		
		show_menu(Num, 0, "^n", 1);
	}
}
public OpenMenu_sub(id, menu, item)
{
	if(item == MENU_EXIT || !is_user_alive(id))
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	switch(item)
	{
		case 0:
		{
			select_m4a1(id);
		}
		case 1:
		{
			select_ak47(id);
		}
		case 2:
		{
			select_awp(id)
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public select_ak47(id)
{
	strip_user_weapons(id);
	give_item(id, "weapon_knife");
	give_item(id, "item_assaultsuit");
	if (get_pcvar_num(g_CvarHe))
	{
		give_item(id, "weapon_hegrenade");	
	}
	if (get_pcvar_num(g_CvarFlash))
	{
		give_item(id, "weapon_flashbang");
		give_item(id, "weapon_flashbang");
	}
	give_item(id, "weapon_ak47");
	cs_set_user_bpammo(id, CSW_AK47, 90);
	give_item(id, "weapon_deagle");
	cs_set_user_bpammo(id, CSW_DEAGLE, 35);
	
	if(user_has_weapon(id, CSW_C4))
		g_c4 = true;
	
	if(cs_get_user_team(id) == CS_TEAM_CT)
	{
		give_item(id, "item_thighpack");
	}
	else if(cs_get_user_team(id) == CS_TEAM_T)
	{
		if(g_c4)
		{
			give_item(id, "weapon_c4");
			cs_set_user_plant(id, 1, 1);
		}
	}
	client_print_color(id,print_team_default,"%s^3 You Got Free^4 M4A1^3 and^4 Deagle",PREFIX_CHAT);
}
public select_m4a1(id)
{
	strip_user_weapons(id);
	give_item(id, "weapon_knife");
	give_item(id, "item_assaultsuit");
	if (get_pcvar_num(g_CvarHe))
	{
		give_item(id, "weapon_hegrenade");	
	}
	if (get_pcvar_num(g_CvarFlash))
	{
		give_item(id, "weapon_flashbang");
		give_item(id, "weapon_flashbang");
	}
	give_item(id, "weapon_m4a1");
	cs_set_user_bpammo(id, CSW_M4A1, 90);
	give_item(id, "weapon_deagle");
	cs_set_user_bpammo(id, CSW_DEAGLE, 35);
	
	if(user_has_weapon(id, CSW_C4))
		g_c4 = true;
	if(cs_get_user_team(id) == CS_TEAM_CT)
	{
		give_item(id, "item_thighpack");
	}
	else if(cs_get_user_team(id) == CS_TEAM_T)
	{
		if(g_c4)
		{
			give_item(id, "weapon_c4");
			cs_set_user_plant(id, 1, 1);
		}
	}
	client_print_color(id,print_team_default,"%s^3 You Got Free^4 AK47^3 and^4 Deagle",PREFIX_CHAT);
}
public select_awp(id)
{
	strip_user_weapons(id);
	give_item(id, "weapon_knife");
	give_item(id, "item_assaultsuit");
	if (get_pcvar_num(g_CvarHe))
	{
		give_item(id, "weapon_hegrenade");	
	}
	if (get_pcvar_num(g_CvarFlash))
	{
		give_item(id, "weapon_flashbang");
		give_item(id, "weapon_flashbang");
	}
	give_item(id, "weapon_awp");
	cs_set_user_bpammo(id, CSW_AWP, 30);
	give_item(id, "weapon_deagle");
	cs_set_user_bpammo(id, CSW_DEAGLE, 35);
	
	if(user_has_weapon(id, CSW_C4))
		g_c4 = true;
	if(cs_get_user_team(id) == CS_TEAM_CT)
	{
		give_item(id, "item_thighpack");
	}
	else if(cs_get_user_team(id) == CS_TEAM_T)
	{
		if(g_c4)
		{
			give_item(id, "weapon_c4");
			cs_set_user_plant(id, 1, 1);
		}
	}
	client_print_color(id,print_team_default,"%s^3 You Got Free^4 AK47^3 and^4 Deagle",PREFIX_CHAT);
}
