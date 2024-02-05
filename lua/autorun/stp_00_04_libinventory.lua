local function DoLoad()
    assert(stp ~= nil, "stpLib is not loaded or not added as addon!")
    stp.IncludeFile("stp/inv/_include.lua")
end

DoLoad()

concommand.Add("stpinv_reload_full_sv", function()
    assert(SERVER)

    print("==== Full reload begin")
    DoLoad()
    if SERVER then
        for _, ply in ipairs(player.GetHumans()) do
            ply:ConCommand("stpinvreload_full_cl")
        end
    end

    print("==== Full reload end")
end)

if CLIENT then
    concommand.Add("stpinv_reload_full_cl", function()
        print("==== Full reload begin")
        DoLoad()
        print("==== Full reload end")
    end)
end
