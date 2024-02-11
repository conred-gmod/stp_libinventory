local libinv = stp.inv
local libinvsch = stp.inv.schema
local libo = stp.obj
local libn = stp.obj.net

local check_ty = stp.CheckType

libinv.MAX_INV_SIZE = 256
libinv.INV_SIZE_BITS = 8

local ITEM_DIR_BITS = 2
libinv.ITEM_DIR = {
    RIGHT = 0,
    DOWN = 1,
    LEFT = 2,
    UP = 3
}

libinv.DEFAULT_INV_POS = { X = 0, Y = 0, Dir = libinv.ITEM_DIR.RIGHT }

libinvsch.ItemInvSize = {
    transmit = function(data)
        net.WriteUInt(data.Height - 1, libinv.INV_SIZE_BITS)
        net.WriteUInt(data.Width - 1, libinv.INV_SIZE_BITS)
    end,
    receive = function()
        local h = net.ReadUInt(libinv.INV_SIZE_BITS) + 1
        local w = net.ReadUInt(libinv.INV_SIZE_BITS) + 1

        return { Height = h, Width = w }
    end
}

libinvsch.ItemInvPos = {
    transmit = function(data)
        net.WriteUInt(data.X, libinv.INV_SIZE_BITS)
        net.WriteUInt(data.Y, libinv.INV_SIZE_BITS)
        net.WriteUInt(data.Dir, ITEM_DIR_BITS)
    end,
    receive = function()
        local x = net.ReadUInt(libinv.INV_SIZE_BITS)
        local y = net.ReadUInt(libinv.INV_SIZE_BITS)
        local dir = net.ReadUInt(ITEM_DIR_BITS)

        return { X = x, Y = y, Dir = dir }
    end
}


-- Inventory metatable
local INV = libo.BeginTrait("stp.inv.Inventory")
libo.ApplyMany(INV, 
    libn.EasyComposite
)

libo.MarkAbstract(INV, "GetItems", "function")

libo.MarkAbstract(INV, "CanPut", "function")
libo.MarkAbstract(INV, "CanPutIfMovedFrom", "function")
libo.MarkAbstract(INV, "FitPosition", "function")
libo.MarkAbstract(INV, "FitPositionIfMovedFrom", "function")

libo.MarkAbstract(INV, "TakeItem", "function")
libo.MarkAbstract(INV, "PutItem", "function")

libo.Register(INV)
libinv.Inventory = INV

-- Item metatable
local ITEM = libo.BeginTrait("stp.inv.Item")
libo.ApplyMany(ITEM, 
    libn.EasyComposite
)

libo.MarkAbstract(ITEM, "GetName", "function")
libo.MarkAbstract(ITEM, "GetDesc", "function")
libo.MarkAbstract(ITEM, "GetSize", "function")

libo.ConstructNestedType(ITEM, "Inventory", libn.MakeEasyVar(libn.schema.StpNetworkable, 
    "GetInventory", SERVER and "_SetInventory", nil, { DefaultIsNil = true }
))

libo.ConstructNestedType(ITEM, "InvPos", libn.MakeEasyVar(libinvsch.ItemInvPos, 
    "_GetInvPos", SERVER and "_SetInvPos", libinv.DEFAULT_INV_POS
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


libo.Register(ITEM)
libinv.Item = ITEM