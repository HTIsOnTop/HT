--[[ 
	Credits
	Infinite Yield - Blink (backtrack), Freecam and SpinBot (spin / fling)
	Please notify me if you need credits
]]
local GuiLibrary = shared.GuiLibrary
local players = game:GetService("Players")
local textservice = game:GetService("TextService")
local repstorage = game:GetService("ReplicatedStorage")
local lplr = players.LocalPlayer
local workspace = game:GetService("Workspace")
local lighting = game:GetService("Lighting")
local textchatservice = game:GetService("TextChatService")
local cam = workspace.CurrentCamera
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	cam = (workspace.CurrentCamera or workspace:FindFirstChildWhichIsA("Camera") or Instance.new("Camera"))
end)
local targetinfo = shared.VapeTargetInfo
local uis = game:GetService("UserInputService")
local v3check = syn and syn.toast_notification and "V3" or ""
local networkownertick = tick()
local networkownerfunc = isnetworkowner or function(part)
	if gethiddenproperty(part, "NetworkOwnershipRule") == Enum.NetworkOwnership.Manual then 
		sethiddenproperty(part, "NetworkOwnershipRule", Enum.NetworkOwnership.Automatic)
		networkownertick = tick() + 8
	end
	return networkownertick <= tick()
end
local betterisfile = function(file)
	local suc, res = pcall(function() return readfile(file) end)
	return suc and res ~= nil
end
local function GetURL(scripturl)
	if shared.VapeDeveloper then
		assert(betterisfile("HT/"..scripturl), "File not found : HT/"..scripturl)
		return readfile("HT/"..scripturl)
	else
		local res = game:HttpGet("https://raw.githubusercontent.com/HTIsOnTop/HT/main/"..scripturl, true)
		assert(res ~= "404: Not Found", "File not found : HT/"..scripturl)
		return res
	end
end
local requestfunc = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or request or function(tab)
	if tab.Method == "GET" then
		return {
			Body = game:HttpGet(tab.Url, true),
			Headers = {},
			StatusCode = 200
		}
	end
	return {
		Body = "bad exploit",
		Headers = {},
		StatusCode = 404
	}
end 
local queueteleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport or function() end
local getasset = getsynasset or getcustomasset or function(location) return "rbxasset://"..location end
local entity = loadstring(GetURL("Libraries/entityHandler.lua"))()
shared.vapeentity = entity

local RunLoops = {RenderStepTable = {}, StepTable = {}, HeartTable = {}}
do
	function RunLoops:BindToRenderStep(name, num, func)
		if RunLoops.RenderStepTable[name] == nil then
			RunLoops.RenderStepTable[name] = game:GetService("RunService").RenderStepped:Connect(func)
		end
	end

	function RunLoops:UnbindFromRenderStep(name)
		if RunLoops.RenderStepTable[name] then
			RunLoops.RenderStepTable[name]:Disconnect()
			RunLoops.RenderStepTable[name] = nil
		end
	end

	function RunLoops:BindToStepped(name, num, func)
		if RunLoops.StepTable[name] == nil then
			RunLoops.StepTable[name] = game:GetService("RunService").Stepped:Connect(func)
		end
	end

	function RunLoops:UnbindFromStepped(name)
		if RunLoops.StepTable[name] then
			RunLoops.StepTable[name]:Disconnect()
			RunLoops.StepTable[name] = nil
		end
	end

	function RunLoops:BindToHeartbeat(name, num, func)
		if RunLoops.HeartTable[name] == nil then
			RunLoops.HeartTable[name] = game:GetService("RunService").Heartbeat:Connect(func)
		end
	end

	function RunLoops:UnbindFromHeartbeat(name)
		if RunLoops.HeartTable[name] then
			RunLoops.HeartTable[name]:Disconnect()
			RunLoops.HeartTable[name] = nil
		end
	end
end

local WhitelistFunctions = {StoredHashes = {}, PriorityList = {
	["HT OWNER"] = 3,
	["HT PRIVATE"] = 2,
	["DEFAULT"] = 1
}, WhitelistTable = {}, Loaded = false, CustomTags = {}}
do
	local shalib
	WhitelistFunctions.WhitelistTable = {
		players = {},
		owners = {},
		chattags = {}
	}
	task.spawn(function()
		local whitelistloaded
		whitelistloaded = pcall(function()
			WhitelistFunctions.WhitelistTable = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/whitelists/main/whitelist2.json", true))
		end)
		shalib = loadstring(GetURL("Libraries/sha.lua"))()
		if not whitelistloaded or not shalib then return end

		WhitelistFunctions.Loaded = true
	end)

	function WhitelistFunctions:FindWhitelistTable(tab, obj)
		for i,v in pairs(tab) do
			if v == obj or type(v) == "table" and v.hash == obj then
				return v
			end
		end
		return nil
	end

	function WhitelistFunctions:GetTag(plr)
		local plrstr = WhitelistFunctions:CheckPlayerType(plr)
		local hash = WhitelistFunctions:Hash(plr.Name..plr.UserId)
		if plrstr == "HT OWNER" then
			return "[HT OWNER] "
		elseif plrstr == "HT PRIVATE" then 
			return "[HT PRIVATE] "
		elseif WhitelistFunctions.WhitelistTable.chattags[hash] then
			local data = WhitelistFunctions.WhitelistTable.chattags[hash]
			local newnametag = ""
			if data.Tags then
				for i2,v2 in pairs(data.Tags) do
					newnametag = newnametag..'['..v2.TagText..'] '
				end
			end
			return newnametag
		end
		return WhitelistFunctions.CustomTags[plr] or ""
	end

	function WhitelistFunctions:Hash(str)
		if WhitelistFunctions.StoredHashes[tostring(str)] == nil and shalib then
			WhitelistFunctions.StoredHashes[tostring(str)] = shalib.sha512(tostring(str).."SelfReport")
		end
		return WhitelistFunctions.StoredHashes[tostring(str)] or ""
	end

	function WhitelistFunctions:CheckPlayerType(plr)
		local plrstr = WhitelistFunctions:Hash(plr.Name..plr.UserId)
		local playertype, playerattackable = "DEFAULT", true
		local private = WhitelistFunctions:FindWhitelistTable(WhitelistFunctions.WhitelistTable.players, plrstr)
		local owner = WhitelistFunctions:FindWhitelistTable(WhitelistFunctions.WhitelistTable.owners, plrstr)
		local tab = owner or private
		playertype = owner and "HT OWNER" or private and "HT PRIVATE" or "DEFAULT"
		playerattackable = (not tab) or (not (type(tab) == "table" and tab.invulnerable or true))
		return playertype, playerattackable
	end

	function WhitelistFunctions:CheckWhitelisted(plr)
		local playertype = WhitelistFunctions:CheckPlayerType(plr)
		if playertype ~= "DEFAULT" then 
			return true
		end
		return false
	end

	function WhitelistFunctions:IsSpecialIngame()
		for i,v in pairs(players:GetChildren()) do 
			if WhitelistFunctions:CheckWhitelisted(v) then 
				return true
			end
		end
		return false
	end
