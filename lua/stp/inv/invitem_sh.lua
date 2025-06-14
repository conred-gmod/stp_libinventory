local sinv = stp.inv
local sinvsch = stp.inv.schema
local sobj = stp.obj
local snet = stp.obj.net

local check_ty = stp.CheckType

sinv.MAX_INV_SIZE = 256
sinv.INV_SIZE_BITS = 8

local ITEM_DIR_BITS = 2
sinv.ITEM_DIR = {
    RIGHT = 0,
    DOWN = 1,
    LEFT = 2,
    UP = 3
}

sinv.DEFAULT_INV_POS = { X = 0, Y = 0, Dir = sinv.ITEM_DIR.RIGHT }

sinvsch.ItemInvSize = {
    transmit = function(data)
        net.WriteUInt(data.Height - 1, sinv.INV_SIZE_BITS)
        net.WriteUInt(data.Width - 1, sinv.INV_SIZE_BITS)
    end,
    receive = function()
        local h = net.ReadUInt(sinv.INV_SIZE_BITS) + 1
        local w = net.ReadUInt(sinv.INV_SIZE_BITS) + 1

        return { Height = h, Width = w }
    end
}

sinvsch.ItemInvPos = {
    transmit = function(data)
        net.WriteUInt(data.X, sinv.INV_SIZE_BITS)
        net.WriteUInt(data.Y, sinv.INV_SIZE_BITS)
        net.WriteUInt(data.Dir, ITEM_DIR_BITS)
    end,
    receive = function()
        local x = net.ReadUInt(sinv.INV_SIZE_BITS)
        local y = net.ReadUInt(sinv.INV_SIZE_BITS)
        local dir = net.ReadUInt(ITEM_DIR_BITS)

        return { X = x, Y = y, Dir = dir }
    end
}

-- -> height: uint, width: uint
function sinv.GetItemExtents(size, dir)
    if dir == sinv.ITEM_DIR.RIGHT or dir == sinv.ITEM_DIR.LEFT then
        return size.Height, size.Width
    else
        return size.Width, size.Height
    end
end

-- Inventory metatable
local INV = sobj.BeginTrait("stp.inv.Inventory")
    sobj.ApplyMany(INV, 
        snet.EasyComposite
    )

    sobj.MarkAbstract(INV, "GetItems", "function")

    sobj.MarkAbstract(INV, "CanPut", "function")
    sobj.MarkAbstract(INV, "CanPutIfMovedFrom", "function")
    sobj.MarkAbstract(INV, "FitPosition", "function")
    sobj.MarkAbstract(INV, "FitPositionIfMovedFrom", "function")

    sobj.MarkAbstract(INV, "TakeItem", "function")
    sobj.MarkAbstract(INV, "PutItem", "function")

    -- TODO: Height/GetHeight
    -- TODO: Width/GetWidth


sinv.Inventory = sobj.Register(INV)

-- Item metatable
local ITEM = sobj.BeginTrait("stp.inv.Item")
    sobj.ApplyMany(ITEM, 
        snet.EasyComposite
    )

    sobj.MarkAbstract(ITEM, "GetName", "function")
    sobj.MarkAbstract(ITEM, "GetDesc", "function")
    sobj.MarkAbstract(ITEM, "GetSize", "function")

    sobj.ConstructNestedType(ITEM, "Inventory", snet.MakeEasyVar(snet.schema.StpNetworkable, 
        "GetInventory", SERVER and "_SetInventory", nil, { DefaultIsNil = true }
    ))

    sobj.ConstructNestedType(ITEM, "InvPos", snet.MakeEasyVar(sinvsch.ItemInvPos, 
        "_GetInvPos", SERVER and "_SetInvPos", sinv.DEFAULT_INV_POS
    ))

    function ITEM:GetInvPos()
        if self:GetInventory() == nil then return nil end

        return self:_GetInvPos()
    end

    function ITEM:GetWorldEntity()
        return self._worldEntity
    end

    function ITEM:_SetWorldEntity(ent)
        self._worldEntity = ent
    end


    if SERVER then
        local function World_Move(ent, pos, ang, item)

        end

        local function World_PreCreate(pos, ang, item)
            
        end

        local function World_Create(ent)

        end


        function ITEM:TryMoveToWorld(pos, ang)
            check_ty(pos, "pos", "Vector")
            check_ty(ang, "ang", {"Angle", "nil"})

            if self._worldEntity ~= nil then
                local err = World_Move(self._worldEntity, pos, ang, self)
                if err then return nil, err end

                return self._worldEntity, nil
            end

            local ent, err = World_PreCreate(pos, ang, self)
            if err then return nil, err end

            local oldinv = self:GetInventory()
            if oldinv ~= nil then
                oldinv:TakeItem(self)
                self:_SetInventory(nil)
            end

            World_Create(ent)
            self._worldEntity = ent

            return ent, nil
        end

        function ITEM:_TryMoveFromWorld()
            local ent = self._worldEntity
            if not IsValid(ent) then return end

            ent:Remove()
            self._worldEntity = nil
        end

        function ITEM:_TryMoveToInventory_Generic(inv, pos, oldinv)
            self:_TryMoveFromWorld()

            
            if oldinv ~= inv then
                oldinv:TakeItem(self)
                self:_SetInventory(inv)
            end

            self:_SetInvPos(inv)
            inv:PutItem(self, pos)

            return nil
        end

        function ITEM:TryMoveToInventory(inv, pos)
            check_ty(inv, "inv", "table")
            check_ty(pos, "pos", "table")

            local oldinv = self:GetInventory()
            if oldinv == inv then
                if not inv:CanPutIfMovedFrom(pos, self:GetSize(), self:GetInvPos()) then
                    return "stp.inv.error.no_place"
                end
            else
                if not inv:CanPut(pos, self:GetSize()) then
                    return "stp.inv.error.no_place"
                end
            end


            self:_TryMoveToInventory_Generic(inv, pos, oldinv)
        end

        function ITEM:TryMoveToInventory_Fit(inv, pos_hint)
            check_ty(inv, "inv", "table")
            check_ty(pos, "pos", "table")

            local oldinv = self:GetInventory()

            local pos
            if oldinv == inv then
                pos = inv:FitPositionIfMovedFrom(pos_hint, self:GetSize(), self:GetInvPos())
            else
                pos = inv:FitPosition(pos_hint, self:GetSize())
            end

            if pos == nil then
                return "stp.inv.error.no_place"
            end

            self:_TryMoveToInventory_Generic(inv, pos, oldinv)
        end
    end

sinv.Item = sobj.Register(ITEM)


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