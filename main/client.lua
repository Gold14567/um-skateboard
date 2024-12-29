local skateboard = {}
local Dir = {}
local Attached = nil
local overSpeed = false
local spawned = false

local config = require 'shared.config'
local controls = require 'shared.controls'

local function configureSkateboard(entity)
	local handling = require 'shared.handling'
	for k, v in pairs(handling) do
		SetVehicleHandlingFloat(entity, "CHandlingData", k, v)
	end
end

local function makeFakeSkateboard(ped, remove) -- The animation for picking up and placing the board
	DebugNotify({ "makeFakeSkateboard", ped, remove })

	local prop = CreateSkateProp({ prop = config.prop, coords = vec4(0, 0, 0, 0), false, true })
	AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, 57005), 0.3, 0.08, 0.09, -86.0, -60.0, 50.0, true, true,
		false, false, 1, true)
	lib.playAnim(cache.ped, "pickup_object", "pickup_low")

	if remove then
		skateboard.Skate = NetworkGetNetworkIdFromEntity(skateboard.Skate)
		skateboard.Bike = NetworkGetNetworkIdFromEntity(skateboard.Bike)
		skateboard.Driver = NetworkGetNetworkIdFromEntity(skateboard.Driver)
		TriggerServerEvent('um-skateboard:server:pickupSkateboard', skateboard)
		ClearPedTasks(cache.ped)
	end

	Wait(900)
	DestroyProp(prop)
end
---- 176
local function pickupSkateboard()
	if not DoesEntityExist(skateboard.Bike) and not Attached then return end

	RemoveLocalEntityTarget(skateboard.Skate)
	RemoveLocalEntityTarget(skateboard.Driver)
	RemoveLocalEntityTarget(skateboard.Bike)
	Attached = false
	Wait(100)
	makeFakeSkateboard(cache.ped, true) -- pick up animation
	skateboard = {}
	Dir = {}
end


local function enterSkateboard()
	if not spawned and not DoesEntityExist(skateboard.Skate) then return end

	AttachEntityToEntity(cache.ped, skateboard.Bike, 20, 0.0, 0.15, 0.05, 0.0, 0.0, -15.0, true, true, false, true, 1,
		true)
	SetEntityCollision(cache.ped, true, true)
	Attached = true

	lib.playAnim(cache.ped, "move_strafe@stealth", "idle", nil, -4.0, nil, 9)

	CreateThread(function()
		while Attached do
			StopCurrentPlayingAmbientSpeech(skateboard.Driver)
			overSpeed = (GetEntitySpeed(skateboard.Bike) * 3.6) > 90
			local rotation = GetEntityRotation(skateboard.Bike)
			if (-40.0 < rotation.x and rotation.x > 40.0) or (-40.0 < rotation.y and rotation.y > 40.0) then
				DetachEntity(cache.ped, false, false)
				TaskVehicleTempAction(skateboard.Driver, skateboard.Bike, 1, 1)
				Attached = false
				Dir = {}
				StopAnimTask(cache.ped, "move_strafe@stealth", "idle", 0.5)
				SetPedToRagdoll(cache.ped, 5000, 4000, 0, true, true, false)
			end

			if not DoesEntityExist(skateboard.Bike) or GetPedInVehicleSeat(skateboard.Bike, -1) ~= skateboard.Driver then
				RemoveLocalEntityTarget(skateboard.Skate)
				RemoveLocalEntityTarget(skateboard.Bike)
				RemoveLocalEntityTarget(skateboard.Driver)
				Attached = false
				Wait(100)
				makeFakeSkateboard(cache.ped, true)
				skateboard = {}
				Dir = {}
			end

			if not IsEntityAttachedToEntity(cache.ped, skateboard.Bike) then
				DetachEntity(cache.ped, false, false)
				TaskVehicleTempAction(skateboard.Driver, skateboard.Bike, 6, 2000)
				Attached = false
				Dir = {}
				StopAnimTask(cache.ped, "move_strafe@stealth", "idle", 0.5)
			end
			Wait(1000)
		end
	end)
