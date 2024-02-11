local inv = stp.inv or stp.RecursiveRemoveFalseValues({
    schema = {}
})
stp.inv = inv

stp.IncludeList("stp/inv/", {
    "invitem_sh.lua"
})