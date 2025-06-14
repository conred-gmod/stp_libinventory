local sinv = stp.inv
local sinvsch = stp.inv.schema
local sobj = stp.obj
local snet = stp.obj.net

local check_ty = stp.CheckType

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