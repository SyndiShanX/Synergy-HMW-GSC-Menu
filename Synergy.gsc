#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

init() {
	executeCommand("sv_cheats 1");

	precacheShader("ui_scrollbar_arrow_right");

	level thread player_connect();
	level thread create_rainbow_color();

	wait 0.5;

	replaceFunc(maps\mp\gametypes\_gamelogic::onForfeit, ::return_false); // Retropack
	replaceFunc(maps\mp\gametypes\_gamelogic::matchStartTimerWaitForPlayers, maps\mp\gametypes\_gamelogic::matchStartTimerSkip); //SimonLFC - Retropack
	level.originalCallbackPlayerDamage = level.callbackPlayerDamage; //doktorSAS - Retropack
	level.callbackPlayerDamage = ::player_damage_callback; // Retropack
	level.rankedmatch = 1;
}

initial_variables() {
	self.in_menu = false;
	self.hud_created = false;
	self.loaded_offset = false;
	self.option_limit = 7;
	self.current_menu = "Synergy";
	self.structure = [];
	self.previous = [];
	self.saved_index = [];
	self.saved_offset = [];
	self.saved_trigger = [];
	self.slider = [];

	self.font = "default";
	self.font_scale = 0.7;
	self.x_offset = 175;
	self.y_offset = 160;

	self.color_theme = "rainbow";
	self.menu_color_red = 0;
	self.menu_color_green = 0;
	self.menu_color_blue = 0;

	self.cursor_index = 0;
	self.scrolling_offset = 0;
	self.previous_scrolling_offset = 0;
	self.description_height = 0;
	self.previous_option = undefined;

	level.bot_difficulty = "Recruit";

	self.syn["visions"][0] = ["None", "AC-130", "AC-130 inverted", "Black & White", "Endgame", "Night", "Night Vision", "MP Intro", "MP Nuke Aftermath", "Sepia"];
	self.syn["visions"][1] = ["", "ac130", "ac130_inverted", "missilecam", "end_game", "default_night", "default_night_mp", "mpintro", "mpnuke_aftermath", "sepia"];

	self.syn["weapons"]["category"][0] = ["assault_rifles", "sub_machine_guns", "sniper_rifles", "light_machine_guns", "machine_pistols", "shotguns", "pistols", "launchers", "melee", "equipment"];
	self.syn["weapons"]["category"][1] = ["Assault Rifles", "Sub Machine Guns", "Sniper Rifles", "Light Machine Guns", "Machine Pistols", "Shotguns", "Pistols", "Launchers", "Melee Weapons", "Equipment"];

	// Weapons

	self.syn["weapons"]["assault_rifles"][0] =     ["h2_m4_mp", "h2_famas_mp", "h2_scar_mp", "h2_cm901_mp", "h2_tavor_mp", "h2_fal_mp", "h2_m16_mp", "h2_g36c_mp", "h2_masada_mp", "h2_aac_mp", "h2_fn2000_mp", "h2_ak47_mp", "h2_iw5acr_mp"];
	self.syn["weapons"]["sub_machine_guns"][0] =   ["h2_mp5k_mp", "h2_ump45_mp", "h2_mp5_mp", "h2_kriss_mp", "h2_p90_mp", "h2_pm9_mp", "h2_uzi_mp", "h2_mp7_mp", "h2_ak74u_mp"];
	self.syn["weapons"]["sniper_rifles"][0] =      ["h2_cheytac_mp_cheytacscope", "h2_l118a_mp_l118ascope", "h2_barrett_mp_barrettscope", "h2_as50_mp_as50scope", "h2_d25s_mp_d25sscope", "h2_wa2000_mp_wa2000scope", "h2_usr_mp_usrscope", "h2_m21_mp_m21scope", "h2_msr_mp_msrscope", "h2_m40a3_mp_m40a3scope"];
	self.syn["weapons"]["light_machine_guns"][0] = ["h2_sa80_mp", "h2_rpd_mp", "h2_pkm_mp", "h2_mg4_mp", "h2_aug_mp", "h2_m240_mp"];
	self.syn["weapons"]["machine_pistols"][0] =    ["h2_fmg9_mp", "h2_pp2000_mp", "h2_glock_mp", "h2_beretta393_mp", "h2_tmp_mp"];
	self.syn["weapons"]["shotguns"][0] =           ["h2_spas12_mp", "h2_aa12_mp", "h2_ksg_mp", "h2_striker_mp", "h2_ranger_mp", "h2_winchester1200_mp", "h2_m1014_mp", "h2_model1887_mp"];
	self.syn["weapons"]["pistols"][0] =            ["h2_usp_mp", "h2_coltanaconda_mp", "h2_m9_mp", "h2_p226_mp", "h2_colt45_mp", "h2_deserteagle_mp", "h2_mp412_mp"];
	self.syn["weapons"]["launchers"][0] =          ["h2_m320_mp", "at4_mp", "h2_m79_mp", "stinger_mp", "javelin_mp", "h2_rpg_mp"];
	self.syn["weapons"]["melee"][0] =              ["h2_hatchet_mp", "h2_sickle_mp", "h2_shovel_mp", "h2_icepick_mp", "h2_karambit_mp"];

	self.syn["weapons"]["assault_rifles"][1] =     ["M4A1", "Famas", "Scar-H", "CM901", "Tar-21", "FAL", "M16A4", "G36C", "ACR", "Honey Badger", "F2000", "AK-47", "ACR 6.8"];
	self.syn["weapons"]["sub_machine_guns"][1] =   ["MP5K", "UMP45", "MP5", "Vector", "P90", "PP90M1", "Mini-Uzi", "MP7", "AK-74u"];
	self.syn["weapons"]["sniper_rifles"][1] =      ["Intervention", "L118A", "Barret .50CAL", "AS50", "D25S", "WA2000", "USR", "M21", "MSR", "M40A3"];
	self.syn["weapons"]["light_machine_guns"][1] = ["L86 LSW", "RPD", "PKM", "MG4", "AUG HBAR", "M240"];
	self.syn["weapons"]["machine_pistols"][1] =    ["FMG9", "PP2000", "G18", "M93 Raffica", "TMP"];
	self.syn["weapons"]["shotguns"][1] =           ["Spas-12", "AA-12", "KSG", "Striker", "Ranger", "W1200", "M1014", "Model 1887"];
	self.syn["weapons"]["pistols"][1] =            ["USP .45", ".44 Magnum", "M9", "P226", "M1911", "Desert Eagle", "MP412"];
	self.syn["weapons"]["launchers"][1] =          ["M320 GLM", "AT4", "Thumper", "FIM-92 Stinger", "FGM-148 Javelin", "RPG-7"];
	self.syn["weapons"]["melee"][1] =              ["Hatchet", "Sickle", "Shovel", "Ice Pick", "Karambit"];

	self.syn["weapons"]["equipment"][0] = ["h1_fraggrenade_mp", "h2_semtex_mp", "iw9_throwknife_mp", "h1_claymore_mp", "h1_c4_mp", "h1_flashgrenade_mp", "h1_concussiongrenade_mp", "h1_smokegrenade_mp"];
	self.syn["weapons"]["equipment"][1] = ["Frag Grenade", "Semtex Grenade", "Throwing Knife", "Claymore", "C4", "Flash Grenade", "Concussion Grenade", "Smoke Grenade"];

	// Attachments

	self.syn["weapons"]["attachments"] = ["acog", "akimbo", "fastfire", "fmj", "foregrip", "gl_glpre", "heartbeat", "holo", "reflex", "silencerar", "silencerlmg", "silencerpistol", "silencershotgun", "silencersmg", "silencersniper", "tacknife", "thermal", "xmag"];
	self.syn["weapons"]["assault_rifles"]["attachments"][0] =       ["gl_glpre", "reflex", "silencerar", "acog", "fmj", "holo", "thermal", "xmag", "heartbeat"];
	self.syn["weapons"]["assault_rifles"]["attachments"][1] =       ["Grenade Launcher", "Red Dot Sight", "Silencer", "Acog", "FMJ", "Holographic Sight", "Thermal", "Extended Mags", "Heartbeat Sensor"];
	self.syn["weapons"]["sub_machine_guns"]["attachments"][0] =     ["fastfire", "reflex", "silencersmg", "acog", "fmj", "akimbo", "holo", "thermal", "xmag"];
	self.syn["weapons"]["sub_machine_guns"]["attachments"][1] =     ["Rapid Fire", "Red Dot Sight", "Silencer", "Acog", "FMJ", "Akimbo", "Holographic Sight", "Thermal", "Extended Mags"];
	self.syn["weapons"]["sniper_rifles"]["attachments"][0] =        ["silencersniper", "acog", "fmj", "thermal", "xmag", "heartbeat"];
	self.syn["weapons"]["sniper_rifles"]["attachments"][1] =        ["Silencer (Sniper)", "Acog", "FMJ", "Thermal", "Extended Mags", "Heartbeat Sensor"];
	self.syn["weapons"]["sniper_rifles_alt"]["attachments"][0] =    ["silencersniper", "acog", "fmj", "thermal", "xmag"];
	self.syn["weapons"]["sniper_rifles_alt"]["attachments"][1] =    ["Silencer (Sniper)", "Acog", "FMJ", "Thermal", "Extended Mags"];
	self.syn["weapons"]["light_machine_guns"]["attachments"][0] =   ["foregrip", "reflex", "silencerlmg", "acog", "fmj", "holo", "thermal", "xmag", "heartbeat"];
	self.syn["weapons"]["light_machine_guns"]["attachments"][1] =   ["Foregrip", "Red Dot Sight", "Silencer", "Acog", "FMJ", "Holographic Sight", "Thermal", "Extended Mags", "Heartbeat Sensor"];
	self.syn["weapons"]["machine_pistols"]["attachments"][0] =      ["reflex", "fmj", "silencerpistol", "akimbo", "holo", "xmag"];
	self.syn["weapons"]["machine_pistols"]["attachments"][1] =      ["Red Dot Sight", "FMJ", "Silencer", "Akimbo", "Holographic Sight", "Extended Mags"];
	self.syn["weapons"]["shotguns"]["attachments"][0] =             ["foregrip", "reflex", "silencershotgun", "fmj", "holo", "xmag"];
	self.syn["weapons"]["shotguns"]["attachments"][1] =             ["Foregrip", "Red Dot Sight", "Silencer", "FMJ", "Holographic Sight", "Extended Mags"];
	self.syn["weapons"]["shotguns_alt"]["attachments"][0] =         ["fmj", "akimbo"]; // Ranger, Model
	self.syn["weapons"]["shotguns_alt"]["attachments"][1] =         ["FMJ", "Akimbo"];
	self.syn["weapons"]["h2_ksg_mp"]["attachments"][0] =            ["reflex", "silencershotgun", "fmj", "xmag"]; // KSG
	self.syn["weapons"]["h2_ksg_mp"]["attachments"][1] =            ["Red Dot Sight", "Silencer", "FMJ", "Extended Mags"];
	self.syn["weapons"]["h2_winchester1200_mp"]["attachments"][0] = ["foregrip", "reflex", "silencershotgun", "fmj", "holo"]; // W1200
	self.syn["weapons"]["h2_winchester1200_mp"]["attachments"][1] = ["Foregrip", "Red Dot Sight", "Silencer", "FMJ", "Holographic Sight"];
	self.syn["weapons"]["pistols"]["attachments"][0] =              ["fmj", "silencerpistol", "akimbo", "tacknife", "xmag"];
	self.syn["weapons"]["pistols"]["attachments"][1] =              ["FMJ", "Silencer", "Akimbo", "Tactical Knife", "Extended Mags"];
	self.syn["weapons"]["pistols_alt"]["attachments"][0] =          ["fmj", "tacknife", "akimbo"]; //Magnum, Deagle, MP412
	self.syn["weapons"]["pistols_alt"]["attachments"][1] =          ["FMJ", "Tactical Knife", "Akimbo"];

	// Perks

	//self.syn["perks"][0] = ["specialty_tacticalinsertion", "specialty_blastshield"];
	//self.syn["perks"][1] = ["Tactical Insertion", "Blast Shield"];
	self.syn["perks"][0] = ["specialty_bling", "specialty_radarimmune", "specialty_extendedmelee", "specialty_explosivedamage", "specialty_hardline", "specialty_pistoldeath", "specialty_lightweight", "specialty_longersprint", "specialty_heartbreaker", "specialty_onemanarmy", "specialty_scavenger", "specialty_localjammer", "specialty_detectexplosive", "specialty_fastreload", "specialty_bulletaccuracy", "specialty_bulletdamage"];
	self.syn["perks"][1] = ["Bling", "Cold Blooded", "Commando", "Danger Close", "Hardline", "Last Stand", "Lightweight", "Marathon", "Ninja", "One Man Army", "Scavenger", "Scrambler", "Sitrep", "Sleight of Hand", "Steady Aim", "Stopping Power"];

	self.syn["perks"][2] = ["specialty_secondarybling", "specialty_spygame", "specialty_falldamage", "specialty_dangerclose", "specialty_rollover", "specialty_laststandoffhand", "specialty_fastsprintrecovery", "specialty_fastmantle", "specialty_quieter", "specialty_omaquickchange", "specialty_extraammo", "specialty_delaymine", "specialty_selectivehearing", "specialty_quickdraw", "specialty_holdbreath", "specialty_armorpiercing"];
	self.syn["perks"][3] = ["Bling Pro", "Cold Blooded Pro", "Commando Pro", "Danger Close Pro", "Hardline Pro", "Last Stand Pro", "Lightweight Pro", "Marathon Pro", "Ninja Pro", "One Man Army Pro", "Scavenger Pro", "Scrambler Pro", "Sitrep Pro", "Sleight of Hand Pro", "Steady Aim Pro", "Stopping Power Pro"];

	// Killstreaks

	self.syn["killstreaks"][0] = ["radar_mp", "airdrop_marker_mp", "airdrop_trap_mp", "counter_radar_mp", "sentry_mp", "predator_mp", "remote_sentry_mp", "airstrike_mp", "helicopter_mp", "harrier_airstrike_mp", "advanced_uav_mp", "airdrop_mega_marker_mp", "stealth_airstrike_mp", "ah6_mp", "pavelow_mp", "reaper_mp", "ac130_mp", "chopper_gunner_mp", "emp_mp", "nuke_mp"];
	self.syn["killstreaks"][1] = ["UAV", "Care Package", "Airdrop Trap", "Counter-UAV", "Sentry Gun", "Predator Missile", "Remote Sentry", "Airstrike", "Helicopter", "Harrier Strike", "Advanced UAV", "Emergency Airdrop", "Stealth Bomber", "AH6 Overwatch", "Pavelow", "Reaper", "AC-130", "Chopper Gunner", "EMP", "Tactical Nuke"];

	// Bullets

	self.syn["bullets"][0] = ["ac130_25mm_mp", "ac130_40mm_mp", "ac130_105mm_mp", "remotemissile_projectile_mp"];
	self.syn["bullets"][1] = ["AC-130 25mm", "AC-130 40mm", "AC-130 105mm", "Predator Missile"];

	// Maps

	self.syn["maps"][0] = ["convoy", "backlot", "bloc", "bog", "bog_summer", "broadcast", "carentan", "countdown", "crash", "crash_snow", "creek", "crossfire", "citystreets", "downpour", "farm_spring", "killhouse", "overgrown", "pipeline", "shipment", "showdown", "strike", "vacant", "cargoship", "vlobby_room"];
	self.syn["maps"][1] = ["Ambush", "Backlot", "Bloc", "Bog", "Beach Bog", "Broadcast", "Chinatown", "Countdown", "Crash", "Winter Crash", "Creek", "Crossfire", "District", "Downpour", "Daybreak", "Killhouse", "Overgrown", "Pipeline", "Shipment", "Showdown", "Strike", "Vacant", "Wet Work", "Firing Range"];

	self.syn["maps"][2] = ["afghan", "complex", "abandon", "derail", "estate", "favela", "fuel2", "highrise", "invasion", "checkpoint", "quarry", "rundown", "rust", "compact", "boneyard", "nightshift", "storm", "subbase", "terminal", "trailerpark", "underpass", "brecourt"];
	self.syn["maps"][3] = ["Afghan", "Bailout", "Carnival", "Derail", "Estate", "Favela", "Fuel", "Highrise", "Invasion", "Karachi", "Quarry", "Rundown", "Rust", "Salvage", "Scrapyard", "Skidrow", "Storm", "Sub Base", "Terminal", "Trailer Park", "Underpass", "Wasteland"];

	self.syn["maps"][4] = ["plaza2", "mogadishu", "bootleg", "dome", "courtyard_ss", "lambeth", "hardhat", "alpha", "bravo", "paris", "seatown", "underground"];
	self.syn["maps"][5] = ["Arkaden", "Bakaara", "Bootleg", "Dome", "Erosion", "Fallen", "Hardhat", "Lockdown", "Mission", "Resistance", "Seatown", "Underground"];

	self.syn["maps"][6] = ["airport", "cliffhanger", "contingency", "dcburning", "boneyard", "gulag", "oilrig", "estate", "dc_whitehouse"];
	self.syn["maps"][7] = ["Airport", "Blizzard", "Contingency", "DC Burning", "Dumpsite", "Gulag", "Oilrig", "Safehouse", "Whiskey Hotel"];

	if(self.pers["prestige"] == 10) {
		self.set_10th_prestige = true;
	}
}

