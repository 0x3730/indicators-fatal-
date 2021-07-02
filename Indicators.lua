-- Your name
local localName = "Marginal [4540]";
--

local menu = fatality.menu
local config = fatality.config
local render = fatality.render
local callbacks = fatality.callbacks;
local screenSize = render:screen_size();
local entity_list = csgo.interface_handler:get_entity_list();

local slist_x = config:add_item("slist_x", 0);
local guiMarginSlider = menu:add_slider("Spectator List (x)", "visuals", "misc", "various", slist_x, 0, screenSize.x, 1);
local slist_y = config:add_item("slist_y", 55);
local guiMarginSlider = menu:add_slider("Spectator List (y)", "visuals", "misc", "various", slist_y, 0, screenSize.y, 1);
--
local klist_x = config:add_item("klist_x", 0);
local guiMarginSlider = menu:add_slider("Kybinds List (x)", "visuals", "misc", "various", klist_x, 0, screenSize.x, 1);
local klist_y = config:add_item("klist_y", 85);
local guiMarginSlider = menu:add_slider("Kybinds List (y)", "visuals", "misc", "various", klist_y, 0, screenSize.y, 1);

local ConVar = csgo.interface_handler:get_cvar();

local backColor = csgo.color(38, 38, 38, 255); 
local fadeColor = csgo.color(74, 104, 255, 255);
local fadeColor2 = csgo.color(102, 127, 255, 0);
local textColor = csgo.color(235, 235, 235, 255);

local fonts = render:create_font("Verdana", 13, 450, true);

local function get_speclist()
	local spectatorsList = { };
	local longestName = 0;
	
	local entityList = csgo.interface_handler:get_entity_list();
    local localPlayer = entityList:get_localplayer();

    for i = 1, entityList:get_max_players(), 1 do
        local entity = entityList:get_player(i)
		
        if not entity or entity:is_alive() or entity:is_dormant() then
            goto continue;
		end
		
        specHandle = entity:get_var_handle("CBasePlayer->m_hObserverTarget");		
        spectatingPlayer = entityList:get_from_handle(specHandle);
        if not spectatingPlayer then
            goto continue;
		end
		
        if spectatingPlayer:get_index() == localPlayer:get_index() then		
			local textSize = render:text_size(fonts, entity:get_name()).x;
			if longestName == 0 then
				longestName = textSize;
			elseif longestName < textSize then
				longestName = textSize;
			end
				
			table.insert(spectatorsList, entity:get_name());
        end

        ::continue::
    end
	table.insert(spectatorsList, "test spec");
	return { longestName, spectatorsList };
end

local function draw_watermark()
	local waterText = "fatality | ";
	local localPing = csgo.interface_handler:get_engine_client():get_ping();
	
	waterText = waterText .. localName .. " | "
	waterText = waterText .. localPing .. " ms | "; 
	waterText = waterText .. os.date("%H:%M:%S");
	
	local watermark_size = render:text_size(fonts, waterText);
	
	local margin_x = 10;
	local paddings = 8;
	local start_x = screenSize.x - watermark_size.x - margin_x - paddings * 2;
	local end_x = screenSize.x - margin_x;
	
	render:rect_filled(start_x, 5, watermark_size.x + paddings * 2, 24, backColor);
	render:rect_fade(start_x, 5 + 8, 2, 15, fadeColor2, fadeColor, false);
	render:rect_fade(start_x, 5 + 24 - 2, 16, 2, fadeColor, fadeColor2, true);
	
	render:rect_fade(end_x - 2, 5 + 2, 2, 15, fadeColor, fadeColor2, false);
	render:rect_fade(end_x - 16, 5, 16, 2, fadeColor2, fadeColor, true);
	
	render:text(fonts, start_x + paddings, 10, waterText, textColor);
end

local function draw_speclist()
	local spectatorsList = get_speclist();
	
	if not spectatorsList[2][1] then
		return;
	end
	
	local start_x = slist_x:get_int();
	local footerTextSize = render:text_size(fonts, "spectators").x;
	local paddings = 5;
	local size_x = 0;
	
	if footerTextSize * 2.6 + paddings * 2 < spectatorsList[1] + paddings * 2 then
		size_x = spectatorsList[1] + paddings * 2;
	else
		size_x = footerTextSize * 2.6 + paddings * 2;
	end
	local start_y = slist_y:get_int();
	
	render:rect_filled(start_x, start_y, size_x, 23, backColor);
	render:rect_filled(start_x, start_y, size_x, 2, fadeColor);
	render:text(fonts, math.ceil((start_x + size_x / 2) - footerTextSize / 2), start_y + 3, "spectators", textColor);
	start_y = start_y + 18;
	
	render:rect_fade(start_x + paddings, start_y, math.ceil(size_x / 2), 2, fadeColor2, fadeColor, true);
	render:rect_fade(start_x + math.ceil(size_x / 2), start_y, math.ceil(size_x / 2) - paddings, 2, fadeColor, fadeColor2, true);
	start_y = start_y + 5;
	
	for i = 1, #spectatorsList[2] do
		local playerName = spectatorsList[2][i];
		
		render:rect_filled(start_x, start_y, size_x, 15, backColor);
		render:text(fonts, start_x + paddings, start_y, playerName, textColor);
		start_y = start_y + 15;
	end	
	render:rect_filled(start_x, start_y, size_x, 3, backColor);
