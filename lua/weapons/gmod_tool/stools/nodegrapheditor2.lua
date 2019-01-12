//hook.Add("InitPostEntity","nodegrapheditor_mapspawninit",function()
	// RunConsoleCommand("ai_norebuildgraph","1") // Not neccessary anymore
//end)

TOOL.Category = "Map"
TOOL.Name = "Nodegraph Editor 2"
if(CLIENT) then
	language.Add("tool.nodegrapheditor.name","Nodegraph Editor 2")
	language.Add("tool.nodegrapheditor.desc","Edit a map's nodegraph.")
	language.Add("tool.nodegrapheditor.0","Left click to place a node at your crosshair, right click to place a node at your position. Hold your use or duck key and click on a node to edit links.")
	if(game.SinglePlayer()) then
		net.Receive("wrench_t_call",function(len)
			local tool = net.ReadString()
			local fc = net.ReadUInt(5)
			local wep = LocalPlayer():GetActiveWeapon()
			if(!wep:IsValid() || wep:GetClass() != "gmod_tool" || wep:GetMode() != tool) then return end
			local tool = wep:GetToolObject()
			local args = {}
			if(fc <= 1) then
				local StartPos = Vector(net.ReadDouble(),net.ReadDouble(),net.ReadDouble())
				local HitPos = Vector(net.ReadDouble(),net.ReadDouble(),net.ReadDouble())
				args[1] = {
					StartPos = StartPos,
					HitPos = HitPos,
					Normal = (HitPos -StartPos):GetNormal()
				}
			end
			if(fc == 0) then fc = "LeftClick"
			elseif(fc == 1) then fc = "RightClick"
			elseif(fc == 2) then fc = "Holster"
			elseif(fc == 3) then fc = "ScreenClick"
			elseif(fc == 4) then fc = "Deploy" end
			tool[fc](tool,unpack(args))
		end)
	end
else
	if(game.SinglePlayer()) then util.AddNetworkString("wrench_t_call") end
	AddCSLuaFile("effects/effect_node/init.lua")
	if(game.SinglePlayer()) then
		function TOOL:CallOnClient(...)
			local fc = ...
			net.Start("wrench_t_call")
				net.WriteString(self:GetMode())
				net.WriteUInt(fc,5)
				if(fc <= 1) then
					local tr = select(2,...)
					for i = 1,3 do net.WriteDouble(tr.StartPos[i]) end
					for i = 1,3 do net.WriteDouble(tr.HitPos[i]) end
				end
			net.Send(self:GetOwner())
		end
	end
end

