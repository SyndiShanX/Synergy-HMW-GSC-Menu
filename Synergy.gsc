#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

init() {
	executeCommand("sv_cheats 1");

	level initial_precache();
	level thread player_connect();
	level thread create_rainbow_color();
	
	replaceFunc(maps\mp\gametypes\_gamelogic::onForfeit, ::return_false); // Retropack
	replaceFunc(maps\mp\gametypes\_gamelogic::matchstarttimerwaitforplayers, maps\mp\gametypes\_gamelogic::matchStartTimerSkip); //SimonLFC - Retropack
	level.OriginalCallbackPlayerDamage = level.callbackPlayerDamage; //doktorSAS - Retropack
	level.callbackPlayerDamage = ::player_damage_callback; // Retropack
	level.rankedmatch = 1; // Retropack

	level thread session_expired();
}

initial_precache() {
	precacheshader("ui_scrollbar_arrow_right");
	precacheshader("ui_scrollbar_arrow_left");
}

initial_variable() {
	self.menu = [];
	self.cursor = [];
	self.slider = [];
	self.previous = [];
	self.previous_option = undefined;

	self.font = "default";
	self.font_scale = 0.7;
	self.option_limit = 9;
	self.option_spacing = 16;
	self.x_offset = 175;
	self.y_offset = 160;
	self.width = -20;
	self.interaction_enabled = true;
	self.description_enabled = true;
	self.randomizing_enabled = true;
	self.scrolling_buffer = 3;
	
	self set_menu();
	self set_title();
	
	self.menu_color_red = 255;
	self.menu_color_green = 255;
	self.menu_color_blue = 255;
	self.color_theme = "rainbow";
	
	self.syn["visions"][0] = ["None", "AC-130", "AC-130 inverted", "Black & White", "Endgame", "Night", "Night Vision", "MP Intro", "MP Nuke Aftermath", "Sepia"];
	self.syn["visions"][1] = ["", "ac130", "ac130_inverted", "missilecam", "end_game", "default_night", "default_night_mp", "mpintro", "mpnuke_aftermath", "sepia"];
	
	self.syn["weapons"]["category"][0] = ["assault_rifles", "sub_machine_guns", "sniper_rifles", "light_machine_guns", "machine_pistols", "shotguns", "pistols", "launchers", "melee", "equipment"];
	self.syn["weapons"]["category"][1] = ["Assault Rifles", "Sub Machine Guns", "Sniper Rifles", "Light Machine Guns", "Machine Pistols", "Shotguns", "Pistols", "Launchers", "Melee Weapons", "Equipment"];
	// Weapon IDs Plus Default Attachments
	self.syn["weapons"]["assault_rifles"][0] =     ["h2_m4_mp", "h2_famas_mp", "h2_scar_mp", "h2_cm901_mp", "h2_tavor_mp", "h2_fal_mp", "h2_m16_mp", "h2_g36c_mp", "h2_masada_mp", "h2_fn2000_mp", "h2_ak47_mp"];
	self.syn["weapons"]["sub_machine_guns"][0] =   ["h2_mp5k_mp", "h2_ump45_mp", "h2_kriss_mp", "h2_p90_mp", "h2_pm9_mp", "h2_uzi_mp", "h2_mp7_mp", "h2_ak74u_mp"];
	self.syn["weapons"]["sniper_rifles"][0] =      ["h2_cheytac_mp", "h2_barrett_mp", "h2_as50_mp", "h2_d25s_mp", "h2_wa2000_mp", "h2_m21_mp", "h2_msr_mp", "h2_m40a3_mp"];
	self.syn["weapons"]["light_machine_guns"][0] = ["h2_sa80_mp", "h2_rpd_mp", "h2_pkm_mp", "h2_mg4_mp", "h2_aug_mp", "h2_m240_mp"];
	self.syn["weapons"]["machine_pistols"][0] =    ["h2_fmg9_mp", "h2_pp2000_mp", "h2_glock_mp", "h2_beretta393_mp", "h2_tmp_mp"];
	self.syn["weapons"]["shotguns"][0] =           ["h2_spas12_mp", "h2_aa12_mp", "h2_ksg_mp", "h2_striker_mp", "h2_ranger_mp", "h2_winchester1200_mp", "h2_m1014_mp", "h2_model1887_mp"];
	self.syn["weapons"]["pistols"][0] =            ["h2_usp_mp", "h2_coltanaconda_mp", "h2_m9_mp", "h2_colt45_mp", "h2_deserteagle_mp", "h2_mp412_mp"];
	self.syn["weapons"]["launchers"][0] =          ["h2_m320_mp", "at4_mp", "h2_m79_mp", "stinger_mp", "javelin_mp", "h2_rpg_mp"];
	self.syn["weapons"]["melee"][0] =              ["h2_hatchet_mp", "h2_sickle_mp", "h2_shovel_mp", "h2_icepick_mp", "h2_karambit_mp"];
	// Weapon Names
	self.syn["weapons"]["assault_rifles"][1] =     ["M4A1", "Famas", "Scar-H", "CM901", "Tar-21", "FAL", "M16A4", "G36C", "ACR", "F2000", "AK-47"];
	self.syn["weapons"]["sub_machine_guns"][1] =   ["MP5K", "UMP45", "Vector", "P90", "PP90M1", "Mini-Uzi", "MP7", "AK-74u"];
	self.syn["weapons"]["sniper_rifles"][1] =      ["Intervention", "Barret .50CAL", "AS50", "D25S", "WA2000", "M21", "MSR", "M40A3"];
	self.syn["weapons"]["light_machine_guns"][1] = ["L86 LSW", "RPD", "PKM", "MG4", "AUG HBAR", "M240"];
	self.syn["weapons"]["machine_pistols"][1] =    ["FMG9", "PP2000", "G18", "M93 Raffica", "TMP"];
	self.syn["weapons"]["shotguns"][1] =           ["Spas-12", "AA-12", "KSG", "Striker", "Ranger", "W1200", "M1014", "Model 1887"];
	self.syn["weapons"]["pistols"][1] =            ["USP .45", ".44 Magnum", "M9", "M1911", "Desert Eagle", "MP412"];
	self.syn["weapons"]["launchers"][1] =          ["M320 GLM", "AT4", "Thumper", "FIM-92 Stinger", "FGM-148 Javelin", "RPG-7"];
	self.syn["weapons"]["melee"][1] =              ["Hatchet", "Sickle", "Shovel", "Ice Pick", "Karambit"];
	// Equipment
	self.syn["weapons"]["equipment"][0] = ["h1_fraggrenade_mp", "h2_semtex_mp", "iw9_throwknife_mp", "h1_claymore_mp", "h1_c4_mp", "h1_flashgrenade_mp", "h1_concussiongrenade_mp", "h1_smokegrenade_mp"];
	self.syn["weapons"]["equipment"][1] = ["Frag Grenade", "Semtex Grenade", "Throwing Knife", "Claymore", "C4", "Flash Grenade", "Concussion Grenade", "Smoke Grenade"];
	//Weapon Attachments
	self.syn["weapons"]["attachments"] = ["acog", "akimbo", "fastfire", "fmj", "foregrip", "gl_glpre", "heartbeat", "holo", "reflex", "silencerar", "silencerlmg", "silencerpistol", "silencershotgun", "silencersmg", "silencersniper", "tacknife", "thermal", "xmag"];
	self.syn["weapons"]["assault_rifles"]["attachments"][0] =       ["gl_glpre", "reflex", "silencerar", "acog", "fmj", "holo", "thermal", "xmag", "heartbeat"];
	self.syn["weapons"]["assault_rifles"]["attachments"][1] =       ["Grenade Launcher", "Red Dot Sight", "Silencer", "Acog", "FMJ", "Holographic Sight", "Thermal", "Extended Mags", "Heartbeat Sensor"];
	self.syn["weapons"]["sub_machine_guns"]["attachments"][0] =     ["fastfire", "reflex", "silencersmg", "acog", "fmj", "akimbo", "holo", "thermal", "xmag"];
	self.syn["weapons"]["sub_machine_guns"]["attachments"][1] =     ["Rapid Fire", "Red Dot Sight", "Silencer", "Acog", "FMJ", "Akimbo", "Holographic Sight", "Thermal", "Extended Mags"];
	self.syn["weapons"]["sniper_rifles"]["attachments"][0] =        ["silencersniper", "acog", "fmj", "thermal", "xmag", "heartbeat"];
	self.syn["weapons"]["sniper_rifles"]["attachments"][1] =        ["Silencer (Sniper)", "Acog", "FMJ", "Thermal", "Extended Mags", "Heartbeat Sensor"];
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
	// Killstreaks
	self.syn["killstreaks"][0] = ["radar_mp", "airdrop_marker_mp", "counter_radar_mp", "predator_mp", "sentry_mp", "airstrike_mp", "harrier_airstrike_mp", "helicopter_mp", "airdrop_mega_marker_mp", "advanced_uav_mp", "pavelow_mp", "stealth_airstrike_mp", "ah6_mp", "reaper_mp", "ac130_mp", "chopper_gunner_mp", "emp_mp", "nuke_mp"];
	self.syn["killstreaks"][1] = ["UAV", "Care Package", "Counter-UAV", "Predator Missile", "Sentry Gun", "Precision Airstrike", "Harrier", "Attack Helicopter", "Emergency Airdrop", "Advanced UAV", "Pavelow", "Stealth Bomber", "AH6 Overwatch", "Reaper", "AC130", "Chopper Gunner", "EMP", "Tactical Nuke"];
	// Bullets
	self.syn["bullets"] = ["ac130_105mm_mp", "ac130_40mm_mp", "ac130_25mm_mp", "harrier_20mm_mp", "remotemissile_projectile_mp", "cobra_20mm_mp"];
	// Map Names
	self.syn["maps"] = ["underground", "trailerpark", "paris", "nightshift", "lambeth", "hardhat", "courtyard_ss", "complex", "compact", "checkpoint", "brecourt", "bravo", "bootleg", "vlobby_room", "abandon", "alpha", "crash", "crossfire", "backlot", "bog", "overgrown", "shipment", "strike", "wetwork", "vacant", "bloc", "countdown", "favela", "highrise", "invasion", "quarry", "rundown", "skidrow", "terminal", "underpass", "rust", "estate", "fuel2", "derail", "subbase", "storm", "boneyard", "afghan", "carbon", "interchange", "village"];
	
	if(self.pers["prestige"] == 10) {
		self.set_10th_prestige = true;
	}
}