initialize_menu() {
	level endon("game_ended");
	self endon("disconnect");

	for(;;) {
	  event_name = self waittill_any_return("spawned_player", "player_downed", "death", "joined_spectators");
	  switch (event_name) {
	    case "spawned_player":
	      if(self isHost()) {
	        if(!self.hud_created) {
	          self freezeControls(false);

						setDvar("xblive_privatematch", 0);
						setDvar("onlinegame", 1);

	          self thread input_manager();

	          self.syn["string"] = self create_text("", "default", 1, "center", "top", 0, -100, (1, 1, 1), 0, 9999, false, true);

	          self.menu["border"] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset - 1), (self.y_offset - 1), 226, 122, self.color_theme, 1, 1);
	          self.menu["background"] = self create_shader("white", "TOP_LEFT", "TOPCENTER", self.x_offset, self.y_offset, 224, 121, (0.075, 0.075, 0.075), 1, 2);
	          self.menu["separator_1"] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 5.5), (self.y_offset + 7.5), 42, 1, self.color_theme, 1, 10);
	          self.menu["separator_2"] = self create_shader("white", "TOP_RIGHT", "TOPCENTER", (self.x_offset + 220), (self.y_offset + 7.5), 42, 1, self.color_theme, 1, 10);
	          self.menu["cursor"] = self create_shader("white", "TOP_LEFT", "TOPCENTER", self.x_offset, 215, 224, 16, (0.15, 0.15, 0.15), 0, 4);

	          self.menu["title"] = self create_text("Title", self.font, self.font_scale, "TOP_LEFT", "TOPCENTER", (self.x_offset + 94.5), (self.y_offset + 3), (1, 1, 1), 1, 10);
	          self.menu["description"] = self create_text("Description", self.font, self.font_scale, "TOP_LEFT", "TOPCENTER", (self.x_offset + 5), (self.y_offset + (self.option_limit * 17.5)), (0.75, 0.75, 0.75), 0, 10);

						self.menu["options"] = self create_text("", self.font, self.font_scale, "TOP_LEFT", "TOPCENTER", (self.x_offset + 5), (self.y_offset + 20), (0.75, 0.75, 0.75), 1, 10);
						self.menu["submenu_icons"] = self create_text("", self.font, self.font_scale, "TOP_LEFT", "TOPCENTER", (self.x_offset + 215), ((self.y_offset + 20)), (0.75, 0.75, 0.75), 0, 10);
						self.menu["slider_texts"] = self create_text("", self.font, self.font_scale, "TOP_LEFT", "TOPCENTER", (self.x_offset + 132.5), (self.y_offset + 20), (0.75, 0.75, 0.75), 0, 10);

						for(i = 1; i <= self.option_limit; i++) {
							self.menu["toggle_" + i] = self create_shader("white", "TOP_RIGHT", "TOPCENTER", (self.x_offset + 11), ((self.y_offset + 4) + (i * 16.5)), 8, 8, (0.25, 0.25, 0.25), 0, 9);
							self.menu["slider_" + i] = self create_shader("white", "TOP_LEFT", "TOPCENTER", self.x_offset, (self.y_offset + (i * 16.5)), 224, 16, (0.25, 0.25, 0.25), 0, 5);
						}

						// Currently Disabled due to HUD Limit
						self.menu["foreground"] = self create_shader("white", "TOP_LEFT", "TOPCENTER", self.x_offset, (self.y_offset + 15), 224, 106, (0.1, 0.1, 0.1), 1, 3);

	          self.hud_created = true;

	          self.menu["title"] set_text("Controls");

	          self.menu["options"] set_text("Open: ^3[{+speed_throw}] ^7and ^3[{+melee}]\n\nScroll: ^3[{+speed_throw}] ^7and ^3[{+attack}]\n\nSelect: ^3[{+activate}] ^7Back: ^3[{+melee}]\n\nSliders: ^3[{+smoke}] ^7and ^3[{+frag}]");

	          self.menu["border"] set_shader("white", self.menu["border"].width, 83);
	          self.menu["background"] set_shader("white", self.menu["background"].width, 81);
	          self.menu["foreground"] set_shader("white", self.menu["foreground"].width, 66);

	          self.controls_menu_open = true;

	          wait 8;

	          if(self.controls_menu_open) {
	            close_controls_menu();
	          }
	        }
	      }
	      break;
	    default:
	      if(!self isHost()) {
	        continue;
	      }

	      if(self.in_menu) {
	        self close_menu();
	      }
	      break;
	  }
	}
}

