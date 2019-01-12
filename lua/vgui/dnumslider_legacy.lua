--[[   _                                
    ( )                               
   _| |   __   _ __   ___ ___     _ _ 
 /'_` | /'__`\( '__)/' _ ` _ `\ /'_` )
( (_| |(  ___/| |   | ( ) ( ) |( (_| |
`\__,_)`\____)(_)   (_) (_) (_)`\__,_) 

	DNumberWang

--]]

local PANEL = {}

--[[---------------------------------------------------------
	
-----------------------------------------------------------]]
function PANEL:Init()

	--local TopPanel = vgui.Create( "Panel", self )
	--TopPanel:Dock( TOP )
	--TopPanel:SetHeight( 16 )

	self.Wang = vgui.Create ( "DNumberWang", self )
	self.Wang.OnValueChanged = function( wang, val ) self:ValueChanged( val ) end
	self.Wang:Dock( RIGHT )
	self.Wang:SetWidth( 50 )
	self.Wang:SetDrawBackground( false )
	self.Wang:HideWang()
	self.Wang:SetContentAlignment( 6 )
	
	self.Slider = vgui.Create( "DSlider", self )
	self.Slider:SetLockY( 0.5 )
	self.Slider.TranslateValues = function( slider, x, y ) return self:TranslateSliderValues( x, y ) end
	self.Slider:SetTrapInside( true )
	self.Slider:Dock( FILL )
	self.Slider:SetHeight( 16 )
	
	Derma_Hook( self.Slider, "Paint", "Paint", "NumSlider" )
	
	self.Label = vgui.Create ( "DLabel", self )
	self.Label:Dock( LEFT )
	self.Label:SetSize( 100 )
	
	self:SetTall( 32 )

	self:SetMin( 0 )
	self:SetMax( 1 )
	self:SetDecimals( 2 )
	self:SetText( "" )
	self:SetValue( 0.5 )

end

--[[---------------------------------------------------------
	SetMinMax
-----------------------------------------------------------]]
function PANEL:SetMinMax( min, max )
	self.Wang:SetMinMax( min, max )
	self:UpdateNotches()
end

function PANEL:SetDark( b )
	self.Label:SetDark( b )
end

--[[---------------------------------------------------------
	GetMin
-----------------------------------------------------------]]
function PANEL:GetMin()
	return self.Wang:GetMin()
end

--[[---------------------------------------------------------
	GetMin
-----------------------------------------------------------]]
function PANEL:GetMax()
	return self.Wang:GetMax()
end

--[[---------------------------------------------------------
	GetRange
-----------------------------------------------------------]]
function PANEL:GetRange()
	return self:GetMax() - self:GetMin()
end

--[[---------------------------------------------------------
	SetMin
-----------------------------------------------------------]]
function PANEL:SetMin( min )

	if ( !min ) then min = 0  end

	self.Wang:SetMin( min )
	self:UpdateNotches()
end

--[[---------------------------------------------------------
	SetMax
-----------------------------------------------------------]]
function PANEL:SetMax( max )

	if ( !max ) then max = 0  end

	self.Wang:SetMax( max )
	self:UpdateNotches()
end

--[[---------------------------------------------------------
   Name: SetConVar
-----------------------------------------------------------]]
function PANEL:SetValue( val )
	self.Wang:SetValue( val )
end

--[[---------------------------------------------------------
   Name: GetValue
-----------------------------------------------------------]]
function PANEL:GetValue()
	return self.Wang:GetValue()
end

--[[---------------------------------------------------------
   Name: SetDecimals
-----------------------------------------------------------]]
function PANEL:SetDecimals( d )
	self.Wang:SetDecimals( d )
	self:UpdateNotches()
end

--[[---------------------------------------------------------
   Name: GetDecimals
-----------------------------------------------------------]]
function PANEL:GetDecimals()
	return self.Wang:GetDecimals()
end


--[[---------------------------------------------------------
   Name: SetConVar
-----------------------------------------------------------]]
function PANEL:SetConVar( cvar )
	self.Wang:SetConVar( cvar )
end

--[[---------------------------------------------------------
   Name: SetText
-----------------------------------------------------------]]
function PANEL:SetText( text )
	self.Label:SetText( text )
end

--[[---------------------------------------------------------
   Name: ValueChanged
-----------------------------------------------------------]]
function PANEL:ValueChanged( val )

	self.Slider:SetSlideX( self.Wang:GetFraction( val ) )
	self:OnValueChanged( val )

end

--[[---------------------------------------------------------
   Name: OnValueChanged
-----------------------------------------------------------]]
function PANEL:OnValueChanged( val )

	
	-- For override

end

--[[---------------------------------------------------------

-----------------------------------------------------------]]
function PANEL:TranslateSliderValues( x, y )

	self.Wang:SetFraction( x )
	
	return self.Wang:GetFraction(), y

end

--[[---------------------------------------------------------
   Name: GetTextArea
-----------------------------------------------------------]]
function PANEL:GetTextArea()

	return self.Wang:GetTextArea()

end

function PANEL:UpdateNotches()

	local range = self:GetRange()
	self.Slider:SetNotches( nil )
	
	if ( range < self:GetWide()/4 ) then
		return self.Slider:SetNotches( range )
	else
		self.Slider:SetNotches( self:GetWide()/4 )
	end

end

--[[---------------------------------------------------------
   Name: GenerateExample
-----------------------------------------------------------]]
function PANEL:GenerateExample( ClassName, PropertySheet, Width, Height )

	local ctrl = vgui.Create( ClassName )
		ctrl:SetWide( 200 )
		ctrl:SetMin( 1 )
		ctrl:SetMax( 10 )
		ctrl:SetText( "Example Slider!" )
		ctrl:SetDecimals( 0 )
	
	PropertySheet:AddSheet( ClassName, ctrl, nil, true, true )

end

derma.DefineControl( "DNumSliderLegacy", "Menu Option Line", table.Copy(PANEL), "Panel" )
