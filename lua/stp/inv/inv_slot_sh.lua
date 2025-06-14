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

    if SERVER then
        function SLOT:PutItem(item, pos)
            self._item = item
        end

        function SLOT:TakeItem(item)
            assert(self._item == item)

            self._item = nil
        end
    end

    function SLOT:CanPut(pos, size)

    end

    function SLOT:CanPutIfMovedFrom(new_pos, size, old_pos)

    end

    function SLOT:FitPosition(pos_hint, size)

    end

    function SLOT:FitPositionIfMovedFrom(new_pos_hint, size, old_pos)

    end

sinv.Slot = sobj.Register(SLOT)