input_manager() {
	level endon("game_ended");
	self endon("disconnect");

	while(self isHost()) {
	  if(!self.in_menu) {
	    if(self adsButtonPressed() && self meleeButtonPressed()) {
	      if(self.controls_menu_open) {
	        close_controls_menu();
	      }

	      self playSoundToPlayer("h1_ui_menu_warning_box_appear", self);

	      open_menu();

	      while(self adsButtonPressed() && self meleeButtonPressed()) {
	        wait 0.2;
	      }
	    }
	  } else {
	    if(self meleeButtonPressed()) {
	      self.saved_index[self.current_menu] = self.cursor_index;
	      self.saved_offset[self.current_menu] = self.scrolling_offset;
	      self.saved_trigger[self.current_menu] = self.previous_trigger;

	      self playSoundToPlayer("h1_ui_pause_menu_resume", self);

	      if(isDefined(self.previous[(self.previous.size - 1)])) {
	        self new_menu();
	      } else {
	        self close_menu();
	      }

	      while(self meleeButtonPressed()) {
	        wait 0.2;
	      }
	    } else if(self adsButtonPressed() && !self attackButtonPressed() || self attackButtonPressed() && !self adsButtonPressed()) {

	      self playSoundToPlayer("h1_ui_menu_scroll", self);

	      scroll_cursor(set_variable(self attackButtonPressed(), "down", "up"));

	      wait (0.2);
	    } else if(self fragButtonPressed() && !self secondaryOffhandButtonPressed() || !self fragButtonPressed() && self secondaryOffhandButtonPressed()) {

	      self playSoundToPlayer("h1_ui_menu_scroll", self);

	      if(isDefined(self.structure[self.cursor_index].array) || isDefined(self.structure[self.cursor_index].increment)) {
	        scroll_slider(set_variable(self secondaryOffhandButtonPressed(), "left", "right"));
	      }

	      wait (0.2);
	    } else if(self useButtonPressed()) {
	      self.saved_index[self.current_menu] = self.cursor_index;
	      self.saved_offset[self.current_menu] = self.scrolling_offset;
	      self.saved_trigger[self.current_menu] = self.previous_trigger;

	      self playSoundToPlayer("mp_ui_decline", self);

	      if(self.structure[self.cursor_index].command == ::new_menu) {
	        self.previous_option = self.structure[self.cursor_index].text;
	      }

	      if(isDefined(self.structure[self.cursor_index].array) || isDefined(self.structure[self.cursor_index].increment)) {
	        if(isDefined(self.structure[self.cursor_index].array)) {
	          cursor_selected = self.structure[self.cursor_index].array[self.slider[(self.current_menu + "_" + self.cursor_index)]];
	        } else {
	          cursor_selected = self.slider[(self.current_menu + "_" + (self.cursor_index))];
	        }
	        self thread execute_function(self.structure[self.cursor_index].command, cursor_selected, self.structure[self.cursor_index].parameter_1, self.structure[self.cursor_index].parameter_2, self.structure[self.cursor_index].parameter_3);
	      } else if(isDefined(self.structure[self.cursor_index]) && isDefined(self.structure[self.cursor_index].command)) {
	        self thread execute_function(self.structure[self.cursor_index].command, self.structure[self.cursor_index].parameter_1, self.structure[self.cursor_index].parameter_2, self.structure[self.cursor_index].parameter_3);
	      }

	      self menu_option();
	      set_options();

	      while(self useButtonPressed()) {
	        wait 0.2;
	      }
	    }
	  }
	  wait 0.05;
	}
}

player_connect() {
	level endon("game_ended");

	for(;;) {
	  level waittill("connected", player);

	  if(isBot(player)) {
	    return;
	  }

	  player.access = player isHost() ? "Host" : "None";

	  player initial_variables();
	  player thread initialize_menu();
	}
}

// Hud Functions

open_menu() {
	self.in_menu = true;

	set_menu_visibility(1);

	self menu_option();
	scroll_cursor();
	set_options();
}

close_menu() {
	set_menu_visibility(0);

	self.in_menu = false;
}

close_controls_menu() {
	self.menu["border"] set_shader("white", self.menu["border"].width, 123);
	self.menu["background"] set_shader("white", self.menu["background"].width, 121);
	self.menu["foreground"] set_shader("white", self.menu["foreground"].width, 106);

	self.controls_menu_open = false;

	set_menu_visibility(0);

	self.menu["title"] set_text("");

	self.in_menu = false;
}

set_menu_visibility(opacity) {
	if(opacity == 0) {
	  self.menu["border"].alpha = opacity;
	  self.menu["description"].alpha = opacity;
	  for(i = 1; i <= self.option_limit; i++) {
	    self.menu["toggle_" + i].alpha = opacity;
	    self.menu["slider_" + i].alpha = opacity;
	  }
	}

	self.menu["title"].alpha = opacity;
	self.menu["separator_1"].alpha = opacity;
	self.menu["separator_2"].alpha = opacity;

	self.menu["options"].alpha = opacity;
	self.menu["submenu_icons"].alpha = opacity;
	self.menu["slider_texts"].alpha = opacity;

	waitframe();

	self.menu["background"].alpha = opacity;
	self.menu["foreground"].alpha = opacity;
	self.menu["cursor"].alpha = opacity;

	if(opacity == 1) {
	  self.menu["border"].alpha = opacity;
	}
}

create_text(text, font, font_scale, align_x, align_y, x_offset, y_offset, color, alpha, z_index, hide_when_in_menu) {
	textElement = self createFontString(font, font_scale);
	textElement setPoint(align_x, align_y, x_offset, y_offset);

	textElement.alpha = alpha;
	textElement.sort = z_index;
	textElement.anchor = self;
	textElement.archived = self auto_archive();

	if(isDefined(hide_when_in_menu)) {
	  textElement.hideWhenInMenu = hide_when_in_menu;
	} else {
	  textElement.hideWhenInMenu = true;
	}

	if(isDefined(color)) {
	  if(!isString(color)) {
	    textElement.color = color;
	  } else if(color == "rainbow") {
	    textElement.color = level.rainbow_color;
	    textElement thread start_rainbow();
	  }
	} else {
	  textElement.color = (0, 1, 1);
	}

	if(isDefined(text)) {
	  if(isNumber(text)) {
	    textElement setValue(text);
	  } else {
	    textElement set_text(text);
	  }
	}

	self.element_result++;
	return textElement;
}

set_text(text) {
	if(!isDefined(self) || !isDefined(text)) {
	  return;
	}

	self.text = text;
	self setText(text);
}

add_text(text, index) {
	if(!isDefined(self) || !isDefined(text)) {
		return;
	}

	self.text = text;
	self.text_array[index] = text + "\n\n";
}

set_text_array() {
	if(!isDefined(self)) {
		return;
	}

	if(!isDefined(self.previous_text)) {
		self.previous_text = "";
	}

	text = "";

	for(i = 1; i <= self.text_array.size; i++) {
		text = text + self.text_array[i];
	}

	if(text != self.previous_text) {
		self.previous_text = text;
		self setText(text);
	}
}

create_shader(shader, align_x, align_y, x_offset, y_offset, width, height, color, alpha, z_index, hide_when_in_menu) {
	shaderElement = newClientHudElem(self);
	shaderElement.elemType = "icon";
	shaderElement.children = [];
	shaderElement.alpha = alpha;
	shaderElement.sort = z_index;
	shaderElement.anchor = self;
	shaderElement.archived = self auto_archive();

	if(isDefined(hide_when_in_menu)) {
	  shaderElement.hideWhenInMenu = hide_when_in_menu;
	} else {
	  shaderElement.hideWhenInMenu = true;
	}

	if(isDefined(color)) {
	  if(!isString(color)) {
	    shaderElement.color = color;
	  } else if(color == "rainbow") {
	    shaderElement.color = level.rainbow_color;
	    shaderElement thread start_rainbow();
	  }
	} else {
	  shaderElement.color = (0, 1, 1);
	}

	shaderElement setParent(level.uiParent);
	shaderElement setPoint(align_x, align_y, x_offset, y_offset);

	shaderElement set_shader(shader, width, height);

	self.element_result++;
	return shaderElement;
}

set_shader(shader, width, height) {
	if(!isDefined(self)) {
	  return;
	}

	if(!isDefined(shader)) {
	  if(!isDefined(self.shader)) {
	    return;
	  }

	  shader = self.shader;
	}

	if(!isDefined(width)) {
	  if(!isDefined(self.width)) {
	    return;
	  }

	  width = self.width;
	}

	if(!isDefined(height)) {
	  if(!isDefined(self.height)) {
	    return;
	  }

	  height = self.height;
	}

	self.shader = shader;
	self.width = width;
	self.height = height;
	self setShader(shader, width, height);
}

auto_archive() {
	if(!isDefined(self.element_result)) {
	  self.element_result = 0;
	}

	if(!isAlive(self) || self.element_result > 22) {
	  return true;
	}

	return false;
}

update_element_positions() {
	self.menu["border"].x = (self.x_offset - 1);
	self.menu["border"].y = (self.y_offset - 1);

	self.menu["background"].x = self.x_offset;
	self.menu["background"].y = self.y_offset;

	self.menu["foreground"].x = self.x_offset;
	self.menu["foreground"].y = (self.y_offset + 15);

	self.menu["separator_1"].x = (self.x_offset + 5);
	self.menu["separator_1"].y = (self.y_offset + 7.5);

	self.menu["separator_2"].x = (self.x_offset + 220);
	self.menu["separator_2"].y = (self.y_offset + 7.5);

	self.menu["cursor"].x = self.x_offset;

	self.menu["description"].y = (self.y_offset + (self.option_limit * 17.5));

	self.menu["options"].x = (self.x_offset + 5);
	self.menu["options"].y = (self.y_offset + 20);

	self.menu["submenu_icons"].x = (self.x_offset + 215);
	self.menu["submenu_icons"].y = (self.y_offset + 20);

	self.menu["slider_texts"].x = (self.x_offset + 132.5);
	self.menu["slider_texts"].y = (self.y_offset + 20);

	for(i = 1; i <= self.option_limit; i++) {
		self.menu["toggle_" + i].x = (self.x_offset + 11);
		self.menu["toggle_" + i].y = ((self.y_offset + 4) + (i * 16.5));

		self.menu["slider_" + i].x = self.x_offset;
		self.menu["slider_" + i].y = (self.y_offset + (i * 16.5));
	}
}

// Colors

