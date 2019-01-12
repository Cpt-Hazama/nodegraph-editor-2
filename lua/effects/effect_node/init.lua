function EFFECT:Init(data)
	local type = data:GetMagnitude() || 2
	self:SetType(type)
end

local nodeTypes = {
	[2] = "models/editor/ground_node.mdl",
	[3] = "models/editor/air_node.mdl",
	[4] = "models/editor/climb_node.mdl"
}

function EFFECT:SetType(type)
	self.m_type = type
	self:SetModel(nodeTypes[type] || nodeTypes[2])
end

function EFFECT:GetType() return self.m_type end

function EFFECT:SetNode(node,nodeID) self.m_node = node; self.m_nodeID = nodeID end

function EFFECT:GetNode() return self.m_node,self.m_nodeID end

function EFFECT:OnRemove()
end

function EFFECT:Think()
	local node = self:GetNode()
	if(node) then self:SetPos(node.pos) end
	return !self.m_bRemove
end

function EFFECT:Render()
	if(self.DrawLinks) then self:DrawLinks() end
	self:DrawModel()
end

function EFFECT:ClearLinks() self.m_tbLinks = {} end

function EFFECT:AddLink(node) table.insert(self.m_tbLinks,node) end
