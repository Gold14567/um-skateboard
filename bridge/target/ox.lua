if GetResourceState('ox_target') ~= 'started' then return end

local ox_target = exports.ox_target

function AddLocalCreateEntityTarget(entity, opts, dist)
    local options = {}
    for i = 1, #opts do
        options[i] = {
            icon = opts[i].icon,
            label = opts[i].label,
            item = opts[i].item or nil,
            groups = opts[i].job or opts[i].gang,
            onSelect = opts[i].action,
            canInteract = function(_, distance)
                return distance < dist and true or false
            end
        }
    end
    ox_target:addLocalEntity(entity, options)
end

function RemoveLocalEntityTarget(entity)
    ox_target:removeLocalEntity(entity, nil)
end