initial_observer() {
	level endon("game_ended");
	self endon("disconnect");
	while(self has_access()) {
		if(!self in_menu()) {
			if(self adsButtonPressed() && self meleeButtonPressed()) {
				if(self.interaction_enabled) {
					self playSoundToPlayer("h1_ui_menu_warning_box_appear", self);
				}

				close_controls_menu();
				self open_menu();
				
				while(self adsButtonPressed() && self meleeButtonPressed()) {
					wait 0.2;
				}
			}
		} else {
			menu = self get_menu();
			cursor = self get_cursor();
			if(self meleeButtonPressed()) {
				if(self.interaction_enabled) {
					self playSoundToPlayer("h1_ui_pause_menu_resume", self);
				}

				if(isDefined(self.previous[(self.previous.size - 1)])) {
					self new_menu();
				} else {
					self close_menu();
				}

				while(self meleeButtonPressed()) {
					wait 0.2;
				}
			} else if(self adsButtonPressed() && !self attackButtonPressed() || self attackButtonPressed() && !self adsButtonPressed()) {
				if(isDefined(self.structure) && self.structure.size >= 2) {
					if(self.interaction_enabled) {
						self playSoundToPlayer("h1_ui_menu_scroll", self);
					}

					scrolling = self attackButtonPressed() ? 1 : -1;

					self set_cursor((cursor + scrolling));
					self update_scrolling(scrolling);
				}

				wait (0.05 * self.scrolling_buffer);
			} else if(self fragButtonPressed() && !self secondaryOffhandButtonPressed() || !self fragButtonPressed() && self secondaryOffhandButtonPressed()) {
				if(isDefined(self.structure[cursor].array) || isDefined(self.structure[cursor].increment)) {
					if(self.interaction_enabled) {
						self playSoundToPlayer("h1_ui_menu_scroll", self);
					}

					scrolling = self secondaryOffhandButtonPressed() ? 1 : -1;

					self update_slider(scrolling);
					self update_progression();
				}

				wait (0.05 * self.scrolling_buffer);
			} else if(self useButtonPressed()) {
				if(isDefined(self.structure[cursor]) && isDefined(self.structure[cursor].function)) {
					if(self.interaction_enabled) {
						self playSoundToPlayer("mp_ui_decline", self);
					}
					
					if(self.structure[cursor].function == ::new_menu) {
						self.previous_option = self.structure[cursor].text;
					}

					if(isDefined(self.structure[cursor].array) || isDefined(self.structure[cursor].increment)) {
						self thread execute_function(self.structure[cursor].function, isDefined(self.structure[cursor].array) ? self.structure[cursor].array[self.slider[(menu + "_" + cursor)]] : self.slider[(menu + "_" + cursor)], self.structure[cursor].parameter_1, self.structure[cursor].parameter_2);
					} else {
						self thread execute_function(self.structure[cursor].function, self.structure[cursor].parameter_1, self.structure[cursor].parameter_2);
					}

					if(isDefined(self.structure[cursor]) && isDefined(self.structure[cursor].toggle)) {
						self update_display();
					}
				}

				while(self useButtonPressed()) {
					wait 0.1;
				}
			}
		}
		wait 0.05;
	}
}

event_system() {
	level endon("game_ended");
	self endon("disconnect");
	for (;;) {
		event_name = self waittill_any_return("spawned_player", "player_downed", "death", "joined_spectators");
		switch (event_name) {
			case "spawned_player":
				self.spawn_origin = self.origin;
				self.spawn_angles = self.angles;
				if(!isDefined(self.finalized) && self has_access()) {
					self.finalized = true;
					
					if(self isHost()) {
						self freezeControls(false);
					}
					
					setdvar("xblive_privatematch", 0);
		
					self initial_variable();
					self thread initial_observer();
					
					self.controls["title"] = self create_text("Controls", self.font, self.font_scale, "TOP_LEFT", "TOPCENTER", (self.x_offset + 99), (self.y_offset + 4), self.color_theme, 1, 10);
					self.controls["separator"][0] = self create_shader("white", "TOP_LEFT", "TOPCENTER", 181, (self.y_offset + 7.5), 37, 1, self.color_theme, 1, 10);
					self.controls["separator"][1] = self create_shader("white", "TOP_RIGHT", "TOPCENTER", 399, (self.y_offset + 7.5), 37, 1, self.color_theme, 1, 10);
					self.controls["border"] = self create_shader("white", "TOP_LEFT", "TOPCENTER", self.x_offset, (self.y_offset - 1), (self.width + 250), 97, self.color_theme, 1, 1);
					self.controls["background"] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 1), self.y_offset, (self.width + 248), 95, (0.075, 0.075, 0.075), 1, 2);
					self.controls["foreground"] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 1), (self.y_offset + 16), (self.width + 248), 79, (0.1, 0.1, 0.1), 1, 3);
					
					self.controls["text"][0] = self create_text("Open: ^3[{+speed_throw}] ^7and ^3[{+melee}]", self.font, 0.9, "TOP_LEFT", "TOPCENTER", (self.x_offset + 4), (self.y_offset + 20), (0.75, 0.75, 0.75), 1, 10);
					self.controls["text"][1] = self create_text("Scroll: ^3[{+speed_throw}] ^7and ^3[{+attack}]", self.font, 0.9, "TOP_LEFT", "TOPCENTER", (self.x_offset + 4), (self.y_offset + 40), (0.75, 0.75, 0.75), 1, 10);
					self.controls["text"][2] = self create_text("Select: ^3[{+activate}] ^7Back: ^3[{+melee}]", self.font, 0.9, "TOP_LEFT", "TOPCENTER", (self.x_offset + 4), (self.y_offset + 60), (0.75, 0.75, 0.75), 1, 10);
					self.controls["text"][3] = self create_text("Sliders: ^3[{+smoke}] ^7and ^3[{+frag}]", self.font, 0.9, "TOP_LEFT", "TOPCENTER", (self.x_offset + 4), (self.y_offset + 80), (0.75, 0.75, 0.75), 1, 10);
					
					wait 8;
					
					close_controls_menu();
				}
				break;
			default:
				if(!self has_access()) {
					continue;
				}
		
				if(self in_menu()) {
					self close_menu();
				}
				break;
		}
	}
}

