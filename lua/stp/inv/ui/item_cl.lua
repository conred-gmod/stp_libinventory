local check_ty = stp.CheckType

local PANEL = {}

function PANEL:Init()
    self:Droppable( "stp.inv" )
    self:SetDoubleClickingEnabled( false )
    self:SetText( "" )

    self._itemExtents = { Width = 1, Height = 1}
    self._gridScale = 64
    self:_InvalidateSize()

    local icon = self:Add("DPanel")
    icon:SetMouseInputEnabled(false)
    self._icon = icon
end

function PANEL:SetItem(item)
    check_ty(item, "item", "table")

    self._item = item
    self._itemExtents = item:GetSize()
    self:_InvalidateSize()
    self:_InvalidateModel()
end

function PANEL:GetItem()
    return self._item
end

function PANEL:SetGridScale(scale)
    self._gridScale = scale
    self:_InvalidateSize()
end

function PANEL:_InvalidateSize()
    local w = self._itemExtents.Width * self._gridScale
    local h = self._itemExtents.Height * self._gridScale

    self:SetSize(w, h)
end


function PANEL:PerformLayout()
    if ( self:IsDown() and not self.Dragging ) then
        self._icon:StretchToParent( 6, 6, 6, 6 )
    else
        self._icon:StretchToParent( 0, 0, 0, 0 )
    end
end

function PANEL:_InvalidateModel()
    
end


derma.DefineControl("stp.inv.UiItem", "Item as seen in inventory", PANEL, "DButton")