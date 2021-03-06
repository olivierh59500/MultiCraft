

-- Function that get the input/output rules of the delayer
local delayer_get_output_rules = function(node)
    local rules = {{x = 0, y = 0, z = 1}}
    for i = 0, node.param2 do
        rules = mesecon:rotate_rules_left(rules)
    end
    return rules
end

local delayer_get_input_rules = function(node)
    local rules = {{x = 0, y = 0, z = -1}}
    for i = 0, node.param2 do
        rules = mesecon:rotate_rules_left(rules)
    end
    return rules
end

-- Functions that are called after the delay time

local delayer_turnon = function(params)
    local rules = delayer_get_output_rules(params.node)
    mesecon:receptor_on(params.pos, rules)
end

local delayer_turnoff = function(params)
    local rules = delayer_get_output_rules(params.node)
    mesecon:receptor_off(params.pos, rules)
end

local delayer_activate = function(pos, node)
    local def = minetest.registered_nodes[node.name]
    local time = def.delayer_time
    mesecon:swap_node(pos, def.delayer_onstate)
    minetest.after(time, delayer_turnon , {pos = pos, node = node})
end

local delayer_deactivate = function(pos, node)
    local def = minetest.registered_nodes[node.name]
    local time = def.delayer_time
    mesecon:swap_node(pos, def.delayer_offstate)
    minetest.after(time, delayer_turnoff, {pos = pos, node = node})
end

-- Register the 2 (states) x 4 (delay times) delayers
local done = false
for i = 1, 4 do
local groups = {}
if i == 1 and not done then
    groups = {bendy=2,snappy = 1,dig_immediate=2, mese = 1}
    done = true
else
    groups = {bendy=2,snappy = 1,dig_immediate=2, not_in_creative_inventory=1}
end

local delaytime
if      i == 1 then delaytime = 0.1
elseif  i == 2 then delaytime = 0.3
elseif  i == 3 then delaytime = 0.5
elseif  i == 4 then delaytime = 1.0
end

local boxes
if i == 1 then
boxes = {
    { -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 },     -- the main slab
    { 6/16, -6/16, -1/16, 4/16, -1/16, 1/16},     -- still torch
    { 0/16, -6/16, -1/16, 2/16, -1/16, 1/16},     -- moved torch
}
elseif i == 2 then
boxes = {
    { -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 },     -- the main slab
    { 6/16, -6/16, -1/16, 4/16, -1/16, 1/16},     -- still torch
    { -2/16, -6/16, -1/16, 0/16, -1/16, 1/16},     -- moved torch
}
elseif i == 3 then
boxes = {
    { -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 },     -- the main slab
    { 6/16, -6/16, -1/16, 4/16, -1/16, 1/16},     -- still torch
    { -4/16, -6/16, -1/16, -2/16, -1/16, 1/16},     -- moved torch
}
elseif i == 4 then
boxes = {
    { -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 },     -- the main slab
    { 6/16, -6/16, -1/16, 4/16, -1/16, 1/16},     -- still torch
    { -6/16, -6/16, -1/16, -4/16, -1/16, 1/16},     -- moved torch
}
end

minetest.register_node("mesecons_delayer:delayer_off_"..tostring(i), {
    description = "Delayer",
    drawtype = "nodebox",
    tiles = {
        "mesecons_delayer_off.png",
        "mesecons_delayer_bottom.png",
        "mesecons_delayer_ends_off.png",
        "mesecons_delayer_ends_off.png",
        "mesecons_delayer_sides_off.png",
        "mesecons_delayer_sides_off.png"
        },
    wield_image = "mesecons_delayer_off.png",
    walkable = true,
    selection_box = {
        type = "fixed",
        fixed = { -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 },
    },
    node_box = {
        type = "fixed",
        fixed = boxes
    },
    groups = groups,
    paramtype = "light",
    paramtype2 = "facedir",
    sunlight_propagates = true,
    drop = 'mesecons_delayer:delayer_off_1',
    on_punch = function (pos, node)
        if node.name=="mesecons_delayer:delayer_off_1" then
            mesecon:swap_node(pos,"mesecons_delayer:delayer_off_2")
        elseif node.name=="mesecons_delayer:delayer_off_2" then
            mesecon:swap_node(pos,"mesecons_delayer:delayer_off_3")
        elseif node.name=="mesecons_delayer:delayer_off_3" then
            mesecon:swap_node(pos,"mesecons_delayer:delayer_off_4")
        elseif node.name=="mesecons_delayer:delayer_off_4" then
            mesecon:swap_node(pos,"mesecons_delayer:delayer_off_1")
        end
    end,
    delayer_time = delaytime,
    delayer_onstate = "mesecons_delayer:delayer_on_"..tostring(i),
    sounds = default.node_sound_stone_defaults(),
    mesecons = {
        receptor =
        {
            state = mesecon.state.off,
            rules = delayer_get_output_rules
        },
        effector =
        {
            rules = delayer_get_input_rules,
            action_on = delayer_activate
        }
    }
})


minetest.register_node("mesecons_delayer:delayer_on_"..tostring(i), {
    description = "You hacker you",
    drawtype = "nodebox",
    tiles = {
        "mesecons_delayer_on.png",
        "mesecons_delayer_bottom.png",
        "mesecons_delayer_ends_on.png",
        "mesecons_delayer_ends_on.png",
        "mesecons_delayer_sides_on.png",
        "mesecons_delayer_sides_on.png"
        },
    walkable = true,
    selection_box = {
        type = "fixed",
        fixed = { -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 },
    },
    node_box = {
        type = "fixed",
        fixed = boxes
    },
    groups = {bendy = 2, snappy = 1, dig_immediate = 2, not_in_creative_inventory = 1},
    paramtype = "light",
    paramtype2 = "facedir",
    sunlight_propagates = true,
    drop = 'mesecons_delayer:delayer_off_1',
    on_punch = function (pos, node)
        if node.name=="mesecons_delayer:delayer_on_1" then
            mesecon:swap_node(pos,"mesecons_delayer:delayer_on_2")
        elseif node.name=="mesecons_delayer:delayer_on_2" then
            mesecon:swap_node(pos,"mesecons_delayer:delayer_on_3")
        elseif node.name=="mesecons_delayer:delayer_on_3" then
            mesecon:swap_node(pos,"mesecons_delayer:delayer_on_4")
        elseif node.name=="mesecons_delayer:delayer_on_4" then
            mesecon:swap_node(pos,"mesecons_delayer:delayer_on_1")
        end
    end,
    delayer_time = delaytime,
    delayer_offstate = "mesecons_delayer:delayer_off_"..tostring(i),
    mesecons = {
        receptor =
        {
            state = mesecon.state.on,
            rules = delayer_get_output_rules
        },
        effector =
        {
            rules = delayer_get_input_rules,
            action_off = delayer_deactivate
        }
    }
})
end

minetest.register_craft({
    output = "mesecons_delayer:delayer_off_1",
    recipe = {
        {"mesecons_torch:mesecon_torch_on", "", "mesecons_torch:mesecon_torch_on"},
        {"default:stone","default:stone", "default:stone"},
    }
})
