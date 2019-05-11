#pragma semicolon 1
#pragma tabsize 0

#define DEBUG
#define PLUGIN_AUTHOR "Habibi"
#define PLUGIN_VERSION "1.03"

new count; //Hazirlik Süresi
new bool:hazirlik = false;
new count2; // Dalga Süresi
new count3; //Dalga ara süresi
new bool:dalgarasi = false;
new dalga; //Dalga Sayısı
new bool:dalgaktif = false;
new npcspawn = 5; //NPC spawnlanma süresi
new maxdalga = 10;
new spawn = false;
new bool:zor = false;
new bool:normal1 = false;
new bool:kolay = false;
new hptank = 600;
new hpboomer = 50;
new Float:spawnnpc = 10.0;
new num; //hazır oolanların sayısı
new count4;
new oylar[MAXPLAYERS];
new num1; //oy sayısı (kolay)
new num2; // "" (normal)
new num3; // "" (zor)
new point;



#define EF_BONEMERGE            (1 << 0)
#define EF_NODRAW				(1 << 1)
#define EF_NOSHADOW             (1 << 4)
#define EF_BONEMERGE_FASTCULL   (1 << 7)
#define EF_PARENT_ANIMATES      (1 << 9)

#include <sdktools>
#include <sdkhooks>
#include <tf2>
#include <tf2_stocks>
#include <sourcemod>


public Plugin:myinfo = 
{
	name = "NPC Survival by Habibi", 
	author = PLUGIN_AUTHOR, 
	description = "NPC Survival", 
	version = PLUGIN_VERSION, 
	url = "http://steamcommunity.com/id/crackersarenoice/"
};

public OnMapStart()
{
	AddFileToDownloadsTable("models/player/items/sniper/sniper_zombie.mdl");
	PrecacheSound("left4fortress/rabies01.mp3");
	PrecacheSound("left4fortress/zincoming_mob.mp3");
	PrecacheSound("left4fortress/zombat/heartbeat_medium.wav");
	PrecacheModel("models/zombie/classic.mdl");
	PrecacheModel("models/headcrabclassic.mdl");
}

public OnPluginStart()
{
	//////////////////////////////MENÜ////////////////////////////
	
	ServerCommand("tf_forced_holiday 2");
	ServerCommand("mp_autoteambalance 0");
	ServerCommand("mp_respawnwavetime 99999");
	//ServerCommand("mp_tournament 1");
	//ServerCommand("mp_tournament_restart");
	RegConsoleCmd("sm_test", test);
	HookEvent("teamplay_round_start", teamplay_round_start);
	CreateTimer(1.0, hazirlik1, _, TIMER_REPEAT); //Hazirlik
	CreateTimer(1.0, dalgatime1, _, TIMER_REPEAT); //Dalga süresi
	CreateTimer(1.0, dalgarasi1, _, TIMER_REPEAT); //Dalga arası süresi
	CreateTimer(spawnnpc, npc, _, TIMER_REPEAT); //npc1 normal
	CreateTimer(30.0, npc2, _, TIMER_REPEAT); //tank
	CreateTimer(16.0, npc3, _, TIMER_REPEAT); //boomer
	CreateTimer(6.0, heartbeat, _, TIMER_FLAG_NO_MAPCHANGE); // şarkı
	CreateTimer(1.0, kontrol, _, TIMER_REPEAT);
}

public Action:kontrol(Handle:timer, any:id)
{
	if (dalga == 10)
	{
		if (!dalgaktif)
		{
			ServerCommand("mp_restartgame 1");
		}
	}
}

public Action:teamplay_round_start(Handle:event, const String:name[], bool:dontBroadcast)
{
	//Süreler - Değerler
	count = 120;
	count2 = 120;
	count3 = 15;
	dalga = 0;
	num = 0;
	num1 = 0;
	num2 = 0;
	num3 = 0;
	hazirlik = true;
	spawn = false;
	dalgaktif = false;
	dalgarasi = false;
	count4 = 120; //Hazır olanların hint texti
	kolay = false;
	zor = false;
	normal1 = false;
}

