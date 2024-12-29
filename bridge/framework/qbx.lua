if GetResourceState('qbx_core') ~= 'started' then return end

local config = require 'shared.config'

local ox_inventory = exports.ox_inventory
local qbx_core = exports.qbx_core

function AddItem(src)
    ox_inventory:AddItem(src, config.item, 1)
end

function RemoveItem(src)
    ox_inventory:RemoveItem(src, config.item, 1)
end

qbx_core:CreateUseableItem(config.item, function(source)
    TriggerClientEvent("um-skateboard:spawn:skateboard", source)
end)
