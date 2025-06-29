local check_ty = stp.CheckType

local PANEL = {}

function PANEL:Init()
    self:MakePopup()

    local container = self:Add("Panel")
    container:Dock(TOP)
    do
        self._layout = container:Add("stp.inv.UiInvLayout")
    end
end

function PANEL:SetInventory(inv)
    check_ty(inv, "inv", "table")

    self._inventory = inv

    self._layout:SetInventory(inv)
end


derma.DefineControl("stp.inv.UiInv", "GUI representation of inventory", PANEL, "DFrame")