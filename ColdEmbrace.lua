-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
BINDING_HEADER_COLDEMBRACE = "ColdEmbrace";
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------

function ColdEmbrace_OnLoad()
	this:RegisterEvent("CHAT_MSG_SYSTEM");
	this:RegisterEvent("CHAT_MSG_OFFICER");

	SLASH_CEZ1 = "/ce";
	SLASH_CEZ2 = "/coldembrace";
	SlashCmdList["CEZ"] = ColdEmbrace_Help;

	SLASH_CEA1 = "/rms";
	SLASH_CEA2 = "/rollms";
	SlashCmdList["CEA"] = ColdEmbrace_MainSpecRoll;

	SLASH_CEB1 = "/ros";
	SLASH_CEB2 = "/rollos";
	SlashCmdList["CEB"] = ColdEmbrace_OffSpecRoll;

	SLASH_CEC1 = "/rc";
	SLASH_CEC2 = "/readycheck";
	SlashCmdList["CEC"] = ColdEmbrace_ReadyCheck;

	SLASH_CED1 = "/ml";
	SLASH_CED2 = "/master";
	SLASH_CED3 = "/masterloot";
	SlashCmdList["CED"] = ColdEmbrace_MasterLoot;

	SLASH_CEE1 = "/gl";
	SLASH_CEE2 = "/group";
	SLASH_CEE3 = "/grouploot";
	SlashCmdList["CEE"] = ColdEmbrace_GroupLoot;

	SLASH_CEF1 = "/inviteraid";
	SlashCmdList["CEF"] = ColdEmbrace_RaidInvites;

	SLASH_CEG1 = "/rl";
	SLASH_CEG2 = "/reload";
	SlashCmdList["CEG"] = ReloadUI;

	SLASH_CEH1 = "/reset";
	SLASH_CEH2 = "/resetinstance";
	SLASH_CEH3 = "/resetinstances";
	SlashCmdList["CEH"] = ResetInstances;
end

-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------

function ColdEmbrace_Help()
	DEFAULT_CHAT_FRAME:AddMessage("Thank you for downloading the Cold Embrace guild addon.",1,1,0);
	DEFAULT_CHAT_FRAME:AddMessage("List of usable commands:",0,1,0);
	DEFAULT_CHAT_FRAME:AddMessage("/rl or /reload - Reload UI.",1,1,1);
	DEFAULT_CHAT_FRAME:AddMessage("/reset or /resetinstance or /resetinstances - Reset Instances.",1,1,1);
	DEFAULT_CHAT_FRAME:AddMessage("/rms or /rollms - Main Spec roll.",1,1,1);
	DEFAULT_CHAT_FRAME:AddMessage("/ros or /rollos - Off Spec roll.",1,1,1);
	DEFAULT_CHAT_FRAME:AddMessage("Requires Raid Lead/Assist and/or a Guild Officer rank:",0,1,0);
	DEFAULT_CHAT_FRAME:AddMessage("/inviteraid - Start raid invites.",1,1,1);
	DEFAULT_CHAT_FRAME:AddMessage("/rc or /readycheck - Start a Ready Check.",1,1,1);
	DEFAULT_CHAT_FRAME:AddMessage("/ml or /master or /masterloot - Change loot method to Master Loot.",1,1,1);
	DEFAULT_CHAT_FRAME:AddMessage("/gl or /group or /grouploot - Change loot method to Group Loot.",1,1,1);
	DEFAULT_CHAT_FRAME:AddMessage("Please report any bugs or problems caused by this addon to Sebben/Perihelion.",1,1,0);
end

-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------

