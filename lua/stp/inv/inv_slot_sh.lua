local sinv = stp.inv
local sinvsch = stp.inv.schema
local sobj = stp.obj
local snet = stp.obj.net

local check_ty = stp.CheckType


local INVS = sobj.BeginObject("stp.inv.SingleItemInv")
    INV(INVS)

    function INVS:GetItem()
        return self._item
    end

    function INVS:GetItems()
        return {self._item}
    end

    if SERVER then
        function INVS:PutItem(item, pos)
            self._item = item
        end

        function INVS:TakeItem(item)
            assert(self._item == item)

            self._item = nil
        end
    end

    function INVS:CanPut(pos, size)

    end

    function INVS:CanPutIfMovedFrom(new_pos, size, old_pos)

    end

    function INVS:FitPosition(pos_hint, size)

    end

    function INVS:FitPositionIfMovedFrom(new_pos_hint, size, old_pos)

    end

sinv.SingleItemInv = sobj.Register(INVS)