local inv = stp.inv or stp.RecursiveRemoveFalseValues({
    schema = {}
})
stp.inv = inv

stp.IncludeList("stp/inv/", {
    "common_sh.lua",
    "inv_base_sh.lua",
    "item_sh.lua",
    "inv_slot_sh.lua",
    "inv_sh.lua",

    "ui/item_cl.lua",
    "ui/inv_layout_cl.lua",
    "ui/inv_cl.lua",

    "__devtest.lua"
})