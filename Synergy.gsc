#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init() {
	level thread onPlayerConnect();
	level thread create_rainbow_color();
	replaceFunc(maps\mp\gametypes\_gamelogic::onForfeit, ::return_false); // Retropack
	replaceFunc(maps\mp\gametypes\_gamelogic::matchstarttimerwaitforplayers, maps\mp\gametypes\_gamelogic::matchStartTimerSkip); //SimonLFC - Retropack
	level.OriginalCallbackPlayerDamage = level.callbackPlayerDamage; //doktorSAS - Retropack
	level.callbackPlayerDamage = ::player_damage_callback; // Retropack
	level.rankedmatch = 1; // Retropack
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

return_toggle(variable) {
	return isDefined(variable) && variable;
}

really_alive() {
	return isAlive(self) && !return_toggle(self.lastStand);
}

get_menu() {
	return self.syn["menu"];
}

get_cursor() {
	return self.cursor[self get_menu()];
}

set_menu(menu) {
	if(isDefined(menu)) {
		self.syn["menu"] = menu;
	}
}

set_cursor(cursor, menu) {
	if(isDefined(cursor)) {
		self.cursor[isDefined(menu) ? menu : self get_menu()] = cursor;
	}
}

set_title(title) {
	if(isDefined(title)) {
		self.syn["title"] = title;
	}
}

has_menu() {
	return return_toggle(self.syn["user"].has_menu);
}

in_menu() {
	return return_toggle(self.syn["utility"].in_menu);
}

set_state() {
	self.syn["utility"].in_menu = !return_toggle(self.syn["utility"].in_menu);
}

execute_function(function, argument_1, argument_2, argument_3, argument_4) {
	if(!isDefined(function)) {
		return;
	}
	
	if(isDefined(argument_4)) {
		return self thread [[function]](argument_1, argument_2, argument_3, argument_4);
	}
	
	if(isDefined(argument_3)) {
		return self thread [[function]](argument_1, argument_2, argument_3);
	}
	
	if(isDefined(argument_2)) {
		return self thread [[function]](argument_1, argument_2);
	}
	
	if(isDefined(argument_1)) {
		return self thread [[function]](argument_1);
	}
	
	return self thread [[function]]();
}

set_slider(scrolling, index) {
	menu = self get_menu();
	index = isDefined(index) ? index : self get_cursor();
	storage = (menu + "_" + index);
	if(!isDefined(self.slider[storage])) {
		self.slider[storage] = isDefined(self.structure[index].array) ? 0 : self.structure[index].start;
	}
	
	if(!isDefined(self.structure[index].array)) {
		self notify("increment_slider");
		if(scrolling == -1)
			self.slider[storage] += self.structure[index].increment;
		
		if(scrolling == 1)
			self.slider[storage] -= self.structure[index].increment;
		
		if(self.slider[storage] > self.structure[index].maximum)
			self.slider[storage] = self.structure[index].minimum;
		
		if(self.slider[storage] < self.structure[index].minimum)
			self.slider[storage] = self.structure[index].maximum;
		
		position = abs((self.structure[index].maximum - self.structure[index].minimum)) / ((50 - 8));
		
		if(!self.structure[index].text_slider) {
			self.syn["hud"]["slider"][0][index] setValue(self.slider[storage]);
		} else {
			self.syn["hud"]["slider"][0][index].x = self.syn["utility"].x_offset + 85;
		}
		self.syn["hud"]["slider"][2][index].x = (self.syn["hud"]["slider"][1][index].x + (abs((self.slider[storage] - self.structure[index].minimum)) / position));
	}
}

clear_option() {
	for(i = 0; i < self.syn["utility"].element_list.size; i++) {
		clear_all(self.syn["hud"][self.syn["utility"].element_list[i]]);
		self.syn["hud"][self.syn["utility"].element_list[i]] = [];
	}
}