create_rainbow_color() {
	x = 0; y = 0;
	r = 0; g = 0; b = 0;
	level.rainbow_color = (0, 0, 0);

	level endon("game_ended");

	while(true) {
	  if(y >= 0 && y < 258) {
	    r = 255;
	    g = 0;
	    b = x;
	  } else if(y >= 258 && y < 516) {
	    r = 255 - x;
	    g = 0;
	    b = 255;
	  } else if(y >= 516 && y < 774) {
	    r = 0;
	    g = x;
	    b = 255;
	  } else if(y >= 774 && y < 1032) {
	    r = 0;
	    g = 255;
	    b = 255 - x;
	  } else if(y >= 1032 && y < 1290) {
	    r = x;
	    g = 255;
	    b = 0;
	  } else if(y >= 1290 && y < 1545) {
	    r = 255;
	    g = 255 - x;
	    b = 0;
	  }

	  x += 3;
	  if(x > 255) {
	    x = 0;
	  }

	  y += 3;
	  if(y > 1545) {
	    y = 0;
	  }

	  level.rainbow_color = (r/255, g/255, b/255);
	  wait 0.05;
	}
}

start_rainbow() {
	level endon("game_ended");
	self endon("stop_rainbow");
	self.rainbow_enabled = true;

	while(isDefined(self) && self.rainbow_enabled) {
	  self fadeOverTime(.05);
	  self.color = level.rainbow_color;
	  wait 0.05;
	}
}

// Misc Functions

return_toggle(variable) {
	return isDefined(variable) && variable;
}

return_false() {
	return false;
}

set_variable(check, option_1, option_2) {
	if(check) {
	  return option_1;
	} else {
	  return option_2;
	}
}

in_array(array, item) {
	if(!isDefined(array) || !isArray(array)) {
	  return;
	}

	for(a = 0; a < array.size; a++) {
	  if(array[a] == item) {
	    return true;
	  }
	}

	return false;
}

clean_name(name) {
	if(!isDefined(name) || name == "") {
	  return;
	}

	illegal = ["^A", "^B", "^F", "^H", "^I", "^0", "^1", "^2", "^3", "^4", "^5", "^6", "^7", "^8", "^9", "^:"];
	new_string = "";
	for(a = 0; a < name.size; a++) {
	  if(a < (name.size - 1)) {
	    if(in_array(illegal, (name[a] + name[(a + 1)]))) {
	      a += 2;
	      if(a >= name.size) {
	        break;
	      }
	    }
	  }

	  if(isDefined(name[a]) && a < name.size) {
	    new_string += name[a];
	  }
	}

	return new_string;
}

get_name() {
	name = self.name;
	if(name[0] != "[") {
	  return name;
	}

	for(a = (name.size - 1); a >= 0; a--) {
	  if(name[a] == "]") {
	    break;
	  }
	}

	return getSubStr(name, (a + 1));
}

player_damage_callback(inflictor, attacker, damage, flags, death_reason, weapon, point, direction, hit_location, time_offset) {
	self endon("disconnect");

	if(isDefined(self.god_mode) && self.god_mode) {
	  return;
	}

	[[level.originalCallbackPlayerDamage]](inflictor, attacker, damage, flags, death_reason, weapon, point, direction, hit_location, time_offset);
}

load_weapons(weapon_category) {
	for(i = 0; i < self.syn["weapons"][weapon_category][0].size; i++) {
		if(weapon_category == "equipment") {
			self add_option(self.syn["weapons"][weapon_category][1][i], undefined, ::give_weapon, self.syn["weapons"][weapon_category][0][i]);
		} else {
			self add_option(self.syn["weapons"][weapon_category][1][i], undefined, ::give_base_weapon, self.syn["weapons"][weapon_category][0][i]);
		}
	}
}

// Custom Structure

execute_function(command, parameter_1, parameter_2, parameter_3, parameter_4) {
	self endon("disconnect");

	if(!isDefined(command)) {
	  return;
	}

	if(isDefined(parameter_4)) {
	  return self thread[[command]](parameter_1, parameter_2, parameter_3, parameter_4);
	}

	if(isDefined(parameter_3)) {
	  return self thread[[command]](parameter_1, parameter_2, parameter_3);
	}

	if(isDefined(parameter_2)) {
	  return self thread[[command]](parameter_1, parameter_2);
	}

	if(isDefined(parameter_1)) {
	  return self thread[[command]](parameter_1);
	}

	self thread[[command]]();
}

add_option(text, description, command, parameter_1, parameter_2, parameter_3) {
	option = spawnStruct();
	option.text = text;
	if(isDefined(description)) {
	  option.description = description;
	}
	if(!isDefined(command)) {
	  option.command = ::empty_function;
	} else {
	  option.command = command;
	}
	if(isDefined(parameter_1)) {
	  option.parameter_1 = parameter_1;
	}
	if(isDefined(parameter_2)) {
	  option.parameter_2 = parameter_2;
	}
	if(isDefined(parameter_3)) {
	  option.parameter_3 = parameter_3;
	}

	self.structure[self.structure.size] = option;
}

add_toggle(text, description, command, variable, parameter_1, parameter_2) {
	option = spawnStruct();
	option.text = text;
	if(isDefined(description)) {
	  option.description = description;
	}
	if(!isDefined(command)) {
	  option.command = ::empty_function;
	} else {
	  option.command = command;
	}
	option.toggle = isDefined(variable) && variable;
	if(isDefined(parameter_1)) {
	  option.parameter_1 = parameter_1;
	}
	if(isDefined(parameter_2)) {
	  option.parameter_2 = parameter_2;
	}

	self.structure[self.structure.size] = option;
}

add_array(text, description, command, array, parameter_1, parameter_2, parameter_3) {
	option = spawnStruct();
	option.text = text;
	if(isDefined(description)) {
	  option.description = description;
	}
	if(!isDefined(command)) {
	  option.command = ::empty_function;
	} else {
	  option.command = command;
	}
	if(!isDefined(command)) {
	  option.array = [];
	} else {
	  option.array = array;
	}
	if(isDefined(parameter_1)) {
	  option.parameter_1 = parameter_1;
	}
	if(isDefined(parameter_2)) {
	  option.parameter_2 = parameter_2;
	}
	if(isDefined(parameter_3)) {
	  option.parameter_3 = parameter_3;
	}

	self.structure[self.structure.size] = option;
}

add_increment(text, description, command, start, minimum, maximum, increment, parameter_1, parameter_2) {
	option = spawnStruct();
	option.text = text;
	if(isDefined(description)) {
	  option.description = description;
	}
	if(!isDefined(command)) {
	  option.command = ::empty_function;
	} else {
	  option.command = command;
	}
	if(isNumber(start)) {
	  option.start = start;
	} else {
	  option.start = 0;
	}
	if(isNumber(minimum)) {
	  option.minimum = minimum;
	} else {
	  option.minimum = 0;
	}
	if(isNumber(maximum)) {
	  option.maximum = maximum;
	} else {
	  option.maximum = 10;
	}
	if(isNumber(increment)) {
	  option.increment = increment;
	} else {
	  option.increment = 1;
	}
	if(isDefined(parameter_1)) {
	  option.parameter_1 = parameter_1;
	}
	if(isDefined(parameter_2)) {
	  option.parameter_2 = parameter_2;
	}

	self.structure[self.structure.size] = option;
}

get_title_width(title) {
	letter_index = [" ", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];
	letter_width = [5, 12, 11, 11, 10, 10, 10, 11, 11, 5, 10, 10, 9, 12, 11, 11, 10, 12, 10, 19, 11, 10, 11, 14, 10, 11, 10];
	title_width = 0;

	for(i = 1; i < title.size; i++) {
	  for(x = 1; x < letter_index.size; x++) {
	    if(tolower(title[i]) == tolower(letter_index[x])) {
	      title_width = int(title_width) + int(letter_width[x]);
	    }
	  }
	}

	return title_width;
}

add_menu(title) {
	self.menu["title"] set_text(title);

	title_width = get_title_width(title);

	self.menu["title"].x = (self.x_offset + ceil((((-0.0000124 * title_width + 0.003832) * title_width - 0.52) * title_width + 115.258) * 10) / 10);
	self.menu["title"].y = (self.y_offset + 3);
}

new_menu(menu) {
	if(!isDefined(menu)) {
	  menu = self.previous[(self.previous.size - 1)];
	  self.previous[(self.previous.size - 1)] = undefined;
	} else {
	  self.previous[self.previous.size] = self.current_menu;
	}

	if(!isDefined(self.slider[(menu + "_" + (self.cursor_index))])) {
	  self.slider[(menu + "_" + (self.cursor_index))] = 0;
	}

	self.current_menu = set_variable(isDefined(menu), menu, "Synergy");

	if(isDefined(self.saved_index[self.current_menu])) {
	  self.cursor_index = self.saved_index[self.current_menu];
	  self.scrolling_offset = self.saved_offset[self.current_menu];
	  self.previous_trigger = self.saved_trigger[self.current_menu];
	  self.loaded_offset = true;
	} else {
	  self.cursor_index = 0;
	  self.scrolling_offset = 0;
	  self.previous_trigger = 0;
	}

	self menu_option();
	scroll_cursor();
}

empty_function() {}

empty_option() {
	option = ["Nothing To See Here!", "Quiet Here, Isn't It?", "Oops, Nothing Here Yet!", "Bit Empty, Don't You Think?"];
	return option[randomInt(option.size)];
}

scroll_cursor(direction) {
	maximum = self.structure.size - 1;
	fake_scroll = false;

	if(maximum < 0) {
	  maximum = 0;
	}

	if(isDefined(direction)) {
	  if(direction == "down") {
	    self.cursor_index++;
	    if(self.cursor_index > maximum) {
	      self.cursor_index = 0;
	      self.scrolling_offset = 0;
	    }
	  } else if(direction == "up") {
	    self.cursor_index--;
	    if(self.cursor_index < 0) {
	      self.cursor_index = maximum;
	      if(((self.cursor_index) + int((self.option_limit / 2))) >= (self.structure.size - 2)) {
	        self.scrolling_offset = (self.structure.size - self.option_limit);
	      }
	    }
	  }
	} else {
	  while(self.cursor_index > maximum) {
	    self.cursor_index--;
	  }
	  self.menu["cursor"].y = int(self.y_offset + (((self.cursor_index + 1) - self.scrolling_offset) * 16.5));
	}

	self.previous_scrolling_offset = self.scrolling_offset;

	if(!self.loaded_offset) {
	  if(self.cursor_index >= int(self.option_limit / 2) && self.structure.size > self.option_limit) {
	    if((self.cursor_index + int(self.option_limit / 2)) >= (self.structure.size - 2)) {
	      self.scrolling_offset = (self.structure.size - self.option_limit);
	      if(self.previous_trigger == 2) {
	        self.scrolling_offset--;
	      }
	      if(self.previous_scrolling_offset != self.scrolling_offset) {
	        fake_scroll = true;
	        self.previous_trigger = 1;
	      }
	    } else {
	      self.scrolling_offset = (self.cursor_index - int(self.option_limit / 2));
	      self.previous_trigger = 2;
	    }
	  } else {
	    self.scrolling_offset = 0;
	    self.previous_trigger = 0;
	  }
	}

	if(self.scrolling_offset < 0) {
	  self.scrolling_offset = 0;
	}

	if(!fake_scroll) {
	  self.menu["cursor"].y = int(self.y_offset + (((self.cursor_index + 1) - self.scrolling_offset) * 16.5));
	}

	if(isDefined(self.structure[self.cursor_index]) && isDefined(self.structure[self.cursor_index].description)) {
	  self.menu["description"] set_text(self.structure[self.cursor_index].description);
	  self.description_height = 15;

	  self.menu["description"].x = (self.x_offset + 5);
	  self.menu["description"].alpha = 1;
	} else {
	  self.menu["description"] set_text("");
	  self.menu["description"].alpha = 0;
	  self.description_height = 0;
	}

	self.loaded_offset = false;
	set_options();
}