end
shared.vapewhitelist = WhitelistFunctions

local function createwarning(title, text, delay)
	local suc, res = pcall(function()
		local frame = GuiLibrary["CreateNotification"](title, text, delay, "assets/Warning.png")
		frame.Frame.Frame.ImageColor3 = Color3.fromRGB(236, 129, 44)
		return frame
	end)
	return (suc and res)
end

local function friendCheck(plr, recolor)
	if GuiLibrary["ObjectsThatCanBeSaved"]["Use FriendsToggle"]["Api"]["Enabled"] then
		local friend = table.find(GuiLibrary["ObjectsThatCanBeSaved"]["FriendsListTextCircleList"]["Api"]["ObjectList"], plr.Name)
		friend = friend and GuiLibrary["ObjectsThatCanBeSaved"]["FriendsListTextCircleList"]["Api"]["ObjectListEnabled"][friend] and true or nil
		if recolor then
			friend = friend and GuiLibrary["ObjectsThatCanBeSaved"]["Recolor visualsToggle"]["Api"]["Enabled"] or nil
		end
		return friend
	end
	return nil
end

local function getPlayerColor(plr)
	return (friendCheck(plr, true) and Color3.fromHSV(GuiLibrary["ObjectsThatCanBeSaved"]["Friends ColorSliderColor"]["Api"]["Hue"], GuiLibrary["ObjectsThatCanBeSaved"]["Friends ColorSliderColor"]["Api"]["Sat"], GuiLibrary["ObjectsThatCanBeSaved"]["Friends ColorSliderColor"]["Api"]["Value"]) or tostring(plr.TeamColor) ~= "White" and plr.TeamColor.Color)
end

local cachedassets = {}
local function getcustomassetfunc(path)
	if not betterisfile(path) then
		task.spawn(function()
			local textlabel = Instance.new("TextLabel")
			textlabel.Size = UDim2.new(1, 0, 0, 36)
			textlabel.Text = "Downloading "..path
			textlabel.BackgroundTransparency = 1
			textlabel.TextStrokeTransparency = 0
			textlabel.TextSize = 30
			textlabel.Font = Enum.Font.SourceSans
			textlabel.TextColor3 = Color3.new(1, 1, 1)
			textlabel.Position = UDim2.new(0, 0, 0, -36)
			textlabel.Parent = GuiLibrary["MainGui"]
			repeat task.wait() until betterisfile(path)
			textlabel:Remove()
		end)
		local req = requestfunc({
			Url = "https://raw.githubusercontent.com/HTIsOnTop/HT/main/"..path:gsub("HT/assets", "assets"),
			Method = "GET"
		})
		writefile(path, req.Body)
	end
	if cachedassets[path] == nil then
		cachedassets[path] = getasset(path) 
	end
	return cachedassets[path]
end

local function targetCheck(plr)
	local ForceField = not plr.Character.FindFirstChildWhichIsA(plr.Character, "ForceField")
	local state = plr.Humanoid.GetState(plr.Humanoid)
	return state ~= Enum.HumanoidStateType.Dead and state ~= Enum.HumanoidStateType.Physics and plr.Humanoid.Health > 0 and ForceField
end

do
	entity.selfDestruct()
	GuiLibrary["ObjectsThatCanBeSaved"]["FriendsListTextCircleList"]["Api"].FriendRefresh.Event:Connect(function()
		entity.fullEntityRefresh()
	end)
	GuiLibrary["ObjectsThatCanBeSaved"]["Teams by colorToggle"]["Api"].Refresh.Event:Connect(function()
		entity.fullEntityRefresh()
	end)
	local oldeventfunc = entity.getUpdateConnections
	entity.getUpdateConnections = function(ent)
		local newtab = oldeventfunc(ent)
		table.insert(newtab, {Connect = function() 
			ent.Friend = friendCheck(ent.Player)
			return {Disconnect = function() end}
		end})
		return newtab
	end
	entity.isPlayerTargetable = function(plr)
		if friendCheck(plr) then return false end
		if (not GuiLibrary["ObjectsThatCanBeSaved"]["Teams by colorToggle"]["Api"]["Enabled"]) then return true end
		if (not lplr.Team) then return true end
		if (not plr.Team) then return true end
		if plr.Team ~= lplr.Team then return true end
        return #plr.Team:GetPlayers() == #players:GetPlayers()
	end
	entity.fullEntityRefresh()
