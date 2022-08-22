#include <amxmodx> 
#include <cstrike> 
new runde = 0
new prefix[32] = "AMXX"
new TerrScore, CTScore
public plugin_init()  
{ 
	register_plugin( "Info Top", "1.4", "->UrOS<-")    
	register_event("HLTV", "round_start", "a", "1=0", "2=0")
	register_event("TextMsg", "round_restart", "a", "2=#Game_will_restart_in", "2=#Game_Commencing")
	register_event("TeamScore", "terr_score", "a", "1=TERRORIST")
	register_event("TeamScore", "ct_score", "a", "1=CT")
} 
public round_restart()
{
	runde = 0
	TerrScore=0
	CTScore=0
}
public terr_score()
{
	TerrScore = read_data(2)
}
public ct_score()
{
	CTScore = read_data(2)
}
public round_start() 
{ 
	
	
	new mapname[32], nextmap[32], players[32], player ,maxrundi, maxplayers 
	
	maxrundi=get_cvar_num("mp_maxrounds")
	maxplayers=get_maxplayers()
	get_cvar_string("amx_nextmap",nextmap,31) 
	get_mapname(mapname,31 ) 
	get_players(players, player)
	
	ChatColor(0,"^4[%s]^3 Rounds:^4 %d^3/^4%d ^1|^3 Score:^3 Ts:^4%i^3 -^3 CTs:^4%i ^1|^3 Map:^4 %s^3/^4%s ^1|^3 Players:^4 %d^3/^4%d",prefix, runde,maxrundi,TerrScore,CTScore,mapname, nextmap, player,maxplayers) 
	runde++
}
stock ChatColor(const id, const input[], any:...) {
	static csaymsg;
	if (!csaymsg) { csaymsg = get_user_msgid("SayText"); }
	
	static count, players[32], i, player;
	count = 1;
	i = 0;
	static msg[191];
	vformat(msg, 190, input, 3);
	
	replace_all(msg, 190, "!g", "^4");
	replace_all(msg, 190, "!y", "^1");
	replace_all(msg, 190, "!n", "^1");
	replace_all(msg, 190, "!t", "^3");
	
	if (id) 
	{
		players[0] = id;
	}
	else 
	{
		get_players(players, count, "ch");
	}
	
	for (i = 0; i < count; i++)
	{
		player = players[i];
		if (is_user_connected(player))
		{
			message_begin(MSG_ONE_UNRELIABLE, csaymsg, _, player);
			write_byte(player);
			write_string(msg);
			message_end();
		}
	}
}