scroll_slider(direction) {
	current_slider_index = self.slider[(self.current_menu + "_" + (self.cursor_index))];
	if(isDefined(direction)) {
	  if(isDefined(self.structure[self.cursor_index].array)) {
	    if(direction == "left") {
	      current_slider_index--;
	      if(current_slider_index < 0) {
	        current_slider_index = (self.structure[self.cursor_index].array.size - 1);
	      }
	    } else if(direction == "right") {
	      current_slider_index++;
	      if(current_slider_index > (self.structure[self.cursor_index].array.size - 1)) {
	        current_slider_index = 0;
	      }
	    }
	  } else {
	    if(direction == "left") {
	      current_slider_index -= self.structure[self.cursor_index].increment;
	      if(current_slider_index < self.structure[self.cursor_index].minimum) {
	        current_slider_index = self.structure[self.cursor_index].maximum;
	      }
	    } else if(direction == "right") {
	      current_slider_index += self.structure[self.cursor_index].increment;
	      if(current_slider_index > self.structure[self.cursor_index].maximum) {
	        current_slider_index = self.structure[self.cursor_index].minimum;
	      }
	    }
	  }
	}
	self.slider[(self.current_menu + "_" + (self.cursor_index))] = current_slider_index;
	set_options();
}

set_options() {
	for(i = 1; i <= self.option_limit; i++) {
	  self.menu["toggle_" + i].alpha = 0;
	  self.menu["slider_" + i].alpha = 0;

		self.menu["options"] add_text("", i);
		self.menu["submenu_icons"] add_text("", i);
		self.menu["slider_texts"] add_text("", i);
	}

	update_element_positions();

	if(isDefined(self.structure)) {
	  if(self.structure.size == 0) {
	    self add_option(empty_option());
	  }

	  self.maximum = int(min(self.structure.size, self.option_limit));

	  if(self.structure.size <= self.option_limit) {
	    self.scrolling_offset = 0;
	  }

	  for(i = 1; i <= self.maximum; i++) {
	    x = ((i - 1) + self.scrolling_offset);

	    self.menu["options"] add_text(self.structure[x].text, i);

	    if(isDefined(self.structure[x].toggle)) {
	      self.menu["options"].alpha = 1;
	      self.menu["toggle_" + i].alpha = 1;

	      if(self.structure[x].toggle) {
	        self.menu["toggle_" + i].color = (1, 1, 1);
	      } else {
	        self.menu["toggle_" + i].color = (0.25, 0.25, 0.25);
	      }
	    } else {
	      self.menu["toggle_" + i].alpha = 0;
	    }

	    if(isDefined(self.structure[x].array) && (self.cursor_index) == x) {
	      if(!isDefined(self.slider[(self.current_menu + "_" + x)])) {
	        self.slider[(self.current_menu + "_" + x)] = 0;
	      }

	      if(self.slider[(self.current_menu + "_" + x)] > (self.structure[x].array.size - 1) || self.slider[(self.current_menu + "_" + x)] < 0) {
	        self.slider[(self.current_menu + "_" + x)] = set_variable(self.slider[(self.current_menu + "_" + x)] > (self.structure[x].array.size - 1), 0, (self.structure[x].array.size - 1));
	      }

	      slider_text = self.structure[x].array[self.slider[(self.current_menu + "_" + x)]] + " [" + (self.slider[(self.current_menu + "_" + x)] + 1) + "/" + self.structure[x].array.size + "]";

	      self.menu["slider_texts"] add_text(slider_text, i);
	    } else if(isDefined(self.structure[x].increment) && (self.cursor_index) == x) {
	      value = abs((self.structure[x].minimum - self.structure[x].maximum)) / 224;
	      width = ceil((self.slider[(self.current_menu + "_" + x)] - self.structure[x].minimum) / value);

	      if(width >= 0) {
	        self.menu["slider_" + i] set_shader("white", int(width), 16);
	      } else {
	        self.menu["slider_" + i] set_shader("white", 0, 16);
	        self.menu["slider_" + i].alpha = 0;
	      }

	      if(!isDefined(self.slider[(self.current_menu + "_" + x)]) || self.slider[(self.current_menu + "_" + x)] < self.structure[x].minimum) {
	        self.slider[(self.current_menu + "_" + x)] = self.structure[x].start;
	      }

	      slider_value = self.slider[(self.current_menu + "_" + x)];

	      self.menu["slider_texts"] add_text(slider_value, i);
	      self.menu["slider_" + i].alpha = 1;
	    }

	    if(isDefined(self.structure[x].command) && self.structure[x].command == ::new_menu) {
	      self.menu["submenu_icons"] add_text(">", i);
	    }
	  }
	}

	self.menu["options"] set_text_array();
	self.menu["submenu_icons"] set_text_array();
	self.menu["slider_texts"] set_text_array();

	menu_height = int(18 + (self.maximum * 16.5));

	self.menu["description"].y = int((self.y_offset + 4) + ((self.maximum + 1) * 16.5));

	self.menu["border"] set_shader("white", self.menu["border"].width, int(menu_height + self.description_height));
	self.menu["background"] set_shader("white", self.menu["background"].width, int((menu_height - 2) + self.description_height));
	self.menu["foreground"] set_shader("white", self.menu["foreground"].width, int(menu_height - 17));
}

// Menu Options

