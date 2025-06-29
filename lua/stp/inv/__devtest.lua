local sinv = stp.inv

print("---- stp_rpfw: __devtest.lua start")

if CLIENT then
    
    concommand.Add("stpinv_devtest_ui", function()
        local frame = vgui.Create("stp.inv.UiInv")
        frame:SetSize(800, 600)
        frame:Center()
        frame:SetInventory({
            GetWidth = function() return 6 end,
            GetHeight = function() return 3 end,
            GetItems = function() 
                return {
                    {
                        GetSize = function() return {Width = 1, Height = 1} end,
                    },
                    {
                        GetSize = function() return {Width = 2, Height = 1} end
                    },
                    {
                        GetSize = function() return {Width = 1, Height = 2} end
                    },
                }
            end,
        })
        -- frame:Center()
    end)

end

print("---- stp_rpfw: __devtest.lua end")