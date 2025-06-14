AddCSLuaFile()

ENT.Base = "base_entity"
ENT.Type = "anim"
EMT.PrintName = "Generic Item"
ENT.Spawnable = false

ENT.stpInv_IsItem = true

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "ItemID")
end

function ENT:GetItem()
    return stp.obj.Tracker.Get(self:GetItemID())
end

function ENT:_SetItem(item)
    if item == nil then
        self:SetItemID(0)
    else
        self:SetItemID(item.TrackId)
    end
end

function ENT:Initialize()
    local item = self:GetItem()
    if item == nil then
        MsgN("stpInv: item entity ",self," has no associated item. Removing.")
        self:Remove()
        return
    end

    item:Entity_Init(self)
end

function ENT:OnRemove(fullUpdate)
    if fullUpdate then return end

    local item = self:GetItem()
    if item == nil then return end

    item:_Entity_Unlink(self)

    if SERVER then
        item:Remove()
    end
end