menu_option() {
	self.structure = [];
	menu = self.current_menu;
	switch(menu) {
	  case "Synergy":
	    self add_menu(menu);

	    self add_option("Basic Options", undefined, ::new_menu, "Basic Options");
	    self add_option("Fun Options", undefined, ::new_menu, "Fun Options");
	    self add_option("Weapon Options", undefined, ::new_menu, "Weapon Options");
	    self add_option("Give Killstreaks", undefined, ::new_menu, "Give Killstreaks");
	    self add_option("Account Options", undefined, ::new_menu, "Account Options");
	    self add_option("Menu Options", undefined, ::new_menu, "Menu Options");
			self add_option("Map Options", undefined, ::new_menu, "Map Options");
			self add_option("Bot Options", undefined, ::new_menu, "Bot Options");
	    self add_option("All Players", undefined, ::new_menu, "All Players");
	    self add_option("Debug Options", undefined, ::new_menu, "Debug Options");

	    break;
	  case "Basic Options":
	    self add_menu(menu);

	    self add_toggle("     God Mode", "Makes you Invincible", ::god_mode, self.god_mode);
	    self add_toggle("     Frag No Clip", "Fly through the Map using (^3[{+frag}]^7)", ::frag_no_clip, self.frag_no_clip);
	    self add_toggle("     Infinite Ammo", "Gives you Infinite Ammo and Infinite Grenades", ::infinite_ammo, self.infinite_ammo);

			self add_toggle("     Rapid Fire", "Shoot Very Fast (Hold ^3[{+reload}]^7 & ^3[{+attack}])", ::rapid_fire, self.rapid_fire);
			self add_toggle("     No Recoil", "No Recoil while ADS & Firing", ::no_recoil, self.no_recoil);
			self add_toggle("     No Spread", "No Bullet Spread while Hip-firing", ::no_spread, self.no_spread);

	    self add_option("Give All Perks", undefined, ::give_all_perks);
	    self add_option("Take All Perks", undefined, ::take_all_perks);

	    self add_option("Give Perks", undefined, ::new_menu, "Give Perks");
	    self add_option("Take Perks", undefined, ::new_menu, "Take Perks");

	    break;
	  case "Fun Options":
	    self add_menu(menu);

	    self add_toggle("     Fullbright", "Removes all Shadows and Lighting", ::fullbright, self.fullbright);
	    self add_toggle("     Third Person", undefined, ::third_person, self.third_person);

			self add_toggle("     Super Jump", undefined, ::super_jump, self.super_jump);

	    self add_increment("Set Speed", undefined, ::set_speed, 190, 190, 990, 50);
	    self add_increment("Set Timescale", undefined, ::set_timescale, 1, 1, 10, 1);

	    self add_option("Visions", undefined, ::new_menu, "Visions");

	    break;
	  case "Weapon Options":
	    self add_menu(menu);

			category = get_category(getBaseWeaponName(self getCurrentWeapon()) + "_mp");

			self add_option("Give Weapons", undefined, ::new_menu, "Give Weapons");

			if(category != "launchers" && category != "equipment") {
				self add_option("Attachments", undefined, ::new_menu, "Attachments");
			}

			self add_option("Take Current Weapon", undefined, ::take_weapon);
			self add_option("Drop Current Weapon", undefined, ::drop_weapon);

			self add_option("Magic Bullets", undefined, ::new_menu, "Magic Bullets");

			break;
	  case "Give Killstreaks":
	    self add_menu(menu);

			for(i = 0; i < self.syn["killstreaks"][0].size; i++) {
				self add_option(self.syn["killstreaks"][1][i], undefined, ::give_killstreak, self.syn["killstreaks"][0][i]);
			}

	    break;
	  case "Account Options":
	    self add_menu(menu);

			self add_option("Rainbow Classes", "Set Rainbow Class Names", ::set_colored_classes);

			self add_increment("Set Prestige", undefined, ::set_prestige, 0, 0, 10, 1);

			if(isDefined(self.set_10th_prestige)) {
				self add_increment("Set Level", undefined, ::set_rank, 0, 0, 1000, 10);
			} else {
				self add_increment("Set Level", undefined, ::set_rank, 0, 0, 70, 1);
			}

			self add_option("Unlock All", undefined, ::set_challenges);

			break;
	  case "Menu Options":
	    self add_menu(menu);

	    self add_increment("Move Menu X", "Move the Menu around Horizontally", ::modify_menu_position, 0, -600, 20, 10, "x");
	    self add_increment("Move Menu Y", "Move the Menu around Vertically", ::modify_menu_position, 0, -100, 30, 10, "y");

	    self add_option("Rainbow Menu", "Set the Menu Outline Color to Cycling Rainbow", ::set_menu_rainbow);

	    self add_increment("Red", "Set the Red Value for the Menu Outline Color", ::set_menu_color, 255, 1, 255, 1, "Red");
	    self add_increment("Green", "Set the Green Value for the Menu Outline Color", ::set_menu_color, 255, 1, 255, 1, "Green");
	    self add_increment("Blue", "Set the Blue Value for the Menu Outline Color", ::set_menu_color, 255, 1, 255, 1, "Blue");

	    self add_toggle("     Hide UI", undefined, ::hide_ui, self.hide_ui);
	    self add_toggle("     Hide Weapon", undefined, ::hide_weapon, self.hide_weapon);

	    break;
		case "Map Options":
			self add_menu(menu);

			self add_option("Change Map", undefined, ::new_menu, "Change Map");
			self add_toggle("     No Fog", "Removes all Fog", ::no_fog, self.no_fog);
			self add_option("End Game", undefined, ::end_game);

			break;
		case "Change Map":
			self add_menu(menu);

			for(i = 0; i < self.syn["maps"][0].size; i++) {
				self add_option(self.syn["maps"][1][i], undefined, ::change_map, self.syn["maps"][0][i], i);
			}

			for(i = 0; i < self.syn["maps"][2].size; i++) {
				self add_option(self.syn["maps"][3][i], undefined, ::change_map, self.syn["maps"][2][i], i);
			}

			for(i = 0; i < self.syn["maps"][4].size; i++) {
				self add_option(self.syn["maps"][5][i], undefined, ::change_map, self.syn["maps"][4][i], i);
			}

			for(i = 0; i < self.syn["maps"][6].size; i++) {
				self add_option(self.syn["maps"][7][i], undefined, ::change_map, self.syn["maps"][6][i], i);
			}

			break;
		case "Bot Options":
			self add_menu(menu);

			self add_array("Set Difficulty", undefined, ::set_difficulty, ["Recruit", "Regular", "Hardened", "Veteran"]);

			self add_option("Spawn Friendly Bot", undefined, ::spawn_friendly_bot);
			self add_option("Spawn Enemy Bot", undefined, ::spawn_enemy_bot);
			self add_option("Kick Random Bot", undefined, ::kick_random_bot);

			break;
	  case "All Players":
	    self add_menu(menu);

	    foreach(player in level.players){
	      self add_option(player.name, undefined, ::new_menu, "Player Option", player);
	    }

	    break;
	  case "Player Option":
	    self add_menu(menu);

	    target = undefined;
	    foreach(player in level.players) {
	      if(player.name == self.previous_option) {
	        target = player;
	        break;
	      }
	    }

	    if(isDefined(target)) {
	      self add_option("Print", "Print Player Name", ::print_player_name, target);
	      self add_option("Kill", "Kill the Player", ::commit_suicide, target);

	      if(isBot(target)) {
	        self add_option("Get Difficulty", undefined, ::get_difficulty, target);
	      }

	      if(!target isHost()) {
	        self add_option("Kick", "Kick the Player from the Game", ::kick_player, target);
	      }
	    } else {
	      self add_option("Player not found");
	    }

	    break;
	  case "Give Perks":
	    self add_menu(menu);

			for(i = 0; i < self.syn["perks"][2].size; i++) {
				self add_option(self.syn["perks"][3][i], undefined, ::give_perk, self.syn["perks"][0][i], self.syn["perks"][2][i]);
			}

	    break;
	  case "Take Perks":
	    self add_menu(menu);

			for(i = 0; i < self.syn["perks"][2].size; i++) {
				self add_option(self.syn["perks"][3][i], undefined, ::take_perk, self.syn["perks"][0][i], self.syn["perks"][2][i]);
			}

	    break;
	  case "Visions":
	    self add_menu(menu);

	    for(i = 0; i < self.syn["visions"][0].size; i++) {
	      self add_option(self.syn["visions"][0][i], undefined, ::set_vision, self.syn["visions"][1][i]);
	    }

	    break;
	  case "Give Weapons":
	    self add_menu(menu);

			for(i = 0; i < self.syn["weapons"]["category"][1].size; i++) {
				self add_option(self.syn["weapons"]["category"][1][i], undefined, ::new_menu, self.syn["weapons"]["category"][1][i]);
			}

	    break;
		case "Attachments":
			self add_menu(menu);

			weapon_name = getBaseWeaponName(self getCurrentWeapon());
			category = get_category(getBaseWeaponName(self getCurrentWeapon()) + "_mp");

			if(category != "launchers" && category != "melee" && category != "equipment") {
				self add_option("Equip Attachment", undefined, ::new_menu, "Equip Attachment");
			}
			if(category != "launchers" && category != "equipment") {
				self add_option("Equip Camo", undefined, ::new_menu, "Equip Camo");
			}

			break;
		case "Equip Attachment":
			self add_menu(menu);

			weapon_name = getBaseWeaponName(self getCurrentWeapon());

			if(weapon_name == "h2_ranger" || weapon_name == "h2_model1887") {
				category = "shotguns_alt";
			} else if(weapon_name == "h2_ksg") {
				category = "h2_ksg_mp";
			} else if(weapon_name == "h2_winchester1200") {
				category = "h2_winchester1200_mp";
			} else if(weapon_name == "h2_coltanaconda" || weapon_name == "h2_deserteagle" || weapon_name == "h2_mp412") {
				category = "pistols_alt";
			} else if(weapon_name == "h2_m40a3" || weapon_name == "h2_usr" || weapon_name == "h2_d25s") {
				category = "sniper_rifles_alt";
			} else {
				category = get_category(weapon_name + "_mp");
			}

			for(i = 0; i < self.syn["weapons"][category]["attachments"][0].size; i++) {
				self add_option(self.syn["weapons"][category]["attachments"][1][i], undefined, ::equip_attachment, self.syn["weapons"][category]["attachments"][0][i], category);
			}

			break;
		case "Equip Camo":
			self add_menu(menu);

			self add_increment("Equip Camo", undefined, ::equip_camo, 1, 1, 45, 1);
			self add_toggle("     Cycle Camos", undefined, ::cycle_camos, self.cycle_camos);

			break;
	  case "Magic Bullets":
			self add_menu(menu);

			for(i = 0; i < self.syn["bullets"][0].size; i++) {
				self add_toggle(self.syn["bullets"][1][i], undefined, ::modify_bullet, self.bullet[i], self.syn["bullets"][0][i], i);
			}

			break;
	  case "Assault Rifles":
	    self add_menu(menu);

	    load_weapons("assault_rifles");

	    break;
	  case "Sub Machine Guns":
	    self add_menu(menu);

	    load_weapons("sub_machine_guns");

	    break;
	  case "Light Machine Guns":
	    self add_menu(menu);

	    load_weapons("light_machine_guns");

	    break;
	  case "Sniper Rifles":
	    self add_menu(menu);

	    load_weapons("sniper_rifles");

	    break;
	  case "Shotguns":
	    self add_menu(menu);

	    load_weapons("shotguns");

	    break;
	  case "Pistols":
	    self add_menu(menu);

	    load_weapons("pistols");

	    break;
	  case "Melee Weapons":
	    self add_menu(menu);

	    load_weapons("melee");

	    break;
	  case "Equipment":
	    self add_menu(menu);

	    load_weapons("equipment");

	    break;
	  case "Debug Options":
	    self add_menu(menu);

	    self add_toggle("     Get Current Weapon", undefined, ::get_weapon, self.get_weapon);
	    self add_option("Get All Weapons", undefined, ::get_all_weapons);

	    self add_toggle("     Get Current Postion", undefined, ::get_position, self.get_position);
	    self add_option("Test Function", undefined, ::test_function);

	    break;
	  default:
	    if(!isDefined(self.selected_player)) {
	      self.selected_player = self;
	    }

	    self player_option(menu, self.selected_player);
	    break;
	}
}

player_option(menu, player) {
	if(!isDefined(menu) || !isDefined(player) || !isPlayer(player)) {
	  menu = "Error";
	}

	switch (menu) {
	  case "Player Option":
	    self add_menu(clean_name(player get_name()));
	    break;
	  case "Error":
	    self add_menu();
	    self add_option("Oops, Something Went Wrong!", "Condition: Undefined");
	    break;
	  default:
	    error = true;
	    if(error) {
	      self add_menu("Critical Error");
	      self add_option("Oops, Something Went Wrong!", "Condition: Menu Index");
	    }
	    break;
	}
}

// Debug Options

test_function() {
	iPrintString(self getweaponslistoffhands()[0]);
	wait 2;
	iPrintString(self getweaponslistoffhands()[1]);
	wait 2;
	iPrintString(getBaseWeaponName(self getCurrentWeapon()));
}

get_weapon() {
	self.get_weapon = !return_toggle(self.get_weapon);
	if(self.get_weapon) {
	  self thread get_weapon_loop();
	} else {
	  self notify("stop_get_weapon");
	}
}

get_weapon_loop() {
	self endon("stop_get_weapon");
	self endon("game_ended");

	for(;;) {
	  iPrintString(self getCurrentWeapon());
	  wait 2.5;
	}
}

get_all_weapons() {
	weapons = self getWeaponsListPrimaries();
	iPrintString(weapons[0]);
	wait 2.5;
	iPrintString(weapons[1]);
	wait 2.5;
	iPrintString(weapons[2]);
	wait 2.5;
	iPrintString(weapons[3]);
	wait 2.5;
	iPrintString(weapons[4]);
}

get_position() {
	self.get_position = !return_toggle(self.get_position);
	if(self.get_position) {
	  self thread get_position_loop();
	} else {
	  self notify("stop_get_position");
	  self.syn["position"][0] destroy();
	}
}

get_position_loop() {
	self endon("stop_get_position");
	self endon("disconnect");
	level endon("game_ended");

	for(;;) {
	  if(!isDefined(self.syn["position"])) {
	    self.syn["position"][0] = self create_text(self.origin + " | " + self.angles, "default", 1, "right", "bottom", 0, 190, (0, 1, 1), 1, 9999, false);
	  } else {
	    if(self.syn["position"][0].text != self.origin + " | " + self.angles) {
	      self.syn["position"][0] set_text(self.origin + " | " + self.angles);
	    }
	  }
	  wait 1;
	}
}

// Menu Options

iPrintString(string) {
	if(!isDefined(self.syn["string"])) {
	  self.syn["string"] = self create_text(string, "default", 1, "center", "top", 0, -100, (1, 1, 1), 1, 9999, false, true);
	} else {
	  self.syn["string"] set_text(string);
	}
	self.syn["string"] notify("stop_hud_fade");
	self.syn["string"].alpha = 1;
	self.syn["string"] setText(string);
	self.syn["string"] thread fade_hud(0, 2.5);
}

fade_hud(alpha, time) {
	self endon("stop_hud_fade");
	self fadeOverTime(time);
	self.alpha = alpha;
	wait time;
}

modify_menu_position(offset, axis) {
	if(axis == "x") {
	  self.x_offset = 175 + offset;
	} else {
	  self.y_offset = 160 + offset;
	}
	self close_menu();
	self open_menu();
}

set_menu_rainbow() {
	if(!isString(self.color_theme)) {
	  self.color_theme = "rainbow";
	  self.menu["border"] thread start_rainbow();
	  self.menu["separator_1"] thread start_rainbow();
	  self.menu["separator_2"] thread start_rainbow();
	  self.menu["border"].color = self.color_theme;
	  self.menu["separator_1"].color = self.color_theme;
	  self.menu["separator_2"].color = self.color_theme;
	}
}

