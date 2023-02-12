local errorPopupShown = false
local setidentity = syn and syn.set_thread_identity or set_thread_identity or setidentity or setthreadidentity or function() end
local getidentity = syn and syn.get_thread_identity or get_thread_identity or getidentity or getthreadidentity or function() return 8 end
local isfile = isfile or function(file)
	local suc, res = pcall(function() return readfile(file) end)
	return suc and res ~= nil
end
local delfile = delfile or function(file) writefile(file, "") end

local function displayErrorPopup(text, func)
	local oldidentity = getidentity()
	setidentity(8)
	local ErrorPrompt = getrenv().require(game:GetService("CoreGui").RobloxGui.Modules.ErrorPrompt)
	local prompt = ErrorPrompt.new("Default")
	prompt._hideErrorCode = true
	local gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
	prompt:setErrorTitle("HT")
	prompt:updateButtons({{
		Text = "OK",
		Callback = function() 
			prompt:_close() 
			if func then func() end
		end,
		Primary = true
	}}, 'Default')
	prompt:setParent(gui)
	prompt:_open(text)
	setidentity(oldidentity)
end

local function vapeGithubRequest(scripturl)
	if not isfile("HT/"..scripturl) then
		local suc, res
		task.delay(15, function()
			if not res and not errorPopupShown then 
				errorPopupShown = true
				displayErrorPopup("The connection to github is taking a while, Please be patient.")
			end
		end)
		suc, res = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/HTIsOnTop/HT/"..readfile("HT/commithash.txt").."/"..scripturl, true) end)
		if not suc then
			displayErrorPopup("Failed to connect to github : HT/"..scripturl.." : "..res)
			error(res)
		end
		writefile("HT/"..scripturl, res)
	end
	return readfile("HT/"..scripturl)
end

if not shared.VapeDeveloper then 
	local commit = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://api.github.com/repos/HTIsOnTop/HT/commits", true))[1].commit.url:split("/commits/")[2]
	if isfolder("HT") then 
		if ((not isfile("HT/commithash.txt")) or readfile("HT/commithash.txt") ~= commit) then
			for i,v in pairs({"HT/Universal.lua", "HT/MainScript.lua", "HT/GuiLibrary.lua"}) do 
				if isfile(v) and readfile(v):find("--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.") then
					delfile(v)
				end 
			end
			if isfolder("HT/CustomModules") then 
				for i,v in pairs(listfiles("HT/CustomModules")) do 
					if isfile(v) and readfile(v):find("--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.") then
						delfile(v)
					end 
				end
			end
			if isfolder("HT/Libraries") then 
				for i,v in pairs(listfiles("HT/Libraries")) do 
					if isfile(v) and readfile(v):find("--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.") then
						delfile(v)
					end 
				end
			end
			writefile("HT/commithash.txt", commit)
		end
	else
		makefolder("HT")
		writefile("HT/commithash.txt", commit)
	end
end

loadstring(vapeGithubRequest("MainScript.lua"))()