session_expired() {
	level waitTill("game_ended");
	level endon("game_ended");
	foreach(index, player in level.players) {
		if(!player has_access()) {
			continue;
		}

		if(player in_menu()) {
			player close_menu();
		}
	}
}

player_connect() {
	for(;;) {
		level waitTill("connected", player);
		player.access = player isHost() ? "Host" : "None";
		
		if(isBot(player)) {
			return;
		}
		
		player thread event_system();
	}
}

player_disconnect() {
	[[level.player_disconnect]]();
}

player_damage(einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime) {
	if(isDefined(self.god_mode) && self.god_mode) {
		return;
	}
	[[level.player_damage]](einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime);
}

player_downed(einflictor, eattacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration) {
	self notify("player_downed");
	[[level.player_downed]](einflictor, eattacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration);
}

// Utilities

in_array(array, item) {
	if(!isDefined(array) || !isArray(array)) {
		return;
	}

	for (a = 0; a < array.size; a++) {
		if(array[a] == item) {
			return true;
		}
	}

	return false;
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

create_rainbow_color() {
	x = 0; y = 0;
	r = 0; g = 0; b = 0;
	level.rainbow_color = (0, 0, 0);
	
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
		wait .05;
	}
}

start_rainbow() {
	while(isDefined(self)) {
		self fadeOverTime(.05);
		self.color = level.rainbow_color;
		wait .05;
	}
}

create_text(text, font, font_scale, align_x, align_y, x_offset, y_offset, color, alpha, z_index, hide_when_in_menu) {
	textElement = self maps\mp\gametypes\_hud_util::createFontString(font, font_scale);
	textElement maps\mp\gametypes\_hud_util::setPoint(align_x, align_y, x_offset, y_offset);

	textElement.alpha = alpha;
	textElement.sort = z_index;
	textElement.anchor = self;
	textElement.archived = self auto_archive();
	
	if(isDefined(hide_when_in_menu)) {
		textElement.hideWhenInMenu = hide_when_in_menu;
	} else {
		textElement.hideWhenInMenu = true;
	}
	
	if(color != "rainbow") {
		textElement.color = color;
	} else {
		textElement.color = level.rainbow_color;
		textElement thread start_rainbow();
	}
	
	if(isNumber(text)) {
		textElement setValue(text);
	} else {
		textElement set_text(text);
	}

	self.element_result++;
	return textElement;
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
	
	if(color != "rainbow") {
		shaderElement.color = color;
	} else {
		shaderElement.color = level.rainbow_color;
		shaderElement thread start_rainbow();
	}

	shaderElement maps\mp\gametypes\_hud_util::setParent(level.uiParent);
	shaderElement maps\mp\gametypes\_hud_util::setPoint(align_x, align_y, x_offset, y_offset);
	
	shaderElement set_shader(shader, width, height);

	self.element_result++;
	return shaderElement;
}

set_text(text) {
	if(!isDefined(self) || !isDefined(text)) {
		return;
	}

	self.text = text;
	self setText(text);
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

clean_text(text) {
	if(!isDefined(text) || text == "") {
		return;
	}

	if(text[0] == toUpper(text[0])) {
		if(isSubStr(text, " ") && !isSubStr(text, "_")) {
			return text;
		}
	}

	text = strTok(toLower(text), "_");
	new_string = "";
	for (a = 0; a < text.size; a++) {
		illegal = ["player", "weapon", "wpn", "viewmodel", "camo"];
		replacement = " ";
		if(in_array(illegal, text[a])) {
			for (b = 0; b < text[a].size; b++) {
				if(b != 0) {
					new_string += text[a][b];
				} else {
					new_string += toUpper(text[a][b]);
				}
			}

			if(a != (text.size - 1)) {
				new_string += replacement;
			}
		}
	}

	return new_string;
}

clean_name(name) {
	if(!isDefined(name) || name == "") {
		return;
	}

	illegal = ["^A", "^B", "^F", "^H", "^I", "^0", "^1", "^2", "^3", "^4", "^5", "^6", "^7", "^8", "^9", "^:"];
	new_string = "";
	for (a = 0; a < name.size; a++) {
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

destroy_element() {
	if(!isDefined(self)) {
		return;
	}

	self destroy();
	if(isDefined(self.anchor)) {
		self.anchor.element_result--;
	}
}

destroy_all(array) {
	if(!isDefined(array) || !isArray(array)) {
		return;
	}

	keys = getarraykeys(array);
	for (a = 0; a < keys.size; a++) {
		if(isArray(array[keys[a]])) {
			foreach(index, value in array[keys[a]]) {
				if(isDefined(value)) {
					value destroy_element();
				}
			}
		} else {
			if(isDefined(array[keys[a]])) {
				array[keys[a]] destroy_element();
			}
		}
	}
}

destroy_option() {
	element = ["text", "submenu", "toggle", "slider"];
	for (a = 0; a < element.size; a++) {
		if(isDefined(self.menu[element[a]]) && self.menu[element[a]].size) {
			destroy_all(self.menu[element[a]]);
		}

		self.menu[element[a]] = [];
	}
}

get_name() {
	name = self.name;
	if(name[0] != "[") {
		return name;
	}

	for (a = (name.size - 1); a >= 0; a--) {
		if(name[a] == "]") {
			break;
		}
	}

	return getSubStr(name, (a + 1));
}

has_access() {
	return isDefined(self.access) && self.access != "None";
}

calculate_distance(origin, destination, velocity) {
	return (distance(origin, destination) / velocity);
}

// Structure

set_menu(menu) {
	self.current_menu = isDefined(menu) ? menu : "Synergy";
}

get_menu() {
	if(!isDefined(self.current_menu)) {
		self set_menu();
	}

	return self.current_menu;
}

set_title(title) {
	self.current_title = isDefined(title) ? title : self get_menu();
}

get_title() {
	if(!isDefined(self.current_title)) {
		self set_title();
	}

	return self.current_title;
}

set_cursor(index) {
	self.cursor[self get_menu()] = isDefined(index) && isNumber(index) ? index : 0;
}

get_cursor() {
	if(!isDefined(self.cursor[self get_menu()])) {
		self set_cursor();
	}

	return self.cursor[self get_menu()];
}

get_description() {
	return self.structure[self get_cursor()].description;
}

set_state(state) {
	self.in_menu = isDefined(state) && state < 2 ? state : false;
}

in_menu() {
	return isDefined(self.in_menu) && self.in_menu;
}

set_locked(state) {
	self.is_locked = isDefined(state) && state < 2 ? state : false;
}

is_locked() {
	return isDefined(self.is_locked) && self.is_locked;
}

empty_option() {
	option = ["Nothing To See Here!", "Quiet Here, Isn't It?", "Oops, Nothing Here Yet!", "Bit Empty, Don't You Think?"];
	return option[randomInt(option.size)];
}

empty_function() {}

execute_function(function, parameter_1, parameter_2, parameter_3) {
	self endon("disconnect");
	if(!isDefined(function)) {
		return;
	}

	if(isDefined(parameter_3)) {
		return self thread[[function]](parameter_1, parameter_2, parameter_3);
	}

	if(isDefined(parameter_2)) {
		return self thread[[function]](parameter_1, parameter_2);
	}

	if(isDefined(parameter_1)) {
		return self thread[[function]](parameter_1);
	}

	self thread[[function]]();
}

add_menu(title, menu_size, extra) {
	self.structure = [];
	self set_title(title);
	
	if(!isDefined(self get_cursor())) {
		self set_cursor();
	}
	
	if(isDefined(extra)) {
		self.menu["title"].x = (self.x_offset + 106) - menu_size - extra;
	} else {
		if(menu_size <= 7) {
			self.menu["title"].x = (self.x_offset + 106) - menu_size;
		} else {
			self.menu["title"].x = (self.x_offset + 106) - (menu_size * 1.4);
		}
	}
}

add_option(text, description, function, parameter_1, parameter_2) {
	option = spawnStruct();
	option.text = text;
	option.description = description;
	option.function = isDefined(function) ? function : ::empty_function;
	option.parameter_1 = parameter_1;
	option.parameter_2 = parameter_2;

	self.structure[self.structure.size] = option;
}

add_toggle(text, description, function, variable, parameter_1, parameter_2) {
	option = spawnStruct();
	option.text = text;
	option.description = description;
	option.function = isDefined(function) ? function : ::empty_function;
	option.toggle = isDefined(variable) && variable;
	option.parameter_1 = parameter_1;
	option.parameter_2 = parameter_2;

	self.structure[self.structure.size] = option;
}

add_array(text, description, function, array, parameter_1, parameter_2) {
	option = spawnStruct();
	option.text = text;
	option.description = description;
	option.function = isDefined(function) ? function : ::empty_function;
	option.array = isDefined(array) && isArray(array) ? array : [];
	option.parameter_1 = parameter_1;
	option.parameter_2 = parameter_2;

	self.structure[self.structure.size] = option;
}

add_increment(text, description, function, start, minimum, maximum, increment, parameter_1, parameter_2) {
	option = spawnStruct();
	option.text = text;
	option.description = description;
	option.function = isDefined(function) ? function : ::empty_function;
	option.start = isDefined(start) && isNumber(start) ? start : 0;
	option.minimum = isDefined(minimum) && isNumber(minimum) ? minimum : 0;
	option.maximum = isDefined(maximum) && isNumber(maximum) ? maximum : 10;
	option.increment = isDefined(increment) && isNumber(increment) ? increment : 1;
	option.parameter_1 = parameter_1;
	option.parameter_2 = parameter_2;

	self.structure[self.structure.size] = option;
}

new_menu(menu) {
	if(!isDefined(menu)) {
		menu = self.previous[(self.previous.size - 1)];
		self.previous[(self.previous.size - 1)] = undefined;
	} else {
		if(self get_menu() == "All Players") {
			player = level.players[self get_cursor()];
			self.selected_player = player;
		}

		self.previous[self.previous.size] = self get_menu();;
	}

	self set_menu(menu);
	self update_display();
}

// Custom Structure

open_menu() {
	self.menu["border"] = self create_shader("white", "TOP_LEFT", "TOPCENTER", self.x_offset, (self.y_offset - 1), (self.width + 250), 34, self.color_theme, 1, 1);
	self.menu["background"] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 1), self.y_offset, (self.width + 248), 32, (0.075, 0.075, 0.075), 1, 2);
	self.menu["foreground"] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 1), (self.y_offset + 16), (self.width + 248), 16, (0.1, 0.1, 0.1), 1, 3);
	self.menu["cursor"] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 1), (self.y_offset + 16), (self.width + 243), 16, (0.15, 0.15, 0.15), 1, 4);
	self.menu["scrollbar"] = self create_shader("white", "TOP_RIGHT", "TOPCENTER", (self.x_offset + (self.menu["background"].width + 1)), (self.y_offset + 16), 4, 16, (0.25, 0.25, 0.25), 1, 4);

	self set_state(true);
	self update_display();
}

