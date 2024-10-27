--[[
    utils.lua
    Part of FourTwenty Fishing System
    https://fourtwenty.dev | https://github.com/FourTwentyDev
    
    Utility functions for the fishing system
    Version: 1.0.0
]]

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end