set_menu_color(value, color) {
	if(color == "Red") {
	  self.menu_color_red = value;
	  iPrintString(color + " Changed to " + value);
	} else if(color == "Green") {
	  self.menu_color_green = value;
	  iPrintString(color + " Changed to " + value);
	} else if(color == "Blue") {
	  self.menu_color_blue = value;
	  iPrintString(color + " Changed to " + value);
	} else {
	  iPrintString(value + " | " + color);
	}
	self.color_theme = (self.menu_color_red / 255, self.menu_color_green / 255, self.menu_color_blue / 255);
	self.menu["border"] notify("stop_rainbow");
	self.menu["separator_1"] notify("stop_rainbow");
	self.menu["separator_2"] notify("stop_rainbow");
	self.menu["border"].rainbow_enabled = false;
	self.menu["separator_1"].rainbow_enabled = false;
	self.menu["separator_2"].rainbow_enabled = false;
	self.menu["border"].color = self.color_theme;
	self.menu["separator_1"].color = self.color_theme;
	self.menu["separator_2"].color = self.color_theme;
}

hide_ui() {
	self.hide_ui = !return_toggle(self.hide_ui);
	setDvar("cg_draw2d", !self.hide_ui);
}

hide_weapon() {
	self.hide_weapon = !return_toggle(self.hide_weapon);
	setDvar("cg_drawgun", !self.hide_weapon);
}

// Basic Options

god_mode() {
	self.god_mode = !return_toggle(self.god_mode);
	if(self.god_mode) {
		iPrintString("God Mode [^2ON^7]");
	} else {
		iPrintString("God Mode [^1OFF^7]");
	}
}

frag_no_clip() {
	self endon("disconnect");
	self endon("game_ended");

	if(!isDefined(self.frag_no_clip)) {
		self.frag_no_clip = true;
		iPrintString("Frag No Clip [^2ON^7], Press ^3[{+frag}]^7 to Enter and ^3[{+melee}]^7 to Exit");
		while (isDefined(self.frag_no_clip)) {
			if(self fragButtonPressed()) {
				if(!isDefined(self.frag_no_clip_loop)) {
					self thread frag_no_clip_loop();
				}
			}
			wait 0.05;
		}
	} else {
		self.frag_no_clip = undefined;
		iPrintString("Frag No Clip [^1OFF^7]");
	}
}

frag_no_clip_loop() {
	self endon("disconnect");
	self endon("noclip_end");

	self disableWeapons();
	self disableOffHandWeapons();
	self.frag_no_clip_loop = true;

	clip = spawn("script_origin", self.origin);
	self playerLinkTo(clip);
	if(!isDefined(self.god_mode) || !self.god_mode) {
		god_mode();
		self.temp_god_mode = true;
	}

	while (true) {
		vec = anglesToForward(self getPlayerAngles());
		end = (vec[0] * 60, vec[1] * 60, vec[2] * 60);
		if(self attackButtonPressed()) {
			clip.origin = clip.origin + end;
		}
		if(self adsButtonPressed()) {
			clip.origin = clip.origin - end;
		}
		if(self meleeButtonPressed()) {
			break;
		}
		wait 0.05;
	}

	clip delete();
	self enableWeapons();
	self enableOffhandWeapons();

	if(isDefined(self.temp_god_mode)) {
		god_mode();
		self.temp_god_mode = undefined;
	}

	self.frag_no_clip_loop = undefined;
}

infinite_ammo() {
	self.infinite_ammo = !return_toggle(self.infinite_ammo);
	if(self.infinite_ammo) {
		iPrintString("Infinite Ammo [^2ON^7]");
		self thread infinite_ammo_loop();
	} else {
		iPrintString("Infinite Ammo [^1OFF^7]");
		self notify("stop_infinite_ammo");
	}
}

infinite_ammo_loop() {
	self endon("stop_infinite_ammo");
	self endon("game_ended");

	for(;;) {
		self setWeaponAmmoClip(self getCurrentWeapon(), 999);
		self setWeaponAmmoClip(self getCurrentWeapon(), 999, "left");
		self setWeaponAmmoClip(self getCurrentWeapon(), 999, "right");
		
		self setWeaponAmmoStock(self getCurrentWeapon(), 999);
		self setWeaponAmmoStock(self getCurrentWeapon(), 999, "left");
		self setWeaponAmmoStock(self getCurrentWeapon(), 999, "right");
		
		wait 0.2;
	}
}

rapid_fire() { // Kony's Weapon Menu
	self.rapid_fire = !return_toggle(self.rapid_fire);
	if(self.rapid_fire) {
		self iPrintString("Rapid Fire [^2ON^7]");
		self giveperk( "specialty_fastreload", false);
		setDvar("perk_weapReloadMultiplier", 0.001);
	} else {
		self iPrintString("Rapid Fire [^1OFF^7]");
		setDvar("perk_weapReloadMultiplier", 1);
	}
}

no_recoil() {
	self.no_recoil = !return_toggle(self.no_recoil);
	if(self.no_recoil) {
		self iPrintString("No Recoil [^2ON^7]");
		self setRecoilScale(100);
	} else {
		self iPrintString("No Recoil [^1OFF^7]");
		self setRecoilScale(1);
	}
}

no_spread() {
	self.no_spread = !return_toggle(self.no_spread);
	if(self.no_spread) {
		self iPrintString("No Spread [^2ON^7]");
		setDvar("perk_weapSpreadMultiplier", 0.001);
		self giveperk("specialty_bulletaccuracy", false);
	} else {
		self iPrintString("No Spread [^1OFF^7]");
		setDvar("perk_weapSpreadMultiplier", 1);
	}
}

// Fun Options

fullbright() {
	self.fullbright = !return_toggle(self.fullbright);
	if(self.fullbright) {
		iPrintString("Fullbright [^2ON^7]");
		setDvar("r_fullbright", 1);
		wait 0.01;
	} else {
		iPrintString("Fullbright [^1OFF^7]");
		setDvar("r_fullbright", 0);
		wait 0.01;
	}
}

third_person() {
	self.third_person = !return_toggle(self.third_person);
	if(self.third_person) {
		iPrintString("Third Person [^2ON^7]");
		setDvar("camera_thirdPerson", 1);
	} else {
		iPrintString("Third Person [^1OFF^7]");
		setDvar("camera_thirdPerson", 0);
	}
}

set_speed(value) {
	setDvar("g_speed", value);
}

set_timescale(value) {
	setDvar("timescale", value);
}

super_jump() {
	self.super_jump = !return_toggle(self.super_jump);
	if(self.super_jump) {
		setDvar("jump_height", 999);
		if(!isDefined(self.god_mode) || !self.god_mode) {
			god_mode();
			self.jump_god_mode = true;
		}
		iPrintString("Super Jump [^2ON^7]");
	} else {
		setDvar("jump_height", 39);
		if(isDefined(self.jump_god_mode)) {
			god_mode();
			self.jump_god_mode = undefined;
		}
		iPrintString("Super Jump [^1OFF^7]");
	}
}

set_vision(vision) {
	self visionSetNakedForPlayer("", 0.1);
	wait 0.25;
	self visionSetNakedForPlayer(vision, 0.1);
}

end_game() {
	setDvar("xblive_privatematch", 1);
	exitLevel(0);
}

// Player Options

print_player_name(target) {
	iPrintString(target);
}

commit_suicide(target) {
	target suicide();
}

kick_player(target) {
	kick(target getEntityNumber());
}

// Killstreaks

give_killstreak(streak) {
	self maps\mp\gametypes\_hardpoints::giveHardpoint(streak, 1);
}

// Perks

give_all_perks() {
	for(i = 0; i < self.syn["perks"][0].size; i++) {
		self giveperk(self.syn["perks"][0][i]);
		self giveperk(self.syn["perks"][2][i]);
	}

	waitFrame();
	maps\mp\perks\_perks::applyperks();
}

take_all_perks() {
	for(i = 0; i < self.syn["perks"][0].size; i++) {
		scripts\mp\utility_patches::_unsetperk_stub(self.syn["perks"][0][i]);
		scripts\mp\utility_patches::_unsetperk_stub(self.syn["perks"][2][i]);
	}

	waitFrame();
	maps\mp\perks\_perks::applyperks();
}

give_perk(perk, pro_perk) { // Retropack
	self giveperk(perk);
	self giveperk(pro_perk);

	waitFrame();
	maps\mp\perks\_perks::applyperks();
}

take_perk(perk, pro_perk) { // Retropack
	if(_hasperk(perk)) {
		scripts\mp\utility_patches::_unsetperk_stub(perk);
		scripts\mp\utility_patches::_unsetperk_stub(pro_perk);

		waitFrame();
		maps\mp\perks\_perks::applyperks();
	}
}

// Weapon Options

get_category(weapon) {
	foreach(weapon_category in self.syn["weapons"]["category"][0]) {
		foreach(weapon_id in self.syn["weapons"][weapon_category][0]) {
			if(weapon_id == weapon) {
				return weapon_category;
			}
		}
	}
}

check_weapons(weapon) {
	return self getCurrentWeapon() != weapon && self getWeaponsListPrimaries()[1] != weapon;
}

give_weapon(weapon) {
	if(weapon == "specialty_tacticalinsertion") {
		weapon = "flare_mp";
		self setLethalWeapon(weapon);
		_giveWeapon(weapon);
		self giveMaxAmmo(weapon);
	} else if(weapon == "specialty_blastshield") {
		self giveperk("specialty_blastshield");
		self setLethalWeapon(weapon);
		_giveWeapon(weapon);
		self giveMaxAmmo(weapon);
	} else {
		_giveWeapon(weapon);
		self switchToWeapon(weapon);
		wait 1;
		self setWeaponAmmoClip(self getCurrentWeapon(), 999);
		self setWeaponAmmoClip(self getCurrentWeapon(), 999, "left");
		self setWeaponAmmoClip(self getCurrentWeapon(), 999, "right");
	}
}

give_base_weapon(weapon) {
	if(check_weapons(weapon)) {
		max_weapon_num = 2;
		if(self getWeaponsListPrimaries().size >= max_weapon_num) {
			self take_weapon(self getCurrentWeapon());
		}

		iPrintString(weapon);
		self give_weapon(weapon);
	}
}

