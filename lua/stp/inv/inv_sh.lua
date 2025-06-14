local sinv = stp.inv
local sinvsch = stp.inv.schema
local sobj = stp.obj
local snet = stp.obj.net

local check_ty = stp.CheckType

local INVM = sobj.BeginObject("stp.inv.MultiItemInv")
    INV(INVM)

    sobj.HookAdd(INVM, "Init", INVM.TypeName, function(self, args)
        self._items = {}
        
        self._itemGrid = {}
        for y = 1, self:GetHeight() do
            self._itemGrid[y] = {}
        end
    end)

    function INVM:GetItems()
        return self._items
    end

    if SERVER then
        function INVM:PutItem(item, pos)
            table.insert(self._items, item)

            local h, w = GetItemExtents(item:GetSize(), pos.Dir)

            for y = pos.Y, pos.Y + h - 1 do
                for x = pos.X, pos.X + w - 1 do
                    self._items[y][x] = item
                end
            end
        end

        function INVM:TakeItem(item)
            table.RemoveFastByValue(self._items, item)

            local pos = item:GetInventoryPos()
            local h, w = GetItemExtents(item:GetSize(), pos.Dir)

            for y = pos.Y, pos.Y + h - 1 do
                for x = pos.X, pos.X + w - 1 do
                    self._items[y][x] = nil
                end
            end
        end
    end

    function INVM:CanPut(pos, size)
        local h, w = GetItemExtents(size, pos.Dir)
        return pos.X < w and pos.Y < h
    end

    function INVM:CanPutIfMovedFrom(new_pos, size, old_pos)
        local h, w = GetItemExtents(size, pos.Dir)
        return pos.X + w - 1 < self:GetWidth() and pos.Y + h - 1 < self:GetHeight()
    end

    function INVM:FitPosition(pos_hint, size)
        --if 
    end

    function INVM:FitPositionIfMovedFrom(new_pos_hint, size, old_pos)

    end

sinv.MultiItemInv = sobj.Register(INVM)