public Action:test(client, args)
{
	PrintToChatAll("---DALGA SAYISI---");
	PrintToChatAll("%d", dalga);
	
	if (hazirlik)
	{
		PrintToChatAll("hazirlik, true");
	}
	
	if (!zor && !normal1 && kolay)
	{
		PrintToChatAll("kolay", "true");
	}
	
	if (zor && !normal1 && !kolay)
	{
		PrintToChatAll("zor", "true");
	}
	
	if (!zor && normal1 && !kolay)
	{
		PrintToChatAll("normal", "true");
	}
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsPlayerAlive(i))
		{
			TF2_RespawnPlayer(i);
		}
	}
	
	return Plugin_Continue;
}

public vote(Handle hVote, MenuAction action, client, item)
{
	if (action == MenuAction_End)
	{
		if (num1 > num2 && num1 > num3)
		{
			kolay = true;
			normal1 = false;
			zor = false;
			PrintToChatAll("Mod Kolay'a ayarlandı");
		}
		
		else if (num2 > num1 && num2 > num3)
		{
			kolay = false;
			normal1 = true;
			zor = false;
			PrintToChatAll("Mod Normal'e ayarlandı");
		}
		
		else if (num3 > num1 && num3 > num2)
		{
			zor = true;
			kolay = false;
			normal1 = false;
			PrintToChatAll("Mod Zor'a ayarlandı");
		}
		
		CloseHandle(hVote);
	}
	
	else if (action == MenuAction_Select)
	{
		switch (item)
		{
			case 0:
			{
				oylar[num1++];
				/*
    			if(num1 > num2 && num1 > num3)
    			{
    				kolay = true;
    				normal1 = false;
    				zor = false;
    				PrintToChatAll("Mod Kolay'a ayarlandı");
    		    }
    		    */
			}
			
			case 1:
			{
				oylar[num2++];
				/*
    	    	if(num2 > num1 && num2 > num3)
    	    	{
    	    		kolay = false;
    	    		normal1 = true;
    	    		zor = false;
    	    		PrintToChatAll("Mod Normal'e ayarlandı");
    	        }
    	        */
			}
			
			case 2:
			{
				oylar[num3++];
				/*
    	        if(num3 > num1 && num3 > num2)
    	    	{
    	    		zor = true;
    	    		kolay = false;
    	    		normal1 = false;
    	    		PrintToChatAll("Mod Zor'a ayarlandı");
    	        }
    	        */
			}
		}
	}
}

//Hazirlik
public Action:hazirlik1(Handle:timer, any:id)
{
	if (hazirlik && !dalgaktif && !dalgarasi)
	{
		count--;
		
		if (count > 0)
		{
			spawn = false;
			votemenu();
			PrintHintTextToAll("Hazırlık Süresi(COOLDOWN):%02d:%02d // Dalga(WAVE): %d / %d", count / 60, count % 60, dalga, maxdalga);
			dalgarasi = false;
			dalgaktif = false;
		}
		
		else if (count == 0)
		{
			if (dalga <= maxdalga)
			{
				dalga = dalga + 1;
			}
			
			spawn = true;
			dalgarasi = false;
			dalgaktif = true;
			hazirlik = false;
		}
	}
}

//DALGA SÜRESİ
public Action:dalgatime1(Handle:timer, any:id)
{
	if (dalgaktif)
	{
		count2--;
		
		if (count2 > 0)
		{
			spawn = true;
			
			PrintHintTextToAll("DALGA SURESI(WAVE TIME):%02d:%02d  // DALGA(WAVE): %d / %d", count2 / 60, count2 % 60, dalga, maxdalga);
			dalgarasi = false;
			hazirlik = false;
		}
		
		else if (count2 == 0)
		{
			spawn = false;
			if (dalga <= maxdalga)
			{
				dalga = dalga + 1;
			}
			
			else if (dalga == 3)
			{
				count3 = 60;
			}
			
			else if (dalga == 4)
			{
				count3 = 60;
			}
			
			else if (dalga == 5)
			{
				count3 = 60;
			}
			
			else if (dalga == 6)
			{
				count3 = 60;
			}
			
			else if (dalga == 7)
			{
				count3 = 60;
			}
			
			else if (dalga == 8)
			{
				count3 = 60;
			}
			
			else if (dalga == 9)
			{
				count3 = 60;
			}
			
			else if (dalga == 10)
			{
				count3 = 60;
			}
			
			count3 = 60;
			dalgarasi = true;
			dalgaktif = false;
			hazirlik = false;
		}
	}
}

