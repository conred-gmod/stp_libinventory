local libinv = stp.inv
local libo = stp.obj
local libn = stp.obj.net

libinv.MAX_INV_SIZE = 256
libinv.INV_SIZE_BITS = 8

libinv.ITEM_DIR = {
    RIGHT = 0,
    DOWN = 1,
    LEFT = 2,
    UP = 3
}


local INV = libo.BeginObject("stp.inv.Inventory")
libo.ApplyMany(INV, 
    libn.EasyComposite
)

libo.MarkAbstract(INV, "GetName", "function")
libo.MarkAbstract(INV, "GetDesc", "function")
libo.MarkAbstract(INV, "GetSize", "function")

libo.Register(INV)
libinv.Inventory = INV

local ITEM = libo.BeginTrait("stp.inv.Item")
libo.ApplyMany(ITEM, 
    libn.EasyComposite
)

libo.ConstructNestedType(ITEM, "Inventory", libn.MakeEasyVar(libn.schema.StpNetworkable, 
    "GetInventory", SERVER and "_SetInventory", nil, { DefaultIsNil = true })
)

libo.ConstructNestedType(ITEM, "WorldEntity", libn.MakeEasyVar(libn.schema.StpNetworkable, 
    "GetWorldEntity", SERVER and "_SetWorldEntity", nil, { DefaultIsNil = true })
)




libo.Register(ITEM)
libinv.Item = ITEM