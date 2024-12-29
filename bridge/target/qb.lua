if GetResourceState('qb-target') ~= 'started' then return end

local qb_target = exports['qb-target']

function AddLocalCreateEntityTarget(entity, opts, dist)
    local options = { options = opts, distance = dist }
    qb_target:AddTargetEntity(entity, options)
end

function RemoveLocalEntityTarget(entity)
    qb_target:RemoveTargetEntity(entity)
end
