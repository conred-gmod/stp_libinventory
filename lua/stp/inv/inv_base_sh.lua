local sinv = stp.inv
local sinvsch = stp.inv.schema
local sobj = stp.obj
local snet = stp.obj.net

local check_ty = stp.CheckType

-- Base Inventory metatable
local INV = sobj.BeginTrait("stp.inv.InventoryBase")
    sobj.ApplyMany(INV, 
        snet.EasyComposite
    )

    sobj.MarkAbstract(INV, "GetItems", "function")

    sobj.MarkAbstract(INV, "CanPut", "function")
    sobj.MarkAbstract(INV, "FitPosition", "function")

    sobj.MarkAbstract(INV, "TakeItem", "function")
    sobj.MarkAbstract(INV, "PutItem", "function")
    sobj.MarkAbstract(INV, "MoveItem", "function")

    -- TODO: Height/GetHeight
    -- TODO: Width/GetWidth
    
    if SERVER then
        function INV:NetGetRecipients(recip)
            hook.Run("stp.inv.Inv.GetCustomRecipients", self, recip)
        end
    end


sinv.InventoryBase = sobj.Register(INV)