close_menu() {
	self notify("menu_ended");
	self set_state(false);
	self destroy_option();
	self destroy_all(self.menu);
}

display_title(title) {
	title = isDefined(title) ? title : self get_title();
	if(!isDefined(self.menu["title"])) {
		self.menu["title"] = self create_text(title, self.font, self.font_scale, "TOP_LEFT", "TOPCENTER", (self.x_offset + 99), (self.y_offset + 4), self.color_theme, 1, 10);
		self.menu["separator"][0] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 6), (self.y_offset + 7.5), int((self.menu["cursor"].width / 6)), 1, self.color_theme, 1, 10);
		self.menu["separator"][1] = self create_shader("white", "TOP_RIGHT", "TOPCENTER", (self.x_offset + (self.menu["cursor"].width - 2) + 3), (self.y_offset + 7.5), int((self.menu["cursor"].width / 6)), 1, self.color_theme, 1, 10);
	} else {
		self.menu["title"] set_text(title);
	}
}

display_description(description) {
	description = isDefined(description) ? description : self get_description();
	if(isDefined(self.menu["description"]) && !self.description_enabled || isDefined(self.menu["description"]) && !isDefined(description)) {
		self.menu["description"] destroy_element();
	}

	if(isDefined(description) && self.description_enabled) {
		if(!isDefined(self.menu["description"])) {
			self.menu["description"] = self create_text(description, self.font, self.font_scale, "TOP_LEFT", "TOPCENTER", (self.x_offset + 4), (self.y_offset + 36), (0.75, 0.75, 0.75), 1, 10);
		} else {
			self.menu["description"] set_text(description);
		}
	}
}

display_option() {
	self destroy_option();
	self menu_option();
	if(!isDefined(self.structure) || !self.structure.size) {
		self add_option(empty_option());
	}

	self display_title();
	self display_description();
	if(isDefined(self.structure) && self.structure.size) {
		if(self get_cursor() >= self.structure.size) {
			self set_cursor((self.structure.size - 1));
		}

		if(!isDefined(self.menu["toggle"][0])) {
			self.menu["toggle"][0] = [];
		}

		if(!isDefined(self.menu["toggle"][1])) {
			self.menu["toggle"][1] = [];
		}

		menu = self get_menu();
		cursor = self get_cursor();
		maximum = min(self.structure.size, self.option_limit);
		for (a = 0; a < maximum; a++) {
			start = self get_cursor() >= int((self.option_limit / 2)) && self.structure.size > self.option_limit ? (((self get_cursor() + int((self.option_limit / 2))) >= (self.structure.size - 1)) ? (self.structure.size - self.option_limit) : (self get_cursor() - int((self.option_limit / 2)))) : 0;
			index = (a + start);
			if(isDefined(self.structure[index].function) && self.structure[index].function == ::new_menu) {
				self.menu["submenu"][index] = self create_shader("ui_scrollbar_arrow_right", "TOP_RIGHT", "TOPCENTER", (self.x_offset + (self.menu["cursor"].width - 1)), (self.y_offset + ((a * self.option_spacing) + 20.5)), 7, 7, (cursor == index) ? (0.75, 0.75, 0.75) : (0.5, 0.5, 0.5), 1, 10);
			}

			if(isDefined(self.structure[index].toggle)) { // Toggle Off
				self.menu["toggle"][0][index] = self create_shader("white", "TOP_RIGHT", "TOPCENTER", (self.x_offset + 14), (self.y_offset + ((a * self.option_spacing) + 19)), 10, 10, (0.25, 0.25, 0.25), 1, 9);
				if(self.structure[index].toggle) { // Toggle On
					self.menu["toggle"][1][index] = self create_shader("white", "TOP_RIGHT", "TOPCENTER", (self.x_offset + 13), (self.y_offset + ((a * self.option_spacing) + 20)), 8, 8, (1, 1, 1), 1, 10);
				}
			}

			if(isDefined(self.structure[index].array) || isDefined(self.structure[index].increment)) {
				if(isDefined(self.structure[index].array)) { // Array Text
					self.menu["slider"][index] = self create_text(self.slider[(menu + "_" + index)], self.font, self.font_scale, "TOP_RIGHT", "TOPCENTER", (self.x_offset + (self.menu["cursor"].width - 2)), (self.y_offset + ((a * self.option_spacing) + 20)), (cursor == index) ? (0.75, 0.75, 0.75) : (0.5, 0.5, 0.5), 1, 10);
				} else if(cursor == index) { // Increment Text
					self.menu["slider"][index] = self create_text(self.slider[(menu + "_" + index)], self.font, self.font_scale, "TOP_RIGHT", "TOPCENTER", (self.x_offset + (self.menu["cursor"].width - 3)), (self.y_offset + ((a * self.option_spacing) + 20)), (0.75, 0.75, 0.75), 1, 10);
				}

				self update_slider(undefined, index);
			}

			self.menu["text"][index] = self create_text((isDefined(self.structure[index].array) || isDefined(self.structure[index].increment)) ? (self.structure[index].text + ":") : self.structure[index].text, self.font, self.font_scale, "TOP_LEFT", "TOPCENTER", isDefined(self.structure[index].toggle) ? (self.x_offset + 16) : (!isDefined(self.structure[index].function) ? (self.x_offset + (self.menu["cursor"].width / 2)) : (self.x_offset + 4)), (self.y_offset + ((a * self.option_spacing) + 20)), !isDefined(self.structure[index].function) ? self.color_theme : ((cursor == index) ? (0.75, 0.75, 0.75) : (0.5, 0.5, 0.5)), 1, 10);
		}
	}
}