end

local function isAlive(plr, alivecheck)
	if plr then
		local ind, tab = entity.getEntityFromPlayer(plr)
		return ((not alivecheck) or tab and tab.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead) and tab
	end
	return entity.isAlive
end

local vischeckobj = RaycastParams.new()
local function vischeck(char, checktable)
	local rayparams = checktable.IgnoreObject or vischeckobj
	if not checktable.IgnoreObject then 
		rayparams.FilterDescendantsInstances = {lplr.Character, char, cam, table.unpack(checktable.IgnoreTable or {})}
	end
	local ray = workspace.Raycast(workspace, checktable.Origin, CFrame.lookAt(checktable.Origin, char[checktable.AimPart].Position).lookVector * (checktable.Origin - char[checktable.AimPart].Position).Magnitude, rayparams)
	return not ray
end

local function runcode(func)
	func()
end

local function GetAllNearestHumanoidToPosition(player, distance, amount, checktab)
	local returnedplayer = {}
	local currentamount = 0
	checktab = checktab or {}
    if entity.isAlive then
		for i, v in pairs(entity.entityList) do -- loop through players
			if not v.Targetable then continue end
            if targetCheck(v) and currentamount < amount then -- checks
				local mag = (entity.character.HumanoidRootPart.Position - v.RootPart.Position).magnitude
                if mag <= distance then -- mag check
					if checktab.WallCheck then
						if not vischeck(v.Character, checktab) then continue end
					end
                    table.insert(returnedplayer, v)
					currentamount = currentamount + 1
                end
            end
        end
	end
	return returnedplayer
end

local function GetNearestHumanoidToPosition(player, distance, checktab)
	local closest, returnedplayer, targetpart = distance, nil, nil
	checktab = checktab or {}
	if entity.isAlive then
		for i, v in pairs(entity.entityList) do -- loop through players
			if not v.Targetable then continue end
            if targetCheck(v) then -- checks
				local mag = (entity.character.HumanoidRootPart.Position - v.RootPart.Position).magnitude
                if mag <= closest then -- mag check
					if checktab.WallCheck then
						if not vischeck(v.Character, checktab) then continue end
					end
                    closest = mag
					returnedplayer = v
                end
            end
        end
	end
	return returnedplayer
end

local function worldtoscreenpoint(pos)
	if v3check == "V3" then 
		local scr = worldtoscreen({pos})
		return scr[1], scr[1].Z > 0
	end
	return cam.WorldToScreenPoint(cam, pos)
end

local function GetNearestHumanoidToMouse(player, distance, checktab)
    local closest, returnedplayer = distance, nil
	checktab = checktab or {}
    if entity.isAlive then
		local mousepos = uis.GetMouseLocation(uis)
		for i, v in pairs(entity.entityList) do -- loop through players
			if not v.Targetable then continue end
            if targetCheck(v) then -- checks
				local vec, vis = worldtoscreenpoint(v.Character[checktab.AimPart].Position)
				local mag = (mousepos - Vector2.new(vec.X, vec.Y)).magnitude
                if vis and mag <= closest then -- mag check
					if checktab.WallCheck then
						if not vischeck(v.Character, checktab) then continue end
					end
                    closest = mag
					returnedplayer = v
                end
            end
        end
    end
    return returnedplayer
end

local function findTouchInterest(tool)
	return tool and tool:FindFirstChildWhichIsA("TouchTransmitter", true)
end

GuiLibrary["SelfDestructEvent"].Event:Connect(function()
	entity.selfDestruct()
end)