equip_attachment(attachment, category) {
	weapon = getBaseWeaponName(self getCurrentWeapon()) + "_mp";
	weapon_split = strtok(self getCurrentWeapon(), "_");
	weapon_camo = undefined;
	weapon_scope = undefined;

	for(i = 3; i < weapon_split.size; i++) {
		if(issubstr(weapon_split[i], "camo")) {
			weapon_camo = "_" + weapon_split[i];
		}
	}

	for(i = 2; i < weapon_split.size; i++) {
		if(issubstr(weapon_split[i], "scope")) {
			weapon_scope = "_" + weapon_split[i];
		}
	}

	if(isDefined(weapon_scope)) {
		iPrintString(weapon_scope);
	} else {
		weapon_scope = "";
	}

	if(!isDefined(weapon_camo)) {
		weapon_camo = "";
	}

	if(attachment == "tacknife") {
		if(weapon == "h2_usp_mp") {
			attachment = "tacknifeusp";
		} else if(weapon == "h2_coltanaconda_mp") {
			attachment = "tacknifecolt44";
		} else if(weapon == "h2_m9_mp") {
			attachment = "tacknifem9";
		} else if(weapon == "h2_colt45_mp") {
			attachment = "tacknifecolt45";
		} else if(weapon == "h2_deserteagle_mp") {
			attachment = "tacknifedeagle";
		} else if(weapon == "h2_mp412_mp") {
			attachment = "tacknifemp412";
		}
	}

	if(check_weapons(weapon + "_" + weapon_scope + attachment + weapon_camo)) {
		weapon_attached = weapon + "_" + weapon_scope + attachment + weapon_camo;
		self take_weapon(self getCurrentWeapon());
		self give_weapon(weapon_attached);
	} else {
		self switchToWeapon(weapon);
	}
}

equip_camo(camo) {
	weapon = getBaseWeaponName(self getCurrentWeapon()) + "_mp";
	weapon_split = strtok(self getCurrentWeapon(), "_");
	weapon_attachment = undefined;

	for(i = 3; i < weapon_split.size; i++) {
		if(array_contains(self.syn["weapons"]["attachments"], weapon_split[i])) {
			weapon_attachment = "_" + weapon_split[i];
		} else if(weapon_split[i] == "gl" || weapon_split[i] == "glpre") {
			weapon_attachment = "_gl_glpre";
		}
	}

	if(!isDefined(weapon_attachment)) {
		weapon_attachment = "";
	}

	iPrintString(weapon_attachment);

	if(camo < 10) {
		camo = "00" + camo;
	} else if(int(camo) > 9 && int(camo) < 100) {
		camo = "0" + camo;
	}

	weapon_painted = weapon + weapon_attachment + "_camo" + camo;
	if(check_weapons(weapon_painted)) {
		self take_weapon(self getCurrentWeapon());
		self give_weapon(weapon_painted);
		self switchToWeapon(weapon_painted);
	} else {
		self switchToWeapon(weapon);
	}
}

cycle_camos() {
	self.cycle_camos = !return_toggle(self.cycle_camos);
	if(self.cycle_camos) {
		self iPrintString("Cycle Camos [^2ON^7]");
		self thread cycle_camos_loop();
	} else {
		self iPrintString("Cycle Camos [^1OFF^7]");
		self notify("stop_cycle_camos");
	}
}

cycle_camos_loop() {
	self endon("stop_cycle_camos");
	self endon("game_ended");

	for(;;) {
		for(i = 1; i < 45; i++) {
			equip_camo(i);
			wait 0.2;
		}
	}
}

take_weapon() {
	self takeweapon(self getCurrentWeapon());
	self switchToWeapon(self getWeaponsListPrimaries()[1]);
}

drop_weapon() {
	self dropItem(self getCurrentWeapon());
	self switchToWeapon(self getWeaponsListPrimaries()[0]);
}

modify_bullet(bullet, i) {
	self.bullet[i] = !return_toggle(self.bullet[i]);
	if(self.bullet[i]) {
		iPrintString(self.syn["bullets"][1][i] + " [^2ON^7]");
		self thread modify_bullet_loop(bullet);
	} else {
		iPrintString(self.syn["bullets"][1][i] + " [^1OFF^7]");
		self notify("stop_modify_bullet_loop");
	}
}

modify_bullet_loop(bullet) {
	self endon("stop_modify_bullet_loop");
	self endon("disconnect");

	for(;;) {
		self waittill("weapon_fired");

		start = self getEye();
		end = vectorScale(anglesToForward(self getPlayerAngles()), 9999);

		magicBullet(bullet, start, bulletTrace(start, start + end, false, undefined)["position"], self);
	}
}

// Account Options

set_colored_classes() {
	if(!self.coloredClasses) {
		self.coloredClasses = true;
		for(i = 0; i < 25; i++) {
			self setplayerdata(getstatsgroup_ranked(), "customClasses", i, "name", "^:" + self getplayerdata(common_scripts\utility::getstatsgroup_ranked(), "customClasses", i, "name"));
		}
		for(i = 0; i < 5; i++) {
			self setplayerdata(getstatsgroup_private(), "privateMatchCustomClasses", i, "name", "^:" + self getplayerdata(common_scripts\utility::getstatsgroup_private(), "privateMatchCustomClasses", i, "name"));
		}
		iPrintString("Colored Classes Set");
	}
}

update_status(element, text) {
	self endon("stop_updating_status");
	status = text + "...";
	for(;;) {
		if(status == text + "...") {
			status = text + ".";
			element setText(status);
		} else if(status == text + ".") {
			status = text + "..";
			element setText(status);
		} else if(status == text + "..") {
			status = text + "...";
			element setText(status);
		}
		wait 0.5;
	}
}

set_challenges() { // Retropack
	self endon("disconnect");
	self endon("death");

	setDvar("xblive_privatematch", 0);
	setDvar("onlinegame", 1);
	self.god_mode = true;
	chalProgress = 0;
	progress_bar = self create_shader("white", "top_left", "center", 0, -100, 1, 10, self.color_theme, 1, 9999);
	progress_outline = self create_shader("white", "center", "top", 0, -105, 132, 37, self.color_theme, 1, 1);
	progress_background = self create_shader("white", "center", "top", 0, -105, 130, 35, (0.075, 0.075, 0.075), 1, 2);
	progress_text = self create_text("Unlocking All", "default", 1, "center", "top", 0, -115, (1, 1, 1), 1, 9999, true);
	self thread update_status(progress_text, "Unlocking All");
	if(self.in_menu) {
		self close_menu();
	}
	foreach(challengeRef, challengeData in level.challengeInfo) {
		finalTarget = 0;
		finalTier = 0;
		for(tierId = 1; isDefined(challengeData["targetval"][tierId]); tierId++) {
			finalTarget = challengeData["targetval"][tierId];
			finalTier = tierId + 1;
		}
		if(self isItemUnlocked(challengeRef)) {
			self setplayerdata(getstatsgroup_ranked(), "challengeProgress", challengeRef, finalTarget);
			self setplayerdata(getstatsgroup_ranked(), "challengeState", challengeRef, finalTier);
		}
		chalProgress++;
		chalPercent = ceil(((chalProgress / level.challengeInfo.size) * 100));
		progress_bar set_shader("white", int(chalPercent), 10);
		waitFrame();
	}
	progress_bar destroyElem();
	progress_outline destroyElem();
	progress_background destroyElem();
	progress_text destroyElem();

	self notify("stop_updating_status");

	iPrintString("Unlock All Completed");
	self.god_mode = false;

	setDvar("xblive_privatematch", 1);
	exitLevel(0);
}

set_rank(value) {
	if(value != 0) {
		value--;
	}

	if(value == 999) {
		rank_xp = 2516000 + (81300 * (value - 69));
	} else if(value > 69) {
		rank_xp = 2516000 + (81300 * (value - 69)) - 81300;
	} else if(value == 69) {
		rank_xp = 2434700;
	} else {
		rank_xp = int(tableLookup("mp/rankTable.csv", 0, value, (value == int(tableLookup("mp/rankTable.csv", 0, "maxrank", 1))) ? 7 : 2));
	}

	self maps\mp\gametypes\_rank::giverankxp(undefined, rank_xp, undefined, undefined, false);
	self maps\mp\gametypes\_persistence::statset("experience", rank_xp);
	iPrintString(self.name + "^7's Level set to " + (value + 1));
}

set_prestige(value) {
	if(value == 20) {
		self.set_20th_prestige = true;
	} else {
		self.set_20th_prestige = undefined;
	}

	self maps\mp\gametypes\_persistence::statset("prestige", value);
	iPrintString(self.name + "^7's Prestige set to " + value);
}

// Map Options

no_fog() {
	self.no_fog = !return_toggle(self.no_fog);
	if(self.no_fog) {
		iPrintString("No Fog [^2ON^7]");
		setDvar("r_fog", 0);
	} else {
		iPrintString("No Fog [^1OFF^7]");
		setDvar("r_fog", 1);
	}
}

change_map(map, i) {
	iPrintString("Changing Map to: " + self.syn["maps"][1][i]);
	wait 1;
	setDvar("ui_mapname", "mp_" + map);
	end_game();
}

// Bot Options

set_difficulty(difficulty) {
	level.bot_difficulty = difficulty;
	iPrintString(level.bot_difficulty);
}

get_difficulty(target) {
	iPrintString(target.difficulty);
}

spawn_friendly_bot() {
	level thread spawn_bot(self.team);
}

spawn_enemy_bot() {
	level thread spawn_bot(maps\mp\gametypes\_gameobjects::getenemyteam(self.team));
}

kick_random_bot() {
	random_num = int(randomintrange(0, level.players.size));
	if(isBot(level.players[random_num])) {
		kick(level.players[random_num] getEntityNumber());
		return;
	} else {
		kick_random_bot();
	}
}

spawn_bot(team) { // Retropack
	level thread _spawn_bot(1, team, undefined, "spawned_player", level.bot_difficulty);
}

_spawn_bot(count, team, callback, notifyWhendone, difficulty) { // Retropack
	time = getTime() + 10000;
	connectingArray = [];
	squad_index = connectingArray.size;
	while (level.players.size < maps\mp\bots\_bots_util::bot_get_client_limit() && connectingArray.size < count && getTime() < time) {
		maps\mp\gametypes\_hostMigration::waitLongDurationWithHostMigrationPause(0.05);
		botEnt = addBot("Synergy", team);
		connecting = spawnStruct();
		connecting.bot = botEnt;
		connecting.ready = 0;
		connecting.abort = 0;
		connecting.index = squad_index;
		connecting.difficulty = difficulty;
		connectingArray[connectingArray.size] = connecting;
		connecting.bot thread maps\mp\bots\_bots::spawn_bot_latent(team, callback, connecting);
		connecting.bot set_team_forced(team);
		squad_index++;
		waitFrame();
	}

	connectedComplete = 0;
	time = getTime() + 60000;
	while (connectedComplete < connectingArray.size && getTime() < time) {
		connectedComplete = 0;
		foreach(connecting in connectingArray) {
			if(connecting.ready || connecting.abort) {
				connectedComplete++;
			}
		}
		wait 0.05;
	}

	if(isDefined(notifyWhendone)) {
		self notify(notifyWhendone);
	}
}

set_team_forced(team) { // Retropack
	self waittill_any("joined_team");
	waitFrame();
	self.pers["forced_team"] = team;
	self maps\mp\gametypes\_menus::addToTeam(team, true);
}