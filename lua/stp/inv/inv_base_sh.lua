local sinv = stp.inv
local sinvsch = stp.inv.schema
local sobj = stp.obj
local snet = stp.obj.net

local check_ty = stp.CheckType

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