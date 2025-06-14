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
    end)

    function INV:GetItems()
        return self._items
    end

    local function ItemPosToGridIdx(x, y, height)
        return x * height + y
    end

    if SERVER then -- TODO: reconstruct _itemsGrid clientside
        function INV:PutItem(item, pos)
            table.insert(self._items, item)

            local h, w = sinv.GetItemExtents(item:GetSize(), pos.Dir)
            local inv_h = self:GetHeight()

            for x = pos.X, pos.X + w - 1 do
                local i_start = ItemPosToGridIdx(pos.X, y, inv_h)
                for i = i_start, i_start + h - 1 do
                    self._items[i] = item
                end
            end
        end

        function INV:TakeItem(item)
            table.RemoveFastByValue(self._items, item)

            local pos = item:GetInventoryPos()
            local h, w = sinv.GetItemExtents(item:GetSize(), pos.Dir)
            local inv_h = self:GetHeight()

            for x = pos.X, pos.X + w - 1 do
                local i_start = ItemPosToGridIdx(pos.X, y, inv_h)
                for i = i_start, i_start + h - 1 do
                    self._items[i] = nil
                end
            end
        end
    end

    function INV:CanPutIfMoved(pos, size, item)
        local h, w = sinv.GetItemExtents(size, pos.Dir)

        if  pos.Y + h > self:GetHeight() or 
            pos.X + w > self:GetWidth() 
        then 
            return false
        end
        
        for x = pos.X, pos.X + w - 1 do
            local i_start = ItemPosToGridIdx(pos.X, y, inv_h)
            for i = i_start, i_start + h - 1 do
                local cur_item = self._items[i]
                if cur_item ~= nil and cur_item ~= item then
                    return false
                end
            end
        end

        return true
    end

    function INV:CanPut(pos, size)
        return self:CanPutIfMoved(pos, size, nil)
    end


    -- TODO: currently this function has complexity of O(h^2*w^2), which is terrible.
    -- Optimize it.
    function INV:FitPositionIfMoved(pos_hint, size, item)
        local inv_h, inv_w = self:GetHeight(), self:GetWidth()
        local it_h, it_w = size.Height, size.Width

        if math.min(it_h, it_w) > math.min(inv_h, inv_w) then
            return nil
        end


        if pos_hint ~= nil then
            MsgN("INV:FitPositionIfMoved: TODO: position hint unsuppoerted")
        end

        -- if pos_hint == nil then
        do
            for x = 0, inv_w - it_w do
                for y = 0, inv_h - it_h do

                    local pos = {X = x, Y = Y, Dir = sinv.ITEM_DIR.RIGHT}
                    if self:CanPutIfMoved(pos, size, item) then -- Try putting item horizontally
                        return pos
                    end

                    pos.Dir = sinv.ITEM_DIR.DOWN -- Try putting it vertically
                    if self:CanPutIfMoved(pos, size, item) then -- Try putting item horizontally
                        return pos
                    end

                end
            end
        end
        -- else ??? end
    end

    function INV:FitPosition(pos_hint, size)
        return self:FitPositionIfMoved(pos_hint, size, nil)
    end

sinv.Inventory = sobj.Register(INV)