//Heart beat şarkısı için
public Action:heartbeat(Handle:timer, any:id)
{
	if (dalga == 1)
	{
		if (dalgaktif)
		{
			EmitSoundToAll("left4fortress/zombat/heartbeat_medium.wav");
		}
	}
}

//DALGA ARASI

public Action:dalgarasi1(Handle:timer, any:id)
{
	if (dalgarasi)
	{
		count3--;
		
		if (count3 > 0)
		{
			PrintHintTextToAll("DALGA ARASI(NEXT WAVE IN):%02d:%02d  // DALGA(WAVE): %d / %d", count3 / 60, count3 % 60, dalga, maxdalga);
			dalgaktif = false;
			hazirlik = false;
			spawn = false;
		}
		
		//Sıfırlandığı için herdalgada süreyi yeniledim.
		else if (count3 == 0)
		{
			count2 = 120;
			
			if (dalga == 3)
			{
				
				count2 = 120;
			}
			
			else if (dalga == 4)
			{
				count2 = 135;
			}
			
			else if (dalga == 5)
			{
				count2 = 150;
			}
			
			else if (dalga == 6)
			{
				count2 = 175;
			}
			
			else if (dalga == 7)
			{
				count2 = 200;
			}
			
			else if (dalga == 8)
			{
				count2 = 215;
			}
			
			else if (dalga == 9)
			{
				count2 = 230;
			}
			
			else if (dalga == 10)
			{
				count2 = 250;
			}
			
			dalgaktif = true;
			dalgarasi = false;
			hazirlik = false;
			spawn = true;
		}
	}
	
	return Plugin_Continue;
}

public Action:npc(Handle:timer, any:id)
{
	if (dalgaktif && !hazirlik && !dalgarasi)
	{
		npczombie();
		
		if (dalga > 1)
		{
			spawnnpc = spawnnpc - 1;
		}
		
		if (zor && !normal1 && !kolay)
		{
			spawnnpc = 5.0;
		}
	}
}

//tank
public Action:npc2(Handle:timer, any:id)
{
	if (dalgaktif && !hazirlik && !dalgarasi)
	{
		if (dalga > 2)
		{
			npczombie2();
		}
	}
}

public Action:npc3(Handle:timer, any:id)
{
	if (dalgaktif && !hazirlik && !dalgarasi)
	{
		if (dalga > 2)
		{
			npczombie3();
		}
	}
}

npczombie()
{
	
	new z1 = CreateEntityByName("tf_zombie");
	new entcount = -1;
	entcount = FindEntityByClassname(entcount, "tf_zombie");
	
	if (z1 != -1)
	{
		if (spawn)
		{
			DispatchSpawn(z1);
		}
	}
	
	decl Float:FurnitureOrigin[3];
	FurnitureOrigin[0] = 45.193310;
	FurnitureOrigin[1] = 86.888908;
	FurnitureOrigin[2] = 0.000000;
	
	decl String:name[64];
	TeleportEntity(z1, FurnitureOrigin, NULL_VECTOR, NULL_VECTOR);
	SetEntProp(z1, Prop_Data, "m_iHealth", 150);
	SetEntProp(z1, Prop_Data, "m_iMaxHealth", 150);
	SetEntProp(z1, Prop_Send, "m_bGlowEnabled", 1);
	SetEntityModel(z1, "models/zombie/classic.mdl");
	SetEntProp(z1, Prop_Send, "m_CollisionGroup", 11);
	SetEntProp(z1, Prop_Send, "m_fEffects", EF_BONEMERGE | EF_NOSHADOW | EF_PARENT_ANIMATES | EF_BONEMERGE_FASTCULL);
	SetEntityRenderColor(z1, 0, 255, 0, 0);
	EmitSoundToAll("left4fortress/zincoming_mob.mp3", z1);
}

