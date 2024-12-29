if GetResourceState('qb-core') ~= 'started' or GetResourceState('qbx_core') == 'started' then return end

local config = require 'shared.config'

local QBCore = exports['qb-core']:GetCoreObject()

function AddItem(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.AddItem(config.item, 1)
end

function RemoveItem(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.RemoveItem(config.item, 1)
end

QBCore.Functions.CreateUseableItem(config.item, function(source)
    TriggerClientEvent("um-skateboard:spawn:skateboard", source)
end)
