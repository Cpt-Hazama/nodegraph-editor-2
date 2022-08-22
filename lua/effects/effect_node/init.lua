local cvColEnable = CreateClientConVar("cl_nodegraph_tool_nodes_col_enable",0,true)
local cvColR = CreateClientConVar("cl_nodegraph_tool_nodes_col_r",255,true)
local cvColG = CreateClientConVar("cl_nodegraph_tool_nodes_col_g",255,true)
local cvColB = CreateClientConVar("cl_nodegraph_tool_nodes_col_b",255,true)

function EFFECT:Init(data)
	local type = data:GetMagnitude() || 2
	self:SetType(type)

	self.CurrentSetting = -1
end

local nodeTypes = {
	[2] = "models/editor/ground_node.mdl",
	[3] = "models/editor/air_node.mdl",
	[4] = "models/editor/climb_node.mdl"
}

local nodeMats = {
	[2] = "editor/ground_node",
	[3] = "editor/air_node",
	[4] = "editor/climb_node"
}

function EFFECT:SetType(type)
	self.m_type = type
	self:SetModel(nodeTypes[type] || nodeTypes[2])
end

function EFFECT:GetType() return self.m_type end

function EFFECT:SetNode(node,nodeID) self.m_node = node; self.m_nodeID = nodeID end

function EFFECT:GetNode() return self.m_node,self.m_nodeID end

function EFFECT:SetDesiredColor(col)
	if col.r == 255 && col.g == 255 && col.b == 255 then
		if cvColEnable:GetBool() then
			self.DesiredColor = Color(cvColR:GetInt(),cvColG:GetInt(),cvColB:GetInt())
		else
			self.DesiredColor = Color(255,255,255)
		end
		return
	end
	if cvColEnable:GetBool() then
		self.DesiredColor = Color(math.abs(cvColR:GetInt() -col.r),math.abs(cvColG:GetInt() -col.g),math.abs(cvColB:GetInt() -col.b))
	else
		self.DesiredColor = col
	end
end

function EFFECT:OnRemove() end

function EFFECT:Think()
	local node = self:GetNode()
	if cvColEnable:GetBool() then
		self:SetColor(self.DesiredColor or Color(cvColR:GetInt(),cvColG:GetInt(),cvColB:GetInt()))
		if self.CurrentSetting != 1 then
			self:SetMaterial(nodeMats[self:GetType()] .. "_col")
			self.CurrentSetting = 1
		end
	else
		if self.CurrentSetting != 0 then
			self:SetMaterial(nodeMats[self:GetType()])
			self.CurrentSetting = 0
		end
		self:SetColor(self.DesiredColor or Color(255,255,255))
	end
	if(node) then self:SetPos(node.pos) end
	return !self.m_bRemove
end

function EFFECT:Render()
	if(self.DrawLinks) then
		self:DrawLinks()
	end

	self:DrawModel()
end

function EFFECT:ClearLinks() self.m_tbLinks = {} end

function EFFECT:AddLink(node) table.insert(self.m_tbLinks,node) end