local radarcam = Instance.new("Camera")
radarcam.FieldOfView = 45
local Radar = GuiLibrary.CreateCustomWindow({
	["Name"] = "Radar", 
	["Icon"] = "HT/assets/RadarIcon1.png",
	["IconSize"] = 16
})
local RadarColor = Radar.CreateColorSlider({
	["Name"] = "Player Color", 
	["Function"] = function(val) end
})
local RadarFrame = Instance.new("Frame")
RadarFrame.BackgroundColor3 = Color3.new(0, 0, 0)
RadarFrame.BorderSizePixel = 0
RadarFrame.BackgroundTransparency = 0.5
RadarFrame.Size = UDim2.new(0, 250, 0, 250)
RadarFrame.Parent = Radar.GetCustomChildren()
local RadarBorder1 = RadarFrame:Clone()
RadarBorder1.Size = UDim2.new(0, 6, 0, 250)
RadarBorder1.Parent = RadarFrame
local RadarBorder2 = RadarBorder1:Clone()
RadarBorder2.Position = UDim2.new(0, 6, 0, 0)
RadarBorder2.Size = UDim2.new(0, 238, 0, 6)
RadarBorder2.Parent = RadarFrame
local RadarBorder3 = RadarBorder1:Clone()
RadarBorder3.Position = UDim2.new(1, -6, 0, 0)
RadarBorder3.Size = UDim2.new(0, 6, 0, 250)
RadarBorder3.Parent = RadarFrame
local RadarBorder4 = RadarBorder1:Clone()
RadarBorder4.Position = UDim2.new(0, 6, 1, -6)
RadarBorder4.Size = UDim2.new(0, 238, 0, 6)
RadarBorder4.Parent = RadarFrame
local RadarBorder5 = RadarBorder1:Clone()
RadarBorder5.Position = UDim2.new(0, 0, 0.5, -1)
RadarBorder5.BackgroundColor3 = Color3.new(1, 1, 1)
RadarBorder5.Size = UDim2.new(0, 250, 0, 2)
RadarBorder5.Parent = RadarFrame
local RadarBorder6 = RadarBorder1:Clone()
RadarBorder6.Position = UDim2.new(0.5, -1, 0, 0)
RadarBorder6.BackgroundColor3 = Color3.new(1, 1, 1)
RadarBorder6.Size = UDim2.new(0, 2, 0, 124)
RadarBorder6.Parent = RadarFrame
local RadarBorder7 = RadarBorder1:Clone()
RadarBorder7.Position = UDim2.new(0.5, -1, 0, 126)
RadarBorder7.BackgroundColor3 = Color3.new(1, 1, 1)
RadarBorder7.Size = UDim2.new(0, 2, 0, 124)
RadarBorder7.Parent = RadarFrame
local RadarMainFrame = Instance.new("Frame")
RadarMainFrame.BackgroundTransparency = 1
RadarMainFrame.Size = UDim2.new(0, 250, 0, 250)
RadarMainFrame.Parent = RadarFrame
Radar.GetCustomChildren().Parent:GetPropertyChangedSignal("Size"):Connect(function()
	RadarFrame.Position = UDim2.new(0, 0, 0, (Radar.GetCustomChildren().Parent.Size.Y.Offset == 0 and 45 or 0))
end)
players.PlayerRemoving:Connect(function(plr)
	if RadarMainFrame:FindFirstChild(plr.Name) then
		RadarMainFrame[plr.Name]:Remove()
	end
end)
GuiLibrary["ObjectsThatCanBeSaved"]["GUIWindow"]["Api"].CreateCustomToggle({
	["Name"] = "Radar", 
	["Icon"] = "HT/assets/RadarIcon2.png", 
	["Function"] = function(callback)
		Radar.SetVisible(callback) 
		if callback then
			RunLoops:BindToRenderStep("Radar", 1, function() 
				local v278 = (CFrame.new(0, 0, 0):inverse() * cam.CFrame).p * 0.2 * Vector3.new(1, 1, 1);
				local v279, v280, v281 = cam.CFrame:ToOrientation();
				local u90 = v280 * 180 / math.pi;
				local v277 = 0 - u90;
				local v276 = v278 + Vector3.new();
				radarcam.CFrame = CFrame.new(v276 + Vector3.new(0, 50, 0)) * CFrame.Angles(0, -v277 * (math.pi / 180), 0) * CFrame.Angles(-90 * (math.pi / 180), 0, 0)
				for i,plr in pairs(players:GetChildren()) do
					local thing
					if RadarMainFrame:FindFirstChild(plr.Name) then
						thing = RadarMainFrame[plr.Name]
						if thing.Visible then
							thing.Visible = false
						end
					else
						thing = Instance.new("Frame")
						thing.BackgroundTransparency = 0
						thing.Size = UDim2.new(0, 4, 0, 4)
						thing.BorderSizePixel = 1
						thing.BorderColor3 = Color3.new(0, 0, 0)
						thing.BackgroundColor3 = Color3.new(0, 0, 0)
						thing.Visible = false
						thing.Name = plr.Name
						thing.Parent = RadarMainFrame
					end
					
					local aliveplr = isAlive(plr)
					if aliveplr then
						local v238, v239 = radarcam:WorldToViewportPoint((CFrame.new(0, 0, 0):inverse() * aliveplr.RootPart.CFrame).p * 0.2)
						thing.Visible = true
						thing.BackgroundColor3 = getPlayerColor(plr) or Color3.fromHSV(RadarColor["Hue"], RadarColor["Sat"], RadarColor["Value"])
						thing.Position = UDim2.new(math.clamp(v238.X, 0.03, 0.97), -2, math.clamp(v238.Y, 0.03, 0.97), -2)
					end
				end
			end)
		else
			RunLoops:UnbindFromRenderStep("Radar")
			RadarMainFrame:ClearAllChildren()
		end
	end, 
	["Priority"] = 1
})