update_display() {
	self display_option();
	self update_scrollbar();
	self update_progression();
	self update_rescaling();
}

update_scrolling(scrolling) {
	if(isDefined(self.structure[self get_cursor()]) && !isDefined(self.structure[self get_cursor()].function)) {
		self set_cursor((self get_cursor() + scrolling));
		return self update_scrolling(scrolling);
	}

	if(self get_cursor() >= self.structure.size || self get_cursor() < 0) {
		self set_cursor(self get_cursor() >= self.structure.size ? 0 : (self.structure.size - 1));
	}

	self update_display();
}

update_slider(scrolling, cursor) {
	menu = self get_menu();
	cursor = isDefined(cursor) ? cursor : self get_cursor();
	scrolling = isDefined(scrolling) ? scrolling : 0;
	if(!isDefined(self.slider[(menu + "_" + cursor)])) {
		self.slider[(menu + "_" + cursor)] = isDefined(self.structure[cursor].array) ? 0 : self.structure[cursor].start;
	}

	if(isDefined(self.structure[cursor].array)) {
		if(scrolling == -1) {
			self.slider[(menu + "_" + cursor)]++;
		}

		if(scrolling == 1) {
			self.slider[(menu + "_" + cursor)]--;
		}

		if(self.slider[(menu + "_" + cursor)] > (self.structure[cursor].array.size - 1) || self.slider[(menu + "_" + cursor)] < 0) {
			self.slider[(menu + "_" + cursor)] = self.slider[(menu + "_" + cursor)] > (self.structure[cursor].array.size - 1) ? 0 : (self.structure[cursor].array.size - 1);
		}

		if(isDefined(self.menu["slider"][cursor])) {
			self.menu["slider"][cursor] set_text((self.structure[cursor].array[self.slider[(menu + "_" + cursor)]] + " [" + (self.slider[(menu + "_" + cursor)] + 1) + "/" + self.structure[cursor].array.size + "]"));
		}
	} else {
		if(scrolling == -1) {
			self.slider[(menu + "_" + cursor)] += self.structure[cursor].increment;
		}

		if(scrolling == 1) {
			self.slider[(menu + "_" + cursor)] -= self.structure[cursor].increment;
		}

		if(self.slider[(menu + "_" + cursor)] > self.structure[cursor].maximum || self.slider[(menu + "_" + cursor)] < self.structure[cursor].minimum) {
			self.slider[(menu + "_" + cursor)] = self.slider[(menu + "_" + cursor)] > self.structure[cursor].maximum ? self.structure[cursor].minimum : self.structure[cursor].maximum;
		}

		if(isDefined(self.menu["slider"][cursor])) {
			self.menu["slider"][cursor] setValue(self.slider[(menu + "_" + cursor)]);
		}
	}
}

update_progression() {
	if(isDefined(self.structure[self get_cursor()].increment) && self.slider[(self get_menu() + "_" + self get_cursor())] != 0) {
		value = abs((self.structure[self get_cursor()].minimum - self.structure[self get_cursor()].maximum)) / (self.menu["cursor"].width);
		width = ceil(((self.slider[(self get_menu() + "_" + self get_cursor())] - self.structure[self get_cursor()].minimum) / value));
		if(!isDefined(self.menu["progression"])) {
			self.menu["progression"] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 1), self.menu["cursor"].y, int(width), 16, (0.3, 0.3, 0.3), 1, 5);
		} else {
			self.menu["progression"] set_shader(self.menu["progression"].shader, int(width), self.menu["progression"].height);
		}

		if(self.menu["progression"].y != self.menu["cursor"].y) {
			self.menu["progression"].y = self.menu["cursor"].y;
		}
	} else if(isDefined(self.menu["progression"])) {
		self.menu["progression"] destroy_element();
	}
}

update_scrollbar() {
	maximum = min(self.structure.size, self.option_limit);
	height = int((maximum * self.option_spacing));
	adjustment = self.structure.size > self.option_limit ? ((180 / self.structure.size) * maximum) : height;
	position = self.structure.size > self.option_limit ? ((self.structure.size - 1) / (height - adjustment)) : 0;
	if(isDefined(self.menu["cursor"])) {
		self.menu["cursor"].y = (self.menu["text"][self get_cursor()].y - 4);
	}

	if(isDefined(self.menu["scrollbar"])) {
		self.menu["scrollbar"].y = (self.y_offset + 16);
		if(self.structure.size > self.option_limit) {
			self.menu["scrollbar"].y += (self get_cursor() / position);
		}
	}

	self.menu["scrollbar"] set_shader(self.menu["scrollbar"].shader, self.menu["scrollbar"].width, int(adjustment));
}

update_rescaling() {
	maximum = min(self.structure.size, self.option_limit);
	height = int((maximum * self.option_spacing));
	if(isDefined(self.menu["description"])) {
		self.menu["description"].y = (self.y_offset + (height + 20));
	}

	self.menu["border"] set_shader(self.menu["border"].shader, self.menu["border"].width, isDefined(self get_description()) && self.description_enabled ? (height + 34) : (height + 18));
	self.menu["background"] set_shader(self.menu["background"].shader, self.menu["background"].width, isDefined(self get_description()) && self.description_enabled ? (height + 32) : (height + 16));
	self.menu["foreground"] set_shader(self.menu["foreground"].shader, self.menu["foreground"].width, height);
}

// Option Structure

