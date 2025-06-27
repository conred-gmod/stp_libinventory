local sinv = stp.inv
local sobj = stp.obj
local snet = stp.obj.net

local check_ty = stp.CheckType


local SLOT = sobj.BeginObject("stp.inv.Slot")
    sinv.InventoryBase(SLOT)

    function SLOT:GetItem()
        return self._item
    end

    function SLOT:GetItems()
        return {self._item}
    end

    function SLOT:PutItem(item, pos)
        self._item = item
    end

    function SLOT:TakeItem(item)
        assert(self._item == item)

        self._item = nil
    end

    function SLOT:MoveItem(item, new_pos)
        assert(self._item == item)
        -- Do nothing.
    end


    function SLOT:_CanFit(dir, item_size)
        local h, w = sinv.GetItemExtents(dir, item_size)

        return h <= self:GetHeight() and w <= self:GetWidth()
    end

    function SLOT:CanPut(pos, item_size, item)
        -- If item was already placed into the slot, it definetely fits
        if item == self._item then return true end

        return self:_CanFit(pos.Dir, item_size)
    end

    local POS_RIGHT = { X = 0, Y = 0, Dir = sinv.ITEM_DIR.RIGHT}
    local POS_DOWN = { X = 0, Y = 0, Dir = sinv.ITEM_DIR.DOWN}

    function SLOT:FitPosition(pos_hint, item_size, _)
        if pos_hint and self:_CanFit(pos_hint.Dir, item_size) then
            return { X = 0, Y = 0, Dir = pos_hint.Dir}
        end

        if self:_CanFit(POS_RIGHT.Dir, item_size) then
            return POS_RIGHT
        end

        if self:_CanFit(POS_DOWN.Dir, item_size) then
            return POS_DOWN
        end
    end

    if SERVER then
        function SLOT:NetTransmitInit() 
        end
    else
        function SLOT:NetReceiveInit()
        end
    end
sinv.Slot = sobj.Register(SLOT)