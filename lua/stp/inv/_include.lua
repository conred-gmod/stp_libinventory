local inv = stp.inv or stp.RecursiveRemoveFalseValues({
    schema = {}
})
stp.inv = inv

stp.IncludeList("stp/inv/", {
    "invitem_sh.lua",
    "ui_item_cl.lua",
    "ui_inv_cl.lua"
})