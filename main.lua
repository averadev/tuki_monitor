---------------------------------------------------------------------------------
-- Tuki Monitor
-- Alberto Vera Espitia
-- GeekBucket 2017
---------------------------------------------------------------------------------

display.setStatusBar( display.DarkStatusBar )
display.setDefault( "background", 1, 1, 1 )

local Globals = require( "src.Globals" )
local composer = require( "composer" )

for z = 1, 31, 1 do 
    valD[z] = math.random(0, 40)
    valT = valT + valD[z]
end


composer.gotoScene("src.Home")


--[[
local DBManager = require('src.DBManager')
DBManager.setupSquema() 
local dbConfig = DBManager.getSettings()
if dbConfig.id == '' then
    composer.gotoScene("src.Login")
else
    composer.gotoScene("src.Home")
end
]]