end

local function get_keylist()
	local keybindsList = { };
	local localPlayer = csgo.interface_handler:get_entity_list():get_localplayer();
	local localWeaponId = 0;
	
	if localPlayer and localPlayer:is_alive() then
		localWeaponId = entity_list:get_from_handle(localPlayer:get_var_handle("CBaseCombatCharacter->m_hActiveWeapon")):get_class_id();
	end
	
	if menu:get_reference("Rage", "Aimbot", "Aimbot", "Force Safepoint"):get_bool() then
		table.insert(keybindsList, "force safepoint");
	end
	
	if menu:get_reference("Rage", "Aimbot", "Aimbot", "Headshot only"):get_bool() then
		table.insert(keybindsList, "headshot only");
	end
	
	if menu:get_reference("Rage", "Anti-aim", "General", "Antiaim override"):get_bool() then
		
		if menu:get_reference("Rage", "Anti-aim", "General", "Back"):get_bool() then
			table.insert(keybindsList, "manual side: normal");
		elseif menu:get_reference("Rage", "Anti-aim", "General", "Left"):get_bool() then
			table.insert(keybindsList, "manual side: left");
		elseif menu:get_reference("Rage", "Anti-aim", "General", "Right"):get_bool() then
			table.insert(keybindsList, "manual side: right");
		end
	end
	
	local currDmg = 0;
	local hideshot = false;
	local doubletap = false;
	
	if localWeaponId == 242 or localWeaponId == 261 then
        activedamage = config:get_weapon_setting("autosniper", "mindmg"):get_int();
		hideshot = config:get_weapon_setting("autosniper", "silent"):get_bool();
		doubletap = config:get_weapon_setting("autosniper", "double_tap"):get_bool();
    elseif localWeaponId == 267 then
		activedamage = config:get_weapon_setting("scout", "mindmg"):get_int();
		hideshot = config:get_weapon_setting("scout", "silent"):get_bool();
		doubletap = config:get_weapon_setting("scout", "double_tap"):get_bool();
    elseif localWeaponId == 233 then
		activedamage = config:get_weapon_setting("awp", "mindmg"):get_int();
		hideshot = config:get_weapon_setting("awp", "silent"):get_bool();
		doubletap = config:get_weapon_setting("awp", "double_tap"):get_bool();
    elseif localWeaponId == 46 then
		activedamage = config:get_weapon_setting("heavy_pistol", "mindmg"):get_int();
		hideshot = config:get_weapon_setting("heavy_pistol", "silent"):get_bool();
		doubletap = config:get_weapon_setting("heavy_pistol", "double_tap"):get_bool();
	elseif localWeaponId == 246 or localWeaponId == 245 or localWeaponId == 239 or localWeaponId == 269 or localWeaponId == 241 or localWeaponId == 258 then
		activedamage = config:get_weapon_setting("pistol", "mindmg"):get_int();
		hideshot = config:get_weapon_setting("pistol", "silent"):get_bool();
		doubletap = config:get_weapon_setting("pistol", "double_tap"):get_bool();
	else
		activedamage = config:get_weapon_setting("other", "mindmg"):get_int();
		hideshot = config:get_weapon_setting("other", "silent"):get_bool();
		doubletap = config:get_weapon_setting("other", "double_tap"):get_bool();
	end
	
	if doubletap then
		table.insert(keybindsList, "double tap");
	elseif hideshot then
		table.insert(keybindsList, "hideshot");
	end
	
	table.insert(keybindsList, "current damage: "..activedamage);
	
	return keybindsList;
end

local function draw_keybinds()
	local keybindsList = get_keylist();
	
	if not keybindsList[1] then
		return;
	end

	local footerTextSize = render:text_size(fonts, "keybinds").x;
	local paddings = 5;
	local size_x = footerTextSize * 3 + paddings * 2;
	local start_x = klist_x:get_int();
	local start_y = klist_y:get_int();
	
	render:rect_filled(start_x, start_y, size_x, 23, backColor);
	render:rect_filled(start_x, start_y, size_x, 2, fadeColor);
	render:text(fonts, math.ceil((start_x + size_x / 2) - footerTextSize / 2), start_y + 3, "keybinds", textColor);
	start_y = start_y + 18;
	
	render:rect_fade(start_x + paddings, start_y, math.ceil(size_x / 2), 2, fadeColor2, fadeColor, true);
	render:rect_fade(start_x + math.ceil(size_x / 2), start_y, math.ceil(size_x / 2) - paddings, 2, fadeColor, fadeColor2, true);
	start_y = start_y + 5;
	
	for i = 1, #keybindsList do
		local bindName = keybindsList[i];
		
		render:rect_filled(start_x, start_y, size_x, 15, backColor);
		render:text(fonts, start_x + paddings, start_y, bindName, textColor);
		start_y = start_y + 15;
	end
	
	render:rect_filled(start_x, start_y, size_x, 3, backColor);
end

local function on_paint()
	if not csgo.interface_handler:get_engine_client():is_in_game() then
		return;
	end
	
	draw_watermark();
	draw_speclist();
	draw_keybinds();
end

callbacks:add("paint", on_paint);