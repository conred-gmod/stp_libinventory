local sinv = stp.inv
local sinvsch = stp.inv.schema
local sobj = stp.obj
local snet = stp.obj.net

local check_ty = stp.CheckType

local INV = sobj.BeginObject("stp.inv.Inventory")
    sinv.InventoryBase(INV)

    -- TODO: fullupdate request (?)

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

    local function PutItem_UpdateGrid(inv, item, pos)
        local h, w = sinv.GetItemExtents(item:GetSize(), pos.Dir)
        local inv_h = inv:GetHeight()
        local items = self._items

        for x = pos.X, pos.X + w - 1 do
            local i_start = ItemPosToGridIdx(pos.X, y, inv_h)
            for i = i_start, i_start + h - 1 do
                items[i] = item
            end
        end
    end

    function INV:PutItem(item, pos)
        table.insert(self._items, item)

        PutItem_UpdateGrid(self, item, pos)
    end

    function INV:TakeItem(item)
        table.RemoveFastByValue(self._items, item)

        local pos = item:GetInventoryPos()
        local h, w = sinv.GetItemExtents(item:GetSize(), pos.Dir)
        local inv_h = self:GetHeight()
        local items = self._items

        for x = pos.X, pos.X + w - 1 do
            local i_start = ItemPosToGridIdx(pos.X, y, inv_h)
            for i = i_start, i_start + h - 1 do
                items[i] = nil
            end
        end
    end

    function INV:MoveItem(item, pos)
        local items = self._items

        for i = 0, self:GetHeight() * self:GetWidth() - 1 do
            if items[i] == item then
                items[i] = nil
            end
        end

        PutItem_UpdateGrid(self, item, pos)
    end

    function INV:CanPut(pos, size, skip_item)
        local h, w = sinv.GetItemExtents(size, pos.Dir)

        if  pos.Y + h > self:GetHeight() or 
            pos.X + w > self:GetWidth() 
        then 
            return false
        end
        
        local items = self._items

        for x = pos.X, pos.X + w - 1 do
            local i_start = ItemPosToGridIdx(pos.X, y, inv_h)
            for i = i_start, i_start + h - 1 do
                local cur_item = items[i]
                if cur_item ~= nil and cur_item ~= skip_item then
                    return false
                end
            end
        end

        return true
    end

    -- TODO: currently this function has complexity of O(h^2*w^2), which is terrible.
    -- Optimize it.
    function INV:FitPosition(pos_hint, size, skip_item)
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
                    if self:CanPutIfMoved(pos, size, skip_item) then -- Try putting item horizontally
                        return pos
                    end

                    pos.Dir = sinv.ITEM_DIR.DOWN -- Try putting it vertically
                    if self:CanPutIfMoved(pos, size, skip_item) then -- Try putting item horizontally
                        return pos
                    end

                end
            end
        end
        -- else ??? end
    end
sinv.Inventory = sobj.Register(INV)