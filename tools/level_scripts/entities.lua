
local sk_definition_writer = require('sk_definition_writer')
local sk_scene = require('sk_scene')
local room_export = require('tools.level_scripts.room_export')
local trigger = require('tools.level_scripts.trigger')
local world = require('tools.level_scripts.world')
local signals = require('tools.level_scripts.signals')

local box_droppers = {}

for _, dropper in pairs(sk_scene.nodes_for_type('@box_dropper')) do
    local position = dropper.node.full_transformation:decompose()

    table.insert(box_droppers, {
        position,
        room_export.node_nearest_room_index(dropper.node),
        signals.signal_index_for_name(dropper.arguments[1] or ''),
    })
end

sk_definition_writer.add_definition('box_dropper', 'struct BoxDropperDefinition[]', '_geo', box_droppers)

local buttons = {}

for _, button in pairs(sk_scene.nodes_for_type('@button')) do
    local position = button.node.full_transformation:decompose()

    table.insert(buttons, {
        position,
        room_export.node_nearest_room_index(dropper.node),
        signals.signal_index_for_name(dropper.arguments[1] or ''),
        signals.signal_index_for_name(dropper.arguments[2] or ''),
    })
end

sk_definition_writer.add_definition('buttons', 'struct ButtonDefinition[]', '_geo', buttons)

local decor = {}

for _, decor_entry in pairs(sk_scene.nodes_for_type('@decor')) do
    local position, rotation = decor_entry.node.full_transformation:decompose()

    table.insert(decor, {
        position,
        rotation,
        room_export.node_nearest_room_index(decor_entry.node),
        'DECOR_TYPE_' .. decor_entry.arguments[1],
    })
end

sk_definition_writer.add_definition('decor', 'struct DecorDefinition', '_geo', decor)
sk_definition_writer.add_header('"decor/decor_object_list.h"')

local doors = {}

for _, door in pairs(sk_scene.nodes_for_type('@door')) do
    local position, rotation = door.node.full_transformation:decompose()

    table.insert(doors, {
        position,
        rotation,
        world.find_coplanar_doorway(position) - 1,
        signals.signal_index_for_name(door.arguments[1] or ''),
    })
end

sk_definition_writer.add_definition('doors', 'struct DoorDefinition[]', '_geo', doors)

local elevators = {}

local elevator_nodes = sk_scene.nodes_for_type('@elevator')

for _, elevator in pairs(elevator_nodes) do
    local position, rotation = elevator.node.full_transformation:decompose()

    local target_elevator = -1

    if elevator.arguments[2] == 'next_level' then
        target_elevator = #elevator_nodes
    else
        for other_index, other_elevator in pairs(elevator_nodes) do
            if other_elevator.arguments[1] == elevator.arguments[2] then
                target_elevator = other_index - 1
                break
            end
        end
    end

    table.insert(elevators, {
        position,
        rotation,
        room_export.node_nearest_room_index(elevator.node),
        target_elevator,
    })
end

sk_definition_writer.add_definition('elevators', 'struct ElevatorDefinition[]', '_geo', elevators)

local fizzlers = {}

for _, fizzler in pairs(sk_scene.nodes_for_type('@fizzler')) do
    local position, rotation = fizzler.node.full_transformation:decompose()

    table.insert(fizzlers, {
        position,
        rotation,
        2,
        2,
        room_export.node_nearest_room_index(fizzler.node),
    })
end

sk_definition_writer.add_definition('fizzlers', 'struct FizzlerDefinition[]', '_geo', fizzlers)

local pedestals = {}

for _, pedestal in pairs(sk_scene.nodes_for_type('@pedestal')) do
    local position = pedestal.node.full_transformation:decompose()

    table.insert(pedestals, {
        position,
        room_export.node_nearest_room_index(fizzlers.node),
    })
end

sk_definition_writer.add_definition('pedestals', 'struct PedestalDefinition[]', '_geo', pedestals)

local signage = {}

for _, signage_element in pairs(sk_scene.nodes_for_type('@signage')) do
    local position, rotation = signage_element.node.full_transformation:decompose()

    table.insert(signage, {
        position,
        rotation,
        room_export.node_nearest_room_index(signage_element.node),
        sk_definition_writer.raw(signage_element.arguments[1]),
    })
end

sk_definition_writer.add_definition('signage', 'struct SignageDefinition[]', '_geo', signage)

return {
    box_droppers = box_droppers,
    buttons = buttons,
    decor = decor,
    doors = doors,
    elevators = elevators,
    fizzlers = fizzlers,
    pedestals = pedestals,
    signage = signage,
}