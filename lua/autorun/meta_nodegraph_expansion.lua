if CLIENT then
	hook.Add("Initialize","NodegraphChangelogInit",function()
		local orange = Color(0,156,33)
		local green = Color(206,151,0)
		timer.Simple(10,function()
			chat.AddText(green,"Nodegraph Editor Changelog:")
			chat.AddText(orange," - Added 'Offset' option (modifies node height)")
		end)
	end)
end

if SERVER then
	util.AddNetworkString("sv_nodegrapheditor_getvectors")
	util.AddNetworkString("cl_nodegrapheditor_updatevectors")

	SLVNodegraphEditor = {}

	NAV_MIN_SIZE = 5000
	NAV_MAX_SIZE = 130000

	SLVNodegraphEditor.GetTargetNav = function(id)
		local tbl = navmesh.GetAllNavAreas()
		for _,v in pairs(tbl) do
			if v:GetID() == id then
				print(v:GetExtentInfo().SizeX *v:GetExtentInfo().SizeY)
			end
		end
	end

	SLVNodegraphEditor.GetNavSize = function(navArea)
		local info = navArea:GetExtentInfo()
		local area = info.SizeX *info.SizeY
		return area
	end

	SLVNodegraphEditor.GetNodeableNavAreas = function()
		local tblNavVectors = {}
		-- print("Total nav areas - " .. #SLVNodegraphEditor.GetNavAreas())
		for _,v in pairs(navmesh.GetAllNavAreas()) do
			if #tblNavVectors >= 4096 then break end
			local area = SLVNodegraphEditor.GetNavSize(v)
			if area > NAV_MIN_SIZE && area < NAV_MAX_SIZE then
				table.insert(tblNavVectors,v:GetCenter())
			elseif area > NAV_MAX_SIZE /*&& v:GetExtentInfo().SizeZ <= 2*/ then -- Pretty fucking massive nav area
				local totalPlace = math.Round(area /56400) or 4
				table.insert(tblNavVectors,v:GetCenter())
				for i = 1,totalPlace do
					table.insert(tblNavVectors,v:GetRandomPoint())
				end
			end
		end
		-- print("Total nodeable nav areas - " .. #tblNavVectors)
		return tblNavVectors
	end
end