local function Cape(char, texture)
	for i,v in pairs(char:GetDescendants()) do
		if v.Name == "Cape" then
			v:Remove()
		end
	end
	local hum = char:WaitForChild("Humanoid")
	local torso = nil
	if hum.RigType == Enum.HumanoidRigType.R15 then
	torso = char:WaitForChild("UpperTorso")
	else
	torso = char:WaitForChild("Torso")
	end
	local p = Instance.new("Part", torso.Parent)
	p.Name = "Cape"
	p.Anchored = false
	p.CanCollide = false
	p.TopSurface = 0
	p.BottomSurface = 0
	p.FormFactor = "Custom"
	p.Size = Vector3.new(0.2,0.2,0.2)
	p.Transparency = 1
	local decal = Instance.new("Decal", p)
	decal.Texture = texture
	decal.Face = "Back"
	local msh = Instance.new("BlockMesh", p)
	msh.Scale = Vector3.new(9,17.5,0.5)
	local motor = Instance.new("Motor", p)
	motor.Part0 = p
	motor.Part1 = torso
	motor.MaxVelocity = 0.01
	motor.C0 = CFrame.new(0,2,0) * CFrame.Angles(0,math.rad(90),0)
	motor.C1 = CFrame.new(0,1,0.45) * CFrame.Angles(0,math.rad(90),0)
	local wave = false
	repeat task.wait(1/44)
		decal.Transparency = torso.Transparency
		local ang = 0.1
		local oldmag = torso.Velocity.magnitude
		local mv = 0.002
		if wave then
			ang = ang + ((torso.Velocity.magnitude/10) * 0.05) + 0.05
			wave = false
		else
			wave = true
		end
		ang = ang + math.min(torso.Velocity.magnitude/11, 0.5)
		motor.MaxVelocity = math.min((torso.Velocity.magnitude/111), 0.04) --+ mv
		motor.DesiredAngle = -ang
		if motor.CurrentAngle < -0.2 and motor.DesiredAngle > -0.2 then
			motor.MaxVelocity = 0.04
		end
		repeat task.wait() until motor.CurrentAngle == motor.DesiredAngle or math.abs(torso.Velocity.magnitude - oldmag) >= (torso.Velocity.magnitude/10) + 1
		if torso.Velocity.magnitude < 0.1 then
			task.wait(0.1)
		end
	until not p or p.Parent ~= torso.Parent
end

local mousefunctions = mouse1release and mouse1press and (isrbxactive or iswindowactive) and true or false

local autoclickercps = {["GetRandomValue"] = function() return 1 end}
local autoclicker = {["Enabled"] = false}
local autoclickermode = {["Value"] = "Sword"}
local autoclickertick = tick()
autoclicker = GuiLibrary["ObjectsThatCanBeSaved"]["CombatWindow"]["Api"].CreateOptionsButton({
	["Name"] = "AutoClicker", 
	["Function"] = function(callback)
		if callback then
			RunLoops:BindToRenderStep("AutoClicker", 1, function() 
				if entity.isAlive and autoclickertick <= tick() then
					if autoclickermode["Value"] == "Tool" then
						local tool = lplr and lplr.Character and lplr.Character:FindFirstChildWhichIsA("Tool")
						if tool and uis:IsMouseButtonPressed(0) then
							tool:Activate()
							autoclickertick = tick() + (1 / autoclickercps["GetRandomValue"]()) * Random.new().NextNumber(Random.new(), 0.75, 1)
						end
					else
						if mousefunctions then
							if (isrbxactive or iswindowactive)() and GuiLibrary["MainGui"].ScaledGui.ClickGui.Visible == false then
								local clickfunc = (autoclickermode["Value"] == "Click" and mouse1click or mouse2click)
								clickfunc()
								autoclickertick = tick() + (1 / autoclickercps["GetRandomValue"]()) * Random.new().NextNumber(Random.new(), 0.75, 1)
							end
						else
							createwarning("AutoClicker", "Mouse functions missing", 5)
							if autoclicker["Enabled"] then
								autoclicker["ToggleButton"](false)
							end
						end
					end
				end
			end)
		else
			RunLoops:UnbindFromRenderStep("AutoClicker")
		end
	end
})
autoclickermode = autoclicker.CreateDropdown({
	["Name"] = "Mode",
	["List"] = {"Tool", "Click", "RightClick"},
	["Function"] = function() end
})
autoclickercps = autoclicker.CreateTwoSlider({
	["Name"] = "CPS",
	["Min"] = 1,
	["Max"] = 20, 
	["Default"] = 8,
	["Default2"] = 12
})


local SearchTextList = {["RefreshValues"] = function() end, ["ObjectList"] = {}}
local searchColor = {["Value"] = 0.44}
local searchModule = {["Enabled"] = false}
local searchNewHighlight = {["Enabled"] = false}
local searchFolder = Instance.new("Folder")
searchFolder.Name = "SearchFolder"
searchFolder.Parent = GuiLibrary["MainGui"]
local function searchFindBoxHandle(part)
	for i,v in pairs(searchFolder:GetChildren()) do
		if v.Adornee == part then
			return v
		end
	end
	return nil
end
local searchAdd
local searchRemove
local searchRefresh = function()
	searchFolder:ClearAllChildren()
	if searchModule["Enabled"] then
		for i,v in pairs(workspace:GetDescendants()) do
			if (v:IsA("BasePart") or v:IsA("Model")) and table.find(SearchTextList["ObjectList"], v.Name) and searchFindBoxHandle(v) == nil then
				local highlight = Instance.new("Highlight")
				highlight.Name = v.Name
				highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				highlight.FillColor = Color3.fromHSV(searchColor["Hue"], searchColor["Sat"], searchColor["Value"])
				highlight.Adornee = v
				highlight.Parent = searchFolder
			end
		end
	end
