local config = require 'shared.config'

local function debugNotify(...)
    if not config.debug then return end

    lib.print.info(...)
end

local function isEntityValid(netId, model)
    if not netId or netId == 0 then return end
    local entity = NetworkGetEntityFromNetworkId(netId)
    debugNotify("exists:", DoesEntityExist(entity))
    debugNotify("model:", GetEntityModel(entity), model)
    if not DoesEntityExist(entity) or (model and GetEntityModel(entity) ~= joaat(model)) then return end
    return entity
end

RegisterNetEvent('um-skateboard:server:placeSkateboard', function()
    local source = source
    debugNotify('removed 1 skateboard from:', source)
    RemoveItem(source)
end)


RegisterNetEvent('um-skateboard:server:pickupSkateboard', function(netIds)
    local source = source
    local sourcePed = GetPlayerPed(source)
    local sourceCoords = GetEntityCoords(sourcePed)

    debugNotify('picking up Skateboard')

    local skate = isEntityValid(netIds.Skate, config.prop)
    if not skate then return end

    debugNotify('skateboard is Valid')

    local skateCoords = GetEntityCoords(skate)
    local dist = #(sourceCoords - skateCoords)

    if dist > 20 then
        debugNotify('Distance too High. Distance:', dist)
        return
    end

    local bike = isEntityValid(netIds.Bike, 'triBike3')
    if not bike then return end

    debugNotify('bike is Valid')

    DeleteEntity(bike)
    DeleteEntity(skate)

    debugNotify('added item', source, config.item)
    AddItem(source)
end)
