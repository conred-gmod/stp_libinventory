local check_ty = stp.CheckType

local PANEL = {}

function PANEL:Init()
    self:Receiver("stp.inv", self._DropAction)

    self._inventoryExtents = { Width = 1, Height = 1 }
    self._gridScale = 64
    self:_InvalidateSize()
end

function PANEL:Paint(w, h)
    draw.RoundedBox(0, 0, 0, w, h, color_white)
end


function PANEL:SetGridScale(scale)
    self._gridScale = scale
end

function PANEL:SetInventory(inv)
    check_ty(inv, "inv", "table")

    self._inventory = inv
    self._inventoryExtents.Width = inv:GetWidth()
    self._inventoryExtents.Height = inv:GetHeight()
    self:_InvalidateSize()

    for _, item in ipairs(inv:GetItems()) do
        local pnl = self:Add("stp.inv.UiItem")
        pnl:SetGridScale(self._gridScale)
        pnl:SetItem(item)
    end
end


function PANEL:_InvalidateSize()
    local w = self._inventoryExtents.Width * self._gridScale
    local h = self._inventoryExtents.Height * self._gridScale
    
    self:SetSize(w, h)
end

function PANEL:_DropAction(drops, doDrop, command, x, y)
    if doDrop then
        if #drops == 1 then
            local pnl = drops[1]
            local w, h = pnl:GetSize()

            local gridX = math.Round(math.max(x - w / 2, 0) / self._gridScale)
            local gridY = math.Round(math.max(y - h / 2, 0) / self._gridScale)

            local item = pnl:GetItem()

            -- if self._inventory:CanPut({ X = gridX, Y = gridY }, item:GetSize()) then
            do
                pnl:SetParent(self)
                pnl:SetPos(gridX * self._gridScale, gridY * self._gridScale)

                -- TODO: transfer or move item
            end  
        else
            -- Auto fit when moving multiple items (?)
        end
    else
        -- Do something with item panel preview during dragging
    end
end


derma.DefineControl("stp.inv.UiInvLayout", "Inventory items layout", PANEL, "DDragBase")