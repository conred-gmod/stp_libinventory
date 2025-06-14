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