npczombie2()
{
	new z = CreateEntityByName("tf_zombie");
	if (z != -1)
	{
		if (spawn)
		{
			DispatchSpawn(z);
		}
	}
	
	decl Float:FurnitureOrigin[3];
	FurnitureOrigin[0] = 45.193310;
	FurnitureOrigin[1] = 86.888908;
	FurnitureOrigin[2] = 0.000000;
	
	if (zor && !kolay && !normal1)
	{
		hptank = hptank + 200;
	}
	
	if (normal1 && !zor && !kolay)
	{
		hptank = hptank + 400;
	}
	
	TeleportEntity(z, FurnitureOrigin, NULL_VECTOR, NULL_VECTOR);
	SetEntProp(z, Prop_Data, "m_takedamage", 2);
	SetEntPropFloat(z, Prop_Data, "m_flModelScale", 2.0);
	SetEntProp(z, Prop_Send, "m_bGlowEnabled", 1);
	SetEntProp(z, Prop_Data, "m_iHealth", hptank);
	SetEntProp(z, Prop_Data, "m_iMaxHealth", hptank);
	SetEntityRenderColor(z, 255, 0, 0, 0);
}

npczombie3()
{
	new z = CreateEntityByName("tf_zombie");
	
	if (z != -1)
	{
		if (spawn)
		{
			DispatchSpawn(z);
		}
	}
	decl Float:FurnitureOrigin[3];
	FurnitureOrigin[0] = 45.193310;
	FurnitureOrigin[1] = 86.888908;
	FurnitureOrigin[2] = 0.000000;
	
	if (kolay)
	{
		hpboomer = hpboomer + 10;
	}
	
	if (normal1)
	{
		hpboomer = hpboomer + 200;
	}
	
	if (zor)
	{
		hpboomer = hpboomer + 200;
	}
	TeleportEntity(z, FurnitureOrigin, NULL_VECTOR, NULL_VECTOR);
	SetEntProp(z, Prop_Data, "m_iHealth", hpboomer);
	SetEntProp(z, Prop_Send, "m_bGlowEnabled", 1);
	SetEntProp(z, Prop_Data, "m_iMaxHealth", hpboomer);
	SetEntityRenderColor(z, 0, 0, 255, 0);
	
	if (hpboomer < 0)
	{
		AcceptEntityInput(z, "explode");
	}
	
}

votemenu()
{
	if (count == 40)
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			Menu hVote = new Menu(vote);
			hVote.SetTitle("NPC Survival Zorluk derecesi");
			hVote.AddItem("Kolay", "Kolay");
			hVote.AddItem("Normal", "Normal");
			hVote.AddItem("Zor", "Zor");
			hVote.ExitButton = false;
			hVote.Display(i, 20);
		}
	}
}
public OnEntityCreated(entity, const String:classname[])
{
	CreateTimer(0.00001, timerDestroy, entity, TIMER_FLAG_NO_MAPCHANGE);
}

public Action:timerDestroy(Handle:timer, any:entity)
{
	decl String:name[64];
	if(dalgaktif)
	{
		GetEntityClassname(entity, name, sizeof(name));
        }
	if (dalgaktif && IsValidEntity(entity) && StrEqual(name, "tf_zombie", false))
	{
		new Float:size = GetEntPropFloat(entity, Prop_Data, "m_flModelScale");
		if (size >= 1.0)
		{
			if (dalgarasi && !hazirlik && !dalgaktif)
			{
				if (dalga >= 0 && !spawn && dalgarasi)
				{
					AcceptEntityInput(entity, "Kill");
				}
			}
			
		} else {
			
			if (IsValidEntity(entity))
			{
				if (kolay && !normal1 && !zor)
				{
					AcceptEntityInput(entity, "Kill");
					
				} else {
					
					SetEntityModel(entity, "models/headcrabclassic.mdl");
					SetEntProp(entity, Prop_Send, "m_bGlowEnabled", 1);
					SetEntityRenderColor(entity, 100, 0, 0, 0);
				}
			}
		}
	}
} 