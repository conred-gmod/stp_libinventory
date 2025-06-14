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
        "GetInventory", SERVER and "_SetInventory", nil, { 
            DefaultIsNil = true,
            Callback = CLIENT and "_OnInventoryChanged"
        }
    ))

    sobj.ConstructNestedType(ITEM, "InvPos", snet.MakeEasyVar(sinvsch.ItemInvPos, 
        "_GetInvPos", SERVER and "_SetInvPos", sinv.DEFAULT_INV_POS, { 
            Callback = CLIENT and "_OnItemPosChanged"
        }
    ))

    function ITEM:GetInvPos()
        if self:GetInventory() == nil then return nil end

        return self:_GetInvPos()
    end


    ITEM.Entity_Class = "stp_item"

    function ITEM:Entity_Get()
        return self._worldEntity
    end

    sobj.HookDefine(ITEM, "Entity_Init")

    function ITEM:_Entity_Unlink(ent)
        self._worldEntity = nil
        ent:_SetItem(nil)
    end

    function ITEM:_Entity_Link(ent)
        if SERVER then ent:_SetItem(item) end
        item._worldEntity = ent
    end

    if SERVER then
        -- Move or teleport the item entity
        local function World_Move(ent, pos, ang, item)
            ent:SetPos(pos)
            ent:SetAngles(ang)
        end

        -- Create the item entity
        local function World_Create(pos, ang, item)
            local class = item.WorldEntityClass

            local ent = ents.Create(class)
            if not IsValid(ent) then 
                ErrorNoHaltWithStack("Can't create entity for item ",item,": failed creating entity '",class,"'")
                return nil, "stp.inv.error.internal"
            end

            item:_Entity_Link(ent)
            
            local err = World_Move(ent, pos, ang, item)
            if err then 
                ent:Remove()
                return nil, err
            end

            local oldinv = item:GetInventory()
            if oldinv ~= nil then
                oldinv:TakeItem(item)
                item:_SetInventory(item)
            end

            ent:Spawn()

            return ent, nil
        end


        function ITEM:TryMoveToWorld(pos, ang)
            check_ty(pos, "pos", "Vector")
            check_ty(ang, "ang", {"Angle", "nil"})

            if self._worldEntity ~= nil then
                local err = World_Move(self._worldEntity, pos, ang, self)
                if err then return nil, err end

                return self._worldEntity, nil
            end

            return World_Create(pos, ang, self)

        end

        function ITEM:_TryMoveFromWorld()
            local ent = self._worldEntity
            if not IsValid(ent) then return end

            self:_Entity_Unlink(ent)
            ent:Remove()
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
                if not inv:CanPut(pos, self:GetSize(), self) then
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
                pos = inv:FitPosition(pos_hint, self:GetSize(), self)
            else
                pos = inv:FitPosition(pos_hint, self:GetSize())
            end

            if pos == nil then
                return "stp.inv.error.no_place"
            end

            self:_TryMoveToInventory_Generic(inv, pos, oldinv)
        end


        function ITEM:NetGetRecipients(recip)
            local ent = self._worldEntity
            if IsValid(ent) then
                recip:AddPVS(ent:GetPos())
            end

            local inv = self:GetInventory()
            if inv ~= nil then
                inv:NetGetRecipients(recip)
            end

            hook.Run("stp.inv.Item.GetCustomRecipients", self, recip)
        end
    
    else
        function ITEM:_OnInventoryChanged(old_inv, new_inv)
            if old_inv ~= nil then
                old_inv:TakeItem(self)
            end

            if new_inv ~= nil then
                new_inv:PutItem(self)
            end
        end

        function ITEM:_OnItemPosChanged(old_pos, new_pos)
            local inv = self:GetInventory()
            if inv == nil then return end
                
            inv:MoveItem(self, new_pos)
        end
    end

sinv.Item = sobj.Register(ITEM)