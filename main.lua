---------------------------------------------------------------------------------
-- Tuki Monitor
-- Alberto Vera Espitia
-- GeekBucket 2017
---------------------------------------------------------------------------------

display.setStatusBar( display.DarkStatusBar )
display.setDefault( "background", 1, 1, 1 )

local Globals = require( "src.Globals" )
local composer = require( "composer" )
local DBManager = require('src.DBManager')
DBManager.setupSquema() 

local dbConfig = DBManager.getSettings()
if dbConfig.id == 0 then
    composer.gotoScene("src.Login")
else
    composer.gotoScene("src.Home")
end

