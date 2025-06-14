local sinv = stp.inv
local sinvsch = stp.inv.schema
local sobj = stp.obj
local snet = stp.obj.net

local check_ty = stp.CheckType

local INV = sobj.BeginObject("stp.inv.Inventory")
    sinv.InventoryBase(INV)

    sobj.HookAdd(INV, "Init", INV.TypeName, function(self, args)
        self._items = {}
        
        self._itemGrid = {}
        for y = 1, self:GetHeight() do
            self._itemGrid[y] = {}
        end
    end)

    function INV:GetItems()
        return self._items
    end

    if SERVER then
        function INV:PutItem(item, pos)
            table.insert(self._items, item)

            local h, w = GetItemExtents(item:GetSize(), pos.Dir)

            for y = pos.Y, pos.Y + h - 1 do
                for x = pos.X, pos.X + w - 1 do
                    self._items[y][x] = item
                end
            end
        end

        function INV:TakeItem(item)
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

    function INV:CanPut(pos, size)
        local h, w = GetItemExtents(size, pos.Dir)
        return pos.X < w and pos.Y < h
    end

    function INV:CanPutIfMovedFrom(new_pos, size, old_pos)
        local h, w = GetItemExtents(size, pos.Dir)
        return pos.X + w - 1 < self:GetWidth() and pos.Y + h - 1 < self:GetHeight()
    end

    function INV:FitPosition(pos_hint, size)
        --if 
    end

    function INV:FitPositionIfMovedFrom(new_pos_hint, size, old_pos)

    end

sinv.Inventory = sobj.Register(INV)