end

local function addTargetSkateEntity()
	local options = {
		{
			action = function() enterSkateboard() end,
			icon = string.format('fas fa-%s', config.icons.getOnSkateBoard),
			label = config.lang.getOnSkateBoard,
			board = skateboard.Skate
		},
		{
			action = function() pickupSkateboard() end,
			icon = string.format('fas fa-%s', config.icons.pickupSkateBoard),
			label = config.lang.pickupSkateBoard,
			board = skateboard.Skate
		},
	}

	AddLocalCreateEntityTarget(skateboard.Skate, options, config.targetDistance)
	AddLocalCreateEntityTarget(skateboard.Driver, options, config.targetDistance)
	AddLocalCreateEntityTarget(skateboard.Bike, options, config.targetDistance)

	DebugNotify({ "addTargetSkateEntity", skateboard.Skate, skateboard.Driver, skateboard.Bike })
end


--- 1- First work event to be called
RegisterNetEvent("um-skateboard:spawn:skateboard", function()
	if GetInvokingResource() ~= nil then return end

	local ped = cache.ped

	if IsPedSittingInAnyVehicle(ped) then return end

	TriggerServerEvent("um-skateboard:server:placeSkateboard")

	local pedCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.5, -40.5)
	skateboard.Bike = CreateBike("triBike3", vec4(pedCoords.x, pedCoords.y, pedCoords.z, 0.0))
	skateboard.Skate = CreateSkateProp({ prop = config.prop, coords = vec4(pedCoords.x, pedCoords.y, pedCoords.z, 0.0) },
		true,
		true)

	while not DoesEntityExist(skateboard.Bike) or not DoesEntityExist(skateboard.Skate) do Wait(5) end

	SetEntityNoCollisionEntity(skateboard.Bike, ped, false)
	SetEntityNoCollisionEntity(skateboard.Skate, ped, false)

	configureSkateboard(skateboard.Bike)

	SetEntityCompletelyDisableCollision(skateboard.Bike, true, true)
	SetEntityCompletelyDisableCollision(skateboard.Skate, true, true)

	SetEntityVisible(skateboard.Bike, config.debug, false)

	AttachEntityToEntity(skateboard.Skate, skateboard.Bike, GetPedBoneIndex(ped, 28422), 0.0, 0.0, -0.60, 0.0,
		0.0, 90.0, false, true, true, true, 1, true)

	skateboard.Driver = ClonePed(ped, true, false, true)
	SetEntityCoords(skateboard.Driver, pedCoords.x, pedCoords.y, pedCoords.z, true, false, false, false)
	while not DoesEntityExist(skateboard.Driver) do Wait(0) end

	SetEntityNoCollisionEntity(skateboard.Driver, ped, false)
	SetEntityCompletelyDisableCollision(skateboard.Driver, true, true)

	SetEnableHandcuffs(skateboard.Driver, true)
	SetEntityInvincible(skateboard.Driver, true)
	FreezeEntityPosition(skateboard.Driver, true)

	while not IsPedSittingInAnyVehicle(skateboard.Driver) do
		SetEntityVisible(skateboard.Driver, config.debug, false)
		TaskWarpPedIntoVehicle(skateboard.Driver, skateboard.Bike, -1)
		Wait(10)
	end


	addTargetSkateEntity()
	makeFakeSkateboard(ped)

	DisableCamCollisionForEntity(skateboard.Bike)
	DisableCamCollisionForEntity(skateboard.Skate)
	DisableCamCollisionForEntity(skateboard.Driver)
	SetVehicleDoorsLocked(skateboard.Bike, 10)

	local offsetCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.5, 1.5)
	SetEntityCoords(skateboard.Bike, offsetCoords.x, offsetCoords.y, offsetCoords.z, false, false, false, false)
	SetEntityHeading(skateboard.Bike, GetEntityHeading(cache.ped) + 90)


	Dir = {}
	spawned = true