menu_option() {
	menu = self get_menu();
	switch (menu) {
		case "Synergy":
			self add_menu(menu, menu.size);
			
			self add_option("Basic Options", undefined, ::new_menu, "Basic Options");
			self add_option("Fun Options", undefined, ::new_menu, "Fun Options");
			self add_option("Weapon Options", undefined, ::new_menu, "Weapon Options");
			self add_option("Give Killstreaks", undefined, ::new_menu, "Give Killstreaks");
			self add_option("Account Options", undefined, ::new_menu, "Account Options");
			self add_option("Menu Options", undefined, ::new_menu, "Menu Options");
			self add_option("Map Options", undefined, ::new_menu, "Map Options");
			self add_option("Bot Options", undefined, ::new_menu, "Bot Options");
			self add_option("All Players", undefined, ::new_menu, "All Players");
			
			break;
		case "Basic Options":
			self add_menu(menu, menu.size);
			
			self add_toggle("God Mode", "Makes you Invincible", ::god_mode, self.god_mode);
			self add_toggle("Frag No Clip", "Fly through the Map using (^3[{+frag}]^7)", ::frag_no_clip, self.frag_no_clip);
			self add_toggle("Infinite Ammo", "Gives you Infinite Ammo and Infinite Grenades", ::infinite_ammo, self.infinite_ammo);
			
			self add_toggle("Rapid Fire", "Shoot Very Fast (Hold ^3[{+reload}]^7 & ^3[{+attack}])", ::rapid_fire, self.rapid_fire);
			self add_toggle("No Recoil", "No Recoil while ADS & Firing", ::no_recoil, self.no_recoil);
			self add_toggle("No Spread", "No Bullet Spread while Hip-firing", ::no_spread, self.no_spread);
			
			break;
		case "Fun Options":
			self add_menu(menu, menu.size);
			
			self add_toggle("Fullbright", "Removes all Shadows and Lighting", ::fullbright, self.fullbright);
			self add_toggle("Third Person", undefined, ::third_person, self.third_person);
			
			self add_toggle("Super Jump", undefined, ::super_jump, self.super_jump);
			
			self add_increment("Set Speed", undefined, ::set_speed, 190, 190, 990, 50);
			self add_increment("Set Timescale", undefined, ::set_timescale, 1, 1, 10, 1);
			
			self add_option("Visions", undefined, ::new_menu, "Visions");
			
			self add_option("Suicide", undefined, ::commit_suicide, self);
			self add_option("End Game", undefined, ::end_game);
			
			break;
		case "Weapon Options":
			self add_menu(menu, menu.size);
			
			category = get_category(getBaseWeaponName(self getCurrentWeapon()) + "_mp");
			
			self add_option("Give Weapons", undefined, ::new_menu, "Give Weapons");
			
			if(category != "launchers" && category != "equipment") {
				self add_option("Attachments", undefined, ::new_menu, "Attachments");
			}
			
			self add_option("Take Current Weapon", undefined, ::take_weapon);
			
			self add_option("Bullet Magic", undefined, ::new_menu, "Bullet Magic");
			
			break;
		case "Give Killstreaks":
			self add_menu(menu, menu.size);
			
			for(i = 0; i < self.syn["killstreaks"][1].size; i++) {
				self add_option(self.syn["killstreaks"][1][i], undefined, ::give_killstreak, self.syn["killstreaks"][0][i]);
			}
			
			break;
		case "Account Options":
			self add_menu(menu, menu.size);
			
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
			self add_menu(menu, menu.size);
			
			self add_increment("Move Menu X", "Move the Menu around Horizontally", ::modify_menu_position, 0, -600, 20, 10, "x");
			self add_increment("Move Menu Y", "Move the Menu around Vertically", ::modify_menu_position, 0, -150, 30, 10, "y");
			
			self add_option("Rainbow Menu", "Set the Menu Outline Color to Cycling Rainbow", ::set_menu_rainbow);
			
			self add_increment("Red", "Set the Red Value for the Menu Outline Color", ::set_menu_color, 255, 1, 255, 1, "Red");
			self add_increment("Green", "Set the Green Value for the Menu Outline Color", ::set_menu_color, 255, 1, 255, 1, "Green");
			self add_increment("Blue", "Set the Blue Value for the Menu Outline Color", ::set_menu_color, 255, 1, 255, 1, "Blue");
			
			self add_toggle("Watermark", "Enable/Disable Watermark in the Top Left Corner", ::watermark, self.watermark);
			self add_toggle("Hide UI", undefined, ::hide_ui, self.hide_ui);
			self add_toggle("Hide Weapon", undefined, ::hide_weapon, self.hide_weapon);
			
			break;
		case "Map Options":
			self add_menu(menu, menu.size);
			
			self add_option("Change Map", undefined, ::new_menu, "Change Map");
			self add_toggle("No Fog", "Removes all Fog", ::no_fog, self.no_fog);
			
			break;
		case "Change Map":
			self add_menu(menu, menu.size);
			
			for(i = 0; i < self.syn["maps"].size; i++) {
				map = self.syn["maps"][i];
				self add_option(map, undefined, ::change_map, map);
			}

			break;
		case "Bot Options":
			self add_menu(menu, menu.size);
			
			self add_option("Spawn Friendly Bot", undefined, ::spawn_friendly_bot);
			self add_option("Spawn Enemy Bot", undefined, ::spawn_enemy_bot);
			self add_option("Kick Random Bot", undefined, ::kick_random_bot);
			
			break;
		case "All Players":
			self add_menu(menu, menu.size);

			foreach(player in level.players){
				self add_option(player.name, undefined, ::new_menu, "Player Option", player);
			}
			
			break;
		case "Player Option":
			self add_menu(menu, menu.size);

			target = undefined;
			foreach(player in level.players) {
				if(player.name == self.previous_option) {
					target = player;
					break;
				}
			}

			if(isDefined(target)) {
				self add_option("Print", "Print Player Name", ::iPrintString, target);
				self add_option("Kill", "Kill the Player", ::commit_suicide, target);
				self add_option("Kick", "Kick the Player from the Game", ::kick_player, target);
			} else {
				self add_option("Player not found");
			}
			
			break;
		case "Bullet Magic":
			self add_menu(menu, menu.size);
			
			for(i = 0; i < self.syn["bullets"].size; i++) {
				bullet = self.syn["bullets"][i];
				self add_toggle(bullet, undefined, ::modify_bullet, self.bullet[i], bullet, i);
			}
			
			break;
		case "Visions":
			self add_menu(menu, menu.size);
			
			for(i = 0; i < self.syn["visions"][0].size; i++) {
				self add_option(self.syn["visions"][0][i], undefined, ::set_vision, self.syn["visions"][1][i]);
			}

			break;
		case "Give Weapons":
			self add_menu(menu, menu.size);
			
			for(i = 0; i < self.syn["weapons"]["category"][1].size; i++) {
				self add_option(self.syn["weapons"]["category"][1][i], undefined, ::new_menu, self.syn["weapons"]["category"][1][i]);
			}
			
			break;
		case "Attachments":
			self add_menu(menu, menu.size);
			
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
			self add_menu(menu, menu.size);
			
			weapon_name = getBaseWeaponName(self getCurrentWeapon());
		
			if(weapon_name == "h2_ranger" || weapon_name == "h2_model1887") {
				category = "shotguns_alt";
			} else if(weapon_name == "h2_ksg") {
				category = "h2_ksg_mp";
			} else if(weapon_name == "h2_winchester1200") {
				category = "h2_winchester1200_mp";
			} else if(weapon_name == "h2_coltanaconda" || weapon_name == "h2_deserteagle" || weapon_name == "h2_mp412") {
				category = "pistols_alt";
			} else {
				category = get_category(weapon_name + "_mp");
			}
			
			for(i = 0; i < self.syn["weapons"][category]["attachments"][0].size; i++) {
				self add_option(self.syn["weapons"][category]["attachments"][1][i], undefined, ::equip_attachment, self.syn["weapons"][category]["attachments"][0][i], category);
			}
			
			break;
		case "Equip Camo":
			self add_menu(menu, menu.size);
			
			self add_increment("Equip Camo", undefined, ::equip_camo, 1, 1, 45, 1);
			self add_toggle("Cycle Camos", undefined, ::cycle_camos, self.cycle_camos);
			
			break;
		case "Assault Rifles":
			self add_menu(menu, menu.size);
			
			category = "assault_rifles";
			
			for(i = 0; i < self.syn["weapons"][category][0].size; i++) {
				self add_option(self.syn["weapons"][category][1][i], undefined, ::give_base_weapon, self.syn["weapons"][category][0][i]);
			}
			
			break;
		case "Sub Machine Guns":
			self add_menu(menu, menu.size);
			
			category = "sub_machine_guns";
			
			for(i = 0; i < self.syn["weapons"][category][0].size; i++) {
				self add_option(self.syn["weapons"][category][1][i], undefined, ::give_base_weapon, self.syn["weapons"][category][0][i]);
			}
			
			break;
		case "Sniper Rifles":
			self add_menu(menu, menu.size);
			
			category = "sniper_rifles";
			
			for(i = 0; i < self.syn["weapons"][category][0].size; i++) {
				self add_option(self.syn["weapons"][category][1][i], undefined, ::give_base_weapon, self.syn["weapons"][category][0][i]);
			}
			
			break;
		case "Light Machine Guns":
			self add_menu(menu, menu.size);
			
			category = "light_machine_guns";
			
			for(i = 0; i < self.syn["weapons"][category][0].size; i++) {
				self add_option(self.syn["weapons"][category][1][i], undefined, ::give_base_weapon, self.syn["weapons"][category][0][i]);
			}
			
			break;
		case "Machine Pistols":
			self add_menu(menu, menu.size);
			
			category = "machine_pistols";
			
			for(i = 0; i < self.syn["weapons"][category][0].size; i++) {
				self add_option(self.syn["weapons"][category][1][i], undefined, ::give_base_weapon, self.syn["weapons"][category][0][i]);
			}
			
			break;
		case "Shotguns":
			self add_menu(menu, menu.size);
			
			category = "shotguns";
			
			for(i = 0; i < self.syn["weapons"][category][0].size; i++) {
				self add_option(self.syn["weapons"][category][1][i], undefined, ::give_base_weapon, self.syn["weapons"][category][0][i]);
			}
			
			break;
		case "Pistols":
			self add_menu(menu, menu.size);
			
			category = "pistols";
			
			for(i = 0; i < self.syn["weapons"][category][0].size; i++) {
				self add_option(self.syn["weapons"][category][1][i], undefined, ::give_base_weapon, self.syn["weapons"][category][0][i]);
			}
			
			break;
		case "Launchers":
			self add_menu(menu, menu.size);
			
			category = "launchers";
			
			for(i = 0; i < self.syn["weapons"][category][0].size; i++) {
				self add_option(self.syn["weapons"][category][1][i], undefined, ::give_base_weapon, self.syn["weapons"][category][0][i]);
			}
			
			break;
		case "Melee Weapons":
			self add_menu(menu, menu.size);
			
			category = "melee";
			
			for(i = 0; i < self.syn["weapons"][category][0].size; i++) {
				self add_option(self.syn["weapons"][category][1][i], undefined, ::give_base_weapon, self.syn["weapons"][category][0][i]);
			}
			
			break;
		case "Equipment":
			self add_menu(menu, menu.size);
			
			category = "equipment";
			
			for(i = 0; i < self.syn["weapons"][category][0].size; i++) {
				self add_option(self.syn["weapons"][category][1][i], undefined, ::give_weapon, self.syn["weapons"][category][0][i]);
			}
			
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
	if(!isDefined(menu) || !isDefined(player) || !isplayer(player)) {
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

// Misc Options

return_toggle(variable) {
	return isDefined(variable) && variable;
}

close_controls_menu() {
	if(isDefined(self.controls["title"])) {
		self.controls["title"] destroy();
		self.controls["separator"][0] destroy();
		self.controls["separator"][1] destroy();
		self.controls["border"] destroy();
		self.controls["background"] destroy();
		self.controls["foreground"] destroy();
		
		self.controls["text"][0] destroy();
		self.controls["text"][1] destroy();
		self.controls["text"][2] destroy();
		self.controls["text"][3] destroy();
	}
}

iPrintString(string) {
	if(!isDefined(self.syn["string"])) {
		self.syn["string"] = self create_text(string, "default", 1, "center", "top", 0, -100, (1,1,1), 1, 9999, false);
	} else {
		self.syn["string"] set_text(string);
	}
	self.syn["string"] notify("stop_hud_fade");
	self.syn["string"].alpha = 1;
	self.syn["string"].glowalpha = 0.2;
	self.syn["string"] setText(string);
	self.syn["string"] thread fade_hud(0, 4);
}

fade_hud(alpha, time) {
	self endon("stop_hud_fade");
	self fadeOverTime(time);
	self.alpha = alpha;
	self.glowalpha = self.glowalpha - (0.2 / (time * 2));
	wait time;
}

hud_scale_over_time(time, width, height) {
	self endon("stop_hud_scale");
	self scaleovertime(time, width, height);
	self.width = width;
	self.height = height;
	wait time;
}

font_scale_over_time(time, scale) {
	self endon("stop_font_scale");
	self changefontscaleovertime(time);
	self.fontscale = scale;
}

return_false() {
	return false;
}

player_damage_callback(inflictor, attacker, damage, flags, death_reason, weapon, point, direction, hit_location, time_offset) {
	self endon("disconnect");

	if(isDefined(self.god_mode) && self.god_mode) {
		return;
	}

	[[level.OriginalCallbackPlayerDamage]](inflictor, attacker, damage, flags, death_reason, weapon, point, direction, hit_location, time_offset);
}

// Menu Options

modify_menu_position(offset, axis) {
	if(axis == "x") {
		self.x_offset = 175 + offset;
	} else {
		self.y_offset = 160 + offset;
	}
	self close_menu();
	open_menu("Menu Options");
	self.menu["title"].x = 264.2;
}

set_menu_rainbow() {
	if(!isString(self.color_theme)) {
		self.color_theme = "rainbow";
		self close_menu();
		open_menu("Menu Options");
		self.menu["title"].x = 264.2;
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
	self close_menu();
	open_menu("Menu Options");
	self.menu["title"].x = 264.2;
}

watermark() {
	self.watermark = !return_toggle(self.watermark);
	if(self.watermark) {
		iPrintString("Watermark [^2ON^7]");
		if(!isDefined(self.syn["watermark"])) {
			self.syn["watermark"] = self create_text("SyndiShanX", self.font, 1, "TOP_LEFT", "TOPCENTER", 350, -25, "rainbow", 1, 3);
		}
	} else {
		iPrintString("Watermark [^1OFF^7]");
		self.syn["watermark"] destroy();
	}
}

hide_ui() {
	self.hide_ui = !return_toggle(self.hide_ui);
	setdvar("cg_draw2d", !self.hide_ui);
}

hide_weapon() {
	self.hide_weapon = !return_toggle(self.hide_weapon);
	setdvar("cg_drawgun", !self.hide_weapon);
}

// Basic Options

god_mode() {
	self.god_mode = !return_toggle(self.god_mode);
	executeCommand("god");
	wait .01;
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
			wait .05;
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
		executeCommand("god");
		wait .01;
		iPrintString("");
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
		wait .05;
	}

	clip delete();
	self enableWeapons();
	self enableOffhandWeapons();

	if(isDefined(self.temp_god_mode)) {
		executeCommand("god");
		wait .01;
		iPrintString("");
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
	self endOn("stop_infinite_ammo");
	self endOn("game_ended");
	
	for(;;) {
		self setWeaponAmmoClip(self getCurrentWeapon(), 999);
		self setWeaponAmmoClip(self getCurrentWeapon(), 999, "left");
		self setWeaponAmmoClip(self getCurrentWeapon(), 999, "right");
		
		self setWeaponAmmoStock(self getCurrentWeapon(), 999);
		self setWeaponAmmoStock(self getCurrentWeapon(), 999, "left");
		self setWeaponAmmoStock(self getCurrentWeapon(), 999, "right");
		
		wait .2;
	}
}

rapid_fire() { // Kony's Weapon Menu
	self.rapid_fire = !return_toggle(self.rapid_fire);
	if(self.rapid_fire) {
		self iPrintString("Rapid Fire [^2ON^7]");
		self maps\mp\_utility::giveperk( "specialty_fastreload", false);
		setdvar("perk_weapReloadMultiplier", 0.001);
	} else {
		self iPrintString("Rapid Fire [^1OFF^7]");
		setdvar("perk_weapReloadMultiplier", 1);
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
		setdvar("perk_weapSpreadMultiplier", 0.001);
		self maps\mp\_utility::giveperk("specialty_bulletaccuracy", false);
	} else {
		self iPrintString("No Spread [^1OFF^7]");
		setdvar("perk_weapSpreadMultiplier", 1);
	}
}

// Fun Options

fullbright() {
	self.fullbright = !return_toggle(self.fullbright);
	if(self.fullbright) {
		iPrintString("Fullbright [^2ON^7]");
		setdvar("r_fullbright", 1);
		wait .01;
	} else {
		iPrintString("Fullbright [^1OFF^7]");
		setdvar("r_fullbright", 0);
		wait .01;
	}
}

third_person() {
	self.third_person = !return_toggle(self.third_person);
	if(self.third_person) {
		iPrintString("Third Person [^2ON^7]");
		setdvar("camera_thirdPerson", 1);
	} else {
		iPrintString("Third Person [^1OFF^7]");
		setdvar("camera_thirdPerson", 0);
	}
}

set_speed(value) {
	setdvar("g_speed", value);
}

set_timescale(value) {
	setdvar("timescale", value);
}

super_jump() {
	self.super_jump = !return_toggle(self.super_jump);
	if(self.super_jump) {
		setdvar("jump_height", 999);
		if(!isDefined(self.god_mode) || !self.god_mode) {
			god_mode();
			wait .01;
			iPrintString("");
			self.jump_god_mode = true;
		}
		iPrintString("Super Jump [^2ON^7]");
	} else {
		setdvar("jump_height", 39);
		if(isDefined(self.jump_god_mode)) {
			god_mode();
			wait .01;
			iPrintString("");
			self.jump_god_mode = undefined;
		}
		iPrintString("Super Jump [^1OFF^7]");
	}
}

set_vision(vision) {
	self visionSetNakedForPlayer("", 0.1);
	wait .25;
	self visionSetNakedForPlayer(vision, 0.1);
}

commit_suicide(target) {
	target maps\mp\_utility::_suicide();
}

kick_player(target) {
	kick(target getEntityNumber());
}

end_game() {
	setdvar("xblive_privatematch", 1);
	exitLevel(0);
}

// Killstreaks

give_killstreak(streak) { // Retropack
	self maps\mp\gametypes\_hardpoints::giveHardpoint(streak, 1);
}

// Perks

give_perk(perk, pro_perk) { // Retropack
	self maps\mp\_utility::giveperk(perk);
	self maps\mp\_utility::giveperk(pro_perk);
	waitFrame();
	maps\mp\perks\_perks::applyperks();
}

// Weapon Options

get_category(weapon) {
	forEach(weapon_category in self.syn["weapons"]["category"][0]) {
		forEach(weapon_id in self.syn["weapons"][weapon_category][0]) {
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
		_giveweapon(weapon);
		self giveMaxAmmo(weapon);
	} else if(weapon == "specialty_blastshield") {
		self maps\mp\_utility::giveperk("specialty_blastshield");
		self setLethalWeapon(weapon);
		_giveweapon(weapon);
		self giveMaxAmmo(weapon);
	} else {
		_giveweapon(weapon);
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
	
	for(i = 3; i < weapon_split.size; i++) {
		if(issubstr(weapon_split[i], "camo")) {
			weapon_camo = "_" + weapon_split[i];
		}
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
	if(check_weapons(weapon + "_" + attachment + weapon_camo)) {
		weapon_attached = weapon + "_" + attachment + weapon_camo;
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
	self endOn("stop_cycle_camos");
	self endOn("game_ended");
	
	for(;;) {
		for(i = 1; i <= 45; i++) {
			equip_camo(i);
			iPrintString(i);
			wait .2;
		}
	}
}

take_weapon() {
	self takeweapon(self getCurrentWeapon());
	self switchToWeapon(self getWeaponsListPrimaries()[1]);
}

drop_weapon() {
	self dropitem(self getCurrentWeapon());
	self switchToWeapon(self getWeaponsListPrimaries()[0]);
}

modify_bullet(bullet, i) { 
	self.bullet[i] = !return_toggle(self.bullet[i]);
	if(self.bullet[i]) {
		iPrintString(bullet + " [^2ON^7]");
		self thread modify_bullet_loop(bullet);
	} else { 
		iPrintString(bullet + " [^1OFF^7]");
		self notify("stop_modify_bullet_loop");
	}
}

modify_bullet_loop(bullet) {
	self endon("disconnect");
	self endon("stop_modify_bullet_loop");

	for(;;) { 
		self waitTill("weapon_fired");

		forward = anglesToForward(self getPlayerAngles());
		start = self getEye();
		end = vectorScale(forward, 9999);

		magicBullet(bullet, start, bulletTrace(start, start + end, false, undefined)["position"], self);
	}
}

// Account Options

set_colored_classes() { // Retropack
	if(!self.coloredClasses) {
		self.coloredClasses = true;
		self setplayerdata(getstatsgroup_ranked(), "customClasses", 0, "name", "^:Custom Slot 1");
		self setplayerdata(getstatsgroup_ranked(), "customClasses", 1, "name", "^:Custom Slot 2");
		self setplayerdata(getstatsgroup_ranked(), "customClasses", 2, "name", "^:Custom Slot 3");
		self setplayerdata(getstatsgroup_ranked(), "customClasses", 3, "name", "^:Custom Slot 4");
		self setplayerdata(getstatsgroup_ranked(), "customClasses", 4, "name", "^:Custom Slot 5");
		self setplayerdata(getstatsgroup_ranked(), "customClasses", 5, "name", "^:Custom Slot 6");
		self setplayerdata(getstatsgroup_ranked(), "customClasses", 6, "name", "^:Custom Slot 7");
		self setplayerdata(getstatsgroup_ranked(), "customClasses", 7, "name", "^:Custom Slot 8");
		self setplayerdata(getstatsgroup_ranked(), "customClasses", 8, "name", "^:Custom Slot 9");
		self setplayerdata(getstatsgroup_ranked(), "customClasses", 9, "name", "^:Custom Slot 10");
		self setplayerdata(getstatsgroup_ranked(), "customClasses", 10, "name", "^:Custom Slot 11");
		self setplayerdata(getstatsgroup_ranked(), "customClasses", 11, "name", "^:Custom Slot 12");
		self setplayerdata(getstatsgroup_ranked(), "customClasses", 12, "name", "^:Custom Slot 13");
		self setplayerdata(getstatsgroup_ranked(), "customClasses", 13, "name", "^:Custom Slot 14");
		self setplayerdata(getstatsgroup_ranked(), "customClasses", 14, "name", "^:Custom Slot 15");
		self setplayerdata(getstatsgroup_private(), "privateMatchCustomClasses", 0, "name", "^:Custom Slot 1");
		self setplayerdata(getstatsgroup_private(), "privateMatchCustomClasses", 1, "name", "^:Custom Slot 2");
		self setplayerdata(getstatsgroup_private(), "privateMatchCustomClasses", 2, "name", "^:Custom Slot 3");
		self setplayerdata(getstatsgroup_private(), "privateMatchCustomClasses", 3, "name", "^:Custom Slot 4");
		self setplayerdata(getstatsgroup_private(), "privateMatchCustomClasses", 4, "name", "^:Custom Slot 5");
		iPrintString("Colored Classes Set");
	}
}

update_status(element, text) {
	self endOn("stop_updating_status");
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
		wait .5;
	}
}

set_challenges() { // Retropack
	self endon("disconnect");
	self endon("death");
	self.god_mode = true;
	chalProgress = 0;
	progress_bar = self create_shader("white", "top_left", "center", 0, -100, 1, 10, self.color_theme, 1, 9999);
	progress_outline = self create_shader("white", "center", "top", 0, -105, 132, 37, self.color_theme, 1, 1);
	progress_background = self create_shader("white", "center", "top", 0, -105, 130, 35, (0.075, 0.075, 0.075), 1, 2);
	progress_text = self create_text("Unlocking All", "default", 1, "center", "top", 0, -115, (1,1,1), 1, 9999, true);
	self thread update_status(progress_text, "Unlocking All");
	if(self in_menu()) {
		self close_menu();
	}
	foreach(challengeRef, challengeData in level.challengeInfo) {
		finalTarget = 0;
		finalTier = 0;
		for (tierId = 1; isDefined(challengeData["targetval"][tierId]); tierId++) {
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
	setdvar("xblive_privatematch", 1);
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
	iPrintString(self.name + "'s Level set to " + (value + 1));
}

set_prestige(value) {
	if(value == 10) {
		self.set_10th_prestige = true;
	} else {
		self.set_10th_prestige = undefined;
	}
	
	self maps\mp\gametypes\_persistence::statset("prestige", value);
	iPrintString(self.name + "'s Prestige set to " + value);
}

// Map Options

no_fog() {
	self.no_fog = !return_toggle(self.no_fog);
	if(self.no_fog) {
		iPrintString("No Fog [^2ON^7]");
		setdvar("r_fog", 0);
	} else {
		iPrintString("No Fog [^1OFF^7]");
		setdvar("r_fog", 1);
	}
}

change_map(map) {
	iPrintString("Changing Map to: " + map);
	wait 1;
	setdvar("ui_mapname", "mp_" + map);
	end_game();
}

// Bot Options

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

spawn_bot(team, num, restart, delay) { // Retropack
	if (!isDefined(num) || num == 0) {
		num = 1;
	}

	for (i = 0; i < num; i++) {
		wait(delay);
		level thread _spawn_bot(1, team, undefined, "spawned_player", "Recruit", restart);
	}
}

_spawn_bot(count, team, callback, notifyWhenDone, difficulty, restart) { // Retropack
	time = getTime() + 10000;
	connectingArray = [];
	squad_index = connectingArray.size;
	while (level.players.size < maps\mp\bots\_bots_util::bot_get_client_limit() && connectingArray.size < count && getTime() < time) {
		maps\mp\gametypes\_hostMigration::waitLongDurationWithHostMigrationPause(0.05);
		botEnt = addBot("[BOT]Synergy", team);
		connecting = spawnstruct();
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
			if (connecting.ready || connecting.abort) {
				connectedComplete++;
			}
		}
		wait 0.05;
	}

	if (isDefined(notifyWhenDone)) {
		self notify(notifyWhenDone);
	}

	if (isDefined(restart) && restart && getDvar("g_gametype") == "sd") {
		wait 3;
		maps\mp\gametypes\common_sd_sr::sd_endGame(game["defenders"], game["end_reason"]["time_limit_reached"]);
	}
}

set_team_forced(team) { // Retropack
	self waitTill_any("joined_team");
	waitFrame();
	self.pers["forced_team"] = team;
	self maps\mp\gametypes\_menus::addToTeam(team, true);
}