check_option(player, menu, cursor) {
	if(isDefined(self.structure) && self.structure.size) {
		for(i = 0; i < self.structure.size; i++) {
			if(player.structure[cursor].text == self.structure[i].text && self get_menu() == menu) {
				return true;
			}
		}
	}

	return false;
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

create_text(text, font, font_scale, align_x, align_y, x, y, color, alpha, z_index, hide_when_in_menu, archive) {
	textElement = self maps\mp\gametypes\_hud_util::createfontstring(font, font_scale);
	textElement.alpha = alpha;
	textElement.sort = z_index;
	textElement.foreground = true;
	
	if(isDefined(hide_when_in_menu)) {
		textElement.hidewheninmenu = hide_when_in_menu;
	} else {
		textElement.hidewheninmenu = true;
	}
	
	if(isDefined(archive)) {
		textElement.archived = archive;
	} else {
		textElement.archived = false;
	}
	
	if(color != "rainbow") {
		textElement.color = color;
	} else {
		textElement.color = level.rainbow_color;
		textElement thread start_rainbow();
	}
	
	textElement maps\mp\gametypes\_hud_util::setpoint(align_x, align_y, x, y);
	
	if(isnumber(text)) {
		textElement setValue(text);
	} else {
		textElement set_text(text);
	}
	
	return textElement;
}

set_text(text) {
	if(!isDefined(self) || !isDefined(text)) {
		return;
	}
	
	self.text = text;
	self setText(text);
}

create_shader(shader, align_x, align_y, x, y, width, height, color, alpha, z_index) {
	shaderElement = newClientHudElem(self);
	shaderElement.elemType = "icon";
	shaderElement.children = [];
	shaderElement.alpha = alpha;
	shaderElement.sort = z_index;
	shaderElement.archived = true;
	shaderElement.foreground = true;
	shaderElement.hidden = false;
	shaderElement.hideWhenInMenu = true;
	
	if(color != "rainbow") {
		shaderElement.color = color;
	} else {
		shaderElement.color = level.rainbow_color;
		shaderElement thread start_rainbow();
	}
	
	shaderElement maps\mp\gametypes\_hud_util::setpoint(align_x, align_y, x, y);
	shaderElement set_shader(shader, width, height);
	shaderElement maps\mp\gametypes\_hud_util::setparent(level.uiparent);
	
	return shaderElement;
}

set_shader(shader, width, height) {
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

clear_all(array) {
	if(!isDefined(array)) {
		return;
	}
	
	keys = getArrayKeys(array);
	for(a = 0; a < keys.size; a++) {
		if(isArray(array[keys[a]])) {
			forEach(value in array[keys[a]])
				if(isDefined(value)) {
					value destroy();
				}
		} else {
			if(isDefined(array[keys[a]])) {
				array[keys[a]] destroy();
			}
		}
	}
	
	for(x = 0; x < 25; x++) {
		if(isDefined(self.syn["hud"]["arrow"][0][x])) {
			self.syn["hud"]["arrow"][0][x] destroy();
			self.syn["hud"]["arrow"][1][x] destroy();
		}
	}
}

add_menu(title, menu_size, extra) {
	if(isDefined(title)) {
		self set_title(title);
		if(isDefined(extra)) {
			self.syn["hud"]["title"][0].x = self.syn["utility"].x_offset + 86 - menu_size - extra;
		} else {
			self.syn["hud"]["title"][0].x = self.syn["utility"].x_offset + 86 - menu_size;
		}
	}

	self.structure = [];
}

add_option(text, function, argument_1, argument_2, argument_3) {
	option = spawnStruct();
	option.text = text;
	option.function = function;
	option.argument_1 = argument_1;
	option.argument_2 = argument_2;
	option.argument_3 = argument_3;
	
	self.structure[self.structure.size] = option;
}

add_toggle(text, function, toggle, array, argument_1, argument_2, argument_3) {
	option = spawnStruct();
	option.text = text;
	option.function = function;
	option.toggle = return_toggle(toggle);
	option.argument_1 = argument_1;
	option.argument_2 = argument_2;
	option.argument_3 = argument_3;
	
	if(isDefined(array)) {
		option.slider = true;
		option.array = array;
	}
	
	self.structure[self.structure.size] = option;
}

add_string(text, function, array, argument_1, argument_2, argument_3) {
	option = spawnStruct();
	option.text = text;
	option.function = function;
	option.slider = true;
	option.array = array;
	option.argument_1 = argument_1;
	option.argument_2 = argument_2;
	option.argument_3 = argument_3;
	
	self.structure[self.structure.size] = option;
}

add_increment(text, function, start, minimum, maximum, increment, text_slider, slider_text, argument_1, argument_2, argument_3) {
	option = spawnStruct();
	option.text = text;
	option.function = function;
	option.slider = true;
	if(isDefined(text_slider)) {
		option.text_slider = text_slider;
		option.slider_text = slider_text;
	}
	option.start = start;
	option.minimum = minimum;
	option.maximum = maximum;
	option.increment = increment;
	option.argument_1 = argument_1;
	option.argument_2 = argument_2;
	option.argument_3 = argument_3;
	
	self.structure[self.structure.size] = option;
}

add_category(text) {
	option = spawnStruct();
	option.text = text;
	option.category = true;
	
	self.structure[self.structure.size] = option;
}

new_menu(menu) {
	if(!isDefined(menu)) {
		menu = self.previous[(self.previous.size - 1)];
		self.previous[(self.previous.size - 1)] = undefined;
	} else {
		self.previous[self.previous.size] = self get_menu();
	}
	
	self set_menu(menu);
	self clear_option();
	self create_option();
}

initial_variable() {
	self.syn["utility"] = spawnStruct();
	self.syn["utility"].font = "objective";
	self.syn["utility"].font_scale = 0.7;
	self.syn["utility"].option_limit = 10;
	self.syn["utility"].option_spacing = 14;
	self.syn["utility"].x_offset = 160;
	self.syn["utility"].y_offset = -60;
	self.syn["utility"].element_list = ["text", "subMenu", "toggle", "category", "slider"];
	
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
	
	self.syn["stat_increment"] = 100;
	
	self.syn["utility"].interaction = true;
	
	self.syn["utility"].color[0] = (0.752941176, 0.752941176, 0.752941176); // Selected Slider Thumb and Category Text
	self.syn["utility"].color[1] = (0.074509804, 0.070588235, 0.078431373); // Title Background and Unselected Slider Background
	self.syn["utility"].color[2] = (0.074509804, 0.070588235, 0.078431373); // Main Background, Selected Slider Background
	self.syn["utility"].color[3] = (0.243137255, 0.22745098, 0.247058824); // Cursor, Scrollbar Background, Unselected Slider Thumb, and Unchecked Toggle
	self.syn["utility"].color[4] = (1, 1, 1); // Text Color
	self.syn["utility"].color[5] = "rainbow"; // Outline and Separators
	
	self.cursor = [];
	self.previous = [];
	self.previous_option = undefined;
	
	self set_menu("Synergy");
	self set_title(self get_menu());
}

initial_monitor() {
	self endOn("disconnect");
	level endOn("game_ended");
	while(true) {
		if(self really_alive()) {
			if(!self in_menu()) {
				if(self adsButtonPressed() && self meleeButtonPressed()) {
					if(return_toggle(self.syn["utility"].interaction)) {
						self playSoundToPlayer("h1_ui_menu_warning_box_appear", self);
					}
					
					clear_all();
					
					self open_menu();
					wait .15;
				}
			} else {
				menu = self get_menu();
				cursor = self get_cursor();
				if(self meleeButtonPressed()) {
					if(return_toggle(self.syn["utility"].interaction)) {
						self playSoundToPlayer("h1_ui_pause_menu_resume", self);
					}
					
					if(isDefined(self.previous[(self.previous.size - 1)])) {
						self new_menu(self.previous[menu]);
					} else {
						self close_menu();
					}
					
					wait .75; // Knife Cooldown
				} else if(self adsButtonPressed() && !self attackButtonPressed() || self attackButtonPressed() && !self adsButtonPressed()) {
					if(isDefined(self.structure) && self.structure.size >= 2) {
						if(return_toggle(self.syn["utility"].interaction)) {
							self playSoundToPlayer("h1_ui_menu_scroll", self);
						}
						
						scrolling = self attackButtonPressed() ? 1 : -1;
						
						self set_cursor((cursor + scrolling));
						self update_scrolling(scrolling);
					}
					wait .15; // Scroll Cooldown
				} else if(self fragButtonPressed() && !self secondaryOffhandButtonPressed() || self secondaryOffhandButtonPressed() && !self fragButtonPressed()) {
					if(return_toggle(self.structure[cursor].slider)) {
						if(return_toggle(self.syn["utility"].interaction)) {
							self playSoundToPlayer("h1_ui_menu_scroll", self);
						}
						
						scrolling = self secondaryOffhandButtonPressed() ? 1 : -1;
						
						self set_slider(scrolling);
					}
					wait .07;
				} else if(self useButtonPressed()) {
					if(isDefined(self.structure[cursor].function)) {
						if(self.structure[cursor].function == ::new_menu) {
							self.previous_option = self.structure[cursor].text;
						}

						if(return_toggle(self.syn["utility"].interaction)) {
							self playSoundToPlayer("mp_ui_decline", self);
						}
						
						if(return_toggle(self.structure[cursor].slider)) {
							self thread execute_function(self.structure[cursor].function, isDefined(self.structure[cursor].array) ? self.structure[cursor].array[self.slider[menu + "_" + cursor]] :self.slider[menu + "_" + cursor], self.structure[cursor].argument_1, self.structure[cursor].argument_2, self.structure[cursor].argument_3);
						} else {
							self thread execute_function(self.structure[cursor].function, self.structure[cursor].argument_1, self.structure[cursor].argument_2, self.structure[cursor].argument_3);
						}
						
						if(isDefined(self.structure[cursor].toggle)) {
							self update_menu(menu, cursor);
						}
					}
					wait .2;
				}
			}
		}
		wait .05;
	}
}

open_menu(menu) {
	if(!isDefined(menu)) {
		menu = isDefined(self get_menu()) && self get_menu() != "Synergy" ? self get_menu() : "Synergy";
	}
	
	self.syn["hud"] = [];
	self.syn["hud"]["title"][0] = self create_text(self.syn["title"], self.syn["utility"].font, self.syn["utility"].font_scale, "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + 86), (self.syn["utility"].y_offset + 2), self.syn["utility"].color[4], 1, 10); // Title Text
	self.syn["hud"]["title"][1] = self create_text("______                         ______", self.syn["utility"].font, self.syn["utility"].font_scale * 1.5, "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + 4), (self.syn["utility"].y_offset - 4), self.syn["utility"].color[5], 1, 10); // Title Separator
	
	self.syn["hud"]["background"][0] = self create_shader("white", "TOP_LEFT", "CENTER", self.syn["utility"].x_offset - 1, (self.syn["utility"].y_offset - 1), 202, 30, self.syn["utility"].color[5], 1, 1); // Outline
	self.syn["hud"]["background"][1] = self create_shader("white", "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset), self.syn["utility"].y_offset, 200, 28, self.syn["utility"].color[1], 1, 2); // Main Background
	self.syn["hud"]["foreground"][0] = self create_shader("white", "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset), (self.syn["utility"].y_offset + 14), 194, 14, self.syn["utility"].color[3], 1, 4); // Cursor
	self.syn["hud"]["foreground"][1] = self create_shader("white", "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + 195), (self.syn["utility"].y_offset + 14), 4, 14, self.syn["utility"].color[3], 1, 4); // Scrollbar
	
	self set_menu(menu);
	self create_option();
	self set_state();
}

close_menu() {
	self clear_option();
	self clear_all(self.syn["hud"]);
	self set_state();
}

create_title(title) {
	self.syn["hud"]["title"][0] set_text(isDefined(title) ? title : self.syn["title"]);
}

create_option() {
	self clear_option();
	self menu_index();
	if(!isDefined(self.structure) || !self.structure.size) {
		self add_option("Currently No Options To Display");
	}
	
	if(!isDefined(self get_cursor())) {
		self set_cursor(0);
	}
	
	start = 0;
	if((self get_cursor() > int(((self.syn["utility"].option_limit - 1) / 2))) && (self get_cursor() < (self.structure.size - int(((self.syn["utility"].option_limit + 1) / 2)))) && (self.structure.size > self.syn["utility"].option_limit)) {
		start = (self get_cursor() - int((self.syn["utility"].option_limit - 1) / 2));
	}
	
	if((self get_cursor() > (self.structure.size - (int(((self.syn["utility"].option_limit + 1) / 2)) + 1))) && (self.structure.size > self.syn["utility"].option_limit)) {
		start = (self.structure.size - self.syn["utility"].option_limit);
	}
	
	self create_title();
	if(isDefined(self.structure) && self.structure.size) {
		limit = min(self.structure.size, self.syn["utility"].option_limit);
		for(i = 0; i < limit; i++) {
			index = (i + start);
			cursor = (self get_cursor() == index);
			color[0] = cursor ? self.syn["utility"].color[0] : self.syn["utility"].color[4];
			color[1] = return_toggle(self.structure[index].toggle) ? cursor ? self.syn["utility"].color[0] : self.syn["utility"].color[4] : cursor ? self.syn["utility"].color[2] : self.syn["utility"].color[3];
			if(isDefined(self.structure[index].function) && self.structure[index].function == ::new_menu) {
				self.syn["hud"]["subMenu"][index] = self create_text(">", self.syn["utility"].font, self.syn["utility"].font_scale, "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + 185), (self.syn["utility"].y_offset + ((i * self.syn["utility"].option_spacing) + 16)), self.syn["utility"].color[4], 1, 10);
			}
			
			if(isDefined(self.structure[index].toggle)) {
				self.syn["hud"]["toggle"][1][index] = self create_shader("white", "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + 4), (self.syn["utility"].y_offset + ((i * self.syn["utility"].option_spacing) + 17)), 8, 8, color[1], 1, 10); // Toggle Box
			}
			
			for(x = 0; x < 25; x++) {
				if(x != self get_cursor()) {
					if(isDefined(self.syn["hud"]["arrow"][0][x])) {
						self.syn["hud"]["arrow"][0][x] destroy();
						self.syn["hud"]["arrow"][1][x] destroy();
					}
				}
			}
			
			if(return_toggle(self.structure[index].slider)) {
				if(isDefined(self.structure[index].array)) {
					self.syn["hud"]["slider"][0][index] = self create_text(self.structure[index].array[self.slider[self get_menu() + "_" + index]], self.syn["utility"].font, self.syn["utility"].font_scale, "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + 155), (self.syn["utility"].y_offset + ((i * self.syn["utility"].option_spacing) + 16)), color[0], 1, 10);
				} else {
					if(cursor) {
						self.syn["hud"]["slider"][0][index] = self create_text(self.slider[self get_menu() + "_" + index], self.syn["utility"].font, (self.syn["utility"].font_scale - 0.1), "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + 155), (self.syn["utility"].y_offset + ((i * self.syn["utility"].option_spacing) + 17)), self.syn["utility"].color[4], 1, 10);
						self.syn["hud"]["arrow"][0][self get_cursor()] = self create_text("<", self.syn["utility"].font, self.syn["utility"].font_scale, "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + 129), (self.syn["utility"].y_offset + ((i * self.syn["utility"].option_spacing) + 16)), self.syn["utility"].color[4], 1, 10); // Slider Arrow
						self.syn["hud"]["arrow"][1][self get_cursor()] = self create_text(">", self.syn["utility"].font, self.syn["utility"].font_scale, "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + 185), (self.syn["utility"].y_offset + ((i * self.syn["utility"].option_spacing) + 16)), self.syn["utility"].color[4], 1, 10); // Slider Arrow
					} else {
						self.syn["hud"]["arrow"][0][index] destroy();
						self.syn["hud"]["arrow"][1][index] destroy();
					}
				
					self.syn["hud"]["slider"][1][index] = self create_shader("white", "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + 135), (self.syn["utility"].y_offset + ((i * self.syn["utility"].option_spacing) + 17)), 50, 8, cursor ? self.syn["utility"].color[2] : self.syn["utility"].color[1], 1, 8); // Slider Background
					self.syn["hud"]["slider"][2][index] = self create_shader("white", "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + 149), (self.syn["utility"].y_offset + ((i * self.syn["utility"].option_spacing) + 17)), 8, 8, cursor ? self.syn["utility"].color[0] : self.syn["utility"].color[3], 1, 9); // Slider Thumb
				}
				
				self set_slider(undefined, index);
			}
			
			if(return_toggle(self.structure[index].category)) {
				self.syn["hud"]["category"][0][index] = self create_text(self.structure[index].text, self.syn["utility"].font, self.syn["utility"].font_scale, "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + 88), (self.syn["utility"].y_offset + ((i * self.syn["utility"].option_spacing) + 17)), self.syn["utility"].color[0], 1, 10);
				self.syn["hud"]["category"][1][index] = self create_text("______                         ______", self.syn["utility"].font, self.syn["utility"].font_scale * 1.5, "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + 4), (self.syn["utility"].y_offset + ((i * self.syn["utility"].option_spacing) + 11)), self.syn["utility"].color[5], 1, 10); // Category Separator
			}
			else {
				if(return_toggle(self.shader_option[self get_menu()])) {
					self.syn["hud"]["text"][index] = self create_shader(isDefined(self.structure[index].text) ? self.structure[index].text : "white", "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + ((i * 20) - ((limit * 10) - 110))), (self.syn["utility"].y_offset + 27), isDefined(self.structure[index].argument_2) ? self.structure[index].argument_2 : 18, isDefined(self.structure[index].argument_3) ? self.structure[index].argument_3 : 18, isDefined(self.structure[index].argument_1) ? self.structure[index].argument_1 : (1, 1, 1), cursor ? 1 : 0.2, 10);
				} else {
					self.syn["hud"]["text"][index] = self create_text(return_toggle(self.structure[index].slider) ? self.structure[index].text + ":" : self.structure[index].text, self.syn["utility"].font, self.syn["utility"].font_scale, "TOP_LEFT", "CENTER", isDefined(self.structure[index].toggle) ? (self.syn["utility"].x_offset + 15) : (self.syn["utility"].x_offset + 4), (self.syn["utility"].y_offset + ((i * self.syn["utility"].option_spacing) + 16)), color[0], 1, 10);
				}
			}
		}
		
		if(!isDefined(self.syn["hud"]["text"][self get_cursor()])) {
			self set_cursor((self.structure.size - 1));
		}
	}
	self update_resize();
}

update_scrolling(scrolling) {	
	if(return_toggle(self.structure[self get_cursor()].category)) {
		self set_cursor((self get_cursor() + scrolling));
		return self update_scrolling(scrolling);
	}
	
	if((self.structure.size > self.syn["utility"].option_limit) || (self get_cursor() >= 0) || (self get_cursor() <= 0)) {
		if((self get_cursor() >= self.structure.size) || (self get_cursor() < 0)) {
			self set_cursor((self get_cursor() >= self.structure.size) ? 0 : (self.structure.size - 1));
		}
		self create_option();
	}
	self update_resize();
}

update_resize() {
	limit = min(self.structure.size, self.syn["utility"].option_limit);
	height = int((limit * self.syn["utility"].option_spacing));
	adjust = (self.structure.size > self.syn["utility"].option_limit) ? int(((94 / self.structure.size) * limit)) : height;
	position = (self.structure.size - 1) / (height - adjust);
	if(!return_toggle(self.shader_option[self get_menu()])) {
		if(!isDefined(self.syn["hud"]["foreground"][0])) {
			self.syn["hud"]["foreground"][0] = self create_shader("white", "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset), (self.syn["utility"].y_offset + 14), 194, 14, self.syn["utility"].color[3], 1, 4); // Cursor
		}
		
		if(!isDefined(self.syn["hud"]["foreground"][1])) {
			self.syn["hud"]["foreground"][1] = self create_shader("white", "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + 195), (self.syn["utility"].y_offset + 14), 4, 14, self.syn["utility"].color[3], 1, 4); // Scrollbar
		}
	}
	
	self.syn["hud"]["background"][0] set_shader("white", self.syn["hud"]["background"][0].width, return_toggle(self.shader_option[self get_menu()]) ? 42 : (height + 16));
	self.syn["hud"]["background"][1] set_shader("white", self.syn["hud"]["background"][1].width, return_toggle(self.shader_option[self get_menu()]) ? 40 : (height + 14));
	self.syn["hud"]["foreground"][1] set_shader("white", self.syn["hud"]["foreground"][1].width, adjust);
	
	if(isDefined(self.syn["hud"]["foreground"][0])) {
		self.syn["hud"]["foreground"][0].y = (self.syn["hud"]["text"][self get_cursor()].y - 2);
	}
	
	self.syn["hud"]["foreground"][1].y = (self.syn["utility"].y_offset + 14);
	if(self.structure.size > self.syn["utility"].option_limit) {
			self.syn["hud"]["foreground"][1].y += (self get_cursor() / position);
	}
}

update_menu(menu, cursor) {
	if(isDefined(menu) && !isDefined(cursor) || !isDefined(menu) && isDefined(cursor)) {
		return;
	}
	
	if(isDefined(menu) && isDefined(cursor)) {
		forEach(player in level.players) {
			if(!isDefined(player) || !player in_menu()) {
				continue;
			}
		
			if(player get_menu() == menu || self != player && player check_option(self, menu, cursor)) {
				if(isDefined(player.syn["hud"]["text"][cursor]) || player == self && player get_menu() == menu && isDefined(player.syn["hud"]["text"][cursor]) || self != player && player check_option(self, menu, cursor)) {
					player create_option();
				}
			}
		}
	} else {
		if(isDefined(self) && self in_menu()) {
			self create_option();
		}
	}
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

on_event() {
	self endOn("disconnect");
	self.syn = [];
	self.syn["user"] = spawnStruct();
	while (true) {
		if(!isDefined(self.syn["user"].has_menu)) {
			self.syn["user"].has_menu = true;
			
			self initial_variable();
			self thread initial_monitor();
		}
		break;
	}
}

on_ended() {
	level waitTill("game_ended");
	if(self in_menu()) {
		self close_menu();
	}
}

onPlayerConnect() {
	for(;;) {
		level waitTill("connected", player);
		executeCommand("sv_cheats 1");
		
		if(isBot(player)) {
			return;
		}
		
		if(player isHost()) {
			player thread onPlayerSpawned();
		}
	}
}

onPlayerSpawned() {
	self endOn("disconnect");
	level endOn("game_ended");
	self thread on_event();
	self thread on_ended();
	if(!isDefined(self.menuInit)) {
		self.menuInit = false;
	}
	for(;;) {
		self waitTill("spawned_player");
		
		setDvar("xblive_privatematch", 0);
		
		if(self isHost()) {
			self freezeControls(false);
			self.syn["watermark"] = self create_text("SyndiShanX", "default", 1, "left", "top", 385, -220, "rainbow", 1, 3);
		}
		
		if(self in_menu()) {
			self close_menu();
		}
		
		self.menuInit = true;

		controlsY = -80;
		self.syn["controls"][0] = self create_text("Open: [{+speed_throw}] + [{+melee}]", "default", 0.6, "LEFT", "LEFT", 12, controlsY, "rainbow", 1, 2);
		self.syn["controls"][1] = self create_text("Scroll: [{+speed_throw}] + [{+attack}]", "default", 0.6, "LEFT", "LEFT", 12, controlsY+10, "rainbow", 1, 2);
		self.syn["controls"][2] = self create_text("Select: [{+activate}] + [{+melee}]", "default", 0.6, "LEFT", "LEFT", 12, controlsY+20, "rainbow", 1, 2);
		self.syn["controls"][3] = self create_text("Sliders: [{+smoke}] + [{+frag}]", "default", 0.6, "LEFT", "LEFT", 12, controlsY+30, "rainbow", 1, 2);
	}
}

menu_index() {
	menu = self get_menu();
	if(!isDefined(menu)) {
		menu = "Empty Menu";
	}
	
	switch(menu) {
		case "Synergy":
			self add_menu(menu, menu.size, menu.size);
			
			self.syn["utility"].option_limit = 10;
			
			self.syn["hud"]["title"][0].x = self.syn["utility"].x_offset + 86;
			
			self add_option("Basic Options", ::new_menu, "Basic Options");
			self add_option("Fun Options", ::new_menu, "Fun Options");
			self add_option("Weapon Options", ::new_menu, "Weapon Options");
			self add_option("All Players", ::new_menu, "All Players");
			self add_option("Account Options", ::new_menu, "Account Options");
			self add_option("Give Killstreaks", ::new_menu, "Give Killstreaks");
			self add_option("Menu Options", ::new_menu, "Menu Options");
			
			break;
		case "Basic Options":
			self add_menu(menu, menu.size, 1);
			
			self add_toggle("God Mode", ::god_mode, self.god_mode);
			self add_toggle("No Clip", ::no_clip, self.no_clip);
			self add_toggle("Infinite Ammo", ::infinite_ammo, self.infinite_ammo);
			self add_toggle("Rapid Fire", ::rapid_fire, self.rapid_fire);
			self add_toggle("No Recoil", ::no_recoil, self.no_recoil);
			self add_toggle("No Spread", ::no_spread, self.no_spread);
		
			break;
		case "Fun Options":
			self add_menu(menu, menu.size);
			
			self add_toggle("Super Jump", ::super_jump, self.super_jump);
			self add_increment("Set Speed", ::set_speed, 190, 190, 990, 50);
			
			self add_toggle("Fullbright", ::fullbright, self.fullbright);
			self add_toggle("Third Person", ::third_person, self.third_person);
			self add_option("Visions", ::new_menu, "Visions");
			
			self add_option("Suicide", ::commit_suicide, self);
			self add_option("End Game", ::end_game);
			
			break;
		case "Weapon Options":
			self add_menu(menu, menu.size);
			
			category = get_category(getBaseWeaponName(self getCurrentWeapon()) + "_mp");
			
			self add_option("Give Weapons", ::new_menu, "Give Weapons");
			
			if(category != "launchers" && category != "equipment") {
				self add_option("Attachments", ::new_menu, "Attachments");
			}
			
			self add_option("Take Current Weapon", ::take_weapon);
			
			break;
		case "All Players":
			self add_menu(menu, menu.size);

			foreach(i, player in level.players){
				self add_option(player.name, ::new_menu, "Player Option", player);
			}
			break;
		case "Player Option":
			self add_menu(menu, menu.size);

			target = undefined;
			foreach(i, player in level.players) {
                if(player.name == self.previous_option) {
                    target = player;
                    break;
                }
            }
			//Need to add more options here

			if(isDefined(target)) {
				self add_option("Kill", ::commit_suicide, target);
				self add_option("Print", ::iPrintString, target);
			} else {
				self add_option("Player not found");
			}

			break;
		case "Account Options":
			self add_menu(menu, menu.size);
			
			self.syn["utility"].option_limit = 10;
			
			self add_option("Colored Classes", ::set_colored_classes);
			
			self add_increment("Set Prestige", ::set_prestige, 0, 0, 10, 1);
			
			if(self.pers["prestige"] == 10 || isDefined(self.set_10th_prestige)) {
				self add_increment("Set Level", ::set_rank, 0, 0, 1000, 10);
			} else {
				self add_increment("Set Level", ::set_rank, 0, 0, 70, 1);
			}
			
			self add_option("Unlock All", ::set_challenges, self);
			
			self add_option("Set Stats", ::new_menu, "Set Stats");
			
			break;
		case "Set Stats":
			self add_menu(menu, menu.size);
			
			self.syn["utility"].option_limit = 5;
			
			self add_increment("Set Increment", ::set_increment, 100, 100, 10000, 100);
			
			self add_increment("Kills", ::set_stat, 0, 0, 100000, self.syn["stat_increment"], undefined, undefined, "kills", "Kills");
			self add_increment("Deaths", ::set_stat, 0, 0, 100000, self.syn["stat_increment"], undefined, undefined, "deaths", "Deaths");
			self add_increment("Assists", ::set_stat, 0, 0, 100000, self.syn["stat_increment"], undefined, undefined, "assists", "Assists");
			self add_increment("Melee Kills", ::set_stat, 0, 0, 100000, self.syn["stat_increment"], undefined, undefined, "meleeKills", "Melee Kills");
			self add_increment("Environment Kills", ::set_stat, 0, 0, 100000, self.syn["stat_increment"], undefined, undefined, "destructibleKills", "Environment Kills");
			
			self add_increment("Wins", ::set_stat, 0, 0, 100000, self.syn["stat_increment"], undefined, undefined, "wins", "Wins");
			self add_increment("Losses", ::set_stat, 0, 0, 100000, self.syn["stat_increment"], undefined, undefined, "losses", "Losses");
			self add_increment("Games Played", ::set_stat, 0, 0, 100000, self.syn["stat_increment"], undefined, undefined, "gamesPlayed", "Games Played");
			
			self add_increment("Score", ::set_stat, 0, 0, 100000, self.syn["stat_increment"], undefined, undefined, "score", "Score");
			
			break;
		case "Give Killstreaks":
			self add_menu(menu, menu.size);
			
			for(i = 0; i < self.syn["killstreaks"][1].size; i++) {
				self add_option(self.syn["killstreaks"][1][i], ::give_killstreak, self.syn["killstreaks"][0][i]);
			}
			
			break;
		case "Menu Options":
			self add_menu(menu, menu.size);
			
			if(self.syn["utility"].y_offset <= (-150 - 60)) {
				self add_increment("Move Menu X", ::modify_x_position, 0, -190, 60, 10);
			} else if(self.syn["utility"].y_offset <= (-130 - 60)) {
				self add_increment("Move Menu X", ::modify_x_position, 0, -400, 60, 10);
			} else {
				self add_increment("Move Menu X", ::modify_x_position, 0, -580, 60, 10);
			}
			
			if(self.syn["utility"].x_offset < (-400 + 160)) {
				self add_increment("Move Menu Y", ::modify_y_position, 0, -20, 110, 10);
			} else if(self.syn["utility"].x_offset < (-240 + 160)) {
				self add_increment("Move Menu Y", ::modify_y_position, 0, -130, 110, 10);
			} else {
				self add_increment("Move Menu Y", ::modify_y_position, 0, -150, 110, 10);
			}
			
			self add_toggle("Hide Watermark", ::watermark, self.watermark);
			self add_toggle("Hide Controls", ::controls, self.controls);
			self add_toggle("Hide UI", ::hide_ui, self.hide_ui);
			self add_toggle("Hide Weapon", ::hide_weapon, self.hide_weapon);
			
			break;
		case "Visions":
			self add_menu(menu, menu.size);
			
			for(i = 0; i < self.syn["visions"][0].size; i++) {
				self add_option(self.syn["visions"][0][i], ::set_vision, self.syn["visions"][1][i]);
			}
		
			break;
		case "Give Weapons":
			self add_menu(menu, menu.size);
			
			for(i = 0; i < self.syn["weapons"]["category"][1].size; i++) {
				self add_option(self.syn["weapons"]["category"][1][i], ::new_menu, self.syn["weapons"]["category"][1][i]);
			}
			
			break;
		case "Assault Rifles":
			self add_menu(menu, menu.size);
			
			category = "assault_rifles";
			
			for(i = 0; i < self.syn["weapons"][category][0].size; i++) {
				self add_option(self.syn["weapons"][category][1][i], ::give_base_weapon, self.syn["weapons"][category][0][i]);
			}
			
			break;
		case "Sub Machine Guns":
			self add_menu(menu, menu.size);
			
			category = "sub_machine_guns";
			
			for(i = 0; i < self.syn["weapons"][category][0].size; i++) {
				self add_option(self.syn["weapons"][category][1][i], ::give_base_weapon, self.syn["weapons"][category][0][i]);
			}
			
			break;
		case "Sniper Rifles":
			self add_menu(menu, menu.size);
			
			category = "sniper_rifles";
			
			for(i = 0; i < self.syn["weapons"][category][0].size; i++) {
				self add_option(self.syn["weapons"][category][1][i], ::give_base_weapon, self.syn["weapons"][category][0][i]);
			}
			
			break;
		case "Light Machine Guns":
			self add_menu(menu, menu.size);
			
			category = "light_machine_guns";
			
			for(i = 0; i < self.syn["weapons"][category][0].size; i++) {
				self add_option(self.syn["weapons"][category][1][i], ::give_base_weapon, self.syn["weapons"][category][0][i]);
			}
			
			break;
		case "Machine Pistols":
			self add_menu(menu, menu.size);
			
			category = "machine_pistols";
			
			for(i = 0; i < self.syn["weapons"][category][0].size; i++) {
				self add_option(self.syn["weapons"][category][1][i], ::give_base_weapon, self.syn["weapons"][category][0][i]);
			}
			
			break;
		case "Shotguns":
			self add_menu(menu, menu.size);
			
			category = "shotguns";
			
			for(i = 0; i < self.syn["weapons"][category][0].size; i++) {
				self add_option(self.syn["weapons"][category][1][i], ::give_base_weapon, self.syn["weapons"][category][0][i]);
			}
			
			break;
		case "Pistols":
			self add_menu(menu, menu.size);
			
			category = "pistols";
			
			for(i = 0; i < self.syn["weapons"][category][0].size; i++) {
				self add_option(self.syn["weapons"][category][1][i], ::give_base_weapon, self.syn["weapons"][category][0][i]);
			}
			
			break;
		case "Launchers":
			self add_menu(menu, menu.size);
			
			category = "launchers";
			
			for(i = 0; i < self.syn["weapons"][category][0].size; i++) {
				self add_option(self.syn["weapons"][category][1][i], ::give_base_weapon, self.syn["weapons"][category][0][i]);
			}
			
			break;
		case "Melee Weapons":
			self add_menu(menu, menu.size);
			
			category = "melee";
			
			for(i = 0; i < self.syn["weapons"][category][0].size; i++) {
				self add_option(self.syn["weapons"][category][1][i], ::give_base_weapon, self.syn["weapons"][category][0][i]);
			}
			
			break;
		case "Equipment":
			self add_menu(menu, menu.size);
			
			category = "equipment";
			
			for(i = 0; i < self.syn["weapons"][category][0].size; i++) {
				self add_option(self.syn["weapons"][category][1][i], ::give_weapon, self.syn["weapons"][category][0][i]);
			}
			
			break;
		case "Attachments":
			self add_menu(menu, menu.size);
			
			weapon_name = getBaseWeaponName(self getCurrentWeapon());
			category = get_category(getBaseWeaponName(self getCurrentWeapon()) + "_mp");
			
			if(category != "launchers" && category != "melee" && category != "equipment") {
				self add_option("Equip Attachment", ::new_menu, "Equip Attachment");
			}
			if(category != "launchers" && category != "equipment") {
				self add_option("Equip Camo", ::new_menu, "Equip Camo");
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
				self add_option(self.syn["weapons"][category]["attachments"][1][i], ::equip_attachment, self.syn["weapons"][category]["attachments"][0][i], category);
			}
			
			break;
		case "Equip Camo":
			self add_menu(menu, menu.size);
			
			self add_increment("Equip Camo", ::equip_camo, 1, 1, 45, 1);
			self add_toggle("Cycle Camos", ::cycle_camos, self.cycle_camos);
			
			break;
		case "Empty Menu":
			self add_menu(menu, menu.size);
			
			self add_option("Unassigned Menu");
			break;
	}
}

// Common Functions

iPrintString(string) {
	if(!isDefined(self.syn["string"])) {
		self.syn["string"] = self create_text(string, "default", 1, "center", "top", 0, -115, (1,1,1), 1, 9999, false, true);
	} else {
		self.syn["string"] set_text(string);
	}
	self.syn["string"] notify("stop_hud_fade");
	self.syn["string"].alpha = 1;
	self.syn["string"].glowalpha = 0.2;
	self.syn["string"] setText(string);
	self.syn["string"] thread fade_hud(0, 4);
}

modify_x_position(offset) {
	self.syn["utility"].x_offset = 160 + offset;
	for(x = 0; x < 25; x++) {
		if(isDefined(self.syn["hud"]["arrow"][0][x])) {
			self.syn["hud"]["arrow"][0][x] destroy();
			self.syn["hud"]["arrow"][1][x] destroy();
		}
	}
	self close_menu();
	open_menu("Menu Options");
}

modify_y_position(offset) {
	self.syn["utility"].y_offset = -60 + offset;
	for(x = 0; x < 25; x++) {
		if(isDefined(self.syn["hud"]["arrow"][0][x])) {
			self.syn["hud"]["arrow"][0][x] destroy();
			self.syn["hud"]["arrow"][1][x] destroy();
		}
	}
	self close_menu();
	open_menu("Menu Options");
}

watermark() {
	self.watermark = !return_toggle(self.watermark);
	if(!self.watermark) {
		iPrintString("Watermark [^2ON^7]");
		self.syn["watermark"].alpha = 1;
	} else {
		iPrintString("Watermark [^1OFF^7]");
		self.syn["watermark"].alpha = 0;
	}
}

controls() {
	self.controls = !return_toggle(self.controls);
	if(!self.controls) {
		iPrintString("Controls [^2ON^7]");
		for(i = 0; i < self.syn["controls"].size; i++) {
			self.syn["controls"][i].alpha = 1;
		}
	} else {
		iPrintString("Controls [^1OFF^7]");
		for(i = 0; i < self.syn["controls"].size; i++) {
			self.syn["controls"][i].alpha = 0;
		}
 	}
}

hide_ui() {
	self.hide_ui = !return_toggle(self.hide_ui);
	setDvar("cg_draw2d", !self.hide_ui);
}

hide_weapon() {
	self.hide_weapon = !return_toggle(self.hide_weapon);
	setDvar("cg_drawgun", !self.hide_weapon);
}

set_increment(value) {
	self.syn["stat_increment"] = value;
}

// Basic Options

god_mode() {
	self.god_mode = !return_toggle(self.god_mode);
	if(self.god_mode) {
		self iPrintString("God Mode [^2ON^7]");
	} else {
		self iPrintString("God Mode [^1OFF^7]");
	}
}

no_clip() {
	self endon("disconnect");
	self endon("game_ended");

	if(!isDefined(self.no_clip)) {
		self.no_clip = true;
		self iPrintString("No Clip [^2ON^7], Press ^3[{+frag}]^7 to Enter and ^3[{+melee}]^7 to Exit");
		while (isDefined(self.no_clip)) {
			if(self fragButtonPressed()) {
				if(!isDefined(self.no_clip_loop)) {
					self thread no_clip_loop();
				}
			}
			wait .05;
		}
	} else {
		self.no_clip = undefined;
		self iPrintString("No Clip [^1OFF^7]");
	}
}

no_clip_loop() {
	self endon("disconnect");
	self endon("noclip_end");
	self disableWeapons();
	self disableOffHandWeapons();
	self.no_clip_loop = true;

	clip = spawn("script_origin", self.origin);
	self playerLinkTo(clip);
	
	if(!isDefined(self.god_mode) || !self.god_mode) {
		god_mode();
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

	if(self.temp_god_mode) {
		god_mode();
		wait .01;
		iPrintString("");
		self.temp_god_mode = undefined;
	}

	self.no_clip_loop = undefined;
}

infinite_ammo() {
	self.infinite_ammo = !return_toggle(self.infinite_ammo);
	if(self.infinite_ammo) {
		self iPrintString("Infinite Ammo [^2ON^7]");
		self thread infinite_ammo_loop();
	} else {
		self iPrintString("Infinite Ammo [^1OFF^7]");
		self notify("stop_infinite_ammo");
	}
}

infinite_ammo_loop() {
	self endOn("stop_infinite_ammo");
	self endOn("game_ended");
	
	for(;;) {
		self setWeaponAmmoStock(self getCurrentWeapon(), 999);
		self setWeaponAmmoStock(self getCurrentWeapon(), 999, "left");
		self setWeaponAmmoStock(self getCurrentWeapon(), 999, "right");
		self setWeaponAmmoClip(self getCurrentWeapon(), 999);
		self setWeaponAmmoClip(self getCurrentWeapon(), 999, "left");
		self setWeaponAmmoClip(self getCurrentWeapon(), 999, "right");
		wait .1;
	}
}

rapid_fire() { // Thanks to Kony from Weapon Menu
	self.rapid_fire = !return_toggle(self.rapid_fire);
	if(self.rapid_fire) {
		self iPrintString("Rapid Fire [^2ON^7]");
		self maps\mp\_utility::giveperk( "specialty_fastreload", false );
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
		self setrecoilscale(100);
	} else {
		self iPrintString("No Recoil [^1OFF^7]");
		self setrecoilscale(1); // Need a better way to reset this
	}
}

no_spread() {
	self.no_spread = !return_toggle(self.no_spread);
	if(self.no_spread) {
		self iPrintString("No Spread [^2ON^7]");
		SetDvar("perk_weapSpreadMultiplier", 0.001);
		self maps\mp\_utility::giveperk("specialty_bulletaccuracy", false );
	} else {
		self iPrintString("No Spread [^1OFF^7]");
		SetDvar("perk_weapSpreadMultiplier", 1);
	}
}
// Fun Options

set_speed(value) {
	setdvar("g_speed", value);
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
		self iPrintString("Super Jump [^2ON^7]");
	} else {
		setdvar("jump_height", 39);
		if(self.jump_god_mode) {
			god_mode();
			wait .01;
			iPrintString("");
			self.jump_god_mode = undefined;
		}
		self iPrintString("Super Jump [^1OFF^7]");
	}
}

commit_suicide(player) {
	player maps\mp\_utility::_suicide();
}

end_game() {
	setDvar("xblive_privatematch", 1);
	exitLevel(0);
}

fullbright() {
	self.fullbright = !return_toggle(self.fullbright);
	if(self.fullbright) {
		self iPrintString("Fullbright [^2ON^7]");
		setdvar("r_fullbright", 1);
		wait .01;
	} else {
		self iPrintString("Fullbright [^1OFF^7]");
		setdvar("r_fullbright", 0);
		wait .01;
	}
}

third_person() {
	self.third_person = !return_toggle(self.third_person);
	if(self.third_person) {
		self iPrintString("Third Person [^2ON^7]");
		setdvar("camera_thirdPerson", 1);
	} else {
		self iPrintString("Third Person [^1OFF^7]");
		setdvar("camera_thirdPerson", 0);
	}
}

set_vision(vision) {
	self visionSetNakedForPlayer("", 0.1);
	wait .25;
	self visionSetNakedForPlayer(vision, 0.1);
}

// Killstreaks

give_killstreak(streak) { // Retropack
	self maps\mp\gametypes\_hardpoints::giveHardpoint(streak, 1);
}

// Perks

give_perk(perk, pro_perk) { // Retropack
	self maps\mp\_utility::giveperk(perk);
	self maps\mp\_utility::giveperk(pro_perk);
	waitframe();
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
		if(common_scripts\utility::array_contains(self.syn["weapons"]["attachments"], weapon_split[i])) {
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

// Account Options

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

set_challenges(target) { // Retropack
	self endon("disconnect");
	self endon("death");
	self.god_mode = true; //Fix this shit
	chalProgress = 0;
	progress_bar = self create_shader("white", "top_left", "center", 0, -100, 1, 10, self.syn["utility"].color[5], 1, 9999);
	progress_outline = self create_shader("white", "center", "top", 0, -105, 132, 37, self.syn["utility"].color[5], 1, 1);
	progress_background = self create_shader("white", "center", "top", 0, -105, 130, 35, self.syn["utility"].color[1], 1, 2);
	progress_text = self create_text("Unlocking All", "default", 1, "center", "top", 0, -115, (1,1,1), 1, 9999, true, true);
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
		if(target isItemUnlocked(challengeRef)) {
			target setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "challengeProgress", challengeRef, finalTarget);
			target setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "challengeState", challengeRef, finalTier);
		}
		chalProgress++;
		chalPercent = ceil(((chalProgress / level.challengeInfo.size) * 100));
		progress_bar set_shader("white", int(chalPercent), 10);
		waitframe();
	}
	progress_bar destroyElem();
	progress_outline destroyElem();
	progress_background destroyElem();
	progress_outline = self create_shader("white", "center", "top", 0, -115, 137, 17, self.syn["utility"].color[5], 1, 1);
	progress_background = self create_shader("white", "center", "top", 0, -115, 135, 15, self.syn["utility"].color[1], 1, 2);
	self notify("stop_updating_status");
	progress_text setText("Unlock All Completed");
	wait 2;
	progress_outline destroyElem();
	progress_background destroyElem();
	progress_text destroyElem();
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

set_colored_classes() { // Retropack
	if(!self.coloredClasses) {
		self.coloredClasses = true;
		self setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "customClasses", 0, "name", "^:Custom Slot 1");
		self setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "customClasses", 1, "name", "^:Custom Slot 2");
		self setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "customClasses", 2, "name", "^:Custom Slot 3");
		self setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "customClasses", 3, "name", "^:Custom Slot 4");
		self setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "customClasses", 4, "name", "^:Custom Slot 5");
		self setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "customClasses", 5, "name", "^:Custom Slot 6");
		self setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "customClasses", 6, "name", "^:Custom Slot 7");
		self setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "customClasses", 7, "name", "^:Custom Slot 8");
		self setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "customClasses", 8, "name", "^:Custom Slot 9");
		self setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "customClasses", 9, "name", "^:Custom Slot 10");
		self setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "customClasses", 10, "name", "^:Custom Slot 11");
		self setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "customClasses", 11, "name", "^:Custom Slot 12");
		self setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "customClasses", 12, "name", "^:Custom Slot 13");
		self setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "customClasses", 13, "name", "^:Custom Slot 14");
		self setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "customClasses", 14, "name", "^:Custom Slot 15");
		self setplayerdata(common_scripts\utility::getstatsgroup_private(), "privateMatchCustomClasses", 0, "name", "^:Custom Slot 1");
		self setplayerdata(common_scripts\utility::getstatsgroup_private(), "privateMatchCustomClasses", 1, "name", "^:Custom Slot 2");
		self setplayerdata(common_scripts\utility::getstatsgroup_private(), "privateMatchCustomClasses", 2, "name", "^:Custom Slot 3");
		self setplayerdata(common_scripts\utility::getstatsgroup_private(), "privateMatchCustomClasses", 3, "name", "^:Custom Slot 4");
		self setplayerdata(common_scripts\utility::getstatsgroup_private(), "privateMatchCustomClasses", 4, "name", "^:Custom Slot 5");
		progress_outline = self create_shader("white", "center", "top", 0, -115, 137, 17, self.syn["utility"].color[5], 1, 1);
		progress_background = self create_shader("white", "center", "top", 0, -115, 135, 15, self.syn["utility"].color[1], 1, 2);
		progress_text = self create_text("Colored Classes Set", "default", 1, "center", "top", 0, -115, (1,1,1), 1, 9999, true, true);
		wait 2;
		progress_outline destroyElem();
		progress_background destroyElem();
		progress_text destroyElem();
	}
}

set_stat(value, stat_name, print_name) {
	self setplayerdata( common_scripts\utility::getstatsgroup_ranked(), stat_name, value);
	iPrintString("Set " + print_name + " to " + value);
}