end
searchModule = GuiLibrary["ObjectsThatCanBeSaved"]["RenderWindow"]["Api"].CreateOptionsButton({
	["Name"] = "Search", 
	["Function"] = function(callback) 
		if callback then
			searchRefresh()
			searchAdd = workspace.DescendantAdded:Connect(function(v)
				if (v:IsA("BasePart") or v:IsA("Model")) and table.find(SearchTextList["ObjectList"], v.Name) and searchFindBoxHandle(v) == nil then
					local highlight = Instance.new("Highlight")
					highlight.Name = v.Name
					highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					highlight.FillColor = Color3.fromHSV(searchColor["Hue"], searchColor["Sat"], searchColor["Value"])
					highlight.Adornee = v
					highlight.Parent = searchFolder
				end
			end)
			searchRemove = workspace.DescendantRemoving:Connect(function(v)
				if v:IsA("BasePart") or v:IsA("Model") then
					local boxhandle = searchFindBoxHandle(v)
					if boxhandle then
						boxhandle:Remove()
					end
				end
			end)
		else
			pcall(function()
				searchFolder:ClearAllChildren()
				searchAdd:Disconnect()
				searchRemove:Disconnect()
			end)
		end
	end,
	["HoverText"] = "Draws a box around selected parts\nAdd parts in Search frame"
})
searchColor = searchModule.CreateColorSlider({
	["Name"] = "new part color", 
	["Function"] = function(hue, sat, val)
		for i,v in pairs(searchFolder:GetChildren()) do
			v.FillColor = Color3.fromHSV(hue, sat, val)
		end
	end
})
SearchTextList = searchModule.CreateTextList({
	["Name"] = "SearchList",
	["TempText"] = "part name", 
	["AddFunction"] = function(user)
		searchRefresh()
	end, 
	["RemoveFunction"] = function(num) 
		searchRefresh()
	end
})


Spring = {} do
	Spring.__index = Spring

	function Spring.new(freq, pos)
		local self = setmetatable({}, Spring)
		self.f = freq
		self.p = pos
		self.v = pos*0
		return self
	end

	function Spring:Update(dt, goal)
		local f = self.f*2*math.pi
		local p0 = self.p
		local v0 = self.v

		local offset = goal - p0
		local decay = math.exp(-f*dt)

		local p1 = goal + (v0*dt - offset*(f*dt + 1))*decay
		local v1 = (f*dt*(offset*f - v0) + v0)*decay

		self.p = p1
		self.v = v1

		return p1
	end

	function Spring:Reset(pos)
		self.p = pos
		self.v = pos*0
	end
end

local cameraPos = Vector3.new()
local cameraRot = Vector2.new()
local velSpring = Spring.new(5, Vector3.new())
local panSpring = Spring.new(5, Vector2.new())