end)


---? Key Mapping ---
RegisterKeyMapping('skategetoff', controls.exit.name, 'keyboard', controls.exit.key)
RegisterCommand('skategetoff', function()
	if not Attached or IsEntityInAir(skateboard.Bike) then return end
	DetachEntity(cache.ped, false, false)
	TaskVehicleTempAction(skateboard.Driver, skateboard.Bike, 1, 100)
	Attached = false
	Dir = {}
	ClearPedTasks(cache.ped)
end)

RegisterKeyMapping('+skateforward', controls.up.name, 'keyboard', controls.up.key)
RegisterCommand('+skateforward', function()
	if not Attached then return end

	if overSpeed or Dir.forward then return end

	CreateThread(function()
		Dir.forward = true
		while Dir.forward do
			local action = Dir.left and 7 or (Dir.right and 8 or 9)
			TaskVehicleTempAction(skateboard.Driver, skateboard.Bike, action, 0.1)
			Wait(50)
		end
	end)
end)

RegisterCommand('-skateforward', function()
	if not Attached then return end

	Dir.forward = nil
	TaskVehicleTempAction(skateboard.Driver, skateboard.Bike, 1, 1)
end)

RegisterKeyMapping('+skatebackward', 'Skateboard: Backward', 'keyboard', 'DOWN')
RegisterCommand('+skatebackward', function()
	if not Attached then return end

	if overSpeed or Dir.backward then return end

	CreateThread(function()
		Dir.backward = true
		while Dir.backward do
			local action = Dir.left and 13 or (Dir.right and 14 or 22)
			TaskVehicleTempAction(skateboard.Driver, skateboard.Bike, action, 0.1)
			Wait(50)
		end
	end)
end)

RegisterCommand('-skatebackward', function()
	if not Attached then return end
	Dir.backward = nil
	TaskVehicleTempAction(skateboard.Driver, skateboard.Bike, 1, 1)
end)

RegisterKeyMapping('+skateleft', 'Skateboard: Left', 'keyboard', 'LEFT')
RegisterCommand('+skateleft', function()
	if not Attached then return end

	if not overSpeed then
		Dir.left = true
	end
end)
RegisterCommand('-skateleft', function()
	if not Attached then return end

	Dir.left = nil
end)

RegisterKeyMapping('+skateright', 'Skateboard: Right', 'keyboard', 'RIGHT')
RegisterCommand('+skateright', function()
	if not Attached then return end

	if not overSpeed then
		Dir.right = true
	end
end)
RegisterCommand('-skateright', function()
	if not Attached then return end

	Dir.right = nil
end)

RegisterKeyMapping('skatejump', 'Skateboard: Jump', 'keyboard', 'SPACE')
RegisterCommand('skatejump', function()
	if not Attached then return end
	if IsEntityInAir(skateboard.Bike) then return end

	local vel = GetEntityVelocity(skateboard.Bike)
	local duration = 0
	local boost = 0

	lib.playAnim(cache.ped, "move_crouch_proto", "idle_intro")

	while IsControlPressed(0, 22) do
		Wait(10)
		duration = duration + 10.0
	end

	boost = 6.0 * duration / 250.0
	if boost > 6.0 then boost = 6.0 end

	SetEntityVelocity(skateboard.Bike, vel.x, vel.y, vel.z + boost)

	StopAnimTask(cache.ped, "move_crouch_proto", "idle_intro", 0.5)

	lib.playAnim(cache.ped, "move_strafe@stealth", "idle", nil, -4.0, nil, 9)
end)

AddEventHandler('onResourceStop', function(resource)
	if resource ~= cache.resource then return end

	if DoesEntityExist(skateboard.Driver) then
		ClearAll(skateboard)
	end
end)