local _R = debug.getregistry()
if(CLIENT) then
	local function NumSlider(self,strLabel,strConVar,numMin,numMax,numDecimals)
		local left = vgui.Create("DNumSliderLegacy",self)
		left:SetText(strLabel)
		left:SetMinMax(numMin,numMax)
		left:SetDark(true)
		
		if(numDecimals != nil) then left:SetDecimals(numDecimals) end
		left:SetConVar(strConVar)
		left:SizeToContents()
		self:AddItem(left,nil)
		return left
	end
	language.Add("undone_node","Undone Node")
	local function GetTool()
		local wep = LocalPlayer():GetActiveWeapon()
		if(!wep:IsValid() || wep:GetClass() != "gmod_tool" || wep:GetMode() != "nodegrapheditor") then return end
		return wep:GetToolObject()
	end
	local cvNotificationSave = CreateClientConVar("~cl_nodegraph_tool_notification_save",0,true)
	local function ShowFirstTimeNotification()
		local bNotification = cvNotificationSave:GetInt() == 2
		local w
		local pnl
		if(!bNotification) then
			RunConsoleCommand("~cl_nodegraph_tool_notification_save","2")
			w = 500
			pnl = vgui.Create("DFrame")
			pnl:SetTitle("Nodegraph Editor - First Time Notification")
			pnl:SizeToContents()
			pnl:MakePopup()
		end

		local y = 40
		local function AddLine(line)
			MsgN(line)
			if(bNotification) then return end
			local l = vgui.Create("DLabel",pnl)
			l:SetText(line)
			l:SetPos(20,y)
			l:SizeToContents()
			
			y = y +l:GetTall()
		end
		AddLine("This message will only show up once, it will only be printed in the console in the future!")
		AddLine("The nodegraph has been saved as '" .. game.GetMap() .. ".txt' in 'garrysmod/data/nodegraph/'.")
		AddLine("Due to limitations regarding file writing in lua, you will have to rename it to '" .. game.GetMap() .. ".ain'")
		AddLine("and move it to 'garrysmod/maps/graphs/' yourself. If this directory doesn't exist, create it. This")
		AddLine("needs to be done every time you change the nodegraph.")
		AddLine("Make sure to change the file extension by renaming the file. Opening it in a text-editor and saving")
		AddLine("it as '" .. game.GetMap() .. ".ain' will corrupt the nodegraph!")
		AddLine("")
		AddLine("Once you have done this, the game will use the new nodegraph the next time you load the map.")
		AddLine("You can use the modified nodegraph on any server, this addon isn't required for it to work.")
		if(bNotification) then return end
		local h = y +60
		local x,yPnl = ScrW() *0.5 -w *0.5,ScrH() *0.5 -h *0.5
		pnl:SetSize(w,h)
		pnl:SetPos(x,yPnl)

		local p = vgui.Create("DButton",pnl)
		p:SetText("OK")
		p.DoClick = function() pnl:Close() end
		p:SetPos(w *0.5 -p:GetWide() *0.5,y +20)
	end
	local bWarned
	local function ShowMapWarning()
		if(bWarned) then return end
		bWarned = true
		local map = game.GetMap()
		if(map != "gm_construct" && map != "gm_flatgrass") then return end
		local w = 500
		local pnl = vgui.Create("DFrame")
		pnl:SetTitle("Nodegraph Editor - Warning")
		pnl:SizeToContents()
		pnl:MakePopup()

		local y = 40
		local function AddLine(line)
			local l = vgui.Create("DLabel",pnl)
			l:SetText(line)
			l:SetPos(20,y)
			l:SizeToContents()
			
			y = y +l:GetTall()
		end
		AddLine("The nodegraph for this map is stored inside the gcf for garrysmod. That means that the game")
		AddLine("will always prioritize the version from the gcf. Any modifications you make will not work.")
		local h = y +60
		local x,yPnl = ScrW() *0.5 -w *0.5,ScrH() *0.5 -h *0.5
		pnl:SetSize(w,h)
		pnl:SetPos(x,yPnl)

		local p = vgui.Create("DButton",pnl)
		p:SetText("OK")
		p.DoClick = function() pnl:Close() end
		p:SetPos(w *0.5 -p:GetWide() *0.5,y +20)
	end
	local cvDist = CreateClientConVar("cl_nodegraph_tool_draw_distance",800,true)
	local cvDistAirNode = CreateClientConVar("cl_nodegraph_tool_airnode_distance",500,true)
	local cvDistLink = CreateClientConVar("cl_nodegraph_tool_max_link_distance",500,true)
	local cvDrawGround = CreateClientConVar("cl_nodegraph_tool_nodes_draw_ground",1,true)
	local cvDrawAir = CreateClientConVar("cl_nodegraph_tool_nodes_draw_air",0,true)
	local cvDrawClimb = CreateClientConVar("cl_nodegraph_tool_nodes_draw_climb",0,true)
	local cvCreateType = CreateClientConVar("cl_nodegraph_tool_node_type",NODE_TYPE_GROUND,true)
	local cvVis = CreateClientConVar("cl_nodegraph_tool_check_visibility",1,true)
	local cvDropToFloor = CreateClientConVar("cl_nodegraph_tool_droptofloor",0,true)
	local cvDrawPreview = CreateClientConVar("cl_nodegraph_tool_draw_preview",1,true)
	local cvSnap = CreateClientConVar("cl_nodegraph_tool_snap",0,true)
	local cvYaw = CreateClientConVar("cl_nodegraph_tool_yaw",0,false)
	local cvX = CreateClientConVar("cl_nodegraph_tool_x",0,false)
	local cvY = CreateClientConVar("cl_nodegraph_tool_y",0,false)
	local cvZ = CreateClientConVar("cl_nodegraph_tool_z",0,false)
	local cvShowYaw = CreateClientConVar("cl_nodegraph_tool_nodes_show_yaw",0,true)
	local matArrow = Material("widgets/arrow.png","nocull translucent vertexalpha smooth mips")
	local szArrow = 20
	local colArrow = Color(255,0,0,255)
	local colArrowSelected = Color(0,255,0,255)
	cvars.AddChangeCallback("cl_nodegraph_tool_yaw",function(cvar,prev,new)
		local tm = CurTime()
		local hk = "nodegrapheditor_renderyawarrow"
		local yaw = tonumber(new)
		if(cvShowYaw:GetBool()) then return end
		hook.Add("RenderScreenspaceEffects",hk,function()
			local tool = GetTool()
			if(tool && !cvShowYaw:GetBool()) then
				local a = math.min((1 -(((CurTime() -1) -tm) /2)) *255,255)
				if(a < 0) then hook.Remove("RenderScreenspaceEffects",hk)
				else
					local pos = tool:GetPreviewOrigin()
					cam.Start3D(EyePos(),EyeAngles())
						colArrow.a = a
						pos = pos +Vector(0,0,30)
						local dir = Angle(0,yaw,0):Forward()
						render.SetMaterial(matArrow)
						render.DepthRange(0,0.01)
						render.DrawBeam(pos,pos +dir *szArrow,6,1,0,colArrow)
					cam.End3D()
				end
			else hook.Remove("RenderScreenspaceEffects",hk) end
		end)
	end)
	local nodegraph
	local nodes,links,lookup
	function TOOL:LeftClick(tr)
		if(self.m_selected) then
			if(self:GetOwner():KeyDown(IN_DUCK) || self:GetOwner():KeyDown(IN_USE)) then
				if(self.m_bKeepSelection) then
					local nodeTrace,nodeTraceID = self:GetTraceNode()
					local nodeSelected = nodes[self.m_selected]
					if(nodeTrace == nodeSelected) then self:RemoveLinks(self.m_selected)
					elseif(self:HasLink(self.m_selected,nodeTraceID)) then self:RemoveLink(self.m_selected,nodeTraceID)
					else self:AddLink(self.m_selected,nodeTraceID) end
				else self:SolidifySelection() end
			else self:RemoveNode(self.m_selected) end
		else self:CreateNode(self:GetPreviewOrigin()) end
		return true
	end
	function TOOL:RightClick(tr)
		self:CreateNode(self:GetOwner():GetPos() +self:GetOwner():OBBCenter())
		return false
	end
	local MAX_NODES = 4096
	local NODE_CLIMB_ON			=	(bit.lshift(1,1))//,	// Node on ladder somewhere
	local NODE_CLIMB_OFF_FORWARD =	(bit.lshift(1,2))//,	// Dismount climb by going forward
	local NODE_CLIMB_OFF_LEFT	=	(bit.lshift(1,3))//,	// Dismount climb by going left
	local NODE_CLIMB_OFF_RIGHT	=	(bit.lshift(1,4))//,	// Dismount climb by going right
	local NODE_CLIMB_EXIT		=	bit.bor(NODE_CLIMB_OFF_FORWARD,NODE_CLIMB_OFF_LEFT,NODE_CLIMB_OFF_RIGHT)
	local q = 0
	function TOOL:CreateNode(pos)
		local createType = cvCreateType:GetInt()
		if cvDropToFloor:GetBool() == true then
			local tr = util.TraceLine({
				start = pos,
				endpos = pos -Vector(0,0,32768),
				mask = MASK_PLAYERSOLID_BRUSHONLY
			})
			if tr.Hit then
				pos = tr.HitPos +Vector(cvX:GetInt(),cvY:GetInt(),2)
			end
		end
		local nodeID = nodegraph:AddNode(pos,createType,cvYaw:GetInt(),info)
		if(!nodeID) then notification.AddLegacy("You can't place any additional nodes.",1,8); return end
		local numNodes = table.Count(nodes)
		local distMin = math.min(cvDist:GetInt(),cvDistLink:GetInt())
		local checkvis = cvVis:GetBool()
		for _,node in pairs(nodes) do
			if(_ != nodeID) then
				if(self:IsNodeTypeVisible(node.type)) then
					local d = node.pos:Distance(pos)
					if(d <= distMin) then
						if((node.type != NODE_TYPE_AIR && createType != NODE_TYPE_AIR) || node.type == createType) then
							if(self:IsLineClear(pos,node.pos)) then self:AddLink(nodeID,_) end
						end
					end
				end
			end
		end
		net.Start("sv_nodegrapheditor_undo_node")
			net.WriteUInt(nodeID,14)
		net.SendToServer()
		//4096
		if(numNodes == 3250 || numNodes == 3680 || numNodes == 3994) then notification.AddLegacy("You are close to the node limit (" .. numNodes .. "/" .. MAX_NODES .. ").",0,8)
		elseif(numNodes == MAX_NODES) then notification.AddLegacy("You have reached the node limit.",0,8) end
	end
	net.Receive("cl_nodegrapheditor_undo_node",function(len)
		local nodeID = net.ReadUInt(14)
		local tool = GetTool()
		if(!tool) then return end
		tool:RemoveNode(nodeID)
	end)
	function TOOL:HasLink(src,dest) return nodegraph:HasLink(src,dest) end
	function TOOL:RemoveLinks(nodeID) nodegraph:RemoveLinks(nodeID) end
	function TOOL:RemoveLink(src,dest) nodegraph:RemoveLink(src,dest) end
	function TOOL:AddLink(src,dest,move) nodegraph:AddLink(src,dest,move) end
	function TOOL:RemoveNode(nodeID)
		self:RemoveEffect(nodeID)
		nodegraph:RemoveNode(nodeID)
	end
	local function ClientsideEffect(...)
		local tbEnts = ents.GetAll()
		util.Effect(...)
		return ents.GetAll()[#tbEnts +1] || NULL
	end
	function TOOL:IsNodeTypeVisible(type)
		return (type == NODE_TYPE_GROUND && cvDrawGround:GetBool()) || (type == NODE_TYPE_AIR && cvDrawAir:GetBool()) || (type == NODE_TYPE_CLIMB && cvDrawClimb:GetBool())
	end
	function TOOL:IsLineClear(a,b)
		local checkvis = cvVis:GetBool()
		if(!checkvis) then return true end
		local tr = util.TraceLine({start = a +Vector(0,0,3),endpos = b +Vector(0,0,3),mask = MASK_NPCWORLDSTATIC})
		return !tr.Hit
	end
	local angNode = Angle(0,0,0)
	local minNode = Vector(-30,-30,-30)
	local maxNode = Vector(30,30,30)
	function TOOL:GetTraceNode()
		local distMax = cvDist:GetInt()
		local pl = self:GetOwner()
		local pos = pl:GetShootPos()
		local dir = pl:GetAimVector()
		local origin = self:GetPreviewOrigin()
		local nodeClosest
		local distClosest = math.huge
		for _,node in pairs(nodes) do
			if(self:IsNodeTypeVisible(node.type)) then
				local hit,norm = util.IntersectRayWithOBB(pos,dir *32768,node.pos,angNode,minNode,maxNode)
				if(hit) then
					local d = node.pos:Distance(origin)
					if(d <= distMax) then
						local dPl = node.pos:Distance(pos)
						if(dPl < distClosest) then
							distClosest = dPl
							nodeClosest = _
						end
					end
				end
			end
		end
		if(nodeClosest) then
			local node = nodes[nodeClosest]
			return node,nodeClosest
		end
	end
	local distMinSelect = 40
	local colSelected = Color(255,0,0,255)
	function TOOL:SelectNode(nodeID)
		if(self.m_selected) then
			local nodeSelected = nodes[self.m_selected]
			local eSelected = self.m_tbEffects[self.m_selected]
			if(eSelected) then eSelected:SetColor(Color(255,255,255,255)) end
		end
		node = nodes[nodeID]
		self:ClearSelection()
		local e = self.m_tbEffects[nodeID]
		if(e) then
			e:SetColor(colSelected)
			e.m_rMin,e.m_rMax = e:GetRenderBounds()
			e:SetRenderBounds(Vector(-16384,-16384,-16384),Vector(16384,16384,16384)) // Make sure this is always rendered, so the links always show
			self.m_selected = nodeID
		end
	end
	function TOOL:ClearSelection()
		if(!self.m_selected) then return end
		local e = self.m_tbEffects[self.m_selected]
		if(e && e.m_rMin) then
			e:SetRenderBounds(e.m_rMin,e.m_rMax)
			e.m_rMin = nil
			e.m_rMax = nil
		end
		self.m_selected = nil
	end
	function TOOL:UpdateSelection(pos)
		if(!self.m_selected) then return end
		local nodeSelected = nodes[self.m_selected]
		if(!nodeSelected) then self:ClearSelection(); return end
		local eSelected = self.m_tbEffects[self.m_selected]
		if(self.m_bKeepSelection) then
			if(!self:GetOwner():KeyDown(IN_DUCK) && !self:GetOwner():KeyDown(IN_USE)) then
				self.m_bKeepSelection = nil
				if(eSelected) then eSelected.m_bKeepSelection = nil end
			else return end
		end
		local d = nodeSelected.pos:Distance(pos)
		if(d > distMinSelect) then
			if(eSelected) then eSelected:SetColor(Color(255,255,255,255)) end
			self:ClearSelection()
		end
	end
	function TOOL:SolidifySelection()
		if(!self.m_selected) then return end
		self.m_bKeepSelection = true
		local eSelected = self.m_tbEffects[self.m_selected]
		if(!eSelected) then return end
		eSelected.m_bKeepSelection = true
	end
	function TOOL:RemoveEffect(nodeID)
		if(!self.m_tbEffects[nodeID]) then return end
		if(self.m_selected == nodeID) then self:ClearSelection() end
		self.m_tbEffects[nodeID].m_bRemove = true
		self.m_tbEffects[nodeID] = nil
	end
	local mat = Material("trails/laser")
	local colDefault = Color(0,255,0,255)
	local colRemove = Color(255,0,0,255)
	local colNew = Color(0,255,255,255)
	local colNewBlocked = Color(255,0,255,255)
	local offset = Vector(0,0,3)
	local DrawLinks = function(self)
		local col = colDefault
		render.SetMaterial(mat)
		if(self.m_tbLinks) then
			for _,nodeLinked in ipairs(self.m_tbLinks) do
				render.DrawBeam(self:GetPos() +offset,nodeLinked.pos +offset,10,0,0,col)
			end
		end
		if(self.m_bPreview) then
			if(cvShowYaw:GetBool()) then
				local yaw = cvYaw:GetInt()
				local pos = self:GetPos() +Vector(0,0,30)
				colArrow.a = 255
				cam.Start3D(EyePos(),EyeAngles())
					local dir = Angle(0,yaw,0):Forward()
					render.SetMaterial(matArrow)
					cam.IgnoreZ(true)
					render.DrawBeam(pos,pos +dir *szArrow,6,1,0,colArrow)
					cam.IgnoreZ(false)
				cam.End3D()
			end
		end
		local node,nodeID = self:GetNode()
		if(!node) then return end
		local tool = GetTool()
		if(!tool) then return end
		local col = colDefault
		local nodeSelected
		if(tool.m_selected) then nodeSelected = nodes[tool.m_selected] end
		local nodeTrace
		if(tool.m_traceNode) then nodeTrace = nodes[tool.m_traceNode] end
		for _,link in pairs(node.link) do
			local col = colDefault
			if(tool.m_bKeepSelection) then
				if((link.src == nodeSelected || link.dest == nodeSelected) && (nodeSelected == nodeTrace || nodeTrace == link.src || nodeTrace == link.dest)) then
					if(!nodeTrace || link.src == nodeTrace || link.dest == nodeTrace) then
						col = colRemove
					end
				end
			end
			local dest = link.dest
			render.DrawBeam(node.pos +offset,dest.pos +offset,10,0,0,col)
		end
		if(node == nodeSelected) then
			if(nodeTrace) then
				if(!tool:HasLink(nodeID,tool.m_traceNode)) then
					local col
					if(tool:IsLineClear(node.pos,nodeTrace.pos)) then col = colNew
					else col = colNewBlocked end
					render.DrawBeam(node.pos +offset,nodeTrace.pos +offset,10,0,0,col)
				end
			end
			if(cvShowYaw:GetBool()) then
				local yaw = node.yaw
				local pos = node.pos +Vector(0,0,15)
				cam.Start3D(EyePos(),EyeAngles())
					local dir = Angle(0,yaw,0):Forward()
					render.SetMaterial(matArrow)
					cam.IgnoreZ(true)
					render.DrawBeam(pos,pos +dir *szArrow,6,1,0,colArrowSelected)
					cam.IgnoreZ(false)
				cam.End3D()
			end
		end
	end
	function TOOL:CreateEffect(nodeID)
		if(IsValid(self.m_tbEffects[nodeID])) then return end
		local node = nodes[nodeID]
		local edata = EffectData()
		edata:SetMagnitude(node.type)
		local e = ClientsideEffect("effect_node",edata)
		e:SetPos(node.pos)
		e:SetNode(node,nodeID)
		e.DrawLinks = DrawLinks
		self.m_tbEffects[nodeID] = e
	end
	local function SnapToGrid(vec,szGrid)
		if(szGrid == 0) then return vec end
		local szHalf = szGrid *0.5
		local x,y,z = vec.x,vec.y,vec.z
		if(x %szGrid < szHalf) then x = x -(x %szGrid)
		else x = x +(szGrid -(x %szGrid)) end
		if(y %szGrid < szHalf) then y = y -(y %szGrid)
		else y = y +(szGrid -(y %szGrid)) end
		if(z %szGrid < szHalf) then z = z -(z %szGrid)
		else z = z +(szGrid -(z %szGrid)) end
		return Vector(x,y,z)
	end
	function TOOL:GetPreviewOrigin()
		local pl = self:GetOwner()
		local pos = pl:GetShootPos()
		local snap = cvSnap:GetInt()
		local tr = util.TraceLine(util.GetPlayerTrace(pl))
		local createType = cvCreateType:GetInt()
		if(createType != NODE_TYPE_AIR) then
			local pos = SnapToGrid(tr.HitPos +Vector(cvX:GetInt(),cvY:GetInt(),cvZ:GetInt()),snap)
			if(createType == NODE_TYPE_CLIMB) then
				local dir
				if(tr.Normal.x > tr.Normal.y) then dir = Vector(tr.Normal.x /math.abs(tr.Normal.x) *-1,0,0)
				else dir = Vector(0,tr.Normal.y /math.abs(tr.Normal.y) *-1,0) end
				pos = pos +Vector(0,0,8)
			end
			return pos
		end
		local dMax = cvDistAirNode:GetInt()
		local d = pos:Distance(tr.HitPos)
		if(d > dMax) then return SnapToGrid(pos +tr.Normal *dMax,snap) end
		return SnapToGrid(tr.HitPos +Vector(cvX:GetInt(),cvY:GetInt(),cvZ:GetInt()),snap)
	end
	function TOOL:ClearEffects()
		if(self.m_tbEffects) then
			for _,e in pairs(self.m_tbEffects) do
				if(e:IsValid()) then e.m_bRemove = true end
			end
			self.m_tbEffects = nil
		end
		if(IsValid(self.m_ePreview)) then
			self.m_ePreview.m_bRemove = true
			self.m_ePreview = nil
		end
	end
	function TOOL:Holster()
		self:ClearEffects()
	end
	function TOOL:IsNodeVisible(nodeID)
		local node = nodes[nodeID]
		if(!node) then return false end
		local pl = self:GetOwner()
		local pos = pl:GetShootPos()
		local dir = pl:GetAimVector()
		local hit,norm = util.IntersectRayWithOBB(pos,dir *32768,node.pos,angNode,minNode,maxNode)
		if(!hit) then return false end
		local tr = util.TraceLine({
			start = pos,
			endpos = node.pos +Vector(0,0,3),
			filter = pl,
			mask = MASK_SOLID
		})
		return tr.Fraction > 0.9
	end
	local mat = Material("trails/laser")
	function TOOL:Think()
		if(!self.m_tbEffects) then
			self.m_tbEffects = {}
			local edata = EffectData()
			edata:SetMagnitude(NODE_TYPE_GROUND)
			self.m_ePreview = ClientsideEffect("effect_node",edata)
			self.m_ePreview.m_bPreview = true
			self.m_ePreview.DrawLinks = DrawLinks
			if(!nodes) then
				nodegraph = _R.Nodegraph.Read()
				nodes = nodegraph:GetNodes()
				links = nodegraph:GetLinks()
				lookup = nodegraph:GetLookupTable()
			end
			ShowMapWarning()
		end
		local distMax = cvDist:GetInt()
		local pl = self:GetOwner()
		local pos = pl:GetShootPos()
		local origin = self:GetPreviewOrigin()
		local createType = cvCreateType:GetInt()
		if(self.m_ePreview:GetType() != createType) then self.m_ePreview:SetType(createType) end
		self.m_ePreview:SetPos(origin)
		self.m_ePreview:SetNoDraw((!cvDrawPreview:GetBool() || self.m_selected) && true || false)
		self.m_ePreview:ClearLinks()
		self:UpdateSelection(origin)
		local dir = pl:GetAimVector()
		local distMinLink = cvDistLink:GetInt()
		self.m_traceNode = nil
		local nodesInRay = {}
		for _,node in pairs(nodes) do
			if(!self:IsNodeTypeVisible(node.type)) then self:RemoveEffect(_)
			else
				local hit,norm = util.IntersectRayWithOBB(pos,dir *32768,node.pos,angNode,minNode,maxNode)
				if(hit) then
					local d = node.pos:Distance(origin)
					hit = d <= distMax
				end
				if(hit) then self.m_traceNode = _ end
				if(hit && !self.m_bKeepSelection && self.m_tbEffects[_] && self:IsNodeVisible(_)) then table.insert(nodesInRay,_)
				else
					local d = node.pos:Distance(origin)
					if(d <= distMax) then self:CreateEffect(_)
					elseif(self.m_selected != _) then self:RemoveEffect(_) end
					if(d <= distMinLink) then
						if((node.type != NODE_TYPE_AIR && createType != NODE_TYPE_AIR) || node.type == createType) then
							if(self:IsLineClear(origin,node.pos)) then self.m_ePreview:AddLink(node) end
						end
					end
				end
			end
		end
		local nodeClosest
		local distClosest = math.huge
		for _,nodeID in ipairs(nodesInRay) do
			local node = nodes[nodeID]
			local d = node.pos:Distance(pos)
			if(d < distClosest) then
				distClosest = d
				nodeClosest = nodeID
			end
		end
		if(nodeClosest) then self:SelectNode(nodeClosest) end
	end
	function TOOL.BuildCPanel(pnl)
		pnl:AddControl("Header",{Text = "Nodegraph Editor 2",Description = [[Use left click to place a node at your crosshair, or remove an existing node.
		Use right click to place a node at your current position.
		To edit links between nodes, hold either use or duck and then click on a node.
		You are in the link edit mode until you release the use / duck key. In this mode you can:
		- Click on the same node again to remove all links
		- Click on a linked node to remove the link between the two
		- Click on a unlinked node to create a new link
		]]})
		local selected = cvCreateType:GetInt()
		local lbl = vgui.Create("DLabel",pnl)
		lbl:SetColor(Color(0,0,0,255))
		lbl:SetText("Node Type:")
		local pCBox = vgui.Create("DComboBox",pnl)
		pCBox:AddChoice("Ground Node",NODE_TYPE_GROUND,selected == NODE_TYPE_GROUND)
		pCBox:AddChoice("Air Node",NODE_TYPE_AIR,selected == NODE_TYPE_AIR)
		pCBox:AddChoice("Climb Node",NODE_TYPE_CLIMB,selected == NODE_TYPE_CLIMB)
		pCBox.OnSelect = function(pCBox,idx,val,data) RunConsoleCommand("cl_nodegraph_tool_node_type",data) end
		pCBox:SetWide(180)
		pnl:AddItem(lbl,pCBox)
		pnl:AddControl("CheckBox",{Label = "Show Node Preview",Command = "cl_nodegraph_tool_draw_preview"})
		
		local values = {0,1,2,4,8,16,32,64,128,256,512}
		local pSl = NumSlider(pnl,"Snap to grid:",nil,1,#values,0)
		local snap = cvSnap:GetInt()
		pSl.Wang:SetText(snap)
		local i
		for _,val in ipairs(values) do if(val == snap) then i = _; break end end
		if(i) then pSl.Slider:SetSlideX((i -1) /(#values -1)) end
		pSl.TranslateSliderValues = function(...)
			local x,y = select(2,...)
			local num = tonumber(x *(#values -1) +1) || 0
			num = math.Round(num)
			local val = math.Clamp(num,1,#values)
			pSl.Wang:SetText(values[val])
			RunConsoleCommand("cl_nodegraph_tool_snap",values[val])
			return ((num -1) /(#values -1)),y
		end
		
		pnl:AddControl("Slider",{type = "int",min = 0,max = 4000,label = "Draw Distance",Command = "cl_nodegraph_tool_draw_distance"})
		pnl:AddControl("Slider",{type = "int",min = 0,max = 1000,label = "Air Node Distance",Command = "cl_nodegraph_tool_airnode_distance"})
		pnl:AddControl("Slider",{type = "int",min = 0,max = 1500,label = "Max Link Distance",Command = "cl_nodegraph_tool_max_link_distance"})
		pnl:AddControl("Slider",{type = "int",min = 0,max = 360,label = "Forward Direction",Command = "cl_nodegraph_tool_yaw"})
		pnl:AddControl("Slider",{type = "int",min = -500,max = 500,label = "X (Left/Right)",Command = "cl_nodegraph_tool_x"})
		pnl:AddControl("Slider",{type = "int",min = -500,max = 500,label = "Y (Forward/Backward)",Command = "cl_nodegraph_tool_y"})
		pnl:AddControl("Slider",{type = "int",min = -500,max = 500,label = "Z (Height)",Command = "cl_nodegraph_tool_z"})
		pnl:AddControl("CheckBox",{Label = "Drop To Floor",Command = "cl_nodegraph_tool_droptofloor"})
		pnl:AddControl("CheckBox",{Label = "Draw Forward Direction Arrow",Command = "cl_nodegraph_tool_nodes_show_yaw"})
		pnl:AddControl("CheckBox",{Label = "Draw Ground Nodes",Command = "cl_nodegraph_tool_nodes_draw_ground"})
		pnl:AddControl("CheckBox",{Label = "Draw Air Nodes",Command = "cl_nodegraph_tool_nodes_draw_air"})
		pnl:AddControl("CheckBox",{Label = "Draw Climb Nodes",Command = "cl_nodegraph_tool_nodes_draw_climb"})
		pnl:AddControl("CheckBox",{Label = "Check Link Visibility",Command = "cl_nodegraph_tool_check_visibility"})
		
		local pSave = vgui.Create("DButton",pnl)
		pSave:SetText("Save Nodegraph")
		pSave.DoClick = function(pSave)
			nodegraph:Save()
			notification.AddLegacy("Nodegraph has been saved as 'data/nodegraph/" .. game.GetMap() .. ".txt' with a total of " .. table.Count(nodes) .. "/4096" .. " nodes.",0,8)
			ShowFirstTimeNotification()
			local tool = GetTool()
			if(tool) then tool:ClearEffects() end // Reload the whole thing
		end
		pSave:SetWide(110)
		pnl:AddItem(pSave)

		local pRestore = vgui.Create("DButton",pnl)
		pRestore:SetText("Restore Nodegraph")
		pRestore.DoClick = function(pReload)
			local tool = GetTool()
			if(tool) then tool:ClearEffects() end
			nodegraph = _R.Nodegraph.Read()
			nodes = nodegraph:GetNodes()
			links = nodegraph:GetLinks()
			lookup = nodegraph:GetLookupTable()
			notification.AddLegacy("Nodegraph has been restored.",0,8)
		end
		pRestore:SetWide(110)
		pnl:AddItem(pRestore)
	end
else
	function TOOL:LeftClick(tr)
		if(game.SinglePlayer()) then self:CallOnClient(0,tr) end
		return true
	end
	function TOOL:RightClick(tr)
		if(game.SinglePlayer()) then self:CallOnClient(1,tr) end
		return false
	end
	function TOOL:Holster()
		if(game.SinglePlayer()) then self:CallOnClient(2,tr) end
		return
	end
	util.AddNetworkString("sv_nodegrapheditor_undo_node")
	util.AddNetworkString("cl_nodegrapheditor_undo_node")
	net.Receive("sv_nodegrapheditor_undo_node",function(len,pl)
		local nodeID = net.ReadUInt(14)
		undo.Create("Node")
			undo.AddFunction(function()
				net.Start("cl_nodegrapheditor_undo_node")
					net.WriteUInt(nodeID,14)
				net.Send(pl)
			end)
			undo.SetPlayer(pl)
		undo.Finish()
	end)
end