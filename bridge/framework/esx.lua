if GetResourceState('es_extended') ~= 'started' then return end

local config = require 'shared.config'

local ESX = exports.es_extended:getSharedObject()

function AddItem(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    xPlayer.addInventoryItem(config.item, 1)
end

function DeleteItem(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    xPlayer.removeInventoryItem(config.item, 1)
end

ESX.RegisterUsableItem(config.item, function(source)
    TriggerClientEvent("um-skateboard:spawn:skateboard", source)
end)