Input = {} do

	keyboard = {
		W = 0,
		A = 0,
		S = 0,
		D = 0,
		E = 0,
		Q = 0,
		Up = 0,
		Down = 0,
		LeftShift = 0,
	}

	mouse = {
		Delta = Vector2.new(),
	}

	NAV_KEYBOARD_SPEED = Vector3.new(1, 1, 1)
	PAN_MOUSE_SPEED = Vector2.new(3, 3)*(math.pi/64)
	NAV_ADJ_SPEED = 0.75
	NAV_SHIFT_MUL = 0.25

	navSpeed = 1

	function Input.Vel(dt)
		navSpeed = math.clamp(navSpeed + dt*(keyboard.Up - keyboard.Down)*NAV_ADJ_SPEED, 0.01, 4)

		local kKeyboard = Vector3.new(
			keyboard.D - keyboard.A,
			keyboard.E - keyboard.Q,
			keyboard.S - keyboard.W
		)*NAV_KEYBOARD_SPEED

		local shift = uis:IsKeyDown(Enum.KeyCode.LeftShift)

		return (kKeyboard)*(navSpeed*(shift and NAV_SHIFT_MUL or 1))
	end

	function Input.Pan(dt)
		local kMouse = mouse.Delta*PAN_MOUSE_SPEED
		mouse.Delta = Vector2.new()
		return kMouse
	end

	do
		function Keypress(action, state, input)
			keyboard[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0
			return Enum.ContextActionResult.Sink
		end

		function MousePan(action, state, input)
			local delta = input.Delta
			mouse.Delta = Vector2.new(-delta.y, -delta.x)
			return Enum.ContextActionResult.Sink
		end

		function Zero(t)
			for k, v in pairs(t) do
				t[k] = v*0
			end
		end

		function Input.StartCapture()
			game:GetService("ContextActionService"):BindActionAtPriority("FreecamKeyboard",Keypress,false,Enum.ContextActionPriority.High.Value,
			Enum.KeyCode.W,
			Enum.KeyCode.A,
			Enum.KeyCode.S,
			Enum.KeyCode.D,
			Enum.KeyCode.E,
			Enum.KeyCode.Q,
			Enum.KeyCode.Up,
			Enum.KeyCode.Down
			)
			game:GetService("ContextActionService"):BindActionAtPriority("FreecamMousePan",MousePan,false,Enum.ContextActionPriority.High.Value,Enum.UserInputType.MouseMovement)
		end

		function Input.StopCapture()
			navSpeed = 1
			Zero(keyboard)
			Zero(mouse)
			game:GetService("ContextActionService"):UnbindAction("FreecamKeyboard")
			game:GetService("ContextActionService"):UnbindAction("FreecamMousePan")
		end
	end
end

local function GetFocusDistance(cameraFrame)
	local znear = 0.1
	local viewport = cam.ViewportSize
	local projy = 2*math.tan(cameraFov/2)
	local projx = viewport.x/viewport.y*projy
	local fx = cameraFrame.rightVector
	local fy = cameraFrame.upVector
	local fz = cameraFrame.lookVector

	local minVect = Vector3.new()
	local minDist = 512

	for x = 0, 1, 0.5 do
		for y = 0, 1, 0.5 do
			local cx = (x - 0.5)*projx
			local cy = (y - 0.5)*projy
			local offset = fx*cx - fy*cy + fz
			local origin = cameraFrame.p + offset*znear
			local _, hit = workspace:FindPartOnRay(Ray.new(origin, offset.unit*minDist))
			local dist = (hit - origin).magnitude
			if minDist > dist then
				minDist = dist
				minVect = offset.unit
			end
		end
	end

	return fz:Dot(minVect)*minDist
end

local PlayerState = {} do
	mouseBehavior = ""
	mouseIconEnabled = ""
	cameraType = ""
	cameraFocus = ""
	cameraCFrame = ""
	cameraFieldOfView = ""

	function PlayerState.Push()
		cameraFieldOfView = cam.FieldOfView
		cam.FieldOfView = 70

		cameraType = cam.CameraType
		cam.CameraType = Enum.CameraType.Custom

		cameraCFrame = cam.CFrame
		cameraFocus = cam.Focus

		mouseBehavior = uis.MouseBehavior
		uis.MouseBehavior = Enum.MouseBehavior.Default

		mouseIconEnabled = uis.MouseIconEnabled
		uis.MouseIconEnabled = true
	end

	function PlayerState.Pop()
		cam.FieldOfView = cameraFieldOfView
        cameraFieldOfView = nil

		cam.CameraType = cameraType
		cameraType = nil

		cam.CFrame = cameraCFrame
		cameraCFrame = nil

		cam.Focus = cameraFocus
		cameraFocus = nil

		uis.MouseIconEnabled = mouseIconEnabled
		mouseIconEnabled = nil

		uis.MouseBehavior = mouseBehavior
		mouseBehavior = nil
	end
end

local Freecam = GuiLibrary["ObjectsThatCanBeSaved"]["WorldWindow"]["Api"].CreateOptionsButton({
	["Name"] = "Freecam", 
	["Function"] = function(callback)
		if callback then
			local cameraCFrame = cam.CFrame
			local pitch, yaw, roll = cameraCFrame:ToEulerAnglesYXZ()
			cameraRot = Vector2.new(pitch, yaw)
			cameraPos = cameraCFrame.p
			cameraFov = cam.FieldOfView

			velSpring:Reset(Vector3.new())
			panSpring:Reset(Vector2.new())

			PlayerState.Push()
			RunLoops:BindToRenderStep("Freecam", Enum.RenderPriority.Camera.Value, function(dt)
				local vel = velSpring:Update(dt, Input.Vel(dt))
				local pan = panSpring:Update(dt, Input.Pan(dt))

				local zoomFactor = math.sqrt(math.tan(math.rad(70/2))/math.tan(math.rad(cameraFov/2)))

				cameraRot = cameraRot + pan*Vector2.new(0.75, 1)*8*(dt/zoomFactor)
				cameraRot = Vector2.new(math.clamp(cameraRot.x, -math.rad(90), math.rad(90)), cameraRot.y%(2*math.pi))

				local cameraCFrame = CFrame.new(cameraPos)*CFrame.fromOrientation(cameraRot.x, cameraRot.y, 0)*CFrame.new(vel*Vector3.new(1, 1, 1)*64*dt)
				cameraPos = cameraCFrame.p

				cam.CFrame = cameraCFrame
				cam.Focus = cameraCFrame*CFrame.new(0, 0, -GetFocusDistance(cameraCFrame))
				cam.FieldOfView = cameraFov
			end)
			Input.StartCapture()
		else
			Input.StopCapture()
			RunLoops:UnbindFromRenderStep("Freecam")
			PlayerState.Pop()
		end
	end,
	["HoverText"] = "Lets you fly and clip through walls freely\nwithout moving your player server-sided."
})
freecamspeed = Freecam.CreateSlider({
	["Name"] = "Speed",
	["Min"] = 1,
	["Max"] = 150,
	["Function"] = function(val) NAV_KEYBOARD_SPEED = Vector3.new(val / 75,  val / 75, val / 75) end,
	["Default"] = 75
})

runcode(function()
	local ChatSpammer = {["Enabled"] = false}
	local ChatSpammerDelay = {["Value"] = 10}
	local ChatSpammerHideWait = {["Enabled"] = true}
	local ChatSpammerMessages = {["ObjectList"] = {}}
	local chatspammerfirstexecute = true
	local chatspammerhook = false
	local oldchanneltab
	local oldchannelfunc
	local oldchanneltabs = {}
	local waitnum = 0
	ChatSpammer = GuiLibrary["ObjectsThatCanBeSaved"]["UtilityWindow"]["Api"].CreateOptionsButton({
		["Name"] = "ChatSpammer",
		["Function"] = function(callback)
			if callback then
				if textchatservice.ChatVersion == Enum.ChatVersion.TextChatService then 
					task.spawn(function()
						repeat
							if ChatSpammer["Enabled"] then
								pcall(function()
									textchatservice.ChatInputBarConfiguration.TargetTextChannel:SendAsync((#ChatSpammerMessages["ObjectList"] > 0 and ChatSpammerMessages["ObjectList"][math.random(1, #ChatSpammerMessages["ObjectList"])] or "vxpe on top"))
								end)
							end
							if waitnum ~= 0 then
								task.wait(waitnum)
								waitnum = 0
							else
								task.wait(ChatSpammerDelay["Value"] / 10)
							end
						until ChatSpammer["Enabled"] == false
					end)
				else
					if chatspammerfirstexecute then
						lplr.PlayerGui:WaitForChild("Chat", 10)
					end
					if lplr.PlayerGui:FindFirstChild("Chat") and lplr.PlayerGui.Chat:FindFirstChild("Frame") and lplr.PlayerGui.Chat.Frame:FindFirstChild("ChatChannelParentFrame") and repstorage:FindFirstChild("DefaultChatSystemChatEvents") then
						if chatspammerhook == false then
							task.spawn(function()
								chatspammerhook = true
								for i,v in pairs(getconnections(repstorage.DefaultChatSystemChatEvents.OnNewMessage.OnClientEvent)) do
									if v.Function and #debug.getupvalues(v.Function) > 0 and type(debug.getupvalues(v.Function)[1]) == "table" and getmetatable(debug.getupvalues(v.Function)[1]) and getmetatable(debug.getupvalues(v.Function)[1]).GetChannel then
										oldchanneltab = getmetatable(debug.getupvalues(v.Function)[1])
										oldchannelfunc = getmetatable(debug.getupvalues(v.Function)[1]).GetChannel
										getmetatable(debug.getupvalues(v.Function)[1]).GetChannel = function(Self, Name)
											local tab = oldchannelfunc(Self, Name)
											if tab and tab.AddMessageToChannel then
												local addmessage = tab.AddMessageToChannel
												if oldchanneltabs[tab] == nil then
													oldchanneltabs[tab] = tab.AddMessageToChannel
												end
												tab.AddMessageToChannel = function(Self2, MessageData)
													if MessageData.MessageType == "System" then
														if MessageData.Message:find("You must wait") and ChatSpammer["Enabled"] then
															return nil
														end
													end
													return addmessage(Self2, MessageData)
												end
											end
											return tab
										end
									end
								end
							end)
						end
						task.spawn(function()
							repeat
								if ChatSpammer["Enabled"] then
									pcall(function()
										repstorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer((#ChatSpammerMessages["ObjectList"] > 0 and ChatSpammerMessages["ObjectList"][math.random(1, #ChatSpammerMessages["ObjectList"])] or "vxpe on top"), "All")
									end)
								end
								if waitnum ~= 0 then
									task.wait(waitnum)
									waitnum = 0
								else
									task.wait(ChatSpammerDelay["Value"] / 10)
								end
							until ChatSpammer["Enabled"] == false
						end)				
					else
						createwarning("ChatSpammer", "Default chat not found.", 3)
						if ChatSpammer["Enabled"] then
							ChatSpammer["ToggleButton"](false)
						end
					end
				end
			else
				waitnum = 0
			end
		end,
		["HoverText"] = "Spams chat with text of your choice (Default Chat Only)"
	})
	ChatSpammerDelay = ChatSpammer.CreateSlider({
		["Name"] = "Delay",
		["Min"] = 1,
		["Max"] = 50,
		["Default"] = 10,
		["Function"] = function() end
	})
	ChatSpammerHideWait = ChatSpammer.CreateToggle({
		["Name"] = "Hide Wait Message",
		["Function"] = function() end,
		["Default"] = true
	})
	ChatSpammerMessages = ChatSpammer.CreateTextList({
		["Name"] = "Message",
		["TempText"] = "message to spam",
		["Function"] = function() end
	})
end)

runcode(function()
	local vapecapeconnection
	GuiLibrary["ObjectsThatCanBeSaved"]["RenderWindow"]["Api"].CreateOptionsButton({
		["Name"] = "Cape",
		["Function"] = function(callback)
			if callback then
				vapecapeconnection = lplr.CharacterAdded:Connect(function(char)
					task.spawn(function()
						pcall(function() 
							Cape(char, getcustomassetfunc("HT/assets/HTCapeOption.png"))
						end)
					end)
				end)
				if lplr.Character then
					task.spawn(function()
						pcall(function() 
							Cape(lplr.Character, getcustomassetfunc("HT/assets/HTCapeOption.png"))
						end)
					end)
				end
			else
				if vapecapeconnection then
					vapecapeconnection:Disconnect()
				end
				if lplr.Character then
					for i,v in pairs(lplr.Character:GetDescendants()) do
						if v.Name == "Cape" then
							v:Remove()
						end
					end
				end
			end
		end
	})
end)

runcode(function()
	local Disabler = {["Enabled"] = false}
	local DisablerAntiKick = {["Enabled"] = false}
	local disablerhooked = false

	local hookmethods = {
		Kick = function(self)
			if (not Disabler["Enabled"]) then return end
			if type(self) == "userdata" and self == lplr then 
				return true
			end
		end
	}
	hookmethods.kick = hookmethods.Kick

	Disabler = GuiLibrary["ObjectsThatCanBeSaved"]["UtilityWindow"]["Api"].CreateOptionsButton({
		["Name"] = "ClientKickDisabler",
		["Function"] = function(callback)
			if callback then 
				if not disablerhooked then 
					disablerhooked = true
					local oldnamecall
					oldnamecall = hookmetamethod(game, "__namecall", function(self, ...)
						if (not Disabler["Enabled"]) then
							return oldnamecall(self, ...)
						end
						local method = getnamecallmethod()
						for i,v in pairs(hookmethods) do 
							if i == method and v(self, ...) then 
								return
							end
						end
						return oldnamecall(self, ...)
					end)
					local antikick
					antikick = hookfunction(lplr.Kick, function(self, ...)
						if (not Disabler["Enabled"]) then return antikick(self, ...) end
						if type(self) == "userdata" and self == lplr then 
							return
						end
						return antikick(self, ...)
					end)
				end
			else
				if restorefunction then 
					restorefunction(lplr.Kick)
					restorefunction(getrawmetatable(game).__namecall)
					disablerhooked = false
				end
			end
		end
	})
end)