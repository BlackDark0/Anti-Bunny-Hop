
local Config = Config or {}
local MaxJumpsBeforeFall = Config.MaxJumpsBeforeFall or 15
local Framework = Config.Framework or 'qbcore'

local QBCore, ESX

Citizen.CreateThread(function()
    while QBCore == nil and ESX == nil do
        Citizen.Wait(0)
        if Framework == 'qbcore' and exports['qb-core'] then
            QBCore = exports['qb-core']:GetCoreObject()
        elseif Framework == 'esx' and exports['esx:getSharedObject'] then
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        end
    end
end)

local function showNotificationQBCore(message, type)
    if QBCore and QBCore.Functions then
        QBCore.Functions.Notify(message, type)
    end
end

local function showNotificationESX(message)
    if ESX and ESX.ShowNotification then
        ESX.ShowNotification(message)
    end
end

local function showNotification(message)
    if Framework == 'qbcore' then
        showNotificationQBCore(message, 'error')
    elseif Framework == 'esx' then
        showNotificationESX(message)
    end
end

Citizen.CreateThread(function()
    local JumpCount = 0
    while true do
        Citizen.Wait(1)
        local ped = PlayerPedId()

        if IsPedOnFoot(ped) and not IsPedSwimming(ped) and (IsPedRunning(ped) or IsPedSprinting(ped)) and not IsPedClimbing(ped) and IsPedJumping(ped) and not IsPedRagdoll(ped) then
            JumpCount = JumpCount + 1

            if JumpCount >= MaxJumpsBeforeFall then
                SetPedToRagdoll(ped, 5000, 1400, 2)
                JumpCount = 0
                showNotification('Has alcanzado el número máximo de saltos y te has caído.')
            end
        else
            Citizen.Wait(500)
        end
    end
end)
