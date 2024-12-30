return {
    debug = false,             -- Set to true to enable debug messages
    prop = 'v_res_skateboard', -- prop model
    item = 'skateboard',       -- item name
    baseVehicle = 'tribike3',  -- base vehicle (Attached)
    targetDistance = 2.5,      -- target distance
    ragdollSpeed = 90,         -- ragdoll speed
    jumpBoost = 6.0,           -- jump boost
    lang = {                   -- language
        enterSkateBoard = 'Drive',
        backoffSkateBoard = 'Back off',
        getOnSkateBoard = 'Ride',
        pickupSkateBoard = 'Pick up',
        usageSkateBoard = "Usage"
    },
    icons = { -- icons
        getOnSkateBoard = 'person-snowboarding',
        pickupSkateBoard = 'hand-back-fist',
        usageSkateBoard = 'info-circle'
    }
}