function ColdEmbrace_OnEvent()
	if event == "CHAT_MSG_SYSTEM" then
		if strfind(arg1, "No players are AFK", 1) then
			SendChatMessage("No players are AFK", "RAID"); end
		if strfind(arg1, "(.*) is not ready", 1) then
			SendChatMessage("...group member is not ready !", "RAID"); end
		if strfind(arg1, "The following players are AFK", 1) then
			SendChatMessage("...some group members are AFK !", "RAID"); end
		if strfind(arg1, "You are now", 1) and strfind(arg1, "(AFK)", 1) then
			inInstance, instanceType = IsInInstance()
			inRaidInstance  = (instanceType == 'raid');
			if inRaidInstance then
				SendChatMessage("I am AFK (..offline in 20 seconds..)", "RAID");
				Logout(); 
			end
		end
	elseif event == "CHAT_MSG_OFFICER" then
		if strfind(arg1, "Please do a Ready Check", 1) then
			isLeader = IsRaidLeader() 
			if isLeader then
				DoReadyCheck();
				--SendChatMessage("Starting ReadyCheck...", "OFFICER"); 
			end end
		if strfind(arg1, "Please change to Master Loot", 1) then
			playerName = UnitName("Player");
			isLeader = IsRaidLeader() 
			if isLeader then
				SetLootMethod("master", playerName);
				--SendChatMessage("is now the loot master", "OFFICER"); 
			end end
		if strfind(arg1, "Please change to Group Loot", 1) then
			isLeader = IsRaidLeader() 
			if isLeader then
				SetLootMethod("group");
				--SendChatMessage("GroupLoot activated", "OFFICER"); 
			end
		end
	end
end

-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------

function ColdEmbrace_MainSpecRoll()		
	guild = ("Cold Embrace");
	guildName, guildRankName, guildRankIndex = GetGuildInfo("Player");
	playerName = UnitName("Player");
	for i = 1,250 do
		name, rank, rankIndex, level, class, zone, note, officernote, online, status = GetGuildRosterInfo(i);
		playerName = UnitName("Player");
		if name == playerName and guildName == guild then
			if officernote == ("") then RandomRoll(0,99);
			else
				RandomRoll(officernote+0,(officernote/2)+100);
			end
		end
	end
end

function ColdEmbrace_OffSpecRoll()
	RandomRoll(1,69);
end

function ColdEmbrace_ReadyCheck()
	isLeader  = IsRaidLeader();
	isOfficer = IsRaidOfficer();
	if isLeader then
		DoReadyCheck();
	elseif isOfficer then 
		SendChatMessage("Please do a Ready Check", "OFFICER"); 
	else
		DEFAULT_CHAT_FRAME:AddMessage("You are not a Raid Leader/Assistant.");
	end
end

function ColdEmbrace_MasterLoot()
	isLeader  = IsRaidLeader();
	isOfficer = IsRaidOfficer(); 
	playerName = UnitName("Player");
	lootmethod = GetLootMethod();
	if lootmethod == ("master") then DEFAULT_CHAT_FRAME:AddMessage("Master Looter already set."); 
	elseif lootmethod == ("group") or lootmethod == ("freeforall") or lootmethod == ("roundrobin") or lootmethod == ("needbeforegreed") then
		if isLeader then SetLootMethod("master", playerName);
		elseif isOfficer then SendChatMessage("Please change to Master Loot", "OFFICER"); 
		else DEFAULT_CHAT_FRAME:AddMessage("You are not a Raid Leader/Assistant."); end
	end
end

function ColdEmbrace_GroupLoot()
	isLeader  = IsRaidLeader();
	isOfficer = IsRaidOfficer(); 
	lootmethod = GetLootMethod();
	if lootmethod == ("group") then DEFAULT_CHAT_FRAME:AddMessage("Group Loot already set.");
	elseif lootmethod == ("master") or lootmethod == ("freeforall") or lootmethod == ("roundrobin") or lootmethod == ("needbeforegreed") then
		if isLeader then SetLootMethod("group");
		elseif isOfficer then SendChatMessage("Please change to Group Loot", "OFFICER");
		else DEFAULT_CHAT_FRAME:AddMessage("You are not a Raid Leader/Assistant."); end
	end
end

function ColdEmbrace_RaidInvites()	
	guild = ("Cold Embrace");
	guildName, guildRankName, guildRankIndex = GetGuildInfo("Player");
	playerName = UnitName("Player");
	if guildRankIndex <= 3 then
		for i = 1,250 do
			name, rank, rankIndex, level, class, zone, note, officernote, online, status = GetGuildRosterInfo(i);
			if rankIndex <= 6 and online == 1 then
				InviteByName(name);
			end
		end
		if GetNumRaidMembers()  < 5 then SendChatMessage("Raid invites starting !", "GUILD"); end
		if GetNumRaidMembers()  > 0 then SendChatMessage("Write + for raid invite", "GUILD"); end
		if GetNumRaidMembers() == 0 and GetNumPartyMembers() > 0 then ConvertToRaid(); end
	else
		DEFAULT_CHAT_FRAME:AddMessage("Your rank is not high enough to do that.");
	end
end

-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
