local function vapeGithubRequest(scripturl)
	if not isfile("HT/"..scripturl) then
		local suc, res = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/HTIsOnTop/HT/"..readfile("HT/commithash.txt").."/"..scripturl, true) end)
		if not suc or res == "404: Not Found" then return nil end
		if res:find(".lua") then res = "--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.\n"..res end
		writefile("HT/"..scripturl, res)
	end
	return readfile("HT/"..scripturl)
end

shared.CustomSaveVape = 6872274481
if pcall(function() readfile("HT/CustomModules/6872274481.lua") end) then
	loadstring(readfile("HT/CustomModules/6872274481.lua"))()
else
	local publicrepo = vapeGithubRequest("CustomModules/6872274481.lua")
	if publicrepo then
		loadstring(publicrepo)()
	end
end